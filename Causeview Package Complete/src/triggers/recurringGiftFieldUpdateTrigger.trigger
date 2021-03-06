/* On the "Recurring Gift" record, display payment summary new fields:
1). Declined Payments (causeview__Declined_Payments__c):
    a). For All Transactions with Status = Active
    b). Count all Payments with Status = Declined
2). Consecutive Declined Payments (causeview__Consecutive_Declined_Payments__c)
    a). If last Payment.Status = Declined then 
    b). count all consecutive payment records with Status = Declined
3). Approved Payments (causeview__Approved_Payments__c)
    a). For All Transactions with Status = Active
    b). Count all Payments with Status = Approved
Trigger roll up Payment records for the most recent Active Transactions into "Recurring Gift" record.
*/
trigger recurringGiftFieldUpdateTrigger on Payment__c (after insert, after update, after delete) {
    
    if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c){    
        Set<Id> transactionIds = new Set<Id>();
        Set<Id> recurringGiftIds = new Set<Id>();
        Set<Id> transctionsIds = new Set<Id>();
         
         
        Map<Id, Map<Id, List<causeview__Payment__c>>> recurringGiftMap = new Map<Id, Map<Id, List<causeview__Payment__c>>>();
        if(Trigger.isInsert || Trigger.isUpdate){    // check Condition if inserting new payment record or updating existing payment record
            for(Payment__c payment : Trigger.new){
                // check condition wheather the payment status is 'Approved' or 'Declined' or status was 'Approved' or 'Declined'
                if(Trigger.isInsert && (payment.causeview__Status__c == 'Approved' || payment.causeview__Status__c == 'Declined') ){
                    
                    transactionIds.add(payment.causeview__Donation__c); //adding Gift ID into set of Id type
                    
                }
                if(Trigger.isUpdate && payment.causeview__Status__c <> Trigger.oldMap.get(payment.id).causeview__Status__c && (payment.causeview__Status__c == 'Approved' || payment.causeview__Status__c == 'Declined' || Trigger.oldMap.get(payment.id).causeview__Status__c == 'Approved' || Trigger.oldMap.get(payment.id).causeview__Status__c == 'Declined')){
                   
                    transactionIds.add(payment.causeview__Donation__c); //adding Gift ID into set of Id type
                    
                }
            } 
        }   
        if(Trigger.isDelete){    // Condition to check if deleting a payment record
            for(Payment__c payment : Trigger.old){
                if(payment.causeview__Status__c == 'Approved' || payment.causeview__Status__c == 'Declined'){ // check condition wheather the payment status is 'Approved' or 'Declined'
                    transactionIds.add(payment.causeview__Donation__c);    //adding Gift Id into set of Id type
                    system.debug('transactionIds==>'+transactionIds);
                }
            } 
        } 
        
       
        
        if(transactionIds.size() > 0){
     
            
            if(recurringGiftFieldUpdateTriggerclass.CanUseFutureContext()){         
                recurringGiftFieldUpdateTriggerclass.recurringGiftFieldUpdateForFuture(transactionIds);
            }
            else{
                recurringGiftFieldUpdateTriggerclass.recurringGiftFieldUpdate(transactionIds);
            }
        }
    }    
}