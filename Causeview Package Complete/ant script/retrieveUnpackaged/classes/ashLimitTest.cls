public class ashLimitTest {
    public ashLimitTest() {
        for(integer i=0; i<101; i++) {
            List<Gift__c> clist = [Select id, (Select id from Recurring_Payments__r) from Gift__c limit 10];
        }
    }
}