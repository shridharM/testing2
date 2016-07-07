trigger UpdateNPDApprovedPayment on Payment__c (after insert) {
    /*List<Payment__c> thePayments = [SELECT Date__c, Donation__r.Next_Payment_Date__c, Donation__r.Last_Payment_Date__c, Donation__r.Recurring_Frequency__c, Donation__r.Withdrawl_Day__c, Donation__c, Status__c
                                    FROM Payment__c WHERE Id IN :Trigger.newmap.keyset()
                                                      AND Amount__c > 0
                                                      AND Date__c != NULL
                                                      AND (Status__c = 'Approved' OR Status__c = 'Deposited' OR Status__c = 'Declined')
                                                      AND Donation__r.Recurring_Donation__c != ''
                                                      AND Donation__r.Status__c = 'Active'];
                                                                     
    if (thePayments.size() > 0)
    {
        List<Gift__c> theGifts = new List<Gift__c>();
        for (Payment__c p : thePayments)
        {
            if (p.Donation__r.Withdrawl_Day__c != 0 || p.Donation__r.Withdrawl_Day__c != null)
            {
                if (p.Donation__r.Recurring_Frequency__c == 'Monthly')
                { p.Donation__r.Next_Payment_Date__c = Date.newInstance(Date.Today().Year(), Date.Today().Month() + 1, Integer.valueOf(p.Donation__r.Withdrawl_Day__c)); }
    
                if (p.Donation__r.Recurring_Frequency__c == 'Quarterly')
                { p.Donation__r.Next_Payment_Date__c = Date.newInstance(Date.Today().Year(), Date.Today().Month() + 3, Integer.valueOf(p.Donation__r.Withdrawl_Day__c)); }
    
                if (p.Donation__r.Recurring_Frequency__c == 'Annually')
                { p.Donation__r.Next_Payment_Date__c = Date.newInstance(Date.Today().Year() + 1, Date.Today().Month(), Integer.valueOf(p.Donation__r.Withdrawl_Day__c)); }
                
                if (p.Status__c == 'Approved' || p.Status__c == 'Deposited')
                { p.Donation__r.Last_Payment_Date__c = Date.Today(); }
                
                theGifts.add(p.Donation__r);
            }
            else
            {
                if (p.Donation__r.Recurring_Frequency__c == 'Monthly')
                { p.Donation__r.Next_Payment_Date__c = Date.newInstance(Date.Today().Year(), Date.Today().Month() + 1, 1); }
    
                if (p.Donation__r.Recurring_Frequency__c == 'Quarterly')
                { p.Donation__r.Next_Payment_Date__c = Date.newInstance(Date.Today().Year(), Date.Today().Month() + 3, 1); }
    
                if (p.Donation__r.Recurring_Frequency__c == 'Annually')
                { p.Donation__r.Next_Payment_Date__c = Date.newInstance(Date.Today().Year() + 1, Date.Today().Month(), 1); }
                
                if (p.Status__c == 'Approved' || p.Status__c == 'Deposited')
                { p.Donation__r.Last_Payment_Date__c = Date.Today(); }
                
                theGifts.add(p.Donation__r);
            }
        }
        update theGifts;
    }                                                                         */
}