public without sharing class VolunteerUtil {
    
public static void RecalculateOpportunityStatus(Set<String> oppIds) {
           List<Volunteer_Opportunity__c> theOpps = [SELECT Id, Status__c, (SELECT Id, Role_Status__c FROM Volunteer_Positions__r) FROM Volunteer_Opportunity__c WHERE Id IN :oppIds AND (Status__c = 'Open' OR Status__c = 'Filled')];
           Boolean isOpen;
           
           for (Volunteer_Opportunity__c opp : theOpps)
           {
               isOpen = True;
               for (Volunteer_Role__c vp : opp.Volunteer_Positions__r)
               {
                   if (vp.Role_Status__c == 'Filled')
                   { isOpen = False; }
                   if (vp.Role_Status__c == 'Open')
                   { isOpen = True; break; }               
               }
               if (isOpen) { opp.Status__c = 'Open'; }
               else { opp.Status__c = 'Filled'; }
           }
           
           update theOpps;
       }
       
       public static Contact upsertContactOnEmail(Contact c) {
           Contact retVal = new Contact();
           if (c.Id != null) { return c; }
           if (c.Email != '' && c.Email != null)
           {       
               List<Contact> results = [SELECT Id FROM Contact WHERE Email = :c.Email];
               if (results.size() == 1) 
               { 
                   return results[0];            
               }
           }
           insert c;
           return c;        
       }
    
       public static void RollupHours(Set<String> hIds) {
           Set<String> volIds = new Set<String>();         
           Set<String> orgIds = new Set<String>();                       
           
           for(Volunteer_Hours__c vh : [SELECT Id, Volunteer__c, Volunteer__r.AccountId FROM Volunteer_Hours__c WHERE Id IN :hIds])
           {
              volIds.add(vh.Volunteer__c);                              
              orgIds.add(vh.Volunteer__r.AccountId);           
           }
           
           List<Contact> vols = [SELECT AccountId, Id, Total_Service_Hours_Completed_This_Year__c, Total_Miles_Traveled_This_Year__c, (SELECT Id, Service_Hours_Completed__c, Mileage__c FROM Volunteer_Hours__r WHERE End_Day__c = THIS_FISCAL_YEAR AND Status__c = 'Confirmed')  FROM Contact WHERE Id IN :volIds];
           //Map<String, Account> AccountMap = new Map<String, Account>([SELECT Total_Service_Hours_Completed_This_Year__c, Total_Service_Hours_Completed__c, Total_Miles_Traveled_This_Year__c, Total_Miles_Traveled__c, Id FROM Account WHERE Id IN :orgIds]);
                  
           for (Contact vol : vols)
           {
               Decimal Total_Serv = 0;
               Decimal Total_Mile = 0;
               for (Volunteer_Hours__c vh : vol.Volunteer_Hours__r)
               {
                   if (vh.Service_Hours_Completed__c != null) { Total_Serv += vh.Service_Hours_Completed__c; }
                   if (vh.Mileage__c != null) { Total_Mile += vh.Mileage__c; }
               }
               vol.Total_Service_Hours_Completed_This_Year__c = Total_Serv;
               vol.Total_Miles_Traveled_This_Year__c = Total_Mile;
           }   
           
           update vols; 
           
           List<Account> orgs = [SELECT Id, Total_Service_Hours_Completed_This_Year__c, Total_Service_Hours_Completed__c, Total_Miles_Traveled_This_Year__c, Total_Miles_Traveled__c, (SELECT Total_Service_Hours_Completed_This_Year__c, Total_Miles_Traveled_This_Year__c, Total_Miles_Traveled__c, Total_Service_Hours_Completed__c FROM Contacts) FROM Account WHERE Id IN :orgIds AND Id != '001d000000BYfW0AAL'];                                                            
           for (Account a : orgs)
           {
               Decimal Total_Serv = 0;
               Decimal Total_Mile = 0;
               Decimal Total_Serv_FY = 0;
               Decimal Total_Mile_FY = 0;          
               for (Contact c : a.Contacts)
               {
                   if (a.Total_Service_Hours_Completed__c != null) { Total_Serv += a.Total_Service_Hours_Completed__c; }
                   if (a.Total_Miles_Traveled__c != null) { Total_Mile += a.Total_Miles_Traveled__c; }
                   if (a.Total_Service_Hours_Completed_This_Year__c != null) { Total_Serv_FY += a.Total_Service_Hours_Completed_This_Year__c; }
                   if (a.Total_Miles_Traveled_This_Year__c != null) { Total_Mile_FY += a.Total_Miles_Traveled_This_Year__c; }                                
               }
               a.Total_Service_Hours_Completed_This_Year__c = Total_Serv_FY;
               a.Total_Miles_Traveled_This_Year__c = Total_Mile_FY;
               a.Total_Service_Hours_Completed__c = Total_Serv;
               a.Total_Miles_Traveled__c = Total_Mile;                                  
           }      
           update orgs; 
       }
    
       public static boolean isEmptyOrNull(String value)
       {
           return (value==null)||(value=='');
       }
        
       public static void serializeShiftWrapper(ShiftWrapper theWrap) {                    
            if (theWrap.theShift.Frequency__c != 'Flexible')
            {
                theWrap.theShift.Start_Time__c = getDateTime(theWrap.theShift.Start_Day__c, theWrap.startHours, theWrap.startMins, theWrap.startMeridiemOffset);
                theWrap.theShift.End_Time__c = getDateTime(theWrap.theShift.End_Day__c, theWrap.endHours, theWrap.endMins, theWrap.endMeridiemOffset);
                theWrap.theShift.Day_of_the_week__c = getDayOfWeek(theWrap.theShift.Shift_Date__c);
            }
       }       
    
       public static DateTime getDateTime(string hours, string mins, string meridium) {
           return DateTime.parse('1/1/1970 ' + hours + ':' + mins + ' ' + meridium);
       } 
    
       public static DateTime getDateTime(Date d, string hours, string mins, string meridium) {
           system.debug(d);
           system.debug(hours);
           system.debug(mins);
           system.debug(meridium);                     
           if (UserInfo.getLocale() == 'en_US') {
               return DateTime.parse(d.Month() + '/' + d.Day() + '/' + d.Year() + ' ' + hours + ':' + mins + ' ' + meridium);
           }
           if (UserInfo.getLocale() == 'en_CA') {
               return DateTime.parse(d.Day() + '/' + d.Month() + '/' + d.Year() + ' ' + hours + ':' + mins + ' ' + meridium);
           }           
           return DateTime.parse(d.Month() + '/' + d.Day() + '/' + d.Year() + ' ' + hours + ':' + mins + ' ' + meridium);
       }        
    
       public static String getDayOfWeek(DateTime theDate) {
           Date weekStart = theDate.date().toStartofWeek();
           Integer dayOfWeek = weekStart.daysBetween(theDate.date());
           if (dayOfWeek == 6) { return 'Sunday'; }
           if (dayOfWeek == 0) { return 'Monday'; }
           if (dayOfWeek == 1) { return 'Tuesday'; }
           if (dayOfWeek == 2) { return 'Wednesday'; }
           if (dayOfWeek == 3) { return 'Thursday'; }
           if (dayOfWeek == 4) { return 'Friday'; }
           if (dayOfWeek == 5) { return 'Saturday'; }
           else { return 'Error'; }                                              
       }
    
       /*public static void sortList(List<ShiftWrapper> items, String sortField, String order){
           List<ShiftWrapper > resultList = new List<ShiftWrapper >();
      
           Map<object, List<ShiftWrapper >> objectMap = new Map<object, List<ShiftWrapper >>();
              
           for(ShiftWrapper ob : items){
                    if(objectMap.get(ob.theShift.get(sortField)) == null){
                        objectMap.put(ob.theShift.get(sortField), new List<ShiftWrapper >());
                    }
                    objectMap.get(ob.theShift.get(sortField)).add(ob);
            }      
    
            List<object> keys = new List<object>(objectMap.keySet());
            keys.sort();
          
            for(object key : keys){
                resultList.addAll(objectMap.get(key));
            }
    
            items.clear();
            if(order.toLowerCase() == 'asc'){
                for(ShiftWrapper ob : resultList){
                    items.add(ob);
                }
            }else if(order.toLowerCase() == 'desc'){
                for(integer i = resultList.size()-1; i >= 0; i--){
                    items.add(resultList[i]); 
                }
            }
        }*/
    
        public static List<Volunteer_Shift__c > getShiftsFromUser(String uId) { 
            List<Volunteer_Shift__c > retVal = new List<Volunteer_Shift__c >();            
  
    
            User u;
            List<User> users = [SELECT ContactId FROM User WHERE Id = :uId];
            if (users.size() > 0 && users != null) { u = users[0]; }
            
            if (u.ContactId == null)
            { return new List<Volunteer_Shift__c >(); }                  
            
            Contact c;
            List<Contact> contacts = [SELECT FirstName, LastName, (SELECT Id, Date_of_Background_Check__c, Status__c FROM Volunteer_Applications__r WHERE Status__c = 'Approved' OR Status__c = 'Placed'), Middle_Name__c, Salutation, Nickname__c, MailingStreet, Apt_Unit__c, MailingCity, MailingState, MailingPostalCode, 
                                      Phone, OtherPhone, Email, BirthDate, cv_pkg_dev_I__Gender__c FROM Contact WHERE Id = :u.ContactId];
            if (contacts.size() > 0 && contacts != null) { c = contacts[0]; }
            
            if (c != null)
            {
                retVal = [SELECT Id, Name, Volunteer_Role__c, Shift_Date__c, Frequency__c, Duration_Hours__c FROM Volunteer_Shift__c  WHERE Volunteer_Application__r.Volunteer__c = :c.Id AND Volunteer_Application__r.Status__c = 'Placed']; 
            }
                    
            return retVal;
        }   
        
        /*public static List<Volunteer_Application__c> getGroupAppsFromUser(String uId) { 
            List<Volunteer_Application__c> retVal = new List<Volunteer_Application__c>();      
            Set<String> OppIds = new Set<String>();         
    
            User u;
            List<User> users = [SELECT ContactId FROM User WHERE Id = :uId];
            if (users.size() > 0 && users != null) { u = users[0]; }
            
            if (u.ContactId == null )
            { return new List<Volunteer_Application__c>(); }                  
            
            Contact c;
            List<Contact> contacts = [SELECT FirstName, LastName, (SELECT Id, Date_of_Background_Check__c, Status__c FROM Volunteer_Applications__r WHERE Status__c = 'Approved' OR Status__c = 'Placed'), Middle_Name__c, Salutation, Nickname__c, MailingStreet, Apt_Unit__c, MailingCity, MailingState, MailingPostalCode, 
                                      Phone, OtherPhone, Email, BirthDate, cv_pkg_dev_I__Gender__c FROM Contact WHERE Id = :u.ContactId];
            if (contacts.size() > 0 && contacts != null) { c = contacts[0]; }
                  
            retVal = [SELECT Id, Volunteer_Role__c, Volunteer_Opportunity__c,Volunteer_Opportunity__r.Program__c, Volunteer_Opportunity__r.Id,Volunteer_Opportunity__r.Name,Volunteer_Opportunity__r.Opportunity_Start_Date__c,Volunteer_Opportunity__r.Opportunity_End_Date__c FROM Volunteer_Application__c WHERE Status__c = 'Placed' AND RecordTypeId = :settings.GroupParentRecordType__c AND Volunteer__c = :c.Id];        
          
            if(retVal.size() != 0 || retVal != null)
            { return retVal; }
            
            return new List<Volunteer_Application__c>();             
        }   */ 
        
       /* public static List<Volunteer_Application__c> getGroupMembersFromParent(string parentId) {
            VolunteerPortalSettings__c settings = VolunteerPortalSettings__c.getInstance('default');  
            List<Volunteer_Application__c> theGroupMembers = [SELECT Id, Volunteer__c, Volunteer__r.FirstName, Volunteer__r.LastName, Volunteer__r.Email, Volunteer_Role__c FROM Volunteer_Application__c WHERE Volunteer__c != :settings.UnknownContactId__c AND Parent_Volunteer_Application__c = :parentId];
            if(theGroupMembers.size() != 0 || theGroupMembers != null)
            { return theGroupMembers; }
                    
            return new List<Volunteer_Application__c>();
        }*/
    
        public static Integer getDuration(DateTime startTime, DateTime endTime) {
            return Integer.valueOf(((startTime.getTime() - endTime.getTime())/60000)/60);
        }
    
        public static Contact getContactFromUser(String uId) {                
 
    
            User u;
            List<User> users = [SELECT ContactId FROM User WHERE Id = :uId];
            if (users.size() > 0 && users != null) { u = users[0]; }
            
            if (u.ContactId == null)
            { return new Contact(); }                  
            
            Contact c;
            List<Contact> contacts = [SELECT Professional_Skills__c, Preferred_Program_1__c, Preferred_Program_2__c, cv_pkg_dev_I__Suffix__c, Account.Name, FirstName, LastName, 
                                        (SELECT Id, Date_of_Background_Check__c, Status__c FROM Volunteer_Applications__r WHERE 
                                        Status__c = 'Approved' OR Status__c = 'Placed'), Middle_Name__c, Salutation, Nickname__c, MailingStreet, Apt_Unit__c, MailingCity, MailingState, 
                                        MailingPostalCode, Phone, OtherPhone, Email, BirthDate, cv_pkg_dev_I__Gender__c
                                        FROM Contact WHERE Id = :u.ContactId];
                                        
            if (contacts.size() > 0 && contacts != null) { c = contacts[0]; }
                    
            return c;
        }
        
        public static Volunteer_Application__c getMostRecentAppFromUser(String uId) {                
    
            User u;
            List<User> users = [SELECT ContactId FROM User WHERE Id = :uId];
            if (users.size() > 0 && users != null) { u = users[0]; }
            
            if (u.ContactId == null )
            { return new Volunteer_Application__c(); }                  
            
            Volunteer_Application__c va = new Volunteer_Application__c();
            List<Volunteer_Application__c> apps = [SELECT Reference_Type3__c, Emergency_Contact__c, Id, Reference_Type1__c, Reference_Type2__c, Reasons_for_Volunteering__c, Currently_employed__c, Title__c, Description_of_Work__c, Programs_Offered_by_Employer__c,Name_of_Educational_Institution__c, Do_you_have_a_criminal_record__c, Will_you_submit_criminal_records_check__c, Education_Level__c, How_Did_You_Hear_About_Us__c,  Languages__c, Professional_Skills__c,Prefered_Locales__c, Miles_Willing_to_Travel_One_Way__c, Agree__c, Agree2__c FROM Volunteer_Application__c WHERE Volunteer__c = :u.ContactId AND RecordTypeId = '012d0000000siPV' ORDER BY LastModifiedDate DESC];
            if (apps.size() > 0 && apps != null) 
            {
                va = apps[0];
            }
                    
            return va;
        }    
        
        public static Set<String> getProgramSet(String uId) { 

            Set<String> theProgs = new Set<String>();
    
            User u;
            List<User> users = [SELECT ContactId FROM User WHERE Id = :uId];
            if (users.size() > 0 && users != null) { u = users[0]; }
            
            if (u.ContactId == null  )
            { return theProgs; }                  
            
            List<Volunteer_Application__c> apps = [SELECT Volunteer_Role__r.Volunteer_Opportunity__r.Program__c, Volunteer_Application__c.Volunteer_Role__c, Emergency_Contact__c, Id, Reference_Type1__c, Reference_Type2__c, Reasons_for_Volunteering__c, Currently_employed__c, Title__c, Description_of_Work__c, Programs_Offered_by_Employer__c, Name_of_Educational_Institution__c, Do_you_have_a_criminal_record__c, Will_you_submit_criminal_records_check__c, Education_Level__c, How_Did_You_Hear_About_Us__c, Languages__c, Professional_Skills__c,Prefered_Locales__c, Miles_Willing_to_Travel_One_Way__c, Agree__c, Agree2__c FROM Volunteer_Application__c WHERE Volunteer__c = :u.ContactId AND Status__c = 'Placed' ORDER BY LastModifiedDate DESC];
                    
            for (Volunteer_Application__c a : apps)
            {
                theProgs.add(a.Volunteer_Role__r.Volunteer_Opportunity__r.Program__c);
            }
            return theProgs;     
        }
        
        public static List<Volunteer_Application__c> getAppsFromUser(String uId) {                  
    
            User u;
            List<User> users = [SELECT ContactId FROM User WHERE Id = :uId];
            if (users.size() > 0 && users != null) { u = users[0]; }
            
            if (u.ContactId == null )
            { return new List<Volunteer_Application__c>(); }                  
            
            List<Volunteer_Application__c> apps = [SELECT Volunteer_Application__c.Volunteer_Role__c, Emergency_Contact__c, Id, Reference_Type1__c, Reference_Type2__c, Reasons_for_Volunteering__c, Currently_employed__c,  Title__c, Description_of_Work__c, Programs_Offered_by_Employer__c, Name_of_Educational_Institution__c, Do_you_have_a_criminal_record__c, Will_you_submit_criminal_records_check__c, Education_Level__c, How_Did_You_Hear_About_Us__c,  Languages__c,  Professional_Skills__c,Prefered_Locales__c, Miles_Willing_to_Travel_One_Way__c, Agree__c, Agree2__c FROM Volunteer_Application__c WHERE Volunteer__c = :u.ContactId ORDER BY LastModifiedDate DESC];
                    
            return apps;
        }        
    
        public static Integer getScreeningLevel(String uId) {
            return 0;
        }
    
        /*public static Map<String, Integer> getScreeningLevel(String uId) {
            Map<String, Integer> retVal = new Map<String, Integer>();
            
            User u;
            List<User> users = [SELECT ContactId FROM User WHERE Id = :uId];
            if (users.size() > 0 && users != null) { u = users[0]; }
            
            if (u.ContactId == null)
            { return null; }       
            
            List<Volunteer_Application__c> theApps = [SELECT Volunteer_Position__r.Volunteer_Opportunity__r.Program__c, Date_of_Background_Check__c FROM Volunteer_Application__c WHERE (Status__c = 'Approved' OR Status__c = 'Placed') AND Volunteer__c = :u.ContactId];
            Map<String, List<Volunteer_Application__c>> program_to_apps = new Map<String, List<Volunteer_Application__c>>();
            Set<String> programs = new Set<String>();
            
            for (Volunteer_Application__c va : theApps)
            {
                programs.add(va.Volunteer_Position__r.Volunteer_Opportunity__r.Program__c);
            }
            
            for (String pId : programs)
            {
                List<Volunteer_Application__c> bufferApps = new List<Volunteer_Application__c>();
                for (Volunteer_Application__c va : theApps)
                {
                    if (va.Volunteer_Position__r.Volunteer_Opportunity__r.Program__c == pId)
                    {
                        bufferApps.add(va);
                    }
                }
                program_to_apps.put(pId, bufferApps);
            }
            
            for (String pId : programs)
            {
                Integer screeningLevel = 1;
                for (Volunteer_Application__c va : program_to_apps.get(pId))
                {
                    if (va.Date_of_Background_Check__c != null)
                    { screeningLevel = 2; }            
                }
                retVal.put(pId, screeningLevel);
            }
            
            return retVal;
        }*/
    
        /*public static Map<String, Integer> getScreeningLevelFromContact(String cId) {
            Map<String, Integer> retVal = new Map<String, Integer>();
            
            List<Volunteer_Application__c> theApps = [SELECT Volunteer_Position__r.Volunteer_Opportunity__r.Program__c, Date_of_Background_Check__c FROM Volunteer_Application__c WHERE (Status__c = 'Approved' OR Status__c = 'Placed') AND Volunteer__c = :cId];
            Map<String, List<Volunteer_Application__c>> program_to_apps = new Map<String, List<Volunteer_Application__c>>();
            Set<String> programs = new Set<String>();
            
            for (Volunteer_Application__c va : theApps)
            {
                programs.add(va.Volunteer_Position__r.Volunteer_Opportunity__r.Program__c);
            }
            
            for (String pId : programs)
            {
                List<Volunteer_Application__c> bufferApps = new List<Volunteer_Application__c>();
                for (Volunteer_Application__c va : theApps)
                {
                    if (va.Volunteer_Position__r.Volunteer_Opportunity__r.Program__c == pId)
                    {
                        bufferApps.add(va);
                    }
                }
                program_to_apps.put(pId, bufferApps);
            }
            
            for (String pId : programs)
            {
                Integer screeningLevel = 1;
                for (Volunteer_Application__c va : program_to_apps.get(pId))
                {
                    if (va.Date_of_Background_Check__c != null)
                    { screeningLevel = 2; }            
                }
                retVal.put(pId, screeningLevel);
            }
            
            return retVal;
        }    */
        
        public static Integer getScreeningLevelFromContact(String cId) {
           return 0;
        }
        
        /*public static void RecalculateScreeningLevel(Set<String> CIDs) {
          
        }*/
        
        public static void updateVolunteerProfile(List<Volunteer_Application__c> theApps)
        {
            App_Settings__c app_settings = App_Settings__c.getInstance();
            Set<String> CIDs = new Set<String>();
            List<Contact> contacts = new List<Contact>();
            Map<String, Volunteer_Application__c> cid_to_app = new Map<String, Volunteer_Application__c>();
            
            for(Volunteer_Application__c va : theApps)
            {
                if(va.Volunteer__c == null || va.RecordTypeId != app_settings.Individual_App_RecordtypeId__c)
                { continue; }
                
                CIDs.add(va.Volunteer__c);
                cid_to_app.put(va.Volunteer__c, va);            
            }      
            
            contacts = [SELECT AccountId,Age__c,Currently_employed__c,AssistantName,AssistantPhone,Birthdate,cv_pkg_dev_I__Anonymous__c,cv_pkg_dev_I__Appeal_Recovery_Gift_Date__c,
                        cv_pkg_dev_I__Consecutive_Years_of_Giving__c,cv_pkg_dev_I__Consecutive_Years_of_Transactions__c,cv_pkg_dev_I__Constituent_Codes__c,cv_pkg_dev_I__Constituent_Count__c,
                        cv_pkg_dev_I__Constituent_ID__c,cv_pkg_dev_I__Date_of_First_Gift__c,cv_pkg_dev_I__Date_of_Last_Event_Attended__c,cv_pkg_dev_I__Date_of_Last_Gift__c,cv_pkg_dev_I__Days_Since_Last_Gift__c,
                        cv_pkg_dev_I__Deceased_Date__c,cv_pkg_dev_I__Deceased__c,cv_pkg_dev_I__Direct_Mail_Recipient__c,cv_pkg_dev_I__Donor_Level__c,cv_pkg_dev_I__Event_Attended__c,
                        cv_pkg_dev_I__First_Time_Donor__c,cv_pkg_dev_I__Gender__c,cv_pkg_dev_I__Giving_of_Income__c,cv_pkg_dev_I__Household_Primary_Contact__c,cv_pkg_dev_I__Household_Role__c,
                        cv_pkg_dev_I__Household__c,cv_pkg_dev_I__Income__c,cv_pkg_dev_I__Lifetime_Appeal_Amount__c,cv_pkg_dev_I__Major_Gift_Donor__c,
                        cv_pkg_dev_I__Name_of_Last_Event_Attended__c,cv_pkg_dev_I__Newsletter_Subscriber__c,cv_pkg_dev_I__Primary_Addressee__c,cv_pkg_dev_I__Primary_Salutation__c,
                        cv_pkg_dev_I__Receipt_Preference__c,cv_pkg_dev_I__Region__c,cv_pkg_dev_I__Same_as_Household__c,cv_pkg_dev_I__Secondary_Addressee__c,cv_pkg_dev_I__Secondary_Salutation__c,
                        cv_pkg_dev_I__Solicit_Codes__c,cv_pkg_dev_I__Student__c,cv_pkg_dev_I__Suffix__c,cv_pkg_dev_I__Total_Fiscal_Gifts__c,cv_pkg_dev_I__Total_Fiscal_Transactions__c,
                        cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c,cv_pkg_dev_I__Total_Fiscal_Year_Giving__c,cv_pkg_dev_I__Total_Lifetime_Fundraising__c,cv_pkg_dev_I__Total_Lifetime_Gifts__c,
                        cv_pkg_dev_I__Total_Lifetime_Giving__c,cv_pkg_dev_I__Total_Lifetime_Transactions__c,cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c,cv_pkg_dev_I__Trade_Status__c,
                        cv_pkg_dev_I__Use_Household_Salutation_Addressee__c,CreatedById,CreatedDate,Department,
                        Description,Description_of_Work__c,Does_Your_Employer_Offer__c,Education_Level__c,Email,EmailBouncedDate,EmailBouncedReason,Fax,FirstName,
                        HomePhone,How_Did_You_Hear_About_Us__c,Id,IsDeleted,Jigsaw,JigsawContactId,Languages__c,LastActivityDate,LastCURequestDate,
                        LastCUUpdateDate,LastModifiedById,LastModifiedDate,LastName,LeadSource,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,MasterRecordId,
                        Middle_Name__c,Miles_Willing_to_Travel_One_Way__c,MobilePhone,Professional_Skills__c,Name,Name_of_Educational_Institution__c,OtherCity,OtherCountry,OtherPhone,OtherPostalCode,OtherState,OtherStreet,OwnerId,Phone,
                        Preferred_Locales__c,Reasons_For_Volunteering__c,ReportsToId,Salutation,
                        SystemModstamp,Title FROM Contact WHERE Id IN :CIDs];
            
            for(Contact c : contacts)
            {
                if (cid_to_app.get(c.Id).Currently_employed__c != '' && cid_to_app.get(c.Id).Currently_employed__c != null) { c.Currently_employed__c = cid_to_app.get(c.Id).Currently_employed__c; }
                if (cid_to_app.get(c.Id).Description_of_Work__c != '' && cid_to_app.get(c.Id).Description_of_Work__c != null) { c.Description_of_Work__c = cid_to_app.get(c.Id).Description_of_Work__c; }
                if (cid_to_app.get(c.Id).Programs_Offered_by_Employer__c != '' && cid_to_app.get(c.Id).Programs_Offered_by_Employer__c!= null) { c.Does_Your_Employer_Offer__c = cid_to_app.get(c.Id).Programs_Offered_by_Employer__c;}
                if (cid_to_app.get(c.Id).Name_of_Educational_Institution__c != '' && cid_to_app.get(c.Id).Name_of_Educational_Institution__c != null) { c.Name_of_Educational_Institution__c = cid_to_app.get(c.Id).Name_of_Educational_Institution__c;}
                if (cid_to_app.get(c.Id).Volunteer_Availability__c != '' && cid_to_app.get(c.Id).Volunteer_Availability__c != null) { c.Volunteer_Availability__c = cid_to_app.get(c.Id).Volunteer_Availability__c ;}
                if (cid_to_app.get(c.Id).Reasons_for_Volunteering__c != '' && cid_to_app.get(c.Id).Reasons_for_Volunteering__c != null) { c.Reasons_for_Volunteering__c = cid_to_app.get(c.Id).Reasons_for_Volunteering__c;}
                if (cid_to_app.get(c.Id).Professional_Skills__c != '' && cid_to_app.get(c.Id).Professional_Skills__c != null) { c.Professional_Skills__c = cid_to_app.get(c.Id).Professional_Skills__c;}
                if (cid_to_app.get(c.Id).Prefered_Locales__c!= '' && cid_to_app.get(c.Id).Prefered_Locales__c!= null) { c.Preferred_Locales__c = cid_to_app.get(c.Id).Prefered_Locales__c;}
                if (cid_to_app.get(c.Id).Miles_Willing_to_Travel_One_Way__c != '' && cid_to_app.get(c.Id).Miles_Willing_to_Travel_One_Way__c != null) { c.Miles_Willing_to_Travel_One_Way__c = cid_to_app.get(c.Id).Miles_Willing_to_Travel_One_Way__c;  } 
                if (cid_to_app.get(c.Id).Education_Level__c != '' && cid_to_app.get(c.Id).Education_Level__c != null) { c.Education_Level__c = cid_to_app.get(c.Id).Education_Level__c;}
                if (cid_to_app.get(c.Id).How_Did_You_Hear_About_Us__c != '' && cid_to_app.get(c.Id).How_Did_You_Hear_About_Us__c != null) { c.How_Did_You_Hear_About_Us__c = cid_to_app.get(c.Id).How_Did_You_Hear_About_Us__c;}
                if (cid_to_app.get(c.Id).Languages__c != '' && cid_to_app.get(c.Id).Languages__c != null) { c.Languages__c = cid_to_app.get(c.Id).Languages__c;    } 
                if (cid_to_app.get(c.Id).Emergency_Contact_Relationship__c != '' && cid_to_app.get(c.Id).Emergency_Contact_Relationship__c != null) { c.Emergency_Contact_Relationship__c = cid_to_app.get(c.Id).Emergency_Contact_Relationship__c ;}     
                if (cid_to_app.get(c.Id).Emergency_Contact_Phone__c != '' && cid_to_app.get(c.Id).Emergency_Contact_Phone__c != null) { c.Emergency_Contact_Phone__c = cid_to_app.get(c.Id).Emergency_Contact_Phone__c ;     }
                if (cid_to_app.get(c.Id).Emergency_Contact__c != '' && cid_to_app.get(c.Id).Emergency_Contact__c != null) { c.Emergency_Contact__c = cid_to_app.get(c.Id).Emergency_Contact__c ;     }
                if (cid_to_app.get(c.Id).Education_Program__c!= '' && cid_to_app.get(c.Id).Education_Program__c!= null) { c.Educational_Program_Name__c = cid_to_app.get(c.Id).Education_Program__c;     }
                c.cv_pkg_dev_I__Last_Volunteer_Profile_Updated__c = DateTime.now();
            }     
            
            update contacts;           
        }



    }