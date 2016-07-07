trigger creditDetailsUpdation on Receipt__c (before Insert) {

    if(trigger.isInsert) {
       
        Boolean paymentState = false;  
        set<Id> gids = new set<Id>();
        for (Receipt__c receipt: Trigger.New)
          {
              
              if( receipt.gift__r.Recurring_Payments__r  != null)
                gids.add(receipt.gift__c);
           }
    
    
    Map<Id,Gift__c > paymentDetails = new Map<Id, Gift__c >(
        [SELECT  Id, (SELECT Credit_Card_Number__c, Credit_Card_Type__c  FROM Recurring_Payments__r  WHERE Payment_Type__c = :'Credit Card' ORDER BY CreatedDate DESC NULLS Last Limit 1) FROM Gift__c WHERE ID IN :gids]);

    
    if(paymentDetails.size() >0)
    {
            
        for (Receipt__c receipt: Trigger.new)
        {  
        
            Id giftId = receipt.Gift__c;
            system.debug('------------giftId'+giftId);
            if(receipt.Gift__r.Recurring_Payments__r != null)
             {
                
                Gift__c GiftObj = paymentDetails.get(giftId);
                
                if(giftObj != null && GiftObj.Recurring_Payments__r.size() > 0)
                {
                 Payment__c paymentObj =  GiftObj.Recurring_Payments__r;
                receipt.Credit_Card__c= paymentObj.Credit_Card_Number__c;
                receipt.Credit_Card_Type__c = paymentObj .Credit_Card_Type__c;
            }    }
        }
    }
   }
}