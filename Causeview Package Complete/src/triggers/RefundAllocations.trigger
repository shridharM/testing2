trigger RefundAllocations on Payment__c (after insert) {  
    Set<String> refundedPaymentIds = new Set<String>();
    Set<String> refundPaymentIds = new Set<String>();    
    Map<String, List<Gift_Detail__c>> payment_to_allocations = new Map<String, List<Gift_Detail__c>>();
    Map<String, Decimal> payment_to_amount = new Map<String, Decimal>();    
    List<Gift_Detail__c> allocationsToInsert = new List<Gift_Detail__c>();
    
    for (Payment__c p : Trigger.new)
    {
        if (p.Payment_Refunded__c == null || p.Status__c != 'Refunded')
        { continue; }
        
        refundPaymentIds.add(p.Id);
        refundedPaymentIds.add(p.Payment_Refunded__c);
    }
    system.debug('Nitin++'+refundedPaymentIds);
    if (refundPaymentIds.size() == 0 || refundedPaymentIds.size() == 0) { return; }
    RollupHelper.RefundAllocationsMethod(refundedPaymentIds, refundPaymentIds);
    //commented by nitin
    /*List<Gift_Detail__c> allocations = [SELECT Allocation_Date__c, Gift__c, Tribute__c, Product__c, New_Campaign__c, Fund__c, Payment__c, Amount__c FROM Gift_Detail__c WHERE Payment__c IN :refundedPaymentIds];
    List<Payment__c> refundedPayments = [SELECT Amount__c, Id, Payment_Refunded__c FROM Payment__c WHERE Id IN :refundedPaymentIds];    
    List<Payment__c> refundPayments = [SELECT Amount__c, Id, Payment_Refunded__c FROM Payment__c WHERE Id IN :refundPaymentIds];       
    List<Gift_Detail__c> bufferAllocations = new List<Gift_Detail__c>();   
    system.debug('Nitin++'+refundedPayments);
    for (Payment__c p : refundedPayments)
    {
        bufferAllocations = new List<Gift_Detail__c>();
        for (Gift_Detail__c gd : allocations)
        {
            if (p.Id == gd.Payment__c)
            bufferAllocations.add(gd);
        }
        payment_to_allocations.put(p.Id, bufferAllocations);
        payment_to_amount.put(p.Id, p.Amount__c);
    }   
    system.debug('Nitin++'+payment_to_amount);
    Gift_Detail__c bufferGiftDetail = new Gift_Detail__c();
    
    for (Payment__c p : refundPayments)
    {        
        for (Gift_Detail__c gd : payment_to_allocations.get(p.Payment_Refunded__c))
        {
            bufferGiftDetail = new Gift_Detail__c();
            bufferGiftDetail.Payment__c = p.Id;
            bufferGiftDetail.Allocation_Date__c = Date.Today();
            bufferGiftDetail.New_Campaign__c = gd.New_Campaign__c;
            bufferGiftDetail.Gift__c = gd.Gift__c;
            bufferGiftDetail.Tribute__c = gd.Tribute__c;
            bufferGiftDetail.Product__c = gd.Product__c;
            bufferGiftDetail.Fund__c = gd.Fund__c;
            bufferGiftDetail.Amount__c = (p.Amount__c * (gd.Amount__c/payment_to_amount.get(p.Payment_Refunded__c)));
            allocationsToInsert.add(bufferGiftDetail);
        }
    }
    system.debug('allocationsToInsert:=>'+allocationsToInsert);
    insert allocationsToInsert;*/
}