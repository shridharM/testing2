public with sharing class lookupController {

   public List<Contact> Contacts { get; set; }
   public List<Account> Accounts { get; set; }
   public string viewType { get; set; }
   public boolean hasRecords {
     get {
       if (Contacts != null && Contacts.size() > 0)
         return true;
       else if (Accounts != null && Accounts.size()>0)
         return true;
       else
        return false;
     }
   }
   
   public lookupController() {
    String component = ApexPages.currentPage().getParameters().get('component');
     viewType = ApexPages.currentPage().getParameters().get('type');
    if (component != null)
    { 
        searchValue = ApexPages.currentPage().getParameters().get(component + '_text');
        if (searchValue != null && searchValue != '')
           doSearch();
    }
   
   }
   
   public String searchValue { get; set; }
   public void doSearch()
   {
       if (viewType == 'Account')
         searchAccounts();
       else
         searchContacts();
   }
   
   private void searchContacts() { 
    string search = searchValue + '%';     
    
    Contacts = [SELECT id, name, Constituent_ID__c, MailingState, MailingStreet, MailingPostalCode, MailingCity, LastModifiedBy.Name, LastModifiedDate FROM Contact 
      WHERE (FirstName LIKE :search OR LastName LIKE :search OR Constituent_ID__c LIKE :search OR MailingPostalCode LIKE :search OR Name LIKE :search) ORDER BY name limit 100];
      
   }
   
   private void searchAccounts() {
    string search = searchValue + '%';
    Accounts = [SELECT id, name, Organization_ID__c, BillingPostalCode, BillingCity, LastModifiedBy.Name, LastModifiedDate FROM Account 
    WHERE (Name LIKE :search OR Organization_ID__c LIKE :search OR BillingPostalCode LIKE :search) ORDER BY name limit 100];
   }
   

  
   
}