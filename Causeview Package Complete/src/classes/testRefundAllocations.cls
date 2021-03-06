//Test RefundAllocations Trigger
@isTest
Public class testRefundAllocations {
    static testMethod void testTrigger() {
        List<Payment__c> allPayments = new List<Payment__c>();
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];        
        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
         causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        Gift__c d1 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert d1;
        Gift__c d2 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert d2;

        Test.startTest();

        Payment__c p1 = new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash',
                                        Status__c='Refunded', Donation__c = d1.Id, Receipt__c=null);
        Insert p1;
        Gift_Detail__c  all = new Gift_Detail__c (Payment__c=p1.Id,Allocation_Date__c=System.today(), Gift__c=d1.Id,Amount__c=200);
        Insert all;
        allPayments.add(new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash', Payment_Refunded__c=p1.Id,
                                        Status__c='Refunded', Donation__c = d1.Id, Receipt__c=null));
        allPayments.add(new Payment__c(Date__c=null, Amount__c=200, Payment_Type__c='cash',
                                        Status__c='Approved', Donation__c=d1.Id, Receipt__c=null));
        allPayments.add(new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash',
                                        Status__c='Approved', Donation__c=d2.Id, Receipt__c=null));

        Insert allPayments;
        
        Test.stopTest();
    }
}