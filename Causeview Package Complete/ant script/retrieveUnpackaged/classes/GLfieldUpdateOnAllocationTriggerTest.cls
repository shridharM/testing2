@isTest
public class GLfieldUpdateOnAllocationTriggerTest{
    
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
    
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'One Time Gift';
        insert g;
      
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';      
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;
        
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;
        
        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 50;
        insert elev;  
          
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;
        
        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;
        
        gd.Payment__c = p2.Id;
        update gd;
        
        p1.Payment_Type__c = 'Other';
        update p1;
        
        gd.Payment__c = p1.Id;
        update gd;
        
        g.Gift_Type__c = 'Pledge';
        update g;
        
        p2.Status__c = 'Written Off';
        update p2;
        
        gd.Payment__c = p2.Id;
        update gd;
        Test.StopTest();        
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest1(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
    
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';      
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;
        
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;
        
        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 50;
        insert elev;  
          
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;
        
        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;
        
        gd.Payment__c = p2.Id;
        update gd;
        
        p1.Payment_Type__c = 'Stock'; 
        update p1;
        
        gd.Payment__c = p1.Id;
        update gd;
        
        p2.Payment_Type__c = 'Property'; 
        update p2;
        
        gd.Payment__c = p2.Id;
        update gd;
        Test.StopTest();    
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest2(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
    
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';      
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;
        
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;
        
        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 50;
        insert elev;  
          
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;
        
        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;
        
        gd.Payment__c = p2.Id;
        update gd;
        
        p1.Payment_Type__c = 'Stock'; 
        update p1;
        
        gd.Payment__c = p1.Id;
        update gd;
        
        p2.Payment_Type__c = 'Property'; 
        update p2;
        
        gd.Payment__c = p2.Id;
        update gd;
        Test.StopTest();    
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest3(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
         cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
    
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Recurring';
        insert g;
        
        Gift__c g1= new Gift__c();
        g1.Constituent__c = c.Id;
        g1.Status__c = 'Active';
        g1.RecordTypeId = rtypes_Map.get('Matching Gift');
        g1.Gift_Type__c = 'Pledge';
        insert g1;
        
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'In Kind';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Committed';
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';      
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;
        
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;
        
        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 50;
        insert elev;  
          
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123',
                                    GL_Matching_Pledge_Current_Fiscal__c ='123', GL_Matching_Pledge_Current_Fiscal_Debit__c ='123', GL_Pledge_Current_Fiscal_Credit__c = '123',
                                    GL_Pledge_Current_Fiscal_Debit__c = '123');
        insert fund;
        
        Test.StartTest();
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = camp.Id;
        gd1.Event_Level__c  = elev.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p2.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = fund.id;
        insert gd1;
        
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g1.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;
        
        g.Gift_Type__c = 'Pledge';
        update g;
        gd.Gift__c = g.Id;
        update gd;
        Test.StopTest();    
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest4(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
         cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
    
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Recurring';
        insert g;
        
        Gift__c g1= new Gift__c();
        g1.Constituent__c = c.Id;
        g1.Status__c = 'Active';
        g1.RecordTypeId = rtypes_Map.get('Matching Gift');
        g1.Gift_Type__c = 'Pledge';
        insert g1;
        
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'In Kind';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Committed';
        p1.Donation__c = g.Id;
        insert p1;
        
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;
        
        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 50;
        insert elev;  
          
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123',
                                    GL_Matching_Pledge_Current_Fiscal__c ='123', GL_Matching_Pledge_Current_Fiscal_Debit__c ='123', GL_Pledge_Current_Fiscal_Credit__c = '123',
                                    GL_Pledge_Current_Fiscal_Debit__c = '123');
        insert fund;
        
        Test.StartTest();
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = camp.Id;
        gd1.Event_Level__c  = elev.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = fund.id;
        gd1.Amount__c = 80;
        insert gd1;
        
        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';      
        p2.Cheque_Date__c = Date.today();
        p2.RecordTypeId = rtypes_Map.get('Refund');
        p2.Status__c = 'Refunded';
        p2.Donation__c = g.Id;
        p2.Payment_Refunded__c = p1.id;
        p2.Amount__c = 0;
        insert p2;
        system.debug('p2++'+p2);
        /*Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p2.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;*/
        Test.StopTest();    
    }
}