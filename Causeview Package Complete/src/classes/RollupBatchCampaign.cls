global class RollupBatchCampaign implements Database.Batchable<sObject> {
  
  //global Set<Id> AIDs = new Set<Id>();
  public string query;
  public string camp_rtid;
    
  global RollupBatchCampaign() {
       List<RecordType> rts = [SELECT Id, Name FROM RecordType WHERE SobjectType='Campaign' AND Name ='Campaign' AND NamespacePrefix = 'causeview'];
       camp_rtid = rts[0].Id;  
  }   
  
  global Database.Querylocator start(Database.BatchableContext BC)
  {
    //(Select New_Campaign__c FROM Gift_Detail__c WHERE New_Campaign__c!=null AND Allocated_Date__c !=null AND LastModifiedDate > :previousRunTime )
    //string query = 'Select a.Id From Campaign a WHERE Id = \'701C0000000cpq4\''; 
    //string query = 'Select a.Id From Campaign a';
    
    if (!System.Test.isRunningTest())
    { 
      query = 'Select a.Id From Campaign a WHERE RecordTypeId = \'' + camp_rtid + '\'';
    }  
    return Database.getQueryLocator(query);
  }
  
  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
    Map<ID, Campaign> scopeMap = new Map<ID, Campaign>((List<Campaign>)scope);    
    AppealUtil.RollupCampaigns(scopeMap.keySet());
  }
  
  global void finish(Database.BatchableContext BC) 
  {
      /* Map<String, String> scheduleJobNamesMap = new Map<String, String>();     
       scheduleJobNamesMap = CauseViewCustomSetting.cronJobMethod();
  
        String jobName = 'Appeal Rollup Batch';
        if(!scheduleJobNamesMap.containskey(jobName))
       {
        AppealRollupBatch2 batch = new AppealRollupBatch2();
        string cronId = System.scheduleBatch(batch, jobName, 10, 1);
       } */
  
   }
}