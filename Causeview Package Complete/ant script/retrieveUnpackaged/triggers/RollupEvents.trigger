trigger RollupEvents on Event_Registration__c (after insert, after update, after delete, after undelete) {
    
    //if(system.isBatch()!=true){
        
        
        Set<String> ContactIDs = new Set<String>();
        
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)
        {
            for (Event_Registration__c er : Trigger.new)
            {
                ContactIDs.add(er.Individual__c);
            }
        }
        
        if (Trigger.isDelete)
        {
            for (Event_Registration__c er : Trigger.old)
            {
                ContactIDs.add(er.Individual__c);        
            }
        }
        
        if(ContactIDs.size() > 0){
        	if(system.isFuture()!=true)
            EventRegistrationTrigger.RollupNamesReceivedTrigger(ContactIDs);
        }
        
                /*List<Contact> Contacts = [SELECT Id, Date_of_Last_Event_Attended__c, Event_Attended__c, Name_of_Last_Event_Attended__c, (SELECT Registration_Date__c, Event__r.Name FROM Event_Registrations__r WHERE Status__c = 'Attended' ORDER BY Registration_Date__c DESC) FROM Contact WHERE Id IN :ContactIDs FOR UPDATE];
        
        for (Contact c : Contacts)
        {
        c.Event_Attended__c = False;
        c.Date_of_Last_Event_Attended__c = null;
        c.Name_of_Last_Event_Attended__c = '';
        
        if (c.Event_Registrations__r.size() != 0)
        {
        c.Event_Attended__c = True;
        c.Date_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Registration_Date__c;
        c.Name_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Event__r.Name;                
        }
        }
        
        update Contacts;*/
    //}
}