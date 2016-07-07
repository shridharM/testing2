trigger AutoNum on Account (before insert) {
    /*if (!Test.isRunningTest()) {
        try
        {
            causeview__aNums__c s = causeview__aNums__c.getInstance('Default');
    
            for (Account a : Trigger.new)
            {
                if (a.causeview__Organization_ID__c == null)
                {                
                    String prefix = '';
                    if (String.valueOf(s.causeview__OrgCount__c).length() < s.causeview__OrgLength__c)
                    {            
                        for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(s.causeview__OrgCount__c).length()); i++)
                        { prefix+= '0'; }            
                    }
                    a.causeview__Organization_ID__c = s.causeview__OrgPrefix__c + prefix + String.valueOf(s.causeview__OrgCount__c);
                    s.causeview__OrgCount__c++;
                }
            }
            update s;
        }
        catch (Exception ex)
        { Trigger.new[0].addError('Your Custom Settings must define the Organizational Counts before you can create records.'); return; }
    }            */
}