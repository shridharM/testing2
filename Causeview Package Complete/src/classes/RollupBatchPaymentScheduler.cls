global class RollupBatchPaymentScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new RollupBatchPayment(), 200);  

  }
  
 }