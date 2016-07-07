trigger updateActiveGiftAmount on Recurring_Donation__c (after update, after delete) {
    List <Gift__c> activeGifts = new List<Gift__c>();
    if(Trigger.isDelete)
        activeGifts = [SELECT Id, Expected_Amount__c, Recurring_Donation__r.Amount__c FROM Gift__c WHERE Recurring_Donation__c IN :Trigger.oldMap.keyset() AND Status__c = 'Active'];
    else
        activeGifts = [SELECT Id, Expected_Amount__c, Recurring_Donation__r.Amount__c FROM Gift__c WHERE Recurring_Donation__c IN :Trigger.newMap.keyset() AND Status__c = 'Active' FOR UPDATE];
    for (Gift__c g : activeGifts)
    {
        g.Expected_Amount__c = g.Recurring_Donation__r.Amount__c;
    }
    update activeGifts;
}