global class ConsolidatedReceiptBatch implements Database.Batchable<sObject> {
    
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        String query = 'Select Id, Name, (Select Id, Amount__c, Receipt_Type__c, Status__c From Gifts__r WHERE Receipt_Type__c = \'Consolidated\'  AND Status__c != \'Acknowledged\''
                        + ' AND Status__c != \'Cancelled\' AND Gift_Date__c = LAST_YEAR) From Contact c WHERE '
                        + ' Id IN (SELECT Constituent__c FROM Gift__c WHERE Receipt_Type__c = \'Consolidated\' AND Status__c != \'Acknowledged\''
                        + ' AND Status__c != \'Cancelled\' AND Gift_Date__c = LAST_YEAR AND Amount__c > 0)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        RollupHelper.executeConsolidatedReceiptBatch(scope);
    }
    
    global void finish(Database.BatchableContext BC) { }
}