public class DuplicateConstituentIdUpdateBatch implements Database.Batchable<sObject>, Database.stateful {
    String logFileData ='Id, Old Constituent Id, New Constituent Id\n';
    public Database.queryLocator start(Database.BatchableContext BC){
        string query ='select causeview__Constituent_ID__c, CreatedDate, LastModifiedDate from Contact order by CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> con){
        Map<Id, Contact> contactToUpdate = new Map<Id, Contact>();
        Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
        Map<String, List<Account>> accountMap = new  Map<String, List<Account>>();
        causeview__aNums__c s = causeview__aNums__c.getInstance('Default');
        if (s == null) { return; }
        Set<String> constituentIds = new Set<String>();
        Set<Id> contactIds = new Set<Id>();
        for(Contact c : con){
            constituentIds.add(c.causeview__Constituent_ID__c);
            contactIds.add(c.id);
        }
        causeview__Application_Setting__c autoNumberSetting = [select Name, causeview__Org_Count__c from causeview__Application_Setting__c where Name = 'Auto Number Setting' Limit 1 FOR UPDATE];
        system.debug('Nitin constituentId==='+constituentIds);
        system.debug('Nitin contactId==='+contactIds);
        for(Contact duplicateCon : [select causeview__Constituent_ID__c, CreatedDate, LastModifiedDate from Contact where causeview__Constituent_ID__c IN: constituentIds]){
            if(!contactMap.containsKey(duplicateCon.causeview__Constituent_ID__c)){
                contactMap.put(duplicateCon.causeview__Constituent_ID__c, new List<Contact>());
            }
            contactMap.get(duplicateCon.causeview__Constituent_ID__c).add(duplicateCon);
            system.debug('Nitin conRecord==='+duplicateCon);
        }
        for(Account accRecord : [select causeview__Organization_ID__c, CreatedDate, LastModifiedDate from Account where causeview__Organization_ID__c IN: constituentIds]){
            if(!accountMap.containsKey(accRecord.causeview__Organization_ID__c)){
                accountMap.put(accRecord.causeview__Organization_ID__c, new List<Account>());
            }
            accountMap.get(accRecord.causeview__Organization_ID__c).add(accRecord);
            system.debug('Nitin accRecord==='+accRecord);
        }
        system.debug('Nitin COntactMap===='+contactMap);
        if(contactMap.size() > 0 || accountMap.size() > 0){
            for(Contact c : con){
                system.debug('Nitin COntact1===='+c);
                string contactConstitentId = c.causeview__Constituent_ID__c;
                if(contactMap.get(contactConstitentId) != null){
                    for(Contact cc : contactMap.get(contactConstitentId)){
                        if(c.causeview__Constituent_ID__c == cc.causeview__Constituent_ID__c && c.id != cc.id){
                            if(c.CreatedDate >= cc.CreatedDate){
                                if(contactToUpdate.containsKey(c.id)){
                                    continue;
                                }
                                system.debug('Nitin COntact===='+c);
                                logFileData += c.Id + ', ' + c.causeview__Constituent_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.causeview__Org_Count__c).length() < s.causeview__OrgLength__c) {
                                    for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(autoNumberSetting.causeview__Org_Count__c).length()-2); i++) {
                                        prefix+= '0'; 
                                    }            
                                }
                                c.causeview__Constituent_ID__c = s.causeview__OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.causeview__Org_Count__c.round());
                                system.debug('Nitin Constituent Id==='+c.causeview__Constituent_ID__c);
                                autoNumberSetting.causeview__Org_Count__c++;
                                logFileData += c.causeview__Constituent_ID__c+ '\n'; 
                                contactToUpdate.put(c.id, c);
                            }
                        }
                    }
                }
                if(accountMap.get(contactConstitentId) != null){
                    for(Account aa : accountMap.get(contactConstitentId)){
                        if(c.causeview__Constituent_ID__c == aa.causeview__Organization_ID__c){
                            if(c.CreatedDate >= aa.CreatedDate){
                                if(contactToUpdate.containsKey(c.id)){
                                    continue;
                                }
                                system.debug('Nitin Account===='+aa);
                                logFileData += c.Id + ', ' + c.causeview__Constituent_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.causeview__Org_Count__c).length() < s.causeview__OrgLength__c) {
                                    for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(autoNumberSetting.causeview__Org_Count__c).length()-2); i++) {
                                        prefix+= '0'; 
                                    }            
                                }
                                c.causeview__Constituent_ID__c = s.causeview__OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.causeview__Org_Count__c.round());
                                system.debug('Nitin Constituent Id==='+c.causeview__Constituent_ID__c);
                                autoNumberSetting.causeview__Org_Count__c++;
                                logFileData += c.causeview__Constituent_ID__c+ '\n'; 
                                contactToUpdate.put(c.id, c);
                            }
                        }
                    }
                }
            }
            if(contactToUpdate.size() > 0){
                Update contactToUpdate.values();
            }
        }
        update autoNumberSetting;
    }
    
    public void finish(Database.BatchableContext BC){
        if (String.isNotBlank(logFileData) == true){
            //Folder folder = [select id from Folder where name='Updated Account/Contact Record Log' LIMIT 1];
            Document doc = new Document (Name = 'ContactBatchLog'+DateTime.now().format() + '.txt');
            doc.Description = ''; // Insert description
            //doc.FolderId = folder.Id;
            doc.FolderId = UserInfo.getUserId();
            doc.Body = Blob.valueOf(logFileData);
            insert doc;
        }
    }
}