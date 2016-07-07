@isTest
public class NewYearTransaction2016batchSchedulerTest{
    public static testMethod void NewYearTransaction2016batchSchedulerTest(){
    
        
        
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = '123', causeview__Campaign_RecordType_Id__c = '123', 
            causeview__Event_RecordType_Id__c = '123', causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;
        
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];  
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c = a.Id, causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact();
        contacts.LastName = 'Constituent Test';
        Insert contacts;
    
    
        causeview__Recurring_Donation__c recurringGift1 = new causeview__Recurring_Donation__c();
        recurringGift1.causeview__Constituent__c = contacts.Id;
        recurringGift1.causeview__Start_Date__c = system.Today();
        recurringGift1.causeview__Credit_Card_Type__c = 'Visa';
        recurringGift1.causeview__Credit_Card__c = '4222222222222220';
        recurringGift1.causeview__Credit_Card_Expiry_Date__c = system.Today()+2000;
        recurringGift1.causeview__Status__c='Active';
        Insert recurringGift1;
        
        causeview__Recurring_Donation__c recurringGift2 = new causeview__Recurring_Donation__c();
        recurringGift2.causeview__Constituent__c = contacts.Id;
        recurringGift2.causeview__Start_Date__c = system.Today();
        recurringGift2.causeview__Credit_Card_Type__c = 'Visa';
        recurringGift2.causeview__Credit_Card__c = '4222222222222220';
        recurringGift2.causeview__Credit_Card_Expiry_Date__c = system.Today()+2000;
        recurringGift2.causeview__Status__c='On Hold';
        Insert recurringGift2;
        
        causeview__Recurring_Donation__c recurringGift3 = new causeview__Recurring_Donation__c();
        recurringGift3.causeview__Constituent__c = contacts.Id;
        recurringGift3.causeview__Start_Date__c = system.Today();
        recurringGift3.causeview__Credit_Card_Type__c = 'Visa';
        recurringGift3.causeview__Credit_Card__c = '4222222222222220';
        recurringGift3.causeview__Credit_Card_Expiry_Date__c = system.Today()+2000;
        recurringGift3.causeview__Status__c='Cancelled';
        Insert recurringGift3;
        
        causeview__Gift__c gift1 = new causeview__Gift__c();
        gift1.causeview__Recurring_Donation__c = recurringGift1.Id;
        gift1.causeview__Status__c = 'Active';
        gift1.causeview__Constituent__c = contacts.Id;
        gift1.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift1.causeview__Gift_Type__c  = 'Recurring';
        Insert gift1;
        
        causeview__Gift__c gift2 = new causeview__Gift__c();
        gift2.causeview__Recurring_Donation__c = recurringGift1.Id;
        gift2.causeview__Status__c = 'Acknowledged';
        gift2.causeview__Constituent__c = contacts.Id;
        gift2.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift2.causeview__Gift_Type__c  = 'Recurring';
        Insert gift2;
        
        causeview__Gift__c gift3 = new causeview__Gift__c();
        gift3.causeview__Recurring_Donation__c = recurringGift1.Id;
        gift3.causeview__Status__c = 'Payment Received';
        gift3.causeview__Constituent__c = contacts.Id;
        gift3.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift3.causeview__Gift_Type__c  = 'Recurring';
        Insert gift3;
        
        causeview__Gift__c gift4 = new causeview__Gift__c();
        gift4.causeview__Recurring_Donation__c = recurringGift2.Id;
        gift4.causeview__Status__c = 'Active';
        gift4.causeview__Constituent__c = contacts.Id;
        gift4.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift4.causeview__Gift_Type__c  = 'Recurring';
        Insert gift4;
        
        causeview__Gift__c gift5 = new causeview__Gift__c();
        gift5.causeview__Recurring_Donation__c = recurringGift2.Id;
        gift5.causeview__Status__c = 'Acknowledged';
        gift5.causeview__Constituent__c = contacts.Id;
        gift5.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift5.causeview__Gift_Type__c  = 'Recurring';
        Insert gift5;
        
        causeview__Gift__c gift6 = new causeview__Gift__c();
        gift6.causeview__Recurring_Donation__c = recurringGift2.Id;
        gift6.causeview__Status__c = 'Payment Received';
        gift6.causeview__Constituent__c = contacts.Id;
        gift6.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift6.causeview__Gift_Type__c  = 'Recurring';
        Insert gift6;
        
        causeview__Gift__c gift7 = new causeview__Gift__c();
        gift7.causeview__Recurring_Donation__c = recurringGift3.Id;
        gift7.causeview__Status__c = 'Active';
        gift7.causeview__Constituent__c = contacts.Id;
        gift7.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift7.causeview__Gift_Type__c  = 'Recurring';
        Insert gift7;
        
        causeview__Gift__c gift8 = new causeview__Gift__c();
        gift8.causeview__Recurring_Donation__c = recurringGift3.Id;
        gift8.causeview__Status__c = 'Acknowledged';
        gift8.causeview__Constituent__c = contacts.Id;
        gift8.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift8.causeview__Gift_Type__c  = 'Recurring';
        Insert gift8;
        
        causeview__Gift__c gift9 = new causeview__Gift__c();
        gift9.causeview__Recurring_Donation__c = recurringGift3.Id;
        gift9.causeview__Status__c = 'Payment Received';
        gift9.causeview__Constituent__c = contacts.Id;
        gift9.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift9.causeview__Gift_Type__c  = 'Recurring';
        Insert gift9;
        
        
    
        Test.StartTest();
        NewYearTransaction2016batch N = new NewYearTransaction2016batch();     
       
        Database.executeBatch(N);
        Test.stopTest();
    }
}