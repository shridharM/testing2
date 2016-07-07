/*This trigger is to update credit card number and credit card type on 
Credit Card Number, credit card type field on Gift record. 
*/
trigger creditDetailUpdationOnGift on Payment__c (after Insert) {
    
    set<Id> giftIds = new set<Id>();
    Set<Gift__c> giftSet = new Set<Gift__c>();
    List<Gift__c> giftRecordsToUpdate = new List<Gift__c>();
    //adding gift id to giftIds if the cv_pkg_dev_I__Payment_Type__c == 'Credit Card' and cv_pkg_dev_I__Credit_Card_Number__c != null 
    //on insertion or updation of record
    if(Trigger.isInsert){
        for(Payment__c payment : Trigger.new){
            if(payment.cv_pkg_dev_I__Payment_Type__c == 'Credit Card' && payment.cv_pkg_dev_I__Credit_Card_Number__c != null){
                giftIds.add(payment.cv_pkg_dev_I__Donation__c);
            }
        }
    }
    //getting gift record into Map
    if(giftIds.size() > 0){
        RollupHelper.creditDetailUpdationOnGiftMethod(giftIds);
        //commented by nitin
        //List<Gift__c> giftRecords = new List<Gift__c>([SELECT  Id, cv_pkg_dev_I__Credit_Card_Number__c, cv_pkg_dev_I__Credit_Card_Type__c, (SELECT Credit_Card_Number__c, Credit_Card_Type__c, cv_pkg_dev_I__Donation__c  FROM Recurring_Payments__r  WHERE Payment_Type__c = :'Credit Card' ORDER BY CreatedDate DESC NULLS Last Limit 1) FROM Gift__c WHERE ID IN :giftIds]);
    }
    //Assigning credit card number and credit card type to gift
    /*if(giftRecords.size() >0)
    {   
        for(Gift__c gift : giftRecords)
        { 
            Payment__c paymentRecord = gift.Recurring_Payments__r;
            gift.cv_pkg_dev_I__Credit_Card_Number__c = paymentRecord.Credit_Card_Number__c;
            gift.cv_pkg_dev_I__Credit_Card_Type__c = paymentRecord.Credit_Card_Type__c;
            giftRecordsToUpdate.add(gift);
        }
    } 
    if(giftRecordsToUpdate.size() > 0){
        update giftRecordsToUpdate; 
    }*/
}