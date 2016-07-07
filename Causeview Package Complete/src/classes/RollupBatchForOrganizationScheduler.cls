global class RollupBatchForOrganizationScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new RollupBatchForOrganization(), 200);   
  }
   
}