trigger insertSoftCredit  on cv_pkg_dev_I__Solicitor__c (after insert) {
  /*  cv_pkg_dev_I__Solicitor__c SoftCredit = [SELECT Id, Name, cv_pkg_dev_I__Gift__c FROM cv_pkg_dev_I__Solicitor__c WHERE Id IN : Trigger.newMap.KeySet() LIMIT 1];
    Id transId = SoftCredit.cv_pkg_dev_I__Gift__c;
    List<cv_pkg_dev_I__Gift_Detail__c> allocs = [SELECT Id FROM cv_pkg_dev_I__Gift_Detail__c A WHERE A.cv_pkg_dev_I__Gift__r.Id = :transId];
    
    for (cv_pkg_dev_I__Gift_Detail__c allocation : allocs) 
    {
        soft_credit_allocation__c softalloc = new soft_credit_allocation__c();
        softalloc.Soft_Credit__c = SoftCredit.Id;
        softalloc.Allocation__c = allocation.Id;
        insert softalloc;
    }*/
}