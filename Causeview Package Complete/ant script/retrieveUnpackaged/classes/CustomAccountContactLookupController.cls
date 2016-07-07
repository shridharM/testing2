public with sharing  class CustomAccountContactLookupController {
 
  //added by nitin
  public List<Account> accountLookupResult{get;set;} // search results for Account
  public List<Contact> contactLookupResults{get;set;}  
  public string searchString{get;set;} // search keyword

  public CustomAccountContactLookupController() {
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    system.debug('Nitin searchString===='+searchString);
    runsearchAccountContact();  
  }
 
  public CustomAccountContactLookupController(String strSearchString) {
    // get the current search string
    searchString = strSearchString;
    runsearchAccountContact();  
  }
  
  //added by nitin
  public PageReference searchAccountContact() {
    runsearchAccountContact();
    return null;
  }
 
  // prepare the query and issue the search command
  private void runsearchAccountContact() {
    // TODO prepare query string for complex serarches & prevent injections
    accountLookupResult = performAccountSearch(searchString);   
    contactLookupResults = performContactSearch(searchString);         
  } 
 
  // run the search and return the records found. 
  private List<Account> performAccountSearch(string searchString) {
     String[] searchStringArray;
    String soql = '';
    //String objName = System.currentPageReference().getParameters().get('objName');

    soql = 'select id, name, Organization_ID__c, AccountNumber, Email__c, Phone, BillingCity, ShippingCity, BillingState, BillingPostalCode from Account';
      if(searchString != '' && searchString != null){
          if(searchString.contains('\\')){
              searchString=searchString.replaceAll('\\\\', '\\\\\\\\');              
          }          
          if(searchString.contains('\'')){
              searchString=searchString.replaceAll('\'', '\\\\\'');              
          }
          soql = soql +  ' where Name LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or Organization_ID__c LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or Email__c LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or Phone LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or BillingCity LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or BillingStreet LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or ShippingCity LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or ShippingStreet LIKE \'%' + searchString +'%\'';
          
          soql = soql +  ' or BillingState LIKE \'%' + searchString +'%\'';
          soql = soql +  ' or BillingPostalCode LIKE \'%' + searchString +'%\'';
      }
      soql = soql + ' limit 50';

      System.debug(soql);
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
      
      return accountResultsTemp; 
      
  }
  
  // run the search and return the records found. 
  private List<Contact> performContactSearch(string searchString) {
     String[] searchStringArray;
    String soql = '';
    //String objName = System.currentPageReference().getParameters().get('objName');

    soql = 'select id, name, Constituent_ID__c, Email, AssistantName, LastName,FirstName , Phone, MailingCity , MailingState ,MailingPostalCode  from Contact';
    if(searchString != '' && searchString != null){
     if(searchString.contains('\\')){
              searchString=searchString.replaceAll('\\\\', '\\\\\\\\');              
            }          
          if(searchString.contains('\'')){
              searchString=searchString.replaceAll('\'', '\\\\\'');              
            }
      soql = soql +  ' where FirstName LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or LastName LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or FirstName LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or name LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or Constituent_ID__c LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or Email LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or Phone LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or MailingCity LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or MailingState LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or MailingPostalCode LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or MailingStreet LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or OtherCity LIKE \'%' + searchString +'%\'';
      soql = soql +  ' or OtherStreet LIKE \'%' + searchString +'%\'';
    }
      soql = soql + ' limit 50';

      System.debug(soql);     
      list<contact> contactResultsTemp = database.query(soql);
      for(contact conactTemp : contactResultsTemp){
          if(conactTemp.Name.contains('\'')){
              // if contact Name contains single quote or back slash then it will creates error in visual force page(customFundLookup). So to escape the meaning of single quote
              // or back slash we are appending back slash. As Conatct.Name is only readable we are using conactTemp.AssistantName field to just pass the value to page.
              // and its value will not be affected in database as we are not updating it.    
              conactTemp.AssistantName = conactTemp.Name;
              conactTemp.AssistantName = conactTemp.AssistantName.replaceAll('\\\\', '\\\\\\\\'); 
              conactTemp.AssistantName = conactTemp.AssistantName.replaceAll('\'', '\\\\\'');
              system.debug('=====conactTemp.AssistantName==='+conactTemp.AssistantName);
          }
          else{
              conactTemp.AssistantName = conactTemp.Name;
          }
              
      }
      return contactResultsTemp; 
  }
 //till here
  // save the new account record
  /*public PageReference save() {
    insert Fund;
    // reset the account
    Fund = new cv_pkg_dev_I__Fund__c();
    return null;
  }*/
 
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
 
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }  
  
 
}
