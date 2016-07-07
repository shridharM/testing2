@isTest
public class EventIdUpdateOnGiftTriggerTest{
    public testMethod static void EventIdUpdateOnGiftTriggerTest(){
        RecordType eventType = [Select Name, Id From RecordType where Name = 'Event' AND NamespacePrefix = 'causeview' LIMIT 1];  
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];
        
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;     
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
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
        
        //System.assertEquals(g.causeview__Event_Id__c,gd.causeview__New_Campaign__c);
    } 
}