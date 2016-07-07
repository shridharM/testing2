/*
To Display Enhanced Batch Item Interface.
To Help "BatchProcessingInterface" Page to display Batch Item fields from Batch Template.
To Submit "Credit Card and ACH/PAD" Payment on to Payment Gateway.

*/

global with sharing class BatchProcessingController {

    public Batch_Template__c presetTemplate{get;set;}
    public Gift_Batch__c giftBatch{get;set;}

    public List<PresetWrapper> accountFields{get;set;}
    public List<PresetWrapper> contactFields{get;set;}
    public List<PresetWrapper> RecurringGiftFields{get;set;}
    public List<PresetWrapper> TransactionFields{get;set;}
    public List<PresetWrapper> PaymentFields{get;set;}
    public List<PresetWrapper> GiftDetailFields{get;set;}
//    public List<PresetWrapper> eventRegFields{get;set;}
    public List<PresetWrapper> ReceiptFields{get;set;}

    public List<Gift__c> transactions{get;set;}

    public Map<string, string> keyPrefixMap{get;set;}

    public static Id batchId;
    
    public static List<PresetWrapper> contFields;

    public String paymentTypesSelected{get;set;}
    public String batchStatusString{get;set;}
    public Boolean checkBatchStatus {get;set;}
    private BatchPresetHelper_moc obj_BPH;

    //----------------    Report    ----------------- 
    public BatchSettings__c BatchSettings { get; set; }

    //----------------    Payment Processing    -----------------
    public Boolean isSubmitEnabled { get; set; }

    //----------------    User Timezone    -----------------
   Public string userTimezone { get; set; }
    
    
    //----------------    User Locale    -----------------
    Public string userlocale { get; set; }
    
    //---------------- Allocation Event Level Lookup Id ------
    Public String eventLevelLookupId {get; set;}
    
   
//------------------------------------------------------------------------------------------------------------
    public BatchProcessingController(ApexPages.StandardController controller) {
        userTimezone = UserInfo.getTimeZone().getId();
        userlocale = UserInfo.getLocale();
        batchId = ApexPages.currentPage().getParameters().get('batchId');    //get the value of the parameter "batchId" from the current url
               
        system.debug('batchId==>'+batchId);
        obj_BPH = new BatchPresetHelper_moc();
        
        isSubmitEnabled = false;
        
       

        keyPrefixMap = new Map<string, string>();
        keyPrefixMap.put('Fund', causeview__Fund__c.sObjectType.getDescribe().getKeyPrefix());    //Putting 'Fund' as key and getKeyPrefix() Returns the three-character prefix code for the Fund Object in Map
        keyPrefixMap.put('Letter', causeview__Letter__c.sObjectType.getDescribe().getKeyPrefix());    //Putting 'Letter' as key and getKeyPrefix() Returns the three-character prefix code for the Letter Object in Map
        keyPrefixMap.put('Account', Account.sObjectType.getDescribe().getKeyPrefix());    //Putting 'Account' as key and getKeyPrefix() Returns the three-character prefix code for the Account Object in Map
        keyPrefixMap.put('Contact', Contact.sObjectType.getDescribe().getKeyPrefix());    //Putting 'Contact' as key and getKeyPrefix() Returns the three-character prefix code for the Contact Object in Map
        //user story : Event Level look-up doesn't return results
        keyPrefixMap.put('Event Level', causeview__Event_Level__c.sObjectType.getDescribe().getKeyPrefix());    //Putting 'Event Level' as key and getKeyPrefix() Returns the three-character prefix code for the Event Level Object in Map
        keyPrefixMap.put('Allocation', causeview__Gift_Detail__c.sObjectType.getDescribe().getKeyPrefix());    //Putting 'Allocation' as key and getKeyPrefix() Returns the three-character prefix code for the Allocation Object in Map
        keyPrefixMap.put('Appeal',Campaign.sObjectType.getDescribe().getKeyPrefix());
        
        
        accountFields = new List<PresetWrapper>();
        contactFields = new List<PresetWrapper>();
        RecurringGiftFields = new List<PresetWrapper>();
        TransactionFields = new List<PresetWrapper>();
        PaymentFields = new List<PresetWrapper>();
        GiftDetailFields = new List<PresetWrapper>();
//        eventRegFields = new List<PresetWrapper>();
        ReceiptFields = new List<PresetWrapper>();

        //loading the custom settings
        List<BatchSettings__c> settingList = [Select b.GatewayUrl__c, b.CurrencyCode__c, b.BatchFormId__c, b.RegularGiftRecordTypeId__c,
           b.Name, b.BucketAccountId__c, BatchReportId__c 
           From BatchSettings__c b WHERE Name = 'Default'];
        if (settingList != null && settingList.size()>0) {
           BatchSettings = settingList[0];
       }
        
        eventLevelLookupId = getFieldId('Event Level');    //user story : Event Level look-up doesn't return results
        
        try {
            giftBatch = [Select Id, CreatedById, Template_Name__c, Total_Gift__c, Batch_Status__c From Gift_Batch__c Where Id =: batchId ];   //madhu 
            presetTemplate =  [SELECT Id,Name,AccountFieldsXml__c,ContactFieldXml__c,GiftDetailFieldsXml__c,PaymentFieldsXml__c,ReceiptFieldsXml__c,
                        RecurringGiftFieldsXml__c,TransactionFieldsXml__c,EventRegistrationsFieldsXml__c,Type__c,Transaction_Type__c FROM Batch_Template__c
                        Where Id =: giftBatch.Template_Name__c];

            if(presetTemplate != null) {
                populateFields(presetTemplate);

                contFields = new List<PresetWrapper>();
                contFields = contactFields;
            }
            if (giftBatch.Batch_Status__c == 'Closed') {                                //madhu
                batchStatusString = 'Gift Batch is Commited';
                checkBatchStatus = true;
            }
            else {
                batchStatusString = '';
                checkBatchStatus = false;
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() + ' : Please select a proper Batch Template'));
        }


    }
    
    //Create 15 digit Id.
      //-------------------------------------------------------------------------------------------------------------------------
      public string selectedBatchId {
         get {
          string Val = giftBatch.id;
          if (Val != null && Val != '')
           Val = Val.substring(0,Val.length()-3);
          return Val;
         }
      }
  
    
