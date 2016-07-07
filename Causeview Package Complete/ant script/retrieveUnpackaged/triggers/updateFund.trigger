trigger updateFund on Gift_Detail__c (before insert, before update) {
    system.debug('Nitin===');
    Set<Id> appealIds = new Set<Id>();
    for(Gift_Detail__c giftDetail : Trigger.new)
    {
        if(giftDetail.cv_pkg_dev_I__Fund__c == null && giftDetail.cv_pkg_dev_I__New_Campaign__c <> null)
        {
            if(Trigger.isInsert){
                appealIds.add(giftDetail.cv_pkg_dev_I__New_Campaign__c);
            }else
            if(Trigger.isUpdate && giftDetail.cv_pkg_dev_I__New_Campaign__c <> Trigger.oldMap.get(giftDetail.id).cv_pkg_dev_I__New_Campaign__c){
                appealIds.add(giftDetail.cv_pkg_dev_I__New_Campaign__c);
            }
        }
    }
    
    if(appealIds.size() > 0)
    {
        Map<Id, Campaign> appealFund= new Map<Id, Campaign>( [select Id, cv_pkg_dev_I__Fund__c from Campaign where Id IN:appealIds]);
        
        for(Gift_Detail__c giftDetail : Trigger.new)
        {
            if(appealFund.get(giftDetail.cv_pkg_dev_I__New_Campaign__c) != null)
            {   
                 giftDetail.cv_pkg_dev_I__Fund__c = appealFund.get(giftDetail.cv_pkg_dev_I__New_Campaign__c).cv_pkg_dev_I__Fund__c;
            }
        }
    }
}