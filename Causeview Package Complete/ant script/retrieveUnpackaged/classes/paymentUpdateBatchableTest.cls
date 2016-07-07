@isTest
public class paymentUpdateBatchableTest{
    public static testMethod Void paymentUpdateBatchableTest(){
        
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = '123', cv_pkg_dev_I__Campaign_RecordType_Id__c = '123', 
            cv_pkg_dev_I__Event_RecordType_Id__c = '123', cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];  
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = a.Id, cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact();
        contacts.LastName = 'Constituent Test';
        Insert contacts;
        
        cv_pkg_dev_I__Recurring_Donation__c recurringGift = new cv_pkg_dev_I__Recurring_Donation__c();
        recurringGift.cv_pkg_dev_I__Constituent__c = contacts.Id;
        recurringGift.cv_pkg_dev_I__Start_Date__c = system.Today();
        recurringGift.cv_pkg_dev_I__Credit_Card_Type__c = 'Visa';
        recurringGift.cv_pkg_dev_I__Credit_Card__c = '4222222222222220';
        recurringGift.cv_pkg_dev_I__Credit_Card_Expiry_Date__c = system.Today()+2000;
        Insert recurringGift;
        
        cv_pkg_dev_I__Gift__c gift = new cv_pkg_dev_I__Gift__c();
        gift.cv_pkg_dev_I__Recurring_Donation__c = recurringGift.Id;
        gift.cv_pkg_dev_I__Status__c = 'Active';
        gift.cv_pkg_dev_I__Constituent__c = contacts.Id;
        gift.cv_pkg_dev_I__Gift_Date__c = system.today();
        gift.cv_pkg_dev_I__Gift_Type__c  = 'Recurring';
        Insert gift;
        
        cv_pkg_dev_I__Gift__c gift1 = new cv_pkg_dev_I__Gift__c();
        gift1.cv_pkg_dev_I__Recurring_Donation__c = recurringGift.Id;
        gift1.cv_pkg_dev_I__Status__c = 'Active';
        gift1.cv_pkg_dev_I__Organization__c = a.Id;
        gift1.cv_pkg_dev_I__Gift_Date__c = system.today();
        gift1.cv_pkg_dev_I__Gift_Type__c  = 'Recurring';
        Insert gift1;
        
        cv_pkg_dev_I__Payment__c payment = new cv_pkg_dev_I__Payment__c();
        payment.cv_pkg_dev_I__Date__c = System.Today();
        payment.cv_pkg_dev_I__Amount__c = 1000.00;
        payment.cv_pkg_dev_I__Payment_Type__c = 'other';
        payment.cv_pkg_dev_I__Donation__c = gift.Id;
        payment.cv_pkg_dev_I__Status__c = 'Approved';
        Insert payment;
        
        cv_pkg_dev_I__Payment__c payment1 = new cv_pkg_dev_I__Payment__c();
        payment1.cv_pkg_dev_I__Date__c = System.Today()+365;
        payment1.cv_pkg_dev_I__Amount__c = 1000.00;
        payment1.cv_pkg_dev_I__Payment_Type__c = 'other';
        payment1.cv_pkg_dev_I__Donation__c = gift.Id;
        payment1.cv_pkg_dev_I__Status__c = 'Approved';
        Insert payment1;
        system.debug('payment1==>'+payment1);
        
        /*Campaign c = new Campaign();
        c.Name = 'Test Campaign';
        c.Status = 'Planned';
        c.IsActive = true;
        insert c;
        
        cv_pkg_dev_I__Fund__c fund = new cv_pkg_dev_I__Fund__c();
        fund.cv_pkg_dev_I__Start_Date__c = system.today();
        fund.cv_pkg_dev_I__End_Date__c = system.today()+123;
        insert fund;
        
        cv_pkg_dev_I__Gift_Detail__c gf = new cv_pkg_dev_I__Gift_Detail__c();
        gf.cv_pkg_dev_I__New_Campaign__c = c.id;
        gf.cv_pkg_dev_I__Gift__c = gift.id;
        gf.cv_pkg_dev_I__Payment__c = payment1.id;
        gf.cv_pkg_dev_I__Amount__c = 100;
        gf.cv_pkg_dev_I__Fund__c = fund.id;
        insert gf;*/
         
        //List<cv_pkg_dev_I__Recurring_Donation__c> rgRecords = new List<cv_pkg_dev_I__Recurring_Donation__c>();
        //rgRecords.add(recurringGift);
        
        //Database.QueryLocator QL;
        //Database.BatchableContext BC;
        //String query = 'select Id, (select cv_pkg_dev_I__Gift_Date__c, cv_pkg_dev_I__Gift_Type__c, cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Organization__c from Orders__r) from cv_pkg_dev_I__Recurring_Donation__c';
        paymentUpdateBatchable p = new paymentUpdateBatchable();
        //Id batchprocessId = Database.executeBatch(p);
        //QL = p.start(bc);        
        //p.execute(BC, rgRecords);
        //p.finish(BC);   
        Database.executeBatch(p);
    }
}