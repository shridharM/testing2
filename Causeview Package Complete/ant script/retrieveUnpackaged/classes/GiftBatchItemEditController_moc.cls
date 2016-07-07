public with sharing class GiftBatchItemEditController_moc {
    
    public List<cv_pkg_dev_I__Gift__c> transactions{get; set;}
    public Map<Id, cv_pkg_dev_I__Gift__c> transactionMap{get; set;}
    
    public GiftBatchItemEditController_moc(ApexPages.StandardController controller) {
        transactionMap = new Map<Id, cv_pkg_dev_I__Gift__c>();
        
        transactions = [SELECT
            cv_pkg_dev_I__Constituent__c,
            cv_pkg_dev_I__Constituent__r.cv_pkg_dev_I__Constituent_ID__c,
            cv_pkg_dev_I__Constituent__r.name,
            cv_pkg_dev_I__Constituent__r.FirstName,
            cv_pkg_dev_I__Constituent__r.LastName,
            cv_pkg_dev_I__Constituent__r.MailingStreet,
            cv_pkg_dev_I__Constituent__r.MailingCity,
            cv_pkg_dev_I__Constituent__r.MailingState,
            cv_pkg_dev_I__Constituent__r.MailingPostalCode,
            cv_pkg_dev_I__Constituent__r.MailingCountry,
            cv_pkg_dev_I__Constituent__r.cv_pkg_dev_I__Region__c,
            cv_pkg_dev_I__Constituent__r.Phone,
            cv_pkg_dev_I__Constituent__r.Email,
            cv_pkg_dev_I__Constituent__r.cv_pkg_dev_I__Primary_Addressee__c,
            cv_pkg_dev_I__Constituent__r.cv_pkg_dev_I__Primary_Salutation__c,
            cv_pkg_dev_I__Constituent__r.cv_pkg_dev_I__Trade_Status__c,
            cv_pkg_dev_I__Constituent__r.cv_pkg_dev_I__Solicit_Codes__c,
            cv_pkg_dev_I__Constituent__r.cv_pkg_dev_I__Constituent_Codes__c,
            cv_pkg_dev_I__Constituent__r.cv_pkg_dev_I__Household__c,
            cv_pkg_dev_I__Batch_Status__c,
            cv_pkg_dev_I__Gift_Date__c,
            cv_pkg_dev_I__Amount__c,
            cv_pkg_dev_I__Gift_Type__c,
            cv_pkg_dev_I__Receipt_Type__c,
            cv_pkg_dev_I__Expected_Amount__c,
            cv_pkg_dev_I__Channel__c,
            cv_pkg_dev_I__Package_Name__c,
            cv_pkg_dev_I__Anonymous__c,
            cv_pkg_dev_I__Internal_Solicitor__c,
            cv_pkg_dev_I__Internal_Solicitor__r.Name,
            cv_pkg_dev_I__Recurring_Donation__c,
            cv_pkg_dev_I__Recurring_Donation__r.cv_pkg_dev_I__Frequency__c,
            cv_pkg_dev_I__Recurring_Donation__r.cv_pkg_dev_I__of_Payments__c,
            Id,
            (Select Id, cv_pkg_dev_I__Payment_Type__c, cv_pkg_dev_I__Date__c, cv_pkg_dev_I__Date_Deposited__c From cv_pkg_dev_I__Recurring_Payments__r),
            (Select Id, cv_pkg_dev_I__Amount_Not_Eligible__c, cv_pkg_dev_I__Notes__c From cv_pkg_dev_I__Receipts__r),
            (Select Id,
                cv_pkg_dev_I__Amount__c,
                cv_pkg_dev_I__New_Campaign__c,
                cv_pkg_dev_I__New_Campaign__r.Name,
                cv_pkg_dev_I__Fund__c,
                cv_pkg_dev_I__Fund__r.Name,
                cv_pkg_dev_I__Product__c,
                cv_pkg_dev_I__Product__r.Name,
                cv_pkg_dev_I__Tribute__c,
                cv_pkg_dev_I__Tribute__r.Name,
                cv_pkg_dev_I__Description__c
            From cv_pkg_dev_I__Gift_Allocations__r)
        From cv_pkg_dev_I__Gift__c LIMIT 7];

    }

    public String getTranxData() {
        for(cv_pkg_dev_I__Gift__c each : transactions) {
            transactionMap.put(each.Id, each);
        }
        return JSON.serialize(transactionMap);
    }

    public pageReference newGiftBatchItem() {
        transactions.add(new cv_pkg_dev_I__Gift__c());
        return null;
    }
}