trigger updateAllocationGAEligibleField on causeview__Fund__c (after update, after delete) {
   causeview__App_Settings__c appSetting = causeview__App_Settings__c.getInstance();
     if(appSetting.causeview__Gift_Aid_Enable__c) 
    {
    list<causeview__Gift_Detail__c > alloctionsTobeUpdated = new list<causeview__Gift_Detail__c >();
    list<causeview__Fund__c > fundsList = new list<causeview__Fund__c >();
    if(trigger.isUpdate || trigger.isDelete){
        fundsList = [select id, gift_Aid_Eligible__c , (select id  from causeview__Gift_Allocations__r) from causeview__Fund__c where id in : trigger.oldMap.keySet() ];
        for(causeview__Fund__c fundTemp : fundsList){
            for(causeview__Gift_Detail__c allocationTemp : fundTemp.causeview__Gift_Allocations__r ){
                 alloctionsTobeUpdated.add(allocationTemp);
            }
        }
   
    }
    
    
    
    if(alloctionsTobeUpdated.size()!=null){
            update alloctionsTobeUpdated;
        }
    }
}