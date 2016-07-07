global class RollupBatchContactScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {    
    Database.executeBatch(new RollupBatchContact(), 200);   
  }
   
}