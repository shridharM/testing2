public with sharing class CPlaceApplicant {

    public PageReference place() {    
        List<Volunteer_Shift__c> shiftsToUpdate = new List<Volunteer_Shift__c>();
        Integer count = 0;
        for (PlacementWrapper pw : shift_wrappers) {
            if (pw.placed) {
                pw.shift.Volunteer__c = volunteerId;
                shiftsToUpdate.add(pw.shift);
                count++;
            }
            else {
                pw.shift.Volunteer__c = null;
                pw.shift.Volunteer_Application__c = null;                
                shiftsToUpdate.add(pw.shift);
            }
            if (count == 0) {
                app.Status__c = 'Exited';
                app.Service_Exit_Date__c = Date.Today();
            }
            else {
                app.Status__c = 'Placed';
            }
        }
        System.debug(shiftsToUpdate);
        update shiftsToUpdate;
        update app;
        return new PageReference('/' + ApexPages.CurrentPage().GetParameters().get('id'));        
    }

    
    public class PlacementWrapper {
        public PlacementWrapper() { }
        public boolean placed { get; set; }
        public Volunteer_Shift__c shift { get; set; }
    }
    
    public List<PlacementWrapper> shift_wrappers { get; set; }
    public string volunteerId { get; set; }
    public Contact volunteer { get; set; }
    public Volunteer_Application__c app { get; set; }
    
    public CPlaceApplicant() {
        shift_wrappers = new List<PlacementWrapper>();
        app = [SELECT Id, Volunteer_Role__c, Volunteer__c, Volunteer_Availability__c FROM Volunteer_Application__c WHERE Id = :ApexPages.CurrentPage().GetParameters().get('id') LIMIT 1];
        volunteerId = app.Volunteer__c;
        volunteer = [SELECT Id, Volunteer_Availability__c FROM Contact WHERE Id = :volunteerId];
        for (Volunteer_Shift__c vps : [SELECT Id, Name, Volunteer__c, Start_Time__c,End_Time__c,Day_of_the_Week__c ,Duration_Hours__c ,Frequency__c ,Location_Address__c    FROM Volunteer_Shift__c WHERE Volunteer_Role__c = :app.Volunteer_Role__c AND (Volunteer__c = :volunteerId OR Volunteer__c = '' OR Volunteer__c = null)]) {
            PlacementWrapper pw = new PlacementWrapper();
            pw.placed = (vps.Volunteer__c == volunteerId);
            pw.shift = vps;
            shift_wrappers.add(pw);
        }
        
    }
}