public class MatchingControllerExtension {

    public Gift__c theGift { get; set; }
    public Gift__c origGift { get; set; }
    public Payment__c thePayment { get; set; }
    public Receipt__c theReceipt { get; set; }
    public string pType { get; set; }
    public string ccExpM { get; set; }
    public string ccExpY { get; set; }    
    public string ccCVV { get; set; }
    public List<Gift_Detail__c> theGiftDetails { get; set; }
    public boolean createReceipt { get; set; }
    public boolean isMatched { get; set; }   

    public MatchingControllerExtension(ApexPages.StandardController controller) {         
         origGift = [SELECT Id, Expected_Amount__c, Constituent__c, Gift_Type__c, Gift_Date__c FROM Gift__c WHERE Id = :controller.getId() ];
         theGift = [SELECT Id, Expected_Amount__c, Constituent__c, Gift_Type__c, Gift_Date__c FROM Gift__c WHERE Id = :origGift.Id ][0].clone(false, true, false, false);      
         RecordType rt = [select id, name from RecordType where SobjectType='cv_pkg_dev_I__Gift__c' AND name='Matching Gift'];               
         theGift.RecordTypeId = rt.Id;
         theGift.Gift_Date__c = Date.Today();
         theGift.Constituent__c = null;
         theGift.Organization__c = null;         
         thePayment = new Payment__c();
         thePayment.Payment_Type__c = '';
         theGiftDetails = new List<Gift_Detail__c>();
         for (Gift_Detail__c gd : [SELECT Name, Tribute__c, Product__c, Fund__c, Fund_Name__c, Id, Approved_Amount__c, Amount__c, New_Campaign__r.Name, Parent_Appeal__c, Campaign__r.Name, Allocation_Date__c FROM Gift_Detail__c WHERE Gift__c = :origGift.Id ])
         {   
             Gift_Detail__c nGD = new Gift_Detail__c();
             nGD = gd.clone(false, true, false, false);
             nGD.Allocation_Date__c = Date.Today();
             theGiftDetails.add(nGD);   
         }
         theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued');   
        List<Gift__c> theGifts = [SELECT Id FROM Gift__c WHERE Matched_Gift__c = :origGift.Id];
        
        isMatched = theGifts.size() > 0;
        
        if (isMatched)
        { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This Transaction has previously been Matched'));
        }              
    }
    
    public List<SelectOption> getPTypes() {
        List<SelectOption> options = new List<SelectOption>();  
        options.add(new SelectOption('-- None --', '-- None --'));
        options.add(new SelectOption('Credit Card', 'Credit Card'));
        options.add(new SelectOption('Credit Card - Offline', 'Credit Card - Offline'));
        options.add(new SelectOption('Check', 'Check'));
        options.add(new SelectOption('Cash', 'Cash'));
        options.add(new SelectOption('Stock', 'Stock'));
        options.add(new SelectOption('Other', 'Other'));                                                                                                                                                                                                                                                                                              
        return options;
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
        for (Integer i = 0; i < 5; i++)
        {
            options.add(new SelectOption(String.valueOf(Date.Today().Year()+i), String.valueOf(Date.Today().Year()+i)));     
        }                                                                                                                                                                                                                                                                                            
        return options;
    }    
    
    public PageReference Submit() {
        //Validation
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'At least '));
        if(pType == '-- None --'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Select Payment Type'));
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        theGift.Matched_Gift__c = origGift.Id;
        theGift.Status__c = 'Entered';
        insert theGift;
        thePayment.Donation__c = theGift.Id;
        thePayment.Amount__c = theGift.Expected_Amount__c;
        thePayment.Status__c = 'Approved';
        thePayment.Payment_Type__c = pType;
        insert thePayment;
        for (Gift_Detail__c gd : theGiftDetails)
        {
            gd.Payment__c = thePayment.Id;
            gd.Gift__c = theGift.Id;
        }
        system.debug('theGiftDetails==>'+theGiftDetails);
        insert theGiftDetails;
        if (createReceipt)
        {
            theReceipt.Gift__c = theGift.Id;
            insert theReceipt;
        }
        
        Solicitor__c softCredit = new Solicitor__c(Solicitor__c = origGift.Constituent__c, Gift__c = theGift.Id);
        insert softCredit;
        
        PageReference pr = new ApexPages.StandardController(theGift).view();
        pr.setRedirect(true);
        
        return pr;
    }    
    
}