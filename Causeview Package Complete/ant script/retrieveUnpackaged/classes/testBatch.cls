@isTest
global class testBatch {

      public static testMethod void TestMe3435()
        {
                //PageReference pageRef = Page.lookup;
                //Test.setCurrentPage(pageRef);
                lookupController controller = new lookupController();
                boolean b = controller.hasRecords;
                controller.searchValue = 'test';
                controller.viewType = 'Contact';
                controller.doSearch();
                controller.viewType = 'Account';
                controller.doSearch();
        }
        
    static testMethod void testMe3()
    {        
        codeCoverage s = new codeCoverage();

    }
    
    static testMethod void testMe()
   { 
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        Account acc = new Account(Name='test');
        insert acc;
        acc = [SELECT id,Name,Organization_ID__c FROM Account WHERE id=:acc.Id limit 1];
                
        Contact c = new Contact(LastName='test ln');
        c.MailingCity = 'Toronto';
        c.AccountId = acc.Id;
        insert c;
                
        c = [SELECT id,Name,LastName,FirstName,Constituent_ID__c FROM Contact WHERE id=:c.Id limit 1];
       
       cv_pkg_dev_I__Batch_Template__c bt123 = new cv_pkg_dev_I__Batch_Template__c();
        bt123.name = 'abc';
        insert bt123;
       
       Gift_Batch__c gb = new Gift_Batch__c();
       gb.Name__c = 'test';
       gb.cv_pkg_dev_I__Template_Name__c = bt123.id;
       insert gb;
           ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(gb);
       GiftBatchController cnt = new GiftBatchController(std);
       cnt.newBatchItemInterface();
       cnt.SelectedBatch = gb;
           cnt.tryParseToInt('sfsdsd');
       cnt.tryParseToInt('44');
       
       cnt.SelectedBatch.Name__c = '';
       cnt.saveBatch();
       
       string i = cnt.selectedBatchId;
       cnt.editBatch();
       cnt.saveBatch();
       cnt.nilMethod();
       cnt.newGift();
       cnt.FindAppeal();
       cnt.populateAmount();
       cnt.populateDate();
       
       cnt.curr_wrapper.isIndividualGift = false;
       cnt.curr_wrapper.constituent.LastName='fsdfsdf';
       cnt.curr_wrapper.constituent.FirstName = 'asdsadsa';
       cnt.curr_wrapper.constituent.Email = 'sdsad@dasd.com';
       cnt.saveItemAndNew();
       
       cnt.validateExpirationDate('4567');
       cnt.validateExpirationDate('0167');
       cnt.validateExpirationDate('0101');
       cnt.validateExpirationDate('dsdkdjkas');
       
       cnt.curr_wrapper = null;
       cnt.EditBatchItem();


        //Test UpdateRecurringUI.
       cnt.UpdateRecurringUI();
       cnt.curr_wrapper.recurringDonation = new Recurring_Donation__c();
       cnt.curr_wrapper.recurringDonation.Frequency__c = '5';
       cnt.UpdateRecurringUI();


       cnt.saveItem();

        //Test GetAppealDefaults.
       GiftBatchController.GetAppealDefaults('123');
       Campaign camp = new campaign(Name = 'appeal');
       Letter__c l = new Letter__c(Name__c = 'letter');
       insert l;
       Fund__c f = new Fund__c();
       insert f;
       camp.Letter__c = l.Id; 
       camp.Fund__c = f.Id; 
       insert camp; 
       GiftBatchController.GetAppealDefaults(camp.Id);
   }
   
     
  static testMethod void testBatch_Scenario1()
  {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        Account acc = new Account(Name='test');
        insert acc;
        acc = [SELECT id,Name,Organization_ID__c FROM Account WHERE id=:acc.Id limit 1];
        
        cv_pkg_dev_I__Batch_Template__c bt123 = new cv_pkg_dev_I__Batch_Template__c();
        bt123.name = 'abc';
        insert bt123;
        
        Gift_Batch__c gb = new Gift_Batch__c();
        gb.Name__c = 'test';
        gb.cv_pkg_dev_I__Template_Name__c = bt123.id;
        insert gb;
        
        Contact c = new Contact(LastName='test ln');
        c.MailingCity = 'Toronto';
        c.AccountId = acc.Id;
        insert c;
                
        c = [SELECT id,Name,LastName,FirstName,Constituent_ID__c FROM Contact WHERE id=:c.Id limit 1];
       
        //third gift (corporate)
        Gift__c g = new Gift__c();
        g.GiftBatch__c = gb.Id;
        g.Organization__c = acc.Id;
        g.Gift_Type__c = 'Gift in Kind';
        g.Batch_Status__c = 'Pending';
        g.RecordTypeId = bs.RegularGiftRecordTypeId__c;
        insert g;
        
        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'Check';
        p2.Amount__c = 85;
        p2.Donation__c = g.Id;
        insert p2;

        Test.startTest();

        ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(gb);
        GiftBatchController cnt = new GiftBatchController(std);
        cnt.SelectedBatch = gb;
        boolean b = cnt.isBatchClosed;
        cnt.SelectedBatch.Close_Date__c = Date.today();
        b = cnt.isBatchClosed;
        b = cnt.hasItems;
        string s = cnt.userLocale;
        cnt.giftItems = new List<GiftBatchWrapper>();

        cnt.updateReconciliation();
        
        //generic tests
        cnt.newGift();
        cnt.cancel();
        
        cnt.ContactSearchText = 'test345345';
        cnt.FindContact();
        
        cnt.ContactSearchText = c.Constituent_ID__c;
        cnt.FindContact();
                
        cnt.AccountSearchText = 'test456859658';
        cnt.FindAccount();
        
        cnt.AccountSearchText = 'test';
        cnt.FindAccount();
        
        cnt.AccountSearchText = acc.Organization_ID__c;
        cnt.FindAccount();
        
        cnt.nilMethod();
        
        cnt.SelectedAccountId = acc.Id;
        cnt.SelectedContactId = c.Id;
        
        cnt.giftItems = GiftBatchWrapper.GetBatchData(gb.Id, new User());
        //testing normal scenario
        cnt.selectedGiftId = g.Id;
        cnt.EditBatchItem();
      
        cnt.updateReconciliation();
        cnt.saveItem();
        
        cnt.curr_wrapper.noteBody = 'test';
        cnt.curr_wrapper.noteSubject  = '';
        cnt.curr_wrapper.isIndividualGift = false;
        cnt.saveItem();
        
        cnt.curr_wrapper.recurringDonation.Frequency__c = null;
        cnt.curr_wrapper.payment.Payment_Type__c = 'Credit Card';
        cnt.curr_wrapper.payment.Amount__c = 80;
        cnt.curr_wrapper.CCNumber = '23432423423784';
        cnt.curr_wrapper.expirationDate = '1212';
        cnt.MakePaymentsClicked();
        //cnt.submit();
        
        cnt.curr_wrapper.isIndividualGift = true;
        cnt.curr_wrapper.noteSubject  = 'sdfsa';
        cnt.saveItemAndNew();
        
        cnt.curr_wrapper.payment.Payment_Type__c = 'Credit Card';
                cnt.curr_wrapper.CCNumber = '23432423423784';
                cnt.curr_wrapper.payment.Amount__c = 80;
        cnt.curr_wrapper.expirationDate = '1212';
        //cnt.submit();
        cnt.selectedGiftId = g.id;
        cnt.EditBatchItem();
        BatchSettings__c settings = cnt.batchSettings;
        cnt.updateReconciliation();
        cnt.commitBatch();
        
        cnt.SelectedBatchName = 'test';
        cnt.selectedGiftId = g.Id;
        cnt.EditBatchItem();
        cnt.editBatch();
        cnt.saveBatch();
        cnt.addGiftDetail();
        
        cnt.isTesting = true;
        cnt.saveBatch();
        cnt.commitBatch();  
        
        string dou =  cnt.selectedBatchId;

        Test.stopTest();    
  }
  
   static testMethod void testCorporateBatch()
   {
        
        Test.startTest();
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), cv_pkg_dev_I__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            cv_pkg_dev_I__Event_RecordType_Id__c = rtypes_Map.get('Event'), cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();

        Account acc = new Account(Name='test dfsfsd');
        insert acc;
        
        cv_pkg_dev_I__Batch_Template__c bt123 = new cv_pkg_dev_I__Batch_Template__c();
        bt123.name = 'abc';
        insert bt123;
        
        Gift_Batch__c gb = new Gift_Batch__c();
        gb.Name__c = 'test uiou io';
        gb.Open_Date__c = Date.today();
        gb.cv_pkg_dev_I__Template_Name__c = bt123.id;
        insert gb;
       
        Contact c2 = new Contact(LastName='test ln',FirstName='wewerwe');
        c2.AccountId = acc.Id;
        insert c2;
        
        Gift__c g = new Gift__c();
        g.GiftBatch__c = gb.Id;
        g.Organization__c = acc.Id;
        g.Gift_Type__c = 'Gift in Kind';
        g.Batch_Status__c = 'Pending';
        g.Receipt_Type__c = 'One Receipt per Gift';
        g.RecordTypeId = bs.RegularGiftRecordTypeId__c;
        insert g;
        
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Check';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Pending';
        p1.Donation__c = g.Id;
        insert p1;
         
        Campaign camp = new campaign(Name = 'appeal');
        insert camp; 
         
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.Amount__c = 80;
        gd.New_campaign__c = camp.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        insert gd; 

        // create HttpCalloutMockImpl
        
        
        ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(gb);
        GiftBatchController cnt = new GiftBatchController(std);
        cnt.SelectedBatch = gb;
        cnt.selectedGiftId = g.Id;
        cnt.EditBatchItem();

        cnt.updateReconciliation();
        cnt.curr_wrapper.isIndividualGift = false;
        cnt.curr_wrapper.account.Name = 'sadsadsa';
        cnt.saveItem();

        cnt.updateReconciliation();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //cnt.submit();
        
        cnt.curr_wrapper.gift.Batch_Status__c = 'Committed';
        cnt.updateReconciliation(); 
        Test.stopTest();
     
    }
    
       
    static testMethod void testGateway()
    {
       BatchGateway3.FormAttribute fattr = new BatchGateway3.FormAttribute();
       fattr.access ='sadsa'; fattr.category = 'asdsad';
       
       BatchGateway3.FieldContainer fcontainer = new BatchGateway3.FieldContainer();
       fcontainer.fields = new BatchGateway3.ArrayOfFormField();
       
       BatchGateway3.FormSection fsection = new BatchGateway3.FormSection();
        fsection.columns = 2;
        fsection.enabled = true;
        fsection.order = 4;
        fsection.sectionName = 'hjhjk';
        fsection.showHeader = true;
        fsection.tabOrder = 'hj';
       
       BatchGateway3.ErrorMessages  messages = new BatchGateway3.ErrorMessages();
       messages.Error = 'sadsada';
       messages.ErrorCode = 'dsadas';
       
       BatchGateway3.Form f = new BatchGateway3.Form();
       f.applicationStyle = 'asdas';
       f.formButtonStyle  = 'asdas';
       f.formLabelStyle = 'asdas';
       f.formPanelStyle  = 'asdas';
       f.formSectionStyle = 'asdas';
       f.globalStyle  = 'asdas';
       f.underMaintenanceMessage = 'asdas';
       f.sections = new BatchGateway3.ArrayOfFormSection();
       
       BatchGateway3.ArrayOfFormSection section = new BatchGateway3.ArrayOfFormSection();
       
       BatchGateway3.MDLookupFilters mdf = new  BatchGateway3.MDLookupFilters();
       mdf.fieldType = 'asdsa'; mdf.operator = 'sdfdf';
         
       BatchGateway3.ArrayOfFormAttribute w = new BatchGateway3.ArrayOfFormAttribute();
       w.attribute = new List<BatchGateway3.FormAttribute>();
       BatchGateway3.ArrayOfObjectList t = new BatchGateway3.ArrayOfObjectList();
       t.ObjectList = new List<BatchGateway3.ObjectList>();
       BatchGateway3.ArrayOfMDLookupFilters arr = new  BatchGateway3.ArrayOfMDLookupFilters();
       arr.lookupFilter = new List<BatchGateway3.MDLookupFilters>();
       BatchGateway3.ArrayOfFieldContainer arrFC = new BatchGateway3.ArrayOfFieldContainer();
       arrFC.child = new List<BatchGateway3.FieldContainer>();
       BatchGateway3.CountryHelper ch = new BatchGateway3.CountryHelper();
       
       BatchGateway3.ArrayOfCountry aoc = new BatchGateway3.ArrayOfCountry();
       aoc.Country = new List<BatchGateway3.Country>();
       
       BatchGateway3.FormFieldAttribute ffattr = new BatchGateway3.FormFieldAttribute();
       ffattr.acceptedValues = 'asdsadas'; ffattr.label = 'sadsadas';
       
       BatchGateway3.SubmitResponse_element sre = new BatchGateway3.SubmitResponse_element();
       sre.SubmitResult = new BatchGateway3.TransactionResult();
       BatchGateway3.ArrayOfMDField amd = new BatchGateway3.ArrayOfMDField();
       amd.field = new List<BatchGateway3.MDField>();
       
       BatchGateway3.SubmitBatchResponse_element sbr = new BatchGateway3.SubmitBatchResponse_element();
       sbr.SubmitBatchResult = new BatchGateway3.ArrayOfTransactionResult();
       
       BatchGateway3.ArrayOfMDKeyValuePair mdk = new BatchGateway3.ArrayOfMDKeyValuePair();
       mdk.property = new List<BatchGateway3.MDKeyValuePair>();
       
       BatchGateway3.GetFormResponse_element fre = new BatchGateway3.GetFormResponse_element();
       fre.form = new BatchGateway3.Form();
       
       BatchGateway3.MDObject mdo = new BatchGateway3.MDObject();
       mdo.alias = 'asdsa'; mdo.apiName  = 'asdsa';
       mdo.condition = 'asdsa';mdo.operation= 'asdsa';
       mdo.order=1;
       
    }
    
    
    global class MockHttpResponseGenerator implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req){
            
            return null;
        }
    
    }
}
