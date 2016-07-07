public class ApplyAdjustmentButtonPageController{
    public cv_pkg_dev_I__Gift_Detail__c giftDetail{get;set;}
    Id allocationId;
    public ApplyAdjustmentButtonPageController(ApexPages.standardController sc){
        giftDetail = new cv_pkg_dev_I__Gift_Detail__c();
        allocationId = sc.getRecord().Id;
        system.debug('Nitin Allocation Id==='+allocationId);
    }
    public pageReference submit(){
        List<cv_pkg_dev_I__Gift_Detail__c> allocationsToInsert = new List<cv_pkg_dev_I__Gift_Detail__c>();
        cv_pkg_dev_I__Gift_Detail__c giftDetail1;
        cv_pkg_dev_I__Gift_Detail__c giftDetail2;
        cv_pkg_dev_I__Gift_Detail__c ExistingGiftDetail = [select Allocation_Date__c, cv_pkg_dev_I__Campaign__c, cv_pkg_dev_I__Parent_Appeal__c, cv_pkg_dev_I__New_Campaign__c, cv_pkg_dev_I__Package__c, cv_pkg_dev_I__Product__c,
                                                        cv_pkg_dev_I__Tribute__c, cv_pkg_dev_I__Fund__c, cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__Gift__c, cv_pkg_dev_I__Payment__c, cv_pkg_dev_I__Event_Level__c, cv_pkg_dev_I__Quantity__c,
                                                        cv_pkg_dev_I__GL_Auto_Debit_Account__c, cv_pkg_dev_I__GL_Auto_Credit_Account__c, cv_pkg_dev_I__Custom_Allocation_Text__c from cv_pkg_dev_I__Gift_Detail__c where Id =: allocationId];
        giftDetail1 = ExistingGiftDetail.clone(false, true);
        giftDetail1.cv_pkg_dev_I__Amount__c = 0 - ExistingGiftDetail.cv_pkg_dev_I__Amount__c;
        allocationsToInsert.add(giftDetail1);
        giftDetail2 = ExistingGiftDetail.clone(false, true);
        giftDetail2.cv_pkg_dev_I__Fund__c = giftDetail.cv_pkg_dev_I__Fund__c;
        allocationsToInsert.add(giftDetail2);
        if(allocationsToInsert.size() > 0){
            insert allocationsToInsert;
        }
        PageReference pageToRedirect = new PageReference('/'+allocationId);
        pageToRedirect.setRedirect(True);
        return pageToRedirect;
    }
}