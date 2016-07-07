trigger AutoNumC on Contact (before insert) {
    /*if (!Test.isRunningTest()) {
        try
        {      
            causeview__aNums__c s = causeview__aNums__c.getInstance('Default');
        
            if (s == null)
                return;
                
            for (Contact c : Trigger.new)
            {
                if (c.causeview__Constituent_ID__c == null)            
                {        
                    String prefix = '';
                    if (String.valueOf(s.causeview__ContactCount__c).length() < s.causeview__ContactLength__c)
                    {            
                        for (Integer i = 0; i < (s.causeview__ContactLength__c - String.valueOf(s.causeview__ContactCount__c).length()); i++)
                        { prefix+= '0'; }            
                    }        
                    c.causeview__Constituent_ID__c = s.causeview__ContactPrefix__c + prefix + String.valueOf(s.causeview__ContactCount__c);
                    s.causeview__ContactCount__c++;
                }
            }
            update s;
        }
        catch (Exception ex)
        { Trigger.new[0].addError('Your Custom Settings must define the Individual Counts before you can create records.'); return; }    
    }    */
}