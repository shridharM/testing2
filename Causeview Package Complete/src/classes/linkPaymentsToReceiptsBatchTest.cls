@isTest
public class linkPaymentsToReceiptsBatchTest{
    public static testMethod void linkPaymentsToReceiptsBatch(){
    
        
        
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
    
    
        
        
        
        causeview__Gift__c gift1 = new causeview__Gift__c();
        
        gift1.causeview__Status__c = 'Active';
        gift1.causeview__Constituent__c = contacts.Id;
        gift1.causeview__Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift1.causeview__Gift_Type__c  = 'one time';
        Insert gift1;
        
        
        causeview__Receipt__c r = new causeview__Receipt__c();
       r.causeview__Receipt_Type__c = 'Single';
       r.causeview__Gift__c = gift1.Id;
       r.causeview__Amount_Not_Eligible__c= 0;
        r.causeview__Status__c = 'Issued';
        insert r;
        
        
        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'Check';
        p2.Amount__c = 85;
        p2.Donation__c = gift1.Id;
        p2.causeview__Status__c  = 'Approved';
        //p2.causeview__Receipt__c ='';
        insert p2;
        
       
    
        Test.StartTest();
        linkPaymentsToReceiptsBatch N = new linkPaymentsToReceiptsBatch();     
       
        Database.executeBatch(N);
        
        ReceiptBodyExportController re = new ReceiptBodyExportController();
        string str = re.content;
        
        ReceiptAttachExportController re1 = new ReceiptAttachExportController();
        string str1 = re1.content;
        
        
        Test.stopTest();
    }
}