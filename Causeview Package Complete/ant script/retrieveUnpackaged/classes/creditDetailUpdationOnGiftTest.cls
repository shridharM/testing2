@isTest
public class creditDetailUpdationOnGiftTest{
    public static testMethod void creditDetailUpdationOnGiftTest(){
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
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact();
        contacts.LastName = 'Constituent Test';
        Insert contacts;
        
        cv_pkg_dev_I__Gift__c gift = new cv_pkg_dev_I__Gift__c();
        gift.cv_pkg_dev_I__Status__c = 'Active';
        gift.cv_pkg_dev_I__Constituent__c = contacts.Id;
        Insert gift;
        
        cv_pkg_dev_I__Payment__c payment = new cv_pkg_dev_I__Payment__c();
        payment.cv_pkg_dev_I__Date__c = System.Today()-2;
        payment.cv_pkg_dev_I__Amount__c = 1000.00;
        payment.cv_pkg_dev_I__Payment_Type__c = 'Credit Card';
        payment.cv_pkg_dev_I__Donation__c = gift.Id;
        payment.cv_pkg_dev_I__Status__c = 'Approved';
        payment.cv_pkg_dev_I__Credit_Card_Type__c = 'Visa';
        payment.cv_pkg_dev_I__Credit_Card_Number__c = '1234567891234567';
        Insert payment;
        
        cv_pkg_dev_I__Payment__c payment1 = new cv_pkg_dev_I__Payment__c();
        payment1.cv_pkg_dev_I__Date__c = System.Today()-1;
        payment1.cv_pkg_dev_I__Amount__c = 1000.00;
        payment1.cv_pkg_dev_I__Payment_Type__c = 'Credit Card';
        payment1.cv_pkg_dev_I__Donation__c = gift.Id;
        payment1.cv_pkg_dev_I__Status__c = 'Approved';
        payment1.cv_pkg_dev_I__Credit_Card_Type__c = 'Visa';
        payment1.cv_pkg_dev_I__Credit_Card_Number__c = '1234567891234567';
        Insert payment1;
        
        delete payment1;
    }
}