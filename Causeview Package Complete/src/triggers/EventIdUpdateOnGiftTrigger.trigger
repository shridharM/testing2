/*
This trigger updates the Event_Id__c field on gift record with causeview__Gift_Detail__c.causeview__New_Campaign__c 
if causeview__Gift_Detail__c.causeview__New_Campaign__c = recordtype of Event
*/
trigger EventIdUpdateOnGiftTrigger on Gift_Detail__c (after insert, after update) {
    
    App_Settings__c settings = App_Settings__c.getInstance();
    Set<Id> appealId = new Set<Id>();   
    Set<Id> giftId = new Set<Id>();  
    Map<String, Id> rt_map = new Map<String, Id>();
    List<Gift__c> giftRecordsToUpdate = new List<Gift__c>();
    Set<Gift__c> setgiftRecordsToUpdate = new Set<Gift__c>();
    
    rt_map.put('Event', settings.Event_RecordType_Id__c);   
    
    for (Gift_Detail__c gd : Trigger.new)
    {
        appealId.add(gd.New_Campaign__c);
        giftId.add(gd.Gift__c);
    }
    
    if (appealId.size() > 0 && giftId.size() > 0)
    {
        Map<Id, Campaign> camp_map = new Map<Id, Campaign>([SELECT Id, RecordTypeId FROM Campaign WHERE Id IN : appealId]);
        Map<Id, Gift__c> gift_map = new Map<Id, Gift__c>([SELECT Id, Event_Id__c FROM Gift__c WHERE Id IN : giftId FOR UPDATE]);
        system.debug('camp_map==>'+camp_map);
        system.debug('gift_map==>'+gift_map);
        system.debug('rt_map==>'+rt_map);
        for(Gift_Detail__c gd : Trigger.new)
        {
             if(camp_map.get(gd.New_Campaign__c) != null && gift_map.get(gd.Gift__c) != null)   
             {
                  system.debug('RecordTypeId==>'+camp_map.get(gd.New_Campaign__c).RecordTypeId);
                  if(camp_map.get(gd.New_Campaign__c).RecordTypeId == rt_map.get('Event'))
                  {
                      system.debug('Gift==>'+gift_map.get(gd.Gift__c));
                      system.debug('appeal==>'+camp_map.get(gd.New_Campaign__c));
                      gift_map.get(gd.Gift__c).Event_Id__c = camp_map.get(gd.New_Campaign__c).id;
                      giftRecordsToUpdate.add(gift_map.get(gd.Gift__c));
                  }
             }
        }
        if(giftRecordsToUpdate.size() > 0){
            setgiftRecordsToUpdate.addAll(giftRecordsToUpdate);
            giftRecordsToUpdate.clear();
            giftRecordsToUpdate.addAll(setgiftRecordsToUpdate);
            update giftRecordsToUpdate;
        }
    }   
}