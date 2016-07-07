//causeview.RollupBatchContact.cls - Original file written by Bit Order Technologies.
//Additional comments by: Landon Borg - 4/6/2016
//Last Updated: 04/11/2016 - Implemented FilterQuery(), added to the query string for finding main records to be updated.
//              04/12/2016 - Deleted records are now rolled up (or rolled down to subtract the amount). 
//              04/13/2016 - Fixed a bug where the final transaction from a contact is deleted and the average, latest and first and last gift dates do not reset.
//              04/14/2016 - Fixed an issue with transaction information on Contact would not rollup for Contacts with their only transaction deleted.
//              04/15/2016 - Fixed issues with payment-less transactions not being correctly rolled up in Contacts.
//              04/18/2016 - Changed the main Query to run off of only Transactions alone rather than Transactions and Payments
//              04/19/2016 - Added the company fiscal year to the twice a year major rollup without the filter query.
//              04/20/2016 - Various changes made by Bit Order Tech.

//Class methods:
//  global  Database.Querylocator start(Database.BatchableContext BC)
//  public  static  string GetQuery()
//  public  static  Set<Id> FilterQuery()
//  global  void    execute(Database.BatchableContext BC, List<sObject> scope)
//  public  static  void MultiCurrencySupport()
//  public  static  void RecalculateGiftDates(Set<Id> contactIds)
//  private static  void RecalculateGiftDates(scopeMap.keySet())
//  public  static  void RecalculateTotalHouseholdGiving(Set<Id> hhIds)
//  public  static  Decimal ConvertCurrencyWithApexCode(String oCurrency, String nCurrency, Decimal  amount)
//  global  void    finish(Database.BatchableContext BC)

