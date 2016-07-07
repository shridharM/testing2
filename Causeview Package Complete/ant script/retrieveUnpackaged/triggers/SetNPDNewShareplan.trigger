trigger SetNPDNewShareplan on Gift__c (after insert) {
    /*List<Gift__c> theGifts = [SELECT Id, Next_Payment_Date__c, Withdrawl_Day__c 
                                FROM Gift__c WHERE Id IN : Trigger.newmap.keyset() 
                                               AND Status__c = 'Active'
                                               AND Recurring_Donation__c != ''];
                                                       
    for (Gift__c g : theGifts)
    { 
        if (Integer.valueOf(g.Withdrawl_Day__c) == null)
        { g.Next_Payment_Date__c = Date.newInstance(Date.Today().Year(), Date.Today().Month() + 1, 1); }
        else
        { g.Next_Payment_Date__c = Date.newInstance(Date.Today().Year(), Date.Today().Month() + 1, Integer.valueOf(g.Withdrawl_Day__c)); }
    }    
    
    update theGifts;*/
}