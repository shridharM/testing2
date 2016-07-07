public class EventBenefitHelper {
    public static List<Transaction_Benefit__c> CreateTransactionBenefits(Map<Gift_Detail__c, string> eventLevelToCreate) {
        List<Transaction_Benefit__c> retVal = new List<Transaction_Benefit__c>();
        Map<string, List<Event_Level_Benefit__c>> event_to_eventbenefits = new Map<string, List<Event_Level_Benefit__c>>(); 
        for(Event_Level_Benefit__c elb : [SELECT Id, Event_Level__c, Benefit__c, Quantity__c FROM Event_Level_Benefit__c WHERE Event_Level__c IN :eventLevelToCreate.values()]){            
            if(event_to_eventbenefits.containsKey(elb.Event_Level__c)) {
                event_to_eventbenefits.get(elb.Event_Level__c).add(elb);
            }
            else {
                List<Event_Level_Benefit__c> temp = new List<Event_Level_Benefit__c>();
                temp.add(elb);
                event_to_eventbenefits.put(elb.Event_Level__c, temp);
            }
        }
            
        for(Gift_Detail__c gd : eventLevelToCreate.keyset()){
            if(eventLevelToCreate.get(gd) != null && event_to_eventbenefits.get(eventLevelToCreate.get(gd)) != null){    //event_to_eventbenefits.values().size() > 0
                for(Event_Level_Benefit__c evtvl : event_to_eventbenefits.get(eventLevelToCreate.get(gd))) {
                    Transaction_Benefit__c tracbnft = new Transaction_Benefit__c();
                    tracbnft.Benefit__c = evtvl.Benefit__c;
                    tracbnft.Benefit_Quantity__c = evtvl.Quantity__c * gd.Quantity__c;                
                    tracbnft.Transaction__c = gd.Gift__c;
                    tracbnft.Allocation__c = gd.Id;
                    retVal.add(tracbnft);
                }
            }
        }
        return retVal;
    }
    public static List<Transaction_Benefit__c> DeleteTransactionBenefits(Set<string> eventLevelToDelete) {
        List<Transaction_Benefit__c> retVal = [SELECT Id FROM Transaction_Benefit__c WHERE Allocation__c IN :eventLevelToDelete];
        return retVal;
    }    
}