//---------------------------------
    //calling Remote Action method from visualforce page using javascript to fetch prefix of Object. Returns the three-character prefix code for the object. 
    //Record IDs are prefixed with three-character codes that specify the type of the object(for example, accounts have a prefix of 001 and opportunities have a prefix of 006)
    @RemoteAction    
    global static String getLookupPrefix(String objName, String fieldName){
        if(fieldName == 'ConstOrgId') {
            return Schema.getGlobalDescribe().get(objName).getDescribe().getKeyPrefix();    //Returning the three-character prefix code for the object
        }
        return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe().getReferenceTo()[0].getDescribe().getKeyPrefix();    //Returning the three-character prefix code for the lookup field object
    }



//-----------------------------------------------------------------------------------
    //calling remote action to find the relationalcontacts    //madhu
   /* @RemoteAction
    global static Boolean getRelation(string contactId){
       Set<Id> contactIds = new Set<Id>();
       contactIds.add(contactId);
       List<npe4__Relationship__c> relationships = [SELECT Id, npe4__Contact__c, npe4__RelatedContact__c 
       FROM npe4__Relationship__c WHERE npe4__Contact__c IN :contactIds 
       AND causeview__Apply_Soft_Credit__c=true AND npe4__RelatedContact__c !=null]; 
    }*/
    
    
//----------------------------------------------------------------------------------------------------------------------------------------
    //Serializing accountFields,contactFields,RecurringGiftFields,TransactionFields,PaymentFields,GiftDetailFields,
    //ReceiptFields,SoftCreditFields into JSON content.
    public String getAccountFieldArray() {
        return JSON.serialize(accountFields);
    }
    public String getContactFieldArray() {
        return JSON.serialize(contactFields);
    }

    public String getRecurringGiftFieldArray() {
        return JSON.serialize(RecurringGiftFields);
    }

    public String getTransactionFieldArray() {
        return JSON.serialize(TransactionFields);
    }

    public String getPaymentFieldArray() {
        return JSON.serialize(PaymentFields);
    }

    public String getGiftDetailFieldArray() {
        return JSON.serialize(GiftDetailFields);
    }

    public String getReceiptFieldArray() {
        return JSON.serialize(ReceiptFields);
    }

    public String getSoftCreditFieldArray() {
        List<PresetWrapper> SoftCreditFields = obj_BPH.discribeObjects('causeview__Solicitor__c');
        return JSON.serialize(SoftCreditFields);
    }

