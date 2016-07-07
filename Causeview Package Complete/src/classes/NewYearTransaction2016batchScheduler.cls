global class NewYearTransaction2016batchScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new NewYearTransaction2016batch(), 200);   
  }
   
}