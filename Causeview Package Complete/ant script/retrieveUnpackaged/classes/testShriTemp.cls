@isTest
public class testShriTemp {
    
     public testMethod static void testMeInstallmentPledge()
    { 
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        cv_pkg_dev_I__aNums__c cs1 = GLAllocationfieldUpdateTriggerTest.anumsSettings();

        cv_pkg_dev_I__FormSettings__c fs1 = GLAllocationfieldUpdateTriggerTest.formSettings();    
        cv_pkg_dev_I__App_Settings__c appSetting = GLAllocationfieldUpdateTriggerTest.appSettings();
        appSetting.cv_pkg_dev_I__Enable_Pledge_Installment_Model__c = true;
        update appSetting;
        cv_pkg_dev_I__BatchSettings__c cs2 = GLAllocationfieldUpdateTriggerTest.batchSettings(); 
          Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        Contact c = new Contact(LastName = 'Smith', FirstName = 'John', AccountId = a.Id);
        insert c;      
        
        Gift__c g = testMapping.createGiftForAccount(a);
        
        ApexPages.StandardController sc = new ApexPages.standardController(g);
        GiftControllerExtension.TestContactId = a.Id;
        GiftControllerExtension controller = new GiftControllerExtension(sc);
        controller.InitializeContact(a.Id);

        Causeview_REST_API rapi = new Causeview_REST_API();
        rapi.GetActionpage('a');
             
        controller.getMonths();
        controller.getYears();
        controller.addGiftDetail();
        controller.removeGiftDetail();
        controller.addSoftCredit();
        controller.getGiftDetailstoUpdate();
        controller.getSotCreditsToUpdate();
        controller.thePayment.Amount__c = 34;
        controller.theGift.Gift_Type__c = 'Pledge';
        controller.thePayment.Payment_Type__c = 'Cash';
        //controller.Submit();
        controller.GoBack();
        
        controller.tryParseToInt('45');
        GiftControllerExtension.BatchAllocationSetting item = new GiftControllerExtension.BatchAllocationSetting('ss','dd');
        controller.theRecurring.Frequency__c = 'Monthly';
        controller.theRecurring.Start_Date__c = system.today();
        controller.payment_structure = '# of Installment';
        controller.fixedNumberInstallment = 2;
        controller.theGift.Expected_Amount__c = 600;
        controller.generateInstallments();
		controller.giftForContact.cv_pkg_dev_I__Constituent__c  = c.id;
        Fund__c fund = new Fund__c(cv_pkg_dev_I__Fund_Name__c = 'Test Fund001');
        insert fund;
        cv_pkg_dev_I__Letter__c letter = new cv_pkg_dev_I__Letter__c(cv_pkg_dev_I__Name__c = 'Test Letter001');
        insert letter;
        RecordType RT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' AND NamespacePrefix = 'causeview'];
        Campaign cmp = new Campaign(Name = 'test', cv_pkg_dev_I__Fund__c = fund.id, cv_pkg_dev_I__Letter__c = letter.id);
        cmp.RecordTypeId = RT.Id;
        insert cmp;
        GiftControllerExtension.GetAppealDefaults(cmp.id);
        for(Gift_Detail__c gd : controller.theGiftDetails)
        {
            gd.New_Campaign__c = cmp.Id;
            gd.Fund__c = fund.Id;
            gd.Amount__c = 200;
            gd.Allocation_Date__c = System.Today();
        }
        controller.softCredits.add(new Solicitor__c(cv_pkg_dev_I__Organization_Solicitor__c = a.id, cv_pkg_dev_I__Gift__c = g.id)); 
        Test.startTest();
        controller.Submit();
     
        controller.payment_structure = 'Per Installment Amount';
        controller.per_payment_amount = '200';
        controller.generateInstallments();
        controller.Submit();
        controller.theGift.Gift_Type__c = 'One Time Gift';
        controller.Submit();
        controller.addInstallment();
        Test.stopTest();      
    
    }
    
}