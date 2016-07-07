trigger updateFund on Gift_Detail__c (before insert, before update) {
    system.debug('Nitin===');
    Set<Id> appealIds = new Set<Id>();
    for(Gift_Detail__c giftDetail : Trigger.new)
    {
        if(giftDetail.causeview__Fund__c == null && giftDetail.causeview__New_Campaign__c <> null)
        {
            if(Trigger.isInsert){
                appealIds.add(giftDetail.causeview__New_Campaign__c);
            }else
            if(Trigger.isUpdate && giftDetail.causeview__New_Campaign__c <> Trigger.oldMap.get(giftDetail.id).causeview__New_Campaign__c){
                appealIds.add(giftDetail.causeview__New_Campaign__c);
            }
        }
    }
    
    if(appealIds.size() > 0)
    {
        Map<Id, Campaign> appealFund= new Map<Id, Campaign>( [select Id, causeview__Fund__c from Campaign where Id IN:appealIds]);
        
        for(Gift_Detail__c giftDetail : Trigger.new)
        {
            if(appealFund.get(giftDetail.causeview__New_Campaign__c) != null)
            {   
                 giftDetail.causeview__Fund__c = appealFund.get(giftDetail.causeview__New_Campaign__c).causeview__Fund__c;
            }
        }
    }
}