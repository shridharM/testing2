public with sharing class GiftBatchItemEditController_moc {
    
    public List<causeview__Gift__c> transactions{get; set;}
    public Map<Id, causeview__Gift__c> transactionMap{get; set;}
    
    public GiftBatchItemEditController_moc(ApexPages.StandardController controller) {
        transactionMap = new Map<Id, causeview__Gift__c>();
        
        transactions = [SELECT
            causeview__Constituent__c,
            causeview__Constituent__r.causeview__Constituent_ID__c,
            causeview__Constituent__r.name,
            causeview__Constituent__r.FirstName,
            causeview__Constituent__r.LastName,
            causeview__Constituent__r.MailingStreet,
            causeview__Constituent__r.MailingCity,
            causeview__Constituent__r.MailingState,
            causeview__Constituent__r.MailingPostalCode,
            causeview__Constituent__r.MailingCountry,
            causeview__Constituent__r.causeview__Region__c,
            causeview__Constituent__r.Phone,
            causeview__Constituent__r.Email,
            causeview__Constituent__r.causeview__Primary_Addressee__c,
            causeview__Constituent__r.causeview__Primary_Salutation__c,
            causeview__Constituent__r.causeview__Trade_Status__c,
            causeview__Constituent__r.causeview__Solicit_Codes__c,
            causeview__Constituent__r.causeview__Constituent_Codes__c,
            causeview__Constituent__r.causeview__Household__c,
            causeview__Batch_Status__c,
            causeview__Gift_Date__c,
            causeview__Amount__c,
            causeview__Gift_Type__c,
            causeview__Receipt_Type__c,
            causeview__Expected_Amount__c,
            causeview__Channel__c,
            causeview__Package_Name__c,
            causeview__Anonymous__c,
            causeview__Internal_Solicitor__c,
            causeview__Internal_Solicitor__r.Name,
            causeview__Recurring_Donation__c,
            causeview__Recurring_Donation__r.causeview__Frequency__c,
            causeview__Recurring_Donation__r.causeview__of_Payments__c,
            Id,
            (Select Id, causeview__Payment_Type__c, causeview__Date__c, causeview__Date_Deposited__c From causeview__Recurring_Payments__r),
            (Select Id, causeview__Amount_Not_Eligible__c, causeview__Notes__c From causeview__Receipts__r),
            (Select Id,
                causeview__Amount__c,
                causeview__New_Campaign__c,
                causeview__New_Campaign__r.Name,
                causeview__Fund__c,
                causeview__Fund__r.Name,
                causeview__Product__c,
                causeview__Product__r.Name,
                causeview__Tribute__c,
                causeview__Tribute__r.Name,
                causeview__Description__c
            From causeview__Gift_Allocations__r)
        From causeview__Gift__c LIMIT 7];

    }

    public String getTranxData() {
        for(causeview__Gift__c each : transactions) {
            transactionMap.put(each.Id, each);
        }
        return JSON.serialize(transactionMap);
    }

    public pageReference newGiftBatchItem() {
        transactions.add(new causeview__Gift__c());
        return null;
    }
}