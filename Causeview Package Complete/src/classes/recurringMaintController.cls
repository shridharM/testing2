public with sharing class recurringMaintController {
    
    public string recurringDonationId { get; set; }
    public Recurring_Donation__c recurringDonation { get; set; }
    public integer wizardStep { get; set; }
    public string recurringAction { get; set; }
    
    //administration
    public boolean isValid { get; set; }
    
    //meta data
    public string ccName { get; set; }
    public string ccType { get; set; }
    public string ccNumber { get; set; }
    public integer expirationMonth { get; set; }
    public integer expirationYear { get; set; }
    public string securityCode { get; set; }
    public causeview__App_Settings__c settings { get; set; }
    
    //contructor
    public recurringMaintController()
    {
        wizardStep = 1;
        recurringDonationId = ApexPages.currentPage().getParameters().get('id');
        if (ApexPages.currentPage().getParameters().get('action')=='cancel') {
           wizardStep = 3;
           recurringAction = '1';
        } else if (ApexPages.currentPage().getParameters().get('action')=='shortupdate') {
           recurringAction = '5';
        } else {
            recurringAction = '0';
        }   
        settings = causeview__App_Settings__c.getInstance();
    }
    
    public PageReference init()
    {
       isValid = false;
       List<Recurring_Donation__c> rds = [SELECT Id, Name, Name_on_Card__c, Reference__c, Type__c, Status__c,causeview__Encrypted_Key__c FROM Recurring_Donation__c WHERE Id = :recurringDonationId ];
       if (rds!=null && rds.size()>0)
       {
         recurringDonation = rds[0];
       }
       
       isValid = (recurringDonation != null && recurringDonation.Status__c =='Active');
       //isValid = (recurringDonation != null && recurringDonation.Type__c == 'Credit Card' && recurringDonation.Status__c =='Active');
       
       //update CC info operation
       if (!isValid && recurringAction == '0')
       {
          apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The record does not meet the criteria for this operation. It may not be Active or type may not be Credit Card'));
          wizardStep = 2;
       }
       
       if (!isValid && recurringAction == '1')
       {
            apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The record does not meet the criteria for this operation. It may not be Active recurring.'));
            wizardStep = 2;
       }
     
       return null;
         
    }
    
    public List<SelectOption> getYearItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Year-'));
        
        Date d = Date.Today();
        integer year = d.year();
        for(integer i=year; i<year+10; i++)
        {
           string val = i.format().replaceAll(',','');
           options.add(new SelectOption(val, val));
        }
        return options;
    }

  /*
    public PageReference submit()
    {
       // validation
       if (RollupHelper.IsEmptyOrNull(ccNumber))
       {
           apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Card Number is required.'));
           return null;
       }
       if (RollupHelper.IsEmptyOrNull(ccType))
       {
          apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Card Type is required.'));
          return null;
       }
       if (expirationMonth==null || expirationYear==null)
       {
          apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Expiration date is required.'));
          return null;
       }
       if (recurringDonation == null)
       {
          apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: the record is not found or deleted!'));
          return null;
       }
       
       Date expiryDate = Date.newinstance(expirationYear, expirationMonth, 1);
       if (Date.today() > expiryDate)
       {
          apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: invalid expiration date!'));
          return null;
       }
       
       // call gateway
       try
       {
        BatchGateway3.TransactionResult result = null;
        if (!System.Test.isRunningTest())
        {
            //submit to gateway
            BatchGateway3.GatewaySoap gateway = RollupHelper.newGPServiceInstance();
            result = gateway.UpdateRecurringProfile(recurringDonation.Reference__c, ccNumber, expirationMonth, expirationYear, securityCode, ccType);
            if (result.Errors != null && result.Errors.ErrorMessages != null && result.Errors.ErrorMessages.size()>0)
            {
               List<BatchGateway3.ErrorMessages> msgs = result.Errors.ErrorMessages;
               for(BatchGateway3.ErrorMessages msg : msgs)
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg.ErrorCode + ' : '+ msg.Error ));
                 
               return null;
            }   
        }
        
        //post update 
        recurringDonation.Name_on_Card__c = ccName;
        recurringDonation.Credit_Card_Expiry_Date__c = Date.newinstance(expirationYear, expirationMonth, 1);
        recurringDonation.Credit_Card__c = RollupHelper.maskCardNumber(ccNumber);
        recurringDonation.Credit_Card_Type__c = ccType;
        update recurringDonation;
        
        //new activity
        Task t = new Task();
        t.Subject = 'Credit Card Updated';
        t.ActivityDate = Date.Today();
        t.Description = (result!=null)? result.TransactionStatus : ''; 
        t.Description += '\n\n New card holder name:'+ ccName;
        t.Description += '\n Credit card type:'+ ccType;
        t.Description += '\n Credit card number:'+ RollupHelper.maskCardNumber(ccNumber);
        t.Description += '\n Expiration date:'+ recurringDonation.Credit_Card_Expiry_Date__c.format();
        t.WhatId = recurringDonation.Id;
        t.Status = 'Completed';
        insert t;
        
       }
       catch(Exception ex)
       {
          ApexPages.addMessages(ex);
          return null;
       }
       
       wizardStep = 2;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'The credit card information is sucessfully updated.' ));
       return null;
    } */
    
    
    public PageReference cancel()
    {
      string retUrl = '/'+recurringDonationId;
      PageReference pageRef = new PageReference(retUrl);
      pageRef.setRedirect(true);
      return pageRef;
    }
    
/*
    static testMethod void testMe()
    {
        recurringMaintController cnt = new recurringMaintController();
        
        cnt.recurringDonationId = 'notid';
        cnt.init();
        cnt.getYearItems();
        cnt.cancel();
    }   
*/
}