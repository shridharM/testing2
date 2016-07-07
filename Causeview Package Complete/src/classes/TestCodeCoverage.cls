@isTest
global class TestCodeCoverage {

        
        public static testMethod void DMAccountRollupsTest()
        {
        
          RecordType rtypes = [Select Name, Id From RecordType where Name = 'Household' AND NamespacePrefix = 'causeview' LIMIT 1]; 
          
          RecordType rtypes1 = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1]; 
          
          Account a1 = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
           insert a1;
          
          causeview__BatchSettings__c settingList= new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes1.Id, causeview__BucketAccountId__c =a1.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
          insert settingList;       

          Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11', recordTypeId = rtypes.Id);
          insert a;
        
          DMAccountRollups AccountRollup = new DMAccountRollups();
          Database.executeBatch(AccountRollup);

        }
        
        public static testMethod void DMContactRollupsTest()
        {
            RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1]; 
          
           causeview__BatchSettings__c settingList= new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c ='fdgg',    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
           insert settingList;
          
           Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
           insert a;
            
           Contact c = new Contact(LastName = 'Smith', FirstName = 'John', AccountId = a.Id);
           insert c;  
        
          DMContactRollups ContactRollups = new DMContactRollups();
          Database.executebatch(ContactRollups);

        }
        
        public static testMethod void Generic_Form_Admin_Panel_ControllerTest()
        {
        
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        
        
         causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;
        
        Generic_Form_Admin_Panel_Controller cc = new Generic_Form_Admin_Panel_Controller();
        String accountId ; cc.accountId='';
        String sessionId ;cc.sessionId='';
        String pageUrl ; cc.pageUrl ='';
        
        }
        
        public static testMethod void RDAllocationURLUpdateTest()
        {
         
         Map<String, String> rtypes_Map = new Map<String, String>();
           for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
             }
             
          causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;   
             
         causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
         insert cs2;
        
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;    
         
         Contact c = new Contact();
         c.LastName = 'sss';
         insert c;
    
    
        causeview__Recurring_Donation__c  RD= new causeview__Recurring_Donation__c();  
        RD.causeview__Constituent__c = c.Id;  
        Rd.causeview__Start_Date__c = system.today();
        insert RD;
        
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Recurring ';
        g.causeview__Recurring_Donation__c = RD.id;
        insert g;
         
    
        causeview__RD_Allocation__c r= new causeview__RD_Allocation__c();
        r.causeview__Recurring_Gift__c= RD.id;
        insert r;
         
        ApexPages.CurrentPage().getparameters().put('id', r.id);
        ApexPages.StandardController sc = new ApexPages.standardController(r);
   
        
        RDAllocationURLUpdate n = new RDAllocationURLUpdate(sc);
        
        }
        
        static testMethod void recurringMaintControllerTest()
    {
    
    
        Map<String, String> rtypes_Map = new Map<String, String>();
           for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
             }
         
         causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;   
             
         causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
         insert cs2; 
         
         causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
            insert app;
         
         
         Contact c = new Contact();
         c.LastName = 'sss';
         insert c;
    
    
        causeview__Recurring_Donation__c  RD= new causeview__Recurring_Donation__c();  
        RD.causeview__Constituent__c = c.Id;  
        Rd.causeview__Start_Date__c = system.today();
        insert RD;
        
        ApexPages.CurrentPage().getparameters().put('id', RD.id);
        ApexPages.StandardController sc = new ApexPages.standardController(RD);
        
        recurringMaintController cnt = new recurringMaintController();
        cnt.init();
        cnt.getYearItems();
        cnt.cancel();
    }   
    
     static testMethod void RollupIndividualBatchTest()
    {
    
    
        Map<String, String> rtypes_Map = new Map<String, String>();
           for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
             }
         causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;   
             
         causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
         insert cs2;
        
            causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
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
    
    
             RollupIndividualBatch b = new RollupIndividualBatch();
             database.executebatch(b);
        
    }   
    
    static testMethod void sysLastTransUpdatePaymentBatchTest()
    {
    
    
        Map<String, String> rtypes_Map = new Map<String, String>();
           for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
             }
         causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;   
             
         causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
         insert cs2;
            
         
            causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
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
    
           set<Id> gids = new set<Id>();
           gids.add(g.id);
    
             sysLastTransUpdatePaymentBatch b = new sysLastTransUpdatePaymentBatch(gids);
             database.executebatch(b);
        
    }   
    
    static testMethod void FieldTest()
    {
      Field f = new Field();
        
         string id;  f.id='';
         string name; f.name='';
         string value; f.value ='';
         string value_type; f.value_type='';
         string field_type;f.field_type='';
         boolean required; f.required =true;
         string description; f.description='';
        
    
    
    
    }
 }