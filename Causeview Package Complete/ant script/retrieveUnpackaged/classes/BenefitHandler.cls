public class BenefitHandler {
    public static void UpdateEventLevels(List<Benefit__c> records) {
        Set<string> benefitIds = new Set<string>();
        for (Benefit__c b : records) {
            benefitIds.add(b.Id);
        }
        List<Benefit__c> benefits = [SELECT Id, (SELECT Id FROM Event_Level_Benefits__r) FROM Benefit__c WHERE Id IN :benefitIds FOR UPDATE];
        List<Event_Level_Benefit__c> elb = new List<Event_Level_Benefit__c>();
        for (Benefit__c b : benefits ) {
            if (b.Event_Level_Benefits__r.size() > 0) {
                elb.addAll(b.Event_Level_Benefits__r);  
            }
        }
        update elb;
    }
}