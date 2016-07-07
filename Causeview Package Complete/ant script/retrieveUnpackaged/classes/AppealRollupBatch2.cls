global class AppealRollupBatch2 implements Database.Batchable<sObject> {
  
  //global Set<Id> AIDs = new Set<Id>();
  public string query;
  public string camp_rtid;
    
  global AppealRollupBatch2()
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
  
  global void finish(Database.BatchableContext BC)
  {
    //Database.executeBatch(new AppealRollupBatch3(), 1);
     
        
        DateTime now = DateTime.now();
        
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();     
        scheduleJobNamesMap = CauseViewCustomSetting.cronJobMethod();
       
        String jobName = 'Campaign Rollup Batch';
        if(!scheduleJobNamesMap.containskey(jobName))
       {          
            AppealRollupBatch3 batch = new AppealRollupBatch3();
            //String sh='0 0 22 * * ?';
            //If there is a default value for batch size defined in the Custom setting use that, otherwise use 60 as default.
            //decimal batchSize = 100;
            //cv_pkg_dev_I__givingpowerSettings__c settings = cv_pkg_dev_I__givingpowerSettings__c.getInstance('Settings');
            //if (settings != null && settings.cv_pkg_dev_I__Rollup_Batch_Size__c > 0) batchSize = settings.cv_pkg_dev_I__Rollup_Batch_Size__c;
            string cronId = System.scheduleBatch(batch, jobName, 10, 1);
    
       
       }
}
}