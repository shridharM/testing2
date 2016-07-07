trigger sysLastTransUpdatePayment on Payment__c (before insert, before update) {
 
    if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c) {       
        if(!Validator_cls.isAlreadyModifiedforPayment()){
            Validator_cls.setAlreadyModifiedforPayment();
            List<Event_Registration__c> eventRegList = null;
            List<Event_Registration__c> toUpdateEventReg = new List<Event_Registration__c>();
            set<Id> giftId = new set<Id>();
            for(Payment__c payment: Trigger.new){
                  giftId.add(payment.Donation__c);
            }
            if(giftId.size() > 0){
                //Database.executeBatch(new sysLastTransUpdatePaymentBatch(giftId));
                //Commented by nitin
                eventRegList = [SELECT Id,sysLastTransactionUpdate__c FROM Event_Registration__c WHERE Transaction__c IN: giftId FOR UPDATE];
            }
            //commented by nitin
            if(eventRegList.size() > 0) {
                for(Event_Registration__c eventReg: eventRegList)
                {
                   eventReg.sysLastTransactionUpdate__c = system.today();
                   //toUpdateEventReg.add(eventReg);
                }   
                /*if(toUpdateEventReg.size() > 0) {
                 update toUpdateEventReg;
                }*/
            }
        }
    }
}