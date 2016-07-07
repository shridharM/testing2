@RestResource(urlMapping='/UpsertRegistration')
global with sharing class RESTUpsertRegistration {
    
    @HttpPost   
    global static Event_Registration__c UpsertRegistration(Event_Registration__c reg, Contact con) {
        
        upsert con;
        
        if (reg != null) {
            reg.Individual__c = con.Id;
            update reg;
        }
        
        return reg;
    }
}