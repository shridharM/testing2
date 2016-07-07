global class NewYearTransactionScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      
      //activate this year gifts that were created last year
      List<Gift__c> thisYearGifts = [SELECT Id, Status__c FROM Gift__c 
            WHERE Gift_Date__c = THIS_YEAR AND Status__c != 'Active'
            AND Recurring_Donation__c IN (SELECT id FROM Recurring_Donation__c 
            WHERE Start_Date__c = THIS_YEAR AND Status__c = 'Active')];
      
      /*if (thisYearGifts!=null && thisYearGifts.size()>0)
      {
        for(Gift__c g : thisYearGifts)
            g.Status__c = 'Active';
        update thisYearGifts;
      }*/
      
      //recreate last year recurring gifts for this year:
      NewYearTransactionsBatch giftBatch = new NewYearTransactionsBatch();
      Database.executeBatch(giftBatch);
      
   }
}