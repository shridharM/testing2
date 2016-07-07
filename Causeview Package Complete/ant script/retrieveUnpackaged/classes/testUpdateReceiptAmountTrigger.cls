@isTest
Public class testUpdateReceiptAmountTrigger{
                            
    static testMethod void testUpdateReceiptAmount() {

        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'Causeview' LIMIT 1];        
         
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a; 
   
        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        
        cv_pkg_dev_I__BatchSettings__c bs= new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert bs;

            
        Gift__c g = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert g;

        Receipt__c receipt = new Receipt__c();
        receipt.Gift__c = g.Id;
        Insert receipt;

        Payment__c payment = new Payment__c();
        payment.Amount__c = 200;
        payment.Receipt__c = receipt.Id;
        payment.Donation__c = g.Id;
        
        system.debug('receipt '+receipt);
        
        //When payment is added to consolidated receipt (via lookup field).
        System.assertEquals(receipt.Amount_Receipted__c, null);
        Insert payment;
        System.assertEquals([Select Amount_Receipted__c From Receipt__c Where Id = :receipt.Id].Amount_Receipted__c, null);

        //When payment amount is Updated.
        payment.Amount__c = 500;
        Update payment;
        System.assertEquals([Select Amount_Receipted__c From Receipt__c Where Id = :receipt.Id].Amount_Receipted__c, null);

        //When payment is removed from consolidated receipt (via lookup field).
        payment.Receipt__c = null;
        Update payment;
        System.assertEquals([Select Amount_Receipted__c From Receipt__c Where Id = :receipt.Id].Amount_Receipted__c, null);
    }
}