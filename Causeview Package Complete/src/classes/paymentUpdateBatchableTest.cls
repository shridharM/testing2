@isTest
public class paymentUpdateBatchableTest{
    public static testMethod Void paymentUpdateBatchableTest(){
        
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
        
        causeview__Recurring_Donation__c recurringGift = new causeview__Recurring_Donation__c();
        recurringGift.causeview__Constituent__c = contacts.Id;
        recurringGift.causeview__Start_Date__c = system.Today();
        recurringGift.causeview__Credit_Card_Type__c = 'Visa';
        recurringGift.causeview__Credit_Card__c = '4222222222222220';
        recurringGift.causeview__Credit_Card_Expiry_Date__c = system.Today()+2000;
        Insert recurringGift;
        
        causeview__Gift__c gift = new causeview__Gift__c();
        gift.causeview__Recurring_Donation__c = recurringGift.Id;
        gift.causeview__Status__c = 'Active';
        gift.causeview__Constituent__c = contacts.Id;
        gift.causeview__Gift_Date__c = system.today();
        gift.causeview__Gift_Type__c  = 'Recurring';
        Insert gift;
        
        causeview__Gift__c gift1 = new causeview__Gift__c();
        gift1.causeview__Recurring_Donation__c = recurringGift.Id;
        gift1.causeview__Status__c = 'Active';
        gift1.causeview__Organization__c = a.Id;
        gift1.causeview__Gift_Date__c = system.today();
        gift1.causeview__Gift_Type__c  = 'Recurring';
        Insert gift1;
        
        causeview__Payment__c payment = new causeview__Payment__c();
        payment.causeview__Date__c = System.Today();
        payment.causeview__Amount__c = 1000.00;
        payment.causeview__Payment_Type__c = 'other';
        payment.causeview__Donation__c = gift.Id;
        payment.causeview__Status__c = 'Approved';
        Insert payment;
        
        causeview__Payment__c payment1 = new causeview__Payment__c();
        payment1.causeview__Date__c = System.Today()+365;
        payment1.causeview__Amount__c = 1000.00;
        payment1.causeview__Payment_Type__c = 'other';
        payment1.causeview__Donation__c = gift.Id;
        payment1.causeview__Status__c = 'Approved';
        Insert payment1;
        system.debug('payment1==>'+payment1);
        
        /*Campaign c = new Campaign();
        c.Name = 'Test Campaign';
        c.Status = 'Planned';
        c.IsActive = true;
        insert c;
        
        causeview__Fund__c fund = new causeview__Fund__c();
        fund.causeview__Start_Date__c = system.today();
        fund.causeview__End_Date__c = system.today()+123;
        insert fund;
        
        causeview__Gift_Detail__c gf = new causeview__Gift_Detail__c();
        gf.causeview__New_Campaign__c = c.id;
        gf.causeview__Gift__c = gift.id;
        gf.causeview__Payment__c = payment1.id;
        gf.causeview__Amount__c = 100;
        gf.causeview__Fund__c = fund.id;
        insert gf;*/
         
        //List<causeview__Recurring_Donation__c> rgRecords = new List<causeview__Recurring_Donation__c>();
        //rgRecords.add(recurringGift);
        
        //Database.QueryLocator QL;
        //Database.BatchableContext BC;
        //String query = 'select Id, (select causeview__Gift_Date__c, causeview__Gift_Type__c, causeview__Status__c, causeview__Constituent__c, causeview__Organization__c from Orders__r) from causeview__Recurring_Donation__c';
        paymentUpdateBatchable p = new paymentUpdateBatchable();
        //Id batchprocessId = Database.executeBatch(p);
        //QL = p.start(bc);        
        //p.execute(BC, rgRecords);
        //p.finish(BC);   
        Database.executeBatch(p);
    }
}