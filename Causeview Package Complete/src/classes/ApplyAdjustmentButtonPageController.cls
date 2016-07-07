public with sharing class ApplyAdjustmentButtonPageController{
    public causeview__Gift_Detail__c giftDetail{get;set;}
    Id allocationId;
    public ApplyAdjustmentButtonPageController(ApexPages.standardController sc){
        giftDetail = new causeview__Gift_Detail__c();
        allocationId = sc.getRecord().Id;
        system.debug('Nitin Allocation Id==='+allocationId);
    }
    public pageReference submit(){
        List<causeview__Gift_Detail__c> allocationsToInsert = new List<causeview__Gift_Detail__c>();
        causeview__Gift_Detail__c giftDetail1;
        causeview__Gift_Detail__c giftDetail2;
        causeview__Gift_Detail__c ExistingGiftDetail = [select Allocation_Date__c, causeview__Campaign__c, causeview__Parent_Appeal__c, causeview__New_Campaign__c, causeview__Package__c, causeview__Product__c,
                                                        causeview__Tribute__c, causeview__Fund__c, causeview__Amount__c, causeview__Gift__c, causeview__Payment__c, causeview__Event_Level__c, causeview__Quantity__c,
                                                        causeview__GL_Auto_Debit_Account__c, causeview__GL_Auto_Credit_Account__c, causeview__Custom_Allocation_Text__c from causeview__Gift_Detail__c where Id =: allocationId];
        giftDetail1 = ExistingGiftDetail.clone(false, true);
        giftDetail1.causeview__Amount__c = 0 - ExistingGiftDetail.causeview__Amount__c;
        allocationsToInsert.add(giftDetail1);
        giftDetail2 = ExistingGiftDetail.clone(false, true);
        giftDetail2.causeview__Fund__c = giftDetail.causeview__Fund__c;
        allocationsToInsert.add(giftDetail2);
        if(allocationsToInsert.size() > 0){
            insert allocationsToInsert;
        }
        PageReference pageToRedirect = new PageReference('/'+allocationId);
        pageToRedirect.setRedirect(True);
        return pageToRedirect;
    }
}