@isTest
public class checkDuplicateNameTest{
    public static testMethod void checkDuplicateBatchTemplateName(){
        cv_pkg_dev_I__Batch_Template__c b = new cv_pkg_dev_I__Batch_Template__c(name = 'test123456');
        insert b;
        
        cv_pkg_dev_I__Batch_Template__c b1 = new cv_pkg_dev_I__Batch_Template__c(name = 'test123456');
        
        
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
        cv_pkg_dev_I__Batch_Template__c b = new cv_pkg_dev_I__Batch_Template__c(name = 'test123456789', RecordTypeId = rtype.id);
        insert b;
        
        cv_pkg_dev_I__Gift_Batch__c g = new cv_pkg_dev_I__Gift_Batch__c(cv_pkg_dev_I__Name__c = 'Test123456789', cv_pkg_dev_I__Template_Name__c = b.id);
        insert g;
        
        cv_pkg_dev_I__Gift_Batch__c g1 = new cv_pkg_dev_I__Gift_Batch__c(cv_pkg_dev_I__Name__c = 'Test123456789', cv_pkg_dev_I__Template_Name__c = b.id);

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