global class DuplicateConstituentIdUpdatescheduled implements Schedulable {
   global void execute(SchedulableContext sc) {
      DuplicateConstituentIdUpdateBatch b = new DuplicateConstituentIdUpdateBatch(); 
      database.executebatch(b);
   }
}