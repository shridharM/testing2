trigger updateTransactionStatus on Recurring_Donation__c (after insert, after update) {
    set<Id> rdIds = new set<Id>();
    for (Recurring_Donation__c rd : trigger.new)
    {
        if (rd.causeview__Status__c == 'Cancelled')
        {
            rdIds.add(rd.id);
        }
    }
    if(rdIds.size() > 0){
        List<causeview__Gift__c> gifts = [select Id, causeview__Status__c from causeview__Gift__c where causeview__Recurring_Donation__c IN :rdIds FOR UPDATE];
        for (causeview__Gift__c gift : gifts)
        {
            gift.causeview__Status__c = 'Payment Received';
        } 
        update gifts;   
    }
    
}