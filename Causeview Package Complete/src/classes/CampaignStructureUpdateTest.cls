@isTest
public class CampaignStructureUpdateTest{
    public static testMethod void CampaignStructureUpdateBatchScheduleTest(){
        CampaignStructureUpdateBatchSchedule d = new CampaignStructureUpdateBatchSchedule();
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex111111111', CRON_EXP, d );
    }
    
    public static testMethod void CampaignStructureUpdateBatchTest(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        causeview__aNums__c cs1 = GLAllocationfieldUpdateTriggerTest.anumsSettings();

        causeview__FormSettings__c fs1 = GLAllocationfieldUpdateTriggerTest.formSettings();    
        
        causeview__App_Settings__c appSetting = GLAllocationfieldUpdateTriggerTest.appSettings();
        
        Account a = GLAllocationfieldUpdateTriggerTest.acc();

        causeview__BatchSettings__c cs2 = GLAllocationfieldUpdateTriggerTest.batchSettings();        

        Contact c = GLAllocationfieldUpdateTriggerTest.con();
        Fund__c f = GLAllocationfieldUpdateTriggerTest.fundRecord();
        //Campaign cam = GLAllocationfieldUpdateTriggerTest.campaignRecord();
        //insert cam;
         Campaign camp = new Campaign(Name = 'Campaign', RecordTypeId = rtype_Map.get('Campaign'));
        insert camp;
        Campaign pAppeal = new Campaign(Name = 'Appeal', RecordTypeId = rtype_Map.get('Appeal'), ParentId = camp.Id);
        insert pAppeal;
        Campaign event = new Campaign(Name = 'Event', RecordTypeId = rtype_Map.get('Event'), ParentId = pAppeal.Id);
        insert event;
        Event_Level__c e = GLAllocationfieldUpdateTriggerTest.eventLevelRecord();
        e.Event__c = event.Id;
        insert e;
        
        Gift__c g= GLAllocationfieldUpdateTriggerTest.giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
      
        Payment__c p1 = GLAllocationfieldUpdateTriggerTest.paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = event.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        system.debug('Nitin gd1===='+gd1);
        
        event.ParentId = null;
        update event;
        
        Campaign pAppeal1 = new Campaign(Name = 'Appeal', RecordTypeId = rtype_Map.get('Appeal'), ParentId = camp.Id);
        insert pAppeal1;
        
        Campaign event1 = new Campaign(Name = 'Event', RecordTypeId = rtype_Map.get('Event'), ParentId = pAppeal.Id);
        insert event1;
        
        Event_Level__c e1 = GLAllocationfieldUpdateTriggerTest.eventLevelRecord();
        e1.Event__c = event1.Id;
        insert e1;
        
        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.New_campaign__c = event1.Id;
        gd2.Event_Level__c  = e1.Id;
        gd2.Gift__c = g.Id;
        gd2.Payment__c = p1.Id;
        gd2.Quantity__c = 50;
        gd2.Fund__c = f.id;
        insert gd2;
        
        event1.ParentId = pAppeal1.id;
        update event1;
        
        Database.executeBatch(new CampaignStructureUpdateBatch());
    }
    public static testMethod void CauseViewCustomSetting(){
        CauseViewCustomSetting d = new CauseViewCustomSetting();
        CauseViewCustomSetting.defaultANumSettings();
        CauseViewCustomSetting.defaultBatchSettings();
        CauseViewCustomSetting.defaultAppSettings();
        CauseViewCustomSetting.defaultAppTemplateSettings();
        CauseViewCustomSetting.updateSeachKey();
        //CauseViewCustomSetting.createObject('a','b','c');
        //CauseViewCustomSetting.getObjectId('a','b');
    }
}
