trigger AssignToApps on Volunteer_Shift__c (before insert) {
    //collect Ids
    Set<string> vpIds = new Set<string>();
    Map<String, String> vp_to_app = new Map<String, String>();
    
    for (Volunteer_Shift__c vps : Trigger.new)
    {
        vpIds.add(vps.Volunteer_Role__c);
    }
    
    //map Position to App (first or default) 
    List<Volunteer_Role__c> vol_pos = [SELECT Id, (SELECT Id FROM Volunteer_Applications__r WHERE Status__c = 'Placed') FROM Volunteer_Role__c WHERE Id IN: vpIds];
    for (Volunteer_Role__c vp : vol_pos)
    {
        if (vp.Volunteer_Applications__r.size() > 0)
        {
            vp_to_app.put(vp.Id, vp.Volunteer_Applications__r[0].Id);    
        }
    }
    
    //assign app to Shift's app lookup
    for (Volunteer_Shift__c vps : Trigger.new)
    {
        vps.Volunteer_Application__c = vp_to_app.get(vps.Volunteer_Role__c);
    }
}