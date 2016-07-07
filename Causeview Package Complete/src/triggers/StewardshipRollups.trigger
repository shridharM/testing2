trigger StewardshipRollups on Task (after insert, after update, after delete, after undelete) {
  Set<Id> individualIds = new Set<Id>();
  BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
  System.debug('====='+settings);
  if (settings.causeview__Data_Migration_Mode__c) return;
  
  if (trigger.isInsert || trigger.isUndelete)
  {
      for(Task t : trigger.new) {
          system.debug('Nitin==='+t.isClosed);
        if (t.WhoId!=null && ((string)t.WhoId).startsWith('003') && !individualIds.contains(t.WhoId))
         individualIds.add(t.WhoId);
      }
  }
  else if (trigger.isUpdate)
  {
     for(Task t : trigger.new) {
        if (t.WhoId!=null && ((string)t.WhoId).startsWith('003') && !individualIds.contains(t.WhoId))
           individualIds.add(t.WhoId); 
        if (t.WhoId==null && trigger.oldMap.get(t.Id).WhoId!=null) {
           string oldWhoId = trigger.oldMap.get(t.Id).WhoId;
           if (!individualIds.contains(oldWhoId) && oldWhoId.startsWith('003'))
             individualIds.add(oldWhoId); 
        }
     }
  }
  else
  {
      for(Task t : trigger.old) 
         if (t.WhoId!=null && ((string)t.WhoId).startsWith('003') && !individualIds.contains(t.WhoId))
           individualIds.add(t.WhoId);
     
  }
  system.debug('Nitin contact==='+individualIds);
  if (individualIds.size()<=0) return;
  
  AggregateResult[] results = [SELECT COUNT(Id) cnt, Type, WhoId FROM Task WHERE WhoId IN :individualIds AND Type!=null AND IsClosed=true AND ActivityDate = THIS_FISCAL_YEAR GROUP BY WhoId,Type];
  if (results==null || results.size()<=0) return;
  system.debug('Nitin result==='+results);
  List<Contact> itemsToUpdate = new List<Contact>();
  Map<string,string> trackedTaskTypes = new Map<string,string>();
  trackedTaskTypes.put('Phone Call','Steward_Phone_Calls__c');
  trackedTaskTypes.put('Personal Letter','Steward_Acknowledgement_Letter__c');
  trackedTaskTypes.put('Automated Email','Steward_Emails__c');
  trackedTaskTypes.put('Personal Email','Steward_Personal_Emails__c');
  trackedTaskTypes.put('Face to Face Meeting','Steward_Face_to_Face_Meetings__c');
    
  for(string contactId : individualIds) {
     boolean isFound = false;
     Contact c = new Contact(Id=contactId);
     
    for(AggregateResult result : results){
        if (result.get('WhoId') == contactId && trackedTaskTypes.containsKey((string)result.get('Type'))) {
            system.debug('Nitin Here==='+result.get('WhoId') + ' track==='+trackedTaskTypes.containsKey((string)result.get('Type')));
            c.put(trackedTaskTypes.get((string)result.get('Type')), result.get('cnt'));
            isFound = true;
        } 
    }
    system.debug('Nitin Contact==='+c);
    //contact fields may be populated:
    if (isFound) itemsToUpdate.add(c);
  }
  
  if (itemsToUpdate.size()>0) update itemsToUpdate;
}