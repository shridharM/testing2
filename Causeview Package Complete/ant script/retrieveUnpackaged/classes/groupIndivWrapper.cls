public class groupIndivWrapper {
        public groupIndivWrapper(Contact e, Volunteer_Role__c p) {
            theApp = new Volunteer_Application__c();
            theEmployee = e;
            thePos = p;
        }
        
        public Volunteer_Application__c theApp {get; set;}
        public Contact theEmployee {get; set;}
        public Volunteer_Role__c thePos {get; set;}
    }