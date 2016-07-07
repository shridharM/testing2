trigger UpdateRecurringProfile on causeview__Recurring_Donation__c(after update)
{
    List<causeview__Recurring_Donation__c> recurrings = new List<causeview__Recurring_Donation__c>();
    List<causeview__Recurring_Donation__c> changedRecurrings = new List<causeview__Recurring_Donation__c>();

    for (causeview__Recurring_Donation__c rd : trigger.new)
    {
        if ((rd.Amount__c != trigger.oldMap.get(rd.Id).Amount__c
           || rd.Frequency__c != trigger.oldMap.get(rd.Id).Frequency__c
           || rd.causeview__Status__c != trigger.oldMap.get(rd.Id).causeview__Status__c)
           && trigger.oldMap.get(rd.Id).causeview__Status__c != 'Cancelled'
           && rd.Reference__c != null && rd.Reference__c != '' && !IsGatewayIats(rd.Reference__c)
           && (Util.getDifferenceInSeconds(Datetime.now(), rd.CreatedDate) > 30))
        {
            recurrings.add(rd);
        }

        // check to see if the status has changed
        causeview__Recurring_Donation__c old = (causeview__Recurring_Donation__c)Util.FindObject(trigger.old, rd.Id, 'Id');
        if(old!=null && rd.Reference__c!=null){
        if (old.causeview__Status__c == 'Active' && rd.causeview__Status__c == 'on Hold' && !IsGatewayIats(rd.Reference__c)) {
            changedRecurrings.add(rd);
        }
            
        if (old.causeview__Status__c == 'On Hold' && rd.causeview__Status__c == 'Active' && !IsGatewayIats(rd.Reference__c)) {
            changedRecurrings.add(rd);
        }
        }   
    }

    if (recurrings.size() > 0)
    {
        if (!Test.isRunningTest()) {
            Util.SubmitRecurringChanges(Util.SerializeRecurringItems(recurrings), 'RecurringUpdate');
        }  
    }

    if (changedRecurrings.size() > 0)
    {
        if (!Test.isRunningTest()) {
            Util.SubmitRecurringChanges(Util.SerializeRecurringItems(changedRecurrings), 'EnableDisableProfile');
        }    
    }

    private Boolean IsGatewayIats(String recurringId)
    {
        if(recurringId!=null){
          return Pattern.matches('[A-Z][0-9]+', recurringId);
        }else
        {
            return null;
        }

    }
}
