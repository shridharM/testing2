global class RollupBatchCampaignScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new RollupBatchCampaign(), 200);  
  }
}