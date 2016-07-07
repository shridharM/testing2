public class FulFillInstallmentPageController{
    //This method is called when payment type is "Credit card" to send a payment information
    //to server and make payment approved or declined on basis of response.
    public PageReference submitPayment() {
        BatchGateway3.TransactionResult result;
        system.debug('Niitin result====1');
        for(cv_pkg_dev_I__Payment__c p: paymentsToBeInserted){
            try
            {
                system.debug('Niitin result====1'+p);
                result = submit(p, p.Donation__c);
                system.debug('Niitin result====1'+result.ApprovalCode);
            }
            catch(Exception ex)
            {
                shouldSubmit = false;
                p.Status__c = 'Declined';                
                p.Credit_Card_Number__c = RollupHelper.maskCardNumber(p.Credit_Card_Number__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                createInstallmentFullfillment();
                return cancelAll();           
                //update Payment;
            }
            
            shouldSubmit = false;
            if(result!=null){
                if (result.TransactionStatus == 'success') {
                    p.Authorization__c = result.ApprovalCode;
                    p.CC_Reference__c = result.TransactionId;
                    p.cv_pkg_dev_I__StatusComment__c = 'Approved.  Transaction Number: ' + result.TransactionId;
                    p.Status__c = result.TransactionStatus == null || result.TransactionStatus != 'success' ? 'Declined' : 'Approved';
                    if ((result.TransactionId == null || result.TransactionId == '') && result.TransactionStatus == 'success') p.Amount__c = 0;
                    
                    p.CC_Transaction_Date__c = Date.today();
                    p.Status__c = 'Approved';
                    //createInstallmentFullfillment();
                    //return cancelAll();
                }
                else
                {
                    p.Authorization__c = result.ApprovalCode;
                    p.CC_Reference__c = result.TransactionId;
                    p.Status__c = 'Declined';
                    //update Payment;
                    //return cancelAll();
                }
            }
        }
        createInstallmentFullfillment();
        return cancelAll();
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
        if(!test.isrunningtest()){
            txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0');
        }
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
    //shri….
    Map<string, cv_pkg_dev_I__Payment__c> instPaymentMap = new Map<string, cv_pkg_dev_I__Payment__c>();
    list<cv_pkg_dev_I__Payment__c> paymentsToBeInserted = new list<cv_pkg_dev_I__Payment__c>();
    
    Map<String, String> rtypes_Map = new Map<String, String>();
    
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
    
    public FulFillInstallmentPageController(ApexPages.StandardController SC){
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
        lookupSelectedId = accContId;
        intial_Acc_Cont_Id = accContId;
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
            query += 'Id, cv_pkg_dev_I__Pledge__r.cv_pkg_dev_I__Organization__c, cv_pkg_dev_I__Pledge__r.cv_pkg_dev_I__Constituent__c, (select cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__Campaign__c, cv_pkg_dev_I__New_Campaign__c, cv_pkg_dev_I__Gift__c, cv_pkg_dev_I__Fund__c, cv_pkg_dev_I__GL_Auto_Credit_Account__c, cv_pkg_dev_I__GL_Auto_Debit_Account__c, cv_pkg_dev_I__Payment__c from Allocations__r) FROM cv_pkg_dev_I__Installment__c where cv_pkg_dev_I__Pledge__c IN: giftIds AND cv_pkg_dev_I__Installment_Balance__c > 0';
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
        
        //creating payment 
        for(InstallmetnWrapperClass i : installmentWrapper){
            
            if(i.fullfilmentAmount != Null && i.fullfilmentAmount !=0){
                cv_pkg_dev_I__Payment__c newPayment = new cv_pkg_dev_I__Payment__c();       
                newPayment.cv_pkg_dev_I__Donation__c = i.installment.cv_pkg_dev_I__Pledge__r.id;     
                newPayment.cv_pkg_dev_I__Date_Deposited__c = Payment.cv_pkg_dev_I__Date_Deposited__c;
                newPayment.cv_pkg_dev_I__Amount__c = i.fullfilmentAmount;
                newPayment.cv_pkg_dev_I__Payment_Type__c = Payment.cv_pkg_dev_I__Payment_Type__c;
                newPayment.cv_pkg_dev_I__Credit_Card_Type__c = Payment.cv_pkg_dev_I__Credit_Card_Type__c;
                newPayment.cv_pkg_dev_I__Date__c= Payment.cv_pkg_dev_I__Date__c;
                newPayment.Cheque_Num__c = Payment.Cheque_Num__c;
                newPayment.Cheque_Date__c = Payment.Cheque_Date__c;
                newPayment.Description__c = Payment.Description__c;
                
                
                
                if(Payment.cv_pkg_dev_I__Payment_Type__c == 'Credit Card'){                
                    newPayment.RecordTypeId = rtypes_Map.get('Credit Card');                
                    newPayment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);
                    creditcardNumber = Payment.Credit_Card_Number__c;
                    system.debug('----shri==='+newPayment.Credit_Card_Number__c);               
                }
                else{
                    newPayment.RecordTypeId = rtypes_Map.get('Standard');
                    newPayment.Status__c= 'Approved';           
                } 
                system.debug('hi-----------------123');
                paymentsToBeInserted.add(newPayment);
                instPaymentMap.put(i.installment.id, newPayment);
                
            }
        }
        if(paymentsToBeInserted.size()>0){ 
            insert paymentsToBeInserted;
        }
        if(Payment.cv_pkg_dev_I__Payment_Type__c == 'Credit Card'){           
            shouldSubmit = true;
            
        }
        else {            
            createInstallmentFullfillment();            
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
        
        if(Payment.cv_pkg_dev_I__Payment_Type__c == 'Credit Card'){
            
            for(cv_pkg_dev_I__Payment__c p: paymentsToBeInserted){
                if(p.Status__c == 'Declined'){
                    Payment.Status__c='Declined';
                    delete paymentsToBeInserted;
                    insert Payment;
                    return ;
                }            
            }              
            if(paymentsToBeInserted.size()>0){ 
                system.debug('----shri'+paymentsToBeInserted);
                update paymentsToBeInserted;
                system.debug('----shri'+paymentsToBeInserted);
            }           
        }
        
        for(InstallmetnWrapperClass i : installmentWrapper){
            if(i.fullfilmentAmount != null && i.fullfilmentAmount != 0){
                cv_pkg_dev_I__Installment_Fulfillment__c installmentFullfillment = new cv_pkg_dev_I__Installment_Fulfillment__c();
                installmentFullfillment.cv_pkg_dev_I__Installment__c = i.installment.Id;
                installmentFullfillment.cv_pkg_dev_I__Payment__c = instPaymentMap.get(i.installment.Id).id;
                installmentFullfillment.cv_pkg_dev_I__Fulfillment_Amount__c = i.fullfilmentAmount;
                installmentFullFillmentList.add(installmentFullfillment);
                system.debug('before creating gl allocation');
                cv_pkg_dev_I__Gift_Detail__c gdP = new cv_pkg_dev_I__Gift_Detail__c();
                cv_pkg_dev_I__Gift_Detail__c gdN = new cv_pkg_dev_I__Gift_Detail__c();
                if(i.installment.Allocations__r.size() > 0){
                    Integer numberOfAllocation = i.installment.Allocations__r.size();
                    for(cv_pkg_dev_I__Gift_Detail__c allocation : i.installment.Allocations__r){
                        if(allocation.cv_pkg_dev_I__Amount__c > 0 && allocation.cv_pkg_dev_I__Payment__c == null){
                            cv_pkg_dev_I__Gift_Detail__c gdClonePositive = allocation;
                            cv_pkg_dev_I__Gift_Detail__c gdCloneNegative = allocation;
                            
                            gdP = gdClonePositive.clone(false, true);
                            //gdP.cv_pkg_dev_I__Approved_Amount__c=i.fullfilmentAmount/numberOfAllocation;
                            gdP.cv_pkg_dev_I__Amount__c = i.fullfilmentAmount;
                            gdP.cv_pkg_dev_I__Payment__c = instPaymentMap.get(i.installment.Id).id;
                            gdP.cv_pkg_dev_I__Allocation_Date__c =instPaymentMap.get(i.installment.Id).cv_pkg_dev_I__Date_Deposited__c;
                            gdP.cv_pkg_dev_I__Gift__c = i.installment.cv_pkg_dev_I__Pledge__r.id;
                            gdP.cv_pkg_dev_I__Installment__c = null;                            
                            theGDs.add(gdP);
                            
                            gdN = gdCloneNegative.clone(false, true);
                            //gdN.cv_pkg_dev_I__Approved_Amount__c=0;
                            gdN.cv_pkg_dev_I__Amount__c = 0-i.fullfilmentAmount;
                            gdN.cv_pkg_dev_I__Payment__c = null;
                            gdN.cv_pkg_dev_I__Allocation_Date__c =instPaymentMap.get(i.installment.Id).cv_pkg_dev_I__Date_Deposited__c;
                            gdN.cv_pkg_dev_I__Gift__c = i.installment.cv_pkg_dev_I__Pledge__r.id;
                            gdN.cv_pkg_dev_I__Installment__c = i.installment.Id;                            
                            //gd.cv_pkg_dev_I__GL_Auto_Debit_Account__c = allocation.cv_pkg_dev_I__GL_Auto_Credit_Account__c;
                            //gd.cv_pkg_dev_I__GL_Auto_Credit_Account__c = allocation.cv_pkg_dev_I__GL_Auto_Debit_Account__c;
                            theGDs.add(gdN);
                        }
                    }
                }
            }
        }
        if(installmentFullFillmentList.size() > 0)
            insert installmentFullFillmentList;
        if(theGDs.size() > 0)
            insert theGDs;
        //delete the payment record after spillting and creating sub payments.
        
    }
    
    //to redirect to newly created payment or transaction if payment is not created
    public PageReference cancelAll(){
        PaymentId = Payment.Id;
        PageReference p;
        if(TransactionId == null || TransactionId.equals('')){  
            p = new PageReference(Url);      
        }else{
            p = new PageReference('/' + TransactionId);
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