public class CMyPosition {
    public List<Volunteer_Application__c> theApps { get; set; }    
    public Set<String> thePosIds{ get; set; }
    public List<Volunteer_Role__c> pastPositions { get; set; }
    public List<Volunteer_Role__c> currentPositions { get; set; }
    public List<Volunteer_Role__c> futurePositions { get; set; }        
    
    public CMyPosition() {
        thePosIds = new Set<String>();
        theApps = VolunteerUtil.getAppsFromUser(UserInfo.getUserId());
        for (Volunteer_Application__c va : theApps)
        {
            thePosIds.add(va.Volunteer_Role__c);
        }
        List<Volunteer_Role__c> thePos = [SELECT Role_Status__c, Volunteer_Supervisor_Email__c, Name,Volunteer_Supervisor__r.Email, Volunteer_Supervisor__r.Name,   Number_of_Service_Hours_Involved__c FROM Volunteer_Role__c WHERE Id IN :thePosIds];
        pastPositions = new List<Volunteer_Role__c>();
        currentPositions = new List<Volunteer_Role__c>();
        futurePositions = new List<Volunteer_Role__c>();                
        for (Volunteer_Role__c vp : thePos)
        {
            if (vp.Role_Status__c == 'Completed') { pastPositions.add(vp); }
            if (vp.Role_Status__c == 'Filled') { currentPositions.add(vp); }
            if (vp.Role_Status__c == 'In Screening') { futurePositions.add(vp); }                        
        }
    }
}