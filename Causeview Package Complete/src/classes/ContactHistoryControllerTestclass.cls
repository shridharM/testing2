@isTest
public class ContactHistoryControllerTestclass{
 public static testMethod void ContactHistoryControllerTestclass(){
 
     App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;
        
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];  
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes.Id, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact();
        contacts.LastName = 'Constituent Test';
        Insert contacts;
        
         String ContactIdurl =contacts.Id;
        
         /* Gift__c gift1 = new Gift__c();
        //gift1.Recurring_Donation__c = recurringGift1.Id;
        gift1.Status__c = 'Active';
        gift1.Constituent__c = contacts.Id;
        gift1.Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift1.Gift_Type__c  = 'one time';
        Insert gift1; */
       
       Gift__c g = testMapping.createGift(contacts);
       ApexPages.StandardController sc = new ApexPages.standardController(g);
       ContactHistoryController c1 = new ContactHistoryController(sc);
 
       c1.loadGivingByYear(contacts.Id);
 
 
    }
}