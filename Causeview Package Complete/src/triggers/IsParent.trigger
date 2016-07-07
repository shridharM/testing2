trigger IsParent on Campaign (before update, before insert) {

    RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Campaign' AND NamespacePrefix = 'causeview' LIMIT 1];
    
    Set<String> CIDs = new Set<String>();
    Map<String, String> cmp_to_par_rt = new Map<String, String>();
    
    for (Campaign c : Trigger.new)
    {
        CIDs.add(c.ParentId);
    } 
    
    for (Campaign c : [SELECT Id, RecordTypeId FROM Campaign WHERE Id IN :CIDs])
    {
        cmp_to_par_rt.put(c.Id, c.RecordTypeId);
    }
    
    for (Campaign c : Trigger.new)
    {    
        if (cmp_to_par_rt.get(c.ParentId) == rt.Id)
        { c.ParentAppeal__c = True; }
        
        if (cmp_to_par_rt.get(c.ParentId) != rt.Id)
        { c.ParentAppeal__c = False; }
    }
}