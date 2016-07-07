@isTest
public class consolidatedReceiptStatusTest{
    public static testMethod void consolidatedReceiptStatus(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        cv_pkg_dev_I__aNums__c cs1 = GLAllocationfieldUpdateTriggerTest.anumsSettings();

        cv_pkg_dev_I__FormSettings__c fs1 = GLAllocationfieldUpdateTriggerTest.formSettings();    
           
        Account a = GLAllocationfieldUpdateTriggerTest.acc();

        cv_pkg_dev_I__BatchSettings__c cs2 = GLAllocationfieldUpdateTriggerTest.batchSettings();        

        Contact c = GLAllocationfieldUpdateTriggerTest.con();
        
        Gift__c g= GLAllocationfieldUpdateTriggerTest.giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
        
        Receipt__c receipt = new Receipt__c();
        receipt.Gift__c = g.id;
        receipt.Status__c = 'Issued';
        receipt.Receipt_Type__c = 'Consolidated';
        receipt.RecordTypeId = rtype_Map.get('Issued');
        insert receipt;
    }
}