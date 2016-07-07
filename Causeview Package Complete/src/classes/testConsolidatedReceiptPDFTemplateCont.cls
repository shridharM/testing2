@isTest
Public class testConsolidatedReceiptPDFTemplateCont{
                            
    static testMethod void testContent() {
        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;         
        
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
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
            Name = 'settings', causeview__EmailTemplateId__c = '012A000000128Ds', causeview__ReceiptEmailDocId__c = '012A000000128Df',
            causeview__ReceiptPDFDocId__c = '012A000000128Dr');
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