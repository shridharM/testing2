@isTest
Public class testConsolidatedReceiptPDFTemplateCont{
                            
    static testMethod void testContent() {
        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;         
        
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
         
        Gift__c g = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert g;

        Receipt__c receipt = new Receipt__c();
        receipt.Gift__c = g.Id;
        receipt.Amount_Receipted__c = 200;
        receipt.Constituent__c = c.Id;
        Insert receipt;

        Payment__c payment = new Payment__c();
        payment.Amount__c = 200;
        payment.Receipt__c = receipt.Id;
        payment.Donation__c = g.Id;

        Insert payment;

        givingpowerSettings__c gps = new givingpowerSettings__c(
            DupeConsolidatedReceiptPDFDocId__c = '012A000000128DT', ConsolidatedReceiptPDFDocId__c = '012A000000128DA',
            Name = 'settings', cv_pkg_dev_I__EmailTemplateId__c = '012A000000128Ds', cv_pkg_dev_I__ReceiptEmailDocId__c = '012A000000128Df',
            cv_pkg_dev_I__ReceiptPDFDocId__c = '012A000000128Dr');
        Insert gps;

        Test.startTest();
        ConsolidatedReceiptPDFTemplateController controller = new ConsolidatedReceiptPDFTemplateController();
        System.assertEquals(controller.content, '');

        controller.relatedToType = 'Receipt__c';
        controller.recipientType = 'Contact';
        controller.isDupe = 'True';
        controller.relatedToId = receipt.Id;
        controller.recipientId = c.Id;
        System.assertEquals(controller.content, '');

        controller.isDupe = 'false';
        System.assertEquals(controller.content, '');

        Test.stopTest();
     }
}