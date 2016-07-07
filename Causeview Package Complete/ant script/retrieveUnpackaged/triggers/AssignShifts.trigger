trigger AssignShifts on Volunteer_Application__c (after update) {
    Map<String, Volunteer_Application__c> position_to_app = new Map<String, Volunteer_Application__c>();
    Set<String> Pids = new Set<String>();
        
    for (Integer i = 0; i < Trigger.new.size(); i++)
    {
        if (Trigger.new[i].Status__c == 'Placed' && Trigger.old[i].Status__c != 'Placed')
        { 
            Pids.add(Trigger.new[i].Volunteer_Role__c);             
            position_to_app.put(Trigger.new[i].Volunteer_Role__c, Trigger.new[i]);
        }
    }
    
    List<Volunteer_Shift__c> theShifts = [SELECT Id, Volunteer__c, Volunteer_Application__c, Volunteer_Role__c FROM Volunteer_Shift__c WHERE Volunteer_Role__c IN :Pids];
    
    for (Volunteer_Shift__c shift : theShifts)
    {
        if (shift.Volunteer__c == position_to_app.get(shift.Volunteer_Role__c).Volunteer__c) {
            shift.Volunteer_Application__c = position_to_app.get(shift.Volunteer_Role__c).Id;
        }
    }
    
    update theShifts;
}