global class RollupBatchAppeal implements Database.Batchable<sObject> {
  
  //global Set<Id> AIDs = new Set<Id>();
  public string query;
  public string camp_rtid;
    
  global RollupBatchAppeal()
  {
       List<RecordType> rts = [SELECT Id, Name FROM RecordType WHERE SobjectType='Campaign' AND Name ='Campaign' AND NamespacePrefix = 'causeview'];
       camp_rtid = rts[0].Id;   
  }   
  
  global Database.Querylocator start(Database.BatchableContext BC)
  {
    //(Select New_Campaign__c FROM Gift_Detail__c WHERE New_Campaign__c!=null AND Allocated_Date__c !=null AND LastModifiedDate > :previousRunTime )
    //string query = 'Select a.Id From Campaign a WHERE Id = \'701M00000005AQjIAM\''; 
    //string query = 'Select a.Id From Campaign a';
    //string query = 'Select a.Id From Campaign a';
    if (!System.Test.isRunningTest())
    { query = 'Select a.Id From Campaign a WHERE Parent.RecordTypeId = \'' + camp_rtid + '\''; }
        
    return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
    Map<ID, Campaign> scopeMap = new Map<ID, Campaign>((List<Campaign>)scope);    
    
    AppealUtil.RollupAppeals(scopeMap.keySet());
  }
  
  global void finish(Database.BatchableContext BC) {}
}