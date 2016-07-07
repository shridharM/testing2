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
      String query = 'select Id, (select cv_pkg_dev_I__Gift_Date__c, cv_pkg_dev_I__Gift_Type__c, cv_pkg_dev_I__Reference__c, cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Organization__c from Orders__r) from cv_pkg_dev_I__Recurring_Donation__c';
      //String query = 'select Id, (select cv_pkg_dev_I__Gift_Date__c, cv_pkg_dev_I__Gift_Type__c, cv_pkg_dev_I__Reference__c, cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Organization__c from Orders__r) from cv_pkg_dev_I__Recurring_Donation__c where Id = \'a0KA000000BFtIy\'';
      return Database.getQueryLocator(query);
   }
    //In execute method, performing operations over reurring gifts fetched in start method
   global void execute(Database.BatchableContext BC, List<cv_pkg_dev_I__Recurring_Donation__c> scope){
     
        System.debug('Scope ---'+scope.size());
        Map<Id, Map<Integer, List<Gift__c>>> recurringGiftMap = new Map<Id, Map<Integer, List<Gift__c>>>();
        set<Id> rgId = new set<Id>();
        List<cv_pkg_dev_I__Gift_Detail__c> updateAllocationList = new List<cv_pkg_dev_I__Gift_Detail__c>();
        Set<cv_pkg_dev_I__Gift_Detail__c> updateAllocationSet = new Set<cv_pkg_dev_I__Gift_Detail__c>();
        List<cv_pkg_dev_I__Gift_Detail__c> updateAllocationList2 = new List<cv_pkg_dev_I__Gift_Detail__c>();
        List<cv_pkg_dev_I__Gift__c> giftInsert = new List<cv_pkg_dev_I__Gift__c>();
        //Adding reurring gift ids fetched in start method in Set of Id type
        for(cv_pkg_dev_I__Recurring_Donation__c rg : scope){
            rgId.add(rg.Id);
            system.debug('scope==>'+rg.Orders__r);
        }
        List<cv_pkg_dev_I__Payment__c> paymentRecord = new List<cv_pkg_dev_I__Payment__c>();
        Set<cv_pkg_dev_I__Payment__c> paymentRecordSet = new Set<cv_pkg_dev_I__Payment__c>();
        List<cv_pkg_dev_I__Payment__c> paymentRecordToUpdate = new List<cv_pkg_dev_I__Payment__c>();
        //Query all the payments of whose "cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c" id in rgId set
        paymentRecord = [select Name, cv_pkg_dev_I__Date__c, cv_pkg_dev_I__Donation__c, cv_pkg_dev_I__Donation__r.Name, cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Gift_Date__c, cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c,cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Gift_Type__c, cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Organization__c, cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Reference__c, (select cv_pkg_dev_I__Gift__c from Allocations__r) from cv_pkg_dev_I__Payment__c where cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c != null AND cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c IN: rgId];
        
        //Putting values to "recurringGiftMap" Map
        for(cv_pkg_dev_I__Recurring_Donation__c recurringGift : scope){    //for loop for recurring gifts fetched in start Method
            if(!recurringGiftMap.containsKey(recurringGift.Id)){    //checking recurringGiftMap already contains "recurringGift.Id" or not
                recurringGiftMap.put(recurringGift.id, new Map<Integer, List<Gift__c>>()); // if recurringGiftMap not contains the "recurringGift.id", then put it into recurringGiftMap
            }
            for(cv_pkg_dev_I__Gift__c gift : recurringGift.Orders__r){    //for loop for child gifts of recurring gift 
                if(!recurringGiftMap.get(recurringGift.id).containsKey(gift.cv_pkg_dev_I__Gift_Date__c.year())){    //checking recurring gift map contains year at keyvalue on inner map
                    recurringGiftMap.get(recurringGift.id).put(gift.cv_pkg_dev_I__Gift_Date__c.year(), new List<Gift__c>());    //if recurringGiftMap not contains the year, then put it into recurringGiftMap 
                }
                recurringGiftMap.get(recurringGift.id).get(gift.cv_pkg_dev_I__Gift_Date__c.year()).add(gift);    //adding List of gift records according to recurring gift id and year of transaction
            }
        }
        for(cv_pkg_dev_I__Payment__c payment : paymentRecord){
            system.debug('payment==>'+payment);
            if(recurringGiftMap.get(payment.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c).get(payment.cv_pkg_dev_I__Date__c.year()) == null ){    //checking for a recurring gift, in inner map for keyvalue "year" it not contains gift record
                cv_pkg_dev_I__Gift__c gift = payment.cv_pkg_dev_I__Donation__r;    //getting gift record on lookup of payment record
                cv_pkg_dev_I__Gift__c gift1 = gift.clone(false, true);    //making clone of gift record fetched in last step
                gift1.cv_pkg_dev_I__Status__c = gift.cv_pkg_dev_I__Status__c;
                gift1.cv_pkg_dev_I__Gift_Type__c = gift.cv_pkg_dev_I__Gift_Type__c;
                gift1.cv_pkg_dev_I__Reference__c = gift.cv_pkg_dev_I__Reference__c;
                gift1.cv_pkg_dev_I__Gift_Date__c = date.valueof(payment.cv_pkg_dev_I__Date__c.year()+'-01-01');    //changing date of cloned gift record to 1st date of payment year
                if(gift.cv_pkg_dev_I__Constituent__c != null){    //checking gift for individual or for organisation
                     gift1.cv_pkg_dev_I__Constituent__c = gift.cv_pkg_dev_I__Constituent__c;   
                }
                 else {
                     gift1.cv_pkg_dev_I__Organization__c = gift.cv_pkg_dev_I__Organization__c;
                }
                giftInsert.add(gift1);
                recurringGiftMap.get(payment.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c).put(gift1.cv_pkg_dev_I__Gift_Date__c.year(), new List<Gift__c>());    //putting newly created gift year to recurringGiftMap
                recurringGiftMap.get(payment.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c).get(gift1.cv_pkg_dev_I__Gift_Date__c.year()).add(gift1);    //adding List of gift records according to recurring gift id and year of transaction
            }
        }
        if(giftInsert.size() > 0){
            system.debug('giftInsert=='+giftInsert);
            Insert giftInsert;    //Inserting gift records into Database
        }
        //mapping payment to transaction according to year
        for(cv_pkg_dev_I__Payment__c payment : paymentRecord){
            if(recurringGiftMap.get(payment.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c).get(payment.cv_pkg_dev_I__Date__c.year()) != null ){
                if(payment.cv_pkg_dev_I__Date__c.year() != payment.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Gift_Date__c.year()){
                    for(cv_pkg_dev_I__Gift__c gift : recurringGiftMap.get(payment.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Recurring_Donation__c).get(payment.cv_pkg_dev_I__Date__c.year())){    //fetching gift for recurring gift and for year of payment from recurringGiftMap
                        system.debug('Gift Name==='+gift);
                        logFileData += payment.cv_pkg_dev_I__Date__c.year() + ' Payment ' + payment.Name +' associated with ' + payment.cv_pkg_dev_I__Donation__r.cv_pkg_dev_I__Gift_Date__c.year() + ' Transaction ' + payment.cv_pkg_dev_I__Donation__r.Id + ' changed to '+ payment.cv_pkg_dev_I__Date__c.year() + ' Payment ' + payment.Name +' associated with ' + gift.cv_pkg_dev_I__Gift_Date__c.year() + ' Transaction ' + gift.Id + '\n';
                        payment.cv_pkg_dev_I__Donation__c = gift.id;    //updating the gift id on payment record
                        paymentRecordToUpdate.add(payment);
                        if(payment.Allocations__r.size() > 0){
                            for(cv_pkg_dev_I__Gift_Detail__c allocation : payment.Allocations__r){
                                allocation.cv_pkg_dev_I__Gift__c = gift.id;    //updating the gift id on allocation record
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
            Document doc = new Document (Name = 'Payment Log'+DateTime.now().format() + '.txt');
            doc.Description = ''; // Insert description
            //doc.FolderId = folder.Id;
            doc.FolderId = UserInfo.getUserId();
            doc.Body = Blob.valueOf(logFileData);
            insert doc;
        }
   }
}