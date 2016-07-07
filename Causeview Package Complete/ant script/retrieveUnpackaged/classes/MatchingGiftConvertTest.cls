@isTest
public class MatchingGiftConvertTest {
    public static testMethod void testMatchingGift() {
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1]; 
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1;  
        Account buck = new Account(Name = 'aaa');
        insert buck;         
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c ( Name = 'Default', cv_pkg_dev_I__Data_Migration_Mode__c = false, cv_pkg_dev_I__BatchFormID__c = 'aa', cv_pkg_dev_I__BatchReportId__c = 'aa', cv_pkg_dev_I__BucketAccountId__c = buck.Id, cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'aaa', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__Record_Type_Id_for_Rollups__c = rtypes.Id);
        insert cs2;              
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
        
        PageReference pageRef = Page.MatchTransaction;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', g1.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(g1);
        MatchingControllerExtension controller = new MatchingControllerExtension(std);
    
        controller.getPTypes();
        controller.getMonths();            
        controller.getYears();
        controller.createReceipt = true; 
        controller.theGift.Organization__c = a.Id;
        controller.Submit();       
        ApexPages.currentPage().getParameters().put('gdIndex', '1');           

    }
}