@isTest
public class tempTestClass {
    
    static testMethod void test(){
        cv_pkg_dev_I__BatchSettings__c cs = new cv_pkg_dev_I__BatchSettings__c (Name='Default',  cv_pkg_dev_I__Unknown_Guest_Id__c='003A000001NEqiNIAT',cv_pkg_dev_I__CurrencyCode__c='CAD', cv_pkg_dev_I__BatchFormID__c ='a0Ai0000009hUmeEAE', cv_pkg_dev_I__BatchReportId__c ='00OA0000004N3xHMAS', cv_pkg_dev_I__RegularGiftRecordTypeId__c='012A000000128DTIAY', cv_pkg_dev_I__BucketAccountId__c ='001A0000016IVkeIAG', cv_pkg_dev_I__LockBucketAccount__c =true, cv_pkg_dev_I__GatewayUrl__c ='https://qaapi.causeview.com/v2.2/Gateway.asmx', cv_pkg_dev_I__Data_Migration_Mode__c=false);
        insert cs;
        
        Account a = new Account(Name = 'Platy IT');
        insert a;
        Contact c = new Contact(LastName = 'Grenfell', FirstName = 'Jessie', AccountId = a.Id);
        insert c;
        system.debug('------'+c.id);
        cv_pkg_dev_I__Gift__c t = new cv_pkg_dev_I__Gift__c(cv_pkg_dev_I__Constituent__c = c.Id, cv_pkg_dev_I__Gift_Date__c = System.today(), cv_pkg_dev_I__Expected_Amount__c = 5, cv_pkg_dev_I__Receipt_Type__c = 'Gift', cv_pkg_dev_I__No_of_Expected_Payments__c = 1);
        insert t;
        system.debug('------'+t.id);
        cv_pkg_dev_I__Payment__c p = new cv_pkg_dev_I__Payment__c(cv_pkg_dev_I__Donation__c = t.Id);
        insert p;
        
    }
    
}