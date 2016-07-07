public with sharing class CustomContactLookupController {
    
    public causeview__Fund__c Fund {get;set;} // new causeview__Fund__c to create 
    public List<Contact> contactResults{get;set;} // search results for Contact
    public string searchString{get;set;} // search keyword
    //added by nitin
    public List<Account> accountLookupResult{get;set;} // search results for Account
    public List<Contact> contactLookupResults{get;set;}
    public List<Campaign> CampaignResults {get;set;}  
     public List<contactsWrapperClass> contactsWrapper{get;set;}
     public List<CampaignWrapperClass> CampaignWrapper{get;set;}
     
     public string objName{get;set;}
     public string nodeId{get;set;}     
      
    public CustomContactLookupController() {    
        // get the current search string
        //objName='contact';
        String objName  = System.currentPageReference().getParameters().get('objName');
        
        nodeId  = System.currentPageReference().getParameters().get('nodeId');
        
       
        if(objName=='Campaign'){
            objName='Campaign';
        }else
        {
         objName='contact';  
        }
         contactsWrapper = new List<contactsWrapperClass>();
         CampaignWrapper = new List<CampaignWrapperClass>();
        searchString = System.currentPageReference().getParameters().get('lksearch');
        
        system.debug('===searchString==='+searchString);
        system.debug('=====objectName-===='+objName);
        runSearch();  
    }
    
    public CustomContactLookupController(String strSearchString) {    
        // get the current search string
         objName='contact';
         contactsWrapper = new List<contactsWrapperClass>();
         CampaignWrapper = new List<CampaignWrapperClass>();
        searchString = strSearchString;
        runSearch();  
    }
    
    // performs the keyword search
    public PageReference search() {
        system.debug('======search');
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
     public void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        performSearch(searchString);               
    } 
    
    // run the search and return the records found. 
    public List<causeview__Fund__c> performSearch(string searchString) {
        
        String soql = '';   
        String objName = System.currentPageReference().getParameters().get('oName');
        system.debug('hii-----'+objName);
    
        String orgId = System.currentPageReference().getParameters().get('orgId');
        if(searchString != '' && searchString != null){
            if(searchString.contains('\\')){
                searchString=searchString.replaceAll('\\\\', '\\\\\\\\');              
            }          
            if(searchString.contains('\'')){
                searchString=searchString.replaceAll('\'', '\\\\\'');              
            }  
        }   
        
        //custom lookup appeal/event 
        
        if(objName == 'Campaign') {  
         List<RecordType> rts = [SELECT Id, Name FROM RecordType WHERE Name='Appeal' OR Name ='Event'];
        
              
        soql = 'SELECT Name,IsActive,ParentId,RecordTypeId,Type, Fund__c, Letter__c, Letter__r.Name, Fund__r.Name, Status FROM Campaign Where RecordTypeId IN :rts ';
        if(searchString != '' && searchString != null){
          soql = soql +  ' AND Name LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
          //soql = soql +  ' or Name__c LIKE \'%' + searchString +'%\'';
          //soql = soql +  ' or Description__c LIKE \'%' + searchString +'%\'';
        }
        soql = soql + ' limit 25';
        
        list<Campaign> CampaignResultsTemp = database.query(soql);
        
        for(Campaign CampaignTemp : CampaignResultsTemp){
            if(CampaignTemp.Name.contains('\'')){
                // if Letter__c.Name contains single quote or back slash then it will creates error in visual force page(customFundLookup). So to escape the meaning of single quote
                // or back slash we are appending back slash. As Letter__c.Name is only readable we are using letterTemp.causeview__Fund_Name__c field to just pass the value to page.
                // and its value will not be affected in database as we are not updating it.    
                  CampaignTemp.Name = CampaignTemp.Name;
                   CampaignTemp.Name  = CampaignTemp.Name.replaceAll('\\\\', '\\\\\\\\'); 
                   CampaignTemp.Name  = CampaignTemp.Name.replaceAll('\'', '\\\\\'');   
            }else{
                CampaignTemp.Name = CampaignTemp.Name;
            }
        }
        CampaignResults = CampaignResultsTemp;
        CampaignWrapper.clear();
        
        
        for(sobject c : CampaignResults){
        CampaignWrapper.add(new CampaignWrapperClass(c));
        }
        
    }

        if(objName == 'Contact') 
        {
        String[] orgIds = new String[]{orgId};
        // soql = 'select id, name, Constituent_ID__c, Email, Phone, MailingCity from Contact';
        soql = 'select id, name, Constituent_ID__c, AssistantName , Email, LastName,FirstName , Phone, MailingCity , MailingState ,MailingPostalCode  from Contact where AccountId in : orgIds';
        if(searchString != '' && searchString != null){      
            soql = soql +  ' and (FirstName LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
            soql = soql +  ' or LastName LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
            soql = soql +  ' or name LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or Constituent_ID__c LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or Email LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or Phone LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or MailingCity LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or MailingStreet LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or OtherCity LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or OtherStreet LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or MailingState LIKE \'%' + searchString +'%\'';
            soql = soql +  ' or MailingPostalCode LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\')';
        }
        soql = soql + ' limit 25';
        
        list<contact> contactResultsTemp = database.query(soql);
        for(contact conactTemp : contactResultsTemp){
            if(conactTemp.Name.contains('\'')){
                // if contact Name contains single quote or back slash then it will creates error in visual force page(customFundLookup). So to escape the meaning of single quote
                // or back slash we are appending back slash. As Conatct.Name is only readable we are using conactTemp.AssistantName field to just pass the value to page.
                // and its value will not be affected in database as we are not updating it.    
                conactTemp.AssistantName = conactTemp.Name;
                conactTemp.AssistantName = conactTemp.AssistantName.replaceAll('\\\\', '\\\\\\\\'); 
                conactTemp.AssistantName = conactTemp.AssistantName.replaceAll('\'', '\\\\\'');   
            }else{
                conactTemp.AssistantName = conactTemp.Name;
            }
        }
        
        contactResults=contactResultsTemp;
        contactsWrapper.clear();
        
        for(sobject c : contactResults){
        contactsWrapper.add(new contactsWrapperClass(c));
        }
        
        soql = 'select id, name, npe5__Contact__r.id, npe5__Contact__r.name, npe5__Contact__r.firstname, npe5__Contact__r.lastname, npe5__Description__c, npe5__Role__c from npe5__Affiliation__c where npe5__Organization__c in : orgIds';
        if(searchString != '' && searchString != null){
            soql = soql +  ' and (npe5__Contact__r.name LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';       
            soql = soql +  ' or npe5__Role__c LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\')';            
        }
        //soql = soql + ' limit 25';
        
        list<npe5__Affiliation__c> affiliationstResults = database.query(soql);
        for(npe5__Affiliation__c affTemp : affiliationstResults){
            if(affTemp.npe5__Contact__r.Name.contains('\'')){
                // if contact Name contains single quote or back slash then it will creates error in visual force page(customFundLookup). So to escape the meaning of single quote
                // or back slash we are appending back slash. As Conatct.Name is only readable we are using conactTemp.AssistantName field to just pass the value to page.
                // and its value will not be affected in database as we are not updating it.    
                affTemp.npe5__Role__c = affTemp.npe5__Contact__r.Name;
                affTemp.npe5__Role__c = affTemp.npe5__Role__c.replaceAll('\\\\', '\\\\\\\\'); 
                affTemp.npe5__Role__c = affTemp.npe5__Role__c.replaceAll('\'', '\\\\\'');   
            }else{
                affTemp.npe5__Role__c = affTemp.npe5__Contact__r.Name;
            }
        }
        for(sobject aff : affiliationstResults){
        contactsWrapper.add(new contactsWrapperClass(aff));
        }
        }
        return null;
       //}
    }
    
    // save the new account record
    public PageReference save() {
        insert Fund;
        // reset the account
        Fund = new causeview__Fund__c();
        return null;
    }
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    
     public class contactsWrapperClass{
        public contact contacts {get; set;}
        public npe5__Affiliation__c affiliations {get; set;}
        public contactsWrapperClass(sObject newObj){
        string obj =newObj.getSObjectType().getDescribe().getName();
        system.debug('=====soject type'+obj);  
        if(obj=='contact'){      
contacts = (contact)newObj;
        }else{
        affiliations=(npe5__Affiliation__c)newObj;
        }
        }
    } 
    
    public class CampaignWrapperClass {
     public campaign campaigns{get;set;}
     
        public CampaignWrapperClass(sObject newObj) {
        
        campaigns=(Campaign)newObj;
        }
    
    
    
    }
    
}