public class RDAllocationURLUpdate {
    public string gateway{get;set;}

    public RDAllocationURLUpdate(ApexPages.StandardController stdController) {
    gateway = ''; 
    list<cv_pkg_dev_I__Gift__c> Gifts;
    list<cv_pkg_dev_I__RD_Allocation__c>  RGiftsAllocations = [select cv_pkg_dev_I__Recurring_Gift__r.id from cv_pkg_dev_I__RD_Allocation__c where id =: stdController.getRecord().id];
    if(RGiftsAllocations.size()>0){
        Gifts = [Select Id, cv_pkg_dev_I__Gateway__c From cv_pkg_dev_I__Gift__c where cv_pkg_dev_I__Recurring_Donation__c =: RGiftsAllocations[0].cv_pkg_dev_I__Recurring_Gift__r.id  order by CreatedDate Desc Limit 1]; 
    }
    if(Gifts.size()>0){    
        gateway = Gifts[0].cv_pkg_dev_I__Gateway__c; 
    }        
        
    
    }
}