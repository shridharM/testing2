public with sharing class leadConvertController {

    public Lead selectedRecord { get; set; }
    public string leadId { get; set; }
    public List<Contact> dupeContacts { get; set; }
    public List<Account> dupeAccounts { get; set; }    
    public boolean getDupes() { if (dupeContacts.size() > 0) { return true; } return false; }
    public boolean getAccDupes() { if (dupeAccounts.size() > 0) { return true; } return false; }    
    public boolean sendEmail { get; set; }
    public boolean noOpp { get; set; }    
    public boolean createAcc { get; set; }        
    public Contact newContact { get; set; }
    public Opportunity newOpp { get; set; }
    public String selectedCId { get; set; }
    public String selectedAId { get; set; }    
    public String templateId;
    public String orgWideId;
    public String bucketAccountId;
    public boolean isIndividual { get; set; }
    public Map<String, String> rt_map = new Map<String, String>();
    public Map<String, String> opp_rt_map = new Map<String, String>();    
    
    public leadConvertController(ApexPages.StandardController controller) {       
       selectedRecord = (Lead)controller.getRecord();       
       leadId = ApexPages.currentPage().getParameters().get('id');
       List<BatchSettings__c> settings = [Select b.BucketAccountId__c From BatchSettings__c b WHERE Name = 'Default'];        
       if (settings != null && settings.size() > 0)
       bucketAccountId = settings[0].BucketAccountId__c;
       List<RecordType> rts = [SELECT Id, Name FROM RecordType WHERE SobjectType='Lead' AND NamespacePrefix = 'causeview'];
       List<RecordType> rts2 = [SELECT Id, Name FROM RecordType WHERE SobjectType='Opportunity' AND NamespacePrefix = 'causeview'];       
       for (RecordType rt : rts)
       {
           rt_map.put(rt.Id, rt.Name);
       }
       for (RecordType rt : rts2)
       {
           opp_rt_map.put(rt.Name, rt.Id);
       }
       selectedRecord = [SELECT FirstName, LastName, OwnerId, Name, Company, RecordTypeId FROM Lead WHERE Id = :leadId];
       createAcc = True;
       isIndividual = False;
       if (selectedRecord.Company == 'Individual')
       { isIndividual = True; createAcc = False; } 
       List<List<SObject>> searchList = [FIND :selectedRecord.Company IN NAME FIELDS RETURNING Account (Id, Name, Phone, BillingStreet, OwnerId )];
       dupeAccounts = (List<Account>)searchList[0]; 
       List<List<SObject>> contactList = [FIND :selectedRecord.LastName IN NAME FIELDS RETURNING Contact (AccountId, FirstName, LastName, MailingStreet, Phone, Email, OwnerId )];
       dupeContacts = (List<Contact>)contactList[0]; 
       //dupeContacts = [SELECT AccountId, FirstName, LastName, MailingStreet, Phone, Email FROM Contact WHERE LastName = :selectedRecord.LastName ORDER BY FirstName];
       //dupeAccounts = [SELECT Name, Phone, BillingStreet FROM Account WHERE Name = :selectedRecord.Company];
       newContact = new Contact(OwnerId = UserInfo.getUserId());
       newOpp = new Opportunity(Name = selectedRecord.FirstName + ' ' + selectedRecord.LastName + '-' + rt_map.get(selectedRecord.RecordTypeId) + '-' + Date.Today().Year(), CloseDate = Date.Today().addDays(90));
       selectedCId = '-1';
       selectedAId = '-1';       
       List<givingpowerSettings__c> settingsRecords = [SELECT New_Lead_Template_Id__c, Org_Wide_Email_ID__c FROM givingpowerSettings__c WHERE Name = 'Settings'];
       if (settingsRecords != null && settingsRecords.size()>0)
       { templateId = settingsRecords[0].New_Lead_Template_Id__c; orgWideId = settingsRecords[0].Org_Wide_Email_ID__c; }
    }
    
    public PageReference convert() {
       Savepoint sp = Database.setSavepoint();
       Database.LeadConvert lc = new database.LeadConvert();
       lc.setLeadId(leadId);
       lc.setDoNotCreateOpportunity(true);
       
       try
       {
           if (selectedCId == '-1')
           {               
               lc.setOwnerId(newContact.OwnerId);
           }
           
           if (selectedAId != '-1' && isIndividual == False)
           {
               lc.setAccountId(selectedAId);
           }
           
           if (selectedAId == '-1' && isIndividual == True)
           {
               lc.setAccountId(bucketAccountId);
           }           
                      
           if (selectedCId != '-1')
           {
               newContact = [SELECT OwnerId, AccountId, Id FROM Contact WHERE Id = :selectedCId];
               if (newContact.AccountId != selectedAId && selectedAId != '-1')
               { newContact.AccountId = selectedAId; update newContact; }
               //lc.setAccountId(newContact.AccountId);
               lc.setContactId(newContact.Id);
           }          
           
           if (!noOpp)
           {
               lc.setDoNotCreateOpportunity(false);
               lc.setOpportunityName(newOpp.name);
           }
           
           if (sendEmail)
           {
               lc.setSendNotificationEmail(true);
           }
           
           LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = True LIMIT 1];
           lc.setConvertedStatus(convertStatus.MasterLabel);
           
           system.debug(lc);
           Database.LeadConvertResult lcr = Database.convertLead(lc);   
                     
           if (lcr.isSuccess())
           {
                newContact = [SELECT OwnerId,  Id FROM Contact WHERE Id = :lcr.getContactId()];
                if (!noOpp) {
                    Opportunity opp = [SELECT RecordTypeId FROM Opportunity WHERE Id = :lcr.getOpportunityId()];
                    opp.RecordTypeId = opp_rt_map.get((rt_map.get(selectedRecord.RecordTypeId)));
                    update opp;
                }
           }
                     
           PageReference pr = new ApexPages.StandardController(newContact).view();
           pr.setRedirect(true);            
           return pr;         
       }
       catch(Exception ex)
       {       
          Database.rollback(sp);
          ApexPages.addMessages(ex);
          return null;
       }
    }
}