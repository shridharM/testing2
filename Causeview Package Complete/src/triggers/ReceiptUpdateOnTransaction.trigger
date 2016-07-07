trigger ReceiptUpdateOnTransaction on Gift__c (after Update) {
    
    if(!Validator_cls.isAlreadyModifiedforReceiptUpdateOnTransaction()){
    Validator_cls.setAlreadyModifiedforReceiptUpdateOnTransaction();

  Map<Id,Gift__c> o = new Map<Id,Gift__c>();
    o = trigger.oldMap;
 
  Map<Id,Gift__c> newGiftMap = new Map<Id,Gift__c>(); 
   for(Gift__c n : trigger.new)
    {
        Gift__c old = o.get(n.Id);
        if(n.Letter__c != old.Letter__c && old !=null )
        {
            newGiftMap.put(n.Id,n);
        }
    }
    List<Receipt__c> receiptListToUpdate = new List<Receipt__c>();

  
   if(newGiftMap.size()>0) 
   {
   
    /* Map<Id, Gift__c > lettersUpdated = new Map<Id, Gift__c>(
        [Select Id, Letter__r.Introduction_Text_Block_Rich_Text__c, Letter__r.Custom_Rich_Text_1__c, Letter__r.Custom_Rich_Text_2__c, Letter__r.Custom_Rich_Text_3__c, Letter__r.Email_Subject__c, Letter__r.Text_Block__c, Letter__r.Signature_Rich_Text__c FROM Gift__c WHERE Id in :newGiftMap.keyset()]);*/
   
  
   
     for(Receipt__c updateReceipt : [SELECT Id, Gift__r.Id, Gift__r.Letter__r.Introduction_Text_Block_Rich_Text__c, Gift__r.Letter__r.Custom_Rich_Text_1__c, Gift__r.Letter__r.Custom_Rich_Text_2__c, Gift__r.Letter__r.Custom_Rich_Text_3__c, Gift__r.Letter__r.Email_Subject__c, Gift__r.Letter__r.Text_Block__c, Gift__r.Letter__r.Signature_Rich_Text__c, Introduction_Text_Block_Rich_Text__c ,Custom_Rich_Text_3__c,Custom_Rich_Text_2__c,Custom_Rich_Text_1__c,Email_Subject__c, Body_Text_Block_Rich_Text__c,Signature_Rich_Text__c ,gift__c FROM Receipt__c where Receipt__c.Gift__c in :newGiftMap.keyset() FOR UPDATE])
       {       
         
         updateReceipt.Introduction_Text_Block_Rich_Text__c = updateReceipt.Gift__r.Letter__r.Introduction_Text_Block_Rich_Text__c;
         updateReceipt.Body_Text_Block_Rich_Text__c = updateReceipt.Gift__r.Letter__r.Text_Block__c;
         updateReceipt.Signature_Rich_Text__c = updateReceipt.Gift__r.Letter__r.Signature_Rich_Text__c;
          
         updateReceipt.Email_Subject__c = updateReceipt.Gift__r.Letter__r.Email_Subject__c;
 
 
         updateReceipt.Custom_Rich_Text_1__c = updateReceipt.Gift__r.Letter__r.Custom_Rich_Text_1__c;
         updateReceipt.Custom_Rich_Text_2__c = updateReceipt.Gift__r.Letter__r.Custom_Rich_Text_2__c;
         updateReceipt.Custom_Rich_Text_3__c = updateReceipt.Gift__r.Letter__r.Custom_Rich_Text_3__c; 
       //update updateReceipt;
       receiptListToUpdate.add(updateReceipt);
       }
       if(receiptListToUpdate.size() > 0) update receiptListToUpdate;
   }
   }
}