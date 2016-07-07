@isTest
public class OrgContactHandlerTest{
    
    public static testMethod void OrgContactHandlerTest(){
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1]; 
        Account a1 = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a1;

        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas', cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = a1.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd', LockBucketAccount__c = true);        
        insert cs2;
        
        Account a = new Account();
        a.name = 'Test-1234';
        a.BillingStreet = 'abc';
        a.BillingCity = 'abc';
        a.BillingPostalCode = '12345';
        a.BillingState = 'abc';
        a.BillingCountry = 'abc';
        insert a;
        
        a.Active__c = 'yes';
        update a;
        
        a.BillingStreet = 'abc';
        a.BillingCity = 'abc';
        a.BillingPostalCode = '12345';
        a.BillingState = 'ghi';
        a.BillingCountry = 'abc';
        a.ShippingStreet = 'abc';
        a.ShippingCity = 'abc';
        a.ShippingPostalCode = '12345';
        a.ShippingState = 'abc';
        a.ShippingCountry = 'abc';
        update a;
        
        a.ShippingStreet = 'abc';
        a.ShippingCity = 'abc';
        a.ShippingPostalCode = 'KA 01';
        a.ShippingState = 'abc';
        a.ShippingCountry = 'abc';
        update a;
        
        delete a;
        
        Contact c = new Contact();
        c.LastName = 'Test12345';
        c.MailingStreet = 'abc';
        c.MailingCity = 'abc';
        c.MailingPostalCode = '12345';
        c.MailingState = 'abc';
        c.MailingCountry = 'abc';
        insert c;
        
        c.MailingStreet = 'abc';
        c.MailingCity = 'ghi';
        c.MailingPostalCode = '12345';
        c.MailingState = 'abc';
        c.MailingCountry = 'abc';
        c.OtherStreet = 'abc';
        c.OtherCity = 'abc';
        c.OtherPostalCode = 'abc';
        c.OtherState = 'abc';
        c.OtherCountry = 'abc';
        update c;
        
        c.OtherStreet = 'abc';
        c.OtherCity = 'abc';
        c.OtherPostalCode = '12345';
        c.OtherState = 'abc';
        c.OtherCountry = 'abc';
        update c;
    } 
}