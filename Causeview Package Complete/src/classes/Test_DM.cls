@isTest
private class Test_DM {
	//Test GITHUB
    static testMethod void Test_GiftRollup() {
        Test.startTest();
        aNums__c a = new aNums__c(Name = 'Default', ContactCount__c = 8, ContactLength__c = 8, ContactPrefix__c = 'Con-', OrgCount__c = 8, OrgLength__c = 8, OrgPrefix__c = 'Con-');
        insert a;
        
        Account acc = new Account(Name = 'sss');
        insert acc;
        
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = 'test', causeview__BucketAccountId__c = acc.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'Contact');
        insert c;
        //Database.executeBatch(new DMContactRollups(), 5); 
        Test.stopTest();
    }
}