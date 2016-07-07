@isTest
public class creditDetailUpdationOnGiftTest{
    public static testMethod void creditDetailUpdationOnGiftTest(){
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
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact();
        contacts.LastName = 'Constituent Test';
        Insert contacts;
        
        causeview__Gift__c gift = new causeview__Gift__c();
        gift.causeview__Status__c = 'Active';
        gift.causeview__Constituent__c = contacts.Id;
        Insert gift;    
        
        
        causeview__Payment__c payment = new causeview__Payment__c();
        payment.causeview__Date__c = System.Today()-2;
        payment.causeview__Amount__c = 1000.00;
        payment.causeview__Payment_Type__c = 'Credit Card';
        payment.causeview__Donation__c = gift.Id;
        payment.causeview__Status__c = 'Approved';
        payment.causeview__Credit_Card_Type__c = 'Visa';
        payment.causeview__Credit_Card_Number__c = '1234567891234567';
        Insert payment;
        
        causeview__Payment__c payment1 = new causeview__Payment__c();
        payment1.causeview__Date__c = System.Today()-1;
        payment1.causeview__Amount__c = 1000.00;
        payment1.causeview__Payment_Type__c = 'Credit Card';
        payment1.causeview__Donation__c = gift.Id;
        payment1.causeview__Status__c = 'Approved';
        payment1.causeview__Credit_Card_Type__c = 'Visa';
        payment1.causeview__Credit_Card_Number__c = '4222222222222220';
        Test.StartTest();
        Insert payment1;
        Test.StopTest();
        system.debug('=====gift.causeview__Credit_Card_Number__c=='+gift.causeview__Credit_Card_Number__c);
        //System.assertEquals(payment1.causeview__Credit_Card_Number__c, gift.causeview__Credit_Card_Number__c);
        //System.assertEquals(payment1.causeview__Credit_Card_Type__c, gift.causeview__Credit_Card_Type__c);
        delete payment1;
    }
}