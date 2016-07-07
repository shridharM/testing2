trigger UpdateNPDAfterCCUpdate on Recurring_Donation__c (after update) {
    /*List<Recurring_Donation__c> oRD = Trigger.old;
    List<Recurring_Donation__c> nRD = Trigger.new;    
    Set<Id> RDIDs = new Set<Id>();
    
    for (Integer i = 0; i < Trigger.old.size(); i++)
    {
        if (oRD[i].Credit_Card_Expiry_Date__c != nRD[i].Credit_Card_Expiry_Date__c)
        { RDIDs.add(nRd[i].Id); }
    }
    
    List<Gift__c> theGifts = [SELECT Id, Next_Payment_Date__c, Withdrawl_Day__c FROM Gift__c WHERE Recurring_Donation__c IN :RDIDs AND Status__c = 'Active'];
    
    for (Gift__c g : theGifts)
    {
        if (Date.Today() <= g.Next_Payment_Date__c)
        { continue; }
        
        if (Date.Today().Day() < Integer.valueOf(g.Withdrawl_Day__c))
        { g.Next_Payment_Date__c = Date.newInstance(Date.Today().Year(), Date.Today().Month(), Integer.valueOf(g.Withdrawl_Day__c)); }
        else
        { g.Next_Payment_Date__c = Date.newInstance(Date.Today().Year(), Date.Today().Month() + 1, Integer.valueOf(g.Withdrawl_Day__c)); }       
    }
    
    update theGifts;*/
}