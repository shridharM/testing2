/*
* @author Nitin Khunal
* @date 20/10/2014
* @Trigger to update Transaction Status when consolidated receipt is created
* @description Trigger to update Transaction Status to "Acknowledged" when consolidated receipt is created and has a status of "Issued".
*/
trigger consolidatedReceiptStatusUpdateOnGift on Receipt__c (after insert) {
    set<Id> giftIds = new Set<Id>();
    List<Gift__c> giftListToUpdate = new List<Gift__c>();
    for(Receipt__c r : Trigger.New){
        if(r.Receipt_Type__c == 'Consolidated' && r.Status__c == 'Issued'){
            giftIds.add(r.Gift__c);
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
    for(Receipt__c r : Trigger.New){
        paymentsToBeUpdated = [select cv_pkg_dev_I__Receipt__c, cv_pkg_dev_I__Amount__c from payment__c where Donation__c=: r.Gift__c];
        
        if(paymentsToBeUpdated.size()==1){
            for(payment__c p :paymentsToBeUpdated){
                if(p.cv_pkg_dev_I__Amount__c == r.cv_pkg_dev_I__Receipt_Amount__c && p.cv_pkg_dev_I__Receipt__c ==null && r.cv_pkg_dev_I__Receipt_Type__c !='Void'){
                    system.debug('--p.cv_pkg_dev_I__Receipt__c----'+p.cv_pkg_dev_I__Receipt__c);
                    p.cv_pkg_dev_I__Receipt__c = r.id;
                    system.debug('--p.cv_pkg_dev_I__Receipt__c----'+p.cv_pkg_dev_I__Receipt__c);
                }
            }           
            update paymentsToBeUpdated;
            system.debug('--p.cv_pkg_dev_I__Receipt__c----'+paymentsToBeUpdated[0].id);
            
        }
        break;
    }
    
    //till here
    
    
}