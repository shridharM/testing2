global class RollupBatchPackageScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new RollupBatchPackage(), 40);   
  }
   
}