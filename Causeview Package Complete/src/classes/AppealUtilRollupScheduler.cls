global class AppealUtilRollupScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    /* String sh='0 0 22 * * ?';
    AppealRollupBatch2 appealrollup= new AppealRollupBatch2(); 
    system.schedule('Appeal Roll Up', sh,appealrollup);*/
    
    Database.executeBatch(new AppealUtilRollBatch(), 20);   
  }
   
}