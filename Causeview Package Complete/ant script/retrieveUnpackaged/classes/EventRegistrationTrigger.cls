public class EventRegistrationTrigger{
    
    @future
    public static void RollupNamesReceivedTrigger(Set<String> ContactIDs){
        
        List<Contact> Contacts = [SELECT Id, Date_of_Last_Event_Attended__c, Event_Attended__c, Name_of_Last_Event_Attended__c, (SELECT Registration_Date__c, Event__r.Name,Event__r.StartDate FROM Event_Registrations__r WHERE Status__c = 'Attended' ORDER BY Registration_Date__c DESC) FROM Contact WHERE Id IN :ContactIDs FOR UPDATE];
    
        for (Contact c : Contacts)
        {
            c.Event_Attended__c = False;
            c.Date_of_Last_Event_Attended__c = null;
            c.Name_of_Last_Event_Attended__c = '';
            
            if (c.Event_Registrations__r.size() != 0)
            {
                c.Event_Attended__c = True;
               // c.Date_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Registration_Date__c;
               // Date of Last Event Attended Not Calculating Correctly--https://www.pivotaltracker.com/story/show/99610876
               c.Date_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Event__r.StartDate;
                c.Name_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Event__r.Name;                
            }
        }
        
        update Contacts;
    }
    
    @future
    public static void RollupNamesReceivedTrigger(Set<Id> transIds){
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        String guestId = settings.Unknown_Guest_Id__c;
        List<Gift__c> trans = [SELECT Id, Attendee_Names_Received__c, (SELECT Id FROM Event_Registrations__r WHERE Individual__c != :guestId ) FROM Gift__c WHERE Id IN :transIds FOR UPDATE];
           
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
        }
    }
    
}
