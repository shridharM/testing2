//To link all historical payment records to existing receipts.
//Update the Receipt__c field of all the historical payment records with respective receipt Ids.

global class linkPaymentsToReceiptsBatch implements Database.Batchable<sObject> {

    global Database.Querylocator start(Database.BatchableContext BC) {
            //Query All the Gift__c records associated with Payment__c records, where the associated Payment__c records having Receipt__c field as "null".
        String query = 'Select Id, (Select Id, Receipt__c, Status__c From Recurring_Payments__r Where Receipt__c = null AND Status__c = \'Approved\'), (Select Id From Receipts__r Where Status__c != \'Void\') From Gift__c Where Id IN (Select Donation__c From Payment__c Where Receipt__c = null AND Status__c = \'Approved\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
            // Extract all the Payment__c records, populate the Receipt__c fields and Update the Payment__c records.
        List<Payment__c> paymentsToUpdate = new List<Payment__c>();
        system.debug('<==inside execute==>'+scope.size());
        for(sObject each : scope) {
            Gift__c gift = (Gift__c)each;
            //Added by Nitin
            if(gift.Receipts__r != null && gift.Receipts__r.size() > 0 && gift.Recurring_Payments__r.size() > 0) {
                system.debug('gift==>'+gift.Recurring_Payments__r);
                for(Payment__c payment : gift.Recurring_Payments__r){
                    system.debug('gift==>'+payment);
                    payment.Receipt__c = gift.Receipts__r[0].Id;
                    paymentsToUpdate.add(payment);
                }
            }
        }
        if(paymentsToUpdate.size() > 0)
        Update paymentsToUpdate;
    }

    global void finish(Database.BatchableContext BC) {
    }
}