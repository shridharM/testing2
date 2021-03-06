@isTest
class testHeirachyTrigger {
     static testMethod void testTrigger() {
        BatchSettings__c settings = new BatchSettings__c(Name = 'Default', RegularGiftRecordTypeId__c = '01pA0000003FY03', cv_pkg_dev_I__BatchFormID__c = '01pA0000003FY03', cv_pkg_dev_I__BatchReportId__c = '01pA0000003FY03', cv_pkg_dev_I__BucketAccountId__c = '01pA0000003FY03', cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');
        insert settings;
        List<RecordType> rts = [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview'];
        Map<String, Id> rt_map = new Map<String, Id>();
        
        for (RecordType rt : rts)
        {
        rt_map.put(rt.Name, rt.Id);
        }     
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rt_map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rt_map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rt_map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;   
        Campaign camp = new Campaign(Name = 'Campaign', RecordTypeId = rt_map.get('Campaign'));
        insert camp;
        Campaign pAppeal = new Campaign(Name = 'Appeal', RecordTypeId = rt_map.get('Appeal'), ParentId = camp.Id);
        insert pAppeal;
        Campaign event = new Campaign(Name = 'Event', RecordTypeId = rt_map.get('Event'), ParentId = pAppeal.Id);
        insert event;
        Account a = new Account(Name = 'sss');
        insert a;
        Gift__c g = new Gift__c(Organization__c = a.id);
        insert g;
        Payment__c p1 = new Payment__c(Donation__c = g.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;        
        Gift_Detail__c gd = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g.Id, New_Campaign__c = pAppeal.Id);
        insert gd;
        Gift_Detail__c gd2 = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g.Id, New_Campaign__c = event.Id);
        insert gd2;        
        List<Gift_Detail__c> gds = new List<Gift_Detail__c>();
        for (Integer i = 0; i < 100; i++)
        {
            gds.add(new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g.Id, New_Campaign__c = event.Id));
            gds.add(new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g.Id, New_Campaign__c = pAppeal.Id));            
        }
        insert gds;
     }
}