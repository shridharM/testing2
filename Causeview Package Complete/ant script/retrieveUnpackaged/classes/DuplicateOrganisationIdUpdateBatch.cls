public class DuplicateOrganisationIdUpdateBatch implements Database.Batchable<sObject>, Database.stateful {
    String logFileData ='Id, Old Constituent Id, New Constituent Id\n';
    public Database.queryLocator start(Database.BatchableContext BC){
        string query ='select cv_pkg_dev_I__Organization_ID__c, CreatedDate from Account order by CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> acc){
        Map<Id, Account> accountToUpdate = new Map<Id, Account>();
        Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
        Map<String, List<Account>> accountMap = new  Map<String, List<Account>>();
        cv_pkg_dev_I__aNums__c s = cv_pkg_dev_I__aNums__c.getInstance('Default');
        if (s == null) { return; }
        Set<String> organisationIds = new Set<String>();
        Set<Id> accounttIds = new Set<Id>();
        for(Account a : acc){
            organisationIds.add(a.cv_pkg_dev_I__Organization_ID__c);
            accounttIds.add(a.id);
        }
        cv_pkg_dev_I__Application_Setting__c autoNumberSetting = [select Name, cv_pkg_dev_I__Org_Count__c from cv_pkg_dev_I__Application_Setting__c where Name = 'Auto Number Setting' Limit 1 FOR UPDATE];
        system.debug('Nitin constituentId==='+organisationIds);
        system.debug('Nitin contactId==='+accounttIds);
        for(Contact duplicateCon : [select cv_pkg_dev_I__Constituent_ID__c, CreatedDate from Contact where cv_pkg_dev_I__Constituent_ID__c IN: organisationIds]){
            if(!contactMap.containsKey(duplicateCon.cv_pkg_dev_I__Constituent_ID__c)){
                contactMap.put(duplicateCon.cv_pkg_dev_I__Constituent_ID__c, new List<Contact>());
            }
            contactMap.get(duplicateCon.cv_pkg_dev_I__Constituent_ID__c).add(duplicateCon);
            system.debug('Nitin conRecord==='+duplicateCon);
        }
        for(Account accRecord : [select cv_pkg_dev_I__Organization_ID__c, CreatedDate from Account where cv_pkg_dev_I__Organization_ID__c IN: organisationIds]){
            if(!accountMap.containsKey(accRecord.cv_pkg_dev_I__Organization_ID__c)){
                accountMap.put(accRecord.cv_pkg_dev_I__Organization_ID__c, new List<Account>());
            }
            accountMap.get(accRecord.cv_pkg_dev_I__Organization_ID__c).add(accRecord);
            system.debug('Nitin accRecord==='+accRecord);
        }
        if(contactMap.size() > 0 || accountMap.size() > 0){
            for(Account a : acc){
                String accountOrganisationID = a.cv_pkg_dev_I__Organization_ID__c;
                if(contactMap.get(accountOrganisationID) != null){
                    for(Contact cc : contactMap.get(accountOrganisationID)){
                        if(a.cv_pkg_dev_I__Organization_ID__c == cc.cv_pkg_dev_I__Constituent_ID__c){
                            if(a.CreatedDate >= cc.CreatedDate){
                                if(accountToUpdate.containsKey(a.id)){
                                    continue;
                                }
                                system.debug('Nitin Account===='+a);
                                logFileData += a.Id + ', ' + a.cv_pkg_dev_I__Organization_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c).length() < s.cv_pkg_dev_I__OrgLength__c) {
                                    for (Integer i = 0; i < (s.cv_pkg_dev_I__OrgLength__c - String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c).length()-2); i++) {
                                        prefix+= '0'; 
                                    }            
                                }
                                a.cv_pkg_dev_I__Organization_ID__c = s.cv_pkg_dev_I__OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c.round());
                                system.debug('Nitin Constituent Id==='+a.cv_pkg_dev_I__Organization_ID__c);
                                autoNumberSetting.cv_pkg_dev_I__Org_Count__c++;
                                logFileData += a.cv_pkg_dev_I__Organization_ID__c+ '\n'; 
                                accountToUpdate.put(a.id, a);
                            }
                        }
                    }
                }
                if(accountMap.get(accountOrganisationID) != null){
                    for(Account aa : accountMap.get(accountOrganisationID)){
                        if(a.cv_pkg_dev_I__Organization_ID__c == aa.cv_pkg_dev_I__Organization_ID__c && a.id != aa.id){
                            if(a.CreatedDate >= aa.CreatedDate){
                                if(accountToUpdate.containsKey(a.id)){
                                    continue;
                                }
                                system.debug('Nitin Account===='+a);
                                logFileData += a.Id + ', ' + a.cv_pkg_dev_I__Organization_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c).length() < s.cv_pkg_dev_I__OrgLength__c) {
                                    for (Integer i = 0; i < (s.cv_pkg_dev_I__OrgLength__c - String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c).length()-2); i++) {
                                        prefix+= '0'; 
                                    }            
                                }
                                a.cv_pkg_dev_I__Organization_ID__c = s.cv_pkg_dev_I__OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.cv_pkg_dev_I__Org_Count__c.round());
                                system.debug('Nitin Constituent Id==='+a.cv_pkg_dev_I__Organization_ID__c);
                                autoNumberSetting.cv_pkg_dev_I__Org_Count__c++;
                                logFileData += a.cv_pkg_dev_I__Organization_ID__c+ '\n'; 
                                accountToUpdate.put(a.id, a);
                            }
                        }
                    }
                }
            }
            if(accountToUpdate.size() > 0)
            update accountToUpdate.values();
        }
        update autoNumberSetting;
    }
    
    public void finish(Database.BatchableContext BC){
        if (String.isNotBlank(logFileData) == true){
            //Folder folder = [select id from Folder where name='Updated Account/Contact Record Log' LIMIT 1];
            Document doc = new Document (Name = 'AccountBatchLog'+DateTime.now().format() + '.txt');
            doc.Description = ''; // Insert description
            //doc.FolderId = folder.Id;
            doc.FolderId = userInfo.getUserId();
            doc.Body = Blob.valueOf(logFileData);
            insert doc;
        }
    }
}