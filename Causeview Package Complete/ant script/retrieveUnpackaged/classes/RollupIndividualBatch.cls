global class RollupIndividualBatch implements Database.Batchable<sObject> {
  global Database.Querylocator start(Database.BatchableContext BC) 
  {
        String query = 'SELECT Id FROM Gift__c';
        return Database.getQueryLocator(query);
  }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {  }
  
}