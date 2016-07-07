@isTest
private class TestMultiChannelCampaign {

    static testMethod void myUnitTest() {
        Campaign c = new Campaign(Name='Test Campaign');
        insert c;
        List<Campaign> cs = new Campaign[] { c };
        ApexPages.StandardSetController std = new ApexPages.StandardSetController(cs);
        MultichannelCampaignController cnt = new MultichannelCampaignController(std);
        cnt.isTesting = false;
        cnt.campaignId = c.Id;
        cnt.init();
        
        MultichannelCampaignController.CampaignWrapper wrapper = new MultichannelCampaignController.CampaignWrapper(c,new List<causeview__Goal__c>());        
        
        cnt.newAppeal.Name = 'test appeal';
        cnt.newGoal.Name = 'test goal';
        cnt.newGoal.causeview__Q1_Goal__c=300;
        cnt.newGoal.causeview__Q2_Goal__c=345;
        cnt.newGoal.causeview__Q3_Goal__c=456;
        cnt.newGoal.causeview__Q4_Goal__c=3400;
        cnt.saveAll();
        
        cnt.addAppeal();
       
        cnt.newAppeal.Name = 'test appeal';
        cnt.newGoal.Name = 'test goal';
        //cnt.newGoal.causeview__Q1_Goal__c=300;
        //cnt.newGoal.causeview__Q2_Goal__c=345;
        //cnt.newGoal.causeview__Q3_Goal__c=456;
        //cnt.newGoal.causeview__Q4_Goal__c=3400;
        cnt.newGoal.causeview__Overall_Goal__c = 534;
        cnt.newGoal.causeview__Active__c = true;
        cnt.newGoal.causeview__Fiscal_Year__c = '2012';
        cnt.campaignGoal.Name='test campaign goal';
        cnt.campaignGoal.causeview__Q1_Goal__c=300;
        cnt.campaignGoal.causeview__Q2_Goal__c=345;
        cnt.campaignGoal.causeview__Q3_Goal__c=456;
        cnt.campaignGoal.causeview__Q4_Goal__c=3400;
        cnt.campaignGoal.causeview__Overall_Goal__c = 534;
        //cnt.isTesting = true;
        cnt.saveAll();
        
        cnt.cancelLastAction();
        if (cnt.newAppeal.Id == null)
            insert cnt.newAppeal;
        cnt.selectedAppealId = cnt.newAppeal.Id;
        cnt.newGoal();
        cnt.addGoal();
        
        
        
    }
}