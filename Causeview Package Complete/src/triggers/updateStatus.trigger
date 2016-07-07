trigger updateStatus on Event_Registration__c (after insert, after update, after undelete, after delete) {    

    Set<string> contactIds = new Set<string>(); 
    Set<string> eventIds = new Set<string>();         
    Map<string, CampaignMember> clist = new Map<string, CampaignMember>();
    List<CampaignMember> cmToUpdate = new List<CampaignMember>();
    BatchSettings__c settings = BatchSettings__c.getInstance('Default');
    
    if (!Trigger.IsDelete) {
        for (Event_Registration__c er: trigger.new){   
            if (!contactIds.contains(er.Individual__c)) contactIds.add(er.Individual__c);
            if (!eventIds.contains(er.Event__c)) eventIds.add(er.Event__c);
        }
        
        for (CampaignMember cms: [SELECT CampaignId, ContactId FROM CampaignMember WHERE ContactId IN :contactIds AND CampaignId IN :eventIds]){
            if (!clist.containsKey(cms.ContactId)) clist.put(cms.ContactId, cms);
        }
        
        for (Event_Registration__c er: trigger.new){            
            CampaignMember cm = new CampaignMember();
            if (clist.get(er.Individual__c) != null) {            
                cm = clist.get(er.Individual__c);        
                cm.Status = 'Responded';
                cmToUpdate.add(cm);
            }
            else {
                cm.Status = 'Responded';
                cm.ContactId = er.Individual__c;
                cm.CampaignId = er.Event__c;
                cmToUpdate.add(cm);            
            }
        }
        
        try {
            upsert cmToUpdate;
        }
        catch(Exception ex) {
            System.debug(ex);
        }
    }
    else {
        for (Event_Registration__c er: trigger.old){    
            contactIds.add(er.Individual__c);
            eventIds.add(er.Event__c);
        }
        
        for (CampaignMember cms: [SELECT CampaignId, ContactId FROM CampaignMember WHERE ContactId IN :contactIds AND CampaignId IN :eventIds FOR UPDATE]){
            clist.put(cms.ContactId, cms);
        }
        
        for (Event_Registration__c er: trigger.old){            
            CampaignMember cm = new CampaignMember();
            if (clist.get(er.Individual__c) != null) {            
                cm = clist.get(er.Individual__c);        
                cm.Status = 'Sent';
                cmToUpdate.add(cm);
            }
        }
        
        update cmToUpdate;
    }
}