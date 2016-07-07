trigger CloneTrigger on cv_pkg_dev_I__Payment__c (after insert) {
    if (trigger.new.size()>1) return;
    
    list<cv_pkg_dev_I__Payment__c> payments = [Select Id, c.cv_pkg_dev_I__Amount__c, c.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Sys_Clone_Transaction__c, 
       c.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Amount__c, c.cv_pkg_dev_I__Donation__c 
       From cv_pkg_dev_I__Payment__c c where Id=:trigger.new[0].Id];
    if (payments==null || payments.size()<=0) return;
    
    cv_pkg_dev_I__Payment__c newPayment = payments[0];
    cv_pkg_dev_I__Gift__c gift = newPayment.cv_pkg_dev_I__Donation__r;
    if (gift==null || gift.cv_pkg_dev_I__Sys_Clone_Transaction__c==null) return;
    
    List<cv_pkg_dev_I__Gift__c> gifts = [Select c.cv_pkg_dev_I__Amount__c, c.Id, 
      (Select Name, cv_pkg_dev_I__Allocation_Date__c, cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__Appeal_Name__c, 
      cv_pkg_dev_I__Approved_Amount__c, cv_pkg_dev_I__Campaign__c, cv_pkg_dev_I__Constituent__c, 
      cv_pkg_dev_I__Description__c, cv_pkg_dev_I__Fund_Name__c, cv_pkg_dev_I__Fund__c, cv_pkg_dev_I__Gift__c, 
      cv_pkg_dev_I__Organization__c, cv_pkg_dev_I__Payment__c, cv_pkg_dev_I__Percent_Allocation__c, 
      cv_pkg_dev_I__Product__c, cv_pkg_dev_I__Tribute__c, cv_pkg_dev_I__Gift_Type__c, 
      cv_pkg_dev_I__New_Campaign__c, cv_pkg_dev_I__Parent_Appeal__c, cv_pkg_dev_I__Custom_Allocation_Text__c, 
      cv_pkg_dev_I__Posted_to_Finance__c, cv_pkg_dev_I__Package__c, cv_pkg_dev_I__GL_Code__c, 
      cv_pkg_dev_I__GL_Debit_Account__c, cv_pkg_dev_I__GL_Credit_Account__c 
      From cv_pkg_dev_I__Gift_Allocations__r) 
      From cv_pkg_dev_I__Gift__c c where Id = :gift.cv_pkg_dev_I__Sys_Clone_Transaction__c];
      
    if (gifts==null || gifts.size()<=0) return;
    
    List<cv_pkg_dev_I__Gift_Detail__c> details = gifts[0].cv_pkg_dev_I__Gift_Allocations__r;
    //[SELECT id FROM cv_pkg_dev_I__Gift_Detail__c where cv_pkg_dev_I__Gift__c = :gift.cv_pkg_dev_I__Sys_Clone_Transaction__c];
    if (details==null || details.size()<=0) return;
    
    List<cv_pkg_dev_I__Gift_Detail__c> newOnes = new List<cv_pkg_dev_I__Gift_Detail__c>();
    for(cv_pkg_dev_I__Gift_Detail__c giftDetail : details)
    {
        cv_pkg_dev_I__Gift_Detail__c item = giftDetail.clone();
        
        item.cv_pkg_dev_I__Gift__c = gift.Id;
        if (newPayment.cv_pkg_dev_I__Amount__c!=gifts[0].cv_pkg_dev_I__Amount__c) {
            //amount is different, use radio
            item.cv_pkg_dev_I__Amount__c = (newPayment.cv_pkg_dev_I__Amount__c * giftDetail.cv_pkg_dev_I__Amount__c) / gifts[0].cv_pkg_dev_I__Amount__c;
        }
        item.cv_pkg_dev_I__Payment__c = trigger.new[0].id;
        newOnes.add(item);
    }
    
    insert newOnes;
    
}