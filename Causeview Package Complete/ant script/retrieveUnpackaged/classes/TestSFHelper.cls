@isTest
public class TestSFHelper{
 
  static testMethod void testMe()
    { 
        Test.startTest(); 
         App_Settings__c appSetting = SFHelper.GetCVAppSettings();
         BatchSettings__c batchSetting = SFHelper.GetDefaultBatchSettings();
         BatchSettings__c batchSetting1 = SFHelper.GetBatchSettings('Default');
        Test.stopTest(); 
    }
 }