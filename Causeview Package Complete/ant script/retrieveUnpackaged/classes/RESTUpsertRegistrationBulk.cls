@RestResource(urlMapping='/UpsertRegistrationBulk')
global with sharing class RESTUpsertRegistrationBulk {
    
    @HttpPost   
    global static List<RegistrationWrapper> UpsertRegistration(List<RegistrationWrapper> wrapper_list) {               
        
        system.debug(wrapper_list);
        
        Set<string> contactEmails = new Set<string>();
        Map<string, Contact> contactsToUpdate = new Map<string, Contact>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Event_Registration__c> registrationsToUpdate = new List<Event_Registration__c>();
        
        for (RegistrationWrapper w : wrapper_list) {
            if (w.con != null) {
                if (w.con.Email != '' && w.con.Email != null) {
                    contactEmails.add(w.con.Email);
                }
            }
        }       
        
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email IN :contactEmails AND Email != ''];
        
        for (RegistrationWrapper w : wrapper_list) {
            if (w.con != null) {
                if (w.con.Id != null) {
                    contactsToUpdate.put(w.con.Id, w.con);
                    continue;
                }
                if (w.con.Email != '' && w.con.Email != null) {   
                    if (contacts.size() == 0) {
                        contactsToInsert.add(w.con);
                    }     
                    for (Contact con : contacts) {            
                        if (w.con.Email == con.Email) {
                            boolean isUpdate = false;
                            if (w.con.Id != null) {
                                isUpdate = true;
                                w.con.Id = con.Id;                                
                            }
                            if (isUpdate) {
                                contactsToUpdate.put(w.con.Id, w.con);
                            }
                            else {
                                contactsToInsert.add(w.con);
                            }
                            break;
                        }
                    }
                }               
            }
        }
        
        System.debug(contactsToUpdate);
        
        update contactsToUpdate.values();
        
        system.debug(contactsToInsert);
        
        insert contactsToInsert;
        
        for (RegistrationWrapper w : wrapper_list) {
            w.reg.Individual__c = w.con.Id;
            registrationsToUpdate.add(w.reg);
        }
        
        system.debug(registrationsToUpdate);
        
        upsert registrationsToUpdate;
        
        //Updating Tickets with new registrations
  /*      List<cv_pkg_dev_I__Tickets__c> ticketsToUpdate = new List<cv_pkg_dev_I__Tickets__c>();
        for (RegistrationWrapper rw : wrapper_list) {
            if(rw.tic != null){
                rw.tic.cv_pkg_dev_I__Event_Registration__c = rw.reg.Id;
                ticketsToUpdate.add(rw.tic);
            }    
        }
        if(ticketsToUpdate.size() > 0)
            update ticketsToUpdate;
        
 */       
        /*List<RegistrationWrapper> retVal = new List<RegistrationWrapper>();
        
        Campaign e = new Campaign(Name = 'Event'); 
        insert e;
        
        RegistrationWrapper reg1 = new RegistrationWrapper();
        reg1.con = new Contact(LastName = 'Test1');        
        insert reg1.con;
        
        reg1.reg = new Event_Registration__c(Registration_Date__c = Date.Today(), Individual__c = reg1.con.Id, Event__c = e.Id);
        insert reg1.reg;
        
        retVal.add(reg1);

        RegistrationWrapper reg2 = new RegistrationWrapper();
        reg2.con = new Contact(LastName = 'Test2');
        insert reg2.con;
        
        reg2.reg = new Event_Registration__c(Registration_Date__c = Date.Today(), Individual__c = reg2.con.Id, Event__c = e.Id);        
        insert reg2.reg;
        
        retVal.add(reg2);    */    
        
        return wrapper_list;    
    
    }
}