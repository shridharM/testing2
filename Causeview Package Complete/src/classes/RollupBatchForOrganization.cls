global class RollupBatchForOrganization implements Database.Batchable<sObject> {
 
    global DateTime previousRunTime;
    global static  Map<String, decimal> conversion_rates = new Map<String, decimal>();
    global static Boolean  MultiCurrencyEn;
    global static String userIsoCode;
    
    global RollupBatchForOrganization()
    {    	
    }
    
    global RollupBatchForOrganization(DateTime lastRun) {
        previousRunTime = lastRun;        
    }
    
    public static void multiCurrencySupport(){   		
        MultiCurrencyEn = UserInfo.isMultiCurrencyOrganization();
        userIsoCode = UserInfo.getDefaultCurrency();
        
        if(MultiCurrencyEn==true){
	    	List<sObject> sobjList = Database.query('SELECT IsoCode,ConversionRate, IsCorporate FROM CurrencyType');
	      	for(sObject curr: sobjList){          
	          conversion_rates.put((String)curr.get('IsoCode'),(decimal)curr.get('ConversionRate'));          
	        }
        }        
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
        query += 'SELECT Id, causeview__Last_Gift_Amount__c, causeview__Total_Lifetime_Fundraising__c, Consecutive_Years_of_Giving__c, Consecutive_Years_of_Transactions__c, Total_Lifetime_Gifts__c, Total_Lifetime_Giving__c, Total_Fiscal_Gifts__c, ';
        if(UserInfo.isMultiCurrencyOrganization()==true){
        	query += 'CurrencyIsoCode, ';
        }
        query += 'Total_Fiscal_Year_Giving__c, Total_Lifetime_Transactions__c, Total_Lifetime_Transaction_Amount__c, Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c,Last_Payment_Amount__c,Last_Payment_Date__c ';
         
        //query += '(SELECT Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId FROM causeview__Orders__r ORDER BY Gift_Date__c DESC) ';
        //query += '(Select Id, Amount__c, Gift_Date__c, Gift_Status__c From Soft_Credits__r), ';
        //query += '(Select Id, Amount__c, Status__c From Orders1__r) ';
        query += 'FROM Account WHERE RecordType.Name <> \'HouseHold\'';
        //query += ' AND Id = \'001A000001B4LuW\'';
        
       
        return query;
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Map<ID, Account> scopeMap = new Map<ID, Account>((List<Account>)scope);
        multiCurrencySupport();
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
        scheduleJobNamesMap = cvpkgdev1CustomSetting.cronJobMethod();
        system.debug('Nitin==>'+scheduleJobNamesMap);
        if(!scheduleJobNamesMap.containskey(jobName)){    
            RollupBatchForOrganization batch = new RollupBatchForOrganization(now);
            decimal batchSize = 100;
            causeview__givingpowerSettings__c settings = causeview__givingpowerSettings__c.getInstance('Settings');
            if (settings != null && settings.causeview__Rollup_Batch_Size__c > 0) batchSize = settings.causeview__Rollup_Batch_Size__c;
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
        string bucketAccount = settings.causeview__BucketAccountId__c;
        
        //user story ---->https://www.pivotaltracker.com/story/show/110070048, to include pledge record type
        RecordType r = [Select Name, Id From RecordType where Name ='Pledge' AND NamespacePrefix = 'causeview' AND sObjectType='causeview__Gift__c'];
        
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
        List<Account> accounts = new List<Account>(); 
        if(MultiCurrencyEn){    
        	accounts= Database.query('Select c.Id, c.CurrencyIsoCode, c.Last_Payment_Amount__c, c.Last_Payment_Date__c, c.Largest_Gift__c, c.Average_Gift__c, c.Total_Giving_Last_Year__c, c.Total_Giving_Two_Years_Ago__c, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.causeview__Date_of_First_Transaction__c, c.causeview__Date_of_Last_Transaction__c From Account c Where Id IN :orgIds');
        }else{
            accounts = [Select c.Id, c.Last_Payment_Amount__c, c.Last_Payment_Date__c, c.Largest_Gift__c, c.Average_Gift__c, c.Total_Giving_Last_Year__c, c.Total_Giving_Two_Years_Ago__c, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.causeview__Date_of_First_Transaction__c, c.causeview__Date_of_Last_Transaction__c From Account c Where Id IN :orgIds];
        }      
        System.debug('RecalculateGiftDatesForOrg Account :=>'+accounts);
         System.debug('RecalculateGiftDatesForOrg Account size :=>'+accounts.size());
        //if (results != null && results.size()>0)
        //{
            for(AggregateResult result : [SELECT AVG(Amount__c)avgGiftAmt, MAX(Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Organization__c org 
                                        FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c != null
                                            AND  (RecordTypeId In :RecordTypeIdsforRollup OR RecordTypeId =: r.Id) AND Organization__c <> :bucketAccount
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
                    c.Largest_Gift__c =((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)largest_gift) : largest_gift);
                    c.Average_Gift__c =((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)average_gift) : average_gift);
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
                if (c != null && (c.causeview__Date_of_Last_Transaction__c <> date_of_last_gift || c.causeview__Date_of_First_Transaction__c <> date_of_first_gift))
                {
                    c.causeview__Date_of_Last_Transaction__c = date_of_last_gift;
                    c.causeview__Date_of_First_Transaction__c = date_of_first_gift;
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }
            }
            //till here
        //}
        //if (last_year != null && last_year.size() > 0)
        //{
           List<Account> accounts1 = new list<Account>();
		 	if(MultiCurrencyEn){    
		    	accounts1= [Select c.Id, c.Largest_Gift__c, c.Average_Gift__c, c.Total_Giving_Last_Year__c, c.Total_Giving_Two_Years_Ago__c, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.causeview__Date_of_First_Transaction__c, c.causeview__Date_of_Last_Transaction__c,(select id,name ,Gift_Date__c, convertCurrency(Amount__c), Organization__c from Orders__r where Gift_Date__c = LAST_YEAR
                                            AND  (RecordTypeId In :RecordTypeIdsforRollup OR RecordTypeId =: r.Id) AND Organization__c <> :bucketAccount ) From Account c Where Id IN :orgIds];
		    }else{
		        accounts1= [Select c.Id, c.Largest_Gift__c, c.Average_Gift__c, c.Total_Giving_Last_Year__c, c.Total_Giving_Two_Years_Ago__c, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.causeview__Date_of_First_Transaction__c, c.causeview__Date_of_Last_Transaction__c,(select id,name ,Gift_Date__c,Amount__c,Organization__c from Orders__r where Gift_Date__c = LAST_YEAR
                                            AND  (RecordTypeId In :RecordTypeIdsforRollup OR RecordTypeId =: r.Id) AND Organization__c <> :bucketAccount ) From Account c Where Id IN :orgIds];
		    }
            /* for(AggregateResult result : [SELECT SUM(Amount__c) total, Organization__c org
                                        FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c = LAST_YEAR
                                            AND  (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup) AND Organization__c <> :bucketAccount
                                        GROUP BY Organization__c])*/
                for(Account a: accounts1) 
                 { 
                   if(a.Orders__r != null && a.Orders__r.size() >0)           
                         
                 {
                    //System.debug('RecalculateGiftDatesForOrg AggregateResult for sum lastyear :=>'+result);
                    //Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);
                    Account c = (Account)RollupHelper.findItem('Id', a.Id, accounts);
                    Decimal total_giving_last_year = 0;
                    
                      for(gift__c g:a.Orders__r)
                      {
                       total_giving_last_year +=((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), (Decimal)g.Amount__c) : g.Amount__c);
                      
                      }
                    
                    if (c != null && c.Total_Giving_Last_Year__c <> total_giving_last_year)
                    {
                    c.Total_Giving_Last_Year__c = total_giving_last_year;
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                    }
                 }
                else
                {
                 Account c = (Account)RollupHelper.findItem('Id', a.Id, accounts);
                 c.Total_Giving_Last_Year__c = null;
                 if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
             
                }
             }

        //if (last2_year != null && last2_year.size()>0)
        //{
        
            List<Account> accounts2 = new List<Account>();
 			if(MultiCurrencyEn){    
		    	accounts2= [Select c.Id, c.Largest_Gift__c, c.Average_Gift__c, c.Total_Giving_Last_Year__c, c.Total_Giving_Two_Years_Ago__c, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.causeview__Date_of_First_Transaction__c, c.causeview__Date_of_Last_Transaction__c,(select id,name ,Gift_Date__c, convertCurrency(Amount__c), Organization__c from Orders__r where Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
                                            AND  ( RecordTypeId In :RecordTypeIdsforRollup OR RecordTypeId =: r.Id) AND Organization__c <> :bucketAccount ) From Account c Where Id IN :orgIds];
		    }else{
		        accounts2= [Select c.Id, c.Largest_Gift__c, c.Average_Gift__c, c.Total_Giving_Last_Year__c, c.Total_Giving_Two_Years_Ago__c, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.causeview__Date_of_First_Transaction__c, c.causeview__Date_of_Last_Transaction__c,(select id,name ,Gift_Date__c,Amount__c,Organization__c from Orders__r where Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
                                            AND  ( RecordTypeId In :RecordTypeIdsforRollup OR RecordTypeId =: r.Id) AND Organization__c <> :bucketAccount ) From Account c Where Id IN :orgIds];
		    }
            /* for(AggregateResult result : [SELECT SUM(Amount__c) total, Organization__c org
                                        FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
                                            AND  (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup) AND Organization__c <> :bucketAccount
                                        GROUP BY Organization__c]) */
                for(Account a:accounts2)                        
                {
            
                   if(a.Orders__r != null && a.Orders__r.size() >0)           
                         
                  {
                   //System.debug('RecalculateGiftDatesForOrg AggregateResult for sum lastyear :=>'+result);
                   // Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);
                    Account c = (Account)RollupHelper.findItem('Id', a.Id, accounts);
                    Decimal total_giving_two_years_ago = 0;
                    
                    for(Gift__c g:a.Orders__r)
                    {
                      total_giving_two_years_ago +=((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), (Decimal)g.Amount__c) : g.Amount__c);
                    }
                    if (c != null && c.Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago)
                    {
                    c.Total_Giving_Two_Years_Ago__c = total_giving_two_years_ago;
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                    }
               }
               else
               {    
                    Account c = (Account)RollupHelper.findItem('Id', a.Id, accounts);
                    c.Total_Giving_Two_Years_Ago__c = null;
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
               }
            }
            
            
            //new code to calculate last payment date  -25/02/2016 
            // https://www.pivotaltracker.com/story/show/115068827 --> only for Approved Payments 
            for(AggregateResult result : [SELECT MIN(Date__c) minpaymentdate,  MAX(Date__c) maxpaymentDate ,Donation__r.Organization__c con , causeview__Status__c  FROM payment__c  where Donation__r.Organization__c IN :orgIds AND Donation__r.RecordTypeId IN :RecordTypeIdsforRollup AND causeview__Status__c = 'Approved' GROUP BY Donation__r.Organization__c, causeview__Status__c ]) 
            {
                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('con')), accounts);
                
                Date Last_Payment_Date = Date.valueOf(result.get('maxpaymentDate'));
                
                if (c != null && (c.Last_Payment_Date__c <> Last_Payment_Date ))
                {
                    c.Last_Payment_Date__c = Last_Payment_Date;
                   
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }

          }
            
    
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
        
        //user story ---->https://www.pivotaltracker.com/story/show/110070048, to include pledge record type
        RecordType r = [Select Name, Id From RecordType where Name ='Pledge' AND NamespacePrefix = 'causeview' AND sObjectType='causeview__Gift__c'];
        string pledgeRecordTypeId = r.id;
        recordIds.add(pledgeRecordTypeId);        
        
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
        Map<Id, List<Payment__c>> PaymentRecordMap = new Map<Id, List<Payment__c>>();
        
        if(MultiCurrencyEn){
        for(Gift__c gift :Database.query('SELECT Id, convertCurrency(Amount__c), Status__c, Gift_Date__c, RecordTypeId, RecordType.Name, Organization__c FROM Gift__c where Organization__c IN : account_Ids ORDER BY Gift_Date__c DESC, CreatedDate DESC')){
            if(!gift_Map.containsKey(gift.Organization__c)){
                gift_Map.put(gift.Organization__c, new List<Gift__c>());
            }
            gift_Map.get(gift.Organization__c).add(gift);
        }
        }
        else{
        for(Gift__c gift : [SELECT Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId, RecordType.Name, Organization__c FROM Gift__c where Organization__c IN : account_Ids ORDER BY Gift_Date__c DESC, CreatedDate DESC]){
            if(!gift_Map.containsKey(gift.Organization__c)){
                gift_Map.put(gift.Organization__c, new List<Gift__c>());
            }
            gift_Map.get(gift.Organization__c).add(gift);
        }
        }
        
        if(MultiCurrencyEn){
        for(Solicitor__c softCredit :Database.query('Select Id, convertCurrency(Amount__c), Gift_Date__c, Gift_Status__c, Organization_Solicitor__c From Solicitor__c where Organization_Solicitor__c IN : account_Ids')){
            if(!soft_Credit_Map.containsKey(softCredit.Organization_Solicitor__c)){
                soft_Credit_Map.put(softCredit.Organization_Solicitor__c, new List<Solicitor__c>());
            }
            soft_Credit_Map.get(softCredit.Organization_Solicitor__c).add(softCredit);
        }
        }
        else{
        for(Solicitor__c softCredit : [Select Id, Amount__c, Gift_Date__c, Gift_Status__c, Organization_Solicitor__c From Solicitor__c where Organization_Solicitor__c IN : account_Ids]){
            if(!soft_Credit_Map.containsKey(softCredit.Organization_Solicitor__c)){
                soft_Credit_Map.put(softCredit.Organization_Solicitor__c, new List<Solicitor__c>());
            }
            soft_Credit_Map.get(softCredit.Organization_Solicitor__c).add(softCredit);
        }
        }
        
        if(MultiCurrencyEn){
        for(Gift__c gift1 : [Select Id, convertCurrency(Amount__c), Status__c,Gift_Date__c, Foundation_Credit__c From Gift__c where Foundation_Credit__c IN : account_Ids]){
            if(!gift1_Map.containsKey(gift1.Foundation_Credit__c)){
                gift1_Map.put(gift1.Foundation_Credit__c, new List<Gift__c>());
            }
            gift1_Map.get(gift1.Foundation_Credit__c).add(gift1);
        }
        }
        else {
        for(Gift__c gift1 : [Select Id, Amount__c, Status__c,Gift_Date__c, Foundation_Credit__c From Gift__c where Foundation_Credit__c IN : account_Ids]){
            if(!gift1_Map.containsKey(gift1.Foundation_Credit__c)){
                gift1_Map.put(gift1.Foundation_Credit__c, new List<Gift__c>());
            }
            gift1_Map.get(gift1.Foundation_Credit__c).add(gift1);
        }
        }
         //new code for calculate last payment date and last payment amount 25-feb2-2016 
         // https://www.pivotaltracker.com/story/show/115068827 --> only for Approved Payments 
        if(MultiCurrencyEn)
        {
        	for(Payment__c p: Database.query('select Id, Name , convertCurrency(Amount__c), Date__c , Donation__r.RecordType.Name, Donation__r.Organization__c ,Donation__r.RecordTypeId, causeview__Status__c  from Payment__c where Donation__r.Organization__c IN : account_Ids AND  causeview__Status__c = \'Approved\' AND Donation__r.RecordTypeId IN : recordIds ORDER BY Date__c DESC, CreatedDate DESC'))
               {
                 if(!PaymentRecordMap.containsKey(p.Donation__r.Organization__c))  {
                  		paymentRecordMap.put(p.Donation__r.Organization__c, new List<Payment__c>());
               		}
                  PaymentRecordMap.get(p.Donation__r.Organization__c).add(p);
        	}
        }
        else{
        	 for(Payment__c p: [select Id, Name , Amount__c,Date__c , Donation__r.RecordType.Name, Donation__r.Organization__c ,Donation__r.RecordTypeId, causeview__Status__c  from Payment__c where Donation__r.Organization__c IN : account_Ids AND  causeview__Status__c = 'Approved' AND Donation__r.RecordTypeId IN : recordIds ORDER BY Date__c DESC, CreatedDate DESC ])
               {
                 if(!PaymentRecordMap.containsKey(p.Donation__r.Organization__c))  {
                  		paymentRecordMap.put(p.Donation__r.Organization__c, new List<Payment__c>());
               		}
                  PaymentRecordMap.get(p.Donation__r.Organization__c).add(p);
        		}       
        }
       
    System.debug('RecalculateTotalGivingForOrg  for loop of accounts');
        for(Account c : accounts)
        {
            Decimal lastGiftAmount = 0;
            Decimal lastPaymentAmount = 0;
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
            
            /*if (c.causeview__Orders__r != null)
            {
                if(c.causeview__Orders__r.size() > 0)
                {
                    //added by nitin on 26/09/2014  
                    //Pivotal Tracker - Last Gift Amount field Not Calculating Only On Record Type = Gift
                    for(Gift__c g : c.causeview__Orders__r){*/
            if(gift_Map.get(c.Id) != null){
                for(Gift__c g : gift_Map.get(c.Id))
                {
                    if(settings.RegularGiftRecordTypeId__c.contains(g.RecordTypeId) && g.RecordType.name == 'Gift'){
                        system.debug('Nitin g===='+g);
                        lastGiftAmount = g.Amount__c;
                        break;
                    } 
                }            
            }
            
            
              if (PaymentRecordMap.get(c.id) != null)
            {
                 for(Payment__c p : PaymentRecordMap.get(c.id)){
                    if(settings.RegularGiftRecordTypeId__c.contains(p.Donation__r.RecordTypeId) && p.Donation__r.RecordType.Name == 'Gift'){
                        lastPaymentAmount = p.Amount__c;
                        break;
                    } 
                }       
            }
            
          System.debug('RecalculateTotalGivingForOrg in loop gift size :=>'+(c.causeview__Orders__r).size());
            
            //for(Gift__c g : c.causeview__Orders__r)
            if(gift_Map.get(c.Id) != null){
                for(Gift__c g : gift_Map.get(c.Id))
                {
                    system.debug('dbglog1o '+recordIds.Contains(g.RecordTypeId));
                    if ((settings.RegularGiftRecordTypeId__c.contains(g.RecordTypeId))||(recordIds.Contains(g.RecordTypeId)))
                    {
                        system.debug('dbglog1 '+recordIds.Contains(g.RecordTypeId));
                        totalGivingAmount += g.Amount__c;
                        totalAmount += g.Amount__c;
                        gDates.add(g.Gift_Date__c); 
                        tDates.add(g.Gift_Date__c); 
                        totalGivingCount++;
                        totalCount++;
                    }
                    else
                    {
                        system.debug('dbglog2 '+recordIds.Contains(g.RecordTypeId));
                        totalAmount += g.Amount__c;
                        tDates.add(g.Gift_Date__c);
                        totalCount++;
                    }        
                    if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
                    {
                        if((settings.RegularGiftRecordTypeId__c.contains(g.RecordTypeId))||(recordIds.Contains(g.RecordTypeId)))
                        {
                            totalFiscalGivingAmount += g.Amount__c;
                            totalFiscalAmount += g.Amount__c;
                            totalFiscalGivingCount++;
                            totalFiscalCount++;
                        }
                        else
                        {
                            totalFiscalAmount += g.Amount__c;
                            totalFiscalCount++;
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
                     
                     //if(GivingpowerUtility.isCurrentFiscal(s.Gift_Date__c, org)) {
                    total_additional_solicitations += (s.Amount__c == null) ? 0 : s.Amount__c;
                   /* system.debug('-----------------------------Soft_Credits__r-----------------------------------------------------');
                    system.debug(total_additional_solicitations);
                    system.debug('-----------------------------Soft_Credits__r-----------------------------------------------------');
                    */
                  // }
                }
            }
            //for(Gift__c g2 : c.Orders1__r)
            if(gift1_Map.get(c.id) != null){
                for(Gift__c g2 : gift1_Map.get(c.id))
                {
                 //if(GivingpowerUtility.isCurrentFiscal(g2.Gift_Date__c, org)) {
                    total_solicitations += g2.Amount__c;
                   /* system.debug('-----------------------------Orders1__r-----------------------------------------------------');
                    system.debug(total_solicitations);
                    system.debug('-----------------------------Orders1__r-----------------------------------------------------');
                   */   
                  // }
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
          		
                totalGivingAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalGivingAmount) : totalGivingAmount);                
                totalFiscalGivingAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalGivingAmount) : totalFiscalGivingAmount);                       
                totalAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalAmount) : totalAmount);
                lastGiftAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastGiftAmount) : lastGiftAmount);                
                totalFiscalAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalAmount) : totalFiscalAmount);               
                total_additional_solicitations=((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_additional_solicitations) : total_additional_solicitations);
                total_solicitations=((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_solicitations) : total_solicitations);
                lastPaymentAmount  = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastPaymentAmount) : lastPaymentAmount); 
               
            if (c.Total_Lifetime_Gifts__c <> totalGivingCount || c.Total_Lifetime_Giving__c <> totalGivingAmount ||
                c.Total_Fiscal_Gifts__c <> totalFiscalGivingCount || c.Total_Fiscal_Year_Giving__c <> totalFiscalGivingAmount ||
                c.Total_Lifetime_Transactions__c <> totalCount || c.Total_Lifetime_Transaction_Amount__c <> totalAmount ||
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Total_Fiscal_Transactions__c <> totalFiscalCount ||
                c.Total_Fiscal_Transaction_Amount__c <> totalFiscalAmount || c.Total_Lifetime_Fundraising__c <> totalGivingAmount + total_additional_solicitations + total_solicitations ||   
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Consecutive_Years_of_Giving__c <> consecutive_years_of_giving ||
                c.Consecutive_Years_of_Transactions__c <> consecutive_years_of_transactions ||
                c.Last_Payment_Amount__c  <> lastPaymentAmount)
            {
                c.Total_Lifetime_Gifts__c = totalGivingCount;
                c.Total_Lifetime_Giving__c = totalGivingAmount;
                c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
                c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;
                c.Total_Lifetime_Transactions__c = totalCount;       
                c.Total_Lifetime_Transaction_Amount__c = totalAmount;
                c.Last_Gift_Amount__c =lastGiftAmount;        
                c.Total_Fiscal_Transactions__c = totalFiscalCount;
                c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;                
                c.Total_Lifetime_Fundraising__c = totalGivingAmount + total_additional_solicitations + total_solicitations;   
                c.Last_Gift_Amount__c =lastGiftAmount;
                c.Consecutive_Years_of_Giving__c = consecutive_years_of_giving;
                c.Consecutive_Years_of_Transactions__c = consecutive_years_of_transactions;
                c.Last_Payment_Amount__c  = lastPaymentAmount;
                 
                 /*if(MultiCurrencyEn) {
                 c.put('CurrencyIsoCode',userIsoCode);
                 } */
                  accountsToUpdate.add(c);
                  system.Debug('Processing Account: ' + c.Id);
            }
        }
        update accountsToUpdate;
    }
    
    public static Decimal convertCurrencyWithApexCode(String oCurrency, String nCurrency, Decimal  amount){       
        //Convert Currency
      if(amount != null){
	      if(oCurrency!='corpCurr'){               
	        amount = amount / conversion_rates.get(oCurrency);       
	       }
	       amount = amount * conversion_rates.get(nCurrency);  
	       return amount;
   		 }
   		 return 0;
    }
}