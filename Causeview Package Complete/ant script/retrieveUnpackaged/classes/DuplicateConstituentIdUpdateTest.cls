@isTest
public class DuplicateConstituentIdUpdateTest{
    public static testMethod void DuplicateConstituentIdUpdatescheduledMethod(){
        DuplicateConstituentIdUpdatescheduled d = new DuplicateConstituentIdUpdatescheduled();
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex54321'+system.Now(), CRON_EXP, d );
        DuplicateOrganisationIdUpdatescheduled dd = new DuplicateOrganisationIdUpdatescheduled();
        System.schedule('testScheduledApex12345'+system.Now(), CRON_EXP, dd );
    }
    
    public static testMethod void DuplicateConstituentIdUpdateBatchTest(){
        cv_pkg_dev_I__aNums__c s = new cv_pkg_dev_I__aNums__c(Name='Default', cv_pkg_dev_I__OrgPrefix__c = '1', cv_pkg_dev_I__ContactPrefix__c ='1', cv_pkg_dev_I__ContactLength__c=8, cv_pkg_dev_I__OrgLength__c=5);
        insert s;
        cv_pkg_dev_I__Application_Setting__c appsetting = new cv_pkg_dev_I__Application_Setting__c(Name = 'Auto Number Setting', cv_pkg_dev_I__Org_Count__c=100);
        insert appsetting;
        List<Account> accRec = new List<Account>();
        List<Contact> contRec = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
        Account a = new Account(name = 'Nitin Test'+i, cv_pkg_dev_I__Organization_ID__c='11111');
        Account aa = new Account(name = 'Nitin Test'+i, cv_pkg_dev_I__Organization_ID__c='22222');
        accRec.add(aa);
        accRec.add(a);
        }
        insert accRec;
        for(Integer i = 0; i < 5; i++){
        contact c = new Contact(LastName = 'Khunal Test'+i, cv_pkg_dev_I__Constituent_ID__c='11111');
        contact cc = new Contact(LastName = 'Khunal Test'+i, cv_pkg_dev_I__Constituent_ID__c='22222');
        contRec.add(c);
        contRec.add(cc);
        }
        insert contRec;
        Account aaa = new Account(name = 'Nitin Test', cv_pkg_dev_I__Organization_ID__c='12345678');
        insert aaa;
        contact ccc = new Contact(LastName = 'Khunal Test Duplicate', cv_pkg_dev_I__Constituent_ID__c='12345678');
        insert ccc;
        DuplicateConstituentIdUpdateBatch d = new DuplicateConstituentIdUpdateBatch();
        Database.executeBatch(d);
       
    }
    
    public static testMethod void DuplicateOrganisationIdUpdateBatchTest(){
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];
        Account acc = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert acc;  
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = acc.Id, cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        cv_pkg_dev_I__aNums__c s = new cv_pkg_dev_I__aNums__c(Name='Default', cv_pkg_dev_I__OrgPrefix__c = '1', cv_pkg_dev_I__ContactPrefix__c ='1', cv_pkg_dev_I__ContactLength__c=5, cv_pkg_dev_I__OrgLength__c=5);
        insert s;
        cv_pkg_dev_I__Application_Setting__c appsetting = new cv_pkg_dev_I__Application_Setting__c(Name = 'Auto Number Setting', cv_pkg_dev_I__Org_Count__c=100);
        insert appsetting;
        List<Account> accRec = new List<Account>();
        List<Contact> contRec = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
        Account a = new Account(name = 'Nitin Test'+i, cv_pkg_dev_I__Organization_ID__c='33333');
        Account aa = new Account(name = 'Nitin Test'+i, cv_pkg_dev_I__Organization_ID__c='44444');
        accRec.add(aa);
        accRec.add(a);
        }
        insert accRec;
        for(Integer i = 0; i < 5; i++){
        contact c = new Contact(LastName = 'Khunal Test'+i, cv_pkg_dev_I__Constituent_ID__c='66666');
        contact cc = new Contact(LastName = 'Khunal Test'+i, cv_pkg_dev_I__Constituent_ID__c='44444');
        contRec.add(c);
        contRec.add(cc);
        }
        insert contRec;
        DuplicateOrganisationIdUpdateBatch dd = new DuplicateOrganisationIdUpdateBatch();
        Database.executeBatch(dd);        
    }
}