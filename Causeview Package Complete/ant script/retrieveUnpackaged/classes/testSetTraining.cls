//Test SetTraining Trigger
@isTest
Public class testSetTraining{
                            
    static testMethod void testTrigger() {
        Volunteer_Opportunity__c vo1 = new Volunteer_Opportunity__c();
        Insert vo1;
        Volunteer_Role__c vr1 = new Volunteer_Role__c(Volunteer_Opportunity__c=vo1.Id);
        Insert vr1;
        Volunteer_Application__c va1 = new Volunteer_Application__c(Volunteer_Role__c=vr1.Id);

        Test.startTest();
        Insert va1;
        Test.stopTest();
    }
}