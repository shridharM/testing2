global class BatchContactUpdateOnEventRegistration implements Database.Batchable<sObject> {
    list<contact> contactsToBeUpdated = new list<contact>();
    list<cv_pkg_dev_I__Event_Registration__c> eventRegistrationsToBeUpdated = new list<cv_pkg_dev_I__Event_Registration__c>();
    map<string, contact> mapEventRegistrationToContact = new map<string, contact>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string query = 'select cv_pkg_dev_I__Attendee_First_Name__c, cv_pkg_dev_I__Attendee_Last_Name__c , cv_pkg_dev_I__Attendee_Email__c from cv_pkg_dev_I__Event_Registration__c  ';             
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<cv_pkg_dev_I__Event_Registration__c> scope) {
        system.debug('execute---------: ');
        list<contact > contactRecords = [select FirstName , LastName , Email  from contact limit 50000];
        string newRecord;
        for(cv_pkg_dev_I__Event_Registration__c eventRegistration : scope){
            newRecord = 'yes';
            system.debug('========'+ eventRegistration.cv_pkg_dev_I__Attendee_First_Name__c);
            if(eventRegistration.cv_pkg_dev_I__Attendee_First_Name__c != null || eventRegistration.cv_pkg_dev_I__Attendee_Last_Name__c != null || eventRegistration.cv_pkg_dev_I__Attendee_Email__c != null){
                for(contact con : contactRecords){
                    if(con.FirstName == eventRegistration.cv_pkg_dev_I__Attendee_First_Name__c && con.LastName == eventRegistration.cv_pkg_dev_I__Attendee_Last_Name__c && con.Email == eventRegistration.cv_pkg_dev_I__Attendee_Email__c){
                        //update the contact record
                        contactsToBeUpdated.add(con); 
                        mapEventRegistrationToContact.put(eventRegistration.id, con);                   
                        newRecord='no';
                        break;
                    }
                    
                }
                if(newRecord=='yes'){
                    contact newContact = new contact();//create new contact
                    newContact.FirstName=eventRegistration.cv_pkg_dev_I__Attendee_First_Name__c;
                    newContact.LastName=eventRegistration.cv_pkg_dev_I__Attendee_Last_Name__c;
                    newContact.Email=eventRegistration.cv_pkg_dev_I__Attendee_Email__c;
                    contactsToBeUpdated.add(newContact);
                    
                    mapEventRegistrationToContact.put(eventRegistration.id, newContact);           
                    
                }
            }
        }
        try{
            upsert contactsToBeUpdated;            
        }
        catch(Exception  e){
            
        }
        
        for(cv_pkg_dev_I__Event_Registration__c eventRegistration : scope){
            if(mapEventRegistrationToContact.containsKey(eventRegistration.id)){
                eventRegistration.cv_pkg_dev_I__Individual__c = mapEventRegistrationToContact.get(eventRegistration.id).id;
                eventRegistrationsToBeUpdated.add(eventRegistration);
            }
        }
        try{
            update eventRegistrationsToBeUpdated;            
        }
        catch(Exception  e){
            system.debug('--Exception---'+e.getMessage());
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        
        
    }
}