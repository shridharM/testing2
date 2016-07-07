trigger ContactTrigger on Contact (after insert, after update, after delete, after undelete, before insert, before update, before delete) {
    cv_pkg_dev_I__App_Settings__c appSetting = cv_pkg_dev_I__App_Settings__c.getInstance();
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        system.debug('<==Nitin Autonumber==>');
        OrgContactHandler.AutoNumber(Trigger.new, 'Contact');
    }
    if (Trigger.isBefore && Trigger.isInsert) { 
        system.debug('<==Nitin Inside Trigger.isBefore==>');
        OrgContactHandler.PopulateBucketAccount(Trigger.new);   
        OrgContactHandler.CreateHouseholdupdate(Trigger.new);   
    }
     
    if (Trigger.isBefore && Trigger.isUpdate) {
       // OrgContactHandler.PreventGuestModify(Trigger.old, Trigger.new);    
        OrgContactHandler.CreateHouseholdupdate(Trigger.new);    
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        if(appSetting.Other_Address_Trigger_Setting__c){
            OrgContactHandler.LegacyAddress(Trigger.old, Trigger.new, 'Contact');
        }        
    }
    if (Trigger.isAfter) {
        //OrgContactHandler.UpdateHouseholdRollups(Trigger.old, Trigger.new);
    }
   /* if (Trigger.isBefore && Trigger.isDelete) {
        OrgContactHandler.PreventGuestDelete(Trigger.old);
    }*/
}