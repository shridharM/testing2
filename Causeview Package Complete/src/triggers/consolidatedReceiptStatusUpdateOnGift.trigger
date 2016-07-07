/*
* @author Nitin Khunal
* @date 20/10/2014
* @Trigger to update Transaction Status when consolidated receipt is created
* @description Trigger to update Transaction Status to "Acknowledged" when consolidated receipt is created and has a status of "Issued".
*/
trigger consolidatedReceiptStatusUpdateOnGift on Receipt__c (after insert) {
    set<Id> giftIds = new Set<Id>();
    set<Id> giftIdsForPayUpdate = new Set<Id>();
    List<Gift__c> giftListToUpdate = new List<Gift__c>();
    map<string, list<Receipt__c>> giftToReceipt = new map<string, list<Receipt__c>>();
    for(Receipt__c r : Trigger.New){
        if(r.Receipt_Type__c == 'Consolidated' && r.Status__c == 'Issued'){
            giftIds.add(r.Gift__c);
        }
        giftIdsForPayUpdate.add(r.Gift__c);
        system.debug('========='+r.Gift__c);
        if (giftToReceipt.containsKey(r.Gift__c)){
            giftToReceipt.get(r.Gift__c).add(r);
        }else{
            list<Receipt__c> tempRecList= new list<Receipt__c>();
            tempRecList.add(r);
            giftToReceipt.put(r.Gift__c, tempRecList);
        }
    }
    if(giftIds.size() > 0){
        Map<Id, Gift__c> gift_Record_Map = new Map<Id, Gift__c>([select Status__c from Gift__c where Id IN : giftIds]);
        for(Receipt__c r : Trigger.New){
            if(gift_Record_Map.get(r.Gift__c) != null){
                Gift__c gift = gift_Record_Map.get(r.Gift__c);
                gift.Status__c = 'Acknowledged';
                giftListToUpdate.add(gift);
            }
        }
        if(giftListToUpdate.size() > 0)
            update giftListToUpdate;
    }
    
    //shridhar- user story :-'The trigger to create the Receipt lookup on the Payment record does not work with the form submission;
    //this code is to just populate reciept in payment when gift is created by form submission
    
    
    list<payment__c> paymentsToBeUpdated = new list<payment__c>();
    if(giftIdsForPayUpdate.size()>0){
        paymentsToBeUpdated = [select causeview__Receipt__c, causeview__Donation__c, causeview__Amount__c from payment__c where Donation__c IN : giftIdsForPayUpdate];
    }
    if(paymentsToBeUpdated.size()>0){
            for(payment__c p :paymentsToBeUpdated){
                for(Receipt__c r : giftToReceipt.get(p.causeview__Donation__c)){
                    if(p.causeview__Amount__c == r.causeview__Receipt_Amount__c && p.causeview__Receipt__c ==null && r.causeview__Receipt_Type__c !='Void'){
                        system.debug('--p.causeview__Receipt__c----'+p.causeview__Receipt__c);
                        p.causeview__Receipt__c = r.id;
                        system.debug('--p.causeview__Receipt__c----'+p.causeview__Receipt__c);
                    }
                }
            }   
           update paymentsToBeUpdated; 
        }
         
    
    //till here
    
    
}