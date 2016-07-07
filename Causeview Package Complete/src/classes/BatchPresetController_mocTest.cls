@isTest
public class BatchPresetController_mocTest{
    public static testMethod void BatchPresetController_mocTest(){
        
        
        String contactXml = '<Contact><fields Lable="Last Name" Name="LastName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="First Name" Name="FirstName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></Contact>';
        String accountXml = '<Account><fields Lable="Organization Name" Name="Name" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Email" Name="causeview__Email__c" Type="EMAIL" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="true"></fields><fields Lable="Industry" Name="Industry" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Mailing City" Name="BillingCity" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Number of Locations" Name="causeview__NumberofLocations__c" Type="DOUBLE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Number" Name="AccountNumber" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Phone" Name="Phone" Type="PHONE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Record Type" Name="RecordTypeId" Type="REFERENCE" Value="012A00000012MG8IAM" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Parent Organization" Name="ParentId" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></Account>';
        String giftDetailXml = '<causeview__Gift_Detail__c><fields Lable="Appeal" Name="causeview__New_Campaign__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Fund" Name="causeview__Fund__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Allocated Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift_Detail__c>';
        string recurringGiftXml = '<causeview__Recurring_Donation__c><fields Lable="Start Date" Name="causeview__Start_Date__c" Type="DATE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Frequency" Name="causeview__Frequency__c" Type="PICKLIST" Value="Monthly" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Recurring_Donation__c>';
        String giftXml = '<causeview__Gift__c><fields Lable="Receipt Type" Name="causeview__Receipt_Type__c" Type="PICKLIST" Value="Single Receipt" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Gift Type" Name="causeview__Gift_Type__c" Type="PICKLIST" Value="One Time Gift" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift__c>';
        String paymentXml = '<causeview__Payment__c PTypes="Credit Card,"><fields Lable="Payment Type" Name="causeview__Payment_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Credit Card Number" Name="causeview__Credit_Card_Number__c" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Credit Card Type" Name="causeview__Credit_Card_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></causeview__Payment__c>';
        String receiptXml = '<causeview__Receipt__c><fields Lable="Amount Not Eligible" Name="causeview__Amount_Not_Eligible__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="true"></fields></causeview__Receipt__c>';
        String eventRegistrationXml = '<causeview__Event_Registration__c></causeview__Event_Registration__c>';
        Batch_Template__c bt = new Batch_Template__c(name = 'Test123', AccountFieldsXml__c = accountXml, ContactFieldXml__c = contactXml, 
            GiftDetailFieldsXml__c = giftDetailXml, PaymentFieldsXml__c = paymentXml, ReceiptFieldsXml__c = receiptXml, RecurringGiftFieldsXml__c = recurringGiftXml,
            TransactionFieldsXml__c = giftXml, EventRegistrationsFieldsXml__c = eventRegistrationXml);
        insert bt;
        
        ApexPages.currentPage().getParameters().put('id',bt.id);
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        BatchPresetController_moc batchtemplate = new BatchPresetController_moc(sc);
        Batch_Template__c btemplate = new Batch_Template__c(name = 'test98765');
        insert btemplate;
        batchtemplate.paymentTypesToAdd = paymentType;
        batchtemplate.paymentTypesToRemove = removePaymentType;
        batchtemplate.getPaymentTypeFields();
        batchtemplate.IndexListStr0 = 'name:0,Email:1';
        batchtemplate.IndexListStr1 = 'name:0,Industry:1';
        batchtemplate.addPaymentTypes();
        batchtemplate.removePaymentTypes();
        batchtemplate.getPTypePickListOptionsToRemove();
        batchtemplate.getPTypePickListOptionsToAdd();
        batchtemplate.getPaymentTypePickListOptions();
        batchtemplate.getConPickListOptions();
        batchtemplate.getAccPickListOptions();
        batchtemplate.getRgfPickListOptions();
        batchtemplate.getTrnxPickListOptions();
        batchtemplate.getPymtPickListOptions();
        batchtemplate.getRcptPickListOptions();
        batchtemplate.getDGPickListOptions();
        batchtemplate.getEventPickListOptions();
        batchtemplate.showTemplate();
        //batchtemplate.getViewPresets();
        batchtemplate.CreateNewPresetTemplate();
        batchtemplate.newPresetTemplate();
        //batchtemplate.templateId = bt.id;
        //batchtemplate.editPresetTemplate();
        batchtemplate.clonePresetTemplate();
        batchtemplate.conSelected.add('Name');
        batchtemplate.conSelected.add('Email');
        ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
        batchtemplate.addInPreset();
        batchtemplate.accSelected.add('Name');
        batchtemplate.accSelected.add('NumberOfEmployees');
        ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
        batchtemplate.addInPreset();
        batchtemplate.rgfSelected.add('Name');
        batchtemplate.rgfSelected.add('Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Recurring_Donation__c');
        batchtemplate.IndexListStr2 = 'Name:0,causeview__Credit_Card__c:1';
        batchtemplate.addInPreset();
        batchtemplate.trnxSelected.add('Name');
        batchtemplate.trnxSelected.add('Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Gift__c');
        batchtemplate.IndexListStr3 = 'Name:0,causeview__Amount__c:1';
        batchtemplate.addInPreset();
        batchtemplate.pymtSelected.add('Name');
        batchtemplate.pymtSelected.add('Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Payment__c');
        batchtemplate.IndexListStr4 = 'Name:0,causeview__Donation__c:1';
        batchtemplate.addInPreset();
        batchtemplate.pymtSelected.add('Name');
        batchtemplate.pymtSelected.add('RecordType');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Payment__c');
        batchtemplate.IndexListStr4 = 'Name:0,causeview__Donation__c:1';
        batchtemplate.addInPreset();
        batchtemplate.rcptSelected.add('Name');
        batchtemplate.rcptSelected.add('RecordType');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Receipt__c');
        batchtemplate.IndexListStr5 = 'Name:0';
        batchtemplate.addInPreset();
        batchtemplate.giftDetailSelected.add('Name');
        batchtemplate.giftDetailSelected.add('Gift__c');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Gift_Detail__c');
        batchtemplate.IndexListStr6 = 'Name:0,causeview__Fund__c:1';
        batchtemplate.addInPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
        ApexPages.currentPage().getParameters().put('index', '1');
        batchtemplate.removalIndex1 = '1';
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
        ApexPages.currentPage().getParameters().put('index', '2');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Recurring_Donation__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Gift__c');
        ApexPages.currentPage().getParameters().put('index', '0');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Payment__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Gift_Detail__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Receipt__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        //batchtemplate.removeFromPreset();
        batchtemplate.template = btemplate;
        batchtemplate.templateId = bt.id;
        batchtemplate.saveBatchPreset();
        batchtemplate.template = btemplate;
        batchtemplate.saveBatchPreset();
        batchtemplate.cancel();
        batchtemplate.templateId = bt.id;
        batchtemplate.deletePreset();
        batchtemplate.createNewBatch();
    }
    
