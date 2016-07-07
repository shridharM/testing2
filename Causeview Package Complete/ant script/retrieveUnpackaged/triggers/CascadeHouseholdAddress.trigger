trigger CascadeHouseholdAddress on Account (after update) {
    
    //only update if household recordtype and if Address, Phone, Salutation or Addressee has changed
    List<RecordType> rtypes = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'Account' AND isActive = true];
    Map<String,String> accountRecordTypes = new Map<String,String>{};
    for(RecordType rt: rtypes)
    { accountRecordTypes.put(rt.Name,rt.Id); }
    
    Set<Id> AIDs = new Set<Id>();
    List<Account> cOld = Trigger.old;
    List<Account> cNew = Trigger.new;    
    for (Integer i = 0; i < Trigger.old.size(); i++)
    {
        if (cOld[i].BillingStreet == cNew[i].BillingStreet && 
            cOld[i].BillingCity == cNew[i].BillingCity && 
            cOld[i].BillingPostalCode == cNew[i].BillingPostalCode && 
            cOld[i].BillingState == cNew[i].BillingState && 
            cOld[i].BillingCountry == cNew[i].BillingCountry &&
            cOld[i].Phone == cNew[i].Phone &&
            cOld[i].Household_Addressee__c == cNew[i].Household_Addressee__c &&
            cOld[i].Household_Salutation__c == cNew[i].Household_Salutation__c)
            { continue; }
        AIDS.add(cNew[i].Id);
    }    
            
    
    List<Contact> ContactSet = new List<Contact>();
    List<Account> theAccounts = [SELECT Id, BillingStreet, BillingState, BillingCountry, BillingPostalCode, BillingCity, Phone, Household_Addressee__c, Household_Salutation__c,
                                (SELECT Id, Use_Household_Salutation_Addressee__c, Same_as_Household__c, Primary_Addressee__c, Primary_Salutation__c, 
                                 HomePhone, MailingStreet, MailingState, MailingCountry, MailingPostalCode, MailingCity FROM HouseholdContacts__r) 
                                FROM Account WHERE Id IN :AIDS AND RecordTypeId = :accountRecordTypes.get('Household')];

    for(Account a : theAccounts)
    {
        for (Contact c : a.HouseholdContacts__r)
        {
            if (c.Use_Household_Salutation_Addressee__c == True)
            { 
                c.Primary_Addressee__c = a.Household_Addressee__c;  
                c.Primary_Salutation__c = a.Household_Salutation__c;
            }
            if (c.Same_as_Household__c == True)
            {  
                c.HomePhone = a.Phone;
                c.MailingStreet = a.BillingStreet;
                c.MailingState = a.BillingState;
                c.MailingCountry = a.BillingCountry;
                c.MailingPostalCode = a.BillingPostalCode;
                c.MailingCity = a.BillingCity;
            }
            ContactSet.add(c);
        }            
    }
    if (ContactSet.size() > 0)
        update ContactSet;
}