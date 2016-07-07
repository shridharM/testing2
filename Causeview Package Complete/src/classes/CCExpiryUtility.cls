public with sharing class CCExpiryUtility {
    public static void RenewCCs(List<Recurring_Donation__c> RDs) {
         List<Messaging.SingleEmailMessage> theMails = new List<Messaging.SingleEmailMessage>();                //Master list to hold emails that will be sent
         List<User> theUsers = [SELECT Id FROM User WHERE Receive_CC_Updates__c = True];             //List of users     
         givingpowerSettings__c CVTemplates = SFHelper.GetDefaultCVTemplates();
    
         //TODO: Wrap/Add logic that checks values in the Custom Settings object (causeview__App_Settings__c) and processes accordingly
         
         for (Recurring_Donation__c rd : RDs) {
            System.debug('#####  Recurring_Donation__c  #####'+rd);
            System.debug('#####  CVTemplates  #####'+CVTemplates);

            if (rd.Reference__c == null || rd.Reference__c == ''){ continue; }
            if (rd.Amount__c == 0 || rd.Amount__c == null) { continue; }
            if (rd.causeview__Status__c == 'Cancelled') { continue; }
            else{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setWhatId(rd.Id);   
                mail.setTargetObjectId(rd.Constituent__c);
                mail.setOrgWideEmailAddressId(CVTemplates.Org_Wide_Email_ID__c);
                if (rd.Credit_Card_Expiry_Date__c == Date.Today()+7) { 
                     for (User u : theUsers){
                         insert new Task (ActivityDate = Date.Today()+7, 
                                          OwnerId = u.Id, 
                                          Subject = 'Expired Credit Card for Shareplan', 
                                          WhatId = rd.Id, 
                                          Description = 'Donor has been sent an e-mail (or snail mail), and a reminder e-mail with no response. Please follow up with a phone call to obtain updated credit card information. Check Activity History of the Recurring Donation for details.',
                                          IsReminderSet = True,
                                          ReminderDateTime = DateTime.Now());
                     }
                 }          
                 if (CVTemplates != null){    
                    //Add email to list if CC expires in 15 Days   
                     if ((rd.Credit_Card_Expiry_Date__c == Date.Today()+15) && (CVTemplates.X15_DAYS_CC_Expiry_Email_Template__c != '')){ 
                        mail.setTemplateID(CVTemplates.X15_DAYS_CC_Expiry_Email_Template__c); theMails.add(mail); 
                     }
                     //Add email to list if CC expires in 30 Days
                     else if ((rd.Credit_Card_Expiry_Date__c == Date.Today()+30) && (CVTemplates.X30_DAYS_CC_Expiry_Email_Template__c != '')){ 
                        mail.setTemplateID(CVTemplates.X30_DAYS_CC_Expiry_Email_Template__c); theMails.add(mail); 
                     }                                                                  
                 }
             }
         }        
         Messaging.sendEmail(theMails,false);
     }
}