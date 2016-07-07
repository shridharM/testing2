@isTest
public class checkDuplicateNameTest{
    public static testMethod void checkDuplicateBatchTemplateName(){
        causeview__Batch_Template__c b = new causeview__Batch_Template__c(name = 'test123456');
        insert b;
        
        causeview__Batch_Template__c b1 = new causeview__Batch_Template__c(name = 'test123456');
        
        
        try
        {
        insert b1;
        }
        catch(Exception e)
        {
        Boolean expectedExceptionThrown =  e.getMessage().contains('Name already Exist!') ? true : false;
        } 
    }
    public static testMethod void checkDuplicateGiftBatchNameTrigger(){
        RecordType rtype = [select id, name from RecordType where Name = 'Parent' AND NamespacePrefix = 'Causeview'];
        causeview__Batch_Template__c b = new causeview__Batch_Template__c(name = 'test123456789', RecordTypeId = rtype.id);
        insert b;
        
        causeview__Gift_Batch__c g = new causeview__Gift_Batch__c(causeview__Name__c = 'Test123456789', causeview__Template_Name__c = b.id);
        insert g;
        
        causeview__Gift_Batch__c g1 = new causeview__Gift_Batch__c(causeview__Name__c = 'Test123456789', causeview__Template_Name__c = b.id);

        try
        {
            insert g1;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Name already Exist!') ? true : false;
        } 
    }
}