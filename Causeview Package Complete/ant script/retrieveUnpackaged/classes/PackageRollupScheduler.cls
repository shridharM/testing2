global class PackageRollupScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new PackageRollupBatch(), 200);   
  }
   
}