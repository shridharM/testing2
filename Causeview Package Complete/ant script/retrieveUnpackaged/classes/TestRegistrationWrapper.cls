@isTest
public with sharing class TestRegistrationWrapper {

    public static testMethod void testRegistrationWrapper(){
        RegistrationWrapper wrapper = new RegistrationWrapper();
        
                RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];        

         Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
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
        
        cv_pkg_dev_I__Event_Registration__c evntReg = new cv_pkg_dev_I__Event_Registration__c();
        evntReg.cv_pkg_dev_I__Individual__c = c.Id;
        evntReg.cv_pkg_dev_I__Event__c = campaign.Id;
        evntReg.cv_pkg_dev_I__Registration_Date__c = Date.today();
        insert evntReg;
        evntReg = [SELECT Id FROM cv_pkg_dev_I__Event_Registration__c LIMIT 1];
        wrapper.reg = evntReg; 
        
    }
}