@isTest
public class TestInsertSoftCreditTrigger{

    static testmethod void TestInsertingSoftCredit () {
    
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;       
       
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        Contact c = testMapping.createContact();
        
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Gift__c g = testMapping.createGift(c);
        g.RecordTypeId = '012A000000128DT';
        Payment__c p = new Payment__c(
            CC_Reference__c = 'SSSESESE',
            Donation__c = g.Id,
            Amount__c = 200,
            Status__c = 'Approved',
            Payment_Type__c = 'Cash');
        p.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'causeview__Payment__c' AND Name = 'Standard'].Id;            
        insert p;
        
        Campaign camp = new Campaign (Name='CADDFFD');
        Fund__c fund = new Fund__c();
        Gift_Detail__c alloc1 = new Gift_Detail__c(
            causeview__Amount__c = 200,
            Campaign__c = camp.Id,
            Fund__c = fund.Id);
            

        Test.startTest();
        causeview__Solicitor__c SoftCredit = new causeview__Solicitor__c(
            causeview__Gift__c = g.Id,
            causeview__Solicitor__c = g.causeview__Constituent__c
        );

        
    }    
        
}