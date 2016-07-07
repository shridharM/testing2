global class RollupScheduler implements Schedulable {
	global void execute(SchedulableContext SC) {
		//when was thr 
		CronTrigger ct = [Select c.TimesTriggered, c.State, c.StartTime, 
		   c.PreviousFireTime, c.NextFireTime, c.Id, 
		   c.EndTime, c.CronExpression 
		   From CronTrigger c WHERE c.id = :SC.getTriggerId()];
		   
		//read custom settings
		decimal batchSize = 10;
		List<givingpowerSettings__c> settingsRecords = [SELECT Rollup_Batch_Size__c FROM givingpowerSettings__c WHERE name = 'settings'];
        if (settingsRecords != null && settingsRecords.size()>0 && settingsRecords[0].Rollup_Batch_Size__c!=null) {
        	batchSize = settingsRecords[0].Rollup_Batch_Size__c;
        }
		
		System.debug('schedule trigger id: ' + SC.getTriggerId());
		System.debug('schedule previous fire time: ' + ct.PreviousFireTime);
		
		Datetime PreviousFireTime = ct.PreviousFireTime;
		if (ct.PreviousFireTime==null || ct.PreviousFireTime>=DateTime.now().addMinutes(-5))
			PreviousFireTime = DateTime.now().addHours(-24);
		
		Database.executeBatch(new RollupBatch(PreviousFireTime), batchSize.intValue());
		Database.executeBatch(new RollupSolicitorBatch(PreviousFireTime), batchSize.intValue());	
	}
  
}
