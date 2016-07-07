@isTest
public with sharing class TestPayment {

    public static testMethod void testCauseviewPayments(){
        
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];        
         Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        
        // transaction
        Contact c = new Contact();
        c.FirstName = 'Test';  
        c.LastName = 'Sanders';
        insert c;
        c = [SELECT Id FROM Contact LIMIT 1];
          
        cv_pkg_dev_I__Gift__c trans = new cv_pkg_dev_I__Gift__c();
        trans.cv_pkg_dev_I__Status__c = 'Entered';
        trans.cv_pkg_dev_I__Constituent__c = c.Id;
        
        insert trans;
        trans = [SELECT Id FROM cv_pkg_dev_I__Gift__c WHERE cv_pkg_dev_I__Status__c = 'Entered' LIMIT 1];
        
        // payment 
        cv_pkg_dev_I__Payment__c pay = new cv_pkg_dev_I__Payment__c();
        pay.cv_pkg_dev_I__Donation__c = trans.Id;
        
        insert pay;
    } 

    public static testMethod void testPayment(){
        
    } 

}