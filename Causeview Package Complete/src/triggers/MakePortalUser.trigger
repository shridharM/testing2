trigger MakePortalUser on Volunteer_Application__c (after update) {
/*    List<Volunteer_Application__c> oldApps = Trigger.old;
    List<Volunteer_Application__c> newApps = Trigger.new;    
    Map<String, User> con_to_user = new Map<String, User>();
    
    Set<String> ContactIds = new Set<String>();
    Set<String> AccIds = new Set<String>();    
    for (Integer i = 0; i < oldApps.size(); i++)
    {
        if (oldApps[i].Status__c != 'Placed' && newApps[i].Status__c == 'Placed' && (newApps[i].RecordTypeId == '012d0000000siPV' || newApps[i].RecordTypeId == '012d0000000siPW'))
        { ContactIds.add(newApps[i].Volunteer__c); }
    }
    
    List<Contact> contacts = [SELECT AccountId, Id, Email, LastName, FirstName FROM Contact WHERE Id IN:ContactIds];
    List<User> users = [SELECT Id, Email, ContactId  FROM User WHERE ContactId IN :ContactIds];
    for (User u : users)
    {
        for (Contact c1 : contacts)
        {
            if (u.ContactId == c1.Id)
            { con_to_user.put(c1.Id, u); }
        }
    }
    List<User> usersToInsert = new List<User>();    
    Double Rnd =  Math.random();
    
    for(Contact c : contacts)
    {
        if (con_to_user.containsKey(c.Id)) { continue; }

        AccIds.add(c.AccountId);

        User u2 = new User(contactId=c.Id, 
                           username=c.FirstName+c.LastName+'@ccaz.org', 
                           firstname=c.FirstName,
                           lastname=c.LastName, 
                           email=c.Email,
                           communityNickname = c.LastName + '_' + Rnd,
                           alias = string.valueof(c.FirstName.substring(0,1) + c.LastName.substring(0,1)), 
                           profileid = '00ed0000000GjrO', 
                           emailencodingkey='UTF-8',
                           languagelocalekey='en_US', 
                           localesidkey='en_US', 
                           timezonesidkey='America/Los_Angeles');
        usersToInsert.add(u2);                           
    }   

    List<Account> accs = [SELECT Id, OwnerId FROM Account WHERE Id IN :AccIds];
    for (Account a : accs)
    {
        a.OwnerId = '005d0000000yhGS';
    }
    
    update accs;

    if (usersToInsert.size() > 0)
    {
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        List<Database.saveresult> sr = Database.insert(usersToInsert, dlo);
        System.debug(sr);
        //if (!sr.isSuccess) { insert new Task(ActivityDate = Date.Today().addDays(14), 
        //                                     Description = 'Perform Reference Checks and conduct face-to-face interview',
        //                                     OwnerId = newAppsFull[i].Volunteer_Position__r.Program_Volunteer_Liason__c,
        //                                     Status = 'In Progress',
        //                                     Subject = 'Perform Reference Checks and conduct face-to-face interview',
        //                                     WhatId = newAppsFull[i].Id,
        //                                     WhoId = newAppsFull[i].Volunteer__c));
    }
*/
}