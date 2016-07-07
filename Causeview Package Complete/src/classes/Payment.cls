public with sharing class Payment {
    public class BatchAllocationSetting {
        public string LetterId { get; set; }
        public string LetterName { get; set; }
        
        public string FundId { get; set; }
        public string FundName { get; set; }
        
        public BatchAllocationSetting() { }
        public BatchAllocationSetting(string l, string f)
        {
            LetterId = l;
            FundId = f;
        }
    }

    @RemoteAction
    public static BatchAllocationSetting GetAppealDefaults(string appealId) {
        List<Campaign> camps = [SELECT Id, Name, Letter__c, Letter__r.Name, Fund__c, Fund__r.Name FROM Campaign WHERE Id = :appealId];
        if (camps!=null && camps.size()>0) {
            BatchAllocationSetting setting = new BatchAllocationSetting(camps[0].Letter__c, camps[0].Fund__c);
            if (camps[0].Letter__c!=null)
                setting.LetterName = camps[0].Letter__r.Name;
            if (camps[0].Fund__c!=null)
                setting.FundName = camps[0].Fund__r.Name;
            return setting;   
        }
        else
            return new BatchAllocationSetting();
    }

    public PageReference submitPayment() {
        BatchGateway3.TransactionResult result;
        try
        {
           result = submit(Payment, Payment.Donation__c);
        }
        catch(Exception ex)
        {
           shouldSubmit = false;
           Payment.Status__c = 'Declined';
           Payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);
           //thePayment.Donation__c = theGift.Id;
           //thePayment.StatusComment__c = ex.getMessage();
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
            Payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);            
           Payment.Status__c = 'Approved';
           Payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);           
           update Payment;
           return cancelAll();
        }
        else
           return null;
    }
    
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
        payment.donationType = 'IND';
        
        //one time payment
        payment.billingStartDate = date.today();
        payment.numberOfPayments = '';
        payment.isIndividual = true;
        payment.isRecurring = false;
        payment.constituentType ='Existing';
        payment.amount = p.Amount__c.format();
        payment.creditCardNumber = p.Credit_Card_Number__c;
        payment.creditCardType = p.Credit_Card_Type__c;
        payment.cvv2 = ccCVV;
        payment.currencyType = BatchSettings.CurrencyCode__c;
        payment.expiryMonth = tryParseToInt(ccExpM);
        payment.expiryYear = tryParseToInt(ccExpY);
        payment.giftId = gid;
        payment.paymentId = p.Id;
        form.payments.payment.add(payment);
        System.debug(payment);
        BatchGateway3.ArrayOfTransactionResult txResults = new BatchGateway3.ArrayOfTransactionResult();
        txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0');
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
    
    //public causeview__Gift__c Transaction1 {get; set;}
    public String PaymentId {get; set;}
    public String Url {get;set;}
    public String Msg {get; set;}
    public causeview__Payment__c Payment {get;set;}  
    public Boolean HasError {get; set;}
    public List<causeview__Gift_Detail__c> AllocationList { get; set; }
    public List<Schema.FieldSetMember> PaymentFieldList {get; set;}
    public List<Schema.FieldSetMember> AllocationFieldList {get; set;}
    public List<causeview__Gift_Detail__c> DelAllocationList {get; set;}
    public List<causeview__Gift_Detail__c> UpsertAllocationList {get; set;}
    public boolean shouldSubmit { get; set; }
    public String TransactionId {get; set;}
    public String FundKeyPrefix {get; set;}
    
    public String PaymentRequiredFields {
        get{
            return ', causeview__Date__c, causeview__Amount__c, causeview__Status__c, causeview__Payment_Type__c, causeview__Donation__c';
        }
    }
    public String AllocationRequiredFields {
        get{
            return ', causeview__New_Campaign__c, causeview__Fund__c, causeview__Amount__c, causeview__Allocation_Date__c, causeview__Payment__c, causeview__Gift__c';
        }
    }  
    
    public Payment(ApexPages.StandardController stdController) {
        Payment = (causeview__Payment__c)stdController.getRecord();
        setKeyPrefix();
        setPaymentFieldList();
        setAllocationFieldList();
        setPayment();
        setAllocationList();
        shouldSubmit = false;
    }    
        
    public Payment(String strTransactionId) {
        shouldSubmit = false;    
        TransactionId = strTransactionId;
        setKeyPrefix();
        setPaymentFieldList();
        setAllocationFieldList();
        setPayment();
        setAllocationList();
    }
    
    public void setKeyPrefix(){
        Schema.DescribeSObjectResult fund = causeview__Fund__c.sObjectType.getDescribe();
        FundKeyPrefix = fund.getKeyPrefix();
        //FundKeyPrefix = causeview__Letter__c.sObjectType.getDescribe().getKeyPrefix();
        //Transaction1 = new causeview__Gift__c();
    }
    
    public void setPaymentFieldList() {
        PaymentFieldList = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> pfl = SObjectType.causeview__Payment__c.FieldSets.causeview__Single_Transation_Custom_Fields.getFields();
        system.debug('Nitin Payment Fieldset==='+pfl);
        for(Schema.FieldSetMember f : pfl) {            
            if(!PaymentRequiredFields.contains(f.getFieldPath())){
                PaymentFieldList.add(f);
            }
        }
    }
    
    public void setAllocationFieldList() {
        AllocationFieldList = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> afl = SObjectType.causeview__Gift_Detail__c.FieldSets.causeview__allocation.getFields();
        for(Schema.FieldSetMember f : afl) {            
            if(!AllocationRequiredFields.contains(f.getFieldPath())){
                AllocationFieldList.add(f);
            }
        }  
    }
    
    public void setPayment() {    
        if(PaymentId == null){
            Url = ApexPages.currentPage().getParameters().get('Url');
            PaymentId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(PaymentId != null && !PaymentId.equals('')){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : PaymentFieldList) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id, causeview__Credit_Card_Type__c, causeview__Credit_Card_Number__c, causeview__Description__c, causeview__Cheque_Num__c, causeview__Date_Deposited__c, causeview__Cheque_Date__c  ';
            query += PaymentRequiredFields + ' FROM causeview__Payment__c where id=\'' + string.escapeSingleQuotes(PaymentId) + '\' LIMIT 1';
            Payment = Database.query(query);            
        }else{    
            if(TransactionId == null){
                TransactionId = ApexPages.currentPage().getParameters().get('TransactionId');
            }
            Payment = new causeview__Payment__c();
            Payment.causeview__Donation__c = TransactionId;
            Payment.causeview__Payment_Type__c = '';
            Payment.causeview__Date_Deposited__c = Date.Today(); 
            //String rtName = 'Paymentld';
            //RecordType rt = [select Id from RecordType where Name =:rtName limit 1];
            //Payment.RecordTypeId = rt.Id;
        }
    }
    
    public void setAllocationList() {
        AllocationList = new List<causeview__Gift_Detail__c>();
        if(PaymentId != null && !PaymentId.equals('')){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : AllocationFieldList) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id' + AllocationRequiredFields + ' FROM causeview__Gift_Detail__c where causeview__Payment__c=\'' +string.escapeSingleQuotes(PaymentId) + '\' ';
            for(causeview__Gift_Detail__c a : Database.query(query)){
                AllocationList.add(a);
            }
        } 
        if(AllocationList.size()<5){
            for(Integer i=AllocationList.size(); i<5; i++){
                AllocationList.add(new causeview__Gift_Detail__c(causeview__Allocation_Date__c = Date.Today()));
                if(AllocationList.size() >=5) break;    
            }       
        }
    }
        
    public List<causeview__Gift_Detail__c> getGiftDetailstoUpdate(){
       List<causeview__Gift_Detail__c> result = new List<causeview__Gift_Detail__c>();       
       for(causeview__Gift_Detail__c gd : AllocationList){
           if ((gd.causeview__New_Campaign__c == null) && (gd.causeview__Fund__c == null) && gd.causeview__Amount__c==null) continue;
           if (gd.causeview__Allocation_Date__c == null) { gd.causeview__Allocation_Date__c.addError('Allocations: Allocation date is required.'); return null; }
           if (gd.causeview__New_Campaign__c == null) { gd.causeview__New_Campaign__c.addError('Allocations: Allocation Appeal is required'); return null; }
           //if (gd.causeview__Fund__c == null) { gd.causeview__Fund__c.addError('Allocations: Allocation Fund is required'); return null; }
           if (gd.causeview__Amount__c==null) { gd.causeview__Amount__c.addError('Allocations: Allocation Amount is required'); return null; }
           result.add(gd);
       }       
       return result;
    }
        
    public void setAllocationOperationList(){
       HasError = false;
       DelAllocationList = new List<causeview__Gift_Detail__c>();      
       UpsertAllocationList = new List<causeview__Gift_Detail__c>();       
       for(causeview__Gift_Detail__c gd : AllocationList){
           if ((gd.causeview__New_Campaign__c == null) && (gd.causeview__Fund__c == null) && gd.causeview__Amount__c==null){
               if(gd.Id != null){
                   DelAllocationList.add(gd);
               }
               continue;
           }
           if (gd.causeview__Allocation_Date__c == null) { gd.causeview__Allocation_Date__c.addError('Allocations: Allocation date is required.'); HasError = true; }
           if (gd.causeview__New_Campaign__c == null) { gd.causeview__New_Campaign__c.addError('Allocations: Allocation Appeal is required'); HasError = true; }
           //if (gd.causeview__Fund__c == null) { gd.causeview__Fund__c.addError('Allocations: Allocation Fund is required'); HasError = true; }
           if (gd.causeview__Amount__c==null) { gd.causeview__Amount__c.addError('Allocations: Allocation Amount is required'); HasError = true; }
           if(!HasError){
               UpsertAllocationList.add(gd);
           }
       }    
       if(HasError){
           DelAllocationList = new List<causeview__Gift_Detail__c>();      
           UpsertAllocationList = new List<causeview__Gift_Detail__c>(); 
       }   
    }
    public PageReference saveAll(){
        try{
            setAllocationOperationList();
            if(HasError){
                return null;
            }else{
                if (Payment.Amount__c <= 0) {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Amount must be greater than 0.'));
                   return null;
                }
                else {
                //if (theFinalGifts.size()<=0) {
                if (UpsertAllocationList.size()<=0) {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: At least one Allocation is required.'));
                   return null;
                }
                else{
                    Decimal dTotalAllocationAmount = 0;
                    for (causeview__Gift_Detail__c gd : UpsertAllocationList){
                        dTotalAllocationAmount += gd.causeview__Amount__c;
                    }
                    if(Payment.causeview__Amount__c == dTotalAllocationAmount){
                        String strRecordTypeName = 'Standard';
                        if(Payment.causeview__Payment_Type__c.equals('Credit Card')){
                            strRecordTypeName = 'Credit Card';
                            shouldSubmit = true;
                        }
                        RecordType rt = [select id from RecordType where Name=:strRecordTypeName AND NamespacePrefix = 'causeview'];
                        Payment.RecordTypeId = rt.id;
                        for(Schema.FieldSetMember f : PaymentFieldList) {
                            Payment.put(f.getFieldPath(), Payment.get(f.getFieldPath())); 
                            Payment.put('causeview__Date__c', Payment.get('causeview__Date__c')); 
                            Payment.put('causeview__Amount__c', Payment.get('causeview__Amount__c')); 
                            Payment.put('causeview__Status__c', Payment.get('causeview__Status__c')); 
                            Payment.put('causeview__Payment_Type__c', Payment.get('causeview__Payment_Type__c')); 
                            Payment.put('causeview__Donation__c', Payment.get('causeview__Donation__c')); 
                        }   
                        upsert Payment;
                        for (causeview__Gift_Detail__c gd : UpsertAllocationList){
                            if(gd.causeview__Payment__c == null){
                                gd.causeview__Payment__c = Payment.Id;
                            }
                            if(gd.causeview__Gift__c == null){
                                gd.causeview__Gift__c = Payment.causeview__Donation__c;
                            }
                            if(gd.causeview__Fund__c == null){
                                gd.causeview__Fund__c = getDefaultFund(gd.causeview__New_Campaign__c);
                            }
                            
                        }
                        if (UpsertAllocationList != null && UpsertAllocationList.size() != 0) {
                            upsert UpsertAllocationList;
                        }
                        if (DelAllocationList != null && DelAllocationList.size() != 0) {
                            delete DelAllocationList;
                        }
                        if (!shouldSubmit) 
                        { return cancelAll(); } 
                        else { return null; }
                    }else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of Allocations must total the Payment amount.');  
                        ApexPages.addMessage(myMsg);
                        return null;
                    }  
                }    
            }  }
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());  
            ApexPages.addMessage(myMsg); 
            return null;
        }
    }
    public PageReference cancelAll(){
        PageReference p;
        if(PaymentId == null || PaymentId.equals('')){  
            //p = new PageReference('/001?fcf=00Bi0000000TiEI');
            p = new PageReference(Url);      
        }else{
            p = new PageReference('/' + PaymentId);
        }
        return p;
    }
    public PageReference newAllocation(){ 
        AllocationList.add(new causeview__Gift_Detail__c(causeview__Allocation_Date__c = Date.Today())); 
        return null;
    }
    
    public causeview__Gift__c theGift { get; set; }
    public string ccExpM { get; set; }
    public string ccExpY { get; set; }    
    public string ccCVV { get; set; }
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
    
    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        for (Integer i = 0; i <= 8; i++)
        {
            options.add(new SelectOption(String.valueOf(Date.Today().Year()+i), String.valueOf(Date.Today().Year()+i)));     
        }                                                                                                                                                                                                                                                                                            
        return options;
    } 
    public Id getDefaultFund(Id AppealId){
        Id fundId = null;
        for(Campaign appeal : [select causeview__Fund__c from  Campaign where Id = :AppealId]){
            fundId = appeal.causeview__Fund__c;
        }
        System.debug('Fund Id:' + fundId);
        return fundId;
    }
}