trigger AccountTrigger on Account (after insert, after update, after delete, after undelete, before insert, before update, before delete) {
    cv_pkg_dev_I__App_Settings__c appSetting = cv_pkg_dev_I__App_Settings__c.getInstance();
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        System.debug('<==inside 1==>');
        OrgContactHandler.AutoNumber(Trigger.new, 'Account');
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        System.debug('<==inside 2==>');
        OrgContactHandler.PreventBucketModify(Trigger.old, Trigger.new);
    }        
    if (Trigger.isBefore && Trigger.isDelete) {
        System.debug('<==inside 3==>');
        OrgContactHandler.PreventBucketDelete(Trigger.old);
    }    
    if( Trigger.isAfter && Trigger.isDelete ){
        System.debug('<==inside 4==>');
        OrgRelationships.deleteEmptyRelationships();
    }    
    if (Trigger.isAfter && Trigger.isUpdate) {
        System.debug('<==inside 5==>');
        OrgContactHandler.CascadeHouseholdAddress(Trigger.old, Trigger.new);
    }
    //Added by Nitin - comment 
    if (Trigger.isAfter && Trigger.isUpdate) {
        System.debug('<==inside 6==>');
        if(appSetting.Other_Address_Trigger_Setting__c){
            OrgContactHandler.LegacyAddress(Trigger.old, Trigger.new, 'Account');  
        }      
    }
}