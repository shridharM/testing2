global class NewYearTransactionsBatch implements Database.Batchable<sObject> {
  global Database.Querylocator start(Database.BatchableContext BC) 
  {
        String query = 'SELECT Id, cv_pkg_dev_I__Channel__c, cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Gift_Date__c, cv_pkg_dev_I__Gift_Type__c, cv_pkg_dev_I__Last_Payment_Date__c, cv_pkg_dev_I__Next_Payment_Date__c, cv_pkg_dev_I__Recurring_Donation__c, cv_pkg_dev_I__Reference__c,' 
                    + ' cv_pkg_dev_I__Recurring_Donation__r.cv_pkg_dev_I__Reference__c, cv_pkg_dev_I__Recurring_Donation__r.cv_pkg_dev_I__Constituent__c FROM Gift__c '
                    + ' WHERE Gift_Date__c = LAST_YEAR AND Gift_Type__c = \'Recurring\'';
        return Database.getQueryLocator(query);
  }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        RollupHelper.executeNewYearTransactionsBatch(scope);
    }
    
    global void finish(Database.BatchableContext BC) {  }
  
}