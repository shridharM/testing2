public class FulFillInstallmentPageController1{
    //This method is called when payment type is "Credit card" to send a payment information
    //to server and make payment approved or declined on basis of response.
    public PageReference submitPayment() {
        BatchGateway3.TransactionResult result;
        try
        {
           result = submit(Payment, Payment.Donation__c);
           system.debug('Niitin result===='+result.TransactionStatus);
        }
        catch(Exception ex)
        {
           shouldSubmit = false;
           Payment.Status__c = 'Declined';
           Payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));           
           update Payment;
        }
        
        shouldSubmit = false;
        
        if (result.TransactionStatus == 'success') {
            Payment.Authorization__c = result.ApprovalCode;
            Payment.CC_Reference__c = result.TransactionId;
            Payment.Status__c = result.TransactionStatus == null || result.TransactionStatus != 'success' ? 'Declined' : 'Approved';
            if ((result.TransactionId == null || result.TransactionId == '') && result.TransactionStatus == 'success') Payment.Amount__c = 0;
            
            Payment.CC_Transaction_Date__c = Date.today();
           Payment.Status__c = 'Approved';
           createInstallmentFullfillment();
           return cancelAll();
        }
        else
        {
            Payment.Authorization__c = result.ApprovalCode;
            Payment.CC_Reference__c = result.TransactionId;
            Payment.Status__c = 'Declined';
            update Payment;
            return cancelAll();
        }
    }
    
    //this method is used to send "credit card" related information to server if payment type is "Credit card" 
    public BatchGateway3.TransactionResult submit(Payment__c p, string gId) {
        BatchSettings__c BatchSettings = null;
        List<BatchSettings__c> settingList = [Select b.GatewayUrl__c, b.CurrencyCode__c, b.BatchFormId__c, b.RegularGiftRecordTypeId__c,
           b.Name, b.BucketAccountId__c, BatchReportId__c 
           From BatchSettings__c b WHERE Name = 'Default'];
        if (settingList != null && settingList.size()>0)
           BatchSettings = settingList[0];
        BatchGateway3.GatewaySoap gw = new BatchGateway3.GatewaySoap();
        gw.timeout_x = 120000;
        gw.endpoint_x = BatchSettings.GatewayUrl__c;
        BatchGateway3.BatchForm form = new BatchGateway3.BatchForm();
        BatchGateway3.FormBase formBase = new BatchGateway3.FormBase();
        form.payments = new BatchGateway3.ArrayOfPaymentInfo();
        form.payments.payment = new List<BatchGateway3.PaymentInfo>();
        formBase.currency_x = BatchSettings.CurrencyCode__c;
        formBase.formId = batchSettings.BatchFormID__c;
        formBase.version = '1.0';
        formBase.debugMode = true;
        
        BatchGateway3.PaymentInfo payment = new BatchGateway3.PaymentInfo();
        if (!lookupSelectedId.startsWith('001')) {
            Contact theIndividual = [select MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Email, FirstName, LastName from Contact where Id =: lookupSelectedId];
            payment.address1 = theIndividual.MailingStreet;
            payment.city = theIndividual.MailingCity;
            payment.state = theIndividual.MailingState;
            payment.country = theIndividual.MailingCountry;
            payment.zipCode = theIndividual.MailingPostalCode;
            payment.donationType = 'IND';
            payment.email = theIndividual.Email;        
            payment.PayerFirstName = theIndividual.FirstName;
            payment.PayerLastName = theIndividual.LastName; 
            payment.isIndividual = true;                       
        }
        else {
            Account theOrg = [select BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Email__c from Account where Id =: lookupSelectedId];
            payment.address1 = theOrg.BillingStreet;
            payment.city = theOrg.BillingCity;
            payment.state = theOrg.BillingState;
            payment.country = theOrg.BillingCountry;
            payment.zipCode = theOrg.BillingPostalCode;
            payment.donationType = 'ORG';
            payment.email = theOrg.Email__c;  
            payment.isIndividual = false;   
            payment.PayerFirstName = '';
            payment.PayerLastName = ''; 
                                   
        }
        //one time payment
        payment.billingStartDate = date.today();
        payment.numberOfPayments = '';
        payment.isIndividual = true;
        payment.isRecurring = false;
        payment.constituentType ='Existing';
        payment.amount = p.Amount__c.format();
        payment.creditCardNumber = creditcardNumber;    //p.Credit_Card_Number__c
        payment.creditCardType = p.Credit_Card_Type__c;
        payment.cvv2 = ccCVV;
        payment.currencyType = BatchSettings.CurrencyCode__c;
        payment.expiryMonth = tryParseToInt(ccExpM);
        payment.expiryYear = tryParseToInt(ccExpY);
        payment.giftId = gid;
        payment.paymentId = p.Id;
        form.payments.payment.add(payment);
        System.debug(payment);
        system.debug('Nitin formBase====='+formBase);
        system.debug('Nitin form====='+form);
        BatchGateway3.ArrayOfTransactionResult txResults = new BatchGateway3.ArrayOfTransactionResult();
        txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0');
        system.debug('Nitin txResults====='+txResults);
        if (txResults!=null && txResults.TransactionResult!=null && txResults.TransactionResult.size()>0) {
          return txResults.TransactionResult[0];
        }
        else
          return null;    
    }

    public integer tryParseToInt(String txt)
    {
        integer result = 0;
        try {
            result = integer.valueOf(txt);
        }
        catch(Exception ex) {
            //do nothing
        }
        
        return result;
    }
    

    public cv_pkg_dev_I__Payment__c Payment {get; set;}
    public String PaymentId {get; set;}
    public String Url {get;set;}
    public String TransactionId {get; set;}
    public List<cv_pkg_dev_I__Installment__c> InstallmentList {get; set;}
    public string ccExpM { get; set; }
    public string ccExpY { get; set; }    
    public string ccCVV { get; set; }
    public string accContId {get; set;}
    public string accContName {get; set;}
    public set<Id> giftIds;
    public List<Schema.FieldSetMember> InstallmentFieldList {get; set;}
    public List<InstallmetnWrapperClass> installmentWrapper {get; set;}
    set<Id> transactonIds;
    public boolean shouldSubmit { get; set; }
    string creditcardNumber;
    String lookupSelectedId;
    String lookupSelectedId_dup;
    set<Id> contAccIds;
    string intial_Acc_Cont_Id;
    Decimal soft_Credit_Amount;
    public Id softcreditid;
    public List<cv_pkg_dev_I__Payment__c> paymentlist{get;set;}
    public List<cv_pkg_dev_I__Gift_Detail__c> allocationlist{get;set;}
    Database.SaveResult[] srList;
    
    //creating a list of options for months to add in picklist in "FulFillInstallmentPage" visualforce page
    public List<SelectOption> getMonths() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', 'Jan'));        
        options.add(new SelectOption('2', 'Feb'));  
        options.add(new SelectOption('3', 'Mar'));  
        options.add(new SelectOption('4', 'Apr'));  
        options.add(new SelectOption('5', 'May'));  
        options.add(new SelectOption('6', 'Jun'));  
        options.add(new SelectOption('7', 'Jul'));  
        options.add(new SelectOption('8', 'Aug'));  
        options.add(new SelectOption('9', 'Sept'));  
        options.add(new SelectOption('10', 'Oct'));  
        options.add(new SelectOption('11', 'Nov'));                                                                                  
        options.add(new SelectOption('12', 'Dec'));                                                                                                                                                                                                                                                                                               
        return options;
    }
    ///creating a list of options for next 8 years to add in picklist in "FulFillInstallmentPage" visualforce page
    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        for (Integer i = 0; i <= 8; i++)
        {
            options.add(new SelectOption(String.valueOf(Date.Today().Year()+i), String.valueOf(Date.Today().Year()+i)));     
        }                                                                                                                                                                                                                                                                                            
        return options;
    }
    //getting all the required fields in payment object
    public String PaymentRequiredFields {
        get{
            return ', cv_pkg_dev_I__Date__c, cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Payment_Type__c, cv_pkg_dev_I__Donation__c';
        }
    }
    
    public FulFillInstallmentPageController1(ApexPages.StandardController SC){
        //Payment = (cv_pkg_dev_I__Payment__c)SC.getRecord();
        Payment = new cv_pkg_dev_I__Payment__c();
        giftIds = new set<Id>();
        transactonIds = new Set<Id>();
        //contAccIds = new Set<Id>();
        installmentWrapper = new List<InstallmetnWrapperClass>();
        shouldSubmit = false;
        setInstallmentFieldList();    //get all the fields from "Installment Fulfillment List" field set
        setPayment();                //set payment initially when a user open "FulFillInstallmentPage" visualforce page
        getAllTranscations();    //this method fetch all the transactions related to Account/Contact.
        setInstallmentList();    //this method fetch all the installments for Account/Contact whose Installment Balance is greater tha zero.
        //lookupSelectedId = accContId;
        //intial_Acc_Cont_Id = accContId;
        String teststring;
    }
    
    
    //this method is call when a new value is choosen in Account/Contact field in "FulFillInstallmentPage" visualforce page
   /* public void callInstallmentMethods(){
     
        giftIds = new set<Id>();
        getIdObject();            //user select any Account/Contact on "FulFillInstallmentPage" visualforce page than to find which object it is i.e. Account or Contact
        setInstallmentList();
        
    } */
    
    //this method add all the gift record id's to giftIds set for Account or Contact
   /* public void getIdObject(){
        if(accContId.startsWith('001')){
            for(Gift__c g : [select Id from Gift__c where cv_pkg_dev_I__Organization__c =: accContId]){
                giftIds.add(g.id);
            }
        }else
        {
            for(Gift__c g : [select Id from Gift__c where cv_pkg_dev_I__Constituent__c =: accContId]){
                giftIds.add(g.id);
            }
        }
    } */
    
    
    //this method add all fields from "Installment Fulfillment List" field set to InstallmentFieldList list
    public void setInstallmentFieldList() {
        InstallmentFieldList = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> afl = SObjectType.cv_pkg_dev_I__Installment__c.FieldSets.cv_pkg_dev_I__Installment_Fulfillment_List.getFields();
        for(Schema.FieldSetMember f : afl) {            
            InstallmentFieldList.add(f);
            system.debug('Nitin PaymentId123 ====' +InstallmentFieldList.size());
        }  
    }
    //this method initially set the payment on "FulFillInstallmentPage" visualforce page
    public void setPayment() {    
        if(PaymentId == null){
            Url = ApexPages.currentPage().getParameters().get('Url');
            //PaymentId = ApexPages.currentPage().getParameters().get('Id');
        }
        system.debug('Nitin PaymentId====' +PaymentId);
        TransactionId = ApexPages.currentPage().getParameters().get('TransactionId');
        Payment = new cv_pkg_dev_I__Payment__c();
        Payment.cv_pkg_dev_I__Donation__c = TransactionId;
        Payment.cv_pkg_dev_I__Payment_Type__c = '';
        Payment.cv_pkg_dev_I__Date_Deposited__c = Date.Today(); 
    }  
    //this method fetch Account/Contact for initially selected gift and all the gift records for Account/Contact
    public void getAllTranscations(){
        Gift__c gift = [Select cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Constituent__r.Name, cv_pkg_dev_I__Organization__c, cv_pkg_dev_I__Organization__r.Name from Gift__c where Id =: TransactionId];
        if(gift.cv_pkg_dev_I__Organization__c != null){
            accContId = gift.cv_pkg_dev_I__Organization__c;
            accContName = gift.cv_pkg_dev_I__Organization__r.Name;
            for(Gift__c g : [select Id from Gift__c where cv_pkg_dev_I__Organization__c =: gift.cv_pkg_dev_I__Organization__c]){
                giftIds.add(g.id);
            }
        }else
        {
            accContId = gift.cv_pkg_dev_I__Constituent__c;
            accContName = gift.cv_pkg_dev_I__Constituent__r.Name;
            system.debug('Nitin accContId====='+gift.cv_pkg_dev_I__Constituent__c);
            for(Gift__c g : [select Id from Gift__c where cv_pkg_dev_I__Constituent__c =: accContId]){
                giftIds.add(g.id);
            }
        }
    }
    //this method fetch all the installments whose Installment Balance is greater tha zero
    public void setInstallmentList() {
        system.debug('Nitin installmentWrapper===='+installmentWrapper);
       
        integer i = 0;
        while(i < installmentWrapper.size()){
            if(installmentWrapper[i].fullfilmentAmount == null || installmentWrapper[i].fullfilmentAmount == 0 )
            {              
                installmentWrapper.remove(i);
            }else
            {
                i++;
            }
        }
        if(giftIds.size() > 0){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : InstallmentFieldList) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id, cv_pkg_dev_I__Pledge__r.cv_pkg_dev_I__Organization__c, cv_pkg_dev_I__Pledge__r.cv_pkg_dev_I__Constituent__c, (select cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__Campaign__c, cv_pkg_dev_I__New_Campaign__c, cv_pkg_dev_I__Gift__c, cv_pkg_dev_I__Fund__c, cv_pkg_dev_I__GL_Auto_Credit_Account__c, cv_pkg_dev_I__GL_Auto_Debit_Account__c from Allocations__r) FROM cv_pkg_dev_I__Installment__c where cv_pkg_dev_I__Pledge__c IN: giftIds AND cv_pkg_dev_I__Installment_Balance__c > 0';
            for(cv_pkg_dev_I__Installment__c a : Database.query(query)){
                installmentWrapper.add(new InstallmetnWrapperClass(a));
            }
        } 
    }
    
    
    /*public PageReference newInstallment(){ 
        installmentWrapper.add(new InstallmetnWrapperClass(new cv_pkg_dev_I__Installment__c(cv_pkg_dev_I__Installment_Date__c = Date.Today())));
        return null;
    }  */
    //when a user click on submit in "FulFillInstallmentPage" visualforce page than this method will be called
    //this method creates the payment record and call "createInstallmentFullfillment" method for installment fullfillment records and other record.
    public PageReference saveAll(){
    system.debug('am here inside save all');
    system.debug('acount value '+accContId );
    
    
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Credit Card' OR Name = 'Standard') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
       Decimal fullfillmentAmount = 0;
        
        
        for(InstallmetnWrapperClass i : installmentWrapper){
            if(i.installment.cv_pkg_dev_I__Installment_Balance__c < i.fullfilmentAmount){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Fullfillment Balance should be less or equal to Installment Balance.'));
                return null;
            }
            if(i.fullfilmentAmount != null && i.fullfilmentAmount != 0){
                fullfillmentAmount += i.fullfilmentAmount;
                
            }
            
        }
        
        if(Payment.Amount__c != fullfillmentAmount){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Amount is not equal to Total installment Fullfillment Amount.'));
            return null;
        }
        if(Payment.cv_pkg_dev_I__Payment_Type__c == 'Credit Card'){
            shouldSubmit = true;
            Payment.RecordTypeId = rtypes_Map.get('Credit Card');
            creditcardNumber = Payment.Credit_Card_Number__c;
            Payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);
            insert Payment;
        }
        else
        {
            Payment.cv_pkg_dev_I__Status__c = 'Approved';
            Payment.RecordTypeId = rtypes_Map.get('Standard');
            // insert Payment;
            createInstallmentFullfillment();
            system.debug('Nitin PaymentId======'+PaymentId);
            return cancelAll();
        }
        return null;
    }
    
    
    
    
    
    //this method creates installment fullfillment record and gift record if installments belong to more than one gift in "FulFillInstallmentPage" visualforce page
    public void createInstallmentFullfillment(){
      system.debug('-----------------------account id'+ accContId);
      system.debug('----------------------lookupselected id'+ lookupSelectedId );
        List<cv_pkg_dev_I__Installment_Fulfillment__c> installmentFullFillmentList = new List<cv_pkg_dev_I__Installment_Fulfillment__c>();
        List<cv_pkg_dev_I__Gift_Detail__c> theGDs = new List<cv_pkg_dev_I__Gift_Detail__c>();
        List<cv_pkg_dev_I__Installment__c> installmentsToUpdate = new List<cv_pkg_dev_I__Installment__c>();
        List<cv_pkg_dev_I__Payment__c> paymentlist=new List<cv_pkg_dev_I__Payment__c>();
        
        
        //creating payment 
           for(InstallmetnWrapperClass i : installmentWrapper){
                if(i.fullfilmentAmount != null && i.fullfilmentAmount != 0){
                    cv_pkg_dev_I__Payment__c payment1= new cv_pkg_dev_I__Payment__c();
                       payment1.cv_pkg_dev_I__Donation__c=TransactionId;
                       payment1.cv_pkg_dev_I__Payment_Type__c='Cash';
                       payment1.cv_pkg_dev_I__Date__c=Payment.cv_pkg_dev_I__Date__c;
                       payment1.Status__c = 'Approved';
                       payment1.cv_pkg_dev_I__Amount__c=i.fullfilmentAmount;
                       paymentlist.add(payment1);
                     system.debug('before creating gl allocation'); 

                   }
                   
                   }
     
                    if(paymentlist.size() > 0)
                    system.debug('hi  --- before insert');
                    Database.SaveResult[] srList = Database.insert(paymentlist, false);
                    //insert paymentlist;
                    
                    /* for(Database.SaveResult p: srList)
                    {
                    cv_pkg_dev_I__Gift_Detail__c pallocation= new cv_pkg_dev_I__Gift_Detail__c();
                    pallocation.cv_pkg_dev_I__Gift__c=TransactionId; 
                    pallocation.cv_pkg_dev_I__Allocation_Date__c= Payment.cv_pkg_dev_I__Date__c;
                    pallocation.cv_pkg_dev_I__Amount__c=p.cv_pkg_dev_I__Amount__c;
                    pallocation.cv_pkg_dev_I__New_Campaign__c='701A0000000Wpdr';
                    pallocation.cv_pkg_dev_I__Fund__c='a08A000000I0bnp';
                    pallocation.cv_pkg_dev_I__Payment__c=p.getId();
                    theGDs.add(pallocation);
                    
                    cv_pkg_dev_I__Gift_Detail__c nallocation= new cv_pkg_dev_I__Gift_Detail__c();
                    nallocation.cv_pkg_dev_I__Allocation_Date__c= Payment.cv_pkg_dev_I__Date__c;
                    nallocation.cv_pkg_dev_I__Gift__c=TransactionId; 
                    nallocation.cv_pkg_dev_I__Amount__c=0-p.cv_pkg_dev_I__Amount__c;
                    nallocation.cv_pkg_dev_I__New_Campaign__c='701A0000000Wpdr';
                    nallocation.cv_pkg_dev_I__Fund__c='a08A000000I0bnp';
                    nallocation.cv_pkg_dev_I__Payment__c=p.getId();
                    theGDs.add(nallocation);
                    }
                    
                     insert theGDs;*/
                     
                     
                     delete Payment;
   
    }
    
    //to redirect to newly created payment or transaction if payment is not created
    public PageReference cancelAll(){
        PaymentId = Payment.Id;
        PageReference p;
        if(PaymentId == null || PaymentId.equals('')){  
            p = new PageReference(Url);      
        }else{
            p = new PageReference('/' + PaymentId);
        }
        return p;
    }
    //wrapper class to keep installment record and fullfillment amount for installments.
    public class InstallmetnWrapperClass{
        public cv_pkg_dev_I__Installment__c installment {get; set;}
        public Decimal fullfilmentAmount {get; set;}
        public InstallmetnWrapperClass(cv_pkg_dev_I__Installment__c inst){
            installment = inst;
        }
    }

}