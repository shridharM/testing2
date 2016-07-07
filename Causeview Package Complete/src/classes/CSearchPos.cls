public with sharing class CSearchPos {
// Security issue resolve.
    public void back() {
        wizardStep = 1;
    }


    public PageReference addConfirm() {
        try 
        {               
            List<CampaignMember> theMembers = new List<CampaignMember>();
            campaign.Name = thePosition.Name + '--' + DateTime.Now();
            insert campaign;            
            for (Contact c : selectedContacts)
            {
                CampaignMember buff = new CampaignMember(ContactId = c.Id, CampaignId = campaign.Id);
                theMembers.add(buff);
            }
            insert theMembers;
            PageReference pr = new ApexPages.StandardController(campaign).view();
            pr.setRedirect(true);
            return pr;
        }
        catch (Exception ex)
        {
            System.debug(ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,String.valueOf(ex.getLineNumber())));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));                
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getStackTraceString()));  
            return null;        
        }
        
    }


    public void addToCampaign() {
        wizardStep = 2;
        for (resultWrapper rw : theVolunteers)
        {
            if (rw.isChecked)
            { selectedContacts.add(rw.theVolunteer); }
        }        
    }    


    public CSearchPos() {
        theVolunteers = new List<resultWrapper>();
        thePosition = [SELECT Id, Number_Of_Service_Hours_Involved__c, Role_Locale__c, Language__c, Name, Skills_Needed__c FROM Volunteer_Role__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        theOpp = new Volunteer_Opportunity__c();
        con = new Contact();
        con.Preferred_Locales__c = thePosition.Role_Locale__c;
        campaign = new Campaign(Volunteer_Position__c = thePosition.Id, IsActive = True);
        selectedContacts = new List<Contact>();
        filterOptions = new List<CKvp>();
        filterOptionsLang = new List<CKvp>();        
        wizardStep = 1;
        Set<String> selectedSkills = new Set<String>();
        if (thePosition.Skills_Needed__c != '' && thePosition.Skills_Needed__c != null)
        { selectedSkills.addAll(thePosition.Skills_Needed__c.split(';')); }
        Set<String> selectedLangs = new Set<String>();       
        if (thePosition.Language__c != '' && thePosition.Language__c != null)
        { selectedLangs.addAll(thePosition.Language__c.split(';')); }
        for (Schema.PicklistEntry p : Contact.Professional_Skills__c.getDescribe().getPicklistValues())
        {
            if (selectedSkills.contains(p.getLabel())) { filterOptions.add(new CKvp(p.getLabel(), true)); }            
            else { filterOptions.add(new CKvp(p.getLabel(), false)); }            
        }
        for (Schema.PicklistEntry p : Contact.Languages__c.getDescribe().getPicklistValues())
        {
            if (selectedLangs.contains(p.getLabel())) { filterOptionsLang.add(new CKvp(p.getLabel(), true)); }            
            else { filterOptionsLang.add(new CKvp(p.getLabel(), false)); }           
        }        
        //refreshList();
    }   
        
    public List<resultWrapper> theVolunteers { get; set; }
    public Volunteer_Role__c thePosition { get; set; }
    public Volunteer_Opportunity__c theOpp { get; set; }
    public Contact con { get; set; }    
    public List<CKvp> filterOptions { get; set; }
    public List<CKvp> filterOptionsLang { get; set; }    
    public String posType { get; set; }
    public Integer wizardStep {get;set;}
    public Campaign campaign {get;set;}
    public List<Contact> selectedContacts {get;set;}

    public List<SelectOption> getTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));                
        options.add(new SelectOption('012d000000047ls', 'Group'));        
        options.add(new SelectOption('012d000000047ln', 'Individual'));                                                                                                                                                                                                                                                                                                
        return options;
    }
    
    public void refreshList() {
        try
        {
            String queryString = 'SELECT FirstName, LastName, Phone, Id, Email, Sys_No_Availability__c FROM Contact';
            List<String> filters = new List<String>();
            String buffFilters = '';
            String finalFilters = '';
            List<Contact> contactResults = new List<Contact>();
            
            if (con.Volunteer_Availability__c != '' && con.Volunteer_Availability__c != null) {
                string filterBuff = '';
                filterBuff += '(Volunteer_Availability__c INCLUDES (';
                if (con.Volunteer_Availability__c.contains(';')) {
                    List<string> values = new List<string>();
                    for (String str : con.Volunteer_Availability__c.split(';')) {
                         values.add('\'' + str + '\'');
                    }
                    filterBuff += string.join(values, ',');
                }
                else {
                    filterBuff += '\'' + con.Volunteer_Availability__c + '\'';
                }
                filterBuff += '))';
                filters.add(filterBuff);                    
            }

            //MY PROFESSIONAL SKILLS
            List<String> selectedSkills = new List<String>();
            Boolean isSkillFiltered = false;
            for (CKvp kvp : filterOptions)
            {
                if(kvp.value)
                {
                    selectedSkills.add(kvp.key);
                    isSkillFiltered = true;
                }
            }            
            if (isSkillFiltered)
            {
                buffFilters = '';
                buffFilters += '(Professional_Skills__c INCLUDES(\'';
                for (String strSkill : selectedSkills)
                {                    
                    buffFilters += (strSkill + ';');
                }
                buffFilters = buffFilters.substring(0, buffFilters.length() - 1);
                buffFilters += '\'))';  
                filters.add(buffFilters);                              
            }
            
            //LOCATION
            if (con.Preferred_Locales__c != '' && con.Preferred_Locales__c != null)
            {
                buffFilters = '';
                buffFilters += '(Preferred_Locales__c INCLUDES(';
                for (String strLoc : con.Preferred_Locales__c.split(';'))
                {                    
                    buffFilters += ('\'' + strLoc + '\', ');
                }
                buffFilters = buffFilters.substring(0, buffFilters.length() - 2);
                buffFilters += '))';
                filters.add(buffFilters);
            }              
            
            //LANGUAGES
            List<String> selectedSkillsLang = new List<String>();
            Boolean isSkillFilteredLang = false;
            for (CKvp kvp : filterOptionsLang)
            {
                if(kvp.value)
                {
                    selectedSkillsLang.add(kvp.key);
                    isSkillFilteredLang = true;
                }
            }            
            if (isSkillFilteredLang)
            {
                buffFilters = '';
                buffFilters += '(Languages__c INCLUDES(\'';
                for (String strSkill : selectedSkillsLang)
                {                    
                    buffFilters += (strSkill + ';');
                }
                buffFilters = buffFilters.substring(0, buffFilters.length() - 1);
                buffFilters += '\'))';                
                filters.add(buffFilters);
            }            
            
            if (filters.size() > 0) 
            {             
                finalFilters += ' WHERE '; 
                for (String f : filters)
                {
                    finalFilters += (f + ' AND ');
                }
                finalFilters = finalFilters.substring(0, finalFilters.length() - 5);
            }

            system.debug(queryString + finalFilters + ' ORDER BY LastName');
            contactResults = Database.query(queryString + finalFilters + ' ORDER BY LastName');          
            theVolunteers = new List<resultWrapper>();  
            for (Contact c : contactResults)
            {
                theVolunteers.add(new resultWrapper(c));
            }
        }
        catch (Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,String.valueOf(ex.getLineNumber())));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));                
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getStackTraceString()));       
        }
    }

    public class resultWrapper {
        public resultWrapper(Contact c) {
            theVolunteer = c;
            isChecked = false;
        }
        public boolean isChecked {get;set;}
        public Contact theVolunteer {get;set;}        
    }

    public class CKvp
    {
        public CKvp(string sKey, boolean bValue)
        {
            key = sKey;
            value = bValue;
        }
        public string key { get; set; }
        public boolean value { get; set; }
    }
}