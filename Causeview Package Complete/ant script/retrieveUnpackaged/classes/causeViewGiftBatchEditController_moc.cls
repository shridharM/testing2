public with sharing class causeViewGiftBatchEditController_moc {
    public contact con {get;set;}
    public cv_pkg_dev_I__Recurring_Donation__c recurringDonation {get;set;}
    public cv_pkg_dev_I__Gift__c gift {get;set;}
    public cv_pkg_dev_I__Payment__c payment {get;set;}
    public cv_pkg_dev_I__Receipt__c receipt {get;set;}
    public cv_pkg_dev_I__Gift_Detail__c giftDetail {get;set;}
    
    public causeViewGiftBatchEditController_moc(){
        string recordId = Apexpages.currentPage().getParameters().get('id');
        System.debug('std---------'+recordId);
        if(recordId == null)return;
        List<cv_pkg_dev_I__Gift__c> giftList = [Select c.cv_pkg_dev_I__GiftBatch__c, c.cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Recurring_Donation__c, c.cv_pkg_dev_I__Package_Name__c, 
                                            c.cv_pkg_dev_I__Internal_Solicitor__c, c.cv_pkg_dev_I__Gift_Type__c, c.cv_pkg_dev_I__Gift_Date__c, 
                                            c.cv_pkg_dev_I__Channel__c, c.cv_pkg_dev_I__Anonymous__c, c.cv_pkg_dev_I__Amount__c ,
                                            (Select cv_pkg_dev_I__Date_Deposited__c, cv_pkg_dev_I__Date__c, cv_pkg_dev_I__Payment_Type__c From cv_pkg_dev_I__Recurring_Payments__r),
                                            c.cv_pkg_dev_I__Reference__c, c.cv_pkg_dev_I__Receipt_Type__c, c.cv_pkg_dev_I__Letter__c, 
                                            (Select cv_pkg_dev_I__Notes__c, cv_pkg_dev_I__Amount_Not_Eligible__c From cv_pkg_dev_I__Receipts__r), 
                                            (Select cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__New_Campaign__c, cv_pkg_dev_I__Product__c, cv_pkg_dev_I__Tribute__c, cv_pkg_dev_I__Fund__c, cv_pkg_dev_I__Description__c From cv_pkg_dev_I__Gift_Allocations__r)
                                            From cv_pkg_dev_I__Gift__c c where id = :recordId];
        if(giftList.isEmpty())return;
        else gift = giftList[0];
        string conId = giftList[0].cv_pkg_dev_I__Constituent__c;
        string recurringDonationId = giftList[0].cv_pkg_dev_I__Recurring_Donation__c;
        
        List<Contact> conList = [Select c.cv_pkg_dev_I__Trade_Status__c, c.cv_pkg_dev_I__Solicit_Codes__c, c.cv_pkg_dev_I__Region__c, c.cv_pkg_dev_I__Primary_Salutation__c, 
                c.cv_pkg_dev_I__Primary_Addressee__c, c.cv_pkg_dev_I__Household__c, c.cv_pkg_dev_I__Constituent_Codes__c, c.Phone, c.MailingStreet, 
                c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LastName, c.FirstName, c.Email 
                From Contact c where id = :conId];
        if(!conList.isEmpty()) {
            con = conList[0];
        }else con = new Contact();
                
        List<cv_pkg_dev_I__Recurring_Donation__c> recurringDonationList = [Select c.cv_pkg_dev_I__of_Payments__c, c.cv_pkg_dev_I__Start_Date__c, c.cv_pkg_dev_I__Frequency__c From cv_pkg_dev_I__Recurring_Donation__c c where id = :recurringDonationId];
        if(!recurringDonationList.isEmpty()) {
            recurringDonation = recurringDonationList[0];
        }else recurringDonation = new cv_pkg_dev_I__Recurring_Donation__c();
        
        List<cv_pkg_dev_I__Payment__c> paymentList = gift.cv_pkg_dev_I__Recurring_Payments__r;
        if(!paymentList.isEmpty()) {
            payment = paymentList[0];
        }else payment = new cv_pkg_dev_I__Payment__c();
        
        List<cv_pkg_dev_I__Receipt__c> receiptList = gift.cv_pkg_dev_I__Receipts__r;
        if(!receiptList.isEmpty()) {
            receipt = receiptList[0];
        }else receipt = new cv_pkg_dev_I__Receipt__c();
        
        List<cv_pkg_dev_I__Gift_Detail__c> giftDetailList = gift.cv_pkg_dev_I__Gift_Allocations__r;
        if(!giftDetailList.isEmpty()) {
            giftDetail = giftDetailList[0];
        }else giftDetail = new cv_pkg_dev_I__Gift_Detail__c();
        //Select c.cv_pkg_dev_I__Package_Name__c, c.cv_pkg_dev_I__Internal_Solicitor__c, c.cv_pkg_dev_I__Gift_Type__c, c.cv_pkg_dev_I__Gift_Date__c, c.cv_pkg_dev_I__Channel__c, c.cv_pkg_dev_I__Anonymous__c, c.cv_pkg_dev_I__Amount__c From cv_pkg_dev_I__Gift__c c
    }
    
    public void save(){
        
    }
    
    public void saveAndNew(){
        
    }
    
    public Pagereference cancel(){
        System.debug('ppp--------'+gift.cv_pkg_dev_I__GiftBatch__c);
        return new Pagereference('/apex/BatchTransactions?id='+gift.cv_pkg_dev_I__GiftBatch__c);
    }
}