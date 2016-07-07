trigger UpdateRecurringProfile on cv_pkg_dev_I__Recurring_Donation__c (after update) {

  List<cv_pkg_dev_I__Recurring_Donation__c> recurrings = new List<cv_pkg_dev_I__Recurring_Donation__c>();
  List<cv_pkg_dev_I__Recurring_Donation__c> changedRecurrings = new List<cv_pkg_dev_I__Recurring_Donation__c>();
  
  for(cv_pkg_dev_I__Recurring_Donation__c rd : trigger.new)
  {
      if ((rd.Amount__c != trigger.oldMap.get(rd.Id).Amount__c 
         || rd.Frequency__c != trigger.oldMap.get(rd.Id).Frequency__c 
         || rd.cv_pkg_dev_I__Status__c != trigger.oldMap.get(rd.Id).cv_pkg_dev_I__Status__c )
         && trigger.oldMap.get(rd.Id).cv_pkg_dev_I__Status__c != 'Cancelled'
         && rd.Reference__c != null && rd.Reference__c != ''
         && (Util.getDifferenceInSeconds(Datetime.now(), rd.CreatedDate) > 30))
         {
            recurrings.add(rd);
         }
      
      // check to see if the status has changed   
      cv_pkg_dev_I__Recurring_Donation__c old = (cv_pkg_dev_I__Recurring_Donation__c)Util.FindObject(trigger.old, rd.Id, 'Id');     
      if(old.cv_pkg_dev_I__Status__c == 'Active' && rd.cv_pkg_dev_I__Status__c == 'on Hold')
        changedRecurrings.add(rd);          
      if(old.cv_pkg_dev_I__Status__c == 'On Hold' && rd.cv_pkg_dev_I__Status__c == 'Active')
        changedRecurrings.add(rd);
  }
  if (recurrings.size()>0){
        if(!Test.isRunningTest())
            Util.SubmitRecurringChanges(Util.SerializeRecurringItems(recurrings), 'RecurringUpdate');
  }
        
  if (changedRecurrings.size()>0){
        if(!Test.isRunningTest())
            Util.SubmitRecurringChanges(Util.SerializeRecurringItems(changedRecurrings), 'EnableDisableProfile');
  } 
}