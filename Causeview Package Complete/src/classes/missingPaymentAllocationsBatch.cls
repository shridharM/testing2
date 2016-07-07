global class missingPaymentAllocationsBatch implements Database.Batchable<sObject>, Database.stateful{
//This class is used to generated reports for Recurring Payments with missing allocation.
        //COUNTERS
        Integer batchCounter = 0;
        Integer paymentCounter = 0;
        Integer fixablePaymentCounter = 0;
        Integer nonFixablePaymentCounter = 0;

        //FIXABLE
        List<causeview__Payment__c> fixableList = new List<causeview__Payment__c>();
        String fixableLogData = 'FIXABLE PAYMENTS, Payment ID, Payment Name, Payment Status, Transaction, Recurring Gift ID\n';

        //NON FIXABLE
        List<causeview__Payment__c> nonFixableList = new List<causeview__Payment__c>();
        String nonFixableLogData = 'NON-FIXABLE PAYMENTS, Payment ID, Payment Name, Payment Status, Transaction, Recurring Gift ID\n';

        //DATA LOADER FILE
        String dataloaderFile = 'ID,Payment Name,causeview__Status__c\n';

        //QUERY
        global String query = 'SELECT ID, Name, causeview__Amount__c, causeview__Status__c, causeview__Description__c, causeview__Donation__c, causeview__Donation__r.Name, causeview__Donation__r.causeview__Recurring_Donation__c, causeview__Donation__r.causeview__Recurring_Donation__r.Name FROM causeview__Payment__c WHERE ID NOT IN (SELECT causeview__Payment__c FROM causeview__Gift_Detail__c) AND causeview__Donation__r.causeview__Gift_Type__c = \'Recurring\' AND causeview__Status__c = \'Approved\'  AND causeview__Amount__c >0 AND causeview__Date__c >= 2013-01-01 AND (causeview__Payment_Type__c = \'Credit Card\' OR causeview__Payment_Type__c = \'ACH/PAD\')';

        global Database.QueryLocator start(Database.BatchableContext BC){
                return Database.getQueryLocator(query);
        }

        global void execute(Database.BatchableContext BC, List<causeview__Payment__c> paymentList){
                batchCounter += 1;
                //Set of Recurring Gift IDs from payments
                Set<ID> RGIDs = new Set<ID>();
                for(causeview__Payment__c ap : paymentList) {
                        RGIDs.add(ap.causeview__Donation__r.causeview__Recurring_Donation__c);
                }
                List<causeview__RD_Allocation__c> RecurringAllocationList = new List<causeview__RD_Allocation__c>();
                //Map used to store all Recurring Gift Allocations
                Map<Id, causeview__RD_Allocation__c> RecurringAllocationMap = new Map<Id,causeview__RD_Allocation__c>();
                try{
                        //Query all Recurring Gift Allocations from :RGIDs set
                        RecurringAllocationList = [SELECT ID,causeview__New_Campaign__c,causeview__Fund__c,causeview__Recurring_Gift__c FROM causeview__RD_Allocation__c WHERE causeview__Recurring_Gift__c IN :RGIDs ];
                        //Loading Map from List
                        for (causeview__RD_Allocation__c RGA : RecurringAllocationList) {
                                RecurringAllocationMap.put(RGA.causeview__Recurring_Gift__c, RGA);
                        }
                } catch (QueryException qe){
                        System.debug('Query Exception: ' + qe.getMessage());
                }
                for(causeview__Payment__c p : paymentList) {
                        paymentCounter += 1;                    //Total Payments Counter
                        if(RecurringAllocationMap.containsKey(p.causeview__Donation__r.causeview__Recurring_Donation__c)){
                                //WITH RECURRING GIFT ALLOCATION
                                fixablePaymentCounter += 1;
                                fixableLogData += ',' + p.ID + ',' + p.Name + ',' + p.causeview__Status__c + ',' + p.causeview__Donation__r.Name + ',' + p.causeview__Donation__r.causeview__Recurring_Donation__r.Name + '\n';
                                dataloaderFile += p.ID + ',' + p.Name + ',' + 'Approved' + '\n';
                                p.causeview__Status__c = 'Pending';
                                fixableList.add(p);
                        }
                        else{   //NO RECURRING GIFT ALLOCATION
                                nonFixablePaymentCounter += 1;
                                nonFixableLogData += ',' + p.ID + ',' + p.Name + ',' + p.causeview__Status__c + ',' + p.causeview__Donation__r.Name + ',' + p.causeview__Donation__r.causeview__Recurring_Donation__r.Name +  '\n';
                                nonFixableList.add(p);
                        }

                }//END: FOR EACH PAYMENT
                update paymentList;
        }
        //END: Batch Execute

        global void finish(Database.BatchableContext BC){
                System.Debug('Number of batches: ' + batchCounter);
                if(!fixableList.isEmpty()){
                        //dataloader file
                        Document dataDoc = new Document (Name = 'paymentsToApproved Dataloader '+DateTime.now().format() + '.csv');
                        dataDoc.Description = '';
                        dataDoc.FolderId = UserInfo.getUserId();
                        dataDoc.Body = Blob.valueOf(dataloaderFile);
                        insert dataDoc;
                        System.Debug('Dataloader File: ' + dataDoc.ID);

                        //fixable file
                        fixableLogData += 'Summary,Total Payments, Fixable, Non-Fixable\n';
                        fixableLogData += ',' + paymentCounter + ',' + fixablePaymentCounter + ',' + nonFixablePaymentCounter + '\n';
                        Document fixableDoc = new Document (Name = 'Fixable Payments '+DateTime.now().format() + '.csv');
                        fixableDoc.Description = '';
                        fixableDoc.FolderId = UserInfo.getUserId();
                        fixableDoc.Body = Blob.valueOf(fixableLogData);
                        insert fixableDoc;
                        System.Debug('Fixable File: ' + fixableDoc.ID);
                }
                //non-fixable file
                if(!nonFixableList.isEmpty()){
                        nonFixableLogData += 'Total,' + nonFixablePaymentCounter + '\n';
                        Document norga = new Document (Name = 'Non-Fixable Payments '+DateTime.now().format() + '.csv');
                        norga.Description = ''; // Insert description
                        norga.FolderId = UserInfo.getUserId();
                        norga.Body = Blob.valueOf(nonFixableLogData);
                        insert norga;
                        System.Debug('Non-Fixable File: ' + norga.ID);
                }
        }

}