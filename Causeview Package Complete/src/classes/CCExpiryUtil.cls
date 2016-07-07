public with sharing class CCExpiryUtil {
     public static void RenewCCs(List<Recurring_Donation__c> RDs) {
         List<Messaging.SingleEmailMessage> theMails = new List<Messaging.SingleEmailMessage>();
         List<User> theUsers = [SELECT Id FROM User WHERE Receive_CC_Updates__c = True];       
         givingpowerSettings__c CVTemplates = SFHelper.GetDefaultCVTemplates();
         //TODO: Custom Settings
         
         for (Recurring_Donation__c rd : RDs)
         {
System.debug('#####  Recurring_Donation__c  #####'+rd);
System.debug('#####  CVTemplates  #####'+CVTemplates);

             if (rd.Reference__c == null || rd.Reference__c == '')
             { continue; }
             if (rd.Amount__c == 0 || rd.Amount__c == null) 
             { continue; }
             if (rd.causeview__Status__c == 'Cancelled') 
             { continue; }
             else
             {
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 mail.setWhatId(rd.Id);   
                 mail.setTargetObjectId(rd.Constituent__c);
                 mail.setOrgWideEmailAddressId(CVTemplates.Org_Wide_Email_ID__c);
                 if (rd.Credit_Card_Expiry_Date__c == Date.Today()+7)
                 { 
                     for (User u : theUsers)
                     {
                         insert new Task (ActivityDate = Date.Today()+7, 
                                          OwnerId = u.Id, 
                                          Subject = 'Expired Credit Card for Shareplan', 
                                          WhatId = rd.Id, 
                                          Description = 'Donor has been sent an e-mail (or snail mail), and a reminder e-mail with no response. Please follow up with a phone call to obtain updated credit card information. Check Activity History of the Recurring Donation for details.',
                                          IsReminderSet = True,
                                          ReminderDateTime = DateTime.Now());
                     }
                 }          
                 if (CVTemplates != null)
                 {       
                     if ((rd.Credit_Card_Expiry_Date__c == Date.Today()+15) && (CVTemplates.X15_DAYS_CC_Expiry_Email_Template__c != ''))
                     { 
                        mail.setTemplateID(CVTemplates.X15_DAYS_CC_Expiry_Email_Template__c); theMails.add(mail); 
                     }
                     else if ((rd.Credit_Card_Expiry_Date__c == Date.Today()+30) && (CVTemplates.X30_DAYS_CC_Expiry_Email_Template__c != ''))
                     { 
                        mail.setTemplateID(CVTemplates.X30_DAYS_CC_Expiry_Email_Template__c); theMails.add(mail); 
                     }                                                                  
                 }
             }
         }        
         Messaging.sendEmail(theMails,false);
     }
     
    static testMethod void testMe()
    {
        Contact c = new Contact(LastName = 'sdsd');
        insert c;
        Recurring_Donation__c rd1 = new Recurring_Donation__c(Amount__c = 25, Start_Date__c = Date.Today(), Reference__c = 'sdsd', Constituent__c = c.Id, Credit_Card_Expiry_Date__c = Date.Today()+30);
        insert rd1;
        RD_Allocation__c rda1 = new RD_Allocation__c(Recurring_Gift__c = rd1.Id, Amount__c = 25);
        insert rda1;
        Recurring_Donation__c rd2 = new Recurring_Donation__c(Amount__c = 25, Start_Date__c = Date.Today(), Reference__c = 'sdsd', Constituent__c = c.Id, Credit_Card_Expiry_Date__c = Date.Today()+15);
        insert rd2;
        RD_Allocation__c rda2 = new RD_Allocation__c(Recurring_Gift__c = rd2.Id, Amount__c = 25);
        insert rda2;
        Recurring_Donation__c rd3 = new Recurring_Donation__c(Amount__c = 25, Start_Date__c = Date.Today(), Reference__c = 'sdsd', Constituent__c = c.Id, Credit_Card_Expiry_Date__c = Date.Today()+7);
        insert rd3;
        RD_Allocation__c rda3 = new RD_Allocation__c(Recurring_Gift__c = rd3.Id, Amount__c = 25);
        insert rda3;  
        Set<Id>RDIDS = new Set<Id>();
        RDIDS.add(rd1.id);
        RDIDS.add(rd2.id);        
        RDIDS.add(rd3.id);        
        List<Recurring_Donation__c> rds = [SELECT r.Id, r.Constituent__c, r.Credit_Card_Expiry_Date__c, r.causeview__Status__c, r.Amount__c, r.Reference__c, r.URL_Safe_Key__c FROM Recurring_Donation__c r WHERE r.Id IN :RDIDS];      
        
        System.Schedule('Test', '0 0 0 3 9 ? 2022', new CCExpiryScheduler());
        CCExpiryUtil.RenewCCs(rds);
        Database.executeBatch(new CCExpiryBatch(), 5); 
    }
    static testMethod void testMe2()
    {     
        Test.startTest();
        string jobId = System.Schedule('Test', '0 0 0 3 9 ? 2022', new CCExpiryScheduler());   
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00',
        String.valueOf(ct.NextFireTime));
        Test.stopTest();
        //System.assertNotEquals('testScheduledApexFromTestMethodUpdated', [SELECT id, name FROM account WHERE id = :a.id].name);
    }
}