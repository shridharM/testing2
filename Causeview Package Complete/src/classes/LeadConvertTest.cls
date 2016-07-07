@isTest
public class LeadConvertTest {
    public static testMethod void testLead() {
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1]; 
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1;  
        Account buck = new Account(Name = 'aaa');
        insert buck;         
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c ( Name = 'Default', causeview__Data_Migration_Mode__c = false, causeview__BatchFormID__c = 'aa', causeview__BatchReportId__c = 'aa', causeview__BucketAccountId__c = buck.Id, causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'aaa', causeview__RegularGiftRecordTypeId__c = rtypes.Id);
        insert cs2; 
        Lead l = new Lead(LastName = 'sddsds', Company = 'sdasga');
        insert l;             
        Account a = new Account(Name = 'aaa');
        insert a;
        Contact c = new Contact(LastName = 'ssss', AccountId = a.Id);
        insert c;
        Gift__c g1 = new Gift__c(Expected_Amount__c = 25, Constituent__c = c.Id, Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 25, Date__c = Date.Today());
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Gift__c = g1.Id, Payment__c = p1.Id, Amount__c = 25, Allocation_Date__c = Date.Today());
        insert gd1;
        
        PageReference pageRef = Page.LeadConvertContact;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', l.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(l);
        leadConvertController controller = new leadConvertController (std);
        boolean dupesResult = controller.getDupes();
        boolean accDupesResult = controller.getAccDupes();
        controller.convert();
    
        ApexPages.currentPage().getParameters().put('gdIndex', '1');           

    }
       public static testMethod void testLead1() {
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1]; 
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1;  
        Account buck = new Account(Name = 'aaa');
        insert buck;         
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c ( Name = 'Default', causeview__Data_Migration_Mode__c = false, causeview__BatchFormID__c = 'aa', causeview__BatchReportId__c = 'aa', causeview__BucketAccountId__c = buck.Id, causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'aaa', causeview__RegularGiftRecordTypeId__c = rtypes.Id);
        insert cs2; 
        Lead l = new Lead(LastName = 'sddsds', Company = 'Individual');
        insert l;             
        Account a = new Account(Name = 'aaa');
        insert a;
        Contact c = new Contact(LastName = 'ssss', AccountId = a.Id);
        insert c;
        Gift__c g1 = new Gift__c(Expected_Amount__c = 25, Constituent__c = c.Id, Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 25, Date__c = Date.Today());
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Gift__c = g1.Id, Payment__c = p1.Id, Amount__c = 25, Allocation_Date__c = Date.Today());
        insert gd1;
        
        PageReference pageRef = Page.LeadConvertContact;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', l.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(l);
        leadConvertController controller = new leadConvertController (std);
        boolean dupesResult = controller.getDupes();
        boolean accDupesResult = controller.getAccDupes();
        controller.selectedCId = '0';
        controller.noOpp = false;   
        controller.convert();
    
        ApexPages.currentPage().getParameters().put('gdIndex', '1');           

    }
}