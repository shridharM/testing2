@isTest
private class TestAppealRollup {
    static testMethod void Test() {
        
         Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
         cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;        
        
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;

        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;       
                        
        Campaign a_p = new Campaign(Name = 'asdads');
        insert a_p;
        Campaign a_c = new Campaign(Name = 'adsd', ParentId = a_p.Id);
        insert a_c;    
               
        
        Expense__c e = new Expense__c(New_Campaign__c = a_c.Id, Amount__c = 100);
        insert e;
      
        Event_Registration__c er = new Event_Registration__c(cv_pkg_dev_I__Event__c = a_c.Id, cv_pkg_dev_I__Individual__c = c.Id, cv_pkg_dev_I__Registration_Date__c = Date.Today(), cv_pkg_dev_I__Status__c = 'Attended');
        insert er;
        
        Gift__c g1 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g1.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_c.Id, Amount__c = 100);
        insert gd1;
    
        
        Test.startTest();        
        AppealRollupBatch arb = new AppealRollupBatch();
        arb.query = 'Select a.Id From Campaign a WHERE Parent.Parent.RecordTypeId = \'012C0000000LyDL\' LIMIT 1';
        Database.executeBatch(arb,1);
        Test.stopTest();        
    } 
    
        static testMethod void Test2() {
        
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
         cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;        
        
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;        

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;        
        
        Campaign a_p = new Campaign(Name = 'asdads');
        insert a_p;
        Campaign a_c = new Campaign(Name = 'adsd', ParentId = a_p.Id, Overall_Gift_Amount__c=0,  Overall_One_Time_Gift_Count__c=0,  Overall_Recurring_Gift_Count__c=0,  Overall_Gifts_for_Current_Fiscal__c=0,  Overall_Gifts_for_Current_Quarter__c=0,  Gifts_for_Current_Quarter__c=0);
        insert a_c;
        
        Gift__c g1 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g1.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_p.Id, Amount__c = 100);
        insert gd1;
        
        Gift__c g2 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'Shareplan', Gift_Date__c = Date.Today());
        insert g2;
        Payment__c p2 = new Payment__c(Donation__c = g2.Id, Amount__c = 100, Status__c = 'Approved');
        insert p2;
        Gift_Detail__c gd2 = new Gift_Detail__c(Payment__c = p2.Id, Gift__c = g2.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_p.Id, Amount__c = 100);
        insert gd2;
    
        
        Test.startTest();        
        AppealRollupBatch arb = new AppealRollupBatch();
        arb.query = 'Select a.Id From Campaign a WHERE Id = \'' + a_p.Id + '\' LIMIT 1';
        Database.executeBatch(arb, 1);  
        Test.stopTest();        
    } 
    
    
    static testMethod void Test3() {
        
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
         cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;       
        
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;        

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;        
        
        Campaign a_p = new Campaign(Name = 'asdads');
        insert a_p;
        Campaign a_c = new Campaign(Name = 'adsd', ParentId = a_p.Id, Overall_Gift_Amount__c=0,  Overall_One_Time_Gift_Count__c=0,  Overall_Recurring_Gift_Count__c=0,  Overall_Gifts_for_Current_Fiscal__c=0,  Overall_Gifts_for_Current_Quarter__c=0,  Gifts_for_Current_Quarter__c=0);
        insert a_c;
        
        Gift__c g1 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g1.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_p.Id, Amount__c = 100);
        insert gd1;
        
        Gift__c g2 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'Shareplan', Gift_Date__c = Date.Today());
        insert g2;
        Payment__c p2 = new Payment__c(Donation__c = g2.Id, Amount__c = 100, Status__c = 'Approved');
        insert p2;
        Gift_Detail__c gd2 = new Gift_Detail__c(Payment__c = p2.Id, Gift__c = g2.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_p.Id, Amount__c = 100);
        insert gd2;
    
        
        Test.startTest();        
        AppealRollupBatch2 arb = new AppealRollupBatch2();
        arb.query = 'Select a.Id From Campaign a WHERE Id = \'' + a_p.Id + '\' LIMIT 1';
        Database.executeBatch(arb, 1);  
        Test.stopTest();        
    } 
    static testMethod void Test4() {
        
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
         cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;       
        
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 

        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;
        
        Campaign a_p = new Campaign(Name = 'parent');
        insert a_p;
        Campaign a_c = new Campaign(Name = 'child', ParentId = a_p.Id,  Overall_Gift_Amount__c=0,  Overall_One_Time_Gift_Count__c=0,  Overall_Recurring_Gift_Count__c=0,  Overall_Gifts_for_Current_Fiscal__c=0,  Overall_Gifts_for_Current_Quarter__c=0,  Gifts_for_Current_Quarter__c=0);
        insert a_c;
        
        Gift__c g1 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g1.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_p.Id, Amount__c = 100);
        insert gd1;
        
        Gift__c g2 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'Shareplan', Gift_Date__c = Date.Today());
        insert g2;
        Payment__c p2 = new Payment__c(Donation__c = g2.Id, Amount__c = 100, Status__c = 'Approved');
        insert p2;
        Gift_Detail__c gd2 = new Gift_Detail__c(Payment__c = p2.Id, Gift__c = g2.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_p.Id, Amount__c = 100);
        insert gd2;
    
        
        Test.startTest();        
        AppealRollupBatch3 arb = new AppealRollupBatch3();
        
        arb.query = 'Select a.Id From Campaign a WHERE Id = \'' + a_p.Id + '\' LIMIT 1';
        Database.executeBatch(arb, 1);  
        Test.stopTest();        
    }         

    static testMethod void Test21() {
        Test.startTest();
        string jobId = System.Schedule('Test', '0 0 0 3 9 ? 2022', new AppealRollupScheduler());   
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00',
        String.valueOf(ct.NextFireTime));        
        Test.stopTest();        
    } 
    static testMethod void Test22() {
        Test.startTest();
        string jobId = System.Schedule('Test', '0 0 0 3 9 ? 2022', new AppealRollupScheduler2());   
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00',
        String.valueOf(ct.NextFireTime));        
        Test.stopTest();        
    } 
    static testMethod void Test23() {
        Test.startTest();
        string jobId = System.Schedule('Test', '0 0 0 3 9 ? 2022', new AppealRollupScheduler3());   
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00',
        String.valueOf(ct.NextFireTime));        
        Test.stopTest();        
    }      
    
  
    
    
    
    
}