@isTest
public class tempTestClass {
    //testing
    static testMethod void test(){
        causeview__BatchSettings__c cs = new causeview__BatchSettings__c (Name='Default',  causeview__Unknown_Guest_Id__c='003A000001NEqiNIAT',causeview__CurrencyCode__c='CAD', causeview__BatchFormID__c ='a0Ai0000009hUmeEAE', causeview__BatchReportId__c ='00OA0000004N3xHMAS', causeview__RegularGiftRecordTypeId__c='012A000000128DTIAY', causeview__BucketAccountId__c ='001A0000016IVkeIAG', causeview__LockBucketAccount__c =true, causeview__GatewayUrl__c ='https://qaapi.causeview.com/v2.2/Gateway.asmx', causeview__Data_Migration_Mode__c=false);
        insert cs;
        
        Account a = new Account(Name = 'Platy IT');
        insert a;
        Contact c = new Contact(LastName = 'Grenfell', FirstName = 'Jessie', AccountId = a.Id);
        insert c;
        system.debug('------'+c.id);
        causeview__Gift__c t = new causeview__Gift__c(causeview__Constituent__c = c.Id, causeview__Gift_Date__c = System.today(), causeview__Expected_Amount__c = 5, causeview__Receipt_Type__c = 'Gift', causeview__No_of_Expected_Payments__c = 1);
        insert t;
        system.debug('------'+t.id);
        causeview__Payment__c p = new causeview__Payment__c(causeview__Donation__c = t.Id);
        insert p;
        
    }
    
}