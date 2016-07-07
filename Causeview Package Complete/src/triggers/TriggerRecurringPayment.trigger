trigger TriggerRecurringPayment on Payment__c (after insert, after update) {
    
      

     Set<Id> paymentIdstest = new Set<Id>(trigger.newMap.keyset());
    //if(!Validator_cls.isAlreadyModifiedforTriggerRecurringPayment()) 
   // for(payment__c p: Trigger.new) { paymentIdstest.add(p.Id);}    
    //if( Validator_cls.paymentids.isEmpty() )  
        system.debug('#########    paymentIdstest    #######' + paymentIdstest);
       // system.debug('#########    Validator_cls.paymentidsset    #######' + Validator_cls.paymentidsset);

        //system.debug('#########    paymentIdstest.containsAll(Validator_cls.paymentidsset    #######' + paymentIdstest.containsAll(Validator_cls.paymentidsset) );

    if(Validator_cls.paymentidsset.isEmpty() || !(paymentIdstest.containsAll(Validator_cls.paymentidsset) ))  
    //if(!Validator_cls.isAlreadyModifiedforTriggerRecurringPayment() ) 
    {   
      
        Boolean myval = paymentIdstest.containsAll(Validator_cls.paymentidsset);
        //system.debug('hiiiiiiiiiiiii' + myval);
       // Validator_cls.setAlreadyModifiedforTriggerRecurringPayment();
        Set<Id> paymentIds = new Set<Id>();
       
        if (trigger.isInsert)
        {
            for(Payment__c p : trigger.new)
             if (p.Status__c=='Approved' && p.Amount__c!=0)    //|| p.Status__c=='Deposited'
                paymentIds.add(p.Id); 
                
        }
        else if (trigger.isUpdate)
        {
            //updated payments
           
            
            for(Payment__c p : trigger.new)
                if ((p.Status__c=='Approved') //|| p.Status__c=='Deposited' removed by nitin
                   && (trigger.oldMap.get(p.Id).Status__c!='Approved')) //SCOTT May15th: Removed requirement to recordtype CC && trigger.oldMap.get(p.Id).Status__c!='Deposited' removed by nitin
                {
                    if (p.Amount__c!=0)
                        paymentIds.add(p.Id);
                        
                }
        }
        
        if (paymentIds!=null && paymentIds.size()>0)
        {
         system.debug('hi -------->' +paymentIds.size() );
           RollupHelper.createGiftDetails(paymentIds);
            /*system.debug('<==Inside TriggerRecurringPayment==>'+paymentIds);
            //list of approved, deposited payments
            Set<String> recurringPIds = new Set<String>();
            List<Payment__c> ps = [Select p.Id, p.Donation__r.Gift_Type__c, p.Donation__r.RecordTypeId, p.Donation__c, 
                p.Donation__r.Recurring_Donation__c
                From Payment__c p WHERE id IN :paymentIds AND Amount__c!=0];
                system.debug('ps==>'+ps);
            for(Payment__c p : ps){
            system.debug('Nitin Recurring Donation==='+p.Donation__r.Recurring_Donation__c);
             if (p.Donation__r.Gift_Type__c=='Recurring' || p.Donation__r.Gift_Type__c=='Sponsorship' )    //|| p.Donation__r.Gift_Type__c == 'Pledge'
               recurringPIds.add(p.Id+':'+p.Donation__r.Recurring_Donation__c);
            }
            if (recurringPIds!=null && recurringPIds.size()>0)
                RollupHelper.createGiftDetails(recurringPIds);*/
        }
    }
    
    
    
}