global class NewYearTransactionsBatch implements Database.Batchable<sObject> {
  global Database.Querylocator start(Database.BatchableContext BC) 
  {
        String query = 'SELECT Id, causeview__Channel__c, causeview__Constituent__c, causeview__Gift_Date__c, causeview__Gift_Type__c, causeview__Last_Payment_Date__c, causeview__Next_Payment_Date__c, causeview__Recurring_Donation__c, causeview__Reference__c,' 
                    + ' causeview__Recurring_Donation__r.causeview__Reference__c, causeview__Recurring_Donation__r.causeview__Constituent__c FROM Gift__c '
                    + ' WHERE Gift_Date__c = LAST_YEARS AND Gift_Type__c = \'Recurring\'';
        return Database.getQueryLocator(query);
  }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        //RollupHelper.executeNewYearTransactionsBatch(scope);
    }
    
    global void finish(Database.BatchableContext BC) {  }
  
}