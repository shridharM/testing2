public class GiftControllerExtension {

    

    // * Standard Objects  * //
    // final tesing 2

    public Gift__c theGift { get; set; }

    public Payment__c thePayment { get; set; }

    public Receipt__c theReceipt { get; set; }

    public Recurring_Donation__c theRecurring { get; set; }

    public List<Payment__c> thePayments { get; set; }

    public List<Gift_Detail__c> theGiftDetails { get; set; }

    public List<Solicitor__c> softCredits { get; set; }    

    public Contact theIndividual { get; set; }

    public Account theOrg { get; set; }    

    public boolean isOrg { get; set; }

    private string authToken { get; set; }

    

    

    public string FirstName { get; set; }

    public string lastName { get; set; }

    public string hiddenInputValue { get; set; }
    
    public string hiddenAppeal { get; set;}

    //public string hiddenInputId1 { get; set; }
    
    // public string hiddeninputid1Val { get; set;}
 
    public string hiddenInputId { get; set; }    

    public string contactlookup1 { get; set; }

    public boolean enablefield{get;set;}

    public contact lookupcontact;

    public Gift__c giftForContact { get; set; }

    public String conId{get;set;}
    
   

    

    

    public string payment_structure { get; set; }    

    public string default_payment_status { get; set; }    

    public string per_payment_amount { get; set; }        

    public string ccExpM { get; set; }

    public string ccExpY { get; set; }    

    public string ccCVV { get; set; }

    public boolean shouldSubmit { get; set; }
    public boolean paymentReference { get; set; }//to know payment processing and has reference no. shri story #102065790

    public BatchGateway4.ArrayOfTransactionResult txResults { get; set; }

    

    public boolean shouldInsertReceipt { get; set; }

    

    public static string TestContactId { get; set; }

    //** API  **//

    //private Causeview_REST_API api { get; set; }

    //public Actionpage batch_form { get; set; }

    

    /** Used for Fund Lookup Override **/

    public string FundKeyPrefix { get; set; }

    public string cId{ get; set; }

    //used for credit card number

    String ccNumber; 

    

    /** Dynamic Fieldsets **/

    public List<Schema.FieldSetMember> PaymentFieldList {get; set;}

    public List<Schema.FieldSetMember> AllocationFieldList {get; set;}  

    

    //added by nitin

    public Boolean multiCurrenyEnable{get;set;}

    public string selectedCurrencyCode{get;set;} 

    public Boolean pledgeInstallmentEnable {get;set;}

    public Integer fixedNumberInstallment {get;set;}

    public List<cv_pkg_dev_I__Installment__c> theInstallments {get; set;}

    
    public void setAllocationFieldList() {

        AllocationFieldList = new List<Schema.FieldSetMember>();

        List<Schema.FieldSetMember> afl = SObjectType.cv_pkg_dev_I__Gift_Detail__c.FieldSets.cv_pkg_dev_I__allocation.getFields();

        for(Schema.FieldSetMember f : afl) {            

            AllocationFieldList.add(f);

        }  

    }

    

    public void setPaymentFieldList() {

        PaymentFieldList = new List<Schema.FieldSetMember>();

        List<Schema.FieldSetMember> pfl = SObjectType.cv_pkg_dev_I__Payment__c.FieldSets.cv_pkg_dev_I__Single_Transation_Custom_Fields.getFields();

        for(Schema.FieldSetMember f : pfl) {            

            PaymentFieldList.add(f);

        }

    }

    

    

    public PageReference  savecontact()

    {

        

        system.debug(hiddenInputId+'--savecontc-'+hiddenInputValue+''+FirstName+''+lastName);    

       /* if((hiddenInputValue == null && string.isBlank(FirstName) && string.isBlank(lastName) ) || (hiddenInputValue != null && !string.isBlank(FirstName) && !string.isBlank(lastName)) ) { 

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select Contact.'));

            return null;

        }*/

        

        /*if((hiddenInputValue != null && (!string.isBlank(FirstName) || !string.isBlank(lastName))))

        {

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter First Name and Last Name or individual'));

           return null;

        }*/

        if((string.isBlank(FirstName) || string.isBlank(lastName)) && string.isBlank(hiddenInputValue) )

        {            

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter FirstName and Last Name'));

           return null;

        }

        

        if(hiddenInputValue != null && hiddenInputValue!='')

        {

            system.debug(hiddenInputValue+'am insire contact account assignmentd'+hiddenInputId);

            Contact c=[SELECT AccountId,FirstName,LastName FROM Contact where id =: hiddenInputId];

            c.AccountId=theOrg.id;

            update c;            

            giftForContact.Constituent__c=hiddenInputId;

            

            return null;

        }

        if(FirstName != null && lastName != null )

        {

            system.debug('am inside create new contact');

            if(!(string.isEmpty(FirstName)&& string.isEmpty(lastName)) ) {

                Contact c= new Contact();

                c.FirstName=FirstName;

                c.LastName=lastName;

                c.AccountId=theOrg.id;

                insert c;            

                giftForContact.Constituent__c = c.Id;

                 theGift.cv_pkg_dev_I__Affiliated_Contact__c=c.Id;

                 hiddenInputValue= c.FirstName+' '+c.LastName;

                 hiddenInputId=c.id;

            }

        }

        return null;

    }

    

    

    /* public PageReference fieldUpdate() {

system.debug('am inside field update----'+enablefield);

enablefield=true;

//lookupcontact=(sObject).var;

return null;

} */

    

    public GiftControllerExtension(ApexPages.StandardController controller) {

        /** Setting Fieldsets in Constructor **/

        Schema.DescribeSObjectResult fund = cv_pkg_dev_I__Fund__c.sObjectType.getDescribe();

        FundKeyPrefix = fund.getKeyPrefix();    

        setAllocationFieldList();

        setPaymentFieldList();

        //enablefield=false;

        

        System.debug('in constrctur');

        

        /** Initialization **/

        theGift = (Gift__c)controller.getRecord();

        giftForContact = new Gift__c();

        theRecurring = new Recurring_Donation__c();

        cId = System.currentPagereference().getParameters().get('cid');

        if (cId == null) cId = TestContactId;

        InitializeContact(cId);

        //added by nitin

        cv_pkg_dev_I__App_Settings__c appSetting = cv_pkg_dev_I__App_Settings__c.getInstance();

        pledgeInstallmentEnable = appSetting.cv_pkg_dev_I__Enable_Pledge_Installment_Model__c;

        if(pledgeInstallmentEnable){

            payment_structure = '# of Installment';

        }else

        {

            payment_structure = '# of Payments';

        }

        //till here

        CalcPaymentAmount();

        //Added by Nitin

        shouldInsertReceipt = false;

        //** API Initialization **//

        //api = new Causeview_REST_API();

        //batch_form = api.GetActionpage('a0JC000000PIdNTMA1');

        //batch_form.setStringField('Name', 'Test_Name');

        //added by nitin

        multiCurrenyEnable = checkMCEnabled();

        

    }

    

    public void InitializeContact(string contactId)

    {

        system.debug('<==Inside InitializeContact==>');

        shouldSubmit = false;
        paymentReference=false;

        

        isOrg = contactId.startsWith('001');

        

        if (isOrg) {

            List<Account> contacts = [SELECT BillingStreet, Email__c, BillingCity, BillingPostalCode, BillingState, BillingCountry, Name, Id FROM Account WHERE Id = :contactId];

            if (contacts==null || contacts.size()<=0) return; 

            

            theOrg = contacts[0];        

        }

        else {

            List<Contact> contacts = [SELECT Name, FirstName, LastName, Email, Id, MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry FROM Contact WHERE Id = :contactId];

            if (contacts==null || contacts.size()<=0) return; 

            

            theIndividual = contacts[0];

        }

        

        if (!isOrg) {

            theGift.Constituent__c = theIndividual.Id;

        }

        else {

            theGift.Organization__c = theOrg.Id;        

        }

        theGift.Gift_Type__c = 'One Time Gift';    

        theGift.Gift_Date__c = Date.Today();          

        theGift.Status__c = 'Entered';

        theGift.Receipt_Type__c = 'Single Receipt';            

        

        thePayment = new Payment__c();

        thePayment.Payment_Type__c = '';

        thePayment.Status__c = 'Approved';

        

        theGiftDetails = new List<Gift_Detail__c>();            

        theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));    

        theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));    

        theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));             

        

        

        if (!isOrg) {

            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Constituent__c = theIndividual.Id);

        }

        else {

            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Organization__c  = theOrg.Id);

        }        

        

        softCredits = new List<Solicitor__c>();

        softCredits.add(new Solicitor__c());  

        softCredits.add(new Solicitor__c());

        

        thePayments = new List<Payment__c>();

        theInstallments = new List<cv_pkg_dev_I__Installment__c>();    //added by nitin

    }       

    

    public void CalcPaymentAmount() {

        if (theRecurring.of_Payments__c != null) {

            if(theRecurring.of_Payments__c == 0) {

                per_payment_amount = '0';    

            }

            else {

                per_payment_amount = String.valueOf(theGift.Expected_Amount__c / theRecurring.of_Payments__c);

            }

        }

    }

    

    public PageReference GeneratePaymentSched() {

        system.debug('<==Inside GeneratePaymentSched==>');

        thePayments = new List<Payment__c>();        

        

        //Validate "# of Payments" and "Per Payment Amount" fields.

        //Both "# of Payments" and "Per Payment Amount" cannot be null.

        if ( (per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (theRecurring.of_Payments__c == null || theRecurring.of_Payments__c <= 0) ) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:"' + payment_structure + '" should be a positive value.'));

            return null;

        }

        

        //If payment structure is "per payment amount", calculate "number of payments" based on the "per payment amount" value.

        if (payment_structure == 'Per Payment Amount')       

            theRecurring.of_Payments__c = Math.floor(theGift.Expected_Amount__c/Decimal.valueOf(per_payment_amount));

        

        system.debug('Nitin Recurring Payment===='+theRecurring.of_Payments__c);

        decimal rounded_amount = 0;

        string standard_rt = [SELECT Id FROM RecordType WHERE SObjectType = 'cv_pkg_dev_I__Payment__c' AND Name = 'Standard'].Id;

        for (integer i = 0; i < theRecurring.of_Payments__c; i++) {

            Payment__c p = new Payment__c();

            p.Donation__c = theGift.Id;                

            p.RecordTypeId = standard_rt;                

            P.Payment_Type__c = thePayment.Payment_Type__c;

            p.Status__c = default_payment_status;                

            if (theRecurring.Frequency__c == 'Monthly') { p.Date__c = theRecurring.Start_Date__c.addMonths(i); }

            if (theRecurring.Frequency__c == 'Quarterly') { p.Date__c = theRecurring.Start_Date__c.addDays(i*90); }

            if (theRecurring.Frequency__c == 'Annually') { p.Date__c = theRecurring.Start_Date__c.addYears(i); }                                

            if (payment_structure != '# of Payments') {

                p.Amount__c = Decimal.valueOf(per_payment_amount);

                theRecurring.Amount__c = Decimal.valueOf(per_payment_amount);

            }      

            else {

                p.Amount__c = (theGift.Expected_Amount__c / theRecurring.of_Payments__c).setScale(2);

                theRecurring.Amount__c = (theGift.Expected_Amount__c / theRecurring.of_Payments__c).setScale(2);

                rounded_amount = rounded_amount + p.Amount__c;

            }          

            thePayments.add(p);

        }            

        if (rounded_amount != 0 && rounded_amount != theGift.Expected_Amount__c) {

            thePayments[Integer.valueOf(theRecurring.of_Payments__c) - 1].Amount__c = thePayments[Integer.valueOf(theRecurring.of_Payments__c) - 1].Amount__c - (rounded_amount - theGift.Expected_Amount__c);

        }

        if (Math.mod(Integer.valueOf(theGift.Expected_Amount__c),Integer.valueOf(theGift.Expected_Amount__c / theRecurring.of_Payments__c)) != 0) {

            thePayments[Integer.valueOf(theRecurring.of_Payments__c) - 1].Amount__c = theGift.Expected_Amount__c - (Math.floor(theGift.Expected_Amount__c/theRecurring.of_Payments__c)*theRecurring.of_Payments__c);

        }

        

        return null;    

    }

    //added by nitin

    public pageReference generateInstallments(){

        theInstallments = new List<cv_pkg_dev_I__Installment__c>();

        

        if ( (per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (fixedNumberInstallment == null || Decimal.valueOf(fixedNumberInstallment) <= 0) ) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:"' + payment_structure + '" should be a positive value.'));

            return null;

        }

        

        if (payment_structure == 'Per Installment Amount') {  

            Decimal decimalValue = Math.floor(theGift.Expected_Amount__c/Decimal.valueOf(per_payment_amount));

            fixedNumberInstallment = decimalValue.intValue();

        }

        

        decimal rounded_amount = 0;

        for (integer i = 0; i < fixedNumberInstallment; i++) {

            cv_pkg_dev_I__Installment__c p = new cv_pkg_dev_I__Installment__c();

            p.cv_pkg_dev_I__Inst_No__c = i+1;  

            //p.cv_pkg_dev_I__Status__c = default_payment_status;                

            if (theRecurring.Frequency__c == 'Monthly') { p.cv_pkg_dev_I__Installment_Date__c = theRecurring.Start_Date__c.addMonths(i); }

            if (theRecurring.Frequency__c == 'Quarterly') { p.cv_pkg_dev_I__Installment_Date__c = theRecurring.Start_Date__c.addDays(i*90); }

            if (theRecurring.Frequency__c == 'Annually') { p.cv_pkg_dev_I__Installment_Date__c = theRecurring.Start_Date__c.addYears(i); }                                

            if (payment_structure != '# of Installment') {

                p.cv_pkg_dev_I__Installment_Amount__c = Decimal.valueOf(per_payment_amount);

                //theRecurring.Amount__c = Decimal.valueOf(per_payment_amount);

            }      

            else {

                p.cv_pkg_dev_I__Installment_Amount__c = (theGift.Expected_Amount__c / fixedNumberInstallment).setScale(2);

                //theRecurring.Amount__c = (theGift.Expected_Amount__c / theRecurring.of_Payments__c).setScale(2);

                rounded_amount = rounded_amount + p.cv_pkg_dev_I__Installment_Amount__c;

            } 

            if(theOrg != null){              

                p.Name = theOrg.Name +' $'+ p.cv_pkg_dev_I__Installment_Amount__c + ' - '+ p.cv_pkg_dev_I__Installment_Date__c.format() +' - Inst ' + p.cv_pkg_dev_I__Inst_No__c;

            }else

            {

                p.Name = theIndividual.Name +' $'+ p.cv_pkg_dev_I__Installment_Amount__c + ' - '+ p.cv_pkg_dev_I__Installment_Date__c.format() +' - Inst ' + p.cv_pkg_dev_I__Inst_No__c;

            }         

            theInstallments.add(p);

        }            

        /*if (rounded_amount != 0 && rounded_amount != theGift.Expected_Amount__c) {

thePayments[Integer.valueOf(theRecurring.of_Payments__c) - 1].Amount__c = thePayments[Integer.valueOf(theRecurring.of_Payments__c) - 1].Amount__c - (rounded_amount - theGift.Expected_Amount__c);

}

if (Math.mod(Integer.valueOf(theGift.Expected_Amount__c),Integer.valueOf(theGift.Expected_Amount__c / theRecurring.of_Payments__c)) != 0) {

thePayments[Integer.valueOf(theRecurring.of_Payments__c) - 1].Amount__c = theGift.Expected_Amount__c - (Math.floor(theGift.Expected_Amount__c/theRecurring.of_Payments__c)*theRecurring.of_Payments__c);

}*/

        

        return null;

    }

    

    

    public PageReference Submit() {

        system.debug('<==Inside Submit==>'+per_payment_amount);

        system.debug('<==Inside Submit==>'+thePayments);
        
        //cv_pkg_dev_I__Custom_Allocation_Text__c  & cv_pkg_dev_I__Description__c are used in SingleTransaction page as a intermediate field to resolve some bug, for that it is making null here. story #102212988
        for(Gift_Detail__c gd : theGiftDetails){
        if(gd.Amount__c!=null){
            system.debug('====='+gd.cv_pkg_dev_I__Custom_Allocation_Text__c+'===='+gd.cv_pkg_dev_I__Description__c);
            string ids= gd.cv_pkg_dev_I__Description__c;
            if(ids!= null && ids != '')
            		gd.New_Campaign__c=ids;
            gd.cv_pkg_dev_I__Custom_Allocation_Text__c='';
            gd.cv_pkg_dev_I__Description__c='';
          }            
        }
        

        if(isOrg)

        {  

        System.debug('-----'+hiddenInputId);

        system.debug(FirstName+'<==Inside Submit==>'+lastName);

        if(hiddenInputValue != null && String.isNotEmpty(hiddenInputValue)){

        theGift.cv_pkg_dev_I__Affiliated_Contact__c=hiddenInputId; 

        }        

            if((String.isNotEmpty(FirstName) && String.isNotEmpty(lastName)) && String.isEmpty(hiddenInputValue)){              

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please click save before submit.'));

                return null;

            }

            

         } 

        

               

        

        //Validation

        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'At least '));

        //added by nitin

        if (theGift.Gift_Type__c == 'Pledge') {

            

            //Validate "# of Payments" and "Per Payment Amount" fields.

            //Both "# of Payments" and "Per Payment Amount" cannot be null.

            if(pledgeInstallmentEnable){    //added by nitin

                if ( (per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (fixedNumberInstallment == null || Decimal.valueOf(fixedNumberInstallment) <= 0) ) {

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:"' + payment_structure + '" should be a positive value.'));

                    return null;

                }

            }else

            {

                if ( (per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (theRecurring.of_Payments__c == null || theRecurring.of_Payments__c <= 0) ) {

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:"' + payment_structure + '" should be a positive value.'));

                    return null;

                }

            }

            //Added by nitin to check generate payment schedule button is clicked

            if (thePayments.size() == 0 && theInstallments.size() == 0) {    //theInstallments.size() condition added by nitin

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must click the Generate Payment Schedule or Generate Installment Schedule button before saving.'));

                return null;

            }

        }

        //till here

        List<Solicitor__c> theSoftCredits = getSotCreditsToUpdate();

        if (theSoftCredits==null) return null;

        

        List<Gift_Detail__c> theFinalGifts = new  List<Gift_Detail__c>();
        
        theFinalGifts = getGiftDetailstoUpdate();

        if (theFinalGifts == null) return null;

        system.debug('<==Inside Submit Gd==>'+theFinalGifts);

        

        if (theFinalGifts.size()<=0) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: At least one Allocation is required.'));

            return null;

        }

        

        Decimal total = 0;

        for (Gift_Detail__c gd : theFinalGifts) {

            total = total + gd.Amount__c;

        }

        if (theGift.Expected_Amount__c != total) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The sum of the Allocations must equal the Transaction Amount.'));

            return null;

        }        

        

        //Savepoint sp = Database.setSavepoint();

        

        

        if (!isOrg) {

            if(theReceipt.Auto_Email_Receipt__c == true && theIndividual.Email == null){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Email Address for Individual, Please update Email Address if you want to use Auto Email Receipt Feature!'));

                return null;

            }

            upsert theIndividual;        

            theRecurring.Constituent__c = theIndividual.Id;                    

            theGift.Constituent__c = theIndividual.Id;

        }

        else {

            if(theReceipt.Auto_Email_Receipt__c == true && theOrg.Email__c == null){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No Email Address for Organisation, Please update Email Address if you want to use Auto Email Receipt Feature!'));

                return null;

            }

            upsert theOrg;               

            theGift.Organization__c = theOrg.Id;

            System.debug('----='+hiddenInputId);            

            if((string.isEmpty(hiddenInputId) && theGift.Gift_Type__c=='Recurring')  ){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must enter or select a contact for an Organization Recurring Gift'));

                return null;

            }

            if(string.isNotEmpty(hiddenInputId)){

            theRecurring.Constituent__c = hiddenInputId;

            }

            theRecurring.cv_pkg_dev_I__Organization__c = theOrg.Id;

            //theGift.Constituent__c = null;

        }    

        //added by nitin  

        if(multiCurrenyEnable){

            theGift.put('CurrencyIsoCode',selectedCurrencyCode);

        }

        upsert theGift;             

        //added by nitin to mask credit card

        ccNumber = thePayment.Credit_Card_Number__c;

        thePayment.Credit_Card_Number__c = RollupHelper.maskCardNumber(ccNumber);

        //added by nitin  

        if(multiCurrenyEnable){

            thePayment.put('CurrencyIsoCode',selectedCurrencyCode);

        } 

        if (theGift.Gift_Type__c == 'Pledge') {

            /** DO PLEDGE STUFF **/

            //theRecurring.Status__c = 'Active';

            //theRecurring.Type__c = 'Pledge';            

            //upsert theRecurring;

            

            //Validate "# of Payments" and "Per Payment Amount" fields.

            //Both "# of Payments" and "Per Payment Amount" cannot be null.

            /*if(pledgeInstallmentEnable){    //added by nitin

if ( (per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (fixedNumberInstallment == null || Decimal.valueOf(fixedNumberInstallment) <= 0) ) {

ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:"' + payment_structure + '" should be a positive value.'));

return null;

}

}else

{

if ( (per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (theRecurring.of_Payments__c == null || theRecurring.of_Payments__c <= 0) ) {

ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:"' + payment_structure + '" should be a positive value.'));

return null;

}

}

//Added by nitin to check generate payment schedule button is clicked

if (thePayments.size() == 0 && theInstallments.size() == 0) {    //theInstallments.size() condition added by nitin

ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must click the Generate Payment Schedule or Generate Installment Schedule button before saving.'));

return null;

}*/

            

            //If payment structure is "per payment amount", calculate "number of payments" based on the "per payment amount" value.

            if (payment_structure != '# of Payments' && payment_structure != '# of Installment')

                theRecurring.of_Payments__c = Math.floor(theGift.Expected_Amount__c/Decimal.valueOf(per_payment_amount));

            

            if(pledgeInstallmentEnable){

                theGift.Per_Payment_Amount__c = theGift.Expected_Amount__c / fixedNumberInstallment;

            }else

            {

                theGift.Per_Payment_Amount__c = theGift.Expected_Amount__c / theRecurring.of_Payments__c;

            }

            theGift.Pledge_Start_Date__c = theRecurring.Start_Date__c;

            theGift.Pledge_Payment_Frequency__c = theRecurring.Frequency__c;

            theGift.No_of_Expected_Payments__c = theRecurring.Of_Payments__c;

            //theGift.Recurring_Donation__c = theRecurring.Id;

            upsert theGift;

            

            /*List<RD_Allocation__c> theRds = new List<RD_Allocation__c>();

for (Gift_Detail__c gd : theFinalGifts) {

RD_Allocation__c rd = new RD_Allocation__c();

rd.Active__c = True;

rd.Amount__c = gd.Amount__c / theRecurring.of_Payments__c;

rd.New_Campaign__c = gd.New_Campaign__c;

rd.Campaign__c = gd.Campaign__c;

rd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;

rd.Fund__c = gd.Fund__c;

rd.Package__c = gd.Package__c;

rd.Parent_Appeal__c = gd.Parent_Appeal__c;

rd.Recurring_Gift__c = theRecurring.Id;

theRds.add(rd);

}

upsert theRds;*/

            

            if(thePayments.size() > 0){

                for (Payment__c p : thePayments) {

                    p.Donation__c = theGift.Id;

                    //added by nitin  

                    if(multiCurrenyEnable){

                        p.put('CurrencyIsoCode',selectedCurrencyCode);

                    }

                }

                upsert thePayments;

                

                List<Gift_Detail__c> theGds = new List<Gift_Detail__c>();

                for (Payment__c p : thePayments) {

                    for (Gift_Detail__c gd : theFinalGifts){

                        Gift_Detail__c nGd = new Gift_Detail__c();

                        nGd=gd.clone(false, false, false, false);

                        nGd.Payment__c = p.Id;

                        //nGd.Amount__c = gd.Amount__c;

                        nGd.Amount__c = gd.Amount__c / theRecurring.of_Payments__c;

                        nGd.New_Campaign__c = gd.New_Campaign__c;

                        nGd.Campaign__c = gd.Campaign__c;

                        nGd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;

                        nGd.Fund__c = gd.Fund__c;

                        nGd.Package__c = gd.Package__c;

                        nGd.Allocation_Date__c = p.Date__c;

                        nGd.Parent_Appeal__c = gd.Parent_Appeal__c;

                        if (nGd.Id == null) nGd.Gift__c = theGift.Id;

                        //added by nitin  

                        if(multiCurrenyEnable){

                            nGd.put('CurrencyIsoCode',selectedCurrencyCode);

                        }

                        theGDs.add(nGd);

                    }                        

                }

                upsert theGDs; 

            }else

                if(theInstallments.size() > 0){

                    for (cv_pkg_dev_I__Installment__c p : theInstallments) {

                        p.cv_pkg_dev_I__Pledge__c = theGift.Id;

                        p.cv_pkg_dev_I__Status__c = 'Open';

                        //added by nitin  

                        if(multiCurrenyEnable){

                            p.put('CurrencyIsoCode',selectedCurrencyCode);

                        }

                    }

                    upsert theInstallments;

                    

                    List<Gift_Detail__c> theGds = new List<Gift_Detail__c>();

                    for (cv_pkg_dev_I__Installment__c p : theInstallments) {

                        for (Gift_Detail__c gd : theFinalGifts){

                            Gift_Detail__c nGd = new Gift_Detail__c();

                            nGd=gd.clone(false, false, false, false);

                            

                            nGd.cv_pkg_dev_I__Installment__c = p.Id;

                            //nGd.Amount__c = gd.Amount__c;

                            nGd.Amount__c = gd.Amount__c / fixedNumberInstallment;    //gd.Amount__c / theRecurring.of_Payments__c

                            nGd.New_Campaign__c = gd.New_Campaign__c;

                            nGd.Campaign__c = gd.Campaign__c;

                            nGd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;

                            nGd.Fund__c = gd.Fund__c;

                            nGd.Package__c = gd.Package__c;

                            nGd.Allocation_Date__c = p.cv_pkg_dev_I__Installment_Date__c;

                            nGd.Parent_Appeal__c = gd.Parent_Appeal__c;

                            if (nGd.Id == null) nGd.Gift__c = theGift.Id;

                            //added by nitin  

                            if(multiCurrenyEnable){

                                nGd.put('CurrencyIsoCode',selectedCurrencyCode);

                            }

                            theGDs.add(nGd);

                        }                        

                    }

                    upsert theGDs;

                }

            

        }

        //when gift type is recurring while creating a new gift

        if (theGift.Gift_Type__c == 'Recurring') {

            // ** DO RECURRING STUFF **

            theRecurring.Status__c = 'Active';

            theRecurring.Type__c = thePayment.Payment_Type__c;

            theRecurring.Amount__c = theGift.Expected_Amount__c;

            system.debug('<==Payment Type==>'+thePayment.Payment_Type__c);

            //if the payment type is not credit card for recurring gift

            if(thePayment.Payment_Type__c != 'Credit Card'){

                //added by nitin  

                if(multiCurrenyEnable){

                    theRecurring.put('CurrencyIsoCode',selectedCurrencyCode);

                }

                upsert theRecurring;   

                

                theGift.Recurring_Donation__c = theRecurring.Id;

                upsert theGift;

                

                List<RD_Allocation__c> theRds = new List<RD_Allocation__c>();

                for (Gift_Detail__c gd : theFinalGifts) {

                    RD_Allocation__c rd = new RD_Allocation__c();

                    //rd=gd.clone(false, false, false, false);

                    rd.Active__c = True;

                    rd.Amount__c = gd.Amount__c;

                    rd.New_Campaign__c = gd.New_Campaign__c;

                    rd.Campaign__c = gd.Campaign__c;

                    rd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;

                    rd.Fund__c = gd.Fund__c;

                    rd.Package__c = gd.Package__c;

                    rd.Parent_Appeal__c = gd.Parent_Appeal__c;

                    rd.Recurring_Gift__c = theRecurring.Id;

                    //added by nitin  

                    if(multiCurrenyEnable){

                        rd.put('CurrencyIsoCode',selectedCurrencyCode);

                    }

                    theRds.add(rd);

                }

                upsert theRds; 

            }

            /*else{

shouldInsertReceipt = true;

}*/

            if (thePayment.Id == null) thePayment.Donation__c = theGift.Id;

            //added by nitin

            if(theRecurring.cv_pkg_dev_I__Start_Date__c > system.Today() && thePayment.Payment_Type__c != 'Credit Card'){

                thePayment.Amount__c = 0;

            }else{

                thePayment.Amount__c = theGift.Expected_Amount__c;

            }        

            upsert thePayment; 

            System.debug('Nitin==>'+thePayment);

            

            

        }       

        if (theGift.Gift_Type__c != 'Recurring' && theGift.Gift_Type__c != 'Pledge') {

            // ** DO Single Gift STUFF **

            system.debug('<==inside not recurring==>');

            if (thePayment.Id == null) thePayment.Donation__c = theGift.Id;

            thePayment.Amount__c = theGift.Expected_Amount__c;            

            upsert thePayment;

            

            for (Gift_Detail__c gd : theFinalGifts){

                gd.Payment__c = thePayment.Id;

                if (gd.Id == null) gd.Gift__c = theGift.Id;

                //added by nitin  

                if(multiCurrenyEnable){

                    gd.put('CurrencyIsoCode',selectedCurrencyCode);

                }

            }                        
system.debug('------'+theFinalGifts);
            upsert theFinalGifts; 

        }

        

        App_Settings__c appSetting1 = App_Settings__c.getInstance(UserInfo.getOrganizationId());

        if (theReceipt.Id == null ) theReceipt.Gift__c = theGift.Id;

        //Upsert the Rreceipt record only if the Gift associated with the Receipt record is not of type "No Receipt", "Consolidated" or Receipt Later is false.

        //(theGift.Gift_Type__c != 'Recurring') removed by Nitin from If condition

        if ( theGift.Receipt_Type__c != 'No Receipt' && theGift.Receipt_Type__c != 'Consolidated' && theGift.Receipt_Later__c != true )

        {

            

            shouldInsertReceipt = true;

            theReceipt.Receipt_Type__c = 'Single';

            //recurring -single gift condition 

            if(theGift.Gift_Type__c == 'Recurring' && appSetting1.Enable_Recurring_Receipts__c )

            { theReceipt.cv_pkg_dev_I__Amount_Receipted__c = thePayment.cv_pkg_dev_I__Amount__c;   }

            

            if(thePayment.Payment_Type__c != 'Credit Card')

            {

                //added by nitin  

                if(multiCurrenyEnable){

                    theReceipt.put('CurrencyIsoCode',selectedCurrencyCode);

                }

                upsert theReceipt;

                thePayment.Receipt__c = theReceipt.Id;  

                system.debug('thePayment==>'+thePayment.id);

                //add nitin 

                //To update recipt id on Payment Record when Gift type is "Pledge" 

                system.debug('thePayment==>'+thePayments.size());

                if(thePayments.size() > 0){

                    for (Payment__c p : thePayments) {

                        system.debug('thePayment==>'+p);

                        p.Receipt__c = theReceipt.Id;

                    }

                    update thePayments;

                }

            }

        }

        

        

        if (theSoftCredits.size() > 0) {

            for(Solicitor__c s : theSoftCredits) {

                s.Gift__c = theGift.Id;

                //added by nitin  

                if(multiCurrenyEnable){

                    s.put('CurrencyIsoCode',selectedCurrencyCode);

                }

            }

            upsert theSoftCredits;

        }

        

        if (thePayment.Payment_Type__c == 'Credit Card') {

            thePayment.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'cv_pkg_dev_I__Payment__c' AND Name = 'Credit Card'].Id;

            shouldSubmit = true;

            return null;

        }

        else {

            //Set Payment record Record Type to "Standard" if the Payment Type is not "Credit Card".

            thePayment.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'cv_pkg_dev_I__Payment__c' AND Name = 'Standard'].Id;

            if (theGift.Gift_Type__c != 'Pledge')

                Update thePayment;

            System.debug('Nitin==>'+thePayment);

            return null;

        }

    }    

    

    public void SubmitPayment()

    {

        

        

        

        system.debug('<==Inside SubmitPayment==>');

        boolean result = false;

        try

        {

            result = UpdatePaymentAndGift(thePayment, theGift, submit(thePayment, theGift.Id));

            

            system.debug('<==result==>'+result);

            system.debug('thePayment==>'+thePayment);

            system.debug('shouldInsertReceipt==>'+shouldInsertReceipt);

            if(result && shouldInsertReceipt && thePayment.Payment_Type__c == 'Credit Card')

            {

                //To check whether 

                system.debug('----------------------Receipt creation'+theReceipt);

                upsert theReceipt;

                thePayment.Receipt__c = theReceipt.Id;  

                

                update thePayment;

            }

        }

        catch(Exception ex)

        {

            

            system.debug('Receipt creation failed');

            shouldSubmit = false;

            thePayment.Status__c = 'Declined';

            thePayment.Credit_Card_Number__c = RollupHelper.maskCardNumber(thePayment.Credit_Card_Number__c);

            //thePayment.Donation__c = theGift.Id;

            //thePayment.StatusComment__c = ex.getMessage();

            

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 

            system.debug('---thePayment-'+thePayment);

            //if(thePayment.Id != null){

            update thePayment; //}

            //delete deleteallocation;

        }

        

        shouldSubmit = true;

        if((result && thePayment.CC_Reference__c==null) || (thePayment.CC_Reference__c!=null)){
            paymentReference =true;
        }
        system.debug('paymentReference-----'+paymentReference); 
        if (!result) {

            
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in proccessing payment'));
            shouldSubmit = false;

        }

        else

        {

            

            //return null;

            

        }

        

    }

    

    public PageReference GoBack() {

        system.debug('<==Inside GoBack==>');

        if(!isOrg) {

            PageReference pr = new ApexPages.StandardController(theIndividual).view();

            pr.setRedirect(true);

            return pr;

        }

        PageReference pr = new ApexPages.StandardController(theOrg).view();

        pr.setRedirect(true);

        return pr;

    }

    public PageReference GoToPayment() {        

        PageReference pr = new ApexPages.StandardController(thePayment).view();

        pr.setRedirect(true);

        return pr;

    }

    public PageReference GoToGift() {        

        PageReference pr = new ApexPages.StandardController(theGift).view();

        pr.setRedirect(true);

        return pr;

    }

    

    /* public PageReference doCancel()

{

if(thePayment.Status__c == 'Declined' && theGift.Gift_Type__c == 'One Time Gift' )

{

system.debug('--------------------Deleting One Time Gift-------------------------------'+theGift.Id);



if(theGiftDetails.size() > 0) 

{   



List<Gift_Detail__c> gd  = [select Id from Gift_Detail__c where Gift__c =: theGift.Id];

if(gd.size() > 0)

delete gd;  

}

system.debug('-----------------Gift details deleted-');



if(softCredits.size() > 0) 

{

List<Solicitor__c> sc  = [select Id  from Solicitor__c where Gift__c =: theGift.Id];

if(sc.size() > 0)

delete sc;  

}

system.debug('-----------------soft credits details deleted-');



if(thePayment.Id != null) 

delete thePayment;

system.debug('-----------------Gift details deleted-');



if(theReceipt.Id != null) 

delete theReceipt;



if(theGift.Id != null) 

delete theGift; 





system.debug('--------------------Deleted Successfully-------------------------------'+theGift);



}

if(thePayment.Status__c == 'Declined' && theGift.Gift_Type__c == 'Recurring')

{

system.debug('--------------------Deleting Recurring-------------------------------'+theGift.Id);



if(theGiftDetails.size() > 0) 

{   



List<Gift_Detail__c> gd  = [select Id from Gift_Detail__c where Gift__c =: theGift.Id];

if(gd.size() > 0)

delete gd;  

}

system.debug('-----------------Gift details deleted-');



if(softCredits.size() > 0) 

{

List<Solicitor__c> sc  = [select Id  from Solicitor__c where Gift__c =: theGift.Id];

if(sc.size() > 0)

delete sc;  

}

system.debug('-----------------soft credits details deleted-');

if(theRecurring.Id != null)

delete theRecurring;

if(thePayment.Id != null) 

delete thePayment;

if(theReceipt.Id != null) 

delete theReceipt;

if(theGift.Id != null) 

delete theGift; 

system.debug('--------------------Deleted Successfully-------------------------------'+theGift);



}





PageReference pr = goBack();

return pr;

} */

    List<cv_pkg_dev_I__Gift_Detail__c> deleteallocation;

    

    @testVisible

    private boolean UpdatePaymentAndGift(Payment__c paymnt, Gift__c gift, BatchGateway4.TransactionResult result)

    {    

        system.debug('<==Inside UpdatePaymentAndGift==>');

        boolean retVal = false;

        system.debug('<==result=>'+result.TransactionStatus);

        system.debug('<==paymnt=>'+paymnt);

        

        

        if (result.TransactionStatus == null || result.TransactionStatus != 'success')

        {

            gift.Batch_Status__c = 'Failed';

            paymnt.Status__c = 'Declined';

            system.debug('<==paymnt=>'+paymnt);

            system.debug('<==result=>'+result.TransactionStatus);

            system.debug('before delete allocation');

            deleteallocation=[select id,name,cv_pkg_dev_I__Payment__c FROM cv_pkg_dev_I__Gift_Detail__c where cv_pkg_dev_I__Payment__c =: thePayment.id];

            delete deleteallocation;
            theGiftDetails.clear();
            theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
            theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
            theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today())); 

        } 

        else

        {

            gift.Batch_Status__c = 'Committed';

            gift.Reference__c = result.RecurringProfileId;

            theRecurring.Reference__c = result.RecurringProfileId;

            theRecurring.Encrypted_Key__c = result.EncryptedRecurringProfileId;

            if (!isOrg) {                    

                theRecurring.Constituent__c = theIndividual.Id;

            }

            theRecurring.Amount__c = theGift.Expected_Amount__c;

            theRecurring.Credit_Card_Expiry_Date__c = Date.newInstance(tryParseToInt(ccExpY), tryParseToInt(ccExpM), 1);

            theRecurring.Credit_Card__c = RollupHelper.maskCardNumber(paymnt.Credit_Card_Number__c);

            theRecurring.Credit_Card_Type__c = paymnt.Credit_Card_Type__c;

            Integer freq = 1;

            if (theRecurring.Frequency__c == 'Monthly') {

                freq = 30;            

            }

            if (theRecurring.Frequency__c == 'Quarterly') {

                freq = 90;            

            }

            if (theRecurring.Frequency__c == 'Annually') {

                freq = 365;            

            }            

            

            retVal = true;

            

            //            theRecurring.recurr

            

            /*submittedGifts[count].recurringDonation.Reference__c = txResults.TransactionResult[count].RecurringProfileId;

submittedGifts[count].recurringDonation.Encrypted_Key__c = txResults.TransactionResult[count].EncryptedRecurringProfileId;*/

        }

        

        paymnt.Authorization__c = result.ApprovalCode;

        system.debug('paymnt.Authorization' + paymnt.Authorization__c);

        //If Transaction Id is -1 do not add it to CC_Reference__c.

        if(result.TransactionId != '-1') {

            system.debug('am inside transactiodid -1'+ result.TransactionId);

            paymnt.CC_Reference__c = result.TransactionId;

        }

        paymnt.Status__c = result.TransactionStatus == null || result.TransactionStatus != 'success' ? 'Declined' : 'Approved';

        if ((result.TransactionId == null || result.TransactionId == '') && result.TransactionStatus == 'success') 

            paymnt.Amount__c = 0;

        

        paymnt.CC_Transaction_Date__c = Date.today();

        paymnt.Credit_Card_Number__c = RollupHelper.maskCardNumber(paymnt.Credit_Card_Number__c);

        if (result.Errors != null)

        {

            if(result.Errors.ErrorMessages != null && result.Errors.ErrorMessages.size() > 0) {

                paymnt.StatusComment__c = result.Errors.ErrorMessages[0].Error;

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.Errors.ErrorMessages[0].Error));

            }

            else

                paymnt.StatusComment__c = 'Approved.  Transaction Number: ' + result.TransactionId;

            

        }

        

        //New Gift Interface: Re-Submit Due to CC Error --fix

        

        if(result.TransactionStatus == 'success' && gift.Gift_Type__c == 'One Time Gift'){

            gift.Status__c = 'Entered';

            update gift;

            if (result.Errors == null) 

            {

                paymnt.StatusComment__c = 'Approved.  Transaction Number: ' + result.TransactionId;

            }

            

        }

        

        //till here 

        

        

        //if the Transaction gets success and Gift Type is recurring then it creates recurring gift 

        if(result.TransactionStatus == 'success' && gift.Gift_Type__c == 'Recurring'){

            List<Gift_Detail__c> theFinalGifts = getGiftDetailstoUpdate();

            system.debug('theFinalGifts==>'+theFinalGifts);

            if (theFinalGifts == null) return null;

            

            if (theFinalGifts.size()<=0) {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: At least one Allocation is required.'));

                return null;

            }

            

            Decimal total = 0;

            for (Gift_Detail__c gd : theFinalGifts) {

                total = total + gd.Amount__c;

            }

            system.debug('recurring gift==>'+theRecurring);

            //if Payment Type is Credit card then it inserts the recurring gift record.

            if(paymnt.Payment_Type__c == 'Credit Card'){

                //added on 25/09/2014 by nitin

                if(theRecurring.cv_pkg_dev_I__Start_Date__c > system.Today()){

                    paymnt.Amount__c = 0;

                }

                //added by nitin  

                if(multiCurrenyEnable){

                    theRecurring.put('CurrencyIsoCode',selectedCurrencyCode);

                }

                upsert theRecurring;

                gift.Recurring_Donation__c = theRecurring.Id;

                upsert gift;

                

                List<RD_Allocation__c> theRds = new List<RD_Allocation__c>();

                for (Gift_Detail__c gd : theFinalGifts) {

                    RD_Allocation__c rd = new RD_Allocation__c();

                    rd.Active__c = True;

                    rd.Amount__c = gd.Amount__c;

                    rd.New_Campaign__c = gd.New_Campaign__c;

                    rd.Campaign__c = gd.Campaign__c;

                    rd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;

                    rd.Fund__c = gd.Fund__c;

                    rd.Package__c = gd.Package__c;

                    rd.Parent_Appeal__c = gd.Parent_Appeal__c;

                    rd.Recurring_Gift__c = theRecurring.Id;

                    theRds.add(rd);

                }

                upsert theRds;

                

                List<Gift_Detail__c> theGds = new List<Gift_Detail__c>();

                for (Gift_Detail__c gd : theFinalGifts){

                    Gift_Detail__c nGd = new Gift_Detail__c();

                    nGd.Payment__c = paymnt.Id;
 
                    // vg test comment --https://www.pivotaltracker.com/story/show/96472392
 
                    nGd.Amount__c = gd.Amount__c;

                    //nGd.Amount__c = gd.Amount__c / theRecurring.of_Payments__c;

                    //nGd.Amount__c = paymnt.cv_pkg_dev_I__Amount__c;

                    nGd.New_Campaign__c = gd.New_Campaign__c;

                    nGd.Campaign__c = gd.Campaign__c;

                    //nGd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;

                    nGd.Fund__c = gd.Fund__c;

                    //nGd.Package__c = gd.Package__c;

                    nGd.Allocation_Date__c = paymnt.Date__c;

                    nGd.Parent_Appeal__c = gd.Parent_Appeal__c;

                    nGd.Gift__c = gift.Id;

                    //added by nitin  

                    if(multiCurrenyEnable){

                        nGd.put('CurrencyIsoCode',selectedCurrencyCode);

                    }

                    theGDs.add(nGd);

                }                        

                Insert theGDs;

            }

            Integer freq = 1;

            if (theRecurring.Frequency__c == 'Monthly') {

                freq = 30;            

            }

            if (theRecurring.Frequency__c == 'Quarterly') {

                freq = 90;            

            }

            if (theRecurring.Frequency__c == 'Annually') {

                freq = 365;            

            }

            upsert theRecurring;

            List<RD_Allocation__c> theRDs = new List<RD_Allocation__c>();

            for (Gift_Detail__c gd : getGiftDetailstoUpdate()) {

                RD_Allocation__c rda = new RD_Allocation__c();

                rda.Recurring_Gift__c = theRecurring.Id;

                rda.Amount__c = gd.Amount__c;

                rda.New_Campaign__c = gd.New_Campaign__c;

                rda.Fund__c = gd.Fund__c;

                rda.Package__c = gd.Package__c;

                rda.Campaign__c = gd.Campaign__c;

                rda.Parent_Appeal__c = gd.Parent_Appeal__c;

            }

            gift.Next_Payment_Date__c = theRecurring.Start_Date__c.addDays(freq);            

            gift.Recurring_Donation__c = theRecurring.Id;

            gift.Status__c = 'Active';

            update gift;

        }

        if (theGift.Gift_Type__c == 'Recurring' && paymnt.Payment_Type__c != 'Credit Card') {

            Integer freq = 1;

            if (theRecurring.Frequency__c == 'Monthly') {

                freq = 30;            

            }

            if (theRecurring.Frequency__c == 'Quarterly') {

                freq = 90;            

            }

            if (theRecurring.Frequency__c == 'Annually') {

                freq = 365;            

            }

            upsert theRecurring;

            List<RD_Allocation__c> theRDs = new List<RD_Allocation__c>();

            for (Gift_Detail__c gd : getGiftDetailstoUpdate()) {

                RD_Allocation__c rda = new RD_Allocation__c();

                rda.Recurring_Gift__c = theRecurring.Id;

                rda.Amount__c = gd.Amount__c;

                rda.New_Campaign__c = gd.New_Campaign__c;

                rda.Fund__c = gd.Fund__c;

                rda.Package__c = gd.Package__c;

                rda.Campaign__c = gd.Campaign__c;

                rda.Parent_Appeal__c = gd.Parent_Appeal__c;

            }

            gift.Next_Payment_Date__c = theRecurring.Start_Date__c.addDays(freq);            

            gift.Recurring_Donation__c = theRecurring.Id;

            gift.Status__c = 'Active';

            update gift;

        }

        if(result.TransactionStatus != 'success'){

            gift.Status__c = 'Cancelled';

            update gift;

        }

        //update gift;

        update paymnt;

        system.debug('<==gift==>'+gift);

        system.debug('<==paymnt==>'+paymnt);

        return retVal;

    }

    

    private BatchGateway4.TransactionResult submit(Payment__c paymnt, string giftId)

    {    

        system.debug('<==Inside BatchGateway4.TransactionResult submit==>');

        BatchSettings__c BatchSettings = null;

        /* List<BatchSettings__c> settingList = [Select b.GatewayUrl__c, b.CurrencyCode__c, b.BatchFormId__c, b.RegularGiftRecordTypeId__c,

b.Name, b.BucketAccountId__c, BatchReportId__c 

From BatchSettings__c b WHERE Name = 'Default'];

*/

        system.debug('<==paymnt==>'+paymnt);

        BatchSettings__c settingObj = BatchSettings__c.getInstance('Default');

        if (settingObj != null)

            BatchSettings = settingObj;

        

        BatchGateway4.GatewaySoap gw = new BatchGateway4.GatewaySoap();

        gw.timeout_x = 120000;

        gw.endpoint_x = BatchSettings.GatewayUrl__c;

        BatchGateway4.BatchForm form = new BatchGateway4.BatchForm();

        BatchGateway4.FormBase formBase = new BatchGateway4.FormBase();

        form.payments = new BatchGateway4.ArrayOfPaymentInfo();

        form.payments.payment = new List<BatchGateway4.PaymentInfo>();

        formBase.currency_x = BatchSettings.CurrencyCode__c;

        formBase.formId = batchSettings.BatchFormID__c;

        formBase.version = '1.0';

        formBase.debugMode = true;

        

        BatchGateway4.PaymentInfo payment = new BatchGateway4.PaymentInfo();

        if (!isOrg) {

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

            payment.address1 = theOrg.BillingStreet;

            payment.city = theOrg.BillingCity;

            payment.state = theOrg.BillingState;

            payment.country = theOrg.BillingCountry;

            payment.zipCode = theOrg.BillingPostalCode;

            payment.donationType = 'ORG';

            payment.email = theOrg.Email__c;  

            payment.isIndividual = false;

            // https://www.pivotaltracker.com/story/show/98032786

            //System.debug('gift constituent ===='+giftForContact.Constituent__c);

            System.debug('gift constituent ====1'+FirstName);

            System.debug('gift constituent ====2'+lastName);

            payment.PayerFirstName = FirstName;

            payment.PayerLastName = lastName;                          

        }

        

        //one time payment

        //payment.billingStartDate = date.today();

        if (theGift.Gift_Type__c == 'Recurring')

        {

            payment.billingStartDate = theRecurring.Start_Date__c;

        }

        else

        {

            payment.billingStartDate = date.today();

        }

        payment.numberOfPayments = '';

        payment.isRecurring = (theGift.Gift_Type__c == 'Recurring');

        payment.constituentType ='Existing';

        payment.amount = paymnt.Amount__c.format();

        //payment.creditCardNumber = paymnt.Credit_Card_Number__c;

        payment.creditCardNumber = ccNumber;

        payment.creditCardType = paymnt.Credit_Card_Type__c;

        payment.cvv2 = ccCVV;

        payment.currencyType = BatchSettings.CurrencyCode__c;

        payment.expiryMonth = tryParseToInt(ccExpM);

        payment.expiryYear = tryParseToInt(ccExpY);

        payment.frequency = (theGift.Gift_Type__c == 'Recurring') ? theRecurring.Frequency__c : '';

        payment.giftId = giftId;

        payment.paymentId = paymnt.Id;

        form.payments.payment.add(payment);

        System.debug('<==payment==>'+payment);

        txResults = new BatchGateway4.ArrayOfTransactionResult();

        

        String userId = UserInfo.getUserId();

        User user = [SELECT Id, cv_pkg_dev_I__Payment_Gateway_Account_ID__c FROM User WHERE Id = :userId];

        system.debug('Nitin formBase====='+formBase);

        system.debug('Nitin form====='+form);

        txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0',user.cv_pkg_dev_I__Payment_Gateway_Account_ID__c);

        system.debug('txResults==>'+txResults);

        if (txResults!=null && txResults.TransactionResult!=null && txResults.TransactionResult.size()>0) {

            system.debug('txResults==>'+JSON.serialize(txResults.TransactionResult[0]));

            return txResults.TransactionResult[0];  

        }

        else

            return null;

    }

    

    

    public List<Solicitor__c> getSotCreditsToUpdate()

    {

        system.debug('<==Inside getSotCreditsToUpdate==>');

        List<Solicitor__c> result = new List<Solicitor__c>();

        for (Solicitor__c s : softCredits){

            if (RollupHelper.IsEmptyOrNull(s.Organization_Solicitor__c) && RollupHelper.IsEmptyOrNull(s.Solicitor__c) && s.Custom_Amount__c==null) {

                continue;

            }

            if (RollupHelper.IsEmptyOrNull(s.Organization_Solicitor__c) && RollupHelper.IsEmptyOrNull(s.Solicitor__c) && s.Custom_Amount__c!=null) {

                s.addError('Soft Credits: Either Individual Solicitor or Organization Solicitor should be entered');

                return null;

            }

            if (!RollupHelper.IsEmptyOrNull(s.Organization_Solicitor__c) && !RollupHelper.IsEmptyOrNull(s.Solicitor__c) && s.Custom_Amount__c!=null) {

                s.addError('Soft Credits: Either Individual Solicitor or Organization Solicitor should be entered, both cannot be entered.');

                return null;

            }

            if ( s.Custom_Amount__c != null && ( s.Custom_Amount__c <= 0 || s.Custom_Amount__c > theGift.Expected_Amount__c ) ) {

                s.addError('Soft Credits: Custom Amount should be a positive value and should not exceed the Transaciton Amount.');

                return null;

            }

            

            result.add(s);

        }

        

        return result;

    }

    

    public List<Gift_Detail__c> getGiftDetailstoUpdate()

    {

        system.debug('<==Inside getGiftDetailstoUpdate==>');

        List<Gift_Detail__c> result = new List<Gift_Detail__c>();

        system.debug('hiiii-------' + theGiftDetails);

        for(Gift_Detail__c gd : theGiftDetails)

        {

            if (RollupHelper.IsEmptyOrNull(gd.New_Campaign__c) && RollupHelper.IsEmptyOrNull(gd.Fund__c) && gd.Amount__c==null) continue;

            

            if (gd.Allocation_Date__c == null) { gd.addError('Allocations: Allocation date is required.'); return null; }

            if (RollupHelper.IsEmptyOrNull(gd.New_Campaign__c)) { gd.addError('Allocations: Allocation Appeal is required'); return null; }

            if (RollupHelper.IsEmptyOrNull(gd.Fund__c)) { gd.addError('Allocations: Allocation Fund is required'); return null; }

            if (gd.Amount__c==null) { gd.addError('Allocations: Allocation Amount is required'); return null; }

            

            RecordType RT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Campaign' AND NamespacePrefix = 'causeview'];

            Campaign cmp = [Select Id, RecordTypeId, Name From Campaign Where Id = :gd.New_Campaign__c];

            //If Appeal record is not of type Appeal or Event, Send Error message.

            if (cmp.RecordTypeId==RT.Id) { gd.addError('Appeal: "' + cmp.Name + '" must be of type Appeal or Event.'); return null; }

            

            result.add(gd);

        }

        

        return result;

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

    

    //** Used to feed Javascript to Dynamicly populate fund when an Appeal is selected ** //  

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

        List<Campaign> camps = [SELECT Id, Name, Letter__c, Letter__r.Name, Fund__c, Fund__r.Name FROM Campaign WHERE Id  = :appealId];

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

        for (Integer i = 0; i < 10; i++)

        {

            options.add(new SelectOption(String.valueOf(Date.Today().Year()+i), String.valueOf(Date.Today().Year()+i)));     

        }                                                                                                                                                                                                                                                                                            

        return options;

    }    

    

    public void addGiftDetail() {
    
        theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));        

    }

    

    public void addSoftCredit() {

        softCredits.add(new Solicitor__c());

    }

    

    public void addPayment() {

        thePayments.add(new Payment__c());

    }

    //added by nitin

    public void addInstallment() {

        theInstallments.add(new cv_pkg_dev_I__Installment__c());
    }

    //till here

    public void removeGiftDetail() {

        Integer count = 0;

        string ind = ApexPages.currentPage().getParameters().get('ind');

        

        Integer selectedIndex = 1;

        if (ind !=null && ind !='') selectedIndex = Integer.valueOf(ind);

        

        for(Gift_Detail__c gd : theGiftDetails)

        {

            count++;

            if (count == selectedIndex ) { theGiftDetails.remove(count-1); break; }

        }

    }    

    //To change value of Receipt field

    public void changeReceipttype(){

        if(theGift.Gift_Type__c == 'Recurring'){

            theGift.cv_pkg_dev_I__Receipt_Type__c = 'Consolidated';

        }

        else{

            theGift.cv_pkg_dev_I__Receipt_Type__c = 'Single Receipt';

        }

    }

    //added by nitin to check exsiting org has currency enabled or not

    public Boolean checkMCEnabled(){

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        Schema.SObjectType mcEnabled = gd.get('CurrencyType');

        system.debug('Nitin mcEnabled=='+mcEnabled);

        return (mcEnabled != null) ? true : false;

    }

    //To get list of enabled currencies in org

    public List<selectOption> getPicklistValues(){

        list<SelectOption> options = new list<SelectOption>();

        string ObjectApi_name = 'CurrencyType';

        String Accountapi = 'Account';

        String Field_name = 'IsoCode';

        String Field_name1 = 'CurrencyIsoCode';

        // Get the object type of the SObject.

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject

        system.debug('Nitin targetType====='+targetType);

        if(targetType != null){

            Sobject Object_name = targetType.newSObject();

            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed

            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject

            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject

            List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject

            Schema.SObjectType targetType1 = Schema.getGlobalDescribe().get(Accountapi);

            Sobject Object_name1 = targetType1.newSObject();

            Schema.sObjectType sobject_type1 = Object_name1.getSObjectType(); //grab the sobject that was passed

            Schema.DescribeSObjectResult sobject_describe1 = sobject_type1.getDescribe(); //describe the sobject

            Map<String, Schema.SObjectField> field_map1 = sobject_describe1.fields.getMap(); //get a map of fields for the passed sobject

            List<Schema.PicklistEntry> pick_list_values1 = field_map1.get(Field_name1).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject

            for (Schema.PicklistEntry a1 : pick_list_values1){

                for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list

                    if(a.getValue() == a1.getValue()){

                        options.add(new SelectOption(a.getValue(), a.getLabel()));

                    }

                }

            }

            system.debug('Nitin====='+options);

            return options;

        }

        return null;

    }

    public PageReference contactFieldSet(){

        System.debug('Contact First Name');

        try{

            if(string.isEmpty(hiddenInputValue)){

            FirstName = '';           

            lastName = '';

            hiddenInputValue='';            

            }

        }catch(Exception ex){}

                return null;

    }

}
