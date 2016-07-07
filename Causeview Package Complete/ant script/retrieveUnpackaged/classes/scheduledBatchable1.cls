global class scheduledBatchable1 implements Schedulable {
   global void execute(SchedulableContext sc) {
      DMAccountRollups b = new DMAccountRollups(); 
      database.executebatch(b);
   }
}