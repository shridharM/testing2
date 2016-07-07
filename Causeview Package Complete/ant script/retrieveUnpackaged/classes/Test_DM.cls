@isTest
private class Test_DM {
	//Test GITHUB
    static testMethod void Test_GiftRollup() {
        Test.startTest();
        aNums__c a = new aNums__c(Name = 'Default', ContactCount__c = 8, ContactLength__c = 8, ContactPrefix__c = 'Con-', OrgCount__c = 8, OrgLength__c = 8, OrgPrefix__c = 'Con-');
        insert a;
        
        Account acc = new Account(Name = 'sss');
        insert acc;
        
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = 'test', cv_pkg_dev_I__BucketAccountId__c = acc.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'Contact');
        insert c;
        //Database.executeBatch(new DMContactRollups(), 5); 
        Test.stopTest();
    }
}
