@isTest
global class GLAllocationfieldUpdateTriggerTest{
    public static testMethod void GLAllocationfieldUpdateTrigger(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger1(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Payment_Type__c = 'In Kind'; 
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger2(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Payment_Type__c = 'Other'; 
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger3(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Status__c = 'Approved';
        update p1;
        
        p1.Status__c = 'Written Off';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger4(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Payment_Type__c = 'In Kind';
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger5(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g.Id;
        insert p2;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'Stock';
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger6(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g.Id;
        insert p2;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'Property';
        p1.Status__c = 'Approved';
        update p1;
        
        p1.Status__c = 'Committed';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger7(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g.Id;
        insert p2;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Status__c = 'Approved';
        update p1;
        p1.Status__c = 'Written Off';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger8(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g.Id;
        insert p2;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'In Kind';
        p1.Status__c = 'Approved';
        update p1;
        
        p1.Status__c = 'Committed';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger9(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'Stock';
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger10(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'Property';
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger11(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        causeview__aNums__c cs1 = anumsSettings();

        causeview__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        causeview__BatchSettings__c cs2 = batchSettings();        
        causeview__App_Settings__c app = appSettings();
        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        g.Gift_Type__c = 'Recurring';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        gd1.causeview__Posted_to_Finance__c = system.today();
        insert gd1;

        p1.Status__c = 'Approved';
        update p1;
        try{
            delete gd1;
        }
        catch(dmlexception err){
            system.assert(err.getMessage().contains('You can not delete this record because \'Enable Enhanced Fund Accounting\' is enabled in custom setting and \'Posted to Finance\' field is not blank!'), err.getMessage() );
        }
    }
    
    global static Gift__c giftRecord(){
        Gift__c g= new Gift__c();
        g.Status__c = 'Active';
        g.Gift_Type__c = 'One Time Gift';
        return g;
    }
    
    global static Payment__c paymentRecord(){
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Written Off';
        return p1;
    }
    
    global static Gift_Detail__c giftDetailRecord(){
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.Quantity__c = 50;
        return gd1;
    }
    
    global static Map<String, String> getrecordTypes(){
        Map<String, String> rtypes = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Refund' OR Name ='Issued') AND NamespacePrefix = 'causeview']){
            rtypes.put(r.Name, r.Id);
        }
        return rtypes;
    }
    
    global static causeview__aNums__c anumsSettings(){
        causeview__aNums__c cs = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs; 
        return cs;
    }
    
    global static causeview__FormSettings__c formSettings(){
        causeview__FormSettings__c fs = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs;
        return fs;  
    }
    
    global static Account acc(){
        Account a1 = new Account(name='testAccount', Email__c='test@account.com');
        Insert a1;
        return a1;
    }
    
    global static Contact con(){
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
        return c;
    }
    
    global static causeview__BatchSettings__c batchSettings(){
        Account a = acc();
        Map<String, String> rtypes_Map = getrecordTypes();
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        return cs2;
    }
    
    global static causeview__App_Settings__c appSettings(){
        Map<String, String> rtypes_Map = getrecordTypes();
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false, causeview__Enable_Enhanced_Fund_Accounting__c = True, causeview__Enable_Pledge_Installment_Model__c = false);
        insert app;
        return app;
    }
    
    global static Fund__c fundRecord(){
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;
        return fund;
    }
    
    global static Event_Level__c eventLevelRecord(){
        //Campaign camp = campaignRecord();
        Event_Level__c elev = new Event_Level__c();
        //elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        //insert elev; 
        return elev;
    }
    
    global static Campaign campaignRecord(){
        Map<String, String> rtypes_Map = getrecordTypes();
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        //insert camp;  
        return camp;
    }
}
