trigger MajorDonor on Gift__c (after update) {
    /*List<Account> accs = new List<Account>();
    List<Contact> cont = new List<Contact>();
    List<String> AIDs = new List<String>();
    List<String> CIDs = new List<String>();
    RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='cv_pkg_dev_I__Gift__c' AND Name = 'Gift'];
    
    for (Gift__c aGift : Trigger.new)
    {
        if (aGift.RecordTypeID != rt.Id)
            return;
        
        if (aGift.Total_Payment_Amount__c > 999)        
        {
            if(aGift.Constituent__c != null)
            { CIDs.add(aGift.Constituent__c); }
            if(aGift.Organization__c != null)
            { AIDs.add(aGift.Organization__c); }            
        }   
    }      
    
    cont = [SELECT Major_Gift_Donor__c FROM Contact WHERE Id IN :CIDs];
    accs = [SELECT Major_Donor__c FROM Account WHERE Id IN :AIDs];
    
    for (Contact c : cont)
    {
        c.Major_Gift_Donor__c = true;
    }   
    
    for (Account a : accs)
    {
        a.Major_Donor__c = true;
    }         
    
    update accs;
    update cont;*/
}