//------------------------------------------------------------------------------------------------------------
    //populate all field, field type and default values from template 
    private void populateFields(Batch_Template__c presetTemplate) {
        if(contactFields.size() == 0) {
            contactFields = obj_BPH.readXML(presetTemplate.ContactFieldXml__c, 'Contact');
        }
        if(accountFields.size() == 0) {
            accountFields = obj_BPH.readXML(presetTemplate.AccountFieldsXml__c, 'Account');
        }
        if(RecurringGiftFields.size() == 0) {
            RecurringGiftFields = obj_BPH.readXML(presetTemplate.RecurringGiftFieldsXml__c, 'causeview__Recurring_Donation__c');
        }
        if(TransactionFields.size() == 0) {
            TransactionFields = obj_BPH.readXML(presetTemplate.TransactionFieldsXml__c, 'causeview__Gift__c');
        }
        if(PaymentFields.size() == 0) {
            PaymentFields = obj_BPH.readXML(presetTemplate.PaymentFieldsXml__c, 'causeview__Payment__c');
            paymentTypesSelected = obj_BPH.paymentTypesSelected;
        }
        if(ReceiptFields.size() == 0) {
            ReceiptFields = obj_BPH.readXML(presetTemplate.ReceiptFieldsXml__c, 'causeview__Receipt__c');
        }
        if(GiftDetailFields.size() == 0) {
            GiftDetailFields = obj_BPH.readXML(presetTemplate.GiftDetailFieldsXml__c, 'causeview__Gift_Detail__c');
        }
    }

