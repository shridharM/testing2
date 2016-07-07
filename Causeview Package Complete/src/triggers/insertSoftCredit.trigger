trigger insertSoftCredit  on causeview__Solicitor__c (after insert) {
  /*  causeview__Solicitor__c SoftCredit = [SELECT Id, Name, causeview__Gift__c FROM causeview__Solicitor__c WHERE Id IN : Trigger.newMap.KeySet() LIMIT 1];
    Id transId = SoftCredit.causeview__Gift__c;
    List<causeview__Gift_Detail__c> allocs = [SELECT Id FROM causeview__Gift_Detail__c A WHERE A.causeview__Gift__r.Id = :transId];
    
    for (causeview__Gift_Detail__c allocation : allocs) 
    {
        soft_credit_allocation__c softalloc = new soft_credit_allocation__c();
        softalloc.Soft_Credit__c = SoftCredit.Id;
        softalloc.Allocation__c = allocation.Id;
        insert softalloc;
    }*/
}