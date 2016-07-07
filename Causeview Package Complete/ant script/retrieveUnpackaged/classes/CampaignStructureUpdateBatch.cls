/*
* @author Nitin Khunal
* @date 08/10/2014
* @Campaign Structure Update - Allocation does not properly update
* @description This batch class update the Campaign structure - "Campaign, Parent Appeal, Appeal" on Allocation Record.
*/
global class CampaignStructureUpdateBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select cv_pkg_dev_I__New_Campaign__c, cv_pkg_dev_I__Campaign__c, cv_pkg_dev_I__Parent_Appeal__c, cv_pkg_dev_I__New_Campaign__r.Parent.RecordTypeId, cv_pkg_dev_I__New_Campaign__r.Parent.ParentId, cv_pkg_dev_I__New_Campaign__r.ParentId from cv_pkg_dev_I__Gift_Detail__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<cv_pkg_dev_I__Gift_Detail__c> giftDetailRecord){
         App_Settings__c settings = App_Settings__c.getInstance();
         Map<String, Id> rt_map = new Map<String, Id>();
        
         rt_map.put('Campaign', settings.Campaign_RecordType_Id__c);
         rt_map.put('Appeal', settings.Appeal_RecordType_Id__c); 
    
        List<cv_pkg_dev_I__Gift_Detail__c> giftDetailRecordList = new List<cv_pkg_dev_I__Gift_Detail__c>();
        for(cv_pkg_dev_I__Gift_Detail__c g : giftDetailRecord){
            if(g.cv_pkg_dev_I__New_Campaign__c != null){
                if(g.cv_pkg_dev_I__Parent_Appeal__c != g.cv_pkg_dev_I__New_Campaign__r.ParentId){
                    if(g.cv_pkg_dev_I__New_Campaign__r.ParentId == null){
                        g.cv_pkg_dev_I__Parent_Appeal__c = null;
                        g.cv_pkg_dev_I__Campaign__c = null;
                    }else
                    if(g.cv_pkg_dev_I__New_Campaign__r.Parent.RecordTypeId == rt_map.get('Appeal')){
                        g.cv_pkg_dev_I__Parent_Appeal__c = g.cv_pkg_dev_I__New_Campaign__r.ParentId;
                    }
                }
                if(g.cv_pkg_dev_I__New_Campaign__r.ParentId != null){
                    g.cv_pkg_dev_I__Campaign__c = g.cv_pkg_dev_I__New_Campaign__r.Parent.ParentId;
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