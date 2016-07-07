trigger RollupNamesReceived on Event_Registration__c (after insert, after update, after delete, after undelete) {
    //if(system.isBatch()!=true){
        
        Set<Id> transIds = new Set<Id>();
        //BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        //String guestId = settings.Unknown_Guest_Id__c;
        
        if (Trigger.IsDelete || Trigger.IsUpdate ) {
            for (Event_Registration__c er : Trigger.old) {
                if(er.Transaction__c != null){
                    transIds.add(er.Transaction__c);
                }
            }
        }
        else {
            for (Event_Registration__c er : Trigger.new) {
                if(er.Transaction__c != null){
                    transIds.add(er.Transaction__c);
                }   
            }    
        }
        if(transIds.size() > 0){
        	if(system.isFuture()!=true)
            EventRegistrationTrigger.RollupNamesReceivedTrigger(transIds); 
            /*List<Gift__c> trans = [SELECT Id, Attendee_Names_Received__c, (SELECT Id FROM Event_Registrations__r WHERE Individual__c != :guestId ) FROM Gift__c WHERE Id IN :transIds FOR UPDATE];

            List<Gift__c> updateGift = new List<Gift__c>();
            
            
            if(trans.size() > 0)
            {
            for (Gift__c g : trans) {
            if(g.Attendee_Names_Received__c != g.Event_Registrations__r.size())
            {
            g.Attendee_Names_Received__c = g.Event_Registrations__r.size();
            updateGift.add(g); 
            }   
            }
            if(updateGift.size() > 0)
            update updateGift;
            }*/
        }
   // }
    
}