@isTest
Public class testConsolidatedReceiptController{
                            
    static testMethod void testCreateNewReceipt() {
        List<Payment__c> allPayments = new List<Payment__c>();
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;            
        
        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        Gift__c d1 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert d1;
        Gift__c d2 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert d2;
        allPayments.add(new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash',
                                        Status__c='Approved', Donation__c = d1.Id, Receipt__c=null));
        allPayments.add(new Payment__c(Date__c=null, Amount__c=200, Payment_Type__c='cash',
                                        Status__c='Approved', Donation__c=d1.Id, Receipt__c=null));
        allPayments.add(new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash',
                                        Status__c='Approved', Donation__c=d2.Id, Receipt__c=null));
        Insert allPayments;

        Test.startTest();
        PageReference pageRef = Page.ConsolidatedReceipt;
        pageRef.getParameters().put('cid', c.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController std = new ApexPages.StandardController(new Receipt__c());

        // Test Controller Catch Block.
        User u = [Select Id, Payment_Filter__c From User Where Id = :UserInfo.getUserId()];
        u.Payment_Filter__c = 'This Year';
        Update u;
        new ConsolidatedReceiptController(std);

        allPayments[1].Date__c=System.today();
        Update allPayments[1];

        ConsolidatedReceiptController controller = new ConsolidatedReceiptController(std);
        
        //getPaymentFilters()
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('This Year','This Year'));
        options.add(new SelectOption('Last Year','Last Year'));
        options.add(new SelectOption('All','All'));
        System.assertEquals(controller.getPaymentFilters(), options);

        //generateReceipt(), If no selected Payments.
        System.assertEquals(controller.generateReceipt(), null);

        //Select Payments.
        for(ConsolidatedReceiptController.paymentWrapper PW : controller.payments) {
            pw.selected = true;
        }

        //Test getTransactionsToAttach() IF recentIndex != 0.
        controller.payments[controller.payments.size()-1].payment.Donation__r.Gift_Date__c = System.today().addDays(10);

        //getTransactionsToAttach()
        controller.getTransactionsToAttach();

        //generateReceipt(), If Exception.
        System.assertEquals(controller.containsPayment, true);
        pageReference pageReturned = controller.generateReceipt();
        System.assertEquals(controller.containsPayment, false);
        System.assertEquals(null, pageReturned);

        //generateReceipt(), No Exception.
        controller.containsPayment = true;
        controller.receipt.Gift__c = d2.Id;
        pageReference pageReturned1 = controller.generateReceipt();
        pageReference pageValue = new pageReference('/' + controller.receipt.id);
        System.assertEquals(controller.containsPayment, true);


/*        System.assertEquals(msgs, msgs1);
        ApexPages.Message[] msgs = ApexPages.getMessages();
        ApexPages.Message[] msgs1 = new ApexPages.Message[]{ new ApexPages.Message(ApexPages.Severity.ERROR, 'Required fields are missing: [cv_pkg_dev_I__Gift__c]')};
*/

        //cancel()
        controller.cancel();

        //Apply all Payment Filters
        controller.selectedPaymentFilter = 'Last Year';
        controller.applyPaymentFilter();
        controller.selectedPaymentFilter = 'All';
        controller.applyPaymentFilter();

        //Test createNewReceipt() IF ELSE
        controller.allPayments[0].Donation__r.Constituent__c = null;
        controller.createNewReceipt();

        Test.stopTest();
    }

    static testMethod void testAllPaymentsSizeZero() {
        Test.startTest();
        PageReference pageRef = Page.ConsolidatedReceipt;
        pageRef.getParameters().put('cid', '123');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController std = new ApexPages.StandardController(new Receipt__c());
        ConsolidatedReceiptController controller = new ConsolidatedReceiptController(std);

        System.assertEquals(controller.containsPayment, false);        

        Test.stopTest();
    }
}