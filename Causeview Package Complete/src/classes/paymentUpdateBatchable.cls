/*Payment Reassign Script batch class
Check all Payments belonging to Transactions that are linked to Recurring Gifts
Verify the Payment year matches with the Transaction year
If the years do not match, then reassign the Payment and Allocations to the correct Transaction
Payment in 2013 is linked to Transaction in 2013
Payment in 2014 is linked to Transaction in 2014
This only applies to Transactions with Recurring Gift lookup populated.
This batch class maps all the payments with transactions according to year for a recurring gift.
*/
global class paymentUpdateBatchable implements Database.Batchable<sObject>, Database.stateful{
    String logFileData = '';
    //In start method querying all the recurring gifts
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'select Id, (select causeview__Gift_Date__c, causeview__Gift_Type__c, causeview__Reference__c, causeview__Status__c, causeview__Constituent__c, causeview__Organization__c from Orders__r) from causeview__Recurring_Donation__c';
      //String query = 'select Id, (select causeview__Gift_Date__c, causeview__Gift_Type__c, causeview__Reference__c, causeview__Status__c, causeview__Constituent__c, causeview__Organization__c from Orders__r) from causeview__Recurring_Donation__c where Id = \'a0KA000000BFtIy\'';
      return Database.getQueryLocator(query);
   }
    //In execute method, performing operations over reurring gifts fetched in start method
   global void execute(Database.BatchableContext BC, List<causeview__Recurring_Donation__c> scope){
     
        System.debug('Scope ---'+scope.size());
        Map<Id, Map<Integer, List<Gift__c>>> recurringGiftMap = new Map<Id, Map<Integer, List<Gift__c>>>();
        set<Id> rgId = new set<Id>();
        List<causeview__Gift_Detail__c> updateAllocationList = new List<causeview__Gift_Detail__c>();
        Set<causeview__Gift_Detail__c> updateAllocationSet = new Set<causeview__Gift_Detail__c>();
        List<causeview__Gift_Detail__c> updateAllocationList2 = new List<causeview__Gift_Detail__c>();
        List<causeview__Gift__c> giftInsert = new List<causeview__Gift__c>();
        //Adding reurring gift ids fetched in start method in Set of Id type
        for(causeview__Recurring_Donation__c rg : scope){
            rgId.add(rg.Id);
            system.debug('scope==>'+rg.Orders__r);
        }
        List<causeview__Payment__c> paymentRecord = new List<causeview__Payment__c>();
        Set<causeview__Payment__c> paymentRecordSet = new Set<causeview__Payment__c>();
        List<causeview__Payment__c> paymentRecordToUpdate = new List<causeview__Payment__c>();
        //Query all the payments of whose "causeview__Donation__r.causeview__Recurring_Donation__c" id in rgId set
        paymentRecord = [select Name, causeview__Date__c, causeview__Donation__c, causeview__Donation__r.Name, causeview__Donation__r.causeview__Gift_Date__c, causeview__Donation__r.causeview__Recurring_Donation__c,causeview__Donation__r.causeview__Status__c, causeview__Donation__r.causeview__Gift_Type__c, causeview__Donation__r.causeview__Constituent__c, causeview__Donation__r.causeview__Organization__c, causeview__Donation__r.causeview__Reference__c, (select causeview__Gift__c from Allocations__r) from causeview__Payment__c where causeview__Donation__r.causeview__Recurring_Donation__c != null AND causeview__Donation__r.causeview__Recurring_Donation__c IN: rgId];
        
        //Putting values to "recurringGiftMap" Map
        for(causeview__Recurring_Donation__c recurringGift : scope){    //for loop for recurring gifts fetched in start Method
            if(!recurringGiftMap.containsKey(recurringGift.Id)){    //checking recurringGiftMap already contains "recurringGift.Id" or not
                recurringGiftMap.put(recurringGift.id, new Map<Integer, List<Gift__c>>()); // if recurringGiftMap not contains the "recurringGift.id", then put it into recurringGiftMap
            }
            for(causeview__Gift__c gift : recurringGift.Orders__r){    //for loop for child gifts of recurring gift 
                if(!recurringGiftMap.get(recurringGift.id).containsKey(gift.causeview__Gift_Date__c.year())){    //checking recurring gift map contains year at keyvalue on inner map
                    recurringGiftMap.get(recurringGift.id).put(gift.causeview__Gift_Date__c.year(), new List<Gift__c>());    //if recurringGiftMap not contains the year, then put it into recurringGiftMap 
                }
                recurringGiftMap.get(recurringGift.id).get(gift.causeview__Gift_Date__c.year()).add(gift);    //adding List of gift records according to recurring gift id and year of transaction
            }
        }
        for(causeview__Payment__c payment : paymentRecord){
            system.debug('payment==>'+payment);
            if(recurringGiftMap.get(payment.causeview__Donation__r.causeview__Recurring_Donation__c).get(payment.causeview__Date__c.year()) == null ){    //checking for a recurring gift, in inner map for keyvalue "year" it not contains gift record
                causeview__Gift__c gift = payment.causeview__Donation__r;    //getting gift record on lookup of payment record
                causeview__Gift__c gift1 = gift.clone(false, true);    //making clone of gift record fetched in last step
                gift1.causeview__Status__c = gift.causeview__Status__c;
                gift1.causeview__Gift_Type__c = gift.causeview__Gift_Type__c;
                gift1.causeview__Reference__c = gift.causeview__Reference__c;
                gift1.causeview__Gift_Date__c = date.valueof(payment.causeview__Date__c.year()+'-01-01');    //changing date of cloned gift record to 1st date of payment year
                if(gift.causeview__Constituent__c != null){    //checking gift for individual or for organisation
                     gift1.causeview__Constituent__c = gift.causeview__Constituent__c;   
                }
                 else {
                     gift1.causeview__Organization__c = gift.causeview__Organization__c;
                }
                giftInsert.add(gift1);
                recurringGiftMap.get(payment.causeview__Donation__r.causeview__Recurring_Donation__c).put(gift1.causeview__Gift_Date__c.year(), new List<Gift__c>());    //putting newly created gift year to recurringGiftMap
                recurringGiftMap.get(payment.causeview__Donation__r.causeview__Recurring_Donation__c).get(gift1.causeview__Gift_Date__c.year()).add(gift1);    //adding List of gift records according to recurring gift id and year of transaction
            }
        }
        if(giftInsert.size() > 0){
            system.debug('giftInsert=='+giftInsert);
            Insert giftInsert;    //Inserting gift records into Database
        }
        //mapping payment to transaction according to year
        for(causeview__Payment__c payment : paymentRecord){
            if(recurringGiftMap.get(payment.causeview__Donation__r.causeview__Recurring_Donation__c).get(payment.causeview__Date__c.year()) != null ){
                if(payment.causeview__Date__c.year() != payment.causeview__Donation__r.causeview__Gift_Date__c.year()){
                    for(causeview__Gift__c gift : recurringGiftMap.get(payment.causeview__Donation__r.causeview__Recurring_Donation__c).get(payment.causeview__Date__c.year())){    //fetching gift for recurring gift and for year of payment from recurringGiftMap
                        system.debug('Gift Name==='+gift);
                        logFileData += payment.causeview__Date__c.year() + ' Payment ' + payment.Name +' associated with ' + payment.causeview__Donation__r.causeview__Gift_Date__c.year() + ' Transaction ' + payment.causeview__Donation__r.Id + ' changed to '+ payment.causeview__Date__c.year() + ' Payment ' + payment.Name +' associated with ' + gift.causeview__Gift_Date__c.year() + ' Transaction ' + gift.Id + '\n';
                        payment.causeview__Donation__c = gift.id;    //updating the gift id on payment record
                        paymentRecordToUpdate.add(payment);
                        if(payment.Allocations__r.size() > 0){
                            for(causeview__Gift_Detail__c allocation : payment.Allocations__r){
                                allocation.causeview__Gift__c = gift.id;    //updating the gift id on allocation record
                                updateAllocationList.add(allocation);
                            }
                            system.debug('giftafterupdate==>'+payment);
                        }
                    }
                }
            }
        }
        try{
            if(paymentRecordToUpdate.size() > 0){
                paymentRecordSet.addAll(paymentRecordToUpdate);
                paymentRecordToUpdate.clear();
                paymentRecordToUpdate.addAll(paymentRecordSet);
                update paymentRecordToUpdate;    //updating the payment record
            }
            if(updateAllocationList.size() > 0){
                updateAllocationSet.addAll(updateAllocationList);
                updateAllocationList2.addAll(updateAllocationSet);
                update updateAllocationList2;    //updating the allocation record
                //update updateAllocationList;
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
   global void finish(Database.BatchableContext BC){
         if (String.isNotBlank(logFileData) == true){
            //Folder folder = [select id from Folder where name='Updated Account/Contact Record Log' LIMIT 1];
            Folder folder = [SELECT Id,Name,Type FROM Folder where Name = 'Causeview' AND Type = 'Document' LIMIT 1];
            Document doc = new Document (Name = 'Payment Log'+DateTime.now().format() + '.txt');
            doc.Description = ''; // Insert description
            doc.FolderId = folder.Id;
            //doc.FolderId = UserInfo.getUserId();
            doc.Body = Blob.valueOf(logFileData);
            insert doc;
        }
   }
}