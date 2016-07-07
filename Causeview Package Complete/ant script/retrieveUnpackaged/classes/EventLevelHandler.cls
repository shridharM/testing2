public class EventLevelHandler {
    public static void RollupTotals(Set<string> eventLevelIds) {
        List<Campaign> camps = [SELECT Number_of_Tickets_Planned__c, (SELECT Ticket_Count__c FROM Tickets__r) FROM Campaign WHERE Id IN :eventLevelIds FOR UPDATE];
        for (Campaign c : camps) {
            Decimal total = 0;
            for (Event_Level__c el : c.Tickets__r) {
                total = total + el.Ticket_Count__c;            
            }
            c.Number_Of_Tickets_Planned__c = total;
        }
        update camps;
    }
}