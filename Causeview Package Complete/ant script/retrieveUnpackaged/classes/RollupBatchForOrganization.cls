global class RollupBatchForOrganization implements Database.Batchable<sObject> {
 
    global DateTime previousRunTime;
    
    global RollupBatchForOrganization()
    {
    
    }
    
    global RollupBatchForOrganization(DateTime lastRun) {
        previousRunTime = lastRun;
    }
     
    global Database.Querylocator start(Database.BatchableContext BC) {
        //get a list of constieunts whose gift is updated or created since the last run.
        if (previousRunTime == null) previousRunTime = DateTime.now().addHours(-24);
            
        //string query = 'Select c.Id From Account c' + 
        //  ' WHERE c.Id IN (Select Organization__c FROM Gift__c WHERE Organization__c!=null AND Gift_Date__c !=null AND LastModifiedDate > :previousRunTime )';
        string query = GetQuery();
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    public static string GetQuery()
    {
        string query = '';
        query += 'SELECT Id, cv_pkg_dev_I__Last_Gift_Amount__c, cv_pkg_dev_I__Total_Lifetime_Fundraising__c, Consecutive_Years_of_Giving__c, Consecutive_Years_of_Transactions__c, Total_Lifetime_Gifts__c, Total_Lifetime_Giving__c, Total_Fiscal_Gifts__c, ';
        query += 'Total_Fiscal_Year_Giving__c, Total_Lifetime_Transactions__c, Total_Lifetime_Transaction_Amount__c, Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c '; 
        //query += '(SELECT Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId FROM cv_pkg_dev_I__Orders__r ORDER BY Gift_Date__c DESC) ';
        //query += '(Select Id, Amount__c, Gift_Date__c, Gift_Status__c From Soft_Credits__r), ';
        //query += '(Select Id, Amount__c, Status__c From Orders1__r) ';
        query += 'FROM Account WHERE RecordType.Name <> \'HouseHold\'';
        //query += ' AND Id = \'001A000001B4LuW\'';
        
       
        return query;
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Map<ID, Account> scopeMap = new Map<ID, Account>((List<Account>)scope);
        system.debug('Parameter for RecalculateGiftDatesForOrg scopemapkeyset:=>'+scopeMap.keySet().size());
        system.debug('Parameter for RecalculateTotalGivingForOrg Account list:=>'+((List<Account>)scope).size());
        RecalculateTotalGivingForOrg((List<Account>)scope, scopeMap.keySet());
        RecalculateGiftDatesForOrg(scopeMap.keySet());
    }
    
    global void finish(Database.BatchableContext BC)
    {
        DateTime now = DateTime.now();
        //commented by Nitin
        /*Integer ms = now.millisecond();
        Integer second = now.second();
        Integer minute = now.minute();
        Integer hour = now.hour();
        Integer day = now.day();
        Integer year = now.year();
        String jobName = 'Rollup Batch for Organizations: ' + hour + ':' + minute + ':' + second + ';' + ms + ' ' + day + '/' + year;
        String jobName = 'Account Rollup Batch';
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();     
        scheduleJobNamesMap = CauseViewCustomSetting.cronJobMethod();
        system.debug('Nitin==>'+scheduleJobNamesMap);
        if(!scheduleJobNamesMap.containskey(jobName)){    
            RollupBatchForOrganization batch = new RollupBatchForOrganization(now);
            decimal batchSize = 100;
            cv_pkg_dev_I__givingpowerSettings__c settings = cv_pkg_dev_I__givingpowerSettings__c.getInstance('Settings');
            if (settings != null && settings.cv_pkg_dev_I__Rollup_Batch_Size__c > 0) batchSize = settings.cv_pkg_dev_I__Rollup_Batch_Size__c;
            string cronId = System.scheduleBatch(batch, jobName, 60, Integer.valueOf(batchSize));
        }*/
    }

    public static void RecalculateGiftDatesForOrg(Set<Id> orgIds)
    {
       system.debug(' In RecalculateTotalGivingForOrg'+orgIds.size());
        String RecordTypeIdforRollup;
        List<String> RecordTypeIdsforRollup;
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
        RecordTypeIdforRollup = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;

        RecordTypeIdsforRollup = RecordTypeIdforRollup.Split(',');
        string bucketAccount = settings.cv_pkg_dev_I__BucketAccountId__c;
        if (bucketAccount == '') bucketAccount = null;
        //AggregateResult[] results = [SELECT AVG(Amount__c)avgGiftAmt, MAX(Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Organization__c org 
        //                                FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c != null
        //                                    AND  RecordTypeId = :settings.RegularGiftRecordTypeId__c
        //                                GROUP BY Organization__c]; 
        //AggregateResult[] last_year = [SELECT SUM(Amount__c) total, Organization__c org
        //                                FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c = LAST_YEAR
        //                                    AND  RecordTypeId = :settings.RegularGiftRecordTypeId__c
        //                                GROUP BY Organization__c]; 

        Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1);
        Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31);      

        //AggregateResult[] last2_year = [SELECT SUM(Amount__c) total, Organization__c org
        //                                FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
        //                                    AND  RecordTypeId =:settings.RegularGiftRecordTypeId__c
        //                                GROUP BY Organization__c];           

        //System.debug(results);
        Set<ID> accountIdsToUpdate = new Set<ID>();
        List<Account> accounts = [Select c.Id, c.Largest_Gift__c, c.Average_Gift__c, c.Total_Giving_Last_Year__c, c.Total_Giving_Two_Years_Ago__c, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.cv_pkg_dev_I__Date_of_First_Transaction__c, c.cv_pkg_dev_I__Date_of_Last_Transaction__c From Account c Where Id IN :orgIds];    
        System.debug('RecalculateGiftDatesForOrg Account :=>'+accounts);
         System.debug('RecalculateGiftDatesForOrg Account size :=>'+accounts.size());
        //if (results != null && results.size()>0)
        //{
            for(AggregateResult result : [SELECT AVG(Amount__c)avgGiftAmt, MAX(Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Organization__c org 
                                        FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c != null
                                            AND  (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup) AND Organization__c <> :bucketAccount
                                        GROUP BY Organization__c])
            {
            
                System.debug('RecalculateGiftDatesForOrg AggregateResult for min max :=>'+result);
               
                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);
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
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }
            }
            
            //added by nitin to update "Date of First Transaction" and "Date of Last Transaction" to Account record 
            for(AggregateResult result : [SELECT MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Organization__c org 
                                        FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c != null AND Organization__c <> :bucketAccount
                                        GROUP BY Organization__c])
            {
            
                System.debug('RecalculateGiftDatesForOrg AggregateResult for min max :=>'+result);
               
                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);
                Date date_of_last_gift = Date.valueOf(result.get('maxGiftDate'));
                Date date_of_first_gift = Date.valueOf(result.get('minGiftDate'));
                if (c != null && (c.cv_pkg_dev_I__Date_of_Last_Transaction__c <> date_of_last_gift || c.cv_pkg_dev_I__Date_of_First_Transaction__c <> date_of_first_gift))
                {
                    c.cv_pkg_dev_I__Date_of_Last_Transaction__c = date_of_last_gift;
                    c.cv_pkg_dev_I__Date_of_First_Transaction__c = date_of_first_gift;
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }
            }
            //till here
        //}
        //if (last_year != null && last_year.size() > 0)
        //{
            for(AggregateResult result : [SELECT SUM(Amount__c) total, Organization__c org
                                        FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c = LAST_YEAR
                                            AND  (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup) AND Organization__c <> :bucketAccount
                                        GROUP BY Organization__c])
            {
                 System.debug('RecalculateGiftDatesForOrg AggregateResult for sum lastyear :=>'+result);
                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);
                Decimal total_giving_last_year = (Decimal)result.get('total');
                if (c != null && c.Total_Giving_Last_Year__c <> total_giving_last_year)
                {
                    c.Total_Giving_Last_Year__c = total_giving_last_year;
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }
            }
        //}

        //if (last2_year != null && last2_year.size()>0)
        //{
            for(AggregateResult result : [SELECT SUM(Amount__c) total, Organization__c org
                                        FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
                                            AND  (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup) AND Organization__c <> :bucketAccount
                                        GROUP BY Organization__c])
            {
               System.debug('RecalculateGiftDatesForOrg AggregateResult for sum lastyear :=>'+result);
                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);
                Decimal total_giving_two_years_ago = (Decimal)result.get('total');
                if (c != null && c.Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago)
                {
                    c.Total_Giving_Two_Years_Ago__c = total_giving_two_years_ago;
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }
            }
        //}
        List<Account> values = new List<Account>();
        
  System.debug('RecalculateGiftDatesForOrg Accounts size :=>'+accounts.size());
        for (Account c : accounts)
        {
            if (accountIdsToUpdate.contains(c.Id)) values.add(c);
        }
        if (values.size() > 0) update values;
    }

    public static void RecalculateTotalGivingForOrg(List<Account> accounts, Set<Id> account_Ids)
    {
    
        System.debug('RecalculateTotalGivingForOrg Accounts size :=>'+accounts.size());
        if (accounts == null || accounts.size() <= 0) return;
        List<Account> accountsToUpdate = new List<Account>();
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
        String RecordTypeIdforRollup1;
        List<String> RecordTypeIdsforRollup1;
        Set<String> recordIds = new Set<String>();
        RecordTypeIdforRollup1 = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
        system.debug('dbglg '+RecordTypeIdforRollup1);
        RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');
        if(RecordTypeIdsforRollup1.size()>0)
        {
        
         System.debug('RecalculateTotalGivingForOrg in if RecordTypeIdsforRollup1 size :=>'+RecordTypeIdsforRollup1.size());
        
        for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++)
        {
           //system.debug('dbglog '+RecordTypeIdsforRollup1.size());

            recordIds.add(RecordTypeIdsforRollup1[i]);
        }
        }
        integer org = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
        List<Date> gDates = new List<Date>();
        List<Date> tDates = new List<Date>();
        Map<Id, List<Gift__c>> gift_Map = new Map<Id, List<Gift__c>>();
        Map<Id, List<Solicitor__c>> soft_Credit_Map = new Map<Id, List<Solicitor__c>>();
        Map<Id, List<Gift__c>> gift1_Map = new Map<Id, List<Gift__c>>();
        for(Gift__c gift : [SELECT Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId, Organization__c FROM Gift__c where Organization__c IN : account_Ids ORDER BY Gift_Date__c DESC, CreatedDate DESC]){
            if(!gift_Map.containsKey(gift.Organization__c)){
                gift_Map.put(gift.Organization__c, new List<Gift__c>());
            }
            gift_Map.get(gift.Organization__c).add(gift);
        }
        for(Solicitor__c softCredit : [Select Id, Amount__c, Gift_Date__c, Gift_Status__c, Organization_Solicitor__c From Solicitor__c where Organization_Solicitor__c IN : account_Ids]){
            if(!soft_Credit_Map.containsKey(softCredit.Organization_Solicitor__c)){
                soft_Credit_Map.put(softCredit.Organization_Solicitor__c, new List<Solicitor__c>());
            }
            soft_Credit_Map.get(softCredit.Organization_Solicitor__c).add(softCredit);
        }
        for(Gift__c gift1 : [Select Id, Amount__c, Status__c, Foundation_Credit__c From Gift__c where Foundation_Credit__c IN : account_Ids]){
            if(!gift1_Map.containsKey(gift1.Foundation_Credit__c)){
                gift1_Map.put(gift1.Foundation_Credit__c, new List<Gift__c>());
            }
            gift1_Map.get(gift1.Foundation_Credit__c).add(gift1);
        }
       
    System.debug('RecalculateTotalGivingForOrg  for loop of accounts');
        for(Account c : accounts)
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
            
            /*if (c.cv_pkg_dev_I__Orders__r != null)
            {
                if(c.cv_pkg_dev_I__Orders__r.size() > 0)
                {
                    //added by nitin on 26/09/2014  
                    //Pivotal Tracker - Last Gift Amount field Not Calculating Only On Record Type = Gift
                    for(Gift__c g : c.cv_pkg_dev_I__Orders__r){*/
            if(gift_Map.get(c.Id) != null){
                for(Gift__c g : gift_Map.get(c.Id))
                {
                    if(g.RecordTypeId == settings.RegularGiftRecordTypeId__c){
                        system.debug('Nitin g===='+g);
                        lastGiftAmount = g.Amount__c;
                        break;
                    } 
                }            
            }
          System.debug('RecalculateTotalGivingForOrg in loop gift size :=>'+(c.cv_pkg_dev_I__Orders__r).size());
            
            //for(Gift__c g : c.cv_pkg_dev_I__Orders__r)
            if(gift_Map.get(c.Id) != null){
                for(Gift__c g : gift_Map.get(c.Id))
                {
                    system.debug('dbglog1o '+recordIds.Contains(g.RecordTypeId));
                    if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                    {
                        system.debug('dbglog1 '+recordIds.Contains(g.RecordTypeId));
                        totalGivingAmount += g.Amount__c; totalAmount += g.Amount__c; gDates.add(g.Gift_Date__c); 
                        tDates.add(g.Gift_Date__c); 
                        totalGivingCount++; totalCount++;
                    }
                    else
                    {
                        system.debug('dbglog2 '+recordIds.Contains(g.RecordTypeId));
                        totalAmount += g.Amount__c; tDates.add(g.Gift_Date__c); totalCount++;
                    }        
                    if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
                    {
                        if((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
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
             
             
             //if (c.Soft_Credits__r != null)
             if(soft_Credit_Map.get(c.id) != null)
            {
               System.debug('RecalculateTotalGivingForOrg in loop gift size :=>'+(c.Soft_Credits__r).size());
                //for(Solicitor__c s : c.Soft_Credits__r)
                for(Solicitor__c s : soft_Credit_Map.get(c.id))
                {
                     tDates.add(s.Gift_Date__c);
                    total_additional_solicitations += (s.Amount__c == null) ? 0 : s.Amount__c;
                   /* system.debug('-----------------------------Soft_Credits__r-----------------------------------------------------');
                    system.debug(total_additional_solicitations);
                    system.debug('-----------------------------Soft_Credits__r-----------------------------------------------------');
                    */
                
                }
            }
            //for(Gift__c g2 : c.Orders1__r)
            if(gift1_Map.get(c.id) != null){
                for(Gift__c g2 : gift1_Map.get(c.id))
                {
                    total_solicitations += g2.Amount__c;
                   /* system.debug('-----------------------------Orders1__r-----------------------------------------------------');
                    system.debug(total_solicitations);
                    system.debug('-----------------------------Orders1__r-----------------------------------------------------');
                   */   
                }
            }
                       
            /*for(Solicitor__c s : c.Soft_Credits__r)
            {
                total_additional_solicitations += s.Amount__c;
                for(Gift__c g2 : c.Orders1__r)
                {
                    total_solicitations += g2.Amount__c;
                }
             }*/
                if (gDates.size() != 0)
                {
                    if (org == null)
                    {
                        consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, 1);
                    }
                    else
                    {
                        consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, org);
                         set<Date> setDate  = new set<Date>(gDates);
      setDate.remove(null);
      gDates.clear();
      //gDates.addAll(setDate);   
      //gDates.sort();
                        system.debug(gDates);
                            system.debug('------------------------else---------------------'+consecutive_years_of_giving );
                    
                    }
                }
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
               tDates.clear();
            if (c.Total_Lifetime_Gifts__c <> totalGivingCount || c.Total_Lifetime_Giving__c <> totalGivingAmount ||
                c.Total_Fiscal_Gifts__c <> totalFiscalGivingCount || c.Total_Fiscal_Year_Giving__c <> totalFiscalGivingAmount ||
                c.Total_Lifetime_Transactions__c <> totalCount || c.Total_Lifetime_Transaction_Amount__c <> totalAmount ||
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Total_Fiscal_Transactions__c <> totalFiscalCount ||
                c.Total_Fiscal_Transaction_Amount__c <> totalFiscalAmount || c.Total_Lifetime_Fundraising__c <> totalGivingAmount + total_additional_solicitations + total_solicitations ||   
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Consecutive_Years_of_Giving__c <> consecutive_years_of_giving ||
                c.Consecutive_Years_of_Transactions__c <> consecutive_years_of_transactions)
            {
                c.Total_Lifetime_Gifts__c = totalGivingCount;
                c.Total_Lifetime_Giving__c = totalGivingAmount;
                c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
                c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;
                c.Total_Lifetime_Transactions__c = totalCount;       
                c.Total_Lifetime_Transaction_Amount__c = totalAmount;
                c.Last_Gift_Amount__c = lastGiftAmount;        
                c.Total_Fiscal_Transactions__c = totalFiscalCount;
                c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;
                c.Total_Lifetime_Fundraising__c = totalGivingAmount + total_additional_solicitations + total_solicitations;   
                c.Last_Gift_Amount__c = lastGiftAmount;
                c.Consecutive_Years_of_Giving__c = consecutive_years_of_giving;
                c.Consecutive_Years_of_Transactions__c = consecutive_years_of_transactions;
                accountsToUpdate.add(c);
                system.Debug('Processing Account: ' + c.Id);
            }
        }
        update accountsToUpdate;
    }
}
