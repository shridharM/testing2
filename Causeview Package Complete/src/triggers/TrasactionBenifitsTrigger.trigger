trigger TrasactionBenifitsTrigger on causeview__Gift_Detail__c (after insert, after update, after delete, after undelete) {
     
     causeview__App_Settings__c appSetting = causeview__App_Settings__c.getInstance();
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
    
    
    if(appSetting.causeview__Gift_Aid_Enable__c)
    {
     if(Trigger.isafter){ 
        list<causeview__Payment__c  > paymentsToBeUpdated = new list<causeview__Payment__c >();
        decimal totalApprovedAmount=0;
        list<string> paymentIds = new list<string>();
        
        if(Trigger.isInsert  || Trigger.isupdate){
            for(causeview__Gift_Detail__c tempAllocation : trigger.new){
                paymentIds.add(tempAllocation.causeview__Payment__c);
            }
            paymentsToBeUpdated = [select Total_Gift_Aid_Eligible_Amount__c , name,Gift_Aid_Declaration__c, (select name, causeview__Approved_Amount__c from causeview__Allocations__r where Allocation_GA_Eligible__c =:True)  from causeview__Payment__c where id in : paymentIds and Gift_Aid_Declaration__c != null];
        }
        if(Trigger.isdelete ){
            for(causeview__Gift_Detail__c tempAllocation : trigger.old){
                paymentIds.add(tempAllocation.causeview__Payment__c);
            }
            paymentsToBeUpdated = [select Total_Gift_Aid_Eligible_Amount__c , name,Gift_Aid_Declaration__c, (select name, causeview__Approved_Amount__c from causeview__Allocations__r where Allocation_GA_Eligible__c =:True)  from causeview__Payment__c where id in : paymentIds and Gift_Aid_Declaration__c != null];
        }
        
        if(paymentsToBeUpdated.size()!=null){
            system.debug('--paymentsToBeUpdated----'+paymentsToBeUpdated.size());
            for(causeview__Payment__c tempPayment : paymentsToBeUpdated){
                totalApprovedAmount=0;           
                if(tempPayment.causeview__Allocations__r.size()>0){
                    system.debug('--tempPayment.causeview__Allocations__r.size()----'+tempPayment.causeview__Allocations__r.size());
                    for(causeview__Gift_Detail__c tempAllocation :  tempPayment.causeview__Allocations__r){
                        if(tempAllocation.causeview__Approved_Amount__c == null) {
                           totalApprovedAmount = 0;
                        }else {
                        totalApprovedAmount+=tempAllocation.causeview__Approved_Amount__c;}
                    }   
                }else{
                    totalApprovedAmount=0;
                }
                system.debug('--totalApprovedAmount----'+totalApprovedAmount);
                tempPayment.Total_Gift_Aid_Eligible_Amount__c=totalApprovedAmount;                    
            }       
        }    
        
        
        if(paymentsToBeUpdated.size() > 0){            
            update paymentsToBeUpdated;
        }
    }
    
}    }
