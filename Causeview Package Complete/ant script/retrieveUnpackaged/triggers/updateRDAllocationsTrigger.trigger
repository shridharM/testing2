/*
    
    When a recurring donation is updated and the amount is different, update the new amount to each allocation
    
    percentage = allocation.Value / donation.OldAmount;
    
    allocation.Value = donation.NewAmout * percentage;
    
*/

trigger updateRDAllocationsTrigger on cv_pkg_dev_I__Recurring_Donation__c (after update) {
/*    
    Set<String> donationIDs = new Set<String>();        
    
    for(cv_pkg_dev_I__Recurring_Donation__c donation: trigger.new){
        
        cv_pkg_dev_I__Recurring_Donation__c oldDonation = (cv_pkg_dev_I__Recurring_Donation__c)Util.FindObject(trigger.old, donation.Id, 'Id');
                
        if(donation.cv_pkg_dev_I__Amount__c != oldDonation.cv_pkg_dev_I__Amount__c)
            donationIDs.add(donation.Id);       
    }
    
    List<cv_pkg_dev_I__RD_Allocation__c> allocations = [SELECT id, cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__Recurring_Gift__c FROM cv_pkg_dev_I__RD_Allocation__c WHERE cv_pkg_dev_I__Recurring_Gift__c IN :donationIDs];
    
    
    // loop through the donations, and if there's a change in amount, reassign the amount of the allocations to the new percentages
    for(cv_pkg_dev_I__Recurring_Donation__c donation: trigger.new){
        
        cv_pkg_dev_I__Recurring_Donation__c oldDonation = (cv_pkg_dev_I__Recurring_Donation__c)Util.FindObject(trigger.old, donation.Id, 'Id');
        
            for(cv_pkg_dev_I__RD_Allocation__c allocation : allocations){
                
                // for every allocation related to this donation, assign the new amount 
                if(allocation.cv_pkg_dev_I__Recurring_Gift__c == donation.Id){
                    
                    if(allocation.cv_pkg_dev_I__Amount__c != null && oldDonation.cv_pkg_dev_I__Amount__c != null){
                        Double percentage = allocation.cv_pkg_dev_I__Amount__c / oldDonation.cv_pkg_dev_I__Amount__c; 
                        allocation.cv_pkg_dev_I__Amount__c = donation.cv_pkg_dev_I__Amount__c * percentage;
                    }
                }
            }       
    }
    
    update allocations; 
    */
}