trigger AutoNum on Account (before insert) {
    /*if (!Test.isRunningTest()) {
        try
        {
            cv_pkg_dev_I__aNums__c s = cv_pkg_dev_I__aNums__c.getInstance('Default');
    
            for (Account a : Trigger.new)
            {
                if (a.cv_pkg_dev_I__Organization_ID__c == null)
                {                
                    String prefix = '';
                    if (String.valueOf(s.cv_pkg_dev_I__OrgCount__c).length() < s.cv_pkg_dev_I__OrgLength__c)
                    {            
                        for (Integer i = 0; i < (s.cv_pkg_dev_I__OrgLength__c - String.valueOf(s.cv_pkg_dev_I__OrgCount__c).length()); i++)
                        { prefix+= '0'; }            
                    }
                    a.cv_pkg_dev_I__Organization_ID__c = s.cv_pkg_dev_I__OrgPrefix__c + prefix + String.valueOf(s.cv_pkg_dev_I__OrgCount__c);
                    s.cv_pkg_dev_I__OrgCount__c++;
                }
            }
            update s;
        }
        catch (Exception ex)
        { Trigger.new[0].addError('Your Custom Settings must define the Organizational Counts before you can create records.'); return; }
    }            */
}