public with sharing class ReceiptPrinter {

    public Receipt__c receipt { get; set; }

    public PageReference rerender() {
        if (receipt.Constituent__c == null)        
        { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Constituent Lookup on Receipt, cannot Email receipt.')); }
        return null;
    }

    public Boolean format { get; set; }
    public Boolean isDupe { get; set; }
    //For Consolidated Receipt
    public Boolean isConsolidatedReceipt { get; set; }
    
    public String giftRecordType  { get; set; } 
    public String emailSubject  { get; set; } 
    public String templateId  { get; set; }    
    public String dupeTemplateId  { get; set; }        
    public String orgWideId { get; set; }  
    public RecordType rt { get; set; }  

    public PageReference print() {
        if (format == true)
        {
            try
            {
                
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if (isDupe == True)
                {   /*if(emailSubject != null)
                        {   EmailTemplate dupeTemplate = [SELECT Id, Subject FROM EmailTemplate where Id =: dupeTemplateId ];
                            dupeTemplate.subject = emailSubject;
                            update dupeTemplate;
                            
                        }*/
                        
                    mail.setTemplateID(dupeTemplateId); 
                }
                else
                { 
                    /*if(emailSubject != null)
                        {
                            EmailTemplate nTemplate = [SELECT Id, Subject FROM EmailTemplate where Id =: templateId ];
                            nTemplate.subject = emailSubject;
                            update nTemplate;
                        }*/
                    mail.setTemplateID(templateId);
                  }
                mail.setWhatId(receipt.Id);
               //mail.setSubject(receipt.Email_subject__c);
                mail.setTargetObjectId(receipt.Constituent__c);
                mail.setOrgWideEmailAddressId(orgWideId);
                mail.setSaveAsActivity(False);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                if (isDupe == False)
                { insert new Task(Subject = 'Receipt Emailed', Status = 'Completed', WhatId = receipt.Id, ActivityDate = Date.Today(), WhoId = receipt.Constituent__c, Type = 'Automated Email'); }            
                if (isDupe == True)
                { insert new Task(Subject = 'Duplicate Receipt Emailed', Status = 'Completed', WhatId = receipt.Id, ActivityDate = Date.Today(), WhoId = receipt.Constituent__c, Type = 'Automated Email'); }                 
                if (isDupe == False)
                { receipt.RecordTypeId = rt.Id; receipt.Date_Issued__c = Date.Today(); receipt.Status__c = 'Issued'; update receipt; }                                
                PageReference pgRef = new PageReference('/' + receipt.Id);
                pgRef.setRedirect(true);
                return pgRef;
            }
            catch (Exception ex)
            {
                ApexPages.addMessages(ex);
                return null;
            }
        }
        else
        {
            if (isDupe == False)
            { insert new Task(Subject = 'Receipt Exported for Mailing or Printing', Status = 'Completed', WhatId = receipt.Id, ActivityDate = Date.Today(), WhoId = receipt.Constituent__c, Type = 'Automated Email'); }            
            if (isDupe == True)
            { insert new Task(Subject = 'Duplicate Receipt Exported for Mailing or Printing', Status = 'Completed', WhatId = receipt.Id, ActivityDate = Date.Today(), WhoId = receipt.Constituent__c, Type = 'Automated Email'); } 
            if (isDupe == False)
            { receipt.RecordTypeId = rt.Id; receipt.Date_Issued__c = Date.Today(); receipt.Status__c = 'Issued'; update receipt; }                          
            PageReference pgRef = new PageReference('/' + receipt.Id);
            pgRef.setRedirect(true);
            return pgRef;                             
        }
    }

    public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('True','Send E-mail'));
    options.add(new SelectOption('False','Save and Print'));
    return options;
    }
    
    public ReceiptPrinter(ApexPages.StandardController controller) {
        List<givingpowerSettings__c> settingsRecords = [SELECT ConsolidatedReceiptEmailTemplateId__c, Event_Registration_Email_Template_ID__c, Dupe_Event_Registration_Template_ID__c, DupeConsolidatedReceiptEmailTempId__c, DupeEmailTemplateId__c, Org_Wide_Email_ID__c, EmailTemplateId__c FROM givingpowerSettings__c WHERE Name = 'Settings'];
        rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'cv_pkg_dev_I__Receipt__c' AND Name = 'Issued' LIMIT 1];
        receipt = [SELECT Status__c, Date_Issued__c, Constituent__c, Id, Print_Date__c, Receipt_Email_Address__c, Receipt_Type__c, Gift__r.RecordTypeId,email_subject__c FROM Receipt__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        
        system.debug('-----------Gift__r.RecordTypeId -----'+receipt.Gift__r.RecordTypeId );
        isDupe = false;
        
        giftRecordType = [SELECT Name FROM RecordType WHERE Id =: receipt.Gift__r.RecordTypeId  LIMIT 1].name;

        
        if(receipt.Date_Issued__c != null)
        { isDupe = true; }

        
                if(receipt.Email_subject__c != null)
                    emailSubject =  receipt.Email_subject__c;
                    
        //Check if Receipt is Consolidated.
        isConsolidatedReceipt = false;
        if(receipt.Receipt_Type__c == 'Consolidated')
        { isConsolidatedReceipt = true; }

        if (settingsRecords != null && settingsRecords.size()>0)
        {
            if(isConsolidatedReceipt)
            {  dupeTemplateId = settingsRecords[0].DupeConsolidatedReceiptEmailTempId__c;  templateId = settingsRecords[0].ConsolidatedReceiptEmailTemplateId__c; 
                system.debug('Nitin dupeTemplateId===='+dupeTemplateId);
                system.debug('Nitin templateId===='+templateId);
            }
            else if(giftRecordType == 'Event Registration')
             {  dupeTemplateId = settingsRecords[0].Dupe_Event_Registration_Template_ID__c;  templateId = settingsRecords[0].Event_Registration_Email_Template_ID__c; }
            else
            { dupeTemplateId = settingsRecords[0].DupeEmailTemplateId__c;  templateId = settingsRecords[0].EmailTemplateId__c; 
              system.debug('Nitin dupeTemplateId===='+dupeTemplateId);
                system.debug('Nitin templateId===='+templateId);
            }
            orgWideId = settingsRecords[0].Org_Wide_Email_ID__c;
        }
    }
    
    public ReceiptPrinter() {
        List<givingpowerSettings__c> settingsRecords = [SELECT ConsolidatedReceiptEmailTemplateId__c, DupeConsolidatedReceiptEmailTempId__c,Event_Registration_Email_Template_ID__c, Dupe_Event_Registration_Template_ID__c, DupeEmailTemplateId__c, Org_Wide_Email_ID__c, EmailTemplateId__c FROM givingpowerSettings__c WHERE Name = 'Settings'];
        rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'cv_pkg_dev_I__Receipt__c' AND Name = 'Issued' LIMIT 1];
        receipt = [SELECT Status__c, Date_Issued__c, Constituent__c, Id, Print_Date__c, Receipt_Email_Address__c, Receipt_Type__c, Gift__r.RecordTypeId, email_subject__c FROM Receipt__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        isDupe = false;
        
                system.debug('-----------Gift__r.RecordTypeId in () -----'+receipt.Gift__r.RecordTypeId );
        
        
        if(receipt.Date_Issued__c != null)
        { isDupe = true; }

         giftRecordType = [SELECT Name FROM RecordType WHERE Id =: receipt.Gift__r.RecordTypeId  LIMIT 1].name;
          
         
                if(receipt.Email_subject__c != null)
                    emailSubject =  receipt.Email_subject__c; 
          
        //Check if Receipt is Consolidated.
        isConsolidatedReceipt = false;
        if(receipt.Receipt_Type__c == 'Consolidated')
        { isConsolidatedReceipt = true; }

        if (settingsRecords != null && settingsRecords.size()>0)
        {
            if(isConsolidatedReceipt)
            {  dupeTemplateId = settingsRecords[0].DupeConsolidatedReceiptEmailTempId__c;  templateId = settingsRecords[0].ConsolidatedReceiptEmailTemplateId__c; 
                system.debug('Nitin dupeTemplateId===='+dupeTemplateId);
                system.debug('Nitin templateId===='+templateId);
            }
             else if(giftRecordType == 'Event Registration')
             {  dupeTemplateId = settingsRecords[0].Dupe_Event_Registration_Template_ID__c;  templateId = settingsRecords[0].Event_Registration_Email_Template_ID__c; }
           
            else 
            { dupeTemplateId = settingsRecords[0].DupeEmailTemplateId__c;  templateId = settingsRecords[0].EmailTemplateId__c; 
                system.debug('Nitin dupeTemplateId===='+dupeTemplateId);
                system.debug('Nitin templateId===='+templateId);
            }
            orgWideId = settingsRecords[0].Org_Wide_Email_ID__c;
        }
        
         
        
        
    }
    
    
    
    
}