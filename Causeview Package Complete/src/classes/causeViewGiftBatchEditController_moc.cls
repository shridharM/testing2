public with sharing class causeViewGiftBatchEditController_moc {
    public contact con {get;set;}
    public causeview__Recurring_Donation__c recurringDonation {get;set;}
    public causeview__Gift__c gift {get;set;}
    public causeview__Payment__c payment {get;set;}
    public causeview__Receipt__c receipt {get;set;}
    public causeview__Gift_Detail__c giftDetail {get;set;}
    
    public causeViewGiftBatchEditController_moc(){
        string recordId = Apexpages.currentPage().getParameters().get('id');
        System.debug('std---------'+recordId);
        if(recordId == null)return;
        List<causeview__Gift__c> giftList = [Select c.causeview__GiftBatch__c, c.causeview__Constituent__c, causeview__Recurring_Donation__c, c.causeview__Package_Name__c, 
                                            c.causeview__Internal_Solicitor__c, c.causeview__Gift_Type__c, c.causeview__Gift_Date__c, 
                                            c.causeview__Channel__c, c.causeview__Anonymous__c, c.causeview__Amount__c ,
                                            (Select causeview__Date_Deposited__c, causeview__Date__c, causeview__Payment_Type__c From causeview__Recurring_Payments__r),
                                            c.causeview__Reference__c, c.causeview__Receipt_Type__c, c.causeview__Letter__c, 
                                            (Select causeview__Notes__c, causeview__Amount_Not_Eligible__c From causeview__Receipts__r), 
                                            (Select causeview__Amount__c, causeview__New_Campaign__c, causeview__Product__c, causeview__Tribute__c, causeview__Fund__c, causeview__Description__c From causeview__Gift_Allocations__r)
                                            From causeview__Gift__c c where id = :recordId];
        if(giftList.isEmpty())return;
        else gift = giftList[0];
        string conId = giftList[0].causeview__Constituent__c;
        string recurringDonationId = giftList[0].causeview__Recurring_Donation__c;
        
        List<Contact> conList = [Select c.causeview__Trade_Status__c, c.causeview__Solicit_Codes__c, c.causeview__Region__c, c.causeview__Primary_Salutation__c, 
                c.causeview__Primary_Addressee__c, c.causeview__Household__c, c.causeview__Constituent_Codes__c, c.Phone, c.MailingStreet, 
                c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LastName, c.FirstName, c.Email 
                From Contact c where id = :conId];
        if(!conList.isEmpty()) {
            con = conList[0];
        }else con = new Contact();
                
        List<causeview__Recurring_Donation__c> recurringDonationList = [Select c.causeview__of_Payments__c, c.causeview__Start_Date__c, c.causeview__Frequency__c From causeview__Recurring_Donation__c c where id = :recurringDonationId];
        if(!recurringDonationList.isEmpty()) {
            recurringDonation = recurringDonationList[0];
        }else recurringDonation = new causeview__Recurring_Donation__c();
        
        List<causeview__Payment__c> paymentList = gift.causeview__Recurring_Payments__r;
        if(!paymentList.isEmpty()) {
            payment = paymentList[0];
        }else payment = new causeview__Payment__c();
        
        List<causeview__Receipt__c> receiptList = gift.causeview__Receipts__r;
        if(!receiptList.isEmpty()) {
            receipt = receiptList[0];
        }else receipt = new causeview__Receipt__c();
        
        List<causeview__Gift_Detail__c> giftDetailList = gift.causeview__Gift_Allocations__r;
        if(!giftDetailList.isEmpty()) {
            giftDetail = giftDetailList[0];
        }else giftDetail = new causeview__Gift_Detail__c();
        //Select c.causeview__Package_Name__c, c.causeview__Internal_Solicitor__c, c.causeview__Gift_Type__c, c.causeview__Gift_Date__c, c.causeview__Channel__c, c.causeview__Anonymous__c, c.causeview__Amount__c From causeview__Gift__c c
    }
    
    public void save(){
        
    }
    
    public void saveAndNew(){
        
    }
    
    public Pagereference cancel(){
        System.debug('ppp--------'+gift.causeview__GiftBatch__c);
        return new Pagereference('/apex/BatchTransactions?id='+gift.causeview__GiftBatch__c);
    }
}