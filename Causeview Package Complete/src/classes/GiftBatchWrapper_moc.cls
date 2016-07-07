public with sharing class GiftBatchWrapper_moc {

    public boolean isIndividualGift { get; set; }
    public boolean isRecurring {get; set;}
    
    //identifier
    public String id { get; set; }
    public Account account { get; set; }
    public Contact constituent { get; set; }
    public Gift__c gift { get; set; }
    public Recurring_Donation__c recurringDonation { get; set; }
    public List<Gift_Detail__c> giftDetails { get; set; }
    public List<RD_Allocation__c> rdGiftDetails { get; set; }
    public Payment__c payment { get; set; }
    public Receipt__c receipt { get; set; }
    public Note giftNote { get; set; }
    public String noteSubject { get; set; }
    public String noteBody { get; set; }
    public Gift_Detail__c giftDetail { get; set; }
    public RD_Allocation__c rdGiftDetail { get; set; }
    
    // CC Info for CC Batch entries
    public String CCNumber {get; set;}
    public String CCName { get; set;}
    public String expirationDate { get; set; }
    public String Cvv { get; set; }
    public String cardholderFirstName { get; set; }
    public String cardholderLastName { get; set; }
    public boolean isNewRecord { get; set; }
   
    //presets related data
    public GiftBatchPresets presets { get; set; }
    public User user { get; set; }
   
    public string SaveTitle {
        get
        {
            string retVal = 'Save';
            try
            {
                if (gift != null && payment != null && gift.Batch_Status__c == 'Failed' && payment.Payment_Type__c == 'Credit Card')
                    retVal = 'Resubmit';
                
            }
            catch (Exception ex)
            {
            }
            return retVal;
        }
   }
   //---------------------------------------------------------------------------------------------------------
   public GiftBatchWrapper_moc() {
       
       isIndividualGift = true;
       isRecurring = false;
       account = new Account();
       constituent = new Contact();
       gift = CreateGiftInstance();
       
       recurringDonation = new Recurring_Donation__c();
       giftDetails = new List<Gift_Detail__c>();
       giftDetail = new Gift_Detail__c();
       rdGiftDetails = new List<RD_Allocation__c>();
       rdGiftDetail = new RD_Allocation__c();
       payment = new Payment__c();
       giftNote = new Note();
       receipt = new Receipt__c();
       noteSubject = '';
       noteBody = '';
       Cvv = '';
       isNewRecord = false;
       id =  'NotSavedYet-' + DateTime.now().format('hmmss');
       //presets = new GiftBatchPresets();
   }
   //---------------------------------------------------------------------------------------------------------
   public string SaveAndNewTitle {
        get
        {
            string retVal = 'Save & New';
            try {
                if (gift != null && payment != null && gift.Batch_Status__c == 'Failed' && payment.Payment_Type__c == 'Credit Card') 
                    retVal = 'Resubmit & New';
            }
            catch (Exception ex) { }
            return retVal;
        }
   }
   //---------------------------------------------------------------------------------------------------------
   public void loadDefaults() {
      
      if (presets==null) {
          if (user == null)
            user = GiftBatchPresets.GetPresetsData();
          presets = new GiftBatchPresets(user);
      } 
      //presets.load(this);
   }
   
   //---------------------------------------------------------------------------------------------------------
   public void clearDefaults() {
      if (presets != null)
       presets.ClearDefaults();
   } 
   //---------------------------------------------------------------------------------------------------------
   public void saveDefaults() {
      //if (presets != null)
        //presets.save(this);
   } 
   
   
   //---------------------------------------------------------------------------------------------------------
   public String getUniqueId() {
      if (gift == null) return '';
      
      string retVal = '';
      string giftNumber = gift.Name;
      if (giftNumber == null || giftNumber == '')
      {
          //refresh gift
          Gift__c g = loadGiftRecord(gift.Id);
          if (g != null) {
           gift = g;
           giftNumber = g.Name;
          }
          else
           return retVal;
      }
      
      retVal = giftNumber + '-' + DateTime.now().format('hmmss');
      
      return retVal;
   }
   //---------------------------------------------------------------------------------------------------------
   public static String getBukectAccountId() {
      string retval = '';
      List<BatchSettings__c> settings = [Select b.BucketAccountId__c From BatchSettings__c b WHERE Name = 'Default'];
      
      if (settings != null && settings.size() > 0)
         retval = settings[0].BucketAccountId__c;
      
      return retval;
   }
   
   //---------------------------------------------------------------------------------------------------------
   public Gift_Detail__c CreateGiftDetailInstance() {
      Gift_Detail__c gd = new Gift_Detail__c();
      gd.Amount__c = giftDetail.Amount__c;
      gd.Appeal__c = giftDetail.Appeal__c;
      gd.New_Campaign__c = giftDetail.New_Campaign__c;
      gd.Product__c = giftDetail.Product__c;
      gd.Tribute__c = giftDetail.Tribute__c;
      gd.Package__c = giftDetail.Package__c;
      
      gd.Fund__c = giftDetail.Fund__c;
      gd.Description__c = giftDetail.Description__c;
      //load defaults
      return gd;
   }
   //---------------------------------------------------------------------------------------------------------
   public RD_Allocation__c CreateRDGiftDetailInstance() {
      RD_Allocation__c gd = new RD_Allocation__c();
      gd.Amount__c = giftDetail.Amount__c;
      gd.Appeal__c = giftDetail.Appeal__c;
      //gd.Product__c = giftDetail.Product__c;
      gd.New_Campaign__c = giftDetail.New_Campaign__c;
      gd.Package__c = giftDetail.Package__c;
      gd.Fund__c = giftDetail.Fund__c;
      //load defaults
      return gd;
   }
   
   //---------------------------------------------------------------------------------------------------------
   public static Gift__c CreateGiftInstance() {
      Gift__c g = new Gift__c();
      g.Batch_Status__c = 'Pending';
      return g;
   }
   //---------------------------------------------------------------------------------------------------------
   public static List<GiftBatchWrapper_moc> GetBatchData(string giftBatchId, User presetsData)
   {
      List<GiftBatchWrapper_moc> wrappers = new List<GiftBatchWrapper_moc>();
      
      List<Gift__c> gifts = [Select g.Package_Name__c, g.Id, g.Name, g.Receipt_Type__c, g.Batch_Status__c, g.Gift_Type__c, 
            g.Gift_Date__c, g.Foundation_Credit__c, Event__c, g.Constituent__c, g.Recurring_Donation__c, g.Receipt_Later__c,
            g.Channel__c, g.Amount__c, g.Organization__c, g.RecordType.Name, g.causeview__Anonymous__c,
            g.Reference__c, g.Letter__c, g.Primary_Solicitor__c, g.Internal_Solicitor__c, g.Expected_Amount__c,
            
            g.Organization__r.Organization_ID__c, g.Organization__r.Solicit_Codes__c, g.Organization__r.Constituent_Codes__c,
            g.Organization__r.Trade_Status__c,  g.Organization__r.Id, g.Organization__r.Type, g.Organization__r.Region__c,
            g.Organization__r.BillingCountry, g.Organization__r.BillingPostalCode, g.Organization__r.BillingState, 
            g.Organization__r.BillingCity, g.Organization__r.BillingStreet, g.Organization__r.Name,
            g.Organization__r.Phone, g.Organization__r.Fax, g.Organization__r.Website, g.Organization__r.Email__c,
            
            g.Constituent__r.Id, g.Constituent__r.Middle_Name__c, g.Constituent__r.Trade_Status__c, g.Constituent__r.Constituent_ID__c,
            g.Constituent__r.Solicit_Codes__c, g.Constituent__r.Primary_Salutation__c, g.Constituent__r.Name, 
            g.Constituent__r.Salutation, g.Constituent__r.FirstName, g.Constituent__r.LastName,
            g.Constituent__r.MailingCountry, g.Constituent__r.MailingPostalCode, g.Constituent__r.MailingState, 
            g.Constituent__r.MailingCity, g.Constituent__r.MailingStreet, g.Constituent__r.Region__c,
            g.Constituent__r.Email, g.Constituent__r.Phone, g.Constituent__r.Primary_Addressee__c, 
            g.Constituent__r.Constituent_Codes__c, g.Constituent__r.AccountId, g.Constituent__r.Household__c,
            
            g.Recurring_Donation__r.Id, g.Recurring_Donation__r.Organization__c,
            g.Recurring_Donation__r.Start_Date__c, g.Recurring_Donation__r.Frequency__c, g.Recurring_Donation__r.Type__c,
            g.Recurring_Donation__r.CreatedDate, g.Recurring_Donation__r.Constituent__c, g.Recurring_Donation__r.End_Date__c,
            g.Recurring_Donation__r.Bank_Name__c, g.Recurring_Donation__r.Bank_City__c, g.Recurring_Donation__r.Amount__c,
            g.Recurring_Donation__r.Branch_Num__c, g.Recurring_Donation__r.Institution_Num__c, g.Recurring_Donation__r.Encrypted_Key__c,
            g.Recurring_Donation__r.Account__c, g.Recurring_Donation__r.Credit_Card_Expiry_Date__c, g.Recurring_Donation__r.Credit_Card__c,
            g.Recurring_Donation__r.Credit_Card_Type__c, g.Recurring_Donation__r.of_Payments__c,
            
            (Select Id, Notes__c, Name, Gift__c, Amount_Not_Eligible__c From Receipts__r), 
            (Select Id, Name, Date__c, Status__c, Amount__c, Payment_Type__c, Donation__c,
                 CC_Transaction_Date__c, Cheque_Num__c, 
                 Cheque_Date__c, Date_Deposited__c, Credit_Card_Type__c, 
                 StatusComment__c From Recurring_Payments__r),   
            (Select Id, Title, ParentId, Body From Notes), 
            (Select Id, Package__c, Amount__c, Package__r.Name, New_Campaign__c, Product__c, Appeal__c, Tribute__c, Fund__c, Description__c, Gift__c  From Gift_Allocations__r)        
      From Gift__c g WHERE GiftBatch__c = :giftBatchId];

      User user = GiftBatchPresets.GetPresetsData();
 
      if (gifts != null && gifts.size()>0)
      {
          List<String> listOfIds = new List<String>();
          for(Gift__c g : gifts)
          {
             if (g.Recurring_Donation__c != null) listOfIds.add(g.Recurring_Donation__c);
          }
          List<RD_Allocation__c> rdAllocations = [Select r.Recurring_Gift__c, r.Name, r.Id, r.Fund__c, r.Package__c, r.Package__r.Name,
                                                r.New_Campaign__c, r.Appeal__c, r.Amount__c, 
                                                r.Active__c From RD_Allocation__c r WHERE r.Recurring_Gift__c in :listOfIds];
                   
          for(Gift__c g : gifts)
          {
             List<RD_Allocation__c> rds = new List<RD_Allocation__c>();
             for(RD_Allocation__c rd : rdAllocations)
               if (g.Recurring_Donation__c==rd.Recurring_Gift__c)
                 rds.add(rd);                       
            
            wrappers.add(GetInstance(g, rds, user));
          }
      }
      return wrappers;
   }
   
   //---------------------------------------------------------------------------------------------------------
   private static GiftBatchWrapper_moc GetInstance(Gift__c gift, List<RD_Allocation__c> rdAllocation)
   {
       User user = GiftBatchPresets.GetPresetsData();
       return GetInstance(gift, rdAllocation, user);
   }
   
   //---------------------------------------------------------------------------------------------------------
    private static GiftBatchWrapper_moc GetInstance(Gift__c gift,List<RD_Allocation__c> rdAllocation, User presetsData)
    {
        if (gift == null)
          return null;
                
        
        GiftBatchWrapper_moc wrapper = new GiftBatchWrapper_moc();
        //wrapper.user = presetsData;
        //wrapper.loadDefaults();
        wrapper.gift = gift;
        wrapper.isIndividualGift = (gift.Constituent__r != null);
        wrapper.giftDetails = gift.Gift_Allocations__r.size() > 0 ? gift.Gift_Allocations__r : new List<Gift_Detail__c>();
        wrapper.rdGiftDetails = rdAllocation != null ? rdAllocation : new List<RD_Allocation__c>();
        wrapper.constituent = gift.Constituent__r==null? new Contact() : gift.Constituent__r;
        wrapper.account = gift.Organization__r==null? new Account() : gift.Organization__r;
        wrapper.payment = gift.Recurring_Payments__r.size() > 0 ? gift.Recurring_Payments__r[0] : new Payment__c();
        wrapper.recurringDonation = gift.recurring_Donation__r == null? new Recurring_Donation__c() : gift.recurring_Donation__r;
        wrapper.expirationDate = wrapper.recurringDonation != null? formatExpirationDate(wrapper.recurringDonation.Credit_Card_Expiry_Date__c) : '';
        wrapper.receipt = gift.Receipts__r.size() > 0 ? gift.Receipts__r[0] : new Receipt__c();
        wrapper.giftNote = gift.Notes.size() > 0 ? gift.Notes[0] : new Note(); 
        if (gift.Notes.size() > 0)
        {
            wrapper.noteSubject = gift.Notes[0].Title;
            wrapper.noteBody = gift.Notes[0].Body;
        } 
        
        //wrapper.isIndividualGift = (wrapper.constituent != null);

        wrapper.isRecurring = (wrapper.recurringDonation != null && wrapper.recurringDonation.Frequency__c != null);
        
        if (wrapper.giftDetails.size()<=0)
          wrapper.giftDetails.add(wrapper.CreateGiftDetailInstance());
          
         if (wrapper.rdGiftDetails.size()<=0)
            wrapper.rdGiftDetails.add(wrapper.CreateRDGiftDetailInstance());        
        
        return wrapper;
    }
   
   //---------------------------------------------------------------------------------------------------------
   public static GiftBatchWrapper_moc CreateInstance(string giftId)
   {
        GiftBatchWrapper_moc newGift = new GiftBatchWrapper_moc();
        
        Gift__c gift = loadGiftRecord(giftId);
     
        if (gift != null)
        {
            List<RD_Allocation__c> rdAllocation = null;
            if (gift.Recurring_Donation__c != null)
            {
                rdAllocation = [Select r.Recurring_Gift__c, r.Name, r.Id, r.Fund__c, r.New_Campaign__c, r.Appeal__c, r.Amount__c, r.Active__c, r.Package__c, r.Package__r.Name
                                From RD_Allocation__c r WHERE r.Recurring_Gift__c = :gift.Recurring_Donation__c];
            }
            
            newGift  = GetInstance(gift, rdAllocation);
        }
        else
        {
            newGift.user = GiftBatchPresets.GetPresetsData();
            newGift.loadDefaults();
        }              
        
        return newGift;
    }
    //---------------------------------------------------------------------------------------------------------
    public static GiftBatchWrapper_moc refreshInstance(GiftBatchWrapper_moc original) {
        if (original == null || original.gift == null || original.gift.Id == null)
          return original;
          
        GiftBatchWrapper_moc wrapper = CreateInstance(original.gift.Id);
        wrapper.CCName = original.CCName;
        wrapper.CCNumber = original.CCNumber;
        //wrapper.CCType = original.CCType;
        wrapper.Cvv = original.Cvv;
        wrapper.expirationDate = original.expirationDate;
        wrapper.isIndividualGift = original.isIndividualGift;
        wrapper.isRecurring = original.isRecurring;
        wrapper.cardholderFirstName = original.cardholderFirstName;
        wrapper.cardholderLastName = original.cardholderLastName;
        
        if (original.receipt.Gift__c != null && wrapper.receipt.Gift__c==null)
          wrapper.receipt = original.receipt;
        
        return wrapper;
    }
    //---------------------------------------------------------------------------------------------------------
    private static Gift__c loadGiftRecord(string giftId)
    {
       List<Gift__c> gifts = new List<Gift__c>();
       
       gifts = [Select g.Package_Name__c, g.Id, g.Name, g.Receipt_Type__c, g.Batch_Status__c, g.Gift_Type__c, 
            g.Gift_Date__c, g.Foundation_Credit__c, Event__c, g.Constituent__c, g.Recurring_Donation__c, 
            g.Channel__c, g.Amount__c, g.Organization__c, g.RecordType.Name, g.causeview__Anonymous__c,
            g.Reference__c, g.Letter__c, g.Primary_Solicitor__c, g.causeview__Internal_Solicitor__c, g.Expected_Amount__c,
            
            g.Organization__r.Organization_ID__c, g.Organization__r.Solicit_Codes__c, g.Organization__r.Constituent_Codes__c,
            g.Organization__r.Trade_Status__c,  g.Organization__r.Id, g.Organization__r.Type, g.Organization__r.Region__c,
            g.Organization__r.BillingCountry, g.Organization__r.BillingPostalCode, g.Organization__r.BillingState, 
            g.Organization__r.BillingCity, g.Organization__r.BillingStreet, g.Organization__r.Name,
            g.Organization__r.Phone, g.Organization__r.Fax, g.Organization__r.Website, g.Organization__r.Email__c,
            
            g.Constituent__r.Middle_Name__c, g.Constituent__r.Id, g.Constituent__r.Trade_Status__c, g.Constituent__r.Constituent_ID__c,
            g.Constituent__r.Solicit_Codes__c, g.Constituent__r.Primary_Salutation__c, g.Constituent__r.Name, 
            g.Constituent__r.Salutation, g.Constituent__r.FirstName, g.Constituent__r.LastName,
            g.Constituent__r.MailingCountry, g.Constituent__r.MailingPostalCode, g.Constituent__r.MailingState, 
            g.Constituent__r.MailingCity, g.Constituent__r.MailingStreet, g.Constituent__r.Region__c,
            g.Constituent__r.Email, g.Constituent__r.Phone, g.Constituent__r.Primary_Addressee__c, 
            g.Constituent__r.Constituent_Codes__c, g.Constituent__r.AccountId, g.Constituent__r.Household__c,
            
            g.Recurring_Donation__r.Id, g.Recurring_Donation__r.Organization__c,
            g.Recurring_Donation__r.Start_Date__c, g.Recurring_Donation__r.Frequency__c, g.Recurring_Donation__r.Type__c,
            g.Recurring_Donation__r.CreatedDate, g.Recurring_Donation__r.Constituent__c, g.Recurring_Donation__r.End_Date__c,
            g.Recurring_Donation__r.Bank_Name__c, g.Recurring_Donation__r.Bank_City__c, g.Recurring_Donation__r.Amount__c,
            g.Recurring_Donation__r.Branch_Num__c, g.Recurring_Donation__r.Institution_Num__c, g.Recurring_Donation__r.Encrypted_Key__c,
            g.Recurring_Donation__r.Account__c, g.Recurring_Donation__r.Credit_Card_Expiry_Date__c, g.Recurring_Donation__r.Credit_Card__c,
            g.Recurring_Donation__r.Credit_Card_Type__c, g.Recurring_Donation__r.of_Payments__c,
            
            (Select Id, Name, Notes__c, Gift__c, Amount_Not_Eligible__c From Receipts__r), 
            (Select Id, Name, Date__c, Status__c, Amount__c, Payment_Type__c, Donation__c,
                 CC_Transaction_Date__c, Cheque_Num__c, 
                 Cheque_Date__c, Date_Deposited__c, Credit_Card_Type__c, 
                 StatusComment__c From Recurring_Payments__r),   
            (Select Id, Title, ParentId, Body From Notes), 
            (Select Id, Amount__c, New_Campaign__c, Appeal__c, Product__c, Tribute__c, Fund__c, Description__c, Gift__c, Package__c, Package__r.Name  From Gift_Allocations__r) 
            From Gift__c g WHERE Id = :giftId];
                               
       if (gifts != null && gifts.size() > 0)
          return gifts[0];
       else
          return null;
 
    }
    
    public static string formatExpirationDate(Date expiryDate)
    {
        if (expiryDate==null)
          return '';
        
        string month = expiryDate.month().format();
        if (month.length()==1)
          month = '0'+month;
        string year = expiryDate.year().format();
          
        return month+year.substring(3,5);
    }
    
    
}