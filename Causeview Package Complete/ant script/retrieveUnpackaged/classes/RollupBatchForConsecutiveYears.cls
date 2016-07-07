global class RollupBatchForConsecutiveYears implements Database.Batchable<sObject>, Database.stateful{
    
    global List<Contact> contactRecord = new List<Contact>();
    global set<string> cid = new Set<string>();
    global DateTime previousRunTime;
    List<String> giftQueries = new List<String>();
    global RollupBatchForConsecutiveYears()
    {
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
        query += 'Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c, Total_Lifetime_Fundraising__c, ';
        //commented by nitin
        //query += '(Select Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId From Gifts__r ORDER BY Gift_Date__c DESC), ';
        //query += '(Select Id, Amount__c, Gift_Date__c, Gift_Status__c From Additional_Solicitations__r), ';
        query += '(Select Id, Amount__c, Status__c From Gifts1__r), ';
        //query += '(Select Id, Amount__c, Status__c From Gifts1__r) ';
        query += '(Select npe4__RelatedContact__c FROM npe4__Relationships1__r where cv_pkg_dev_I__Apply_Soft_Credit__c=true) ';
        //query += 'FROM Contact c where Id=\'003A000000qVaMQ\'';
        query += 'FROM Contact c';
        
        return query;       
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Map<ID, Contact> scopeMap = new Map<ID, Contact>((List<Contact>)scope);
        List<Contact> contactToUpdate = new List<Contact>();
        //system.debug(scopeMap.keySet().size());
        Set<ID> contactIds = scopeMap.keySet();
        //Commented by nitin
        for(Contact c : (List<Contact>)scope){
            cid.add(c.id);
            contactRecord.add(c);
        }
    }
    // Reschedule the job for an hour from now
    global void finish(Database.BatchableContext BC)
    {
        RollupBatchforgift r = new RollupBatchforgift();
        r.cid1.addAll(cid);
        r.con.addAll(contactRecord);
        r.query = 'Select Id, Amount__c, Status__c, Gift_Date__c, Constituent__c, RecordTypeId From Gift__c where Constituent__c IN: cid1 ORDER BY Gift_Date__c DESC';
        Database.executeBatch(r);
    }
}