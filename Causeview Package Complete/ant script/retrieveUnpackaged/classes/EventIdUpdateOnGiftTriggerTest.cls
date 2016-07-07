@isTest
public class EventIdUpdateOnGiftTriggerTest{
    public testMethod static void EventIdUpdateOnGiftTriggerTest(){
        RecordType eventType = [Select Name, Id From RecordType where Name = 'Event' AND NamespacePrefix = 'causeview' LIMIT 1];  
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];
        
        cv_pkg_dev_I__aNums__c cs1 = new cv_pkg_dev_I__aNums__c( Name = 'Default', cv_pkg_dev_I__OrgPrefix__c = 'ORG', cv_pkg_dev_I__OrgLength__c = 8, cv_pkg_dev_I__OrgCount__c = 1, cv_pkg_dev_I__ContactPrefix__c = 'CON', cv_pkg_dev_I__ContactLength__c = 8, cv_pkg_dev_I__ContactCount__c = 1);
        insert cs1; 
        
        cv_pkg_dev_I__FormSettings__c fs1 = new cv_pkg_dev_I__FormSettings__c( Name = 'Default', cv_pkg_dev_I__Contact__c = 'TBD', cv_pkg_dev_I__Donation__c = 'TBD', cv_pkg_dev_I__RSVP__c = 'TBD', cv_pkg_dev_I__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
    
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        insert g;
      
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Check';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Pending';
        p1.Donation__c = g.Id;
        insert p1;
        
        Campaign camp = new Campaign();
        camp.RecordTypeId = eventType.id;
        camp.Name = 'sss';
        insert camp;
        
        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 50;
        insert elev;    
      
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        insert gd; 
    } 
}