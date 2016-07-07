trigger OneActiveRD on Gift__c (before insert, before update) {
    /*Set<Id> RDIDs = new Set<Id>();
    
    //Scott Aug-08/11: capture the Recurring Donations
    for(Gift__c theGift : Trigger.new)
    {        
        if (theGift.Recurring_Donation__c != null)
        { RDIDs.add(theGift.Recurring_Donation__c); }        
    }  
    
    if (RDIDs.size() == 0)
        return;
    
    //Scott Aug-08/11: determine if each RD has an active gift
    List<Recurring_Donation__c> theRDs = [SELECT Id, (SELECT Id, Status__c FROM Orders__r) FROM Recurring_Donation__c WHERE Id IN :RDIDs];
    Map<Id, Boolean> RD_to_Actives = new Map<Id, Boolean>();
    for(Recurring_Donation__c rd : theRDs)
    {
        Boolean hasActives = false;
        for(Gift__c g : rd.Orders__r)
        {
            if(g.Status__c == 'Active')
            { hasActives = true; }
        }
        RD_to_Actives.put(rd.Id, hasActives);
    }
    
    //Scott Aug-08/11: error any active gifts onto RDs with an active gift already   
    if (Trigger.isInsert)
    {
        for (Gift__c theGift : Trigger.new)
        {
            if(theGift.Status__c == 'Active' && RD_to_Actives.get(theGift.Recurring_Donation__c))
            { theGift.Status__c.addError('There is already an Active Transaction for this Recurring Donation'); }
        }
    }
    if (Trigger.isUpdate)
    {
        List<Gift__c> oGifts = Trigger.old;
        List<Gift__c> nGifts = Trigger.new;
        for (Integer i = 0; i < Trigger.old.size(); i++)
        {
            if (nGifts[i].Status__c == 'Active' && oGifts[i].Status__c != 'Active' && RD_to_Actives.get(nGifts[i].Recurring_Donation__c))
            { nGifts[i].Status__c.addError('There is already an Active Transaction for this Recurring Donation'); }
        }
    }*/
}