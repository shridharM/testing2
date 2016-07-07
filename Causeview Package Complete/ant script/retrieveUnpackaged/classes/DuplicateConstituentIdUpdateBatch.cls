public class DuplicateConstituentIdUpdateBatch implements Database.Batchable<sObject>, Database.stateful {
    String logFileData ='Id, Old Constituent Id, New Constituent Id\n';
    public Database.queryLocator start(Database.BatchableContext BC){
        string query ='select cv_pkg_dev_I__Constituent_ID__c, CreatedDate, LastModifiedDate from Contact order by CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> con){
        Map<Id, Contact> contactToUpdate = new Map<Id, Contact>();
        Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
        Map<String, List<Account>> accountMap = new  Map<String, List<Account>>();
        cv_pkg_dev_I__aNums__c s = cv_pkg_dev_I__aNums__c.getInstance('Default');
        if (s == null) { return; }
        Set<String> constituentIds = new Set<String>();
        Set<Id> contactIds = new Set<Id>();
        for(Contact c : con){
            constituentIds.add(c.cv_pkg_dev_I__Constituent_ID__c);
            contactIds.add(c.id);
        }
        cv_pkg_dev_I__Application_Setting__c autoNumberSetting = [select Name, cv_pkg_dev_I__Org_Count__c from cv_pkg_dev_I__Application_Setting__c where Name = 'Auto Number Setting' Limit 1 FOR UPDATE];
        system.debug('Nitin constituentId==='+constituentIds);
        system.debug('Nitin contactId==='+contactIds);
        for(Contact duplicateCon : [select cv_pkg_dev_I__Constituent_ID__c, CreatedDate, LastModifiedDate from Contact where cv_pkg_dev_I__Constituent_ID__c IN: constituentIds]){
            if(!contactMap.containsKey(duplicateCon.cv_pkg_dev_I__Constituent_ID__c)){
                contactMap.put(duplicateCon.cv_pkg_dev_I__Constituent_ID__c, new List<Contact>());
            }
            contactMap.get(duplicateCon.cv_pkg_dev_I__Constituent_ID__c).add(duplicateCon);
            system.debug('Nitin conRecord==='+duplicateCon);
        }
        for(Account accRecord : [select cv_pkg_dev_I__Organization_ID__c, CreatedDate, LastModifiedDate from Account where cv_pkg_dev_I__Organization_ID__c IN: constituentIds]){
            if(!accountMap.containsKey(accRecord.cv_pkg_dev_I__Organization_ID__c)){
                accountMap.put(accRecord.cv_pkg_dev_I__Organization_ID__c, new List<Account>());
            }
            accountMap.get(accRecord.cv_pkg_dev_I__Organization_ID__c).add(accRecord);
            system.debug('Nitin accRecord==='+accRecord);
        }
        system.debug('Nitin COntactMap===='+contactMap);
        if(contactMap.size() > 0 || accountMap.size() > 0){
            for(Contact c : con){
                system.debug('Nitin COntact1===='+c);
                string contactConstitentId = c.cv_pkg_dev_I__Constituent_ID__c;
                if(contactMap.get(contactConstitentId) != null){
                    for(Contact cc : contactMap.get(contactConstitentId)){
                        if(c.cv_pkg_dev_I__Constituent_ID__c == cc.cv_pkg_dev_I__Constituent_ID__c && c.id != cc.id){
                            if(c.CreatedDate >= cc.CreatedDate){
                                if(contactToUpdate.containsKey(c.id)){
                                    continue;
                                }
                                system.debug('Nitin COntact===='+c);
                                logFileData += c.Id + ', ' + c.cv_pkg_dev_I__Constituent_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c).length() < s.cv_pkg_dev_I__OrgLength__c) {
                                    for (Integer i = 0; i < (s.cv_pkg_dev_I__OrgLength__c - String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c).length()-2); i++) {
                                        prefix+= '0'; 
                                    }            
                                }
                                c.cv_pkg_dev_I__Constituent_ID__c = s.cv_pkg_dev_I__OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c.round());
                                system.debug('Nitin Constituent Id==='+c.cv_pkg_dev_I__Constituent_ID__c);
                                autoNumberSetting.cv_pkg_dev_I__Org_Count__c++;
                                logFileData += c.cv_pkg_dev_I__Constituent_ID__c+ '\n'; 
                                contactToUpdate.put(c.id, c);
                            }
                        }
                    }
                }
                if(accountMap.get(contactConstitentId) != null){
                    for(Account aa : accountMap.get(contactConstitentId)){
                        if(c.cv_pkg_dev_I__Constituent_ID__c == aa.cv_pkg_dev_I__Organization_ID__c){
                            if(c.CreatedDate >= aa.CreatedDate){
                                if(contactToUpdate.containsKey(c.id)){
                                    continue;
                                }
                                system.debug('Nitin Account===='+aa);
                                logFileData += c.Id + ', ' + c.cv_pkg_dev_I__Constituent_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c).length() < s.cv_pkg_dev_I__OrgLength__c) {
                                    for (Integer i = 0; i < (s.cv_pkg_dev_I__OrgLength__c - String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c).length()-2); i++) {
                                        prefix+= '0'; 
                                    }            
                                }
                                c.cv_pkg_dev_I__Constituent_ID__c = s.cv_pkg_dev_I__OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c.round());
                                system.debug('Nitin Constituent Id==='+c.cv_pkg_dev_I__Constituent_ID__c);
                                autoNumberSetting.cv_pkg_dev_I__Org_Count__c++;
                                logFileData += c.cv_pkg_dev_I__Constituent_ID__c+ '\n'; 
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