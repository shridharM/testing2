global class RollupBatch implements Database.Batchable<sObject>, Database.stateful {
    
    global List<Contact> contactRecord = new List<Contact>();
    global set<string> cid = new Set<string>();
    global DateTime previousRunTime;
    List<String> giftQueries = new List<String>();
    global RollupBatch()
    {
    }
    global RollupBatch(DateTime lastRun)
    {
        previousRunTime = lastRun;
    }
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        //get a list of constieunts whose gift is updated or created since the last run.
        if (previousRunTime == null) previousRunTime = DateTime.now().addHours(-24);
            
        //string query = 'Select c.Id From Contact c' + 
        //  ' WHERE c.Id IN (Select Constituent__c FROM Gift__c WHERE Constituent__c!=null AND Gift_Date__c !=null AND LastModifiedDate > :previousRunTime )';
        string query = GetQuery();
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    public static string GetQuery()
    {   
        string query = '';
        query += 'SELECT Id, Consecutive_Years_of_Giving__c, Consecutive_Years_of_Transactions__c, Last_Gift_Amount__c, Total_Lifetime_Gifts__c, Total_Lifetime_Giving__c, ';
        query += 'Total_Fiscal_Gifts__c, Total_Fiscal_Year_Giving__c, Total_Lifetime_Transactions__c, Total_Lifetime_Transaction_Amount__c, ';
        query += 'Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c, Total_Lifetime_Fundraising__c, Total_Fiscal_Fundraising__c, ';
        //commented by nitin
        //query += '(Select Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId From Gifts__r ORDER BY Gift_Date__c DESC), ';
        //query += '(Select Id, Amount__c, Gift_Date__c, Gift_Status__c From Additional_Solicitations__r), ';
        query += '(Select Id, Amount__c, Status__c From Gifts1__r), ';
        //query += '(Select Id, Amount__c, Status__c From Gifts1__r) ';
        query += '(Select npe4__RelatedContact__c FROM npe4__Relationships1__r where cv_pkg_dev_I__Apply_Soft_Credit__c=true) ';
        //query += 'FROM Contact c where Id=\'003A000001TQZ1t\'';
        query += 'FROM Contact c';
        
        return query;       
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Map<ID, Contact> scopeMap = new Map<ID, Contact>((List<Contact>)scope);
        List<Contact> contactToUpdate = new List<Contact>();
        //system.debug(scopeMap.keySet().size());
        Set<ID> contactIds = scopeMap.keySet();
        Set<Id> hhIds = new Set<Id>();
        List<Gift__c> gifts = [SELECT Id, HouseholdId__c FROM Gift__c where HouseholdId__c <> null and HouseholdId__c <> '' AND Constituent__c in :contactIds];
        system.debug('giftssize==>'+gifts.size());
        for(Gift__c g : gifts)
        {
            hhIds.add(g.HouseholdId__c);
        }
        //Commented by nitin
        /*for(Contact c : (List<Contact>)scope){
            cid.add(c.id);
            contactRecord.add(c);
        }*/ 
        RecalculateTotalGiving((List<Contact>)scope);
        RecalculateGiftDates(scopeMap.keySet());
        if (hhIds.size() > 0) RecalculateTotalHouseholdGiving(hhIds);
    }
    // Reschedule the job for an hour from now
    global void finish(Database.BatchableContext BC)
    {
        //commented By Nitin
        /*RollupBatchforgift r = new RollupBatchforgift();
        r.cid1.addAll(cid);
        r.con.addAll(contactRecord);
        r.query = 'Select Id, Amount__c, Status__c, Gift_Date__c, Constituent__c, RecordTypeId From Gift__c where Constituent__c IN: cid1 ORDER BY Gift_Date__c DESC';
        Database.executeBatch(r);*/
        //till here
        
        DateTime now = DateTime.now();
        //commented by nitin
        /*Integer ms = now.millisecond();
        Integer second = now.second();
        Integer minute = now.minute();
        Integer hour = now.hour();
        Integer day = now.day();
        Integer year = now.year();
        
        String jobName = 'Rollup Batch for Contacts: ' + hour + ':' + minute + ':' + second + ';' + ms + ' ' + day + '/' + year;
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();     
        scheduleJobNamesMap = CauseViewCustomSetting.cronJobMethod();
        system.debug('Nitin==>'+scheduleJobNamesMap);
        String jobName = 'Contact Rollup Batch';
        if(!scheduleJobNamesMap.containskey(jobName)){          
            RollupBatch batch = new RollupBatch(now);
            //If there is a default value for batch size defined in the Custom setting use that, otherwise use 60 as default.
            decimal batchSize = 100;
            cv_pkg_dev_I__givingpowerSettings__c settings = cv_pkg_dev_I__givingpowerSettings__c.getInstance('Settings');
            if (settings != null && settings.cv_pkg_dev_I__Rollup_Batch_Size__c > 0) batchSize = settings.cv_pkg_dev_I__Rollup_Batch_Size__c;
            string cronId = System.scheduleBatch(batch, jobName, 60, Integer.valueOf(batchSize)); 
        }*/
    }
    
    public static void RecalculateGiftDates(Set<Id> contactIds)
    {
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
        String RecordTypeIdforRollup;
        List<String> RecordTypeIdsforRollup;
        //RecordTypeIdforRollup = settings.Record_Type_Id_for_Rollups__c;
        RecordTypeIdforRollup = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
        
        RecordTypeIdsforRollup = RecordTypeIdforRollup.Split(',');
        //AggregateResult[] results = [SELECT AVG(Amount__c)avgGiftAmt, MAX(Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Constituent__c con 
        //                                FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c != null
        //                                    AND  RecordTypeId = :settings.RegularGiftRecordTypeId__c
        //                                GROUP BY Constituent__c];
          
        //System.debug(results);    
        //AggregateResult[] last_year = [SELECT SUM(Amount__c) total, Constituent__c con
        //                                FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c = LAST_YEAR
        //                                    AND  RecordTypeId = :settings.RegularGiftRecordTypeId__c
        //                                GROUP BY Constituent__c]; 
                                   
        Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1);
        Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31);      
        //AggregateResult[] last2_year = [SELECT SUM(Amount__c) total, Constituent__c con
        //                                FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
        //                                    AND  RecordTypeId = :settings.RegularGiftRecordTypeId__c
        //                                GROUP BY Constituent__c];                                                    
      

        Set<ID> contactIdsToUpdate = new Set<ID>();
        List<Contact> contacts = [Select c.Id, c.Total_Giving_Last_Year__c, c.Total_Giving_Two_Years_Ago__c, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.Largest_Gift__c, c.Average_Gift__c, c.cv_pkg_dev_I__Date_of_Last_Transaction__c, c.cv_pkg_dev_I__Date_of_First_Transaction__c From Contact c Where Id IN :contactIds];     
        System.debug(contacts);
        //if (last_year != null && last_year.size() > 0)
        //{
            for(AggregateResult result : [SELECT SUM(Amount__c) total, Constituent__c con
                                        FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c = LAST_YEAR
                                            AND   (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup)
                                        GROUP BY Constituent__c])
            {
                Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
                Decimal total_giving_last_year = (Decimal)result.get('total');
                if (c != null && c.Total_Giving_Last_Year__c <> total_giving_last_year)
                {
                    c.Total_Giving_Last_Year__c = total_giving_last_year;
                    if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);
                }
            }
        //}
        //if (last2_year != null && last2_year.size() > 0)
        //{
            for(AggregateResult result : [SELECT SUM(Amount__c) total, Constituent__c con
                                        FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
                                            AND   (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup)
                                        GROUP BY Constituent__c])
            {              
                Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
                Decimal total_giving_two_years_ago = (Decimal)result.get('total');
                if (c != null && c.Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago)
                {
                    c.Total_Giving_Two_Years_Ago__c = total_giving_two_years_ago;
                    if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);
                }
            }
        //}
        //if (results != null && results.size() > 0)
        //{
        
            for(AggregateResult result : [SELECT AVG(Amount__c)avgGiftAmt, MAX(Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Constituent__c con 
                                        FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c != null
                                            AND   (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup)
                                        GROUP BY Constituent__c])
                                        
            {
                Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts); 
                Date date_of_last_gift = Date.valueOf(result.get('maxGiftDate'));
                Date date_of_first_gift = Date.valueOf(result.get('minGiftDate'));
                Decimal largest_gift = (Decimal)result.get('maxGiftAmt');
                Decimal average_gift = (Decimal)result.get('avgGiftAmt');                 
                if (c != null && (c.Date_of_Last_Gift__c <> date_of_last_gift ||
                    c.Date_of_First_Gift__c <> date_of_first_gift || c.Largest_Gift__c <> largest_gift || c.Average_Gift__c <> average_gift))
                {
                    c.Date_of_Last_Gift__c = date_of_last_gift;
                    c.Date_of_First_Gift__c = date_of_first_gift;
                    c.Largest_Gift__c = largest_gift;
                    c.Average_Gift__c = average_gift;
                    if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);
                }
            }
            
            //added by nitin to update "Date of First Transaction" and "Date of Last Transaction" to contact record 
            for(AggregateResult result : [SELECT MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Constituent__c con 
                                        FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c != null
                                        GROUP BY Constituent__c])
            {
                Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
                Date date_of_last_gift = Date.valueOf(result.get('maxGiftDate'));
                Date date_of_first_gift = Date.valueOf(result.get('minGiftDate'));
                if (c != null && (c.cv_pkg_dev_I__Date_of_Last_Transaction__c <> date_of_last_gift || c.cv_pkg_dev_I__Date_of_First_Transaction__c <> date_of_first_gift))
                {
                    c.cv_pkg_dev_I__Date_of_Last_Transaction__c = date_of_last_gift;
                    c.cv_pkg_dev_I__Date_of_First_Transaction__c = date_of_first_gift;
                    if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);
                }
            }    //till here
        //}
        List<Contact> values = new List<Contact>();
        for (Contact c : contacts)
        {
            if (contactIdsToUpdate.contains(c.Id)) values.add(c);
        }
        if (values.size() > 0) update values;
   }

    private static void RecalculateTotalGiving(List<Contact> contacts)
    {
       system.debug('<======inside REcalculateTotalGiving======>');
        if (contacts == null || contacts.size() <= 0) return;
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default'); 
        String RecordTypeIdforRollup1;
        List<String> RecordTypeIdsforRollup1 = new List<String>();
        Set<String> recordIds = new Set<String>();
        RecordTypeIdforRollup1 = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
        system.debug('dbglg '+RecordTypeIdforRollup1);
        RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');
        if(RecordTypeIdsforRollup1.size()>0)
        {
        for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++)
        {
                    system.debug('dbglog '+RecordTypeIdsforRollup1.size());

            recordIds.add(RecordTypeIdsforRollup1[i]);
        }
        }
        //Added by Nitin
        Set<Id> contactIds = new Set<Id>();
        Map<Id, List<Gift__c>> GiftRecordMap = new Map<Id, List<Gift__c>>();
        Map<Id, List<Solicitor__c>> softCreditRecordMap = new Map<Id, List<Solicitor__c>>();
        for(Contact c : contacts){
            contactIds.add(c.id);
        }
        for(Gift__c g : [Select Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId, Constituent__c From Gift__c where Constituent__c IN : contactIds ORDER BY Gift_Date__c DESC, CreatedDate DESC ]){
            if(!GiftRecordMap.containsKey(g.Constituent__c)){
                GiftRecordMap.put(g.Constituent__c, new List<Gift__c>());
            }
            GiftRecordMap.get(g.Constituent__c).add(g);
        }
        for(Solicitor__c s : [Select Id, Amount__c, Gift_Date__c, Gift_Status__c, Solicitor__c From Solicitor__c where Solicitor__c IN : contactIds]){
            if(!softCreditRecordMap.containsKey(s.Solicitor__c)){
                softCreditRecordMap.put(s.Solicitor__c, new List<Solicitor__c>());
            }
            softCreditRecordMap.get(s.Solicitor__c).add(s);
        }
        //till here  
        List<Contact> contactsToUpdate = new List<Contact>();
        
        integer org;
        org = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
    
        List<Date> gDates = new List<Date>();
        List<Date> tDates = new List<Date>();
        for(Contact c : contacts)
        {
            Decimal lastGiftAmount = 0;
            Decimal totalAmount = 0;        
            Decimal totalFiscalAmount = 0;
            Decimal totalCount = 0;
            Decimal totalFiscalCount = 0;
            Decimal totalGivingAmount = 0;
            Decimal totalFiscalGivingAmount = 0;
            Decimal totalGivingCount = 0;
            Decimal totalFiscalGivingCount = 0;
            Decimal total_additional_solicitations = 0;
            Decimal total_solicitations = 0;
            Decimal consecutive_years_of_giving = 0;
            Decimal consecutive_years_of_transactions = 0;
            if (GiftRecordMap.get(c.id) != null)
            {
                //added by nitin on 26/09/2014  
                //Pivotal Tracker - Last Gift Amount field Not Calculating Only On Record Type = Gift
                for(Gift__c g : GiftRecordMap.get(c.id)){
                    if(g.RecordTypeId == settings.RegularGiftRecordTypeId__c){
                        lastGiftAmount = g.Amount__c;
                        break;
                    } 
                }       
            }
            if(GiftRecordMap.get(c.id) != null)
            {    
                for(Gift__c g : GiftRecordMap.get(c.id))
                {
                    if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                    {
                        totalGivingAmount += g.Amount__c; totalAmount += g.Amount__c; gDates.add(g.Gift_Date__c); tDates.add(g.Gift_Date__c);
                        totalGivingCount++; totalCount++;
                    }
                    else
                    {
                        totalAmount += g.Amount__c; tDates.add(g.Gift_Date__c); totalCount++;
                    }        
                    if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
                    {
                        if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                        {
                            totalFiscalGivingAmount += g.Amount__c; totalFiscalAmount += g.Amount__c; totalFiscalGivingCount++; totalFiscalCount++;
                        }
                        else
                        {
                            totalFiscalAmount += g.Amount__c; totalFiscalCount++;
                        }
                    }
                }
            }
            if (softCreditRecordMap.get(c.id) != null)
            {
                for(Solicitor__c s : softCreditRecordMap.get(c.id))
                {
                    //tDates.add(s.Gift_Date__c); 
                    total_additional_solicitations += (s.Amount__c == null) ? 0 : s.Amount__c;
                }
            }
            if(c.Gifts1__r.size() > 0){
                for(Gift__c g2 : c.Gifts1__r)
                {
                    system.debug('<=Inside Primary=>'+g2);
                    total_solicitations += g2.Amount__c;
                    system.debug('total_solicitations==>'+total_solicitations);
                }
            }
            system.debug('Contact==>'+c.id);
            if (gDates.size() != 0)
            {
                if (org == null)
                {
                     consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, 1);
                }
                else
                {
                    consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, org);
                    

                }
            }
            system.debug('consecutive_years_of_giving=='+consecutive_years_of_giving);
            if (tDates.size() != 0)
            {
                if (org == null)
                {
                    consecutive_years_of_transactions = GivingpowerUtility.ConseqFiscalYears(tDates, 1);
                }
                else
                {
                    consecutive_years_of_transactions = GivingpowerUtility.ConseqFiscalYears(tDates, org);
                }
            }
            gDates.clear();
            tDates.clear();
            system.debug('consecutive_years_of_transactions=='+consecutive_years_of_transactions);
            if (c.Total_Lifetime_Gifts__c <> totalGivingCount || c.Total_Lifetime_Giving__c <> totalGivingAmount ||
                c.Total_Fiscal_Gifts__c <> totalFiscalGivingCount || c.Total_Fiscal_Year_Giving__c <> totalFiscalGivingAmount ||
                c.Total_Lifetime_Transactions__c <> totalCount || c.Total_Lifetime_Transaction_Amount__c <> totalAmount ||
                c.Total_Fiscal_Transactions__c <> totalFiscalCount || c.Total_Fiscal_Transaction_Amount__c <> totalFiscalAmount ||
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Total_Lifetime_Fundraising__c <> totalGivingAmount + total_additional_solicitations + total_solicitations ||
                c.Consecutive_Years_of_Giving__c <> consecutive_years_of_giving || c.Consecutive_Years_of_Transactions__c <> consecutive_years_of_transactions ||
                c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c <> totalFiscalGivingAmount + total_additional_solicitations + total_solicitations)
            {
                c.Total_Lifetime_Gifts__c = totalGivingCount;
                c.Total_Lifetime_Giving__c = totalGivingAmount;
                c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
                c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;
                c.Total_Lifetime_Transactions__c = totalCount;       
                c.Total_Lifetime_Transaction_Amount__c = totalAmount;
                c.Total_Fiscal_Transactions__c = totalFiscalCount;
                c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;
                c.Last_Gift_Amount__c = lastGiftAmount;
                
                //c.Total_Lifetime_Fundraising__c = totalAmount + total_additional_solicitations + total_solicitations;
                c.Total_Lifetime_Fundraising__c = totalGivingAmount + total_additional_solicitations + total_solicitations;
               
                c.Consecutive_Years_of_Giving__c = consecutive_years_of_giving;
                c.Consecutive_Years_of_Transactions__c = consecutive_years_of_transactions;
                system.debug('---Inside RecalculateTotalGiving---');
                system.debug('consecutive_years_of_giving==>'+consecutive_years_of_giving);
                system.debug('consecutive_years_of_transactions==>'+consecutive_years_of_transactions);
                system.debug('c.Consecutive_Years_of_Giving__c==>'+c.Consecutive_Years_of_Giving__c);
                system.debug('c.Consecutive_Years_of_Transactions__c==>'+c.Consecutive_Years_of_Transactions__c);
                
                 c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c =  totalFiscalGivingAmount + total_additional_solicitations + total_solicitations;
                
                contactsToUpdate.add(c);
                
                
                
            }
        }
        update contactsToUpdate;
    }

    public static void RecalculateTotalHouseholdGiving(Set<Id> hhIds)
    {
        system.debug(hhIds);
        if (hhIds == null || hhIds.size()<=0) return;
        List<Account> households = [SELECT Id, cv_pkg_dev_I__Total_Household_Fundraising__c, cv_pkg_dev_I__Total_Fiscal_Household_Transactions__c , cv_pkg_dev_I__Total_Household_Transactions__c , cv_pkg_dev_I__Total_Household_Giving__c , cv_pkg_dev_I__Total_Fiscal_Household_Giving__c , cv_pkg_dev_I__Total_Fiscal_Household_Fundraising__c,  (SELECT Id, cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c, cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c, cv_pkg_dev_I__Total_Fiscal_Year_Giving__c, cv_pkg_dev_I__Total_Lifetime_Fundraising__c, cv_pkg_dev_I__Total_Lifetime_Giving__c , cv_pkg_dev_I__Total_Fiscal_Fundraising__c FROM cv_pkg_dev_I__HouseholdContacts__r) FROM Account WHERE Id IN :hhIds];
        integer org = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
        List<Account> accountsToUpdate = new List<Account>();
        List<Date> gDates = new List<Date>();
        List<Date> tDates = new List<Date>();
        Set<String> cIds = new Set<String>();
        
        for(Account a : households)
        {
            Decimal totalAmount = 0;        
            Decimal totalFiscalAmount = 0;
            Decimal totalGivingAmount = 0;
            Decimal totalFiscalGivingAmount = 0;
            Decimal totalFundraisingAmount = 0;
            Decimal totalFiscalFundraisingAmount = 0;          
            for(Contact c : a.cv_pkg_dev_I__HouseholdContacts__r)
            {
                if (c.cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c != 0 && c.cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c != null)
                {
                    totalFiscalAmount += c.cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c;
                }
                if (c.cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c!= 0 && c.cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c!= null)
                {
                    totalAmount += c.cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c;
                }
                if (c.cv_pkg_dev_I__Total_Fiscal_Year_Giving__c!= 0 && c.cv_pkg_dev_I__Total_Fiscal_Year_Giving__c!= null)
                {
                    totalFiscalGivingAmount += c.cv_pkg_dev_I__Total_Fiscal_Year_Giving__c;
                }
                if (c.cv_pkg_dev_I__Total_Lifetime_Giving__c!= 0 && c.cv_pkg_dev_I__Total_Lifetime_Giving__c!= null)
                {
                    totalGivingAmount += c.cv_pkg_dev_I__Total_Lifetime_Giving__c;
                }   
                if (c.cv_pkg_dev_I__Total_Lifetime_Fundraising__c != 0 && c.cv_pkg_dev_I__Total_Lifetime_Fundraising__c != null)
                {
                    totalFundraisingAmount += c.cv_pkg_dev_I__Total_Lifetime_Fundraising__c;
                } 
                
                if(c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c != 0 && c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c != null)
                {
                    totalFiscalFundraisingAmount += c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c;
                }  
            }
            if (a.cv_pkg_dev_I__Total_Household_Giving__c <> totalGivingAmount || a.cv_pkg_dev_I__Total_Fiscal_Household_Giving__c <> totalFiscalGivingAmount || 
                a.cv_pkg_dev_I__Total_Household_Transactions__c <> totalAmount || a.cv_pkg_dev_I__Total_Fiscal_Household_Transactions__c <> totalFiscalAmount || 
                a.cv_pkg_dev_I__Total_Household_Fundraising__c <> totalFundraisingAmount || a.cv_pkg_dev_I__Total_Fiscal_Household_Fundraising__c <> totalFiscalFundraisingAmount)
            { 
                a.cv_pkg_dev_I__Total_Household_Giving__c = totalGivingAmount;
                a.cv_pkg_dev_I__Total_Fiscal_Household_Giving__c = totalFiscalGivingAmount;
                a.cv_pkg_dev_I__Total_Household_Transactions__c = totalAmount;
                a.cv_pkg_dev_I__Total_Fiscal_Household_Transactions__c = totalFiscalAmount;
                a.cv_pkg_dev_I__Total_Household_Fundraising__c = totalFundraisingAmount;
                a.cv_pkg_dev_I__Total_Fiscal_Household_Fundraising__c  = totalFiscalFundraisingAmount;        
                accountsToUpdate.add(a);
            }
        }
        update accountsToUpdate;
    } 
}
