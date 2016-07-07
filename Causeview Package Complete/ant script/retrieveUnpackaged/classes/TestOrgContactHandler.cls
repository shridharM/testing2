@isTest
public with sharing class TestOrgContactHandler{



  /*static testMethod void testOrgContacHandler()
  {
     
    

    Account aOld = new Account();
     aOld.Name = 'test1';
     aOld.BillingStreet = 'asa';
     aOld.BillingCity = 'canada';
     aOld.BillingPostalCode = '456456';
     aOld.BillingState = 'CA';
     aOld.BillingCountry = 'US';
     aOld.Phone = '7564864';
     aOld.cv_pkg_dev_I__Household_Addressee__c = 'sdfsd'; 
     aOld.cv_pkg_dev_I__Household_Salutation__c = '';
     insert aOld;
     
     
      Account aNew = new Account();
     aNew.Name = 'test1';
     aNew.BillingStreet = 'dddddd';
     aNew.BillingCity = 'cana';
     aNew.BillingPostalCode = '456456';
     aNew.BillingState = 'CA';
     aNew.BillingCountry = 'US';
     aNew.Phone = '7564864';
     aNew.cv_pkg_dev_I__Household_Addressee__c = 'asfasas'; 
     aNew.cv_pkg_dev_I__Household_Salutation__c = '';
     insert aNew;
     
      List<Account> cOld = new List<Account>();
      cOld.add(aOld);
      
      List<Account> cNew = new List<Account>();
      cNew.add(aNew);
  
      //OrgContactHandler.CascadeHouseholdAddress(cOld, cNew);
      
     
  }*/
  
static testMethod void testorg()
 {
    
    Account aOld = new Account();
     aOld.Name = 'test1';
     aOld.BillingStreet = 'asa';
     aOld.BillingCity = 'canada';
     aOld.BillingPostalCode = '456456';
     aOld.BillingState = 'CA';
     aOld.BillingCountry = 'US';
     aOld.Phone = '7564864';
     aOld.cv_pkg_dev_I__Household_Addressee__c = 'sdfsd'; 
     aOld.cv_pkg_dev_I__Household_Salutation__c = '';
     insert aOld;
     
     
      Account aNew = new Account();
     aNew.Name = 'test1';
     aNew.BillingStreet = 'dddddd';
     aNew.BillingCity = 'cana';
     aNew.BillingPostalCode = '456456';
     aNew.BillingState = 'CA';
     aNew.BillingCountry = 'US';
     aNew.Phone = '7564864';
     aNew.cv_pkg_dev_I__Household_Addressee__c = 'asfasas'; 
     aNew.cv_pkg_dev_I__Household_Salutation__c = '';
     insert aNew;
     
      List<Account> cOld = new List<Account>();
      cOld.add(aOld);
      
      List<Account> cNew = new List<Account>();
      cNew.add(aNew);
      
      Account aNew1 = new Account();
     aNew1.Name = 'test1';
     aNew1.BillingStreet = 'dddddd';
     aNew1.BillingCity = 'cana';
     aNew1.BillingPostalCode = '456456';
     aNew1.BillingState = 'CA';
     aNew1.BillingCountry = 'US';
     aNew1.Phone = '7564864';
     aNew1.cv_pkg_dev_I__Household_Addressee__c = 'asfasas'; 
     aNew1.cv_pkg_dev_I__Household_Salutation__c = '';
     insert aNew1;

      RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];        
       cv_pkg_dev_I__BatchSettings__c settingList= new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = aNew1.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert settingList;
      
           
      cNew.clear(); 
      aNew.Id = settingList.BucketAccountId__c;
      cNew.add(aNew);
      OrgContactHandler.PreventBucketDelete(cNew);
      
      
      
     OrgContactHandler.PreventBucketModify(cOld,cNew);
      
      cv_pkg_dev_I__aNums__c a = new cv_pkg_dev_I__aNums__c(Name = 'Default', cv_pkg_dev_I__ContactCount__c = 1, cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactPrefix__c = 'CON-', cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__OrgLength__c = 8,  cv_pkg_dev_I__OrgPrefix__c = 'ORG-');
        insert a;
      
      
      
      
      
     
      
      boolean reValue = OrgContactHandler.IsAssigned('accout', 'Account', a.Id);
      
      String val = OrgContactHandler.GetNext('Account', a);
 }
 
}