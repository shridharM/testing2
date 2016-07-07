trigger checkDuplicateGiftBatchNameTrigger on Gift_Batch__c (before insert) {
    Set<String> giftBatchName = new Set<String>();
    for(Gift_Batch__c g : Trigger.New){
        giftBatchName.add(g.causeview__Name__c);
    }
    List<causeview__Gift_Batch__c> giftBatchRecordList = [select causeview__Name__c from causeview__Gift_Batch__c where causeview__Name__c =: giftBatchName];
    
    if(giftBatchRecordList.size() > 0){
        for(causeview__Gift_Batch__c giftBatch : trigger.New){
            for(causeview__Gift_Batch__c giftBatchList : giftBatchRecordList){
                if(giftBatch.causeview__Name__c == giftBatchList.causeview__Name__c){
                    giftBatch.addError('Name already Exist!'); //
                }
            }
        }
    }
}