    public static testMethod void BatchPresetController_newTest(){
        
        
        String contactXml = '<Contact><fields Lable="Last Name" Name="LastName" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="First Name" Name="FirstName" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields></Contact>';
        String accountXml = '<Account><fields Lable="Organization Name" Name="Name" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Email" Name="causeview__Email__c" Type="EMAIL" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="true"></fields><fields Lable="Industry" Name="Industry" Type="PICKLIST" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Mailing City" Name="BillingCity" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Number of Locations" Name="causeview__NumberofLocations__c" Type="DOUBLE" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Number" Name="AccountNumber" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Phone" Name="Phone" Type="PHONE" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Record Type" Name="RecordTypeId" Type="REFERENCE" Value="012A00000012MG8IAM" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Parent Organization" Name="ParentId" Type="REFERENCE" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields></Account>';
        String giftDetailXml = '<causeview__Gift_Detail__c><fields Lable="Appeal" Name="causeview__New_Campaign__c" Type="REFERENCE" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Fund" Name="causeview__Fund__c" Type="REFERENCE" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Allocated Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift_Detail__c>';
        string recurringGiftXml = '<causeview__Recurring_Donation__c><fields Lable="Start Date" Name="causeview__Start_Date__c" Type="DATE" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Frequency" Name="causeview__Frequency__c" Type="PICKLIST" Value="Monthly" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Recurring_Donation__c>';
        String giftXml = '<causeview__Gift__c><fields Lable="Receipt Type" Name="causeview__Receipt_Type__c" Type="PICKLIST" Value="Single Receipt" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Gift Type" Name="causeview__Gift_Type__c" Type="PICKLIST" Value="One Time Gift" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift__c>';
        String paymentXml = '<causeview__Payment__c PTypes="Credit Card,"><fields Lable="Payment Type" Name="causeview__Payment_Type__c" Type="PICKLIST" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Credit Card Number" Name="causeview__Credit_Card_Number__c" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Credit Card Type" Name="causeview__Credit_Card_Type__c" Type="PICKLIST" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields></causeview__Payment__c>';
        String receiptXml = '<causeview__Receipt__c><fields Lable="Amount Not Eligible" Name="causeview__Amount_Not_Eligible__c" Type="CURRENCY" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="true"></fields></causeview__Receipt__c>';
        String eventRegistrationXml = '<causeview__Event_Registration__c></causeview__Event_Registration__c>';
        Batch_Template__c bt = new Batch_Template__c(name = 'Test123', AccountFieldsXml__c = accountXml, ContactFieldXml__c = contactXml, 
            GiftDetailFieldsXml__c = giftDetailXml, PaymentFieldsXml__c = paymentXml, ReceiptFieldsXml__c = receiptXml, RecurringGiftFieldsXml__c = recurringGiftXml,
            TransactionFieldsXml__c = giftXml, EventRegistrationsFieldsXml__c = eventRegistrationXml);
        insert bt;
        
        ApexPages.currentPage().getParameters().put('id',bt.id);
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        BatchPresetController_New batchtemplate = new BatchPresetController_New(sc);
        Batch_Template__c btemplate = new Batch_Template__c(name = 'test98765');
        insert btemplate;
       // batchtemplate.paymentTypesToAdd = paymentType;
       // batchtemplate.paymentTypesToRemove = removePaymentType;
        /* batchtemplate.getPaymentTypeFields();
        batchtemplate.IndexListStr0 = 'name:0,Email:1';
        batchtemplate.IndexListStr1 = 'name:0,Industry:1';
        batchtemplate.addPaymentTypes();
        batchtemplate.removePaymentTypes();
        batchtemplate.getPTypePickListOptionsToRemove();
        batchtemplate.getPTypePickListOptionsToAdd();
        batchtemplate.getPaymentTypePickListOptions();
        batchtemplate.getConPickListOptions();
        batchtemplate.getAccPickListOptions();
        batchtemplate.getRgfPickListOptions();
        batchtemplate.getTrnxPickListOptions();
        batchtemplate.getPymtPickListOptions();
        batchtemplate.getRcptPickListOptions();
        batchtemplate.getDGPickListOptions();
        batchtemplate.getEventPickListOptions();
        batchtemplate.showTemplate();
        //batchtemplate.getViewPresets();
        batchtemplate.CreateNewPresetTemplate();
        batchtemplate.newPresetTemplate();
        //batchtemplate.templateId = bt.id;
        //batchtemplate.editPresetTemplate();
        batchtemplate.clonePresetTemplate();
        batchtemplate.conSelected.add('Name');
        batchtemplate.conSelected.add('Email'); */
        ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
        batchtemplate.addInPreset();
        batchtemplate.accSelected.add('Name');
        batchtemplate.accSelected.add('NumberOfEmployees');
        ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
        batchtemplate.addInPreset();
        batchtemplate.rgfSelected.add('Name');
        batchtemplate.rgfSelected.add('Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Recurring_Donation__c');
       // batchtemplate.IndexListStr2 = 'Name:0,causeview__Credit_Card__c:1';
        batchtemplate.addInPreset();
        batchtemplate.trnxSelected.add('Name');
        batchtemplate.trnxSelected.add('Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Gift__c');
       // batchtemplate.IndexListStr3 = 'Name:0,causeview__Amount__c:1';
        batchtemplate.addInPreset();
        batchtemplate.pymtSelected.add('Name');
        batchtemplate.pymtSelected.add('Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Payment__c');
       // batchtemplate.IndexListStr4 = 'Name:0,causeview__Donation__c:1';
        batchtemplate.addInPreset();
        batchtemplate.pymtSelected.add('Name');
        batchtemplate.pymtSelected.add('RecordType');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Payment__c');
        //batchtemplate.IndexListStr4 = 'Name:0,causeview__Donation__c:1';
        batchtemplate.addInPreset();
        batchtemplate.rcptSelected.add('Name');
        batchtemplate.rcptSelected.add('RecordType');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Receipt__c');
       // batchtemplate.IndexListStr5 = 'Name:0';
        batchtemplate.addInPreset();
        batchtemplate.giftDetailSelected.add('Name');
        batchtemplate.giftDetailSelected.add('Gift__c');
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Gift_Detail__c');
        //batchtemplate.IndexListStr6 = 'Name:0,causeview__Fund__c:1';
        batchtemplate.addInPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
        ApexPages.currentPage().getParameters().put('index', '1');
       // batchtemplate.removalIndex1 = '1';
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
        ApexPages.currentPage().getParameters().put('index', '2');
       batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Recurring_Donation__c');
        ApexPages.currentPage().getParameters().put('index', '1');
       batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Gift__c');
        ApexPages.currentPage().getParameters().put('index', '0');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Payment__c');
        ApexPages.currentPage().getParameters().put('index', '1');
       batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Gift_Detail__c');
        ApexPages.currentPage().getParameters().put('index', '1');
       batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'causeview__Receipt__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        //batchtemplate.removeFromPreset();
        batchtemplate.template = btemplate;
        //batchtemplate.templateId = bt.id;
        batchtemplate.saveBatchPreset();
        batchtemplate.template = btemplate;
        batchtemplate.saveBatchPreset();
        batchtemplate.cancel();
       // batchtemplate.templateId = bt.id;
        //batchtemplate.deletePreset();
        batchtemplate.createNewBatch();
        batchtemplate.cloneBatchPreset();
        batchtemplate.newBatchPreset();
        batchtemplate.openBatchPresetsTab();
        //batchtemplate.getConPickListOptions();
        //batchtemplate.getAccPickListOptions();
        //batchtemplate.getRgfPickListOptions();
        //batchtemplate.getTrnxPickListOptions();
        //batchtemplate.getPymtPickListOptions();
        //batchtemplate.getRcptPickListOptions();
        //batchtemplate.getDGPickListOptions();
        //batchtemplate.getEventPickListOptions();
        batchtemplate.getPresetTemplateOptions();
        batchtemplate.editBatchPreset();
    }
    public static testMethod void BatchPresetController_mocTest1(){
        String contactXml = '<Contact><fields Lable="Last Name" Name="LastName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="First Name" Name="FirstName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></Contact>';
        String accountXml = '<Account><fields Lable="Organization Name" Name="Name" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Email" Name="causeview__Email__c" Type="EMAIL" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="true"></fields><fields Lable="Industry" Name="Industry" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Mailing City" Name="BillingCity" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Number of Locations" Name="causeview__NumberofLocations__c" Type="DOUBLE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Number" Name="AccountNumber" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Phone" Name="Phone" Type="PHONE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Record Type" Name="RecordTypeId" Type="REFERENCE" Value="012A00000012MG8IAM" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Parent Organization" Name="ParentId" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></Account>';
        String giftDetailXml = '<causeview__Gift_Detail__c><fields Lable="Appeal" Name="causeview__New_Campaign__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Fund" Name="causeview__Fund__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Allocated Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift_Detail__c>';
        string recurringGiftXml = '<causeview__Recurring_Donation__c><fields Lable="Start Date" Name="causeview__Start_Date__c" Type="DATE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Frequency" Name="causeview__Frequency__c" Type="PICKLIST" Value="Monthly" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Recurring_Donation__c>';
        String giftXml = '<causeview__Gift__c><fields Lable="Receipt Type" Name="causeview__Receipt_Type__c" Type="PICKLIST" Value="Single Receipt" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Gift Type" Name="causeview__Gift_Type__c" Type="PICKLIST" Value="One Time Gift" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift__c>';
        String paymentXml = '<causeview__Payment__c PTypes="Credit Card,"><fields Lable="Payment Type" Name="causeview__Payment_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Credit Card Number" Name="causeview__Credit_Card_Number__c" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Credit Card Type" Name="causeview__Credit_Card_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></causeview__Payment__c>';
        String receiptXml = '<causeview__Receipt__c></causeview__Receipt__c>';
        String eventRegistrationXml = '<causeview__Event_Registration__c></causeview__Event_Registration__c>';
        Batch_Template__c bt = new Batch_Template__c(name = 'Test123', AccountFieldsXml__c = accountXml, ContactFieldXml__c = contactXml, 
            GiftDetailFieldsXml__c = giftDetailXml, PaymentFieldsXml__c = paymentXml, ReceiptFieldsXml__c = receiptXml, RecurringGiftFieldsXml__c = recurringGiftXml,
            TransactionFieldsXml__c = giftXml, EventRegistrationsFieldsXml__c = eventRegistrationXml);
        insert bt;
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('id', bt.id);
        BatchPresetController_moc batchtemplate = new BatchPresetController_moc(sc);
        batchtemplate.editAPresetTemplate();
        batchtemplate.templateId = bt.id;
        batchtemplate.saveBatchPreset();
    }
    public static testMethod void BatchPresetController_mocTest2(){
        String contactXml = '<Contact><fields Lable="Last Name" Name="LastName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="First Name" Name="FirstName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></Contact>';
        String accountXml = '<Account><fields Lable="Organization Name" Name="Name" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Email" Name="causeview__Email__c" Type="EMAIL" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="true"></fields><fields Lable="Industry" Name="Industry" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Mailing City" Name="BillingCity" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Number of Locations" Name="causeview__NumberofLocations__c" Type="DOUBLE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Number" Name="AccountNumber" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Phone" Name="Phone" Type="PHONE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Record Type" Name="RecordTypeId" Type="REFERENCE" Value="012A00000012MG8IAM" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Parent Organization" Name="ParentId" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></Account>';
        String giftDetailXml = '<causeview__Gift_Detail__c><fields Lable="Appeal" Name="causeview__New_Campaign__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Fund" Name="causeview__Fund__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Allocated Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift_Detail__c>';
        string recurringGiftXml = '<causeview__Recurring_Donation__c><fields Lable="Start Date" Name="causeview__Start_Date__c" Type="DATE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Frequency" Name="causeview__Frequency__c" Type="PICKLIST" Value="Monthly" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Recurring_Donation__c>';
        String giftXml = '<causeview__Gift__c><fields Lable="Receipt Type" Name="causeview__Receipt_Type__c" Type="PICKLIST" Value="Single Receipt" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Gift Type" Name="causeview__Gift_Type__c" Type="PICKLIST" Value="One Time Gift" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift__c>';
        String paymentXml = '<causeview__Payment__c PTypes="Credit Card,"><fields Lable="Payment Type" Name="causeview__Payment_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Credit Card Number" Name="causeview__Credit_Card_Number__c" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Credit Card Type" Name="causeview__Credit_Card_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></causeview__Payment__c>';
        String receiptXml = '<causeview__Receipt__c></causeview__Receipt__c>';
        String eventRegistrationXml = '<causeview__Event_Registration__c></causeview__Event_Registration__c>';
        Batch_Template__c bt = new Batch_Template__c(name = 'Test123', AccountFieldsXml__c = accountXml, ContactFieldXml__c = contactXml, 
            GiftDetailFieldsXml__c = giftDetailXml, PaymentFieldsXml__c = paymentXml, ReceiptFieldsXml__c = receiptXml, RecurringGiftFieldsXml__c = recurringGiftXml,
            TransactionFieldsXml__c = giftXml, EventRegistrationsFieldsXml__c = eventRegistrationXml);
        insert bt;
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('id', bt.id);
        BatchPresetController_moc batchtemplate = new BatchPresetController_moc(sc);
        batchtemplate.editAPresetTemplate();
        batchtemplate.saveBatchPreset();
        
        batchtemplate.IndexListStr0 = 'name:0,Email:1';
        batchtemplate.IndexListStr1 = 'name:0,AccountNumber:1';
        batchtemplate.IndexListStr2 = 'Name:0,causeview__Credit_Card__c:1';
        batchtemplate.IndexListStr3 = 'Name:0,causeview__Amount__c:1';
        batchtemplate.IndexListStr4 = 'Name:0,causeview__Donation__c:1';
        batchtemplate.IndexListStr5 = 'Name:0';
        batchtemplate.IndexListStr6 = 'Name:0,causeview__Fund__c:1';
        batchtemplate.SaveOrderListForAll();
        
    }
    public static testMethod void BatchPresetControllerTest2(){
        String contactXml = '<Contact><fields Lable="Last Name" Name="LastName" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="First Name" Name="FirstName" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields></Contact>';
        String accountXml = '<Account><fields Lable="Organization Name" Name="Name" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Email" Name="causeview__Email__c" Type="EMAIL" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="true"></fields><fields Lable="Industry" Name="Industry" Type="PICKLIST" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Mailing City" Name="BillingCity" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Number of Locations" Name="causeview__NumberofLocations__c" Type="DOUBLE" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Number" Name="AccountNumber" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Phone" Name="Phone" Type="PHONE" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Record Type" Name="RecordTypeId" Type="REFERENCE" Value="012A00000012MG8IAM" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Parent Organization" Name="ParentId" Type="REFERENCE" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields></Account>';
        String giftDetailXml = '<causeview__Gift_Detail__c><fields Lable="Appeal" Name="causeview__New_Campaign__c" Type="REFERENCE" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Fund" Name="causeview__Fund__c" Type="REFERENCE" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Allocated Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift_Detail__c>';
        string recurringGiftXml = '<causeview__Recurring_Donation__c><fields Lable="Start Date" Name="causeview__Start_Date__c" Type="DATE" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Frequency" Name="causeview__Frequency__c" Type="PICKLIST" Value="Monthly" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Recurring_Donation__c>';
        String giftXml = '<causeview__Gift__c><fields Lable="Receipt Type" Name="causeview__Receipt_Type__c" Type="PICKLIST" Value="Single Receipt" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Gift Type" Name="causeview__Gift_Type__c" Type="PICKLIST" Value="One Time Gift" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields></causeview__Gift__c>';
        String paymentXml = '<causeview__Payment__c PTypes="Credit Card,"><fields Lable="Payment Type" Name="causeview__Payment_Type__c" Type="PICKLIST" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Amount" Name="causeview__Amount__c" Type="CURRENCY" Value="null" Hidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Credit Card Number" Name="causeview__Credit_Card_Number__c" Type="STRING" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Credit Card Type" Name="causeview__Credit_Card_Type__c" Type="PICKLIST" Value="null" Hidden="false" ReadOnly="false" Req="false" Summ="false"></fields></causeview__Payment__c>';
        String receiptXml = '<causeview__Receipt__c></causeview__Receipt__c>';
        String eventRegistrationXml = '<causeview__Event_Registration__c></causeview__Event_Registration__c>';
        Batch_Template__c bt = new Batch_Template__c(name = 'Test123', AccountFieldsXml__c = accountXml, ContactFieldXml__c = contactXml, 
            GiftDetailFieldsXml__c = giftDetailXml, PaymentFieldsXml__c = paymentXml, ReceiptFieldsXml__c = receiptXml, RecurringGiftFieldsXml__c = recurringGiftXml,
            TransactionFieldsXml__c = giftXml, EventRegistrationsFieldsXml__c = eventRegistrationXml);
        insert bt;
       
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController batchtemplate = new BatchPresetController();
        batchtemplate.newBatchPreset(); 
        batchtemplate.editBatchPreset();
        batchtemplate.getViewPresets();
        batchtemplate.presetTemplateData();   
        batchtemplate.newBatchPresetData();
        batchtemplate.saveBatchPreset();            
       /* batchtemplate.IndexListStr0 = 'name:0,Email:1';
        batchtemplate.IndexListStr1 = 'name:0,AccountNumber:1';
        batchtemplate.IndexListStr2 = 'Name:0,causeview__Credit_Card__c:1';
        batchtemplate.IndexListStr3 = 'Name:0,causeview__Amount__c:1';
        batchtemplate.IndexListStr4 = 'Name:0,causeview__Donation__c:1';
        batchtemplate.IndexListStr5 = 'Name:0';
        batchtemplate.IndexListStr6 = 'Name:0,causeview__Fund__c:1';
        batchtemplate.SaveOrderListForAll(); */
        
    }
}
