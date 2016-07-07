global class CCExpiryBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global final Date thirty;
    global final Date fifteen;
    global final Date seven; 
    global Integer success;
    global Integer total;    
     public string query;
     
     
     
    global CCExpiryBatch()
    {
    
        
        
    
        thirty = Date.today()+30;
        fifteen = Date.today()+15;
        seven = Date.today()+7;
        success = 0;
        total = 0;
    }    
    
    global Database.Querylocator start(Database.BatchableContext BC) {
        if (!System.Test.isRunningTest())
        {query = 'SELECT r.Id, r.Constituent__c, r.Credit_Card_Expiry_Date__c, r.causeview__Status__c, r.Amount__c, r.Reference__c, r.URL_Safe_Key__c FROM Recurring_Donation__c r WHERE r.Credit_Card_Expiry_Date__c = :thirty OR r.Credit_Card_Expiry_Date__c = :fifteen OR r.Credit_Card_Expiry_Date__c = :seven' ;}        
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {      
        CCExpiryUtil.RenewCCs((List<Recurring_Donation__c>)scope);
    }
    
    global void finish(Database.BatchableContext BC) {}
}