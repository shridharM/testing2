public class TransactionBenefitHandler {
    public static void RollupTotals (List<Transaction_Benefit__c> records) {
        Set<string> giftIds = new Set<string>();
        for (Transaction_Benefit__c tb : records) {
            giftIds.add(tb.Transaction__c);
        }
        List<Gift__c> gifts = [SELECT Id, Sponsorship_Amount__c, (SELECT Id, Sponsorship_Amount__c FROM Transaction_Benefits__r) FROM Gift__c WHERE Id IN :giftIds];
        for (Gift__c g : gifts) {
            Decimal total = 0;
            for (Transaction_Benefit__c tb : g.Transaction_Benefits__r) {
                total = total + tb.Sponsorship_Amount__c;
            }
            g.Sponsorship_Amount__c = total;
        }
        update gifts;
    }
}