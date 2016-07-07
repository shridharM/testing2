/*--------------------------- ROLLUPBATCH----------------------------
|  Class RollupBatch
|
|  Purpose: When this class is called in a organiaztion it looks to see
|  if the a transaction has been inserted, updated or deleted and updates
|  the following information:
|
|  Last Modified Date: 21/06/2016
 *-------------------------------------------------------------------*/
global class RollupBatch implements Database.Batchable<sObject>, Database.stateful {
    //Deprecated Global Variables Start//
    global List<Contact> contactRecord;
    global static Map <string, decimal> conversion_rates;
    global Set <string> cid;
    global DateTime previousRunTime;
    global Static DateTime lastRunTime;
    global static Boolean multiCurrencyEn;
    global static Set <Id> contactFilter;
    global static Integer orgFiscalStart;
    //Deprecated Global Variables End//
    
    //Public Variables Start//
    global static String userIsoCode;
    public static Map <string, decimal> conversionRates = new Map <string, decimal>();
    public DateTime lastTimeRun;
    public static Boolean multiCurrencyOrganization;
    public static Integer orgFiscalYearStartMonth;
    public Set <Id> alreadyUpdatedContacts = new Set<Id>();
    public Set <Id> contactsForUpdate = new Set <Id>();
    //Public Variables End//
    
    //DEFAULT CONSTRUCTOR//
    global RollupBatch(){ }
    
    //PARAMETERIZED CONSTRUCTOR//
    global RollupBatch(DateTime setLastRun){
        this.lastTimeRun = setLastRun;    
        System.Debug('Constructor: ' + lastTimeRun);
    }
    
    global RollupBatch(Set <Id> pastUpdatedContacts, DateTime setLastRun){
        this.alreadyUpdatedContacts = pastUpdatedContacts;
        this.lastTimeRun = setLastRun;    
        System.Debug('Constructor: ' + lastTimeRun);    
        System.Debug('Constructor: ' + alreadyUpdatedContacts);
    }
    
    //Temporarily disabled until further notice
    global RollupBatch(Set <Id> specificContactsToUpdate){
        /*this.contactsForUpdate = specificContactsToUpdate;  
        System.Debug('Constructor: ' + alreadyUpdatedContacts);*/
    }
    
    /*----------------------------------- START ------------------------
    |  Function Start
    |
    |  Purpose: RollupBatch starts here. Here it sets the organizations fiscal year start,
    |  sets lastTimeRun if it isn't already set, then calls BuildContactQuery in order
    |  to build the query that will be used to get contacts to update.
    |
    |  Parameters: Database.BatchableContext BC
    |
    |  Returns:  Database.getQueryLocator(query)
    |  Return Type: List<Contact>
     *-------------------------------------------------------------------*/
    global Database.Querylocator Start(Database.BatchableContext BC){
        System.Debug('Start:' + alreadyUpdatedContacts);
        orgFiscalYearStartMonth = GetFiscalStartMonth();

        System.Debug('Before: ' + lastTimeRun);
        if (lastTimeRun == null) {
            List<AsyncApexJob> st = database.query('SELECT CompletedDate FROM AsyncApexJob WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = \'RollupBatch\') AND (Status = \'Completed\' AND numberOfErrors = 0) ORDER BY CreatedDate DESC LIMIT 1');   
            if(st.size() > 0)
            lastTimeRun = st[0].CompletedDate;
        }
        System.Debug('After: ' + lastTimeRun);

        string query = BuildContactQuery();
        System.Debug(query);
        System.Debug('Contacts For Update:' + contactsForUpdate);
        return Database.getQueryLocator(query);
    }
    
    /*----------------------- BUILDCONTACTQUERY ------------------------
    |  Function BuildContactQuery
    |
    |  Purpose: Here a query to grab all the rollup fields relating to a contact
    |  is built. It will use the function GetContactsForUpdate in order to append
    |  a where clause in order to update only contacts that need to be updated.
    |
    |  Returns:  query
    |  Return Type: String
     *-------------------------------------------------------------------*/
    public string BuildContactQuery(){
        System.Debug('Is fiscal Year: ' + IsFiscalOrCalendarYearStart());
        System.Debug('lastRunTime: ' + (lastTimeRun != null));    
        if(IsFiscalOrCalendarYearStart() && lastTimeRun != null && (contactsForUpdate.Size() == 0 || contactsForUpdate.isEmpty()))
            contactsForUpdate = GetContactsForUpdate();
        
        System.Debug('contactsForUpdate:' + contactsForUpdate);
        string query = 'SELECT Id, causeview__Consecutive_Years_of_Giving__c, causeview__Consecutive_Years_of_Transactions__c, causeview__Last_Gift_Amount__c, causeview__Total_Lifetime_Gifts__c, causeview__Total_Lifetime_Giving__c, ';

        if(UserInfo.isMultiCurrencyOrganization()==true)
            query += 'CurrencyIsoCode, ';

        query += 'causeview__Total_Fiscal_Gifts__c, causeview__Total_Fiscal_Year_Giving__c, causeview__Total_Lifetime_Transactions__c, causeview__Total_Lifetime_Transaction_Amount__c, ';
        query += ' causeview__Date_of_Last_Gift__c,causeview__Date_of_First_Gift__c,causeview__Date_of_First_Transaction__c,causeview__Largest_Gift__c,causeview__Average_Gift__c,causeview__Date_of_Last_Transaction__c,causeview__Total_Giving_Two_Years_Ago__c, causeview__Total_Giving_Last_Year__c,causeview__Total_Fiscal_Transactions__c, causeview__Total_Fiscal_Transaction_Amount__c, causeview__Total_Lifetime_Fundraising__c, causeview__Total_Fiscal_Fundraising__c,causeview__Last_Payment_Amount__c,causeview__Last_Payment_Date__c'; 
        query += ' FROM Contact c'; 
        
        System.Debug('Is fiscal Year:' + IsFiscalOrCalendarYearStart());
        System.Debug('lastRunTime: ' + (lastTimeRun != null));   
        if(IsFiscalOrCalendarYearStart() && lastTimeRun != null)
            query += ' WHERE Id IN :contactsForUpdate';

        return query;                              
    }

    /*----------------------- GETCONTACTSFORUPDATE ------------------------
    |  Function GetContactsForUpdate
    |
    |  Purpose: Here a query is run in order to obtain a list of contact Ids that
    |  need to be updated. The result is then returned so that the list may be used.
    |
    |  Returns:  contactIdsForUpdating
    |  Return Type: List<Id>
     *-------------------------------------------------------------------*/
    private Set<Id> GetContactsForUpdate(){
        List<AggregateResult> queryResults = new List<AggregateResult>();
        Set <Id> contactIdsForUpdating = new Set <Id>();
        String query;
        
        query = 'SELECT causeview__Constituent__c FROM causeview__Gift__c WHERE (LastModifiedDate > :lastTimeRun OR (IsDeleted = True AND SystemModStamp > :lastTimeRun)) AND causeview__Constituent__c NOT IN :alreadyUpdatedContacts GROUP BY causeview__Constituent__c LIMIT 20000 ALL ROWS';
        
        queryResults = Database.query(query); //Runs the query and places the resulting IDs in idsToBeUpdated
        
        for (AggregateResult currentGift : queryResults){
            contactIdsForUpdating.add((Id)currentGift.get('causeview__Constituent__c'));
        }
        if(contactIdsForUpdating.size() > 0){
            alreadyUpdatedContacts.addAll(contactIdsForUpdating);
        }
        System.Debug(contactIdsForUpdating);
        
        return contactIdsForUpdating;
    }    
    
    /*----------------------------------- EXECUTE ------------------------
    |  Function Execute
    |
    |  Purpose: Once start is finished and the list of contacts being updated
    |  is created, it is passed to execute. Execute takes a list of sObjects,
    |  in this case contacts, and calls methods to calculate the appropriate fields.
    |  
    |  Parameters: Database.BatchableContext BC, List<sObject> contactsToBeUpdated
     *-------------------------------------------------------------------*/  
    global void execute(Database.BatchableContext BC, List<sObject> contactsToBeUpdated){
        System.Debug('Execute:' + contactsToBeUpdated);
        Map <Id, Contact> contactsToBeUpdatedMap = new Map <Id, Contact>((List<Contact>)contactsToBeUpdated);                          
        Set <Id> householdIdsToUpdate = new Set <Id>();
        
        GetMultiCurrencySupport();
        
        householdIdsToUpdate = RecalculateTotalGiving(contactsToBeUpdated);
        RecalculateGiftDates(contactsToBeUpdatedMap);
        if (householdIdsToUpdate.size() > 0) RecalculateTotalHouseholdGiving(householdIdsToUpdate);
    }
    
    /*----------------------- GETMULTICURRENCYSUPPORT ---------------------
    |  Function GetMultiCurrencySupport
    |
    |  Purpose: Gets the users default ISO code and a list of the currency
    |  types the organization supports.
     *-------------------------------------------------------------------*/
    public static void GetMultiCurrencySupport(){        
        multiCurrencyOrganization = UserInfo.isMultiCurrencyOrganization();
        userIsoCode = UserInfo.getDefaultCurrency();
                               
        if(multiCurrencyOrganization==true){                 
            List<sObject> isoList = Database.query('SELECT IsoCode,ConversionRate, IsCorporate FROM CurrencyType');

            for(sObject isoCode: isoList)      
              conversionRates.put((String)isoCode.get('IsoCode'),(decimal)isoCode.get('ConversionRate'));      
        }   
    }
    
    /*----------------------- RECALCULATETOTALGIVING ------------------------
    |  Function RecalculateTotalGiving
    |
    |  Purpose: Here a query is run in order to obtain a list of contact Ids that
    |  need to be updated. The result is then returned so that the list may be used.
    |
    |  Returns:  contactIdsForUpdating
    |  Return Type: List<Id>
     *-------------------------------------------------------------------*/
    private static set<id> RecalculateTotalGiving(List<Contact> contacts){     
        System.Debug('Multi Currency2'+multiCurrencyOrganization);            //Displays multicurrency once again for debugging purposes.
        System.Debug('<======inside REcalculateTotalGiving======>');//Formatting string to display below the multicurrency.
        
        if (contacts == null || contacts.size() <= 0) return null;//Ensures that the Contacts list is populated with objects.
        
        causeview__BatchSettings__c             settings                =  causeview__BatchSettings__c.getInstance('Default'); //Pulls the default settings from the BatchSettings.
        String                                  RecordTypeIdforRollup1;
        List<String>                            RecordTypeIdsforRollup1 = new List<String>();
        Set <String>                            recordTypesToRollup               = new Set<String>();                                   //Set created to store record ids and ensure they are unique
        //Added by Nitin
        Map <Id, List<causeview__Gift__c>>      GiftRecordMap           = new Map<Id, List<causeview__Gift__c>>();             //map created to store contact ids, each id has a list of gifts attached to it
        Map <Id, List<causeview__payment__c>>   PaymentRecordMap        = new Map<Id, List<causeview__payment__c>>();          //map created to store contact ids, each id has a list of payments attached to it
        Map <Id, List<causeview__Solicitor__c>> softCreditRecordMap     = new Map<Id, List<causeview__Solicitor__c>>();
        Map<Id, List<causeview__Gift__c>>       GiftRecordMapPrimarySolicitor = new Map<Id, List<causeview__Gift__c>>();        //map created to store contact ids, each id has a list of softCredits attached to it
        
        String transactionRecordTypeId = [Select Name, Id From RecordType where Name ='Gift' AND NamespacePrefix = 'causeview' AND sObjectType = 'causeview__Gift__c' LIMIT 1].Id;
        System.Debug('transactionRecordTypeId is ' + transactionRecordTypeId);
        
        if(settings.causeview__Record_Type_Id_for_Rollups__c != null){
            RecordTypeIdforRollup1 = settings.causeview__Record_Type_Id_for_Rollups__c;
            System.Debug('RecordTypeIdforRollup1 is ' + RecordTypeIdforRollup1);
            
            RecordTypeIdsforRollup1 = SplitStringAtCommma(RecordTypeIdforRollup1, true);
            System.Debug('RecordTypeIdforRollup1 is ' + RecordTypeIdforRollup1);
        }
        
        for(RecordType loopCurrentRecordType : [Select Name, Id From RecordType where (Name ='Pledge' OR Name ='Gift') AND NamespacePrefix = 'causeview' AND sObjectType = 'causeview__Gift__c'])
            RecordTypeIdsforRollup1.add(loopCurrentRecordType.Id);             
        
        //Checks to make sure the records id list is not empty.
        if(RecordTypeIdsforRollup1.size()>0){
            //Adds the records type ids to recordIds to be processed and rolled up in the statements below.
            for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++){
                System.Debug('dbglog '+RecordTypeIdsforRollup1.size());
                recordTypesToRollup.add(RecordTypeIdsforRollup1[i]);
            }
        }
        
        Map<Id,Contact> contactsMap = new Map<Id,Contact>(contacts);
        set<id> householdIds = new set<id>();
        set<id> contactIds = new set<Id>();
        contactIds = contactsMap.keyset();
                
        System.Debug('Multi Currency'+multiCurrencyOrganization);//User debug displays the state of multiCurrency for the org.
        //Below is where the maps are constructed containing all of the fields to be rolled up
        
        //The following three headings: GIFTS, SOFT CREDIT and PAYMENTS query the database for their respective fields and add the results into maps to be totalled later on in the method.
        
        // GIFTS RELATED TO CONTACTS //
        if(multiCurrencyOrganization) 
        {
            for(causeview__Gift__c g : Database.query ('Select Id, convertCurrency(causeview__Amount__c), convertCurrency(causeview__Total_Gift_Amount__c), causeview__Status__c,causeview__HouseholdId__c, causeview__Gift_Date__c, RecordType.Name, RecordTypeId,causeview__Constituent__c,causeview__Primary_Solicitor__c From causeview__Gift__c where causeview__Constituent__c IN : contactIds OR causeview__Primary_Solicitor__c  IN : contactIds ORDER BY causeview__Gift_Date__c DESC,CreatedDate DESC ') )
            {  
                if(contactsMap.keySet().contains(g.causeview__Constituent__c)) 
                {
                    if(!GiftRecordMap.containsKey(g.causeview__Constituent__c)){
                        GiftRecordMap.put(g.causeview__Constituent__c, new List<causeview__Gift__c>());
                        }
                        GiftRecordMap.get(g.causeview__Constituent__c).add(g);
                        
                    if(g.causeview__HouseholdId__c !=null && g.causeview__HouseholdId__c != '')
                    {
                      householdIds.add(g.causeview__HouseholdId__c);
                    }
                }
                if(contactsMap.keySet().contains(g.causeview__Primary_Solicitor__c)) 
                {
                    if(!GiftRecordMapPrimarySolicitor.containsKey(g.causeview__Primary_Solicitor__c)){
                        GiftRecordMapPrimarySolicitor.put(g.causeview__Primary_Solicitor__c, new List<causeview__Gift__c>());
                    }
                    GiftRecordMapPrimarySolicitor.get(g.causeview__Primary_Solicitor__c).add(g);
                }
            }
        }
        else
        {
            for(causeview__Gift__c g : [Select Id,causeview__HouseholdId__c, causeview__Amount__c, causeview__Total_Gift_Amount__c, causeview__Status__c, causeview__Gift_Date__c,RecordType.Name, RecordTypeId, causeview__Constituent__c,causeview__Primary_Solicitor__c From causeview__Gift__c where (causeview__Constituent__c IN : contactIds OR causeview__Primary_Solicitor__c  IN : contactIds) ORDER BY causeview__Gift_Date__c DESC,CreatedDate DESC])
            {
                if(contactsMap.keySet().contains(g.causeview__Constituent__c)) 
                {
                    if(!GiftRecordMap.containsKey(g.causeview__Constituent__c)){
                        GiftRecordMap.put(g.causeview__Constituent__c, new List<causeview__Gift__c>());
                    }
                    GiftRecordMap.get(g.causeview__Constituent__c).add(g);
                    
                    if(g.causeview__HouseholdId__c !=null && g.causeview__HouseholdId__c != '')
                    {
                      householdIds.add(g.causeview__HouseholdId__c);
                    }
                }
                
                if(contactsMap.keySet().contains(g.causeview__Primary_Solicitor__c)) 
                {
                    if(!GiftRecordMapPrimarySolicitor.containsKey(g.causeview__Primary_Solicitor__c)){
                        GiftRecordMapPrimarySolicitor.put(g.causeview__Primary_Solicitor__c, new List<causeview__Gift__c>());
                    }
                    GiftRecordMapPrimarySolicitor.get(g.causeview__Primary_Solicitor__c).add(g);
                }
            }
        
        
        }
        
        // SOFT CREDIT RELATED TO CONTACTS //
        if(multiCurrencyOrganization){
            for(causeview__Solicitor__c s : Database.query('Select Id, convertCurrency(causeview__Amount__c), causeview__Gift_Date__c, causeview__Gift_Status__c, causeview__Solicitor__c From causeview__Solicitor__c where causeview__solicitor__c IN : contactIds')){
                if(!softCreditRecordMap.containsKey(s.causeview__Solicitor__c)){
                    softCreditRecordMap.put(s.causeview__Solicitor__c, new List<causeview__solicitor__c>());
                }
                softCreditRecordMap.get(s.causeview__Solicitor__c).add(s);
            }
        }
        else{
            for(causeview__solicitor__c s : [Select Id, causeview__Amount__c, causeview__Gift_Date__c, causeview__Gift_Status__c, causeview__Solicitor__c From causeview__solicitor__c where causeview__Solicitor__c IN : contactIds]){
                if(!softCreditRecordMap.containsKey(s.causeview__solicitor__c)){
                    softCreditRecordMap.put(s.causeview__Solicitor__c, new List<causeview__Solicitor__c>());
                }
                softCreditRecordMap.get(s.causeview__Solicitor__c).add(s);
            }
        }
        //new code for calculate last payment date and last payment amount 25-feb2-2015 
        // https://www.pivotaltracker.com/story/show/115068827 --> only for Approved Payments
        // PAYMENTS RELATED TO CONTACTS //        
        if(multiCurrencyOrganization){
            for(causeview__payment__c p: Database.query('select Id, Name , convertCurrency(causeview__Amount__c), causeview__Date__c , causeview__Status__c  ,causeview__Donation__r.causeview__Constituent__c ,causeview__Donation__r.RecordTypeId, causeview__Donation__r.RecordType.Name from causeview__payment__c where causeview__Donation__r.causeview__Constituent__c IN : contactIds AND causeview__Status__c  = \'Approved\' AND causeview__Donation__r.RecordTypeId IN : recordTypesToRollup ORDER BY causeview__Date__c DESC, CreatedDate DESC')){
                 if(!PaymentRecordMap.containsKey(p.causeview__Donation__r.causeview__Constituent__c)){
                        PaymentRecordMap.put(p.causeview__Donation__r.causeview__Constituent__c, new List<causeview__payment__c>());
                    }
                  PaymentRecordMap.get(p.causeview__Donation__r.causeview__Constituent__c).add(p);
            }
        }
        else{
            for(causeview__payment__c p: [select Id, Name , causeview__Amount__c,causeview__Date__c , causeview__Status__c  ,causeview__Donation__r.causeview__Constituent__c ,causeview__Donation__r.RecordTypeId, causeview__Donation__r.RecordType.Name from causeview__payment__c where causeview__Donation__r.causeview__Constituent__c IN : contactIds AND causeview__Status__c  = 'Approved' AND causeview__Donation__r.RecordTypeId IN : recordTypesToRollup ORDER BY causeview__Date__c DESC, CreatedDate DESC ]){
                if(!PaymentRecordMap.containsKey(p.causeview__Donation__r.causeview__Constituent__c))  {
                    PaymentRecordMap.put(p.causeview__Donation__r.causeview__Constituent__c, new List<causeview__payment__c>());
                }
              
                PaymentRecordMap.get(p.causeview__Donation__r.causeview__Constituent__c).add(p);
            }       
        } 
        //From here on is where the math for rollup takes place
        integer org;//org is set to the users organization id on the line below
        org = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
        List<Contact>   contactsToUpdate    = new List<Contact>();
        List<Date>      gDates              = new List<Date>();     //Gift date List object.
        List<Date>      tDates              = new List<Date>();     //Transaction date List object.
        //Iterates to total the total rollup fields in Contact.
        for(Contact c : contacts){
            Decimal lastGiftAmount = 0;
            Decimal lastPaymentAmount = 0;
            Decimal totalAmount = 0;        
            Decimal totalFiscalAmount = 0;
            Decimal totalGivingAmountLastYear = 0;
            Decimal totalCount = 0;
            Decimal totalFiscalCount = 0;
            Decimal totalGivingAmount = 0;
            Decimal totalFiscalGivingAmount = 0;
            Decimal totalGivingCount = 0;
            Decimal totalFiscalGivingCount = 0;
            Decimal total_additional_solicitations = 0;
            Decimal total_additional_solicitations1 = 0;
            Decimal totalAdditionalSolicitationsLastYear = 0;
            Decimal total_solicitations = 0;
            Decimal total_solicitations1 = 0;
            Decimal totalSolicitationsLastYear = 0;
            Decimal consecutive_years_of_giving = 0;
            Decimal consecutive_years_of_transactions = 0;
        
            if (GiftRecordMap.get(c.id) != null){
                //added by nitin on 26/09/2014  
                //Pivotal Tracker - Last Gift Amount field Not Calculating Only On Record Type = Gift
                for(causeview__Gift__c g : GiftRecordMap.get(c.id)){
                    if(recordTypesToRollup.contains(g.RecordTypeId)){
                        lastGiftAmount =g.causeview__Total_Gift_Amount__c;
                        break;
                    } 
                }       
            }
            //payment last amount
            if (PaymentRecordMap.get(c.id) != null)
            {
                for(causeview__Payment__c p : PaymentRecordMap.get(c.id)){
                    //if(transactionRecordTypeId.contains(p.causeview__Donation__r.RecordTypeId) && p.causeview__Donation__r.RecordType.Name == 'Gift' ){
                    if(recordTypesToRollup.contains(p.causeview__Donation__r.RecordTypeId)){
                        lastPaymentAmount = p.causeview__Amount__c;
                        break;
                    } 
                }       
            }    
            
            //if clause here totals up gift amounts by running through each gift per contact 
            if(GiftRecordMap.get(c.id) != null){    
                for(causeview__Gift__c g : GiftRecordMap.get(c.id)){//loops via the contact ids
                    if ((transactionRecordTypeId.contains(g.RecordTypeId))||(recordTypesToRollup.Contains(g.RecordTypeId))){
                        totalGivingAmount   += g.causeview__Total_Gift_Amount__c;
                        totalAmount         += g.causeview__Amount__c;
                        gDates.add(g.causeview__Gift_Date__c);
                        tDates.add(g.causeview__Gift_Date__c);
                        totalGivingCount++;
                        totalCount++;
                    }
                    else{
                        totalAmount += g.causeview__Amount__c;
                        tDates.add(g.causeview__Gift_Date__c);
                        totalCount++;
                    }        
                    if (GivingPowerUtility.isCurrentFiscal(g.causeview__Gift_Date__c, org)){
                        if ((transactionRecordTypeId.contains(g.RecordTypeId))||(recordTypesToRollup.Contains(g.RecordTypeId))){
                            totalFiscalGivingAmount     += g.causeview__Total_Gift_Amount__c;
                            totalFiscalAmount           += g.causeview__Amount__c;
                            totalFiscalGivingCount++;
                            totalFiscalCount++;
                        }
                        else{
                            totalFiscalAmount += g.causeview__Amount__c;
                            totalFiscalCount++;
                        }
                    }
                    if (GivingPowerUtility.isLastFiscalYear(g.causeview__Gift_Date__c, org)){
                        if ((transactionRecordTypeId.contains(g.RecordTypeId))||(recordTypesToRollup.Contains(g.RecordTypeId)))
                            totalGivingAmountLastYear += g.causeview__Total_Gift_Amount__c;
                    }
                }
            }
            if (softCreditRecordMap.get(c.id) != null){
                for(causeview__Solicitor__c s : softCreditRecordMap.get(c.id)){
                    total_additional_solicitations1 += (s.causeview__Amount__c == null) ? 0 : s.causeview__Amount__c;
                    //need to calculate only current fiscal year transaction
                    if (GivingPowerUtility.isCurrentFiscal(s.causeview__Gift_Date__c, org))
                         total_additional_solicitations += (s.causeview__Amount__c == null) ? 0 : s.causeview__Amount__c;
                    if (GivingPowerUtility.isLastFiscalYear(s.causeview__Gift_Date__c, org))
                         totalAdditionalSolicitationsLastYear += (s.causeview__Amount__c == null) ? 0 : s.causeview__Amount__c;
                }
            }
            
            if(GiftRecordMapPrimarySolicitor.get(c.Id) != null ){
                for(causeview__Gift__c g2 : GiftRecordMapPrimarySolicitor.get(c.Id))
                {
                    system.debug('<=Inside Primary=>'+g2);
                    total_solicitations1 += g2.causeview__Amount__c;
                    system.debug('total_solicitations==>'+total_solicitations);
                    
                    if (GivingPowerUtility.isCurrentFiscal(g2.causeview__Gift_Date__c, org)) {
                        system.debug('<=Inside Primary=>'+g2);
                        total_solicitations += g2.causeview__Amount__c;
                        system.debug('total_solicitations==>'+total_solicitations);
                    }
                    if (GivingPowerUtility.isLastFiscalYear(g2.causeview__Gift_Date__c, org)) {
                        system.debug('<=Inside Primary=>'+g2);
                        totalSolicitationsLastYear += g2.causeview__Amount__c;
                        system.debug('total_solicitations==>'+total_solicitations);
                    }
                }
            }
            
            System.Debug('Contact==>'+c.id);
            
            if (gDates.size() != 0){
                if (org == null){
                     consecutive_years_of_giving = GivingPowerUtility.ConseqFiscalYears(gDates, 1);
                }
                else{
                    consecutive_years_of_giving = GivingPowerUtility.ConseqFiscalYears(gDates, org);
                }
            }
            
            System.Debug('consecutive_years_of_giving== '+consecutive_years_of_giving);
            
            if (tDates.size() != 0){
                if (org == null){
                    consecutive_years_of_transactions = GivingPowerUtility.ConseqFiscalYears(tDates, 1);
                }
                else{
                    consecutive_years_of_transactions = GivingPowerUtility.ConseqFiscalYears(tDates, org);
                }
            }
            
            gDates.clear();
            tDates.clear();          
            
            System.Debug('consecutive_years_of_transactions=='+consecutive_years_of_transactions);
            //Converts the totalled amounts to the appropriate currencies
            totalGivingAmount                   = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalGivingAmount) : totalGivingAmount);            
            totalFiscalGivingAmount             = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalGivingAmount) : totalFiscalGivingAmount);
            totalGivingAmountLastYear           = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalGivingAmountLastYear) : totalGivingAmountLastYear);                                      
            totalAmount                         = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalAmount) : totalAmount);            
            totalFiscalAmount                   = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalAmount) : totalFiscalAmount);
            lastGiftAmount                      = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastGiftAmount) : lastGiftAmount);
            lastPaymentAmount                   = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastPaymentAmount) : lastPaymentAmount);           
            total_additional_solicitations1     = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_additional_solicitations1) : total_additional_solicitations1);           
            total_additional_solicitations      = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_additional_solicitations) : total_additional_solicitations);           
            total_solicitations1                = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_solicitations1) : total_solicitations1);
            total_solicitations                 = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_solicitations) : total_solicitations);
            
            //If there is a difference in the new amount from the c. amounts, the c. amounts are set to the calculated totals
            if (c.causeview__Total_Lifetime_Gifts__c <> totalGivingCount || c.causeview__Total_Lifetime_Giving__c <> totalGivingAmount ||
                c.causeview__Total_Fiscal_Gifts__c <> totalFiscalGivingCount || c.causeview__Total_Fiscal_Year_Giving__c <> totalFiscalGivingAmount ||
                c.causeview__Total_Lifetime_Transactions__c <> totalCount || c.causeview__Total_Lifetime_Transaction_Amount__c <> totalAmount ||
                c.causeview__Total_Fiscal_Transactions__c <> totalFiscalCount || c.causeview__Total_Fiscal_Transaction_Amount__c <> totalFiscalAmount ||
                c.causeview__Last_Gift_Amount__c <> lastGiftAmount || c.causeview__Total_Lifetime_Fundraising__c <> totalGivingAmount + total_additional_solicitations1 + total_solicitations1 ||
                c.causeview__Consecutive_Years_of_Giving__c <> consecutive_years_of_giving || c.causeview__Consecutive_Years_of_Transactions__c <> consecutive_years_of_transactions ||
                c.causeview__Total_Fiscal_Fundraising__c <> totalFiscalGivingAmount + total_additional_solicitations + total_solicitations ||
                c.causeview__Last_Payment_Amount__c  <> lastPaymentAmount){
            
                c.causeview__Total_Lifetime_Gifts__c                = totalGivingCount;
                c.causeview__Total_Lifetime_Giving__c               = totalGivingAmount;
                c.causeview__Total_Fiscal_Gifts__c                  = totalFiscalGivingCount;
                c.causeview__Total_Fiscal_Year_Giving__c            = totalFiscalGivingAmount;
                c.causeview__Total_Lifetime_Transactions__c         = totalCount;       
                c.causeview__Total_Lifetime_Transaction_Amount__c   = totalAmount;
                c.causeview__Total_Fiscal_Transactions__c           = totalFiscalCount;
                c.causeview__Total_Fiscal_Transaction_Amount__c     = totalFiscalAmount;
                c.causeview__Last_Gift_Amount__c                    = lastGiftAmount;
                c.causeview__Last_Payment_Amount__c                 = lastPaymentAmount; 
                c.causeview__Total_Lifetime_Fundraising__c          = totalGivingAmount + total_additional_solicitations1 + total_solicitations1;                
                c.causeview__Total_Fiscal_Fundraising__c            = totalFiscalGivingAmount + total_additional_solicitations + total_solicitations;
                c.causeview__Total_Fundraising_Last_Fiscal_Year__c  = totalGivingAmountLastYear + totalAdditionalSolicitationsLastYear + totalSolicitationsLastYear;
                System.debug('causeview__Total_Fundraising_Last_Year__c would = ' + (totalGivingAmountLastYear + totalAdditionalSolicitationsLastYear + totalSolicitationsLastYear));
                c.causeview__Consecutive_Years_of_Giving__c         = consecutive_years_of_giving;
                c.causeview__Consecutive_Years_of_Transactions__c   = consecutive_years_of_transactions;
                
                //Below are user debug logs to keep track of a handful of totals.
                System.Debug(LoggingLevel.Info,'---Inside RecalculateTotalGiving---');
                System.Debug(LoggingLevel.Info,'consecutive_years_of_giving==>'+consecutive_years_of_giving);
                System.Debug(LoggingLevel.Info,'consecutive_years_of_transactions==>'+consecutive_years_of_transactions);
                System.Debug(LoggingLevel.Info,'c.causeview__Consecutive_Years_of_Giving__c==>'+c.causeview__Consecutive_Years_of_Giving__c);
                System.Debug(LoggingLevel.Info,'c.causeview__Consecutive_Years_of_Transactions__c==>'+c.causeview__Consecutive_Years_of_Transactions__c);
                
                contactsToUpdate.add(c);//Adds the totals to the indexed list
            }
        }
        //completed list of contact values are sent off to be UPDATED in the database
        update contactsToUpdate;
        return householdIds;
    }
    
    public void RecalculateGiftDates(Map<Id,Contact> contactMap){
        causeview__BatchSettings__c settings =  causeview__BatchSettings__c.getInstance('Default'); //Gets settings from the Organization's batch settings.
        String                      RecordTypeIdforRollup;                                          //Will be used to store the settings to be split for recordTypesToRollup.
        List<String>                recordTypesToRollup = new List<String>();                                         //Will store the split string from RecordTypeIdforRollup. 
        RecordType                  r                   = [Select Name, Id From RecordType where Name ='Pledge' AND NamespacePrefix = 'causeview' AND sObjectType='causeview__Gift__c'];
        
        String transactionRecordTypeId = [Select Name, Id From RecordType where Name ='Gift' AND NamespacePrefix = 'causeview' AND sObjectType = 'causeview__Gift__c' LIMIT 1].Id;
        
        if(settings.causeview__Record_Type_Id_for_Rollups__c != null){
            RecordTypeIdforRollup = settings.causeview__Record_Type_Id_for_Rollups__c;
            
            recordTypesToRollup = SplitStringAtCommma(RecordTypeIdforRollup, true);
        }
          
        for(RecordType loopCurrentRecordType : [Select Name, Id From RecordType where (Name ='Pledge' OR Name ='Gift') AND NamespacePrefix = 'causeview' AND sObjectType = 'causeview__Gift__c'])
            recordTypesToRollup.add(loopCurrentRecordType.Id);  
        
        Map<Id,Contact> contactRecordsToUpdate = new Map<Id,Contact>();
        List<Contact> contacts = contactMap.values();        
                                   
        Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1); //Sets the date for a year ago today.
        Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31); //Sets the date for two years ago today.                                                           
        set<Id> Contactsetids     = new set<Id>();
        Contactsetids=contactMap.KeySet();
        //**********UPDATED CODE BY BIT ORDER ***********
        if(IsFiscalOrCalendarYearStart()){
            //Loop added to address the issue when a Contacts final transaction is deleted, certain transaction related fields such as Largest Gift and Average Gift 
            //are not properly reset to empty fields.
            //The loop performs query for deleted transactions and resets the Contacts fields appropriately.
            for(AggregateResult result : [SELECT causeview__Constituent__c con 
                      FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c != null AND IsDeleted = true
                      AND (RecordTypeId In :recordTypesToRollup OR RecordTypeId =:r.Id)
                      GROUP BY causeview__Constituent__c ALL ROWS]){
                //Fields affected by the transaction issue are reset to null.     
                Contact c               = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts); 
                Date date_of_last_gift  = null;
                Date date_of_first_gift = null;
                Decimal largest_gift    = null;
                Decimal average_gift    = null;
                
                Date date_of_last_gift_transaction  = null;
                Date date_of_first_gift_transaction = null;
                Date Last_Payment_Date              = null;
                
                Decimal total_giving_two_years_ago  = null; 
                Decimal total_giving_last_year      = null;             
                
                if (c != null && 
                (c.causeview__Date_of_Last_Gift__c <> date_of_last_gift ||
                c.causeview__Date_of_First_Gift__c <> date_of_first_gift || c.causeview__Largest_Gift__c <> largest_gift || c.causeview__Average_Gift__c <> average_gift||
                c.causeview__Total_Giving_Last_Year__c <> total_giving_last_year||c.causeview__Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago||
                c.causeview__Date_of_Last_Transaction__c <> date_of_last_gift_transaction || c.causeview__Date_of_First_Transaction__c <> date_of_first_gift_transaction ))
                {
                    System.Debug('Calculations');
                    c.causeview__Date_of_Last_Gift__c           = null;
                    c.causeview__Date_of_First_Gift__c          = null;
                    c.causeview__Largest_Gift__c                = null;
                    c.causeview__Average_Gift__c                = null;
                    
                    c.causeview__Date_of_Last_Transaction__c    = null;
                    c.causeview__Date_of_First_Transaction__c   = null;
                    c.causeview__Last_Payment_Date__c           = null;
                    
                    c.causeview__Total_Giving_Last_Year__c      = null;
                    c.causeview__Total_Giving_Two_Years_Ago__c  = null;

                    ContactRecordsToUpdate.put(c.Id, c);
                }
            } 
        }
        
        for(AggregateResult result : [SELECT SUM(causeview__Total_Gift_Amount__c) total, causeview__Constituent__c con
            FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c = LAST_YEAR
            AND  (RecordTypeId = :transactionRecordTypeId OR RecordTypeId In :recordTypesToRollup)
            GROUP BY causeview__Constituent__c])
        {
            System.debug('in last 1 year==='+result); 
            Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts); 
           
            decimal total_giving_last_year = (Decimal)result.get('total');
            total_giving_last_year= ((multiCurrencyOrganization)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)total_giving_last_year) : total_giving_last_year);
            if (c != null && c.causeview__Total_Giving_Last_Year__c <> total_giving_last_year)
            {
                c.causeview__Total_Giving_Last_Year__c = total_giving_last_year;
                ContactRecordsToUpdate.put(c.Id, c);
            }
        }                                
          
        for(AggregateResult result : [SELECT SUM(causeview__Total_Gift_Amount__c) total, causeview__Constituent__c con
            FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c >= :last2_year_start AND causeview__Gift_Date__c <= :last2_year_end
            AND   (RecordTypeId = :transactionRecordTypeId OR RecordTypeId In :recordTypesToRollup )
            GROUP BY causeview__Constituent__c])
        {      
            System.debug('in last 2 year==='+result);        
            Contact c2 = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
            
            decimal total_giving_two_years_ago = (Decimal)result.get('total');
            total_giving_two_years_ago= ((multiCurrencyOrganization)? convertCurrencyWithApexCode('corpCurr', (string)c2.get('CurrencyIsoCode'), (Decimal)total_giving_two_years_ago) : total_giving_two_years_ago);
            if (c2 != null && c2.causeview__Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago)
            {
                c2.causeview__Total_Giving_Two_Years_Ago__c = total_giving_two_years_ago ;
                ContactRecordsToUpdate.put(c2.Id, c2);
            }
        }     
        
        for(AggregateResult result : [SELECT AVG(causeview__Total_Gift_Amount__c)avgGiftAmt, MAX(causeview__Total_Gift_Amount__c)maxGiftAmt, MIN(causeview__Gift_Date__c) minGiftDate,  MAX(causeview__Gift_Date__c) maxGiftDate, causeview__Constituent__c con
                                    FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c != null
                                    AND (RecordTypeId In :recordTypesToRollup OR RecordTypeId =:r.Id)//As in the above queries, the AND clause containing RecordTypeId etc. had to be removed in order for Average Gift, Latest Gift,
                                    GROUP BY causeview__Constituent__c]){                               //Date of First Gift and Date of Last Gift to properly be reset when and if a Transaction and all related records were deleted.   
            Contact c               = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts); 
            Date date_of_last_gift  =  Date.valueOf(result.get('maxGiftDate'));
            Date date_of_first_gift =  Date.valueOf(result.get('minGiftDate'));
            Decimal largest_gift    = (Decimal)result.get('maxGiftAmt');
            Decimal average_gift    = (Decimal)result.get('avgGiftAmt');
            largest_gift            = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), (Decimal)largest_gift) : largest_gift);
            average_gift            = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), (Decimal)average_gift) : average_gift);                 
            
            if (c != null && (c.causeview__Date_of_Last_Gift__c <> date_of_last_gift ||
                c.causeview__Date_of_First_Gift__c <> date_of_first_gift || c.causeview__Largest_Gift__c <> largest_gift || c.causeview__Average_Gift__c <> average_gift))
            {
                c.causeview__Date_of_Last_Gift__c   = date_of_last_gift;
                c.causeview__Date_of_First_Gift__c  = date_of_first_gift;
                c.causeview__Largest_Gift__c        = largest_gift;
                c.causeview__Average_Gift__c        = average_gift;
                
                ContactRecordsToUpdate.put(c.Id, c);
            }
        }

        for(AggregateResult result : [SELECT MIN(causeview__Gift_Date__c) minGiftDate,  MAX(causeview__Gift_Date__c) maxGiftDate, causeview__Constituent__c con 
                                    FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c != null
                                    GROUP BY causeview__Constituent__c])
        {
            Contact c               = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
            Date date_of_last_gift  = Date.valueOf(result.get('maxGiftDate'));
            Date date_of_first_gift = Date.valueOf(result.get('minGiftDate'));
            if (c != null && (c.causeview__Date_of_Last_Transaction__c <> date_of_last_gift || c.causeview__Date_of_First_Transaction__c <> date_of_first_gift)){
                c.causeview__Date_of_Last_Transaction__c    = date_of_last_gift;
                c.causeview__Date_of_First_Transaction__c   = date_of_first_gift;
                ContactRecordsToUpdate.put(c.Id, c);
            }
        }//till here
        //new code for calculate last payment date and last payment amount 25-feb2-2016 
        //https://www.pivotaltracker.com/story/show/115068827 --> only for Approved Payments 
        for(AggregateResult result : [SELECT MIN(causeview__Date__c) minpaymentdate,  MAX(causeview__Date__c) maxpaymentDate ,causeview__Donation__r.causeview__Constituent__c con, causeview__Status__c  FROM causeview__payment__c  where causeview__Donation__r.causeview__Constituent__c IN :Contactsetids AND (causeview__Donation__r.RecordTypeId IN :recordTypesToRollup OR causeview__Donation__r.RecordTypeId = :r.Id) AND causeview__Status__c = 'Approved' GROUP BY causeview__Donation__r.causeview__Constituent__c, causeview__Status__c ]){//
          Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
                
                Date Last_Payment_Date = Date.valueOf(result.get('maxpaymentDate'));
                
                if (c != null && (c.causeview__Last_Payment_Date__c <> Last_Payment_Date )){
                    c.causeview__Last_Payment_Date__c = Last_Payment_Date;

                    ContactRecordsToUpdate.put(c.Id, c);
                }
        }
        
        if( ContactRecordsToUpdate.size() > 0 )
       {
           update ContactRecordsToUpdate.values();
       }
    }
   
    //Needs to be tested using households within the sandbox orgs.
    public static void RecalculateTotalHouseholdGiving(Set<Id> hhIds1){
        System.Debug(hhIds1);
        
        if (hhIds1 == null || hhIds1.size()<=0) return;
        
        List<Account> households = new List<Account>();
        
        if(multiCurrencyOrganization){
            households=Database.query('SELECT Id, CurrencyIsoCode, causeview__Total_Household_Fundraising__c, causeview__Total_Fiscal_Household_Transactions__c , causeview__Total_Household_Transactions__c , causeview__Total_Household_Giving__c , causeview__Total_Fiscal_Household_Giving__c , causeview__Total_Fiscal_Household_Fundraising__c,  (SELECT Id, CurrencyIsoCode, causeview__Total_Fiscal_Transaction_Amount__c, causeview__Total_Lifetime_Transaction_Amount__c, causeview__Total_Fiscal_Year_Giving__c, causeview__Total_Lifetime_Fundraising__c, causeview__Total_Lifetime_Giving__c , causeview__Total_Fiscal_Fundraising__c FROM causeview__HouseholdContacts__r) FROM Account WHERE Id IN :hhIds1');
        }else{        
            households=[SELECT Id, causeview__Total_Household_Fundraising__c, causeview__Total_Fiscal_Household_Transactions__c , causeview__Total_Household_Transactions__c , causeview__Total_Household_Giving__c , causeview__Total_Fiscal_Household_Giving__c , causeview__Total_Fiscal_Household_Fundraising__c,  (SELECT Id, causeview__Total_Fiscal_Transaction_Amount__c, causeview__Total_Lifetime_Transaction_Amount__c, causeview__Total_Fiscal_Year_Giving__c, causeview__Total_Lifetime_Fundraising__c, causeview__Total_Lifetime_Giving__c , causeview__Total_Fiscal_Fundraising__c FROM causeview__HouseholdContacts__r) FROM Account WHERE Id IN :hhIds1];
        }
        
        integer org = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
        List<Account>   accountsToUpdate  = new List<Account>();
        List<Date>      gDates            = new List<Date>();
        List<Date>      tDates            = new List<Date>();
        Set <String>    cIds              = new Set <String>();
        
        for(Account a : households){
            Decimal totalAmount                     = 0;        
            Decimal totalFiscalAmount               = 0;
            Decimal totalGivingAmount               = 0;
            Decimal totalFiscalGivingAmount         = 0;
            Decimal totalFundraisingAmount          = 0;
            Decimal totalFiscalFundraisingAmount    = 0;
            
            for(Contact c : a.causeview__HouseholdContacts__r){
                if (c.causeview__Total_Fiscal_Transaction_Amount__c != 0 && c.causeview__Total_Fiscal_Transaction_Amount__c != null){
                    totalFiscalAmount +=((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Fiscal_Transaction_Amount__c) : c.causeview__Total_Fiscal_Transaction_Amount__c);
                }
                if (c.causeview__Total_Lifetime_Transaction_Amount__c!= 0 && c.causeview__Total_Lifetime_Transaction_Amount__c!= null){
                    totalAmount += ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Lifetime_Transaction_Amount__c) : c.causeview__Total_Lifetime_Transaction_Amount__c);
                }
                if (c.causeview__Total_Fiscal_Year_Giving__c!= 0 && c.causeview__Total_Fiscal_Year_Giving__c!= null){
                    totalFiscalGivingAmount +=  ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Fiscal_Year_Giving__c) : c.causeview__Total_Fiscal_Year_Giving__c);
                }
                if (c.causeview__Total_Lifetime_Giving__c!= 0 && c.causeview__Total_Lifetime_Giving__c!= null){
                    totalGivingAmount += ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Lifetime_Giving__c) : c.causeview__Total_Lifetime_Giving__c);
                }   
                if (c.causeview__Total_Lifetime_Fundraising__c != 0 && c.causeview__Total_Lifetime_Fundraising__c != null){
                    totalFundraisingAmount += ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Lifetime_Fundraising__c) : c.causeview__Total_Lifetime_Fundraising__c);
                }                
                if(c.causeview__Total_Fiscal_Fundraising__c != 0 && c.causeview__Total_Fiscal_Fundraising__c != null){
                    totalFiscalFundraisingAmount += ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Fiscal_Fundraising__c) : c.causeview__Total_Fiscal_Fundraising__c);
                }  
            }
            if (a.causeview__Total_Household_Giving__c <> totalGivingAmount || a.causeview__Total_Fiscal_Household_Giving__c <> totalFiscalGivingAmount || 
                a.causeview__Total_Household_Transactions__c <> totalAmount || a.causeview__Total_Fiscal_Household_Transactions__c <> totalFiscalAmount || 
                a.causeview__Total_Household_Fundraising__c <> totalFundraisingAmount || a.causeview__Total_Fiscal_Household_Fundraising__c <> totalFiscalFundraisingAmount)
            { 
                a.causeview__Total_Household_Giving__c              = totalGivingAmount;
                a.causeview__Total_Fiscal_Household_Giving__c       = totalFiscalGivingAmount;
                a.causeview__Total_Household_Transactions__c        = totalAmount;
                a.causeview__Total_Fiscal_Household_Transactions__c = totalFiscalAmount;
                a.causeview__Total_Household_Fundraising__c         = totalFundraisingAmount;
                a.causeview__Total_Fiscal_Household_Fundraising__c  = totalFiscalFundraisingAmount;

                accountsToUpdate.add(a);
            }
        }
        update accountsToUpdate;
    }

    public static Decimal ConvertCurrencyWithApexCode(String oCurrency, String nCurrency, Decimal  amount){       
        //Convert Currency
        if(oCurrency!='corpCurr')           
            amount = amount / conversionRates.get(oCurrency);       
        
        amount = amount * conversionRates.get(nCurrency);  
        return amount;
    }
    
    global void finish(Database.BatchableContext BC){
        if(contactsForUpdate.size() == 20000)
            Database.executeBatch(new RollupBatch(alreadyUpdatedContacts, lastTimeRun));
        System.Debug('Finish:' + alreadyUpdatedContacts);
    }   

    /*--------------------- Funtions to go to Utilities -----------------*/
    public boolean IsFiscalOrCalendarYearStart(){
        return (Date.newInstance(Date.Today().Year(),1,1) != Date.Today() || Date.newInstance(Date.Today().Year(), orgFiscalYearStartMonth, 1) != Date.Today());
    }

    public Integer GetFiscalStartMonth() {
        return [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
    }

    public static List<String> SplitStringAtCommma(String stringWithCommas, Boolean clearWhitespace) {
        if(stringWithCommas.containsWhitespace() && clearWhitespace == true)
            stringWithCommas = (String)stringWithCommas.deleteWhitespace();
        return stringWithCommas.Split(',');
    }
}