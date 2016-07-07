public class DuplicateOrganisationIdUpdateBatch implements Database.Batchable<sObject>, Database.stateful {
    String logFileData ='Id, Old Constituent Id, New Constituent Id\n';
    public Database.queryLocator start(Database.BatchableContext BC){
        string query ='select causeview__Organization_ID__c, CreatedDate from Account order by CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> acc){
        Map<Id, Account> accountToUpdate = new Map<Id, Account>();
        Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
        Map<String, List<Account>> accountMap = new  Map<String, List<Account>>();
        causeview__aNums__c s = causeview__aNums__c.getInstance('Default');
        if (s == null) { return; }
        Set<String> organisationIds = new Set<String>();
        Set<Id> accounttIds = new Set<Id>();
        for(Account a : acc){
            organisationIds.add(a.causeview__Organization_ID__c);
            accounttIds.add(a.id);
        }
        causeview__Application_Setting__c autoNumberSetting = [select Name, causeview__Org_Count__c from causeview__Application_Setting__c where Name = 'Auto Number Setting' Limit 1 FOR UPDATE];
        system.debug('Nitin constituentId==='+organisationIds);
        system.debug('Nitin contactId==='+accounttIds);
        for(Contact duplicateCon : [select causeview__Constituent_ID__c, CreatedDate from Contact where causeview__Constituent_ID__c IN: organisationIds]){
            if(!contactMap.containsKey(duplicateCon.causeview__Constituent_ID__c)){
                contactMap.put(duplicateCon.causeview__Constituent_ID__c, new List<Contact>());
            }
            contactMap.get(duplicateCon.causeview__Constituent_ID__c).add(duplicateCon);
            system.debug('Nitin conRecord==='+duplicateCon);
        }
        for(Account accRecord : [select causeview__Organization_ID__c, CreatedDate from Account where causeview__Organization_ID__c IN: organisationIds]){
            if(!accountMap.containsKey(accRecord.causeview__Organization_ID__c)){
                accountMap.put(accRecord.causeview__Organization_ID__c, new List<Account>());
            }
            accountMap.get(accRecord.causeview__Organization_ID__c).add(accRecord);
            system.debug('Nitin accRecord==='+accRecord);
        }
        if(contactMap.size() > 0 || accountMap.size() > 0){
            for(Account a : acc){
                String accountOrganisationID = a.causeview__Organization_ID__c;
                if(contactMap.get(accountOrganisationID) != null){
                    for(Contact cc : contactMap.get(accountOrganisationID)){
                        if(a.causeview__Organization_ID__c == cc.causeview__Constituent_ID__c){
                            if(a.CreatedDate >= cc.CreatedDate){
                                if(accountToUpdate.containsKey(a.id)){
                                    continue;
                                }
                                system.debug('Nitin Account===='+a);
                                logFileData += a.Id + ', ' + a.causeview__Organization_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.causeview__Org_Count__c).length() < s.causeview__OrgLength__c) {
                                    for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(autoNumberSetting.causeview__Org_Count__c).length()-2); i++) {
                                        prefix+= '0'; 
                                    }            
                                }
                                a.causeview__Organization_ID__c = s.causeview__OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.causeview__Org_Count__c.round());
                                system.debug('Nitin Constituent Id==='+a.causeview__Organization_ID__c);
                                autoNumberSetting.causeview__Org_Count__c++;
                                logFileData += a.causeview__Organization_ID__c+ '\n'; 
                                accountToUpdate.put(a.id, a);
                            }
                        }
                    }
                }
                if(accountMap.get(accountOrganisationID) != null){
                    for(Account aa : accountMap.get(accountOrganisationID)){
                        if(a.causeview__Organization_ID__c == aa.causeview__Organization_ID__c && a.id != aa.id){
                            if(a.CreatedDate >= aa.CreatedDate){
                                if(accountToUpdate.containsKey(a.id)){
                                    continue;
                                }
                                system.debug('Nitin Account===='+a);
                                logFileData += a.Id + ', ' + a.causeview__Organization_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.causeview__Org_Count__c).length() < s.causeview__OrgLength__c) {
                                    for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(autoNumberSetting.causeview__Org_Count__c).length()-2); i++) {
                                        prefix+= '0'; 
                                    }            
                                }
                                a.causeview__Organization_ID__c = s.causeview__OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.causeview__Org_Count__c.round());
                                system.debug('Nitin Constituent Id==='+a.causeview__Organization_ID__c);
                                autoNumberSetting.causeview__Org_Count__c++;
                                logFileData += a.causeview__Organization_ID__c+ '\n'; 
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