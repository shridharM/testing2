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
        causeview__aNums__c s = new causeview__aNums__c(Name='Default', causeview__OrgPrefix__c = '1', causeview__ContactPrefix__c ='1', causeview__ContactLength__c=8, causeview__OrgLength__c=5);
        insert s;
        causeview__Application_Setting__c appsetting = new causeview__Application_Setting__c(Name = 'Auto Number Setting', causeview__Org_Count__c=100);
        insert appsetting;
        List<Account> accRec = new List<Account>();
        List<Contact> contRec = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
        Account a = new Account(name = 'Nitin Test'+i, causeview__Organization_ID__c='11111');
        Account aa = new Account(name = 'Nitin Test'+i, causeview__Organization_ID__c='22222');
        accRec.add(aa);
        accRec.add(a);
        }
        insert accRec;
        for(Integer i = 0; i < 5; i++){
        contact c = new Contact(LastName = 'Khunal Test'+i, causeview__Constituent_ID__c='11111');
        contact cc = new Contact(LastName = 'Khunal Test'+i, causeview__Constituent_ID__c='22222');
        contRec.add(c);
        contRec.add(cc);
        }
        insert contRec;
        Account aaa = new Account(name = 'Nitin Test', causeview__Organization_ID__c='12345678');
        insert aaa;
        contact ccc = new Contact(LastName = 'Khunal Test Duplicate', causeview__Constituent_ID__c='12345678');
        insert ccc;
        DuplicateConstituentIdUpdateBatch d = new DuplicateConstituentIdUpdateBatch();
        Database.executeBatch(d);
       
    }
    
    public static testMethod void DuplicateOrganisationIdUpdateBatchTest(){
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];
        Account acc = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert acc;  
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c = acc.Id, causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        causeview__aNums__c s = new causeview__aNums__c(Name='Default', causeview__OrgPrefix__c = '1', causeview__ContactPrefix__c ='1', causeview__ContactLength__c=5, causeview__OrgLength__c=5);
        insert s;
        causeview__Application_Setting__c appsetting = new causeview__Application_Setting__c(Name = 'Auto Number Setting', causeview__Org_Count__c=100);
        insert appsetting;
        List<Account> accRec = new List<Account>();
        List<Contact> contRec = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
        Account a = new Account(name = 'Nitin Test'+i, causeview__Organization_ID__c='33333');
        Account aa = new Account(name = 'Nitin Test'+i, causeview__Organization_ID__c='44444');
        accRec.add(aa);
        accRec.add(a);
        }
        insert accRec;
        for(Integer i = 0; i < 5; i++){
        contact c = new Contact(LastName = 'Khunal Test'+i, causeview__Constituent_ID__c='66666');
        contact cc = new Contact(LastName = 'Khunal Test'+i, causeview__Constituent_ID__c='44444');
        contRec.add(c);
        contRec.add(cc);
        }
        insert contRec;
        DuplicateOrganisationIdUpdateBatch dd = new DuplicateOrganisationIdUpdateBatch();
        Database.executeBatch(dd);        
    }
}