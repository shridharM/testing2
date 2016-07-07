trigger CloneTrigger on causeview__Payment__c (after insert) {
    if (trigger.new.size()>1) return;
    
    list<causeview__Payment__c> payments = [Select Id, c.causeview__Amount__c, c.causeview__Donation__r.causeview__Sys_Clone_Transaction__c, 
       c.causeview__Donation__r.causeview__Amount__c, c.causeview__Donation__c 
       From causeview__Payment__c c where Id=:trigger.new[0].Id];
    if (payments==null || payments.size()<=0) return;
    
    causeview__Payment__c newPayment = payments[0];
    causeview__Gift__c gift = newPayment.causeview__Donation__r;
    if (gift==null || gift.causeview__Sys_Clone_Transaction__c==null) return;
    
    List<causeview__Gift__c> gifts = [Select c.causeview__Amount__c, c.Id, 
      (Select Name, causeview__Allocation_Date__c, causeview__Amount__c, causeview__Appeal_Name__c, 
      causeview__Approved_Amount__c, causeview__Campaign__c, causeview__Constituent__c, 
      causeview__Description__c, causeview__Fund_Name__c, causeview__Fund__c, causeview__Gift__c, 
      causeview__Organization__c, causeview__Payment__c, causeview__Percent_Allocation__c, 
      causeview__Product__c, causeview__Tribute__c, causeview__Gift_Type__c, 
      causeview__New_Campaign__c, causeview__Parent_Appeal__c, causeview__Custom_Allocation_Text__c, 
      causeview__Posted_to_Finance__c, causeview__Package__c, causeview__GL_Code__c, 
      causeview__GL_Debit_Account__c, causeview__GL_Credit_Account__c 
      From causeview__Gift_Allocations__r) 
      From causeview__Gift__c c where Id = :gift.causeview__Sys_Clone_Transaction__c];
      
    if (gifts==null || gifts.size()<=0) return;
    
    List<causeview__Gift_Detail__c> details = gifts[0].causeview__Gift_Allocations__r;
    //[SELECT id FROM causeview__Gift_Detail__c where causeview__Gift__c = :gift.causeview__Sys_Clone_Transaction__c];
    if (details==null || details.size()<=0) return;
    
    List<causeview__Gift_Detail__c> newOnes = new List<causeview__Gift_Detail__c>();
    for(causeview__Gift_Detail__c giftDetail : details)
    {
        causeview__Gift_Detail__c item = giftDetail.clone();
        
        item.causeview__Gift__c = gift.Id;
        if (newPayment.causeview__Amount__c!=gifts[0].causeview__Amount__c) {
            //amount is different, use radio
            item.causeview__Amount__c = (newPayment.causeview__Amount__c * giftDetail.causeview__Amount__c) / gifts[0].causeview__Amount__c;
        }
        item.causeview__Payment__c = trigger.new[0].id;
        newOnes.add(item);
    }
    
    insert newOnes;
    
}