@IsTest
public class TestCauseViewCustomSetting
{


 static testMethod  void testANumSettings()
 {
     CauseViewCustomSetting.defaultANumSettings();   
 }
 
 
 
  static testMethod  void testBatchSettings()
 {
     CauseViewCustomSetting.defaultBatchSettings();
 }
 
 
 
 static testMethod  void testAppSettings()
 {
     CauseViewCustomSetting.defaultAppSettings();
 }
 
 
 static testMethod  void testAppTemplateSettings()
 {
   CauseViewCustomSetting.defaultAppTemplateSettings();
 }
 
 static testMethod void testSearchKey(){
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
        
        CauseViewCustomSetting.updateSeachKey();
  }



}