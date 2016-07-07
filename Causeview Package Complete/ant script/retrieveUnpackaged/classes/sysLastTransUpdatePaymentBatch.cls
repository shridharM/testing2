global class sysLastTransUpdatePaymentBatch implements Database.Batchable<sObject>{
    
    Set<Id> setGiftIds = new Set<Id>();
    global sysLastTransUpdatePaymentBatch(Set<Id> giftIds){
        setGiftIds = giftIds;
    }
    
    global Database.queryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,sysLastTransactionUpdate__c FROM Event_Registration__c WHERE Transaction__c IN: setGiftIds]);
    }
    
    global void execute(Database.BatchableContext BC, List<Event_Registration__c> eventRegList){
        if(eventRegList.size() > 0) {
            for(Event_Registration__c eventReg: eventRegList)
            {
               eventReg.sysLastTransactionUpdate__c = system.today();
               //toUpdateEventReg.add(eventReg);
            }
            /*if(toUpdateEventReg.size() > 0) {
             update toUpdateEventReg;
            }*/
        }    
        system.debug('---- Script Statements: '+Limits.getScriptStatements()); 
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}