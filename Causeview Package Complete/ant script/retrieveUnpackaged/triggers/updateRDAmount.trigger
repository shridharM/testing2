trigger updateRDAmount on RD_Allocation__c (after update, after insert, after delete) {
    Set<ID> theRDsIDs = new Set<ID>();
    if (Trigger.isDelete)
    {
        for (RD_Allocation__c rda : Trigger.old)
        {
            theRDsIDs.add(rda.Recurring_Gift__c);
        }
    }
    if(Trigger.isUpdate || Trigger.isInsert)
    {
        for (RD_Allocation__c rda : Trigger.new)
        {
            theRDsIDs.add(rda.Recurring_Gift__c);
        }
    }    
    
    Decimal sum;
    List<Recurring_Donation__c> theRDs = [SELECT Id, Amount__c, (SELECT Amount__c,Recurring_Gift__c FROM Recurring_Gift_Allocations__r WHERE Active__c = True) FROM Recurring_Donation__c WHERE Id IN: theRDsIDs FOR UPDATE];
    for (Recurring_Donation__c rd : theRDs)
    {
        sum = 0;
        for (RD_Allocation__c rda : rd.Recurring_Gift_Allocations__r)
        {
            if (rda.Amount__c != null && rda.Amount__c != 0) {
                sum += rda.Amount__c;
            }
        }
        rd.Amount__c = sum;
    }
    update theRDs;
}