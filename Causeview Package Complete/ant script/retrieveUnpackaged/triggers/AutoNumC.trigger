trigger AutoNumC on Contact (before insert) {
    /*if (!Test.isRunningTest()) {
        try
        {      
            cv_pkg_dev_I__aNums__c s = cv_pkg_dev_I__aNums__c.getInstance('Default');
        
            if (s == null)
                return;
                
            for (Contact c : Trigger.new)
            {
                if (c.cv_pkg_dev_I__Constituent_ID__c == null)            
                {        
                    String prefix = '';
                    if (String.valueOf(s.cv_pkg_dev_I__ContactCount__c).length() < s.cv_pkg_dev_I__ContactLength__c)
                    {            
                        for (Integer i = 0; i < (s.cv_pkg_dev_I__ContactLength__c - String.valueOf(s.cv_pkg_dev_I__ContactCount__c).length()); i++)
                        { prefix+= '0'; }            
                    }        
                    c.cv_pkg_dev_I__Constituent_ID__c = s.cv_pkg_dev_I__ContactPrefix__c + prefix + String.valueOf(s.cv_pkg_dev_I__ContactCount__c);
                    s.cv_pkg_dev_I__ContactCount__c++;
                }
            }
            update s;
        }
        catch (Exception ex)
        { Trigger.new[0].addError('Your Custom Settings must define the Individual Counts before you can create records.'); return; }    
    }    */
}