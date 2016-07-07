trigger TrasactionBenifitsTrigger on cv_pkg_dev_I__Gift_Detail__c (after insert, after update, after delete, after undelete) {
     
    if (Trigger.IsInsert) {    
        GiftDetailHandler.ManageTransactionBenefitsInsert(Trigger.new);   
        GiftDetailHandler.RollupTotals(Trigger.new);
    }
    
    if (Trigger.IsUpdate || Trigger.IsUndelete) {
        GiftDetailHandler.ManageTransactionBenefitsUpdate(Trigger.new, Trigger.old);   
        GiftDetailHandler.RollupTotals(Trigger.new);        
    }
    
    if (Trigger.IsDelete) {
        GiftDetailHandler.ManageTransactionBenefitsDelete(Trigger.old);           
        GiftDetailHandler.RollupTotals(Trigger.old);        
    }
}