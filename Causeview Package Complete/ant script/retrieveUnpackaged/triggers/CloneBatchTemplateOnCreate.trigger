trigger CloneBatchTemplateOnCreate on Gift_Batch__c (after insert) {

    RecordType RT = [SELECT Id FROM RecordType WHERE SobjectType = 'cv_pkg_dev_I__Batch_Template__c' AND Name = 'Cloned'];

    Map<Id, List<Gift_Batch__c>> giftBatchMap = new Map<Id, List<Gift_Batch__c>>();
    Map<Id, Batch_Template__c> templateMap = new Map<Id, Batch_Template__c>();

    for(Gift_Batch__c gb : [Select Id, Template_Name__c From Gift_Batch__c Where Id IN : Trigger.newMap.keySet()]) {
        if(giftBatchMap.get(gb.Template_Name__c) != null) {
            giftBatchMap.get(gb.Template_Name__c).add(gb);
        } else {
            List<Gift_Batch__c> gbs = new List<Gift_Batch__c>();
            gbs.add(gb);
            giftBatchMap.put(gb.Template_Name__c, gbs);
        }
    }

    for(Batch_Template__c temp : [Select cv_pkg_dev_I__AccountFieldsXml__c,cv_pkg_dev_I__ContactFieldXml__c,cv_pkg_dev_I__EventRegistrationsFieldsXml__c,
                                            cv_pkg_dev_I__GiftDetailFieldsXml__c,cv_pkg_dev_I__PaymentFieldsXml__c,cv_pkg_dev_I__ReceiptFieldsXml__c,
                                            cv_pkg_dev_I__RecurringGiftFieldsXml__c,cv_pkg_dev_I__TransactionFieldsXml__c,cv_pkg_dev_I__Type__c,Id,Name,RecordTypeId,Transaction_Type__c 
                                            From Batch_Template__c Where RecordType.Name = 'Parent' And Id IN : giftBatchMap.keySet()]) {

        for(Gift_Batch__c g : giftBatchMap.get(temp.Id)) {
            Batch_Template__c newTemp = temp.clone(false, true, false, true);
            newTemp.RecordTypeId = RT.Id;
            templateMap.put(g.Id, newTemp);
        }
    }

    insert templateMap.values();

    List<Gift_Batch__c> giftBatches = new List<Gift_Batch__c>();

    for(Id id : giftBatchMap.keySet()) {
        for(Gift_Batch__c g : giftBatchMap.get(id)) {
            if(templateMap.get(g.Id) != null) {
                g.Template_Name__c = templateMap.get(g.Id).Id;
                giftBatches.add(g);
            }
        }
    }

    update giftBatches;
}