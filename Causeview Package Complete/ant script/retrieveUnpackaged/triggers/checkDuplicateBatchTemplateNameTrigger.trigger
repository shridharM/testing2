trigger checkDuplicateBatchTemplateNameTrigger on Batch_Template__c (before insert) {
    RecordType rtype = [select id, name from RecordType where Name = 'Parent' AND NamespacePrefix = 'causeview'];
    Set<String> batchTemplateName = new Set<String>();
    for(Batch_Template__c b : Trigger.New){
        batchTemplateName.add(b.Name);
    }
    List<cv_pkg_dev_I__Batch_Template__c> batchTemplateRecordList = [select Name, RecordTypeId from cv_pkg_dev_I__Batch_Template__c where name =: batchTemplateName AND RecordTypeId =: rtype.id];
    
    if(batchTemplateRecordList.size() > 0){
        for(cv_pkg_dev_I__Batch_Template__c batchTemplate : trigger.New){
            for(cv_pkg_dev_I__Batch_Template__c batchTemplateList : batchTemplateRecordList){
                if(batchTemplate.Name == batchTemplateList.Name && batchTemplate.RecordTypeId == rtype.id){
                    batchTemplate.addError('The Gift Batch Template Name you entered already exists. Please enter a unique name.');
                }
            }
        }
    }
}