global class RollupBatchContact implements Database.Batchable<sObject>, Database.stateful {
    
    // GLOBAL VARIABLE DECLARATIONS //
    
    global          List<Contact>           contactRecord      = new List<Contact>();
    global static   Map <string, decimal>   conversion_rates   = new Map <string, decimal>();
    global          Set <string>            cid                = new Set <string>();         //Appears to be used elsewhere (Does it need to be here?)
    global          DateTime                previousRunTime;                                 //Created to store the previous run date for the batch update.
    global Static   DateTime                lastRunTime;                                 //Created to store the previous run date for the batch update.
    global static   Boolean                 multiCurrencyEn;                                 //Switch to tell methods whether or not the client contact is multicurrency or not.
    global static   String                  userIsoCode;                                     //Will store ISO code to keep track of the currency used by the client if multicurrency is true.
    global static   Set <Id>                contactFilter      = new Set <Id>();             //Id Set used to store unique ids which will be fed to a query in order to filter the existing query created by Bit Order.
    global static   Integer                 orgFiscalStart;                                  //Will hold the org's fiscal start month.
    
    // CONSTRUCTORS //
    
    //Empty constructor.
    //Takes no arguments.
    global RollupBatchContact(){            
    }
    
    //DateTime constructor that can be fed a last run time from the Batch scheduler.
    global RollupBatchContact(DateTime lastRun){
        lastRunTime = lastRun;    
    }
    
    // METHODS //
    
    //First method ran by causeview.RollupBatchContact.cls.
    global Database.Querylocator start(Database.BatchableContext BC){
        orgFiscalStart = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        
        System.Debug('Landon: '+orgFiscalStart);
        
        if (lastRunTime == null) {
     
            List<AsyncApexJob> st = database.query('SELECT CompletedDate FROM AsyncApexJob WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = \'RollupBatchContact\') AND (Status = \'Completed\' AND numberOfErrors = 0) ORDER BY CreatedDate DESC LIMIT 1');   
            if(st.size() > 0)
            lastRunTime= st[0].CompletedDate; 
 
        }
        System.Debug(lastRunTime);
        string query = GetQuery();              //Calls GetQuery() to created the initial Query to grab all relevant query information in order to rollup Contacts.
        System.Debug(query);                    //User Debug

        return Database.getQueryLocator(query); //The constructed query is passed to execute().
        
    }
    
    //Get query is initially run at the beginning to create the SELECT string.
    //Takes no arguments.
    //Returns string: SELECT query for contacts to run against the database.
    public static string GetQuery(){   

        if((Date.newInstance(Date.Today().Year(),1,1) != Date.Today() || Date.newInstance(Date.Today().Year(), orgFiscalStart, 1) != Date.Today()))
            contactFilter = FilterQuery();//FilterQuery() is called to create filter for the query below to ensure that only recently updated records will be pulled. This substantially reduces batch run times.
    
        string query = 'SELECT Id, causeview__Consecutive_Years_of_Giving__c, causeview__Consecutive_Years_of_Transactions__c, causeview__Last_Gift_Amount__c, causeview__Total_Lifetime_Gifts__c, causeview__Total_Lifetime_Giving__c, ';

        //If org. uses currency other currency types, the ISO code will be appended to the query.
        if(UserInfo.isMultiCurrencyOrganization()==true)
            query += 'CurrencyIsoCode, ';
        
        //Appends the rollup field totals to the query String.
        query += 'causeview__Total_Fiscal_Gifts__c, causeview__Total_Fiscal_Year_Giving__c, causeview__Total_Lifetime_Transactions__c, causeview__Total_Lifetime_Transaction_Amount__c, ';
        query += ' causeview__Date_of_Last_Gift__c,causeview__Date_of_First_Gift__c,causeview__Date_of_First_Transaction__c,causeview__Largest_Gift__c,causeview__Average_Gift__c,causeview__Date_of_Last_Transaction__c,causeview__Total_Giving_Two_Years_Ago__c, causeview__Total_Giving_Last_Year__c,causeview__Total_Fiscal_Transactions__c, causeview__Total_Fiscal_Transaction_Amount__c, causeview__Total_Lifetime_Fundraising__c, causeview__Total_Fiscal_Fundraising__c,causeview__Last_Payment_Amount__c,causeview__Last_Payment_Date__c '; 

        query += 'FROM Contact c '; 
        
        if((Date.newInstance(Date.Today().Year(),1,1) != Date.Today() || Date.newInstance(Date.Today().Year(), orgFiscalStart, 1) != Date.Today()) && lastRunTime != null)
        query += 'WHERE Id IN :contactFilter';   //contactFilter is applied. Constructed in queryFilter().
                                                 //It is a list containing unique ids of contacts whose payments have been updated recently.                           
                                                 //Completed query is returned to start().
        return query;                              
    }

    //Gets only the contact ID's for contacts that have been modified.
    //Writen by: Robert Collins
    //Date: 04/08/2016
    //Date Last Modified 04/13/2016 - Landon Borg 
    //Modified the method to store the returned query in a Set rather than sObject.
    public static Set<Id> FilterQuery(){
        Database.Querylocator   filterQueryLocator        = Database.getQueryLocator([SELECT causeview__Constituent__c FROM causeview__Gift__c WHERE LastModifiedDate > :lastRunTime OR (IsDeleted = True AND SystemModStamp > :lastRunTime) ALL ROWS]);
        Database.QuerylocatorIterator filterQueryIterator = filterQueryLocator.iterator();
        Set <Id>                idsToBeUpdated            = new Set <Id>();                             //Set to hold all unique IDs found from the aggregate query.
        
        while(filterQueryIterator.hasNext()) {
            causeview__Gift__c currentGift = (causeview__Gift__c)filterQueryIterator.next();
            Id constituentId = currentGift.causeview__Constituent__c;
            idsToBeUpdated.add(constituentId);
        }
        //Loops through the aggregate queryResults and adds them to the Id Set.
        
        return idsToBeUpdated; //Returns the filtered IDs to GetQuery().
    }    
    
    //Query results from the above methods is passed here for processing.    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map <Id, Contact>   scopeMap        = new Map <Id, Contact>((List<Contact>)scope);   //Creates a Map of Contact objects each with their corresponding unique keys.                          
        Set <Id>            hhIds           = new Set <Id>();                                //Set is used so that the ids are ordered and no duplicates exist. Stores a list of HouseHolds
        
        MultiCurrencySupport(); //Will instantiate a multiCurrency object list if the organization uses more than one.
        
        hhIds = RecalculateTotalGiving((List<Contact>)scope);
        RecalculateGiftDates(scopeMap);
        if (hhIds.size() > 0) RecalculateTotalHouseholdGiving(hhIds);
    }
    
    //Handles orgs. multiple currencies by creating an object list and populating it with conversion rates and
    //IsoCodes to use later on. (If multicurrency is true.)
    //Takes no arguments. Only called from: execute().
    public static void MultiCurrencySupport(){        
        multiCurrencyEn = UserInfo.isMultiCurrencyOrganization();   //Checks to see if the Org. is multicurrency. Returns True or False.
        System.Debug('MULTI CURRENCY==' + multiCurrencyEn);         //User Debug to display returned multiCurrencyEn value.
        userIsoCode = UserInfo.getDefaultCurrency();                //Gets the orgs. ISO code.
                    
         //If multiCurrencyEn returns True, creates an object list of ISO codes and currency exchange rates from the Organization.            
        if(multiCurrencyEn==true){                 
            List<sObject> isoList = Database.query('SELECT IsoCode,ConversionRate, IsCorporate FROM CurrencyType');//Object list of ISO codes and currency exchange rates queried from the Organization. 
            
            //Loop runs to select the ISO codes and conversion rates for each currency type.  
            for(sObject curr: isoList)      
              conversion_rates.put((String)curr.get('IsoCode'),(decimal)curr.get('ConversionRate'));       //Populates isoList with ISO codes and currency exchange rates.      
        }   
    }
    
    //Handles most of the rollup fields having to do with cumulative totals.
    //Accepts no arguments.
    //At the end of the method, contacts are updated in the database.
    private static set<id>  RecalculateTotalGiving(List<Contact> contacts){     
        System.Debug('Multi Currency2'+multiCurrencyEn);            //Displays multicurrency once again for debugging purposes.
        System.Debug('<======inside REcalculateTotalGiving======>');//Formatting string to display below the multicurrency.
        
        if (contacts == null || contacts.size() <= 0) return null;//Ensures that the Contacts list is populated with objects.
        
        causeview__BatchSettings__c             settings                =  causeview__BatchSettings__c.getInstance('Default'); //Pulls the default settings from the BatchSettings.
        String                                  RecordTypeIdforRollup1;
        List<String>                            RecordTypeIdsforRollup1 = new List<String>();
        Set <String>                            recordIds               = new Set<String>();                                   //Set created to store record ids and ensure they are unique
        //Added by Nitin
        Map <Id, List<causeview__Gift__c>>      GiftRecordMap           = new Map<Id, List<causeview__Gift__c>>();             //map created to store contact ids, each id has a list of gifts attached to it
        Map <Id, List<causeview__payment__c>>   PaymentRecordMap        = new Map<Id, List<causeview__payment__c>>();          //map created to store contact ids, each id has a list of payments attached to it
        Map <Id, List<causeview__Solicitor__c>> softCreditRecordMap     = new Map<Id, List<causeview__Solicitor__c>>();
        Map<Id, List<causeview__Gift__c>>       GiftRecordMapPrimarySolicitor = new Map<Id, List<causeview__Gift__c>>();        //map created to store contact ids, each id has a list of softCredits attached to it
        
        RecordTypeIdforRollup1 = (settings.causeview__Record_Type_Id_for_Rollups__c != null) ? settings.causeview__Record_Type_Id_for_Rollups__c : settings.causeview__RegularGiftRecordTypeId__c ;
        System.Debug('dbglg '+RecordTypeIdforRollup1);
        RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');
         //user story ---->https://www.pivotaltracker.com/story/show/110070048, to include pledge record type 
        RecordType r = [Select Name, Id From RecordType where Name ='Pledge' AND NamespacePrefix = 'causeview' AND sObjectType = 'causeview__Gift__c' ];
        String                                  pledgeRecordTypeId      = r.id;
        recordIds.add(pledgeRecordTypeId);            
        
        //Checks to make sure the records id list is not empty.
        if(RecordTypeIdsforRollup1.size()>0){
            //Adds the records type ids to recordIds to be processed and rolled up in the statements below.
            for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++){
                System.Debug('dbglog '+RecordTypeIdsforRollup1.size());
                recordIds.add(RecordTypeIdsforRollup1[i]);
            }
        }
        
        Map<Id,Contact> contactsMap = new Map<Id,Contact>(contacts);
        set<id> householdIds = new set<id>();
        set<id> contactIds = new set<Id>();
        contactIds = contactsMap.keyset();
                
        System.Debug('Multi Currency'+multiCurrencyEn);//User debug displays the state of multiCurrency for the org.
        //Below is where the maps are constructed containing all of the fields to be rolled up
        
        //The following three headings: GIFTS, SOFT CREDIT and PAYMENTS query the database for their respective fields and add the results into maps to be totalled later on in the method.
        
        // GIFTS RELATED TO CONTACTS //
        if(MultiCurrencyEn) 
        {
            for(causeview__Gift__c g : Database.query ('Select Id, convertCurrency(causeview__Amount__c), causeview__Status__c,causeview__HouseholdId__c, causeview__Gift_Date__c, RecordType.Name, RecordTypeId,causeview__Constituent__c,causeview__Primary_Solicitor__c From causeview__Gift__c where causeview__Constituent__c IN : contactIds OR causeview__Primary_Solicitor__c  IN : contactIds ORDER BY causeview__Gift_Date__c DESC,CreatedDate DESC ') )
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
            for(causeview__Gift__c g : [Select Id,causeview__HouseholdId__c, causeview__Amount__c, causeview__Status__c, causeview__Gift_Date__c,RecordType.Name, RecordTypeId, causeview__Constituent__c,causeview__Primary_Solicitor__c From causeview__Gift__c where (causeview__Constituent__c IN : contactIds OR causeview__Primary_Solicitor__c  IN : contactIds) ORDER BY causeview__Gift_Date__c DESC,CreatedDate DESC])
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
        if(multiCurrencyEn){
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
        if(multiCurrencyEn){
            for(causeview__payment__c p: Database.query('select Id, Name , convertCurrency(causeview__Amount__c), causeview__Date__c , causeview__Status__c  ,causeview__Donation__r.causeview__Constituent__c ,causeview__Donation__r.RecordTypeId, causeview__Donation__r.RecordType.Name from causeview__payment__c where causeview__Donation__r.causeview__Constituent__c IN : contactIds AND causeview__Status__c  = \'Approved\' AND causeview__Donation__r.RecordTypeId IN : recordIds ORDER BY causeview__Date__c DESC, CreatedDate DESC')){
                 if(!PaymentRecordMap.containsKey(p.causeview__Donation__r.causeview__Constituent__c)){
                        PaymentRecordMap.put(p.causeview__Donation__r.causeview__Constituent__c, new List<causeview__payment__c>());
                    }
                  PaymentRecordMap.get(p.causeview__Donation__r.causeview__Constituent__c).add(p);
            }
        }
        else{
            for(causeview__payment__c p: [select Id, Name , causeview__Amount__c,causeview__Date__c , causeview__Status__c  ,causeview__Donation__r.causeview__Constituent__c ,causeview__Donation__r.RecordTypeId, causeview__Donation__r.RecordType.Name from causeview__payment__c where causeview__Donation__r.causeview__Constituent__c IN : contactIds AND causeview__Status__c  = 'Approved' AND causeview__Donation__r.RecordTypeId IN : recordIds ORDER BY causeview__Date__c DESC, CreatedDate DESC ]){
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
            Decimal lastGiftAmount                      = 0;
            Decimal lastPaymentAmount                   = 0;
            Decimal totalAmount                         = 0;        
            Decimal totalFiscalAmount                   = 0;
            Decimal totalCount                          = 0;
            Decimal totalFiscalCount                    = 0;
            Decimal totalGivingAmount                   = 0;
            Decimal totalFiscalGivingAmount             = 0;
            Decimal totalGivingCount                    = 0;
            Decimal totalFiscalGivingCount              = 0;
            Decimal total_additional_solicitations      = 0;
            Decimal total_additional_solicitations1     = 0;
            Decimal total_solicitations                 = 0;
            Decimal total_solicitations1                = 0;
            Decimal consecutive_years_of_giving         = 0;
            Decimal consecutive_years_of_transactions   = 0;
        
            if (GiftRecordMap.get(c.id) != null){
                //added by nitin on 26/09/2014  
                //Pivotal Tracker - Last Gift Amount field Not Calculating Only On Record Type = Gift
                for(causeview__Gift__c g : GiftRecordMap.get(c.id)){
                    if(settings.causeview__RegularGiftRecordTypeId__c.contains(g.RecordTypeId) && g.RecordType.name == 'Gift'){
                        lastGiftAmount =g.causeview__Amount__c;
                        break;
                    } 
                }       
            }
            //payment last amount
            if (PaymentRecordMap.get(c.id) != null)
            {
                for(causeview__Payment__c p : PaymentRecordMap.get(c.id)){
                    if(settings.causeview__RegularGiftRecordTypeId__c.contains(p.causeview__Donation__r.RecordTypeId) && p.causeview__Donation__r.RecordType.Name == 'Gift' ){
                        lastPaymentAmount = p.causeview__Amount__c;
                        break;
                    } 
                }       
            }    
            
            //if clause here totals up gift amounts by running through each gift per contact 
            if(GiftRecordMap.get(c.id) != null){    
                for(causeview__Gift__c g : GiftRecordMap.get(c.id)){//loops via the contact ids
                    if ((settings.causeview__RegularGiftRecordTypeId__c.contains(g.RecordTypeId))||(recordIds.Contains(g.RecordTypeId))){
                        totalGivingAmount   += g.causeview__Amount__c;
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
                    if (GivingpowerUtility.isCurrentFiscal(g.causeview__Gift_Date__c, org)){
                        if ((settings.causeview__RegularGiftRecordTypeId__c.contains(g.RecordTypeId))||(recordIds.Contains(g.RecordTypeId))){
                            totalFiscalGivingAmount     += g.causeview__Amount__c;
                            totalFiscalAmount           += g.causeview__Amount__c;
                            totalFiscalGivingCount++;
                            totalFiscalCount++;
                        }
                        else{
                            totalFiscalAmount += g.causeview__Amount__c;
                            totalFiscalCount++;
                        }
                    }
                }
            }
            if (softCreditRecordMap.get(c.id) != null){
                for(causeview__Solicitor__c s : softCreditRecordMap.get(c.id)){
                    total_additional_solicitations1 += (s.causeview__Amount__c == null) ? 0 : s.causeview__Amount__c;
                    //need to calculate only current fiscal year transaction
                    if (GivingpowerUtility.isCurrentFiscal(s.causeview__Gift_Date__c, org))
                         total_additional_solicitations += (s.causeview__Amount__c == null) ? 0 : s.causeview__Amount__c;
                }
            }
            
            if(GiftRecordMapPrimarySolicitor.get(c.Id) != null ){
                for(causeview__Gift__c g2 : GiftRecordMapPrimarySolicitor.get(c.Id))
                {
                    system.debug('<=Inside Primary=>'+g2);
                    total_solicitations1 += g2.causeview__Amount__c;
                    system.debug('total_solicitations==>'+total_solicitations);
                    
                    if (GivingpowerUtility.isCurrentFiscal(g2.causeview__Gift_Date__c, org)) {
                                system.debug('<=Inside Primary=>'+g2);
                                total_solicitations += g2.causeview__Amount__c;
                                system.debug('total_solicitations==>'+total_solicitations);
                     }
                }
            }
            
            System.Debug('Contact==>'+c.id);
            
            if (gDates.size() != 0){
                if (org == null){
                     consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, 1);
                }
                else{
                    consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, org);
                }
            }
            
            System.Debug('consecutive_years_of_giving== '+consecutive_years_of_giving);
            
            if (tDates.size() != 0){
                if (org == null){
                    consecutive_years_of_transactions = GivingpowerUtility.ConseqFiscalYears(tDates, 1);
                }
                else{
                    consecutive_years_of_transactions = GivingpowerUtility.ConseqFiscalYears(tDates, org);
                }
            }
            
            gDates.clear();
            tDates.clear();          
            
            System.Debug('consecutive_years_of_transactions=='+consecutive_years_of_transactions);
            //Converts the totalled amounts to the appropriate currencies
            totalGivingAmount                   = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalGivingAmount) : totalGivingAmount);            
            totalFiscalGivingAmount             = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalGivingAmount) : totalFiscalGivingAmount);                   
            totalAmount                         = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalAmount) : totalAmount);            
            totalFiscalAmount                   = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalAmount) : totalFiscalAmount);
            lastGiftAmount                      = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastGiftAmount) : lastGiftAmount);
            lastPaymentAmount                   = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastPaymentAmount) : lastPaymentAmount);           
            total_additional_solicitations1     = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_additional_solicitations1) : total_additional_solicitations1);           
            total_additional_solicitations      = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_additional_solicitations) : total_additional_solicitations);           
            total_solicitations1                = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_solicitations1) : total_solicitations1);
            total_solicitations                 = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_solicitations) : total_solicitations);
            
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
    
    public static void RecalculateGiftDates(Map<Id,Contact> contactMap){
        causeview__BatchSettings__c settings =  causeview__BatchSettings__c.getInstance('Default'); //Gets settings from the Organization's batch settings.
        String                      RecordTypeIdforRollup;                                          //Will be used to store the settings to be split for RecordTypeIdsforRollup.
        List<String>                RecordTypeIdsforRollup;                                         //Will store the split string from RecordTypeIdforRollup. 
        RecordType                  r                   = [Select Name, Id From RecordType where Name ='Pledge' AND NamespacePrefix = 'causeview' AND sObjectType='causeview__Gift__c'];
        
        RecordTypeIdforRollup = (settings.causeview__Record_Type_Id_for_Rollups__c != null) ? settings.causeview__Record_Type_Id_for_Rollups__c : settings.causeview__RegularGiftRecordTypeId__c ;        
        RecordTypeIdsforRollup = RecordTypeIdforRollup.Split(',');
        
        Map<Id,Contact> contactRecordsToUpdate = new Map<Id,Contact>();
        List<Contact> contacts = contactMap.values();        
                                   
        Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1); //Sets the date for a year ago today.
        Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31); //Sets the date for two years ago today.                                                           
        set<Id> Contactsetids     = new set<Id>();
        Contactsetids=contactMap.KeySet();
        //**********UPDATED CODE BY BIT ORDER ***********
        if(Date.newInstance(Date.Today().Year(),1,1) != Date.Today() || Date.newInstance(Date.Today().Year(), orgFiscalStart, 1) != Date.Today()){
            //Loop added to address the issue when a Contacts final transaction is deleted, certain transaction related fields such as Largest Gift and Average Gift 
            //are not properly reset to empty fields.
            //The loop performs query for deleted transactions and resets the Contacts fields appropriately.
            for(AggregateResult result : [SELECT causeview__Constituent__c con 
                      FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c != null AND IsDeleted = true
                      AND (RecordTypeId In :RecordTypeIdsforRollup OR RecordTypeId =:r.Id)
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
        
        for(AggregateResult result : [SELECT SUM(causeview__Amount__c) total, causeview__Constituent__c con
            FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c = LAST_YEAR
            AND  (RecordTypeId = :settings.causeview__RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup)
            GROUP BY causeview__Constituent__c])
        {
            System.debug('in last 1 year==='+result); 
            Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts); 
           
            decimal total_giving_last_year = (Decimal)result.get('total');
            total_giving_last_year= ((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)total_giving_last_year) : total_giving_last_year);
            if (c != null && c.causeview__Total_Giving_Last_Year__c <> total_giving_last_year)
            {
                c.causeview__Total_Giving_Last_Year__c = total_giving_last_year;
                ContactRecordsToUpdate.put(c.Id, c);
            }
        }                                
          
        for(AggregateResult result : [SELECT SUM(causeview__Amount__c) total, causeview__Constituent__c con
            FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c >= :last2_year_start AND causeview__Gift_Date__c <= :last2_year_end
            AND   (RecordTypeId = :settings.causeview__RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup )
            GROUP BY causeview__Constituent__c])
        {      
            System.debug('in last 2 year==='+result);        
            Contact c2 = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
            
            decimal total_giving_two_years_ago = (Decimal)result.get('total');
            total_giving_two_years_ago= ((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c2.get('CurrencyIsoCode'), (Decimal)total_giving_two_years_ago) : total_giving_two_years_ago);
            if (c2 != null && c2.causeview__Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago)
            {
                c2.causeview__Total_Giving_Two_Years_Ago__c = total_giving_two_years_ago ;
                ContactRecordsToUpdate.put(c2.Id, c2);
            }
        }     
        
        for(AggregateResult result : [SELECT AVG(causeview__Amount__c)avgGiftAmt, MAX(causeview__Amount__c)maxGiftAmt, MIN(causeview__Gift_Date__c) minGiftDate,  MAX(causeview__Gift_Date__c) maxGiftDate, causeview__Constituent__c con
                                    FROM causeview__Gift__c WHERE causeview__Constituent__c IN :Contactsetids AND causeview__Gift_Date__c != null
                                    AND (RecordTypeId In :RecordTypeIdsforRollup OR RecordTypeId =:r.Id)//As in the above queries, the AND clause containing RecordTypeId etc. had to be removed in order for Average Gift, Latest Gift,
                                    GROUP BY causeview__Constituent__c]){                               //Date of First Gift and Date of Last Gift to properly be reset when and if a Transaction and all related records were deleted.   
            Contact c               = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts); 
            Date date_of_last_gift  =  Date.valueOf(result.get('maxGiftDate'));
            Date date_of_first_gift =  Date.valueOf(result.get('minGiftDate'));
            Decimal largest_gift    = (Decimal)result.get('maxGiftAmt');
            Decimal average_gift    = (Decimal)result.get('avgGiftAmt');
            largest_gift            = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), (Decimal)largest_gift) : largest_gift);
            average_gift            = ((multiCurrencyEn)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), (Decimal)average_gift) : average_gift);                 
            
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
        for(AggregateResult result : [SELECT MIN(causeview__Date__c) minpaymentdate,  MAX(causeview__Date__c) maxpaymentDate ,causeview__Donation__r.causeview__Constituent__c con, causeview__Status__c  FROM causeview__payment__c  where causeview__Donation__r.causeview__Constituent__c IN :Contactsetids AND (causeview__Donation__r.RecordTypeId IN :RecordTypeIdsforRollup OR causeview__Donation__r.RecordTypeId = :r.Id) AND causeview__Status__c = 'Approved' GROUP BY causeview__Donation__r.causeview__Constituent__c, causeview__Status__c ]){//
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
        
        if(multiCurrencyEn){
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
                    totalFiscalAmount +=((multiCurrencyEn)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Fiscal_Transaction_Amount__c) : c.causeview__Total_Fiscal_Transaction_Amount__c);
                }
                if (c.causeview__Total_Lifetime_Transaction_Amount__c!= 0 && c.causeview__Total_Lifetime_Transaction_Amount__c!= null){
                    totalAmount += ((multiCurrencyEn)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Lifetime_Transaction_Amount__c) : c.causeview__Total_Lifetime_Transaction_Amount__c);
                }
                if (c.causeview__Total_Fiscal_Year_Giving__c!= 0 && c.causeview__Total_Fiscal_Year_Giving__c!= null){
                    totalFiscalGivingAmount +=  ((multiCurrencyEn)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Fiscal_Year_Giving__c) : c.causeview__Total_Fiscal_Year_Giving__c);
                }
                if (c.causeview__Total_Lifetime_Giving__c!= 0 && c.causeview__Total_Lifetime_Giving__c!= null){
                    totalGivingAmount += ((multiCurrencyEn)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Lifetime_Giving__c) : c.causeview__Total_Lifetime_Giving__c);
                }   
                if (c.causeview__Total_Lifetime_Fundraising__c != 0 && c.causeview__Total_Lifetime_Fundraising__c != null){
                    totalFundraisingAmount += ((multiCurrencyEn)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Lifetime_Fundraising__c) : c.causeview__Total_Lifetime_Fundraising__c);
                }                
                if(c.causeview__Total_Fiscal_Fundraising__c != 0 && c.causeview__Total_Fiscal_Fundraising__c != null){
                    totalFiscalFundraisingAmount += ((multiCurrencyEn)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.causeview__Total_Fiscal_Fundraising__c) : c.causeview__Total_Fiscal_Fundraising__c);
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
            amount = amount / conversion_rates.get(oCurrency);       
        
        amount = amount * conversion_rates.get(nCurrency);  
        return amount;
    }
    
    global void finish(Database.BatchableContext BC){
        DateTime now = DateTime.now();
    }    
}