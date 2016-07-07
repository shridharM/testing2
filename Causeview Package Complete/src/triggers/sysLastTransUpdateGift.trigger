trigger sysLastTransUpdateGift on Gift__c (after insert, after update) {
       
     if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c) {     
        if(!Validator_cls.isAlreadyModified()){
            Validator_cls.setAlreadyModified();
           
               //For RollUpName Trigger To avoid cycle 
               String guestId = BatchSettings__c.getInstance('Default').Unknown_Guest_Id__c;
               system.debug('Nitin===>'+trigger.newMap.keySet());
               List<Gift__c> trans = [SELECT Id, Attendee_Names_Received__c, (SELECT Id FROM Event_Registrations__r WHERE Individual__c != :guestId ) FROM Gift__c WHERE Id IN : trigger.newMap.keySet()];
               
    
               if(trans.size() > 0)
               {
                   List<Gift__c> updateGift = new List<Gift__c>();
                     for (Gift__c g : trans) 
                     {
                       if(g.Attendee_Names_Received__c != g.Event_Registrations__r.size())
                        {
                            
                            g.Attendee_Names_Received__c = g.Event_Registrations__r.size();
                            updateGift.add(g);
                        }
                     }
                     if(updateGift.size() > 0)
                         update updateGift;      
                }
       
          //Systransc Update Logic
        List<Event_Registration__c> toUpdateEventReg = new List<Event_Registration__c>();
        List<Event_Registration__c> eventRegList = [SELECT Id,sysLastTransactionUpdate__c FROM Event_Registration__c WHERE Transaction__c IN: Trigger.newMap.keySet() FOR UPDATE];
        
        if(eventRegList.size() > 0)
         {
            for(Event_Registration__c eventReg: eventRegList)
            {
               eventReg.sysLastTransactionUpdate__c = system.today();
               toUpdateEventReg.add(eventReg);        
            }
            if(toUpdateEventReg.size() > 0) 
             update toUpdateEventReg;
         }
        }
    }
}