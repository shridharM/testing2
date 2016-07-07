@isTest
public class BatchProcessingControllerTest{
    public static testMethod void BatchProcessingControllerTest(){
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = a.Id,    cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        String contactXml = '<Contact><fields Lable="Last Name" Name="LastName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="First Name" Name="FirstName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></Contact>';
        String accountXml = '<Account><fields Lable="Organization Name" Name="Name" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Email" Name="cv_pkg_dev_I__Email__c" Type="EMAIL" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="true"></fields><fields Lable="Industry" Name="Industry" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Mailing City" Name="BillingCity" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Number of Locations" Name="cv_pkg_dev_I__NumberofLocations__c" Type="DOUBLE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Number" Name="AccountNumber" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Phone" Name="Phone" Type="PHONE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Record Type" Name="RecordTypeId" Type="REFERENCE" Value="012A00000012MG8IAM" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Parent Organization" Name="ParentId" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></Account>';
        String giftDetailXml = '<cv_pkg_dev_I__Gift_Detail__c><fields Lable="Appeal" Name="cv_pkg_dev_I__New_Campaign__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Fund" Name="cv_pkg_dev_I__Fund__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Allocated Amount" Name="cv_pkg_dev_I__Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></cv_pkg_dev_I__Gift_Detail__c>';
        string recurringGiftXml = '<cv_pkg_dev_I__Recurring_Donation__c><fields Lable="Start Date" Name="cv_pkg_dev_I__Start_Date__c" Type="DATE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Frequency" Name="cv_pkg_dev_I__Frequency__c" Type="PICKLIST" Value="Monthly" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></cv_pkg_dev_I__Recurring_Donation__c>';
        String giftXml = '<cv_pkg_dev_I__Gift__c><fields Lable="Receipt Type" Name="cv_pkg_dev_I__Receipt_Type__c" Type="PICKLIST" Value="Single Receipt" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Gift Type" Name="cv_pkg_dev_I__Gift_Type__c" Type="PICKLIST" Value="One Time Gift" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></cv_pkg_dev_I__Gift__c>';
        String paymentXml = '<cv_pkg_dev_I__Payment__c PTypes="Credit Card,"><fields Lable="Payment Type" Name="cv_pkg_dev_I__Payment_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Amount" Name="cv_pkg_dev_I__Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Credit Card Number" Name="cv_pkg_dev_I__Credit_Card_Number__c" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Credit Card Type" Name="cv_pkg_dev_I__Credit_Card_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></cv_pkg_dev_I__Payment__c>';
        String receiptXml = '<cv_pkg_dev_I__Receipt__c></cv_pkg_dev_I__Receipt__c>';
        String eventRegistrationXml = '<cv_pkg_dev_I__Event_Registration__c></cv_pkg_dev_I__Event_Registration__c>';
        Batch_Template__c bt = new Batch_Template__c(name = 'Test123', AccountFieldsXml__c = accountXml, ContactFieldXml__c = contactXml, 
            GiftDetailFieldsXml__c = giftDetailXml, PaymentFieldsXml__c = paymentXml, ReceiptFieldsXml__c = receiptXml, RecurringGiftFieldsXml__c = recurringGiftXml,
            TransactionFieldsXml__c = giftXml, EventRegistrationsFieldsXml__c = eventRegistrationXml);
        insert bt;
        Gift_Batch__c gB = new Gift_Batch__c(Name__c = 'GiftBatch1234', Template_Name__c = bt.id, Open_Date__c = system.Today());
        insert gB;
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test fund123');
        insert fund;
        Letter__c letter = new Letter__c(Name__c = 'Letter test123');
        insert letter;
        RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
        Campaign appeal = new Campaign(Name = 'Campaign Test123', Fund__c = fund.id, Letter__c = letter.id, RecordTypeId=recType.id );
        insert appeal;
        Account acc = new Account(Name = 'Account Test123', NumberOfEmployees = 2);
        insert acc;
        List<Account> accList = new List<Account>();
        accList.add(acc);
        Contact con = new COntact(LastName = 'Test Contact123');
        insert con;
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        Recurring_Donation__c rd = new Recurring_Donation__c(Constituent__c = con.id, Start_Date__c = system.Today());
        insert rd;
        List<Recurring_Donation__c> rdList = new List<Recurring_Donation__c>();
        rdList.add(rd);
        Gift__c gift = new Gift__c(Constituent__c = con.id, cv_pkg_dev_I__GiftBatch__c = gB.id, Batch_Status__c ='Pending');
        insert gift;
        Payment__c pay = new Payment__c(Date__c = system.Today(), Amount__c = 10.00, Payment_Type__c = 'Cash', Status__c = 'Approved', Donation__c = gift.id);
        insert pay;
        Gift__c gift1 = new Gift__c(Constituent__c = con.id, cv_pkg_dev_I__GiftBatch__c = gB.id, Batch_Status__c ='Pending');
        insert gift1;
        Payment__c pay1 = new Payment__c(Date__c = system.Today(), Amount__c = 10.00, Payment_Type__c = 'Credit Card', Donation__c = gift1.id, cv_pkg_dev_I__Credit_Card_Number__c = '4222222222222220', cv_pkg_dev_I__Credit_Card_Type__c = 'visa');
        insert pay1;
        List<Gift__c> giftList = new List<Gift__c>();
        giftList.add(gift);
        Gift_Detail__c giftDetail = new Gift_Detail__c(New_Campaign__c = appeal.id, Amount__c = 10.00, Gift__c = gift.id, Payment__c = pay.id, Fund__c = fund.id);
        insert giftDetail;
        List<Gift_Detail__c> giftDetailList = new List<Gift_Detail__c>();
        giftDetailList.add(giftDetail);
        Receipt__c receipt = new Receipt__c(Gift__c = gift.id, Amount_Not_Eligible__c = 10.00);
        insert receipt;
        List<Receipt__c> receiptList = new List<Receipt__c>();
        receiptList.add(receipt);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(gB);
        ApexPages.currentPage().getParameters().put('batchId', gB.id);
        BatchProcessingController bpcontroller = new BatchProcessingController(sc);
        BatchProcessingController.getLookupPrefix('Contact', 'ConstOrgId');
//        BatchProcessingController.AllBatchItemsWrapper allBIWrapper = new BatchProcessingController.AllBatchItemsWrapper();
        bpcontroller.getAccountFieldArray();
        bpcontroller.getContactFieldArray();
        bpcontroller.getRecurringGiftFieldArray();
        bpcontroller.getTransactionFieldArray();
        bpcontroller.getPaymentFieldArray();
        bpcontroller.getGiftDetailFieldArray();
        bpcontroller.getReceiptFieldArray();
        bpcontroller.getSoftCreditFieldArray();
        bpcontroller.getAllBatchItems();
        BatchProcessingController.getData(rtypes.id, 'Name', 'Gift__c', 'RecordTypeId');
        bpcontroller.postSave();
        bpcontroller.enableSubmit();
        string numberToText = '12345';
        BatchProcessingController.tryParseToInt(numberToText);
        string s = gift1.id;
        String giftPaymentUIFieldsMap = '{"'+s+'":{"CCNumber":"4222222222222220","Pay_Expiry_Date__x":"0120","Pay_Security_Code__x":"123","Pay_Branch_City__x":"","Pay_Bank_Country__x":""}}';
        system.debug('Nitin==='+giftPaymentUIFieldsMap);
        //BatchProcessingController.submitPayment1(gB.id, giftPaymentUIFieldsMap);
        
    }
}
