trigger updateTransactionStatus on Recurring_Donation__c (after insert, after update) {
    set<Id> rdIds = new set<Id>();
    for (Recurring_Donation__c rd : trigger.new)
    {
        if (rd.cv_pkg_dev_I__Status__c == 'Cancelled')
        {
            rdIds.add(rd.id);
        }
    }
    if(rdIds.size() > 0){
        List<cv_pkg_dev_I__Gift__c> gifts = [select Id, cv_pkg_dev_I__Status__c from cv_pkg_dev_I__Gift__c where cv_pkg_dev_I__Recurring_Donation__c IN :rdIds FOR UPDATE];
        for (cv_pkg_dev_I__Gift__c gift : gifts)
        {
            gift.cv_pkg_dev_I__Status__c = 'Payment Received';
        } 
        update gifts;   
    }
    
}