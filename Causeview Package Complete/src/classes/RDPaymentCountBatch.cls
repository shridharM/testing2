global class RDPaymentCountBatch implements Database.Batchable<sObject> {
  
  //global Set<Id> AIDs = new Set<Id>();
  public string query;
  global Database.Querylocator start(Database.BatchableContext BC)
  {
    //(Select New_Campaign__c FROM Gift_Detail__c WHERE New_Campaign__c!=null AND Allocated_Date__c !=null AND LastModifiedDate > :previousRunTime )
    //string query = 'Select a.Id From Campaign a WHERE Id = \'701M00000005EjKIAU\''; 
    //string query = 'Select a.Id From Campaign a';
        
    //if (!System.Test.isRunningTest())
    { query = 'SELECT causeview__Donation__c,causeview__StatusComment__c,causeview__Status__c,Id FROM causeview__Payment__c  WHERE LastModifiedDate = yesterday ALL ROWS'; }  
    
    return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
     Map<ID, causeview__Payment__c> scopeMap = new Map<ID, causeview__Payment__c>((List<causeview__Payment__c>)scope);
     Map<Id, causeview__Payment__c> map_GiftId_Payment = new Map<Id,causeview__Payment__c>();
     for(causeview__Payment__c payment : scopeMap.values())
     {
        if((payment.causeview__Status__c == 'Approved' || payment.causeview__Status__c == 'Declined') && !map_GiftId_Payment.containsKey(payment.causeview__Donation__c))
        {    
            map_GiftId_Payment.put(payment.causeview__Donation__c,payment);   
        }
     }
     recurringGiftFieldUpdateTriggerclass.recurringGiftFieldUpdate(map_GiftId_Payment.keySet());
  }
  
  global void finish(Database.BatchableContext BC)
  {
  }
}