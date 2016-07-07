@isTest
public class FulFillInstallmentPageControllerTest {

    public static testMethod void FulFillInstallmentPageControllerTest(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        cv_pkg_dev_I__aNums__c cs1 = anumsSettings();

        cv_pkg_dev_I__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        cv_pkg_dev_I__BatchSettings__c cs2 = batchSettings();        

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
        
        cv_pkg_dev_I__Installment__c installment = installmentRecord();
        installment.cv_pkg_dev_I__Pledge__c = g.id;
        system.debug('Nitin installment====='+installment);
        insert installment;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.cv_pkg_dev_I__Installment__c = installment.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        ApexPages.currentPage().getParameters().put('TransactionId',g.id);
        FulFillInstallmentPageController fullfillment = new FulFillInstallmentPageController(sc);
        system.debug('Nitin installmentWrapper===='+fullfillment.installmentWrapper);
        fullfillment.Payment = paymentRecord();
        fullfillment.Payment.cv_pkg_dev_I__Donation__c = g.id;
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        system.debug('Nitin installmentWrapper===='+fullfillment.installmentWrapper);
        fullfillment.saveAll();
        fullfillment.getMonths();
        fullfillment.getYears();
        
    }
    
    public static testMethod void FulFillInstallmentPageControllerTest1(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        cv_pkg_dev_I__aNums__c cs1 = anumsSettings();

        cv_pkg_dev_I__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        cv_pkg_dev_I__BatchSettings__c cs2 = batchSettings();        

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
        
        Gift__c g1 = giftRecord();
        g1.Constituent__c = c.Id;
        g1.RecordTypeId = rtype_Map.get('Gift');
        insert g1;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        cv_pkg_dev_I__Installment__c installment = installmentRecord();
        installment.cv_pkg_dev_I__Pledge__c = g.id;
        system.debug('Nitin installment====='+installment);
        insert installment;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.cv_pkg_dev_I__Installment__c = installment.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        cv_pkg_dev_I__Installment__c installment1 = installmentRecord();
        installment1.cv_pkg_dev_I__Pledge__c = g1.id;
        system.debug('Nitin installment====='+installment1);
        insert installment1;
        
        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.New_campaign__c = cam.Id;
        gd2.Event_Level__c  = e.Id;
        gd2.Gift__c = g1.Id;
        gd2.cv_pkg_dev_I__Installment__c = installment1.Id;
        gd2.Quantity__c = 50;
        gd2.Fund__c = f.id;
        insert gd2;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        ApexPages.currentPage().getParameters().put('TransactionId',g.id);
        FulFillInstallmentPageController fullfillment = new FulFillInstallmentPageController(sc);
        system.debug('Nitin installmentWrapper===='+fullfillment.installmentWrapper);
        fullfillment.Payment = paymentRecord();
        fullfillment.Payment.Amount__c = 400;
        fullfillment.Payment.cv_pkg_dev_I__Donation__c = g.id;
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        system.debug('Nitin installmentWrapper===='+fullfillment.installmentWrapper);
        fullfillment.saveAll();
    }
    
