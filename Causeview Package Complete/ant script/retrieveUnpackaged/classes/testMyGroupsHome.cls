@isTest
private class testMyGroupsHome{

    static void createAutoNums() {
        cv_pkg_dev_I__aNums__c a = new cv_pkg_dev_I__aNums__c(Name = 'Default', cv_pkg_dev_I__ContactCount__c = 1, cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactPrefix__c = 'CON-', cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__OrgLength__c = 8,  cv_pkg_dev_I__OrgPrefix__c = 'ORG-');
        insert a;
        cv_pkg_dev_I__FormSettings__c b = new cv_pkg_dev_I__FormSettings__c(Name = 'Default', cv_pkg_dev_I__Contact__c = 'NA', cv_pkg_dev_I__Donation__c = 'NA', cv_pkg_dev_I__RSVP__c = 'NA', cv_pkg_dev_I__RSVP_Free__c = 'NA');
        insert b;
    }    

    static void createPortalSettings() {
        string groupId;
        string groupParentId;
        Contact unknown = new Contact(LastName = 'Unknown');
        insert unknown;
        //User guest = [SELECT Id FROM User WHERE Alias = 'guest'];  
        List<RecordType > types = 
          [SELECT Id, Name 
             FROM RecordType 
            WHERE SObjectType = 'Volunteer_Application__c' AND NamespacePrefix = 'causeview']; 
        for (RecordType rt : types)
        {
          if (rt.Name == 'Group Application') groupId = rt.Id;
          if (rt.Name == 'Parent Group Application') groupParentId = rt.Id;
        }      
    }    
    
    @isTest static void test3() {
        createAutoNums();
        createPortalSettings();  
        String groupId;
        String groupParentId;
        List<RecordType > types = 
          [SELECT Id, Name 
             FROM RecordType 
            WHERE SObjectType = 'Volunteer_Application__c' AND NamespacePrefix = 'causeview']; 
        for (RecordType rt : types)
        {
          if (rt.Name == 'Group Application') groupId = rt.Id;
          if (rt.Name == 'Parent Group Application') groupParentId = rt.Id;
        }              
        Account a = new Account(Name = 'sss');
        insert a;    
        Contact c = new Contact(AccountId = a.Id, LastName = 'Test', FirstName = 'Test', Email = 'email@email.com');
        insert c;
        /*Profile pr = [SELECT Id FROM Profile WHERE Name=:'High Volume Clone'];
        User u2 = new User(contactId=c.Id, 
                           username=c.Email, 
                           firstname=c.FirstName,
                           lastname=c.LastName, 
                           email=c.Email,
                           communityNickname = c.LastName,
                           alias = string.valueof(c.FirstName.substring(0,1) + c.LastName.substring(0,1)), 
                           profileid = pr.id, 
                           emailencodingkey='UTF-8',
                           languagelocalekey='en_US', 
                           localesidkey='en_US', 
                           timezonesidkey='America/Los_Angeles');
        insert u2;      */
        /*Program__c p = new Program__c(Name = 'TestProg');
        insert p;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Program__c = p.Id, Name = 'afas', Opportunity_Name__c = 'TestOpp');
        insert vopp;
        Volunteer_Position_Description__c vpd = new Volunteer_Position_Description__c(Status__c = 'Approved', Training_Provided__c = 'Program Specific Training');
        insert vpd;
        Volunteer_Positions__c vp = new Volunteer_Positions__c(Volunteer_Opportunity__c = vopp.Id, Volunteer_Position_Description__c = vpd.Id, Position_Name__c = 'testpos', Name = 'pos');
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Position__c = vp.Id, Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;   
        Volunteer_Hours__c vh = new Volunteer_Hours__c(Volunteer_Shift__c = shift.Id, Volunteer__c = c.Id);                 
        insert vh;
        //Volunteer_Application__c app = new Volunteer_Application__c(Volunteer__c = c.Id, Volunteer_Position__c = vp.Id, Status__c = 'Placed', Date_of_Background_Check__c = Date.Today(), Date_of_Fingerprint_Check__c = Date.Today(), Date_of_Reference_Check__c = Date.Today());
        //insert app;
        Volunteer_Application__c parent = new Volunteer_Application__c(Volunteer__c = c.Id, RecordTypeId = groupParentId, Status__c = 'Placed');
        insert parent;        
        Contact c3 = new Contact(AccountId = a.Id, LastName = 'Test', FirstName = 'Test', Email = 'email@email.com');
        insert c3;        
        Volunteer_Application__c child = new Volunteer_Application__c(Volunteer__c = c3.Id, Parent_Volunteer_Application__c = parent.Id, Volunteer_Position__c = vp.Id);
        insert child;                    
        System.runAs(u2)
        { 
            MyGroupsHomeController controller = new MyGroupsHomeController();  
            //controller.getPickLstValue();
            /*controller.getHours();
            controller.getMins();
            controller.getMeridiemOffset();   
            controller.logTime();   */ 
        //}
    } 
}