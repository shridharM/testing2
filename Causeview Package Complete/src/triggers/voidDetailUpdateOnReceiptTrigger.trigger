/*
This trigger updates the information for Receipt that has been Void. In this trigger we are updating the Receipt Status to Void, 
Receipt Custom Amount with Receipt Amount and removing the payment records relationship with receipt record.
*/
trigger voidDetailUpdateOnReceiptTrigger on Receipt__c (before insert, before update) {
    System.debug('trigger new==='+Trigger.new);
    set<Id> receiptIds = new set<Id>();
    Map<String, String> rtypes_Map = new Map<String, String>();
    for(RecordType recType : [Select r.Id, r.Name from RecordType r Where r.Name = 'Void' AND r.SobjectType = 'causeview__Receipt__c']){
        rtypes_Map.put(recType.Name, recType.Id);
    }
    for(causeview__Receipt__c r : Trigger.new){
        if(r.RecordTypeId == rtypes_Map.get('Void')){
            r.causeview__Status__c = 'Void';
            r.causeview__Amount_Receipted__c = r.causeview__Receipt_Amount__c;
            receiptIds.add(r.id);
        }
    }
    
    List<causeview__Payment__c> paymentRecords = [Select p.Id, p.causeview__Receipt__c from causeview__Payment__c p Where p.causeview__Receipt__c IN: receiptIds FOR UPDATE];
    if(paymentRecords.size() > 0){
        for(causeview__Payment__c p : paymentRecords){
            p.causeview__Receipt__c = null;
        }
        update paymentRecords;
    }
}