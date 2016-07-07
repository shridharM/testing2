@isTest
public class voidDetailUpdateOnReceiptTriggerTest{
    
    public static testMethod void voidDetailUpdateOnReceiptTriggerTest(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund' OR Name = 'Void') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
        
        Gift__c g= new Gift__c();
        g.Status__c = 'Active';
        g.Gift_Type__c = 'One Time Gift';
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtypes_Map.get('Gift');
        insert g;
        
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Written Off';
        p1.Donation__c = g.Id;
        insert p1;
        
        Receipt__c receipt = new Receipt__c(Gift__c = g.Id, Amount_Not_Eligible__c =0);
        insert receipt;
        
        p1.Receipt__c = receipt.id;
        update p1;
        
        receipt.RecordTypeId = rtypes_Map.get('Void');
        update receipt;
    }
}