public with sharing class CustomFundLookupController {
 
  public causeview__Fund__c Fund {get;set;} // new causeview__Fund__c to create
  public List<causeview__Fund__c> results{get;set;} // search results
  public List<causeview__Letter__c> letterResults{get;set;} // search results for letter
  public List<Account> accountResults{get;set;} // search results for Account
  public List<Contact> contactResults{get;set;} // search results for Contact
  public string searchString{get;set;} // search keyword
  //added by nitin
  public List<Account> accountLookupResult{get;set;} // search results for Account
  public List<Contact> contactLookupResults{get;set;}  
  
   Map<String, String> rtypes_Map = new Map<String, String>();
  
  RecordType r = [Select Name, Id From RecordType where Name = 'Household' AND NamespacePrefix = 'causeview'];
  {
            rtypes_Map.put(r.name, r.id);
        }
  
  public CustomFundLookupController() {
    Fund = new causeview__Fund__c();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    
    runSearch();  
  }
 
  public CustomFundLookupController(String strSearchString) {
    Fund = new causeview__Fund__c();
    // get the current search string
    searchString = strSearchString;
    runSearch();  
  }
 
  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }
 
  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);               
  } 
 
  // run the search and return the records found. 
  private List<causeview__Fund__c> performSearch(string searchString) {

    String soql = '';
    String objName = System.currentPageReference().getParameters().get('objName');
    
      if(searchString != '' && searchString != null){
          if(searchString.contains('\\')){
              searchString=searchString.replaceAll('\\\\', '\\\\\\\\');              
          }          
          if(searchString.contains('\'')){
              searchString=searchString.replaceAll('\'', '\\\\\'');              
          }  
      }
    //If Letter
    if(objName == 'Letter') {        
        soql = 'select id, name, causeview__Fund_Name__c, Description__c, Name__c from Letter__c';
        if(searchString != '' && searchString != null){
          soql = soql +  ' where Name LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
          soql = soql +  ' or Name__c LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
          soql = soql +  ' or Description__c LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
        }
        soql = soql + ' limit 25';
        
        list<Letter__c> letterResultsTemp = database.query(soql);
        
        for(Letter__c letterTemp : letterResultsTemp){
            if(letterTemp.Name.contains('\'')){
                // if Letter__c.Name contains single quote or back slash then it will creates error in visual force page(customFundLookup). So to escape the meaning of single quote
                // or back slash we are appending back slash. As Letter__c.Name is only readable we are using letterTemp.causeview__Fund_Name__c field to just pass the value to page.
                // and its value will not be affected in database as we are not updating it.    
                letterTemp.causeview__Fund_Name__c = letterTemp.Name;
                letterTemp.causeview__Fund_Name__c = letterTemp.causeview__Fund_Name__c.replaceAll('\\\\', '\\\\\\\\'); 
                letterTemp.causeview__Fund_Name__c = letterTemp.causeview__Fund_Name__c.replaceAll('\'', '\\\\\'');   
            }else{
                letterTemp.causeview__Fund_Name__c = letterTemp.Name;
            }
        }
        letterResults = letterResultsTemp;
        return null;
    }

    if(objName == 'Account') {
        String recordid = rtypes_Map.get('Household') ;
        System.debug('Recird Type id---' +recordid );
        //soql = 'select id, name, Organization_ID__c, Email__c, Phone, BillingCity, ShippingCity from Account';
        soql='select id, name, AccountNumber, Organization_ID__c, Email__c, Phone, BillingCity, ShippingCity, BillingState, BillingStreet, BillingPostalCode , RecordTypeId from Account where (RecordTypeId != :recordid) ';
        if(searchString != '' && searchString != null){            
          soql = soql + 'AND' + '('+ 'Name LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
          soql = soql +  ' or Organization_ID__c LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
          soql = soql +  ' or Email__c LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or  Phone LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or BillingCity LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or BillingStreet LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or ShippingCity LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or ShippingStreet LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or BillingState LIKE \'%' + searchString +'%\'';
          //soql = soql +  ' or BillingStreet LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or BillingPostalCode LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'' + ')';
        }
        soql = soql + ' limit 25';
        system.debug(soql);
        list<account> accountResultsTemp = database.query(soql);
        
        for(account accountTemp : accountResultsTemp){
            if(accountTemp.Name.contains('\'')){
                // if account Name contains single quote or back slash then it will creates error in visual force page(customFundLookup). So to escape the meaning of single quote
                // or back slash we are appending back slash. As account.Name is only readable we are using accountTemp.AccountNumber field to just pass the value to page.
                // and its value will not be affected in database as we are not updating it.    
                accountTemp.AccountNumber  = accountTemp.Name;
                accountTemp.AccountNumber = accountTemp.AccountNumber.replaceAll('\\\\', '\\\\\\\\'); 
                accountTemp.AccountNumber = accountTemp.AccountNumber.replaceAll('\'', '\\\\\'');   
            }
            else{
                accountTemp.AccountNumber  = accountTemp.Name;
            }
        }
        accountResults = accountResultsTemp;
        return null;
    }

    if(objName == 'Contact') {
       // soql = 'select id, name, Constituent_ID__c, Email, Phone, MailingCity from Contact';
          soql = 'select id, name, Constituent_ID__c, AssistantName , Email, LastName,FirstName , Phone, MailingCity , MailingState , MailingStreet , MailingPostalCode  from Contact';
        if(searchString != '' && searchString != null){       
          soql = soql +  ' where FirstName LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
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
          
          soql = soql +  ' or MailingPostalCode LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
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
        return null;
    }

    soql = 'select id, name, causeview__Fund_Name__c, causeview__Notes__c, causeview__Fund_Code__c from causeview__Fund__c';
    if(searchString != '' && searchString != null){
      soql = soql +  ' where Name LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
      soql = soql +  ' or causeview__Fund_Name__c LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
      //added by nitin to search for fund code field
      soql = soql +  ' or causeview__Fund_Code__c LIKE \'%' + string.escapeSingleQuotes(searchString) +'%\'';
    }
    soql = soql + ' limit 25';
    System.debug(soql);
    return database.query(soql); 
 
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
 
}