@isTest
public class TestInsertSoftCreditTrigger{

    static testmethod void TestInsertingSoftCredit () {
    
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;       
       
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        Contact c = testMapping.createContact();
        
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Gift__c g = testMapping.createGift(c);
        g.RecordTypeId = '012A000000128DT';
        Payment__c p = new Payment__c(
            CC_Reference__c = 'SSSESESE',
            Donation__c = g.Id,
            Amount__c = 200,
            Status__c = 'Approved',
            Payment_Type__c = 'Cash');
        p.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'cv_pkg_dev_I__Payment__c' AND Name = 'Standard'].Id;            
        insert p;
        
        Campaign camp = new Campaign (Name='CADDFFD');
        Fund__c fund = new Fund__c();
        Gift_Detail__c alloc1 = new Gift_Detail__c(
            cv_pkg_dev_I__Amount__c = 200,
            Campaign__c = camp.Id,
            Fund__c = fund.Id);
            

        Test.startTest();
        cv_pkg_dev_I__Solicitor__c SoftCredit = new cv_pkg_dev_I__Solicitor__c(
            cv_pkg_dev_I__Gift__c = g.Id,
            cv_pkg_dev_I__Solicitor__c = g.cv_pkg_dev_I__Constituent__c
        );

        
    }    
        
}