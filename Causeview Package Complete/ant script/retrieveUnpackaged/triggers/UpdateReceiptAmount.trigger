/*Recalculate and update the associated Receipt Amount if,
    1. Payment Amount is updated,
    2. A payment is removed from a consolidated receipt and,
    3. A payment is added to a consolidated receipt.
*/
trigger UpdateReceiptAmount on Payment__c (after update, after insert) {
    Set<Id> receiptIds = new Set<Id>();

        //List all the Receipt Ids from the Updated Payment records (If a payment is updated or added to consolidated receipt).
    for (Payment__c payment : Trigger.new) {
        if(payment.Receipt__c != null) {
            receiptIds.add(payment.Receipt__c);
        }
    }

        //List all the Receipt Ids from the Payment records to be Updated (If a payment is removed from consolidated receipt).
    if(Trigger.isUpdate) {
        for (Payment__c payment : Trigger.old) {
            if(payment.Receipt__c != null) {
                receiptIds.add(payment.Receipt__c);
            }
        }
    }

   /*     //Query for Receipt records and the Payment records associated with each Receipt record to Recalculate Receipt Amount.
    List<Receipt__c> receiptsToUpdate = [Select Id, Amount_Receipted__c, (Select Id, Amount__c From Payments__r) From Receipt__c Where Id IN :receiptIds];

        //Recalculate Receipt Amount (Sum all the related Payment amounts and assign it to the Receipt amount).
    for (Receipt__c receipt : receiptsToUpdate) {
        //receipt.Amount_Receipted__c = 0;
        for (Payment__c payment : receipt.Payments__r) {
            if(payment.Amount__c != null) {
               receipt.Amount_Receipted__c = 0; 
                receipt.Amount_Receipted__c = receipt.Amount_Receipted__c ;//+ payment.Amount__c;
            }
        }
    }

    Update receiptsToUpdate;*/
}