    public static testMethod void FulFillInstallmentPageControllerTest2(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        cv_pkg_dev_I__aNums__c cs1 = anumsSettings();

        cv_pkg_dev_I__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        cv_pkg_dev_I__BatchSettings__c cs2 = batchSettings();        

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
        
        Gift__c g1 = giftRecord();
        g1.cv_pkg_dev_I__Organization__c = a.Id;
        g1.RecordTypeId = rtype_Map.get('Gift');
        insert g1;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        cv_pkg_dev_I__Installment__c installment = installmentRecord();
        installment.cv_pkg_dev_I__Pledge__c = g.id;
        system.debug('Nitin installment====='+installment);
        insert installment;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.cv_pkg_dev_I__Installment__c = installment.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        cv_pkg_dev_I__Installment__c installment1 = installmentRecord();
        installment1.cv_pkg_dev_I__Pledge__c = g1.id;
        system.debug('Nitin installment====='+installment1);
        insert installment1;
        
        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.New_campaign__c = cam.Id;
        gd2.Event_Level__c  = e.Id;
        gd2.Gift__c = g1.Id;
        gd2.cv_pkg_dev_I__Installment__c = installment1.Id;
        gd2.Quantity__c = 50;
        gd2.Fund__c = f.id;
        insert gd2;
                
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        ApexPages.currentPage().getParameters().put('TransactionId',g.id);
        FulFillInstallmentPageController fullfillment = new FulFillInstallmentPageController(sc);
        system.debug('Nitin installmentWrapper===='+fullfillment.installmentWrapper);
        fullfillment.Payment = paymentRecord();
        fullfillment.Payment.Amount__c = 400;
        fullfillment.Payment.Payment_Type__c = 'Credit Card';   
        fullfillment.Payment.cv_pkg_dev_I__Credit_Card_Type__c = 'Visa';
        fullfillment.Payment.cv_pkg_dev_I__Credit_Card_Number__c = '4222222222222220';
        fullfillment.ccExpM = '1';
        fullfillment.ccExpY = '2020';
        fullfillment.Payment.cv_pkg_dev_I__Donation__c = g.id;
        system.debug('Nitin installmentWrapper===='+fullfillment.installmentWrapper);
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        fullfillment.accContId = a.id;
        
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        fullfillment.saveAll();
        
        fullfillment.submit(fullfillment.Payment, fullfillment.Payment.Donation__c);
    }
    public static testMethod void FulFillInstallmentPageControllerTest3(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        cv_pkg_dev_I__aNums__c cs1 = anumsSettings();

        cv_pkg_dev_I__FormSettings__c fs1 = formSettings();    
           
        Account a = acc();

        cv_pkg_dev_I__BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.cv_pkg_dev_I__Organization__c = a.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
        
        Gift__c g1 = giftRecord();
        g1.cv_pkg_dev_I__Organization__c = a.Id;
        g1.RecordTypeId = rtype_Map.get('Gift');
        insert g1;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        cv_pkg_dev_I__Installment__c installment = installmentRecord();
        installment.cv_pkg_dev_I__Pledge__c = g.id;
        system.debug('Nitin installment====='+installment);
        insert installment;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.cv_pkg_dev_I__Installment__c = installment.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        cv_pkg_dev_I__Installment__c installment1 = installmentRecord();
        installment1.cv_pkg_dev_I__Pledge__c = g1.id;
        system.debug('Nitin installment====='+installment1);
        insert installment1;
        
        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.New_campaign__c = cam.Id;
        gd2.Event_Level__c  = e.Id;
        gd2.Gift__c = g1.Id;
        gd2.cv_pkg_dev_I__Installment__c = installment1.Id;
        gd2.Quantity__c = 50;
        gd2.Fund__c = f.id;
        insert gd2;
                
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        ApexPages.currentPage().getParameters().put('TransactionId',g.id);
        FulFillInstallmentPageController fullfillment = new FulFillInstallmentPageController(sc);
        system.debug('Nitin installmentWrapper===='+fullfillment.installmentWrapper);
        fullfillment.Payment = paymentRecord();
        fullfillment.Payment.Amount__c = 300;
        fullfillment.Payment.cv_pkg_dev_I__Donation__c = g.id;
        system.debug('Nitin installmentWrapper===='+fullfillment.installmentWrapper);
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        fullfillment.accContId = a.id;
        
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 100;
        }
        fullfillment.saveAll();
    }
    
    public static Gift__c giftRecord(){
        Gift__c g= new Gift__c();
        g.Status__c = 'Active';
        g.Gift_Type__c = 'One Time Gift';
        return g;
    }
    
    public static Payment__c paymentRecord(){
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 200;
        p1.Status__c = 'Approved';
        return p1;
    }
    
    public static Gift_Detail__c giftDetailRecord(){
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.Quantity__c = 50;
        return gd1;
    }
    
    public static Map<String, String> getrecordTypes(){
        Map<String, String> rtypes = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Refund' OR Name = 'Credit Card' OR Name = 'Standard') AND NamespacePrefix = 'causeview']){
            rtypes.put(r.Name, r.Id);
        }
        return rtypes;
    }
    
    public static cv_pkg_dev_I__aNums__c anumsSettings(){
        cv_pkg_dev_I__aNums__c cs = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs; 
        return cs;
    }
    
    public static cv_pkg_dev_I__FormSettings__c formSettings(){
        cv_pkg_dev_I__FormSettings__c fs = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs;
        return fs;  
    }
    
    public static Account acc(){
        Account a1 = new Account(name='testAccount', Email__c='test@account.com');
        Insert a1;
        return a1;
    }
    
    public static Contact con(){
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
        return c;
    }
    
    public static cv_pkg_dev_I__BatchSettings__c batchSettings(){
        Account a = acc();
        Map<String, String> rtypes_Map = getrecordTypes();
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        return cs2;
    }
    
    public static cv_pkg_dev_I__App_Settings__c appSettings(){
        Map<String, String> rtypes_Map = getrecordTypes();
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false, cv_pkg_dev_I__Enable_Enhanced_Fund_Accounting__c = True);
        insert app;
        return app;
    }
    
    public static Fund__c fundRecord(){
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
    
    Public static Event_Level__c eventLevelRecord(){
        //Campaign camp = campaignRecord();
        Event_Level__c elev = new Event_Level__c();
        //elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 50;
        //insert elev; 
        return elev;
    }
    
    Public static Campaign campaignRecord(){
        Map<String, String> rtypes_Map = getrecordTypes();
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        //insert camp;  
        return camp;
    }
    
    public static cv_pkg_dev_I__Installment__c installmentRecord(){
        cv_pkg_dev_I__Installment__c installment = new cv_pkg_dev_I__Installment__c();
        installment.Name = 'Installment 1';
        installment.cv_pkg_dev_I__Inst_No__c = 1;
        installment.cv_pkg_dev_I__Installment_Date__c = system.today();
        installment.cv_pkg_dev_I__Installment_Amount__c = 200;
        installment.cv_pkg_dev_I__Status__c = 'Open';
        return installment;
    }
}