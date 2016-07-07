trigger SetTraining on Volunteer_Application__c (before insert) {
    Set<String> posIds = new Set<String>();  }  
 /*   for (Volunteer_Application__c va : Trigger.new)
    {
        posIds.add(va.Volunteer_Role__c);
    }
    Map<String, Volunteer_Role__c> posMap = new Map<String, Volunteer_Role__c>([SELECT Id, Training_Provided__c FROM Volunteer_Role__c WHERE Id IN :posIds]);
    for (Volunteer_Application__c va : Trigger.new)
    {
        if (va.RecordTypeId != '012d0000000siPV') { continue; }
        Set<String> selected = new Set<String>();
        if (posMap.containsKey(va.Volunteer_Role__c)) 
        {
            if(posMap.get(va.Volunteer_Role__c).Training_Provided__c != null && posMap.get(va.Volunteer_Role__c).Training_Provided__c != '')
            {
                if(posMap.get(va.Volunteer_Role__c).Training_Provided__c.indexOf(';') != -1)
                { selected.addAll(posMap.get(va.Volunteer_Role__c).Training_Provided__c.split(';')); }
                else
                { selected.add(posMap.get(va.Volunteer_Role__c).Training_Provided__c); }
            }
        }
        if (selected.contains('Observation/Shadowing')) { va.Program_Specific_Training_Status__c = 'To Be Done'; } else { va.Program_Specific_Training_Status__c = 'Not Required'; }                        
    }
}*/