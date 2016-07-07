public class GroupWrapper {
        public Volunteer_Opportunity__c theOpp {get; set;}
        public List<Volunteer_Role__c> thePositions {get; set;}
        public String locations {get; set;}
        
        public GroupWrapper (Volunteer_Opportunity__c Opp, List<Volunteer_Role__c> Positions) {
            theOpp = Opp;
            thePositions = Positions;
            locations = '';
            Set<string> locs = new Set<String>();
            for (Volunteer_Role__c vp : Positions)
            {
                if (vp.Role_Locale__c!= null) 
                { 
                    List<String> locations = vp.Role_Locale__c.split(';');
                    locs.addAll(locations);
                }
            }
            for (String str : locs)
            {
                if(str == null || str == '') { continue; }
                locations += (str + ';');
            }
        } 
    }