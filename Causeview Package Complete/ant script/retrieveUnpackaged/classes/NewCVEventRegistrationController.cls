public class NewCVEventRegistrationController {   
    // ** Standard Objects  ** //
  
    public Gift__c theGift { get; set; }
    public Payment__c thePayment { get; set; }
    public Receipt__c theReceipt { get; set; }
    public Recurring_Donation__c theRecurring { get; set; }
    
    public List<Gift_Detail__c> theGiftDetails { get; set; }
    public List<Solicitor__c> softCredits { get; set; }    
    public Contact theIndividual { get; set; }
    public Account theOrg { get; set; }    
    public boolean isOrg { get; set; }
    private string authToken { get; set; }
    
    public string payment_structure { get; set; }    
    public string default_payment_status { get; set; }    
    public string per_payment_amount { get; set; }        
    public string ccExpM { get; set; }
    public string ccExpY { get; set; }    
    public string ccCVV { get; set; }
    public boolean shouldSubmit { get; set; }
    public boolean shouldInsertReceipt { get; set; }
    
    public static string TestContactId { get; set; }
    //** API  **//
    //private Causeview_REST_API api { get; set; }
    //public Actionpage batch_form { get; set; }
    
    /** Used for Fund Lookup Override **/
    public string FundKeyPrefix { get; set; }
    
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
    
    //added by shridhar....
    public list<campaign> theEvent { get; set; }
    public cv_pkg_dev_I__Event_Level__c theEventLevel { get; set; }
    public list<cv_pkg_dev_I__Event_Level__c> theEventLevelsList { get; set; }
    public string evenName{get;set;}
    public list<eventLevelsWrapperClass> eventLevelsWrappers{get;set;}
    public decimal totalAmount{get;set;}
    //till here
    
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
    
    public NewCVEventRegistrationController(ApexPages.StandardController controller) {
        /** Setting Fieldsets in Constructor **/
        Schema.DescribeSObjectResult fund = cv_pkg_dev_I__Fund__c.sObjectType.getDescribe();
        FundKeyPrefix = fund.getKeyPrefix();    
        setAllocationFieldList();
        setPaymentFieldList();
        
        /** Initialization **/
        theGift = new Gift__c();
        
        string cId = System.currentPagereference().getParameters().get('cid');
        if (cId == null) cId = TestContactId;
        InitializeContact(cId);
        //added by nitin
        cv_pkg_dev_I__App_Settings__c appSetting = cv_pkg_dev_I__App_Settings__c.getInstance();
        
        shouldInsertReceipt = false;
        
        multiCurrenyEnable = checkMCEnabled();
    	//added by shridhar
        
       theEventLevel = new cv_pkg_dev_I__Event_Level__c();
        theEventLevelsList=new list<cv_pkg_dev_I__Event_Level__c>();

    }
    
    public void InitializeContact(string contactId)
    {
        system.debug('<==Inside InitializeContact==>');
        shouldSubmit = false;
        
        isOrg = contactId.startsWith('001');
        
        if (isOrg) {
            List<Account> contacts = [SELECT BillingStreet, Email__c, BillingCity, BillingPostalCode,Phone, BillingState, BillingCountry, Name, Id FROM Account WHERE Id = :contactId];
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
        
        if (!isOrg) {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Constituent__c = theIndividual.Id);
        }
        else {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Organization__c  = theOrg.Id);
        }        
        
        
        
        
    }       
    
    
    
    public PageReference Submit() {
        return null;
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
    
    
    
    //vg edit 
    
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
    
    
    
    //added by nitin to check exsiting org has currency enabled or not
    public Boolean checkMCEnabled(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType mcEnabled = gd.get('CurrencyType');
        system.debug('Nitin mcEnabled=='+mcEnabled);
        return (mcEnabled != null) ? true : false;
    }
    //To get list of enabled currencies in org
    
    //Extended
     public PageReference eventLevels() {
         system.debug('----level-'+evenName );
         eventLevelsWrappers =new list<eventLevelsWrapperClass>();
         theEventLevelsList = [select id, Name, Level_Price__c  from cv_pkg_dev_I__Event_Level__c where cv_pkg_dev_I__Event__c=: evenName ];
         for(cv_pkg_dev_I__Event_Level__c eventLevelTemp :  theEventLevelsList){
            eventLevelsWrappers.add(new eventLevelsWrapperClass(eventLevelTemp)); 
         }
        return null;
    }
    
    public class eventLevelsWrapperClass{
        public string Quantity{get;set;}
         public cv_pkg_dev_I__Event_Level__c eventLevel{get;set;}
        
        public eventLevelsWrapperClass(cv_pkg_dev_I__Event_Level__c EL){
            eventLevel=EL;
            Quantity='';
        }
        
        
    }
    
}