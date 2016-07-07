@isTest
public with sharing class TestRegistrationWrapper {

    public static testMethod void testRegistrationWrapper(){
        RegistrationWrapper wrapper = new RegistrationWrapper();
        
                RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];        

         Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Sanders';
        insert c;
        c = [SELECT Id FROM Contact LIMIT 1];
        
        wrapper.con = [SELECT Id FROM Contact LIMIT 1];
        
        Campaign campaign = new Campaign();
        campaign.Name = 'Test Campaign';
        insert campaign;
        campaign = [SELECT Id FROM Campaign LIMIT 1];
        
        causeview__Event_Registration__c evntReg = new causeview__Event_Registration__c();
        evntReg.causeview__Individual__c = c.Id;
        evntReg.causeview__Event__c = campaign.Id;
        evntReg.causeview__Registration_Date__c = Date.today();
        insert evntReg;
        evntReg = [SELECT Id FROM causeview__Event_Registration__c LIMIT 1];
        wrapper.reg = evntReg; 
        
    }
}