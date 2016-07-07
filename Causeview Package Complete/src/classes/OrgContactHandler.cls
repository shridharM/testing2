public class OrgContactHandler {
    public static void CascadeHouseholdAddress(List<Account> cOld, List<Account> cNew) {
        system.debug('<==Inside CascadeHouseholdAddress==>');
        List<RecordType> rtypes = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'Account' AND isActive = true AND NamespacePrefix = 'causeview'];
        Map<String,String> accountRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
        { accountRecordTypes.put(rt.Name,rt.Id); }
        
        Set<Id> AIDs = new Set<Id>();  
        for (Integer i = 0; i < Trigger.old.size(); i++)
        {
            if (cOld[i].BillingStreet == cNew[i].BillingStreet && 
                cOld[i].BillingCity == cNew[i].BillingCity && 
                cOld[i].BillingPostalCode == cNew[i].BillingPostalCode && 
                cOld[i].BillingState == cNew[i].BillingState && 
                cOld[i].BillingCountry == cNew[i].BillingCountry &&
                cOld[i].Phone == cNew[i].Phone &&
                cOld[i].Household_Addressee__c == cNew[i].Household_Addressee__c &&
                cOld[i].Household_Salutation__c == cNew[i].Household_Salutation__c)
                { continue; }
            AIDS.add(cNew[i].Id);
        }    
                
        
        List<Contact> ContactSet = new List<Contact>();
        List<Account> theAccounts = [SELECT Id, BillingStreet, BillingState, BillingCountry, BillingPostalCode, BillingCity, Phone, Household_Addressee__c, Household_Salutation__c,
                                    (SELECT Id, Use_Household_Salutation_Addressee__c, Same_as_Household__c, Primary_Addressee__c, Primary_Salutation__c, 
                                     HomePhone, MailingStreet, MailingState, MailingCountry, MailingPostalCode, MailingCity FROM HouseholdContacts__r) 
                                    FROM Account WHERE Id IN :AIDS AND RecordTypeId = :accountRecordTypes.get('Household')];
    
        for(Account a : theAccounts)
        {
            for (Contact c : a.HouseholdContacts__r)
            {
                if (c.Use_Household_Salutation_Addressee__c == True)
                { 
                    c.Primary_Addressee__c = a.Household_Addressee__c;  
                    c.Primary_Salutation__c = a.Household_Salutation__c;
                }
                if (c.Same_as_Household__c == True)
                {  
                    c.HomePhone = a.Phone;
                    c.MailingStreet = a.BillingStreet;
                    c.MailingState = a.BillingState;
                    c.MailingCountry = a.BillingCountry;
                    c.MailingPostalCode = a.BillingPostalCode;
                    c.MailingCity = a.BillingCity;
                }
                ContactSet.add(c);
               
            }            
        }
        if (ContactSet.size() > 0)
             Validator_cls.setAlreadyDone1();
            update ContactSet;  
           
    }
    
    public static void PreventBucketDelete(List<Account> accounts) {
        system.debug('<==Inside PreventBucketDelete==>');
        BatchSettings__c settingList = BatchSettings__c.getInstance('Default');
        for (Account a : accounts)
        {
            if (a.Id == settingList.BucketAccountId__c && settingList.LockBucketAccount__c == True)
            { a.addError('Cannot delete the Guest Contact!'); }
        }
    }

    public static void PreventBucketModify(List<Account> aOld, List<Account> aNew) {
        system.debug('<==Inside PreventBucketModify==>');
        BatchSettings__c settingList = BatchSettings__c.getInstance('Default');
        system.debug('settingList==>'+settingList.BucketAccountId__c); 
        system.debug('settingList==>'+settingList.LockBucketAccount__c);        
        for (Integer i = 0; i < aNew.size(); i++)
        {
            system.debug('aid==>'+aNew[i].id);
            if (aNew[i].Id == settingList.BucketAccountId__c && settingList.LockBucketAccount__c == True && (aNew[i].Name != aOld[i].Name))
            { aNew[i].addError('Cannot modify the Guest Contact!'); }
        }
    }    
 
 /*
    public static void PreventGuestDelete(List<Contact> accounts) {
        BatchSettings__c settingList = BatchSettings__c.getInstance('Default');
        for (Contact a : accounts)
        {
            if (a.Id == settingList.Unknown_Guest_Id__c)
            { a.addError('Cannot delete the Individual Bucket Account!'); }
        }
    }

    public static void PreventGuestModify(List<Contact> aOld, List<Contact> aNew) {
        BatchSettings__c settingList = BatchSettings__c.getInstance('Default');     
        if (settingList != null) {   
            for (Integer i = 0; i < aNew.size(); i++)
            {
                if (aNew[i].Id == settingList.Unknown_Guest_Id__c && ((aNew[i].LastName != aOld[i].LastName) || (aNew[i].FirstName != aOld[i].FirstName)))
                { aNew[i].addError('Cannot modify the Individual Bucket Account!'); }
            }
        }
    }  */

    public static string GetNext(string type, causeview__aNums__c s)
    {
        Boolean stop = false;
        string prefix = '';
        string value = '';
        while(!stop)
        {
            prefix = '';
            if (type == 'Account')
            {
                if (String.valueOf(s.causeview__OrgCount__c).length() < s.causeview__OrgLength__c)
                {            
                    for (Integer i = 0; i <= (s.causeview__OrgLength__c - String.valueOf(s.causeview__OrgCount__c).length()); i++)
                    { 
                        prefix+= '0'; 
                    }            
                }
                value = s.causeview__OrgPrefix__c + prefix + String.valueOf(s.causeview__OrgCount__c.round());
                s.causeview__OrgCount__c++;
                update s;
            }
            else
            {
                if (String.valueOf(s.causeview__OrgCount__c).length() < s.causeview__OrgLength__c)
                {
                    for (Integer i = 0; i <= (s.causeview__OrgLength__c - String.valueOf(s.causeview__OrgCount__c).length()); i++)
                    { 
                        prefix+= '0'; 
                    }            
                }        
                value = s.causeview__ContactPrefix__c + prefix + String.valueOf(s.causeview__OrgCount__c.round());
                s.causeview__OrgCount__c++;
                update s;
            }
            stop = !IsAssigned(value, type, null);
        }
        system.debug('value==>'+value);
        return value;
    }
    public static boolean IsAssigned(string value, string type, string id)
    {
        //if (type == 'Account')
        //{
        //  List<sObject> results = [SELECT Id FROM Account WHERE causeview__Organization_ID__c = :value AND Id <> :Id];
        //  if (results.size() > 0) return true;
        //  results = [SELECT Id FROM Contact WHERE causeview__Constituent_ID__c = :value];         
        //  return results.size() > 0;
        //}
        //else
        //{
        //  List<sObject> results = [SELECT Id FROM Contact WHERE causeview__Constituent_ID__c = :value AND Id <> :Id];         
        //  if (results.size() > 0) return true;
        //  results = [SELECT Id FROM Account WHERE causeview__Organization_ID__c = :value];
        //  return results.size() > 0;
        //}
        return false;
    }
    /*public static void AutoNumber(List<sObject> constituents, string type) {
        System.debug('<==Inside AutoNumber==>');
        causeview__aNums__c s = causeview__aNums__c.getInstance('Default');   
        if (s == null) { return; }
        if (!Test.isRunningTest()) {
            try {   
                if (type == 'Account') {
                    List<Account> accountRec = (List<Account>)constituents;
                    Set<String> contOrgId = new Set<String>();
                    Set<Id> accID = new Set<Id>();
                    for (Account a : (List<Account>)constituents) {
                        if (a.causeview__Organization_ID__c != null && IsAssigned(a.causeview__Organization_ID__c, type, a.Id)) a.causeview__Organization_ID__c = null;
                        if (a.causeview__Organization_ID__c == null) {
                            //next 8 lines uncommented and 9th line commented by nitin
                            String prefix = '';
                            if (String.valueOf(s.causeview__OrgCount__c).length() < s.causeview__OrgLength__c) {
                                for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(s.causeview__OrgCount__c).length()); i++) {
                                    prefix+= '0'; 
                                }            
                            }
                            a.causeview__Organization_ID__c = s.causeview__OrgPrefix__c + prefix + String.valueOf(s.causeview__OrgCount__c.round());
                            //system.debug('orgCount==>'+s.causeview__OrgCount__c);
                            s.causeview__OrgCount__c++;
                            //a.causeview__Organization_ID__c = GetNext(type, s);
                            system.debug('Nitin Account Id===='+a.causeview__Organization_ID__c);
                        }
                        contOrgId.add(a.causeview__Organization_ID__c);
                        accID.add(a.id);
                    }
                    //checkDuplicate(accountRec, contOrgId, accID, 'Account');
                    //uncommented by nitin
                    update s;
                    system.debug('Nitin orgCount==>'+s.causeview__OrgCount__c);
                }
                if (type == 'Contact') {
                    List<Contact> conRec = (List<Contact>)constituents;
                    Set<String> contOrgId = new Set<String>();
                    Set<Id> conIds = new Set<Id>();
                    for (Contact c : (List<Contact>)constituents) {
                        system.debug('Nitin Id==='+c.id);
                        if (c.causeview__Constituent_ID__c != null && IsAssigned(c.causeview__Constituent_ID__c, type, c.Id)) c.causeview__Constituent_ID__c = null;
                        if (c.causeview__Constituent_ID__c == null) {
                            //next 8 lines uncommented and 9th line commented by nitin
                            String prefix = '';
                            system.debug('Nitin orgCountValue===='+s.causeview__OrgCount__c);
                            system.debug('Nitin orgCountValue===='+String.valueOf(s.causeview__OrgCount__c));
                            system.debug('Nitin orgCountValue===='+String.valueOf(s.causeview__OrgCount__c).length());
                            if (String.valueOf(s.causeview__OrgCount__c).length() < s.causeview__OrgLength__c) {
                                for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(s.causeview__OrgCount__c).length()); i++) { 
                                    prefix+= '0'; 
                                }            
                            }        
                            c.causeview__Constituent_ID__c = s.causeview__ContactPrefix__c + prefix + String.valueOf(s.causeview__OrgCount__c.round());
                            s.causeview__OrgCount__c++;
                            //c.causeview__Constituent_ID__c = GetNext(type, s);
                            system.debug('Nitin==='+c.causeview__Constituent_ID__c);
                        }
                        contOrgId.add(c.causeview__Constituent_ID__c);
                        conIds.add(c.id);
                    }
                    //checkDuplicate(conRec, contOrgId, conIds, 'Contact');
                    //uncommented by nitin
                    update s;
                    system.debug('Nitin custom setting==='+s);
                }
            }
            catch (Exception ex) { 
                Trigger.new[0].addError('Your Custom Settings must define the Individual Counts before you can create records.'); return;
            }                    
        }
    }*/
    
    public static void AutoNumber(List<sObject> constituents, string type) {
        System.debug('<==Inside AutoNumber==>');
        Long BeginTime = DateTime.now().getTime();
        causeview__aNums__c s = causeview__aNums__c.getInstance('Default');   
        if (s == null) { return; }
        if (!Test.isRunningTest()) {
            try {   
                if (type == 'Account') {
                    causeview__Application_Setting__c app = [select causeview__Org_Count__c from causeview__Application_Setting__c where name = 'Auto Number Setting' Limit 1 FOR UPDATE];
                    System.debug('Nitin app setting==='+app.causeview__Org_Count__c);
                    List<Account> accountRec = (List<Account>)constituents;
                    Set<String> contOrgId = new Set<String>();
                    Set<Id> accID = new Set<Id>();
                    for (Account a : (List<Account>)constituents) {
                        if (a.causeview__Organization_ID__c == null) {
                            //next 8 lines uncommented and 9th line commented by nitin
                            String prefix = '';
                            if (String.valueOf(app.causeview__Org_Count__c).length() < s.causeview__OrgLength__c) {
                                for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(app.causeview__Org_Count__c).length() - 2); i++) {
                                    prefix+= '0'; 
                                }            
                            }
                            a.causeview__Organization_ID__c = s.causeview__OrgPrefix__c + prefix + String.valueOf(app.causeview__Org_Count__c.round());
                            app.causeview__Org_Count__c++;
                            system.debug('Nitin Account Id===='+a.causeview__Organization_ID__c);
                        }
                        contOrgId.add(a.causeview__Organization_ID__c);
                        accID.add(a.id);
                    }
                    checkDuplicate(accountRec, contOrgId, accID, 'Account');
                    //uncommented by nitin
                    //update s;
                    update app;
                    system.debug('Nitin orgCount==>'+s.causeview__OrgCount__c);
                }
                if (type == 'Contact') {
                    causeview__Application_Setting__c app = [select causeview__Org_Count__c from causeview__Application_Setting__c where name = 'Auto Number Setting' Limit 1 FOR UPDATE];
                    System.debug('Nitin app setting==='+app.causeview__Org_Count__c);
                    List<Contact> conRec = (List<Contact>)constituents;
                    Set<String> contOrgId = new Set<String>();
                    Set<Id> conIds = new Set<Id>();
                    for (Contact c : (List<Contact>)constituents) {
                        system.debug('Nitin Id==='+c.id);
                        if (c.causeview__Constituent_ID__c == null) {
                            //next 8 lines uncommented and 9th line commented by nitin
                            String prefix = '';
                            system.debug('Nitin orgCountValue===='+s.causeview__OrgCount__c);
                            system.debug('Nitin orgCountValue===='+String.valueOf(s.causeview__OrgCount__c));
                            system.debug('Nitin orgCountValue===='+String.valueOf(s.causeview__OrgCount__c).length());
                            if (String.valueOf(app.causeview__Org_Count__c).length() < s.causeview__OrgLength__c) {
                                for (Integer i = 0; i < (s.causeview__OrgLength__c - String.valueOf(app.causeview__Org_Count__c).length() - 2); i++) { 
                                    prefix+= '0'; 
                                }            
                            }        
                            c.causeview__Constituent_ID__c = s.causeview__ContactPrefix__c + prefix + String.valueOf(app.causeview__Org_Count__c.round());
                            app.causeview__Org_Count__c++;
                            system.debug('Nitin==='+c.causeview__Constituent_ID__c);
                        }
                        contOrgId.add(c.causeview__Constituent_ID__c);
                        conIds.add(c.id);
                    }
                    checkDuplicate(conRec, contOrgId, conIds, 'Contact');
                    //uncommented by nitin
                    //update s;
                    update app;
                    system.debug('Nitin custom setting==='+s);
                }
            }
           
            catch (Exception ex) {                                          
                Trigger.new[0].addError(ex); return;
            }   
                           
        }
        
        Long EndTime = DateTime.now().getTime();
        Long Difference =(EndTime-BeginTime);
        System.debug('<==Execution Time==>'+Difference);        
    }
    
    public static void checkDuplicate(List<sObject> constituents, Set<string> conOrgIds, Set<Id> Ids, String type){
        causeview__aNums__c s = causeview__aNums__c.getInstance('Default');
        system.debug('Nitin s=='+s.causeview__OrgCount__c);
        if(type == 'Account'){
            List<Account> accountRecords = [select causeview__Organization_ID__c from Account where causeview__Organization_ID__c IN: conOrgIds AND Id <>: Ids];
            //List<Contact> contactRecords = [select causeview__Constituent_ID__c from Contact where causeview__Constituent_ID__c IN: conOrgIds];
            system.debug('Nitin Account'+accountRecords);
           // system.debug('Nitin Contact'+contactRecords);
            if(accountRecords.size()>0 ){//|| contactRecords.size()>0 ){
                for(Account a : (List<Account>)constituents){
                    String organization_Id = a.causeview__Organization_ID__c;
                    if(accountRecords.size() > 0){
                        for(Account aa : accountRecords){
                            //if(a.causeview__Organization_ID__c == aa.causeview__Organization_ID__c){
                            if(organization_Id.equals(aa.causeview__Organization_ID__c)){
                                a.addError('You have entered a duplicate Organziation ID');
                            }
                        }
                    }
                    //following code is not needed. commented by shri- user story:#78405898
                    /*if(contactRecords.size() > 0){
                        for(Contact cc : contactRecords){
                            //if(a.causeview__Organization_ID__c == cc.causeview__Constituent_ID__c){
                            if(organization_Id.equals(cc.causeview__Constituent_ID__c)){
                                a.addError('You have entered a duplicate Organziation ID');
                            }
                        }
                    }*/
                }
            }
        }
        if(type == 'Contact'){
            //List<Account> accountRecords = [select causeview__Organization_ID__c from Account where causeview__Organization_ID__c IN: conOrgIds];
            List<Contact> contactRecords = [select causeview__Constituent_ID__c from Contact where causeview__Constituent_ID__c IN: conOrgIds AND Id <>: Ids];
            //system.debug('Nitin Account'+accountRecords);
            system.debug('Nitin Contact'+contactRecords);
            if(contactRecords.size()>0 ){//if(accountRecords.size()>0  || contactRecords.size()>0 ){
                for(Contact c : (List<Contact>)constituents){
                    String constituent_Id = c.causeview__Constituent_ID__c;
                    //following code is not needed. commented by shri
                    /*if(accountRecords.size() > 0){
                        for(Account aa : accountRecords){
                            //if(c.causeview__Constituent_ID__c == aa.causeview__Organization_ID__c){
                            if(constituent_Id.equals(c.causeview__Constituent_ID__c)){
                                c.addError('You have entered a duplicate Constituent ID');
                            }
                        }
                    }*/
                    if(contactRecords.size() > 0){
                        for(Contact cc : contactRecords){
                            //if(c.causeview__Constituent_ID__c == cc.causeview__Constituent_ID__c){
                            if(constituent_Id.equals(cc.causeview__Constituent_ID__c)){
                                c.addError('You have entered a duplicate Constituent ID');
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void LegacyAddress(List<sObject> oldO, List<sObject> newO, string type) {
    system.debug('<==LegacyAddress==>');
        List<Historical_Address__c> theAdds = new List<Historical_Address__c>();
        Historical_Address__c oldAdd;
        //if condition for type and Validator_cls.hasAlreadyDone() added by Nitin
        //To check record of contact object
        if(type == 'Contact')
        {
            //In few cases of contact records, trigger was firing twice. so it was creating two same
            //records of "other Address". To restrict on firing of trigger second time to create
            //record again I used this condition.  
            if(!Validator_cls.hasAlreadyDone())
            {
                Validator_cls.setAlreadyDone();
                //Validator_cls.setAlreadyDone1();
                List<Contact> cOld = (List<contact>)oldO;
                system.debug('hii old' +cOld);
                List<Contact> cNew = (List<contact>)newO;  
                system.debug('hii old' +cNew);  
                //Scott April-25-11: go through all the contact pairs
                for (Integer i = 0; i < cOld.size(); i++)
                {
                    //Scott April-25-11: all the address fields are identical, don't need to make any historical addies
                    if (cOld[i].MailingStreet == cNew[i].MailingStreet && 
                        cOld[i].MailingCity == cNew[i].MailingCity && 
                        cOld[i].MailingPostalCode == cNew[i].MailingPostalCode && 
                        cOld[i].MailingState == cNew[i].MailingState && 
                        cOld[i].MailingCountry == cNew[i].MailingCountry && 
                        cOld[i].OtherStreet == cNew[i].OtherStreet && 
                        cOld[i].OtherCity == cNew[i].OtherCity && 
                        cOld[i].OtherPostalCode == cNew[i].OtherPostalCode && 
                        cOld[i].OtherState == cNew[i].OtherState && 
                        cOld[i].OtherCountry == cNew[i].OtherCountry)
                    {          
                        system.debug('No Changes');
                        continue;    
                    }
                    //Scott April-25-11: there is a change to the Primary addie, lets archive the old one
                    if (cOld[i].MailingStreet != cNew[i].MailingStreet ||
                        cOld[i].MailingCity != cNew[i].MailingCity || 
                        cOld[i].MailingPostalCode != cNew[i].MailingPostalCode || 
                        cOld[i].MailingState != cNew[i].MailingState || 
                        cOld[i].MailingCountry != cNew[i].MailingCountry)
                    {
                        if (cOld[i].MailingStreet != null ||
                            cOld[i].MailingCity != null ||
                            cOld[i].MailingCountry != null ||
                            cOld[i].MailingPostalCode != null ||
                            cOld[i].MailingState != null)
                        { 
                            system.debug('Mailing Changes');
                            oldAdd = new Historical_Address__c(); 
                            if (cOld[i].MailingStreet != null)
                            {    
                                if (cOld[i].MailingStreet.length() < 60){
                                    if(cOld[i].MailingStreet.contains('\n')){
                                        List<String> otheradd = cOld[i].MailingStreet.split('\n');
                                        system.debug('Nitin otheradd===='+otheradd);
                                        system.debug('Nitin otheradd===='+otheradd.size());
                                        oldAdd.Address_1__c = otheradd[0];
                                        oldAdd.Address_2__c = '';
                                        for(integer k = 1; k < otheradd.size(); k++){
                                            oldAdd.Address_2__c += otheradd[k];
                                        }
                                    } else
                                    {
                                        oldAdd.Address_1__c = cOld[i].MailingStreet;
                                    } 
                                }
                                if (cOld[i].MailingStreet.length() >= 60){ 
                                    if(cOld[i].MailingStreet.contains('\n')){
                                        List<String> otheradd = cOld[i].MailingStreet.split('\n');
                                        oldAdd.Address_1__c = otheradd[0];
                                        oldAdd.Address_2__c = '';
                                        for(integer k = 1; k < otheradd.size(); k++){
                                            oldAdd.Address_2__c += otheradd[k];
                                        }
                                    } else
                                    {
                                        oldAdd.Address_1__c = cOld[i].MailingStreet.substring(0, 59); 
                                    }
                                }                
                            }
                            oldAdd.City__c = cOld[i].MailingCity;
                            oldAdd.Country__c = cOld[i].MailingCountry;
                            oldAdd.Postal_Code__c = cOld[i].MailingPostalCode;
                            oldAdd.Province__c = cOld[i].MailingState;            
                            oldAdd.Date_To__c = Date.today();
                            oldAdd.Address_Type__c = 'Mailing';            
                            //if (cOld[i].npe01__Primary_Address_Type__c == 'Work')
                                //{ oldAdd.Address_Type__c = 'Business'; }
                            //if (cOld[i].npe01__Primary_Address_Type__c == 'Home')
                                //{ oldAdd.Address_Type__c = 'Home'; }
                            //Scott April-25-11: attach the Historical_Address__c to the contact
                            oldAdd.Contact__c = cOld[i].Id;
                            
                            //Scott April-25-11: Don't want to insert blank historical addies
                            theAdds.add(oldAdd); 
                            system.debug('theAdds'+theAdds);
                        }            
                    }
                    //system.debug('Nitin OtherStreet===='+cOld[i].OtherStreet);
                    //system.debug('Nitin OtherStreet===='+cOld[i].OtherStreet.contains('\n'));
                    //Scott April-25-11: there was a change to the secondary addie, lets archive the old one
                    if (cOld[i].OtherStreet != cNew[i].OtherStreet || 
                        cOld[i].OtherCity != cNew[i].OtherCity || 
                        cOld[i].OtherPostalCode != cNew[i].OtherPostalCode || 
                        cOld[i].OtherState != cNew[i].OtherState || 
                        cOld[i].OtherCountry != cNew[i].OtherCountry)
                    {
                        if (cOld[i].OtherStreet != null ||
                            cOld[i].OtherCity != null ||
                            cOld[i].OtherCountry != null ||
                            cOld[i].OtherPostalCode != null ||
                            cOld[i].OtherState != null)
                        { 
                            system.debug('Other Changes');
                            oldAdd = new Historical_Address__c();
                            if (cOld[i].OtherStreet != null)
                            {
                                if (cOld[i].OtherStreet.length() < 60){
                                    if(cOld[i].OtherStreet.contains('\n')){
                                        List<String> otheradd = cOld[i].OtherStreet.split('\n');
                                        system.debug('Nitin otheradd===='+otheradd);
                                        system.debug('Nitin otheradd===='+otheradd.size());
                                        oldAdd.Address_1__c = otheradd[0];
                                        oldAdd.Address_2__c = '';
                                        for(integer k = 1; k < otheradd.size(); k++){
                                            oldAdd.Address_2__c += otheradd[k];
                                        }
                                    } else
                                    {
                                        oldAdd.Address_1__c = cOld[i].OtherStreet;
                                    } 
                                }
                                if (cOld[i].OtherStreet.length() >= 60){ 
                                    if(cOld[i].OtherStreet.contains('\n')){
                                        List<String> otheradd = cOld[i].OtherStreet.split('\n');
                                        oldAdd.Address_1__c = otheradd[0];
                                        oldAdd.Address_2__c = '';
                                        for(integer k = 1; k < otheradd.size(); k++){
                                            oldAdd.Address_2__c += otheradd[k];
                                        }
                                    } else
                                    {
                                        oldAdd.Address_1__c = cOld[i].OtherStreet.substring(0, 59); 
                                    }
                                }
                            }
                            oldAdd.City__c = cOld[i].OtherCity;
                            oldAdd.Country__c = cOld[i].OtherCountry;
                            oldAdd.Postal_Code__c = cOld[i].OtherPostalCode;
                            oldAdd.Province__c = cOld[i].OtherState;            
                            oldAdd.Date_To__c = Date.today();
                            oldAdd.Address_Type__c = 'Other';                        
                            //if (cOld[i].npe01__Secondary_Address_Type__c == 'Work')
                                //{ oldAdd.Address_Type__c = 'Business'; }
                            //if (cOld[i].npe01__Secondary_Address_Type__c == 'Home')
                                //{ oldAdd.Address_Type__c = 'Home'; }                        
                            //Scott April-25-11: Attach the Historical_Address__c to the contact
                            oldAdd.Contact__c = cOld[i].Id;
                
                            //Scott April-25-11: Don't want to insert blank historical addies
                            theAdds.add(oldAdd);
                            system.debug('theAdds'+theAdds); 
                        }                        
                    }                                
                }
            }
        }
        //To create "other address" record for Account
        Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();        
        if(type == 'Account')
        {
        
            
            system.debug('<==Inside Account==>');
            List<Account> acOld = (List<Account>)oldO;
            List<Account> acNew = (List<Account>)newO;    
            //Scott April-25-11: go through all the contact pairs
            for (Integer i = 0; i < acOld.size(); i++)
            {
                //Scott April-25-11: all the address fields are identical, don't need to make any historical addies
                if (acOld[i].BillingStreet == acNew[i].BillingStreet && 
                    acOld[i].BillingCity == acNew[i].BillingCity && 
                    acOld[i].BillingPostalCode == acNew[i].BillingPostalCode && 
                    acOld[i].BillingState == acNew[i].BillingState && 
                    acOld[i].BillingCountry == acNew[i].BillingCountry && 
                    acOld[i].ShippingStreet == acNew[i].ShippingStreet && 
                    acOld[i].ShippingCity == acNew[i].ShippingCity && 
                    acOld[i].ShippingPostalCode == acNew[i].ShippingPostalCode && 
                    acOld[i].ShippingState == acNew[i].ShippingState && 
                    acOld[i].ShippingCountry == acNew[i].ShippingCountry)
                {          
                    system.debug('No Changes');
                    continue;    
                }
                //Scott April-25-11: there is a change to the Primary addie, lets archive the old one
                if (acOld[i].BillingStreet != acNew[i].BillingStreet ||
                    acOld[i].BillingCity != acNew[i].BillingCity || 
                    acOld[i].BillingPostalCode != acNew[i].BillingPostalCode || 
                    acOld[i].BillingState != acNew[i].BillingState || 
                    acOld[i].BillingCountry != acNew[i].BillingCountry)
                {
                    if (acOld[i].BillingStreet != null || acOld[i].BillingStreet != '' ||
                        acOld[i].BillingCity != null || acOld[i].BillingCity != '' ||
                        acOld[i].BillingCountry != null || acOld[i].BillingCountry != '' ||
                        acOld[i].BillingPostalCode != null || acOld[i].BillingPostalCode != '' ||
                        acOld[i].BillingState != null || acOld[i].BillingState != '')
                    { 
                        system.debug(acOld[i].BillingStreet);
                        oldAdd = new Historical_Address__c();
                        if (acOld[i].BillingStreet != null)
                        {
                            if (acOld[i].BillingStreet.length() < 60){
                                if(acOld[i].BillingStreet.contains('\n')){
                                    List<String> otheradd = acOld[i].BillingStreet.split('\n');
                                    system.debug('Nitin otheradd===='+otheradd);
                                    system.debug('Nitin otheradd===='+otheradd.size());
                                    oldAdd.Address_1__c = otheradd[0];
                                    oldAdd.Address_2__c = '';
                                    for(integer k = 1; k < otheradd.size(); k++){
                                        oldAdd.Address_2__c += otheradd[k];
                                    }
                                } else
                                {
                                    oldAdd.Address_1__c = acOld[i].BillingStreet;
                                } 
                            }
                            if (acOld[i].BillingStreet.length() >= 60){ 
                                if(acOld[i].BillingStreet.contains('\n')){
                                    List<String> otheradd = acOld[i].BillingStreet.split('\n');
                                    oldAdd.Address_1__c = otheradd[0];
                                    oldAdd.Address_2__c = '';
                                    for(integer k = 1; k < otheradd.size(); k++){
                                        oldAdd.Address_2__c += otheradd[k];
                                    }
                                } else
                                {
                                    oldAdd.Address_1__c = acOld[i].BillingStreet.substring(0, 59); 
                                }
                            }     
                        }           
                        oldAdd.City__c = acOld[i].BillingCity;
                        oldAdd.Country__c = acOld[i].BillingCountry;
                        oldAdd.Postal_Code__c = acOld[i].BillingPostalCode;
                        oldAdd.Province__c = acOld[i].BillingState;            
                        oldAdd.Date_To__c = Date.today();
                        //oldAdd.Address_Type__c = 'Billing';
                        //Scott April-25-11: attach the Historical_Address__c to the org
                        oldAdd.Organization__c = acOld[i].Id;
                        
                        if(rt_map.get(acOld[i].recordTypeID).getName()=='Household'){  //story:#106969638
                            oldAdd.Address_Type__c = 'Previous';
                        }else{
                            oldAdd.Address_Type__c = 'Billing';
                        }
                        
                        //Scott April-25-11: Don't want to insert blank historical addies
                        theAdds.add(oldAdd); 
                    }                
                }
                
                //Scott April-25-11: there was a change to the secondary addie, lets archive the old one
                if (acOld[i].ShippingStreet != acNew[i].ShippingStreet || 
                    acOld[i].ShippingCity != acNew[i].ShippingCity || 
                    acOld[i].ShippingPostalCode != acNew[i].ShippingPostalCode || 
                    acOld[i].ShippingState != acNew[i].ShippingState || 
                    acOld[i].ShippingCountry != acNew[i].ShippingCountry)
                {
                    if (acOld[i].ShippingStreet != null ||
                        acOld[i].ShippingCity != null ||
                        acOld[i].ShippingCountry != null ||
                        acOld[i].ShippingPostalCode != null ||
                        acOld[i].ShippingState != null)
                    { 
                        system.debug('Shipping Changes');
                        oldAdd = new Historical_Address__c();  
                        if (acOld[i].ShippingStreet != null)
                        {         
                            if (acOld[i].ShippingStreet.length() < 60){
                                if(acOld[i].ShippingStreet.contains('\n')){
                                    List<String> otheradd = acOld[i].ShippingStreet.split('\n');
                                    system.debug('Nitin otheradd===='+otheradd);
                                    system.debug('Nitin otheradd===='+otheradd.size());
                                    oldAdd.Address_1__c = otheradd[0];
                                    oldAdd.Address_2__c = '';
                                    for(integer k = 1; k < otheradd.size(); k++){
                                        oldAdd.Address_2__c += otheradd[k];
                                    }
                                } else
                                {
                                    oldAdd.Address_1__c = acOld[i].ShippingStreet;
                                } 
                            }
                            if (acOld[i].ShippingStreet.length() >= 60){ 
                                if(acOld[i].ShippingStreet.contains('\n')){
                                    List<String> otheradd = acOld[i].ShippingStreet.split('\n');
                                    oldAdd.Address_1__c = otheradd[0];
                                    oldAdd.Address_2__c = '';
                                    for(integer k = 1; k < otheradd.size(); k++){
                                        oldAdd.Address_2__c += otheradd[k];
                                    }
                                } else
                                {
                                    oldAdd.Address_1__c = acOld[i].ShippingStreet.substring(0, 59); 
                                }
                            }                 
                        }
                        oldAdd.City__c = acOld[i].ShippingCity;
                        oldAdd.Country__c = acOld[i].ShippingCountry;
                        oldAdd.Postal_Code__c = acOld[i].ShippingPostalCode;
                        oldAdd.Province__c = acOld[i].ShippingState;            
                        oldAdd.Date_To__c = Date.today();    
                        oldAdd.Address_Type__c = 'Shipping';
                        //Scott April-25-11: Attach the Historical_Address__c to the org
                        oldAdd.Organization__c = acOld[i].Id;
            
                        //Scott April-25-11: Don't want to insert blank historical addies
                        theAdds.add(oldAdd); 
                    }        
                }                                
            }
            
            
        }
        if(theAdds.size()>0){
            insert theAdds;   
        }
    }
    
    public static void LegacyAddressOfHousehold(List<Contact> contNew) {  //story:#106969638
    
      if(!Validator_cls.hasAlreadyDone1()) {
      system.debug('first time running' );
        map<string, list<contact>> hhToContMap = new map<string, list<contact>>();
        for(contact con: contNew ){
            if(con.causeview__Household__c !=null && con.causeview__Same_as_Household__c==true){
                if(hhToContMap.containsKey(con.causeview__Household__c)){
                    hhToContMap.get(con.causeview__Household__c).add(con);
                }else{
                    list<contact> temp = new list<contact>();
                    temp.add(con);
                    hhToContMap.put(con.causeview__Household__c, temp);
                }
                
            }
            
            }
        
        if(hhToContMap.size()>0){
            list<account> accts = [select BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry from account where id in : hhToContMap.keySet()];            
            for(account acc : accts){
                acc.BillingStreet= hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size())-1].MailingStreet;                
                acc.BillingCity= hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size())-1].MailingCity;
                acc.BillingPostalCode= hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size())-1].MailingPostalCode;
                acc.BillingState= hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size())-1].MailingState;
                acc.BillingCountry= hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size())-1].MailingCountry;              
                
            }            
            update accts;
        }    
      }
    }
    
    public static void PopulateBucketAccount(List<sObject> constituents) {
        system.debug('<=PopulateBucketAccount=>');
        BatchSettings__c setting = BatchSettings__c.getInstance('Default');
        for (Contact c : (List<contact>)constituents)    
        {
            if (c.AccountId == null && setting != null)
            { c.AccountId = setting.BucketAccountId__c; }
        }
    }
    
    //@future
   /* public static void CreateHousehold(List<Contact> conRecord) {
  
        system.debug('<=CreateHousehold=>');
        /*List<Contact> conRecord = [Select Salutation, FirstName, LastName, causeview__Household__c, AccountId, MailingStreet, HomePhone,
                                    MailingCity, MailingCountry, MailingPostalCode, MailingState, causeview__Primary_Addressee__c, causeview__Primary_Salutation__c,
                                    Email, causeview__Household_Primary_Contact__c, Same_as_Household__c, Use_Household_Salutation_Addressee__c from contact
                                    where Id IN : conId];
        system.debug('Nitin Contact===='+conRecord);
        //system.debug('Nitin Contact HouseHold===='+conRecord[0].causeview__Household__c);
        App_Settings__c cs = App_Settings__c.getInstance();
        BatchSettings__c setting = BatchSettings__c.getInstance('Default');
        RecordType retype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Household' AND NamespacePrefix = 'causeview' Limit 1];
        system.debug('Nitin R Id==='+retype);
        system.debug('Nitin Cs===='+cs);
        List<Account> households = new List<Account>();
        List<Contact> conList = new List<Contact>();
        Map<String, Account> contact_to_household = new Map<String, Account>();
        for (Contact c : conRecord) {
            if(c.causeview__Household__c == null && ((cs.causeview__Auto_Create_Household__c == 'IND' && c.AccountId == setting.BucketAccountId__c) || cs.causeview__Auto_Create_Household__c == 'ALL')) {                
                String acName = '';
                if (c.Salutation != null) {
                    acName += c.Salutation + ' ';
                } 
                if (c.FirstName != null) {
                    acName += c.FirstName + ' ';
                }
                if (c.LastName != null) {
                    acName += c.LastName;
                }
                
                Account acObj = new Account (Name = acName + ' ' + 'Household', 
                BillingStreet = c.MailingStreet, Phone = c.HomePhone, BillingCity = c.MailingCity, BillingCountry = c.MailingCountry,
                BillingPostalCode = c.MailingPostalCode, BillingState = c.MailingState, causeview__Household_Addressee__c = c.causeview__Primary_Addressee__c,
                causeview__Household_Salutation__c = c.causeview__Primary_Salutation__c, causeview__Email__c = c.Email, RecordTypeId = retype.Id);
                system.debug('Nitin R Id==='+acObj);
                system.debug('Nitin Salutation==='+c.Salutation);
                if(acObj.causeview__Household_Addressee__c == null){
                    acObj.causeview__Household_Addressee__c = c.Salutation == null ? c.FirstName +' '+ c.LastName : c.Salutation +' '+c.FirstName +' '+ c.LastName;
                }
                if(acObj.causeview__Household_Salutation__c == null){
                    acObj.causeview__Household_Salutation__c = c.Salutation == null ? c.FirstName +' '+ c.LastName : c.Salutation +' '+ c.LastName;
                }
                households.add(acObj);                
                c.causeview__Household_Primary_Contact__c = true;
                //commented by nitin
                contact_to_household.put(c.Id, acObj);
                system.debug('<==here==>');
                if(c.FirstName != null && c.Email != null){
                    contact_to_household.put(c.FirstName+c.LastName+c.Email, acObj);
                }else
                if(c.FirstName == null && c.Email != null){
                    contact_to_household.put(c.LastName+c.Email, acObj);
                }else
                if(c.FirstName != null && c.Email == null){
                    contact_to_household.put(c.FirstName+c.LastName, acObj);
                }else
                if(c.FirstName == null && c.Email == null){
                    contact_to_household.put(c.LastName, acObj);    
                }
            }    
        }
        system.debug('Nitin R Id==='+households);
        if(households.size() > 0)
        insert households;
        
        for(Contact c : conRecord) {
            //commented by nitin
            Account hh;
            if(contact_to_household.get(c.Id) != null){
                hh = contact_to_household.get(c.Id);
            }
            system.debug('Nitin Contcat 2===='+c);
            //Account hh = new Account();
            if(c.FirstName != null && c.Email != null){
                hh = contact_to_household.get(c.FirstName+c.LastName+c.Email);
            }else
            if(c.FirstName == null && c.Email != null){
                hh = contact_to_household.get(c.LastName+c.Email);
            }else
            if(c.FirstName != null && c.Email == null){
                hh = contact_to_household.get(c.FirstName+c.LastName);
            }else
            if(c.FirstName == null && c.Email == null){
                hh = contact_to_household.get(c.LastName);    
            }
            system.debug('hh==>'+hh);
            if (hh != null) {
                system.debug('<==Here inside Account==>'+hh);
                c.Household__c = hh.Id;
                c.Same_as_Household__c = true;
                c.Use_Household_Salutation_Addressee__c = true;
                //conList.add(c);
            }
        }
        /*system.debug('Nitin Test Check===='+conList);
        if(conList.size() > 0){
            update conList;
        }     
    } */
    
    // vijayshree createHouseholdupdate
    
    //@future
     public static void CreateHouseholdupdate(List<sObject> constituents) {
  
        system.debug('<=CreateHousehold=>');
        /*List<Contact> conRecord = [Select Salutation, FirstName, LastName, causeview__Household__c, AccountId, MailingStreet, HomePhone,
                                    MailingCity, MailingCountry, MailingPostalCode, MailingState, causeview__Primary_Addressee__c, causeview__Primary_Salutation__c,
                                    Email, causeview__Household_Primary_Contact__c, Same_as_Household__c, Use_Household_Salutation_Addressee__c from contact
                                    where Id IN : conId];*/
        system.debug('Nitin Contact===='+constituents);
        //system.debug('Nitin Contact HouseHold===='+conRecord[0].causeview__Household__c);
        App_Settings__c cs = App_Settings__c.getInstance();
        BatchSettings__c setting = BatchSettings__c.getInstance('Default');
        RecordType retype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Household' AND NamespacePrefix = 'causeview' Limit 1];
        system.debug('Nitin R Id==='+retype);
        system.debug('Nitin Cs===='+cs);
        List<Account> households = new List<Account>();
        List<Contact> conList = new List<Contact>();
        Map<String, Account> contact_to_household = new Map<String, Account>();
        for (Contact c :(List<contact>) constituents) {
            if(c.causeview__Household__c == null && ((cs.causeview__Auto_Create_Household__c == 'IND' && c.AccountId == setting.BucketAccountId__c) || cs.causeview__Auto_Create_Household__c == 'ALL')) {                
                String acName = '';
                if (c.Salutation != null) {
                    acName += c.Salutation + ' ';
                } 
                if (c.FirstName != null) {
                    acName += c.FirstName + ' ';
                }
                if (c.LastName != null) {
                    acName += c.LastName;
                }
                
                Account acObj = new Account (Name = acName + ' ' + 'Household', 
                BillingStreet = c.MailingStreet, Phone = c.HomePhone, BillingCity = c.MailingCity, BillingCountry = c.MailingCountry,
                BillingPostalCode = c.MailingPostalCode, BillingState = c.MailingState, causeview__Household_Addressee__c = c.causeview__Primary_Addressee__c,
                causeview__Household_Salutation__c = c.causeview__Primary_Salutation__c, causeview__Email__c = c.Email, RecordTypeId = retype.Id);
                system.debug('Nitin R Id==='+acObj);
                system.debug('Nitin Salutation==='+c.Salutation);
                if(acObj.causeview__Household_Addressee__c == null){
                    acObj.causeview__Household_Addressee__c = c.Salutation == null ? c.FirstName +' '+ c.LastName : c.Salutation +' '+c.FirstName +' '+ c.LastName;
                }
                if(acObj.causeview__Household_Salutation__c == null){
                    acObj.causeview__Household_Salutation__c = c.Salutation == null ? c.FirstName +' '+ c.LastName : c.Salutation +' '+ c.LastName;
                }
                households.add(acObj);                
                c.causeview__Household_Primary_Contact__c = true;
                //commented by nitin
                contact_to_household.put(c.Id, acObj);
                system.debug('<==here==>');
                if(c.FirstName != null && c.Email != null){
                    contact_to_household.put(c.FirstName+c.LastName+c.Email, acObj);
                }else
                if(c.FirstName == null && c.Email != null){
                    contact_to_household.put(c.LastName+c.Email, acObj);
                }else
                if(c.FirstName != null && c.Email == null){
                    contact_to_household.put(c.FirstName+c.LastName, acObj);
                }else
                if(c.FirstName == null && c.Email == null){
                    contact_to_household.put(c.LastName, acObj);    
                }
            }    
        }
        system.debug('Nitin R Id==='+households);
        if(households.size() > 0)
        insert households;
        
        for(Contact c : (List<contact>) constituents) {
            //commented by nitin
            Account hh;
            if(contact_to_household.get(c.Id) != null){
                hh = contact_to_household.get(c.Id);
            }
            system.debug('Nitin Contcat 2===='+c);
            //Account hh = new Account();
            if(c.FirstName != null && c.Email != null){
                hh = contact_to_household.get(c.FirstName+c.LastName+c.Email);
            }else
            if(c.FirstName == null && c.Email != null){
                hh = contact_to_household.get(c.LastName+c.Email);
            }else
            if(c.FirstName != null && c.Email == null){
                hh = contact_to_household.get(c.FirstName+c.LastName);
            }else
            if(c.FirstName == null && c.Email == null){
                hh = contact_to_household.get(c.LastName);    
            }
            system.debug('hh==>'+hh);
            if (hh != null) {
                system.debug('<==Here inside Account==>'+hh);
                c.Household__c = hh.Id;
                c.Same_as_Household__c = true;
                c.Use_Household_Salutation_Addressee__c = true;
                //conList.add(c);
            }
        }
        system.debug('contact updates----1');
        /*system.debug('Nitin Test Check===='+conList);
        if(conList.size() > 0){
            update conList;
        } */     
    }
    
    
    public static void UpdateHouseholdRollups(List<Contact> cOld, List<Contact> cNew) {
        Set<Id> cIds = new Set<Id>();
        if (cOld == null) {
            for (Contact c : cNew) {
                cIds.add(c.Household__c);
            }         
        }
        if (cNew == null) {
            for (Contact c : cOld) {
                cIds.add(c.Household__c);
            }
        }
        else {        
            for (Integer i = 0; i < cNew.size(); i++) {
                if (cOld[i].Household__c != cNew[i].Household__c) {
                    System.debug(cOld[i].Household__c);
                    System.debug(cNew[i].Household__c);                
                    cIds.add(cNew[i].Household__c);
                }
            }
        }
        RollupHelper.RecalculateTotalHouseholdGiving(cIds); 
    }
}
