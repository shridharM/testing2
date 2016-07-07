@isTest
private class testTriggs{

    @isTest static void test3() {
     Account a23 = new Account();
      a23.Name = 'Indiv';
      insert a23;
      
      Contact uc = new Contact();
      uc.LastName = 'ssss';
      insert uc;

      BatchSettings__c settings = new BatchSettings__c();
      settings.Name = 'Default';
      settings.Unknown_Guest_Id__c = uc.Id;
      settings.cv_pkg_dev_I__BatchFormID__c = 'sss';
      settings.cv_pkg_dev_I__BatchReportId__c = 'sss';
      settings.cv_pkg_dev_I__BucketAccountId__c = a23.Id;
      settings.cv_pkg_dev_I__CurrencyCode__c = 'sss';
      settings.cv_pkg_dev_I__GatewayUrl__c = 'sss';
      settings.cv_pkg_dev_I__RegularGiftRecordTypeId__c = 'sss';
      insert settings;
        cv_pkg_dev_I__aNums__c a2 = new cv_pkg_dev_I__aNums__c(Name = 'Default', cv_pkg_dev_I__ContactCount__c = 1, cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactPrefix__c = 'CON-', cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__OrgLength__c = 8,  cv_pkg_dev_I__OrgPrefix__c = 'ORG-');
        insert a2;
        cv_pkg_dev_I__FormSettings__c b = new cv_pkg_dev_I__FormSettings__c(Name = 'Default', cv_pkg_dev_I__Contact__c = 'NA', cv_pkg_dev_I__Donation__c = 'NA', cv_pkg_dev_I__RSVP__c = 'NA', cv_pkg_dev_I__RSVP_Free__c = 'NA');
        insert b;       
        //string groupId;
        //string groupParentId;
        Contact unknown = new Contact(LastName = 'Unknown');
        insert unknown;
        //User guest = [SELECT Id FROM User WHERE Alias = 'guest'];  
        List<RecordType > types = 
          [SELECT Id, Name 
             FROM RecordType 
            WHERE SObjectType = 'Volunteer_Application__c' AND NamespacePrefix = 'causeview']; 
        for (RecordType rt : types)
        {
        //  if (rt.Name == 'Group Application') groupId = rt.Id;
        //  if (rt.Name == 'Parent Group Application') groupParentId = rt.Id;
        }      
 
        Account a = new Account(Name = 'sss');
        insert a;    
        Contact c = new Contact(AccountId = a.Id, LastName = 'Test', FirstName = 'Test', Email = 'email@email.com');
        insert c;    
       // Program__c p = new Program__c(Name = 'TestProg');
       // insert p;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Name = 'afas');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved', Training_Provided__c = 'Program Specific Training');
        insert vpd;
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;    
        Volunteer_Application__c app = new Volunteer_Application__c(Volunteer__c = c.Id, Volunteer_Role__c = vp.Id, Status__c = 'Placed');
        insert app;
        Volunteer_Hours__c hour = new Volunteer_Hours__c(Volunteer_Shift__c = shift.Id, Volunteer__c = c.Id);
        insert hour;
    }
    
   
     @isTest static void updateVolunteeerStatus() {
     
        Account a = new Account(Name = 'sss');
        insert a;    
        
        Contact c = new Contact(AccountId = a.Id, LastName = 'Test', FirstName = 'Test', Email = 'email@email.com',Volunteer_Status__c = 'Active');
        insert c;  
        
         Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved', Training_Provided__c = 'Program Specific Training');
        insert vpd;
        
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Name = 'afas');
        insert vopp; 
        
         Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        
         Volunteer_Application__c app = new Volunteer_Application__c(Volunteer__c = c.Id, Volunteer_Role__c = vp.Id, Status__c = 'Placed');
        insert app;
        
         Volunteer_Application__c app1 = new Volunteer_Application__c(Volunteer__c = c.Id, Volunteer_Role__c = vp.Id, Status__c = 'Submitted / In-Screening');
        insert app1; 
        
        app1.Status__c = 'Screening Complete';
        update app1;
        
        app.Program_Specific_Training_Status__c = 'Completed';
        update app;
        
        c.Volunteer_Status__c = 'InActive';
        update c;
        
         app1.Status__c = 'Placed';
         app1.Program_Specific_Training_Status__c = 'To Be Done';
        update app1;
        
    }
    
    
}