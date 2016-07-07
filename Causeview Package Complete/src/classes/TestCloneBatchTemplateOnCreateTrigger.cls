@isTest
public class TestCloneBatchTemplateOnCreateTrigger {
    static TestMethod void test() {
        RecordType RT = [SELECT Id FROM RecordType WHERE SobjectType = 'causeview__Batch_Template__c' AND Name = 'Parent'];
        causeview__Batch_Template__c temp = new causeview__Batch_Template__c();
        temp.Name = 'test';
        temp.RecordTypeId = RT.Id;
        Insert temp;

        Gift_Batch__c gb = new Gift_Batch__c();
        gb.Name__c = 'batch';
        gb.Template_Name__c = temp.Id;
        Insert gb;

        //System.assertNotEquals([Select Id, Template_Name__c From Gift_Batch__c Where Id =: gb.Id].Template_Name__c, temp.Id);
    }
}