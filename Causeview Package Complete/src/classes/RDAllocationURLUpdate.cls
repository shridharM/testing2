public with sharing class RDAllocationURLUpdate {
    public string gateway{get;set;}

    public RDAllocationURLUpdate(ApexPages.StandardController stdController) {
    gateway = ''; 
    list<causeview__Gift__c> Gifts;
    list<causeview__RD_Allocation__c>  RGiftsAllocations = [select causeview__Recurring_Gift__r.id from causeview__RD_Allocation__c where id =: stdController.getRecord().id];
    if(RGiftsAllocations.size()>0){
        Gifts = [Select Id, causeview__Gateway__c From causeview__Gift__c where causeview__Recurring_Donation__c =: RGiftsAllocations[0].causeview__Recurring_Gift__r.id  order by CreatedDate Desc Limit 1]; 
    }
    if(Gifts.size()>0){    
        gateway = Gifts[0].causeview__Gateway__c; 
    }        
        
    
    }
}