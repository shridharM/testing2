global class RollupBatchAppealScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    Database.executeBatch(new RollupBatchAppeal(), 20);   
  }
   
}