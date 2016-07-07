global class AppealRollupScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new AppealRollupBatch(), 1);   
  }
   
}