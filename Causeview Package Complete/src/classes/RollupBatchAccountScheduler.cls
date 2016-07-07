global class RollupBatchAccountScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new RollupBatchAccount(), 200);   
  }
   
}