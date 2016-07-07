@isTest
public with sharing class TestPayment {

    public static testMethod void testCauseviewPayments(){
        
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];        
         Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        
        // transaction
        Contact c = new Contact();
        c.FirstName = 'Test';  
        c.LastName = 'Sanders';
        insert c;
        c = [SELECT Id FROM Contact LIMIT 1];
          
        causeview__Gift__c trans = new causeview__Gift__c();
        trans.causeview__Status__c = 'Entered';
        trans.causeview__Constituent__c = c.Id;
        
        insert trans;
        trans = [SELECT Id FROM causeview__Gift__c WHERE causeview__Status__c = 'Entered' LIMIT 1];
        
        // payment 
        causeview__Payment__c pay = new causeview__Payment__c();
        pay.causeview__Donation__c = trans.Id;
        
        insert pay;
    } 

    public static testMethod void testPayment(){
        
    } 

}