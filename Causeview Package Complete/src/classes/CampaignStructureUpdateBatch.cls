/*
* @author Nitin Khunal
* @date 08/10/2014
* @Campaign Structure Update - Allocation does not properly update
* @description This batch class update the Campaign structure - "Campaign, Parent Appeal, Appeal" on Allocation Record.
*/
global class CampaignStructureUpdateBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select causeview__New_Campaign__c, causeview__Campaign__c, causeview__Parent_Appeal__c, causeview__New_Campaign__r.Parent.RecordTypeId, causeview__New_Campaign__r.Parent.ParentId, causeview__New_Campaign__r.ParentId from causeview__Gift_Detail__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<causeview__Gift_Detail__c> giftDetailRecord){
         App_Settings__c settings = App_Settings__c.getInstance();
         Map<String, Id> rt_map = new Map<String, Id>();
        
         rt_map.put('Campaign', settings.Campaign_RecordType_Id__c);
         rt_map.put('Appeal', settings.Appeal_RecordType_Id__c); 
    
        List<causeview__Gift_Detail__c> giftDetailRecordList = new List<causeview__Gift_Detail__c>();
        for(causeview__Gift_Detail__c g : giftDetailRecord){
            if(g.causeview__New_Campaign__c != null){
                if(g.causeview__Parent_Appeal__c != g.causeview__New_Campaign__r.ParentId){
                    if(g.causeview__New_Campaign__r.ParentId == null){
                        g.causeview__Parent_Appeal__c = null;
                        g.causeview__Campaign__c = null;
                    }else
                    if(g.causeview__New_Campaign__r.Parent.RecordTypeId == rt_map.get('Appeal')){
                        g.causeview__Parent_Appeal__c = g.causeview__New_Campaign__r.ParentId;
                    }
                }
                if(g.causeview__New_Campaign__r.ParentId != null){
                    g.causeview__Campaign__c = g.causeview__New_Campaign__r.Parent.ParentId;
                }
                giftDetailRecordList.add(g);
            }
        }
        if(giftDetailRecordList.size() > 0)
        update giftDetailRecordList;
    }
    global void finish(Database.BatchableContext BC){
        
        System.scheduleBatch(new AppealRollupBatch(), 'AppealRollupBatch - '+system.Now(), 1, 1);
        System.scheduleBatch(new AppealRollupBatch2(), 'AppealRollupBatch2 - '+system.Now(), 5, 1);
        System.scheduleBatch(new AppealRollupBatch3(), 'AppealRollupBatch3 - '+system.Now(), 10, 1);
    }
}