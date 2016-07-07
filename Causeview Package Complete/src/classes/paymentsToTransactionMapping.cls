/*Payment Reassign Script
Check all Payments belonging to Transactions that are linked to Recurring Gifts
Verify the Payment year matches with the Transaction year
If the years do not match, then reassign the Payment and Allocations to the correct Transaction
Payment in 2013 is linked to Transaction in 2013
Payment in 2014 is linked to Transaction in 2014
This only applies to Transactions with Recurring Gift lookup populated.
*/

global class paymentsToTransactionMapping implements Schedulable {
    global void execute(SchedulableContext SC)     
    {
        decimal batchSize;
        List<givingpowerSettings__c> settingsRecords = [SELECT Recurring_Batch_Size__c FROM givingpowerSettings__c WHERE name = 'settings'];
        if (settingsRecords != null && settingsRecords.size()>0) {
            batchSize = settingsRecords[0].Recurring_Batch_Size__c;
        }
        if (batchSize==null)
          batchSize=5;
        paymentUpdateBatchable p = new paymentUpdateBatchable(); //creating object of "paymentUpdateBatchable" apex batch class
        ID myBatchJobID = database.executebatch(p, batchSize.intValue());
    }

}