//------------------------------------------------------------------------------------------------------------
    //serailizing the response into JSON format
    public String getAllBatchItems() {
        causeview__Gift__c gift = new causeview__Gift__c();
        String JSONString = JSON.serialize(gift);//This is how we can serailize our response into JSON format
        return '{\"Records\":' +JSONString+', \"error\": \"null\", \"status\":\"SUCCESS\", \"count\":\"' + 1 + '\" }';
    }

    //Remote Action to get data for recordId, fields, object Name, field Name by passing these values in javascript from visualforce page 
    @RemoteAction
    global static sObject getData(String recordId, String fields, String objName, String fieldName) {
        String query = 'Select Id' + fields + ' From ' + objName + ' Where ' + fieldName + ' = :recordId';    //Creating a soql query for the values passed from visualforce page

        sObject obj = null;
        try {    
            obj = database.query(query);    //fetching data from database for the query
        } catch(Exception ex) {
            return obj;
        }
//        Contact con = [Select Id, Name From Contact Where Id = :recordId];
        
//        String JSONString = JSON.serialize(recordId);
        
//        return '{\"Records\":' +JSONString+', \"error\": \"null\", \"status\":\"SUCCESS\", \"count\":\"' + 1 + '\" }';
        return obj;
    }
    
    
    //To process payments. Passing values in method from visualforce page to process payments.
    @RemoteAction
  global static string submitPayment(String giftBatchId, String giftPaymentUIFieldsMap)
  {
//        return 'test';
        
        //loading the custom settings
        BatchSettings__c BatchSettings;
        List<BatchSettings__c> settingList = [Select b.GatewayUrl__c, b.CurrencyCode__c, b.BatchFormId__c, b.RegularGiftRecordTypeId__c,
           b.Name, b.BucketAccountId__c, BatchReportId__c 
           From BatchSettings__c b WHERE Name = 'Default'];
        if (settingList != null && settingList.size()>0) {
           BatchSettings = settingList[0];
        }

        Map<String, String> accountTypeMap = new Map<String, String>();
        accountTypeMap.put('Personal Checking', 'PC');
        accountTypeMap.put('Personal Savings', 'PS');
        accountTypeMap.put('Business Checking', 'BC');
        accountTypeMap.put('Business Savings', 'BS');

        BatchGateway4.GatewaySoap gw = new BatchGateway4.GatewaySoap();    //creating Instance of BatchGateway4.GatewaySoap apex class
        gw.timeout_x = 120000;                                           

        //set the endpoint
        gw.endpoint_x = BatchSettings.GatewayUrl__c;
        BatchGateway4.BatchForm form = new BatchGateway4.BatchForm();
        BatchGateway4.FormBase formBase = new BatchGateway4.FormBase();
        form.payments = new BatchGateway4.ArrayOfPaymentInfo();
        form.payments.payment = new List<BatchGateway4.PaymentInfo>();
        formBase.currency_x = BatchSettings.CurrencyCode__c;
        formBase.formId = batchSettings.BatchFormID__c;
        formBase.version = '1.0';
        formBase.debugMode = true;
                
        //Convert JSON Payment UI fields Map to APEX Map.
        Map<String, Map<String, String>> paymentUIFieldsMap;
        System.debug('####### giftPaymentUIFieldsMap  ########' + giftPaymentUIFieldsMap);
        if(giftPaymentUIFieldsMap != null) {        
            paymentUIFieldsMap = (Map<String, Map<String, String>>)JSON.deserialize(giftPaymentUIFieldsMap, Map<String, Map<String, String>>.class);
            System.debug('####### paymentUIFieldsMap  ########' + paymentUIFieldsMap);
        }

        if(paymentUIFieldsMap == null) {
            return null;
        }

        /*    CCNumber,expirationDate,Cvv    */
        //Fetching causeview__GiftBatch__c record for the giftBatchId passed from visualforce page
        List<causeview__Gift__c > giftItems = [Select Id,Batch_Status__c,Constituent__c,Organization__c,Gift_Type__c,Expected_Amount__c,
                                                Constituent__r.MailingStreet,Constituent__r.MailingCity,Constituent__r.MailingState,Constituent__r.MailingCountry,
                                                    Constituent__r.MailingPostalCode,Constituent__r.Email,Constituent__r.Phone,Constituent__r.FirstName,Constituent__r.LastName,
                                                Organization__r.BillingStreet,Organization__r.BillingCity,Organization__r.BillingState,Organization__r.BillingCountry,
                                                    Organization__r.BillingPostalCode,Organization__r.Email__c,Organization__r.Phone,Organization__r.Name,
                                                Recurring_Donation__r.Start_Date__c,Recurring_Donation__r.of_Payments__c,Recurring_Donation__r.Frequency__c,
                                                (Select Id,Amount__c, Payment_Type__c,Status__c,Credit_Card_Type__c, Account_Number__c,Cheque_Num__c,Routing_Branch_Number__c,
                                                    Account_Type__c,Bank_Name__c From Recurring_Payments__r) 
                                            From causeview__Gift__c Where Id IN : paymentUIFieldsMap.keySet()];    //causeview__GiftBatch__c =: giftBatchId AND 


        if (giftItems != null)
        {
            for (causeview__Gift__c gift : giftItems)
            {
                Integer paymentSize = gift.Recurring_Payments__r.size() - 1;
                System.debug('####### paymentSize  ########' + paymentSize);
                System.debug('####### gift  ########' + gift);
                Map<String, String> pUIFieldMap = paymentUIFieldsMap.get(gift.Id);
                System.debug('####### pUIFieldMap  ########' + pUIFieldMap);

                if(pUIFieldMap == null) continue;

                //if (processed >= maxItemPerBatch) break;
                /*if (gift.Batch_Status__c == 'Committed' || gift.Batch_Status__c == 'Receipted') continue;*/
                
                 if (paymentSize != -1 && (gift.Recurring_Payments__r[paymentSize].Payment_Type__c != 'Credit Card' && gift.Recurring_Payments__r[paymentSize].Payment_Type__c != 'ACH/PAD')) {
                        if (gift.Batch_Status__c == 'Pending')
                        {
                            gift.Batch_Status__c = 'Committed';
                            gift.Recurring_Payments__r[paymentSize].Status__c = 'Approved';
                        }
                    }
                /*else if (paymentSize  == -1)
                    {
                      gift.Batch_Status__c = 'Committed';
                    }*/
                else {
                    if (paymentSize  == -1)
                    {
                      gift.Batch_Status__c = 'Committed';
                    }
                    system.debug('Inside else');
                    BatchGateway4.PaymentInfo payment = new BatchGateway4.PaymentInfo();
                    if (paymentSize != -1 && gift.Recurring_Payments__r[paymentSize].Payment_Type__c == 'Credit Card') {
                        if (pUIFieldMap !=null && ( pUIFieldMap.get('CCNumber') == null || pUIFieldMap.get('CCNumber') == '' || pUIFieldMap.get('Pay_Expiry_Date__x') == null || pUIFieldMap.get('Pay_Expiry_Date__x') == ''))
                        {
                            system.debug('*** Gift Failed. Status: ' + gift.Batch_Status__c);
                            gift.Batch_Status__c = 'Failed';
    //                        ResetCreditCardInfo(gift);
                            System.debug('800: Invalid Credit Card Information');
                            continue;
                        } else {
                            //credit card detail
                            payment.creditCardNumber = pUIFieldMap.get('CCNumber');
                            payment.creditCardType = gift.Recurring_Payments__r[paymentSize].Credit_Card_Type__c;
                            payment.cvv2 = pUIFieldMap.get('Pay_Security_Code__x');
                            if(pUIFieldMap.get('Pay_Expiry_Date__x') != null && pUIFieldMap.get('Pay_Expiry_Date__x').length() > 3) {
                                payment.expiryMonth = tryParseToInt(pUIFieldMap.get('Pay_Expiry_Date__x').substring(0,2));
                                payment.expiryYear = tryParseToInt(pUIFieldMap.get('Pay_Expiry_Date__x').substring(2,4));
                            }
                        }
                    }
                    else if(paymentSize == -1)
                    {
                         payment.creditCardNumber = pUIFieldMap.get('CCNumber');
                         //payment.creditCardType = gift.Recurring_Payments__r[paymentSize].Credit_Card_Type__c;
                            payment.cvv2 = pUIFieldMap.get('Pay_Security_Code__x');
                            if(pUIFieldMap.get('Pay_Expiry_Date__x') != null && pUIFieldMap.get('Pay_Expiry_Date__x').length() > 3) {
                                payment.expiryMonth = tryParseToInt(pUIFieldMap.get('Pay_Expiry_Date__x').substring(0,2));
                                payment.expiryYear = tryParseToInt(pUIFieldMap.get('Pay_Expiry_Date__x').substring(2,4));
                              }
                    }
                    if ( paymentSize != -1 && gift.Recurring_Payments__r[paymentSize].Payment_Type__c == 'ACH/PAD') {    //false && 
                        system.debug('<=Inside ACH=>');
                        //    ACH/PAD detail
                        payment.paymentType = 'ACH';
                        payment.bankAccountNumber = pUIFieldMap.get('ACHAccountNo');
                        payment.BankRoutingNumber = gift.Recurring_Payments__r[paymentSize].Routing_Branch_Number__c;
                        if(accountTypeMap.get(gift.Recurring_Payments__r[paymentSize].Account_Type__c) != null){
                            payment.bankAccountType = accountTypeMap.get(gift.Recurring_Payments__r[paymentSize].Account_Type__c);
                        }
                        else{
                            payment.bankAccountType = '';
                        }
                        //payment.banckName = gift.Recurring_Payments__r[paymentSize].Bank_Name__c;
                        //payment.banckCity = pUIFieldMap.get('Pay_Branch_City__x');
                        //payment.bankCountry = pUIFieldMap.get('Pay_Bank_Country__x');
//                        payment.checkNumber = gift.Recurring_Payments__r[paymentSize].Cheque_Num__c;
                        payment.checkNumber = '';
                    }
                    else if(paymentSize == -1){
                         payment.paymentType = 'ACH';
                        payment.bankAccountNumber = pUIFieldMap.get('ACHAccountNo');  
                    }
                    //payment for Individual
                    if (gift.Constituent__c != null)
                    {
                        payment.address1 = gift.Constituent__r.MailingStreet;
                        payment.city = gift.Constituent__r.MailingCity;
                        payment.state = gift.Constituent__r.MailingState;
                        payment.country = gift.Constituent__r.MailingCountry;
                        payment.zipCode = gift.Constituent__r.MailingPostalCode;
                        payment.donationType = 'IND';
                        payment.email = gift.Constituent__r.Email;
                        payment.phone = gift.Constituent__r.Phone;
                        //payment.PayerFirstName = gift.constituent.FirstName;
                        //payment.PayerLastName = gift.constituent.LastName;
                    }
                    else    //payment for Organisation
                    {
                        payment.address1 = gift.Organization__r.BillingStreet;
                        payment.city = gift.Organization__r.BillingCity;
                        payment.state = gift.Organization__r.BillingState;
                        payment.country = gift.Organization__r.BillingCountry;
                        payment.zipCode = gift.Organization__r.BillingPostalCode;
                        payment.donationType = 'ORG';
                        payment.email = gift.Organization__r.Email__c;
                        payment.phone = gift.Organization__r.Phone;
                        payment.organization = gift.Organization__r.Name;
                    }
                    if (gift.Gift_Type__c == 'Recurring')    
                    {
                        //gift.Recurring_Donation__r.Start_Date__c
                        payment.billingStartDate = date.valueOf(pUIFieldMap.get('billingStartDate'));    //For recurring type gift payment billing start date will be Recurring Gift start date
                    }
                    else
                    {
                        payment.billingStartDate = date.today();    //For other type of gift records billingStartDate it will be the date of that day.
                    }
                    payment.numberOfPayments = '';
                    if (pUIFieldMap.get('of_Payments__c') != null)
                    {
                        payment.numberOfPayments = pUIFieldMap.get('of_Payments__c');    //gift.Recurring_Donation__r.of_Payments__c.format();
                    }
                      
                    payment.PayerFirstName = gift.Constituent__r != null ? (gift.Constituent__r.FirstName != null ? gift.Constituent__r.FirstName  : '') : ( pUIFieldMap.get('RecGift_First_Name') != null ? pUIFieldMap.get('RecGift_First_Name') : '');
                    payment.PayerLastName = gift.Constituent__r != null ? gift.Constituent__r.LastName : (pUIFieldMap.get('RecGift_Last_Name') != null ? pUIFieldMap.get('RecGift_Last_Name') : '');
                    payment.isIndividual = gift.Constituent__c == null ? false : true;
                    payment.isRecurring = gift.Gift_Type__c == 'Recurring' ? true : false;
                    payment.constituentType = pUIFieldMap.get('isNewRecord');
                    //System.debug(gift.Recurring_Payments__r[paymentSize].Amount__c);
                    //System.debug(gift.Recurring_Payments__r[paymentSize].Amount__c.format());
                    if (gift.Expected_Amount__c != null) {
                        payment.amount = gift.Expected_Amount__c.format();
                    }
                    else {
                        payment.amount = '0';
                    }
                    
                    payment.currencyType = BatchSettings.CurrencyCode__c;
                    payment.frequency = pUIFieldMap.get('Frequency__c');    //gift.Recurring_Donation__r.Frequency__c;
                    payment.giftId = gift.Id;
                    if(gift.Recurring_Payments__r.size() != 0 ) {
                        payment.paymentId = gift.Recurring_Payments__r[paymentSize].Id; }
                        
                    form.payments.payment.add(payment);
                    System.debug('<==payment==>'+payment);
                }
            }
        }
                BatchGateway4.ArrayOfTransactionResult txResults = new BatchGateway4.ArrayOfTransactionResult();
                System.debug(form.payments);



                System.debug('####### formBase  ########' + formBase);
                System.debug('####### form  ########' + form);
                
                String userId = UserInfo.getUserId();
                User user = [SELECT Id, causeview__Payment_Gateway_Account_ID__c FROM User WHERE Id = :userId];
                
                txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0', user.causeview__Payment_Gateway_Account_ID__c);

                System.debug('####### txResults  ########' + txResults);
                System.debug('####### txResults.TransactionResult  ########' + txResults.TransactionResult);
                System.debug('####### JSON.serialize(txResults.TransactionResult)  ########' + JSON.serialize(txResults.TransactionResult));

                String res = JSON.serialize(txResults.TransactionResult); 

                return res;       
//                return '{\"Records\":' +JSON.serialize(txResults.TransactionResult)+', \"error\": \"null\", \"status\":\"SUCCESS\", \"count\":\"' + 1 + '\" }';
  }

    WebService static String submitPayment1(String giftBatchId, String giftPaymentUIFieldsMap) {
        return BatchProcessingController.submitPayment(giftBatchId, giftPaymentUIFieldsMap);    
    }


    //To redirect on visualforce page after save a record
    public PageReference postSave()
    {
        //System.debug('######## giftBatch.Id #######' + giftBatch.Id);
        PageReference pageRef = new PageReference('/apex/BatchTransaction?id=' + giftBatch.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    //To enable submit on visualforce page
    public void enableSubmit() {
        isSubmitEnabled = true;
    }
  

  
  public static integer tryParseToInt(String txt)
  {
     integer result = 0;
     try
     {
        result = integer.valueOf(txt);
     }
     catch(Exception ex)
     {
        //do nothing
     }
     
     return result;
  }
    
    public static string getFieldId(String field_label){    //user story : Event Level look-up doesn't return results
        // Obtain the magic ids
        PageReference p = new PageReference('/' + causeview__Gift_Detail__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1');
        String html;
        if(!test.isrunningtest()){
            html = p.getContent().toString();
        }else{
            html = 'test content';
        }
        Map<String, String> labelToId = new Map<String, String>();
        Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
        while (m.find()) {
            String label = m.group(3);
            String id = m.group(1);
            system.debug('Nitin Id===='+id);
            if(label.equalsIgnoreCase(field_label))
                return id; // return field Id.
        }
        return '';
    }

}
