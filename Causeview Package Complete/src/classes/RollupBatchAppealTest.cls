@isTest
private class RollupBatchAppealTest {
    static testMethod void Test() {
        
         Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
         causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;        
        
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;

        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;       
                        
        Campaign a_p = new Campaign(Name = 'asdads');
        insert a_p;
        
        RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
        Campaign a_c = new Campaign(Name = 'adsd', ParentId = a_p.Id, RecordTypeId=recType.id);
        insert a_c;    
               
        
        Expense__c e = new Expense__c(New_Campaign__c = a_c.Id, Amount__c = 100);
        insert e;
      
        Event_Registration__c er = new Event_Registration__c(causeview__Event__c = a_c.Id, causeview__Individual__c = c.Id, causeview__Registration_Date__c = Date.Today(), causeview__Status__c = 'Attended');
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
         causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;        
        
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;        

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;        
        RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
        Campaign a_p = new Campaign(Name = 'asdads', RecordTypeId=recType.id);
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
         causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;       
        
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;        

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;        
        RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
        Campaign a_p = new Campaign(Name = 'asdads', RecordTypeId=recType.id);
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
         causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;       
        
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 

        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;
        RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
        Campaign a_p = new Campaign(Name = 'parent', RecordTypeId=recType.id);
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
        //Test.stopTest();    
        
         RollupBatchAppeal b =new RollupBatchAppeal(); 
         b.query = 'Select a.Id From Campaign a WHERE Id = \'' + a_p.Id + '\' LIMIT 1'; 
         Database.executeBatch(b, 1); 
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