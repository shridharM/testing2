trigger checkDuplicateGiftBatchNameTrigger on Gift_Batch__c (before insert) {
    Set<String> giftBatchName = new Set<String>();
    for(Gift_Batch__c g : Trigger.New){
        giftBatchName.add(g.cv_pkg_dev_I__Name__c);
    }
    List<cv_pkg_dev_I__Gift_Batch__c> giftBatchRecordList = [select cv_pkg_dev_I__Name__c from cv_pkg_dev_I__Gift_Batch__c where cv_pkg_dev_I__Name__c =: giftBatchName];
    
    if(giftBatchRecordList.size() > 0){
        for(cv_pkg_dev_I__Gift_Batch__c giftBatch : trigger.New){
            for(cv_pkg_dev_I__Gift_Batch__c giftBatchList : giftBatchRecordList){
                if(giftBatch.cv_pkg_dev_I__Name__c == giftBatchList.cv_pkg_dev_I__Name__c){
                    giftBatch.addError('Name already Exist!'); //
                }
            }
        }
    }
}