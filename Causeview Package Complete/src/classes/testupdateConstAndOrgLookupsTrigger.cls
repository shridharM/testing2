@isTest
class testupdateConstAndOrgLookupsTrigger {
    static testMethod void testTrigger() {
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];        

        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        Gift__c d1 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert d1;
        Gift__c d2 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=null, Organization__c=a.Id); 
        Insert d2;

        Test.startTest();

        Receipt__c r1 = new Receipt__c(Gift__c=d1.Id);
        Insert r1;
        r1.Amount_Receipted__c = 100;
        Update r1;

        Receipt__c r2 = new Receipt__c(Gift__c=d2.Id);
        Insert r2;

        Test.stopTest();
    }
}