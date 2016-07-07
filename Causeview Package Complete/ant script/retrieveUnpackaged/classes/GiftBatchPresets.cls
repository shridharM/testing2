public with sharing class GiftBatchPresets {
     
    //Contact
    public FieldSetting constituentID { get; set; }
    public FieldSetting constituentFirstName { get; set; }
    public FieldSetting constituentLastName { get; set; }
    public FieldSetting constituentMailingStreet { get; set; }
    public FieldSetting constituentMailingCity { get; set; }
    public FieldSetting constituentMailingState { get; set; }
    public FieldSetting constituentMailingPostalCode { get; set; }
    public FieldSetting constituentMailingCountry { get; set; }
    public FieldSetting constituentRegion { get; set; }
    public FieldSetting constituentPhone { get; set; }
    public FieldSetting constituentEmail { get; set; }
    public FieldSetting constituentPrimaryAddressee { get; set; }
    public FieldSetting constituentPrimarySalutation { get; set; }
    public FieldSetting constituentTradeStatus { get; set; }
    public FieldSetting constituentCodes { get; set; }
    public FieldSetting constituentSolicitCode { get; set; }
    public FieldSetting constituentHousehold { get; set; }
    
    //Account
    public FieldSetting orgID { get; set; }
    public FieldSetting orgName { get; set; }
    public FieldSetting orgBillingStreet { get; set; }
    public FieldSetting orgBillingCity { get; set; }
    public FieldSetting orgBillingState { get; set; }
    public FieldSetting orgBillingPostalCode { get; set; }
    public FieldSetting orgBillingCountry { get; set; }
    public FieldSetting orgRegion { get; set; }
    public FieldSetting orgPhone { get; set; }
    public FieldSetting orgFax { get; set; }
    public FieldSetting orgWebsite { get; set; }
    public FieldSetting orgEmail { get; set; }
    public FieldSetting orgType { get; set; }
    public FieldSetting orgTradeStatus { get; set; }
    public FieldSetting orgSolicitCode { get; set; }
    public FieldSetting orgConstituentCode { get; set; }
        
    //Recurring donation
    public FieldSetting shareplanFrequency { get; set; }
    public FieldSetting shareplanStartDate { get; set; }
    public FieldSetting shareplanEndDate { get; set; }
    public FieldSetting shareplanWithdrawalDate { get; set; }
    public FieldSetting shareplanNumberOfPayments { get; set; }
    public FieldSetting shareplanBankName { get; set; }
    public FieldSetting shareplanBankCity { get; set; }
    public FieldSetting shareplanBranchNo { get; set; }
    public FieldSetting shareplanInstitutionNo { get; set; }
    public FieldSetting shareplanAccountNo { get; set; }
    public FieldSetting shareplanCCExpiryDate { get; set; }
    
    // gift
    public FieldSetting giftDate { get; set; }
    public FieldSetting giftChannel { get; set; }
    public FieldSetting giftAmount { get; set; }
    public FieldSetting giftType { get; set; }
    //public FieldSetting giftTribute { get; set; }
    public FieldSetting giftFoundationCredit { get; set; }
    public FieldSetting giftEvent {get; set; }
    public FieldSetting giftReference { get; set; }
    //public FieldSetting giftMembership { get; set; }
    //public FieldSetting giftProduct { get; set; }
    public FieldSetting giftLetter { get; set; }
    public FieldSetting giftSubject { get; set; }
    public FieldSetting giftNotes { get; set; }
    public FieldSetting giftPrimarySolicitor { get; set; }
    public FieldSetting giftInternalSolicitor { get; set; }
    
    //payment
    public FieldSetting paymentType { get; set; }
    public FieldSetting paymentCCType { get; set; }
    public FieldSetting paymentChequeDate { get; set; }
    public FieldSetting paymentChequeNo { get; set; }
    public FieldSetting paymentDateDeposited { get; set; }
    public FieldSetting paymentDate { get; set; }
    public FieldSetting paymentStatus { get; set; }
    
    //receipt
    public FieldSetting receiptNotes { get; set; }
    public FieldSetting receiptAmountEligible { get; set; }    
    public FieldSetting receiptType { get; set; }
    
    //gift detail
    public FieldSetting giftDetailAmount { get; set; }
    public FieldSetting giftDetailFund { get; set; }
    public FieldSetting giftDetailCampaign { get; set; }
    public FieldSetting giftDetailPackage { get; set; }
    public FieldSetting giftDetailAppeal { get; set; }
    public FieldSetting giftDetailProduct { get; set; }    
    public FieldSetting giftDetailTribute { get; set; }
    public FieldSetting giftDetailDescription { get; set; }
      
    private User user { get; set; }
      
    public GiftBatchPresets(User u) 
    {
        //contact
        constituentID  = new FieldSetting('ci',false,false,true);
        constituentFirstName  = new FieldSetting('cf',false,false,true);
        constituentLastName  = new FieldSetting('cl',false,false,false);
        constituentLastName.isRequired = true;
        constituentMailingStreet  = new FieldSetting('cs',false,false,true);
        constituentMailingCity  = new FieldSetting('cc');
        constituentMailingState  = new FieldSetting('cm');
        constituentMailingPostalCode  = new FieldSetting('cp',false,false,true);
        constituentMailingCountry  = new FieldSetting('cu');
        constituentRegion  = new FieldSetting('cr');
        constituentPhone  = new FieldSetting('ch',false,false,true);
        constituentEmail  = new FieldSetting('ce',false,false,true);
        constituentPrimaryAddressee  = new FieldSetting('ca',false,false,true);
        constituentPrimarySalutation  = new FieldSetting('cn',false,false,true);
        constituentTradeStatus  = new FieldSetting('ct');
        constituentCodes  = new FieldSetting('co');
        constituentSolicitCode  = new FieldSetting('cl');
        constituentHousehold  = new FieldSetting('ck',false,false,true);
            
        
        //organization
        orgID = new FieldSetting('oi',false,false,true);
        orgName = new FieldSetting('on',false,false,false);
        orgName.isRequired = true;
        orgBillingStreet = new FieldSetting('os',false,false,true);
        orgBillingCity = new FieldSetting('oc');
        orgBillingState = new FieldSetting('ot');
        orgBillingPostalCode = new FieldSetting('op',false,false,true);
        orgBillingCountry = new FieldSetting('ou');
        orgRegion = new FieldSetting('or');
        orgPhone = new FieldSetting('oh',false,false,true);
        orgFax = new FieldSetting('of',false,false,true);
        orgWebsite = new FieldSetting('ow',false,false,true);
        orgEmail = new FieldSetting('oe',false,false,true);
        orgType = new FieldSetting('oy');
        orgTradeStatus = new FieldSetting('od');
        orgSolicitCode = new FieldSetting('oo');
        orgConstituentCode = new FieldSetting('og');
        
        //shareplan
        shareplanFrequency = new FieldSetting('sf');
        shareplanStartDate = new FieldSetting('ss');
        shareplanWithdrawalDate = new FieldSetting('sw');
        shareplanEndDate = new FieldSetting('se');
        shareplanNumberOfPayments = new FieldSetting('sn');
        shareplanBankName = new FieldSetting('sb');
        shareplanBankCity = new FieldSetting('sc');
        shareplanBranchNo = new FieldSetting('sr',false,false,true);
        shareplanInstitutionNo = new FieldSetting('si',false,false,true);
        shareplanAccountNo = new FieldSetting('sa',false,false,true);
        shareplanCCExpiryDate = new FieldSetting('sx',false,false,true);
    
        //gift
        giftDate = new FieldSetting('gd');
        giftDate.isRequired = true;
        giftChannel = new FieldSetting('gc');
        giftChannel.isRequired = true;
        giftAmount = new FieldSetting('gt');
        giftAmount.isRequired = true;
        giftType = new FieldSetting('gy');
        //giftTribute = new FieldSetting('gr');
        giftFoundationCredit = new FieldSetting('gf');
        giftEvent = new FieldSetting('ge');
        giftReference = new FieldSetting('gn');
        giftSubject = new FieldSetting('gs');
        giftNotes = new FieldSetting('go');
        giftLetter = new FieldSetting('gl');
        
        //giftProduct = new FieldSetting('gp');
        giftPrimarySolicitor = new FieldSetting('ga');
        giftInternalSolicitor  = new FieldSetting('gis');
        //giftMembership = new FieldSetting('gm');
        
        //payment
        paymentType = new FieldSetting('pt');
        paymentType.isRequired = true;
        paymentCCType = new FieldSetting('pc');
        paymentChequeDate = new FieldSetting('ph');
        paymentChequeNo = new FieldSetting('pq');
        paymentDateDeposited = new FieldSetting('pd');
        paymentDate = new FieldSetting('pa');
        paymentStatus = new FieldSetting('ps');

        
        //receipt
        receiptType = new FieldSetting('rt');
        receiptNotes = new FieldSetting('rn');
        receiptAmountEligible = new FieldSetting('rae');
        
        //gift allocation
        giftDetailAmount = new FieldSetting('df');
        giftDetailFund = new FieldSetting('du');
        giftDetailCampaign = new FieldSetting('dc');
        giftDetailAppeal = new FieldSetting('de');
        giftDetailPackage = new FieldSetting('dpkg');        
        giftDetailProduct = new FieldSetting('ddp');        
        giftDetailTribute = new FieldSetting('dp');
        giftDetailDescription = new FieldSetting('dd');
     
        //
        user = u;  
    }
        
    //-----------------------------------------------------------------------------------------------------------
    public class FieldSetting
    {
        private Boolean m_readOnly = false;
        private Boolean m_isHidden = false;
        private Boolean m_isRequired = false;
        
        public Boolean readOnly {
            get {
                return m_readOnly;
            }
            set {
                if (canSetReadOnly){
                    m_readOnly = value;
                }
            }
        }
        public Boolean isHidden {
            get {
                return m_isHidden;
            }
            set {
                if (canHide)
                {
                    m_isHidden = value;
                }
            }
        }
        public Boolean isRequired {
            get {
                return m_isRequired;
            }
            set {
                m_isRequired = value;
            }
        }
        
        //auto populated by constructor
        public String shortName { get; set; }
        public Boolean hasDefaultValue { get; set; } 
        public Boolean canHide { get; set; }
        public Boolean canSetReadOnly { get; set; }
        
        public FieldSetting() { }
        public FieldSetting(String n) { shortName = n; hasDefaultValue = true; canHide = true; canSetReadOnly = true; }
        public FieldSetting(String n, Boolean hasDefault, Boolean setReadOnly, Boolean hide ) {
             shortName = n;
             hasDefaultValue = hasDefault;
             canHide = hide;
             canSetReadOnly = setReadOnly;
        }
    }
    
    //-----------------------------------------------------------------------------------------------------------
    //operations
    //-----------------------------------------------------------------------------------------------------------
    //private List<keyValue> fieldRefs;
    //private Map<string, string> data;
    //private Map<string, string> dataReadOnly;
    //private Map<string, string> dataHidden;
    //private string xml = '';
    
    //-----------------------------------------------------------------------------------------------------------
    public void ClearDefaults () { 
        User user = [SELECT Id, BatchDefaults__c, BatchReadonlys__c, BatchHiddenFields__c FROM User WHERE Id = :UserInfo.getUserId()];
        if (user != null) {
            user.BatchDefaults__c = '<defaults></defaults>';
            user.BatchHiddenFields__c = '<defaults></defaults>';
            user.BatchReadonlys__c = '<defaults></defaults>';
            update user;
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    public static User GetPresetsData()
    {
        system.debug('<==GetPresetsData()==>');
        User user = [SELECT Id, BatchDefaults__c, BatchReadonlys__c, BatchHiddenFields__c FROM User WHERE Id = :UserInfo.getUserId()];
        return user;
    }
    //-------------------------------------------------------------------------------------------------------------------------------
    //Added by Nitin
    //To fetch giftdetailpackage Property Hidden: "True" or "False" on Gift Batch Preset page 
    public Boolean loadGiftDetailPackageProperty(GiftBatchWrapper gw){
        
        //User user = [SELECT Id, BatchDefaults__c, BatchReadonlys__c, BatchHiddenFields__c FROM User WHERE Id = :UserInfo.getUserId()];
        system.debug('<==inside load==>'); 
        Map<string, string> data;
        Map<string, string> dataReadOnly;
        Map<string, string> dataHidden;
        string defaultsXml = '<defaults></defaults>';
        string readonlyXml = '<defaults></defaults>';
        string hiddenXml = '<defaults></defaults>';
        
        if (user != null && gw != null) {
            defaultsXml = user.BatchDefaults__c;
            readonlyXml = user.BatchHiddenFields__c;
            hiddenXml = user.BatchReadonlys__c;
            system.debug(defaultsXml);
        }
        else
        {
            system.debug('*** did not load presets');
            if (gw == null) system.debug('*** Gift Batch Wrapper is null.');
            if (user == null) system.debug('*** User is null.');
        }
        data = doParse(defaultsXml);
        dataReadOnly = doParse(readonlyXml);
        dataHidden = doParse(hiddenXml);
        
        if (giftDetailPackage.hasDefaultValue) gw.gift.Package_Name__c = getStringValue(data, giftDetailPackage.shortName);
        giftDetailPackage.readOnly = getBooleanValue(dataReadOnly, giftDetailPackage.shortName);
        giftDetailPackage.isHidden = getBooleanValue(dataHidden, giftDetailPackage.shortName);  
        system.debug('giftDetailPackage.isHidden==>'+giftDetailPackage.isHidden); 
        return giftDetailPackage.isHidden;
    }
    //-------------------------------------------------------------------------------------------------------------------------------
    public void load(GiftBatchWrapper gw) {
        system.debug('<==inside load==>'); 
        Map<string, string> data;
        Map<string, string> dataReadOnly;
        Map<string, string> dataHidden;
        string defaultsXml = '<defaults></defaults>';
        string readonlyXml = '<defaults></defaults>';
        string hiddenXml = '<defaults></defaults>';
        
        if (user != null && gw != null) {
            defaultsXml = user.BatchDefaults__c;
            readonlyXml = user.BatchHiddenFields__c;
            hiddenXml = user.BatchReadonlys__c;
            system.debug(defaultsXml);
        }
        else
        {
            system.debug('*** did not load presets');
            if (gw == null) system.debug('*** Gift Batch Wrapper is null.');
            if (user == null) system.debug('*** User is null.');
        }
        data = doParse(defaultsXml);
        dataReadOnly = doParse(readonlyXml);
        dataHidden = doParse(hiddenXml);

        //Contact
        //constituentID  = new FieldSetting('ci',false,false,true);
        //gw.constituent.Constituent_ID__c cannot have default value
        constituentID.readOnly = getBooleanValue(dataReadOnly, constituentID.shortName);
        constituentID.isHidden = getBooleanValue(dataHidden, constituentID.shortName);

        //constituentFirstName  = new FieldSetting('cf',false,false,true);
        if (constituentFirstName.hasDefaultValue) gw.constituent.FirstName = getStringValue(data, constituentFirstName.shortName);
        constituentFirstName.readOnly = getBooleanValue(dataReadOnly, constituentFirstName.shortName);
        constituentFirstName.isHidden = getBooleanValue(dataHidden, constituentFirstName.shortName);
        
        //constituentLastName  = new FieldSetting('cl',false,false,false);
        if (constituentLastName.hasDefaultValue) gw.constituent.LastName = getStringValue(data, constituentLastName.shortName);
        constituentLastName.readOnly = getBooleanValue(dataReadOnly, constituentLastName.shortName);
        constituentLastName.isHidden = getBooleanValue(dataHidden, constituentLastName.shortName);

        //constituentMailingStreet  = new FieldSetting('cs');
        if (constituentMailingStreet.hasDefaultValue) gw.constituent.MailingStreet = getStringValue(data, constituentMailingStreet.shortName);
        constituentMailingStreet.readOnly = getBooleanValue(dataReadOnly, constituentMailingStreet.shortName);
        constituentMailingStreet.isHidden = getBooleanValue(dataHidden, constituentMailingStreet.shortName);

        //constituentMailingCity  = new FieldSetting('cc');
        if (constituentMailingCity.hasDefaultValue) gw.constituent.MailingCity = getStringValue(data, constituentMailingCity.shortName);
        constituentMailingCity.readOnly = getBooleanValue(dataReadOnly, constituentMailingCity.shortName);
        constituentMailingCity.isHidden = getBooleanValue(dataHidden, constituentMailingCity.shortName);

        //constituentMailingState  = new FieldSetting('cm');
        if (constituentMailingState.hasDefaultValue) gw.constituent.MailingState = getStringValue(data, constituentMailingState.shortName);
        constituentMailingState.readOnly = getBooleanValue(dataReadOnly, constituentMailingState.shortName);
        constituentMailingState.isHidden = getBooleanValue(dataHidden, constituentMailingState.shortName);

        //constituentMailingPostalCode  = new FieldSetting('cp');
        if (constituentMailingPostalCode.hasDefaultValue) gw.constituent.MailingPostalCode = getStringValue(data, constituentMailingPostalCode.shortName);
        constituentMailingPostalCode.readOnly = getBooleanValue(dataReadOnly, constituentMailingPostalCode.shortName);
        constituentMailingPostalCode.isHidden = getBooleanValue(dataHidden, constituentMailingPostalCode.shortName);

        //constituentMailingCountry  = new FieldSetting('cu');
        if (constituentMailingCountry.hasDefaultValue) gw.constituent.MailingCountry = getStringValue(data, constituentMailingCountry.shortName);
        constituentMailingCountry.readOnly = getBooleanValue(dataReadOnly, constituentMailingCountry.shortName);
        constituentMailingCountry.isHidden = getBooleanValue(dataHidden, constituentMailingCountry.shortName);

        //constituentRegion  = new FieldSetting('cr');
        if (constituentRegion.hasDefaultValue) gw.constituent.Region__c = getStringValue(data, constituentRegion.shortName);
        constituentRegion.readOnly = getBooleanValue(dataReadOnly, constituentRegion.shortName);
        constituentRegion.isHidden = getBooleanValue(dataHidden, constituentRegion.shortName);

        //constituentPhone  = new FieldSetting('ch',false,false,true);
        if (constituentPhone.hasDefaultValue) gw.constituent.Phone = getStringValue(data, constituentPhone.shortName);
        constituentPhone.readOnly = getBooleanValue(dataReadOnly, constituentPhone.shortName);
        constituentPhone.isHidden = getBooleanValue(dataHidden, constituentPhone.shortName);

        //constituentEmail  = new FieldSetting('ce',false,false,true);
        if (constituentEmail.hasDefaultValue) gw.constituent.Email = getStringValue(data, constituentEmail.shortName);
        constituentEmail.readOnly = getBooleanValue(dataReadOnly, constituentEmail.shortName);
        constituentEmail.isHidden = getBooleanValue(dataHidden, constituentEmail.shortName);

        //constituentPrimaryAddressee  = new FieldSetting('ca',false,false,true);
        if (constituentPrimaryAddressee.hasDefaultValue) gw.constituent.Primary_Addressee__c = getStringValue(data, constituentPrimaryAddressee.shortName);
        constituentPrimaryAddressee.readOnly = getBooleanValue(dataReadOnly, constituentPrimaryAddressee.shortName);
        constituentPrimaryAddressee.isHidden = getBooleanValue(dataHidden, constituentPrimaryAddressee.shortName);

        //constituentPrimarySalutation  = new FieldSetting('cn',false,false,true);
        if (constituentPrimarySalutation.hasDefaultValue) gw.constituent.Primary_Salutation__c = getStringValue(data, constituentPrimarySalutation.shortName);
        constituentPrimarySalutation.readOnly = getBooleanValue(dataReadOnly, constituentPrimarySalutation.shortName);
        constituentPrimarySalutation.isHidden = getBooleanValue(dataHidden, constituentPrimarySalutation.shortName);

        //constituentTradeStatus  = new FieldSetting('ct');
        if (constituentTradeStatus.hasDefaultValue) gw.constituent.Trade_Status__c = getStringValue(data, constituentTradeStatus.shortName);
        constituentTradeStatus.readOnly = getBooleanValue(dataReadOnly, constituentTradeStatus.shortName);
        constituentTradeStatus.isHidden = getBooleanValue(dataHidden, constituentTradeStatus.shortName);

        //constituentCodes  = new FieldSetting('co');
        if (constituentCodes.hasDefaultValue) gw.constituent.Constituent_Codes__c = getStringValue(data, constituentCodes.shortName);
        constituentCodes.readOnly = getBooleanValue(dataReadOnly, constituentCodes.shortName);
        constituentCodes.isHidden = getBooleanValue(dataHidden, constituentCodes.shortName);

        //constituentSolicitCode  = new FieldSetting('cl');
        if (constituentSolicitCode.hasDefaultValue) gw.constituent.Solicit_Codes__c = getStringValue(data, constituentSolicitCode.shortName);
        constituentSolicitCode.readOnly = getBooleanValue(dataReadOnly, constituentSolicitCode.shortName);
        constituentSolicitCode.isHidden = getBooleanValue(dataHidden, constituentSolicitCode.shortName);

        //constituentHousehold  = new FieldSetting('ck',false,false,true);
        if (constituentHousehold.hasDefaultValue) gw.constituent.Household__c = getStringValue(data, constituentHousehold.shortName);
        constituentHousehold.readOnly = getBooleanValue(dataReadOnly, constituentHousehold.shortName);
        constituentHousehold.isHidden = getBooleanValue(dataHidden, constituentHousehold.shortName);

        //Organization
        //orgID = new FieldSetting('oi',false,false,true);
        //if (orgID.hasDefaultValue) gw.account.Organization_ID__c = getStringValue(data, orgID.shortName);
        orgID.readOnly = getBooleanValue(dataReadOnly, orgID.shortName);
        orgID.isHidden = getBooleanValue(dataHidden, orgID.shortName);

        
        
        //orgName = new FieldSetting('on',false,false,false);
        if (orgName.hasDefaultValue && gw.account!=null) gw.account.Name = getStringValue(data, orgName.shortName);
        orgName.readOnly = getBooleanValue(dataReadOnly, orgName.shortName);
        orgName.isHidden = getBooleanValue(dataHidden, orgName.shortName);
    
        //orgBillingStreet = new FieldSetting('os',false,false,true);
        if (orgBillingStreet.hasDefaultValue && gw.account!=null) gw.account.BillingStreet = getStringValue(data, orgBillingStreet.shortName);
        orgBillingStreet.readOnly = getBooleanValue(dataReadOnly, orgBillingStreet.shortName);
        orgBillingStreet.isHidden = getBooleanValue(dataHidden, orgBillingStreet.shortName);

        //orgBillingCity = new FieldSetting('oc');
        if (orgBillingCity.hasDefaultValue && gw.account!=null) gw.account.BillingCity = getStringValue(data, orgBillingCity.shortName);
        orgBillingCity.readOnly = getBooleanValue(dataReadOnly, orgBillingCity.shortName);
        orgBillingCity.isHidden = getBooleanValue(dataHidden, orgBillingCity.shortName);

        //orgBillingState = new FieldSetting('ot');
        if (orgBillingState.hasDefaultValue && gw.account!=null) gw.account.BillingState = getStringValue(data, orgBillingState.shortName);
        orgBillingState.readOnly = getBooleanValue(dataReadOnly, orgBillingState.shortName);
        orgBillingState.isHidden = getBooleanValue(dataHidden, orgBillingState.shortName);

        //orgBillingPostalCode = new FieldSetting('op',false,false,true);
        if (orgBillingPostalCode.hasDefaultValue && gw.account!=null) gw.account.BillingPostalCode = getStringValue(data, orgBillingPostalCode.shortName);
        orgBillingPostalCode.readOnly = getBooleanValue(dataReadOnly, orgBillingPostalCode.shortName);
        orgBillingPostalCode.isHidden = getBooleanValue(dataHidden, orgBillingPostalCode.shortName);

        //orgBillingCountry = new FieldSetting('ou');
        if (orgBillingCountry.hasDefaultValue && gw.account!=null) gw.account.BillingCountry = getStringValue(data, orgBillingCountry.shortName);
        orgBillingCountry.readOnly = getBooleanValue(dataReadOnly, orgBillingCountry.shortName);
        orgBillingCountry.isHidden = getBooleanValue(dataHidden, orgBillingCountry.shortName);

        //orgRegion = new FieldSetting('or');
        if (orgRegion.hasDefaultValue && gw.account!=null) gw.account.Region__c = getStringValue(data, orgRegion.shortName);
        orgRegion.readOnly = getBooleanValue(dataReadOnly, orgRegion.shortName);
        orgRegion.isHidden = getBooleanValue(dataHidden, orgRegion.shortName);

        //orgPhone = new FieldSetting('oh',false,false,true);
        if (orgPhone.hasDefaultValue && gw.account!=null) gw.account.Phone = getStringValue(data, orgPhone.shortName);
        orgPhone.readOnly = getBooleanValue(dataReadOnly, orgPhone.shortName);
        orgPhone.isHidden = getBooleanValue(dataHidden, orgPhone.shortName);

        //orgFax = new FieldSetting('of',false,false,true);
        if (orgFax.hasDefaultValue && gw.account!=null) gw.account.Fax = getStringValue(data, orgFax.shortName);
        orgFax.readOnly = getBooleanValue(dataReadOnly, orgFax.shortName);
        orgFax.isHidden = getBooleanValue(dataHidden, orgFax.shortName);

        //orgWebsite = new FieldSetting('ow',false,false,true);
        if (orgWebsite.hasDefaultValue && gw.account!=null) gw.account.Website = getStringValue(data, orgWebsite.shortName);
        orgWebsite.readOnly = getBooleanValue(dataReadOnly, orgWebsite.shortName);
        orgWebsite.isHidden = getBooleanValue(dataHidden, orgWebsite.shortName);

        //orgEmail = new FieldSetting('oe',false,false,true);
        if (orgEmail.hasDefaultValue && gw.account!=null) gw.account.Email__c = getStringValue(data, orgEmail.shortName);
        orgEmail.readOnly = getBooleanValue(dataReadOnly, orgEmail.shortName);
        orgEmail.isHidden = getBooleanValue(dataHidden, orgEmail.shortName);

        //orgType = new FieldSetting('oy');
        if (orgType.hasDefaultValue && gw.account!=null) gw.account.Type = getStringValue(data, orgType.shortName);
        orgType.readOnly = getBooleanValue(dataReadOnly, orgType.shortName);
        orgType.isHidden = getBooleanValue(dataHidden, orgType.shortName);

        //orgTradeStatus = new FieldSetting('od');
        if (orgTradeStatus.hasDefaultValue && gw.account!=null) gw.account.Trade_Status__c = getStringValue(data, orgTradeStatus.shortName);
        orgTradeStatus.readOnly = getBooleanValue(dataReadOnly, orgTradeStatus.shortName);
        orgTradeStatus.isHidden = getBooleanValue(dataHidden, orgTradeStatus.shortName);

        //orgSolicitCode = new FieldSetting('oo');
        if (orgSolicitCode.hasDefaultValue && gw.account!=null) gw.account.Solicit_Codes__c = getStringValue(data, orgSolicitCode.shortName);
        orgSolicitCode.readOnly = getBooleanValue(dataReadOnly, orgSolicitCode.shortName);
        orgSolicitCode.isHidden = getBooleanValue(dataHidden, orgSolicitCode.shortName);

        //orgConstituentCode = new FieldSetting('og');
        if (orgConstituentCode.hasDefaultValue && gw.account!=null) gw.account.Constituent_Codes__c = getStringValue(data, orgConstituentCode.shortName);
        orgConstituentCode.readOnly = getBooleanValue(dataReadOnly, orgConstituentCode.shortName);
        orgConstituentCode.isHidden = getBooleanValue(dataHidden, orgConstituentCode.shortName);
    
        
        //Shareplan
        //shareplanFrequency = new FieldSetting('sf');
        if (shareplanFrequency.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Frequency__c = getStringValue(data, shareplanFrequency.shortName);
        shareplanFrequency.readOnly = getBooleanValue(dataReadOnly, shareplanFrequency.shortName);
        shareplanFrequency.isHidden = getBooleanValue(dataHidden, shareplanFrequency.shortName);
        
        //shareplanStartDate = new FieldSetting('ss');
        if (shareplanStartDate.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Start_Date__c = getDateValue(data, shareplanStartDate.shortName);
        shareplanStartDate.readOnly = getBooleanValue(dataReadOnly, shareplanStartDate.shortName);
        shareplanStartDate.isHidden = getBooleanValue(dataHidden, shareplanStartDate.shortName);
/*
        //shareplanWithdrawalDate = new FieldSetting('sw');
        if (shareplanWithdrawalDate.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Withdrawal_Date__c = getStringValue(data, shareplanWithdrawalDate.shortName);
        shareplanWithdrawalDate.readOnly = getBooleanValue(dataReadOnly, shareplanWithdrawalDate.shortName);
        shareplanWithdrawalDate.isHidden = getBooleanValue(dataHidden, shareplanWithdrawalDate.shortName);
*/
        //shareplanEndDate = new FieldSetting('se');
        if (shareplanEndDate.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.End_Date__c = getDateValue(data, shareplanEndDate.shortName);
        shareplanEndDate.readOnly = getBooleanValue(dataReadOnly, shareplanEndDate.shortName);
        shareplanEndDate.isHidden = getBooleanValue(dataHidden, shareplanEndDate.shortName);

        //shareplanNumberOfPayments = new FieldSetting('sn');
        if (shareplanNumberOfPayments.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Of_Payments__c = getDecimalValue(data, shareplanNumberOfPayments.shortName);
        shareplanNumberOfPayments.readOnly = getBooleanValue(dataReadOnly, shareplanNumberOfPayments.shortName);
        shareplanNumberOfPayments.isHidden = getBooleanValue(dataHidden, shareplanNumberOfPayments.shortName);

        //shareplanBankName = new FieldSetting('sb');
        if (shareplanBankName.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Bank_Name__c = getStringValue(data, shareplanBankName.shortName);
        shareplanBankName.readOnly = getBooleanValue(dataReadOnly, shareplanBankName.shortName);
        shareplanBankName.isHidden = getBooleanValue(dataHidden, shareplanBankName.shortName);

        //shareplanBankCity = new FieldSetting('sc');
        if (shareplanBankCity.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Bank_City__c = getStringValue(data, shareplanBankCity.shortName);
        shareplanBankCity.readOnly = getBooleanValue(dataReadOnly, shareplanBankCity.shortName);
        shareplanBankCity.isHidden = getBooleanValue(dataHidden, shareplanBankCity.shortName);

        //shareplanBranchNo = new FieldSetting('sr',false,false,true);
        if (shareplanBranchNo.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Branch_Num__c = getStringValue(data, shareplanBranchNo.shortName);
        shareplanBranchNo.readOnly = getBooleanValue(dataReadOnly, shareplanBranchNo.shortName);
        shareplanBranchNo.isHidden = getBooleanValue(dataHidden, shareplanBranchNo.shortName);

        //shareplanInstitutionNo = new FieldSetting('si',false,false,true);
        if (shareplanInstitutionNo.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Institution_Num__c = getStringValue(data, shareplanInstitutionNo.shortName);
        shareplanInstitutionNo.readOnly = getBooleanValue(dataReadOnly, shareplanInstitutionNo.shortName);
        shareplanInstitutionNo.isHidden = getBooleanValue(dataHidden, shareplanInstitutionNo.shortName);

        //shareplanAccountNo = new FieldSetting('sa',false,false,true);
        if (shareplanAccountNo.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Account__c = getStringValue(data, shareplanAccountNo.shortName);
        shareplanAccountNo.readOnly = getBooleanValue(dataReadOnly, shareplanAccountNo.shortName);
        shareplanAccountNo.isHidden = getBooleanValue(dataHidden, shareplanAccountNo.shortName);

        //shareplanCCExpiryDate = new FieldSetting('sx',false,false,true);
        if (shareplanCCExpiryDate.hasDefaultValue && gw.recurringDonation!=null) gw.recurringDonation.Credit_Card_Expiry_Date__c = getDateValue(data, shareplanCCExpiryDate.shortName);
        shareplanCCExpiryDate.readOnly = getBooleanValue(dataReadOnly, shareplanCCExpiryDate.shortName);
        shareplanCCExpiryDate.isHidden = getBooleanValue(dataHidden, shareplanCCExpiryDate.shortName);

        //Gift
        //giftDate = new FieldSetting('gd');
        if (giftDate.hasDefaultValue) gw.gift.Gift_Date__c = getDateValue(data, giftDate.shortName);
        giftDate.readOnly = getBooleanValue(dataReadOnly, giftDate.shortName);
        giftDate.isHidden = getBooleanValue(dataHidden, giftDate.shortName);
        
        //giftChannel = new FieldSetting('gc');
        if (giftChannel.hasDefaultValue) gw.gift.Channel__c = getStringValue(data, giftChannel.shortName);
        giftChannel.readOnly = getBooleanValue(dataReadOnly, giftChannel.shortName);
        giftChannel.isHidden = getBooleanValue(dataHidden, giftChannel.shortName);
        
        //giftAmount = new FieldSetting('gt');
        if (giftAmount.hasDefaultValue) gw.payment.Amount__c = getDecimalValue(data, giftAmount.shortName);
        giftAmount.readOnly = getBooleanValue(dataReadOnly, giftAmount.shortName);
        giftAmount.isHidden = getBooleanValue(dataHidden, giftAmount.shortName);
        
        //giftType = new FieldSetting('gy');
        if (giftType.hasDefaultValue) gw.gift.Gift_Type__c = getStringValue(data, giftType.shortName);
        giftType.readOnly = getBooleanValue(dataReadOnly, giftType.shortName);
        giftType.isHidden = getBooleanValue(dataHidden, giftType.shortName);
        
        //giftTribute = new FieldSetting('gr');
        //if (giftTribute.hasDefaultValue) gw.gift.Tribute__c = getStringValue(data, giftTribute.shortName);
        //giftTribute.readOnly = getBooleanValue(dataReadOnly, giftTribute.shortName);
        //giftTribute.isHidden = getBooleanValue(dataHidden, giftTribute.shortName);
        
        //giftFoundationCredit = new FieldSetting('gf');
        if (giftFoundationCredit.hasDefaultValue) gw.gift.Foundation_Credit__c = getStringValue(data, giftFoundationCredit.shortName);
        giftFoundationCredit.readOnly = getBooleanValue(dataReadOnly, giftFoundationCredit.shortName);
        giftFoundationCredit.isHidden = getBooleanValue(dataHidden, giftFoundationCredit.shortName);
        
        //giftEvent = new FieldSetting('ge');
        if (giftEvent.hasDefaultValue) gw.gift.Event__c = getStringValue(data, giftEvent.shortName);
        giftEvent.readOnly = getBooleanValue(dataReadOnly, giftEvent.shortName);
        giftEvent.isHidden = getBooleanValue(dataHidden, giftEvent.shortName);
        
        //giftReference = new FieldSetting('gn');
        if (giftReference.hasDefaultValue) gw.gift.Reference__c = getStringValue(data, giftReference.shortName);
        giftReference.readOnly = getBooleanValue(dataReadOnly, giftReference.shortName);
        giftReference.isHidden = getBooleanValue(dataHidden, giftReference.shortName);
        
        //giftSubject = new FieldSetting('gs');
        if (giftSubject.hasDefaultValue) gw.noteSubject = getStringValue(data, giftSubject.shortName);
        giftSubject.readOnly = getBooleanValue(dataReadOnly, giftSubject.shortName);
        giftSubject.isHidden = getBooleanValue(dataHidden, giftSubject.shortName);
        
        //giftNotes = new FieldSetting('go');
        if (giftNotes.hasDefaultValue) gw.noteBody = getStringValue(data, giftNotes.shortName);
        giftNotes.readOnly = getBooleanValue(dataReadOnly, giftNotes.shortName);
        giftNotes.isHidden = getBooleanValue(dataHidden, giftNotes.shortName);
        
        //giftLetter = new FieldSetting('gl');
        if (giftLetter.hasDefaultValue) gw.gift.Letter__c = getStringValue(data, giftLetter.shortName);
        giftLetter.readOnly = getBooleanValue(dataReadOnly, giftLetter.shortName);
        giftLetter.isHidden = getBooleanValue(dataHidden, giftLetter.shortName);
        
        //giftProduct = new FieldSetting('gp');
        //if (giftProduct.hasDefaultValue) gw.gift.Product__c = getStringValue(data, giftProduct.shortName);
        //giftProduct.readOnly = getBooleanValue(dataReadOnly, giftProduct.shortName);
        //giftProduct.isHidden = getBooleanValue(dataHidden, giftProduct.shortName);

        //giftMembership = new FieldSetting('gm');
        //if (giftMembership.hasDefaultValue) gw.gift.Membership__c = getStringValue(data, giftMembership.shortName);
        //giftMembership.readOnly = getBooleanValue(dataReadOnly, giftMembership.shortName);
        //giftMembership.isHidden = getBooleanValue(dataHidden, giftMembership.shortName);
        
        //giftPrimarySolicitor = new FieldSetting('ga');
        if (giftPrimarySolicitor.hasDefaultValue) gw.gift.Primary_Solicitor__c = getStringValue(data, giftPrimarySolicitor.shortName);
        giftPrimarySolicitor.readOnly = getBooleanValue(dataReadOnly, giftPrimarySolicitor.shortName);
        giftPrimarySolicitor.isHidden = getBooleanValue(dataHidden, giftPrimarySolicitor.shortName);
        
        if (giftInternalSolicitor.hasDefaultValue) gw.gift.Internal_Solicitor__c = getStringValue(data, giftInternalSolicitor.shortName);
        giftInternalSolicitor.readOnly = getBooleanValue(dataReadOnly, giftInternalSolicitor.shortName);
        giftInternalSolicitor.isHidden = getBooleanValue(dataHidden, giftInternalSolicitor.shortName);

        //Payment
        //paymentType = new FieldSetting('pt');
        if (paymentType.hasDefaultValue) gw.payment.Payment_Type__c = getStringValue(data, paymentType.shortName);
        paymentType.readOnly = getBooleanValue(dataReadOnly, paymentType.shortName);
        paymentType.isHidden = getBooleanValue(dataHidden, paymentType.shortName);

        //paymentCCType = new FieldSetting('pc');
        if (paymentCCType.hasDefaultValue) gw.payment.Credit_Card_Type__c = getStringValue(data, paymentCCType.shortName);
        paymentCCType.readOnly = getBooleanValue(dataReadOnly, paymentCCType.shortName);
        paymentCCType.isHidden = getBooleanValue(dataHidden, paymentCCType.shortName);

        //paymentChequeDate = new FieldSetting('ph');
        if (paymentChequeDate.hasDefaultValue) gw.payment.Cheque_Date__c = getDateValue(data, paymentChequeDate.shortName);
        paymentChequeDate.readOnly = getBooleanValue(dataReadOnly, paymentChequeDate.shortName);
        paymentChequeDate.isHidden = getBooleanValue(dataHidden, paymentChequeDate.shortName);

        //paymentChequeNo = new FieldSetting('pq');
        if (paymentChequeNo.hasDefaultValue) gw.payment.Cheque_Num__c = getStringValue(data, paymentChequeNo.shortName);
        paymentChequeNo.readOnly = getBooleanValue(dataReadOnly, paymentChequeNo.shortName);
        paymentChequeNo.isHidden = getBooleanValue(dataHidden, paymentChequeNo.shortName);

        //paymentDateDeposited = new FieldSetting('pd');
        if (paymentDateDeposited.hasDefaultValue) gw.payment.Date_Deposited__c = getDateValue(data, paymentDateDeposited.shortName);
        paymentDateDeposited.readOnly = getBooleanValue(dataReadOnly, paymentDateDeposited.shortName);
        paymentDateDeposited.isHidden = getBooleanValue(dataHidden, paymentDateDeposited.shortName);

        //paymentDate = new FieldSetting('pa');
        if (paymentDate.hasDefaultValue) gw.payment.Date__c = getDateValue(data, paymentDate.shortName);
        paymentDate.readOnly = getBooleanValue(dataReadOnly, paymentDate.shortName);
        paymentDate.isHidden = getBooleanValue(dataHidden, paymentDate.shortName);

        //paymentStatus = new FieldSetting('ps');
        if (paymentStatus.hasDefaultValue) gw.payment.Status__c = getStringValue(data, paymentStatus.shortName);
        paymentStatus.readOnly = getBooleanValue(dataReadOnly, paymentStatus.shortName);
        paymentStatus.isHidden = getBooleanValue(dataHidden, paymentStatus.shortName);

        //Receipt
        //receiptType = new FieldSetting('rt');
        if (receiptType.hasDefaultValue) gw.gift.Receipt_Type__c = getStringValue(data, receiptType.shortName);
        receiptType.readOnly = getBooleanValue(dataReadOnly, receiptType.shortName);
        receiptType.isHidden = getBooleanValue(dataHidden, receiptType.shortName);
        
        //receiptNotes = new FieldSetting('rn');
        if (receiptNotes.hasDefaultValue) gw.receipt.Notes__c = getStringValue(data, receiptNotes.shortName);
        receiptNotes.readOnly = getBooleanValue(dataReadOnly, receiptNotes.shortName);
        receiptNotes.isHidden = getBooleanValue(dataHidden, receiptNotes.shortName);
        
        if (receiptAmountEligible.hasDefaultValue) gw.receipt.Amount_Not_Eligible__c = getDecimalValue(data, receiptAmountEligible.shortName);
        receiptAmountEligible.readOnly = getBooleanValue(dataReadOnly, receiptAmountEligible.shortName);
        receiptAmountEligible.isHidden = getBooleanValue(dataHidden, receiptAmountEligible.shortName);        
        
        //Gift allocation
        //giftDetailAmount = new FieldSetting('df');
        if (giftDetailAmount.hasDefaultValue) gw.giftDetail.Amount__c = getDecimalValue(data, giftDetailAmount.shortName);
        giftDetailAmount.readOnly = getBooleanValue(dataReadOnly, giftDetailAmount.shortName);
        giftDetailAmount.isHidden = getBooleanValue(dataHidden, giftDetailAmount.shortName);
        
        //giftDetailFund = new FieldSetting('du');
        if (giftDetailFund.hasDefaultValue) gw.giftDetail.Fund__c = getStringValue(data, giftDetailFund.shortName);
        giftDetailFund.readOnly = getBooleanValue(dataReadOnly, giftDetailFund.shortName);
        giftDetailFund.isHidden = getBooleanValue(dataHidden, giftDetailFund.shortName);
        
        //giftDetailCampaign = new FieldSetting('dc');
        if (giftDetailCampaign.hasDefaultValue) gw.giftDetail.New_Campaign__c = getStringValue(data, giftDetailCampaign.shortName);
        giftDetailCampaign.readOnly = getBooleanValue(dataReadOnly, giftDetailCampaign.shortName);
        giftDetailCampaign.isHidden = getBooleanValue(dataHidden, giftDetailCampaign.shortName);
        
        //giftDetailAppeal = new FieldSetting('de');
        if (giftDetailAppeal.hasDefaultValue) gw.giftDetail.Appeal__c = getStringValue(data, giftDetailAppeal.shortName);
        giftDetailAppeal.readOnly = getBooleanValue(dataReadOnly, giftDetailAppeal.shortName);
        giftDetailAppeal.isHidden = getBooleanValue(dataHidden, giftDetailAppeal.shortName);
        
        //giftDetailPackage = new FieldSetting('dpkg');
        // chamges bikram
        
        if (giftDetailPackage.hasDefaultValue) gw.gift.Package_Name__c = getStringValue(data, giftDetailPackage.shortName);
        giftDetailPackage.readOnly = getBooleanValue(dataReadOnly, giftDetailPackage.shortName);
        giftDetailPackage.isHidden = getBooleanValue(dataHidden, giftDetailPackage.shortName);  
        system.debug('giftDetailPackage.isHidden==>'+giftDetailPackage.isHidden);      
        
        /*if (giftDetailPackage.hasDefaultValue) gw.giftDetail.Package__c = getStringValue(data, giftDetailPackage.shortName);
        giftDetailPackage.readOnly = getBooleanValue(dataReadOnly, giftDetailPackage.shortName);
        giftDetailPackage.isHidden = getBooleanValue(dataHidden, giftDetailPackage.shortName); */
        
        
        if (giftDetailProduct.hasDefaultValue) gw.giftDetail.Product__c = getStringValue(data, giftDetailProduct.shortName);
        giftDetailProduct.readOnly = getBooleanValue(dataReadOnly, giftDetailProduct.shortName);
        giftDetailProduct.isHidden = getBooleanValue(dataHidden, giftDetailProduct.shortName);
        
        //giftDetailTribute = new FieldSetting('dp');
        if (giftDetailTribute.hasDefaultValue) gw.giftDetail.Tribute__c = getStringValue(data, giftDetailTribute.shortName);
        giftDetailTribute.readOnly = getBooleanValue(dataReadOnly, giftDetailTribute.shortName);
        giftDetailTribute.isHidden = getBooleanValue(dataHidden, giftDetailTribute.shortName);
        
        //giftDetailDescription = new FieldSetting('dd');
        if (giftDetailDescription.hasDefaultValue) gw.giftDetail.Description__c = getStringValue(data, giftDetailDescription.shortName);
        giftDetailDescription.readOnly = getBooleanValue(dataReadOnly, giftDetailDescription.shortName);
        giftDetailDescription.isHidden = getBooleanValue(dataHidden, giftDetailDescription.shortName);
        
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------
    public void save(GiftBatchWrapper gw) {
        system.debug('hhkkk- '+gw.giftDetail.Package__c);
      system.debug('hhkkk-- '+gw.giftDetail.New_Campaign__c);
      
        Map<string, string> data = new Map<string, string>();
        Map<string, string> dataReadOnly = new Map<string, string>();
        Map<string, string> dataHidden = new Map<string, string>();

        //Contact
        //constituentID  = new FieldSetting('ci',false,false,true);
        if (constituentID.hasDefaultValue && gw.constituent.Constituent_ID__c != null) data.put (constituentID.shortName, gw.constituent.Constituent_ID__c);
        dataReadOnly.put(constituentID.shortName, toString(constituentID.readOnly));
        dataHidden.put(constituentID.shortName, toString(constituentID.isHidden));

        //constituentFirstName  = new FieldSetting('cf',false,false,true);
        if (constituentFirstName.hasDefaultValue && gw.constituent.FirstName != null) data.put (constituentFirstName.shortName, gw.constituent.FirstName);
        dataReadOnly.put(constituentFirstName.shortName, toString(constituentFirstName.readOnly));
        dataHidden.put(constituentFirstName.shortName, toString(constituentFirstName.isHidden));
        
        //constituentLastName  = new FieldSetting('cl',false,false,false);
        if (constituentLastName.hasDefaultValue && gw.constituent.LastName != null) data.put (constituentLastName.shortName, gw.constituent.LastName);
        dataReadOnly.put(constituentLastName.shortName, toString(constituentLastName.readOnly));
        dataHidden.put(constituentLastName.shortName, toString(constituentLastName.isHidden));

        //constituentMailingStreet  = new FieldSetting('cs');
        if (constituentMailingStreet.hasDefaultValue && gw.constituent.MailingStreet != null) data.put (constituentMailingStreet.shortName, gw.constituent.MailingStreet);
        dataReadOnly.put(constituentMailingStreet.shortName, toString(constituentMailingStreet.readOnly));
        dataHidden.put(constituentMailingStreet.shortName, toString(constituentMailingStreet.isHidden));

        //constituentMailingCity  = new FieldSetting('cc');
        if (constituentMailingCity.hasDefaultValue && gw.constituent.MailingCity != null) data.put (constituentMailingCity.shortName, gw.constituent.MailingCity);
        dataReadOnly.put(constituentMailingCity.shortName, toString(constituentMailingCity.readOnly));
        dataHidden.put(constituentMailingCity.shortName, toString(constituentMailingCity.isHidden));

        //constituentMailingState  = new FieldSetting('cm');
        if (constituentMailingState.hasDefaultValue && gw.constituent.MailingState != null) data.put (constituentMailingState.shortName, gw.constituent.MailingState);
        dataReadOnly.put(constituentMailingState.shortName, toString(constituentMailingState.readOnly));
        dataHidden.put(constituentMailingState.shortName, toString(constituentMailingState.isHidden));

        //constituentMailingPostalCode  = new FieldSetting('cp');
        if (constituentMailingPostalCode.hasDefaultValue && gw.constituent.MailingPostalCode != null) data.put (constituentMailingPostalCode.shortName, gw.constituent.MailingPostalCode);
        dataReadOnly.put(constituentMailingPostalCode.shortName, toString(constituentMailingPostalCode.readOnly));
        dataHidden.put(constituentMailingPostalCode.shortName, toString(constituentMailingPostalCode.isHidden));

        //constituentMailingCountry  = new FieldSetting('cu');
        if (constituentMailingCountry.hasDefaultValue && gw.constituent.MailingCountry != null) data.put (constituentMailingCountry.shortName, gw.constituent.MailingCountry);
        dataReadOnly.put(constituentMailingCountry.shortName, toString(constituentMailingCountry.readOnly));
        dataHidden.put(constituentMailingCountry.shortName, toString(constituentMailingCountry.isHidden));

        //constituentRegion  = new FieldSetting('cr');
        if (constituentRegion.hasDefaultValue && gw.constituent.Region__c != null) data.put (constituentRegion.shortName, gw.constituent.Region__c);
        dataReadOnly.put(constituentRegion.shortName, toString(constituentRegion.readOnly));
        dataHidden.put(constituentRegion.shortName, toString(constituentRegion.isHidden));

        //constituentPhone  = new FieldSetting('ch',false,false,true);
        if (constituentPhone.hasDefaultValue && gw.constituent.Phone != null) data.put (constituentPhone.shortName, gw.constituent.Phone);
        dataReadOnly.put(constituentPhone.shortName, toString(constituentPhone.readOnly));
        dataHidden.put(constituentPhone.shortName, toString(constituentPhone.isHidden));

        //constituentEmail  = new FieldSetting('ce',false,false,true);
        if (constituentEmail.hasDefaultValue && gw.constituent.Email != null) data.put (constituentEmail.shortName, gw.constituent.Email);
        dataReadOnly.put(constituentEmail.shortName, toString(constituentEmail.readOnly));
        dataHidden.put(constituentEmail.shortName, toString(constituentEmail.isHidden));

        //constituentPrimaryAddressee  = new FieldSetting('ca',false,false,true);
        if (constituentPrimaryAddressee.hasDefaultValue && gw.constituent.Primary_Addressee__c != null) data.put (constituentPrimaryAddressee.shortName, gw.constituent.Primary_Addressee__c);
        dataReadOnly.put(constituentPrimaryAddressee.shortName, toString(constituentPrimaryAddressee.readOnly));
        dataHidden.put(constituentPrimaryAddressee.shortName, toString(constituentPrimaryAddressee.isHidden));

        //constituentPrimarySalutation  = new FieldSetting('cn',false,false,true);
        if (constituentPrimarySalutation.hasDefaultValue && gw.constituent.Primary_Salutation__c != null) data.put (constituentPrimarySalutation.shortName, gw.constituent.Primary_Salutation__c);
        dataReadOnly.put(constituentPrimarySalutation.shortName, toString(constituentPrimarySalutation.readOnly));
        dataHidden.put(constituentPrimarySalutation.shortName, toString(constituentPrimarySalutation.isHidden));

        //constituentTradeStatus  = new FieldSetting('ct');
        if (constituentTradeStatus.hasDefaultValue && gw.constituent.Trade_Status__c != null) data.put (constituentTradeStatus.shortName, gw.constituent.Trade_Status__c);
        dataReadOnly.put(constituentTradeStatus.shortName, toString(constituentTradeStatus.readOnly));
        dataHidden.put(constituentTradeStatus.shortName, toString(constituentTradeStatus.isHidden));

        //constituentCodes  = new FieldSetting('co');
        if (constituentCodes.hasDefaultValue && gw.constituent.Constituent_Codes__c != null) data.put (constituentCodes.shortName, gw.constituent.Constituent_Codes__c);
        dataReadOnly.put(constituentCodes.shortName, toString(constituentCodes.readOnly));
        dataHidden.put(constituentCodes.shortName, toString(constituentCodes.isHidden));

        //constituentSolicitCode  = new FieldSetting('cl');
        if (constituentSolicitCode.hasDefaultValue && gw.constituent.Solicit_Codes__c != null) data.put (constituentSolicitCode.shortName, gw.constituent.Solicit_Codes__c);
        dataReadOnly.put(constituentSolicitCode.shortName, toString(constituentSolicitCode.readOnly));
        dataHidden.put(constituentSolicitCode.shortName, toString(constituentSolicitCode.isHidden));

        //constituentHousehold  = new FieldSetting('ck',false,false,true);
        if (constituentHousehold.hasDefaultValue && gw.constituent.Household__c != null) data.put (constituentHousehold.shortName, gw.constituent.Household__c);
        dataReadOnly.put(constituentHousehold.shortName, toString(constituentHousehold.readOnly));
        dataHidden.put(constituentHousehold.shortName, toString(constituentHousehold.isHidden));

        //Organization
        //orgID = new FieldSetting('oi',false,false,true);
        if (orgID.hasDefaultValue && gw.account.Organization_ID__c != null) data.put (orgID.shortName, gw.account.Organization_ID__c);
        dataReadOnly.put(orgID.shortName, toString(orgID.readOnly));
        dataHidden.put(orgID.shortName, toString(orgID.isHidden));

        //orgName = new FieldSetting('on',false,false,false);
        if (orgName.hasDefaultValue && gw.account.Name != null) data.put (orgName.shortName, gw.account.Name);
        dataReadOnly.put(orgName.shortName, toString(orgName.readOnly));
        dataHidden.put(orgName.shortName, toString(orgName.isHidden));
        
        //orgBillingStreet = new FieldSetting('os',false,false,true);
        if (orgBillingStreet.hasDefaultValue && gw.account.BillingStreet != null) data.put (orgBillingStreet.shortName, gw.account.BillingStreet);
        dataReadOnly.put(orgBillingStreet.shortName, toString(orgBillingStreet.readOnly));
        dataHidden.put(orgBillingStreet.shortName, toString(orgBillingStreet.isHidden));

        //orgBillingCity = new FieldSetting('oc');
        if (orgBillingCity.hasDefaultValue && gw.account.BillingCity != null) data.put (orgBillingCity.shortName, gw.account.BillingCity);
        dataReadOnly.put(orgBillingCity.shortName, toString(orgBillingCity.readOnly));
        dataHidden.put(orgBillingCity.shortName, toString(orgBillingCity.isHidden));

        //orgBillingState = new FieldSetting('ot');
        if (orgBillingState.hasDefaultValue && gw.account.BillingState != null) data.put (orgBillingState.shortName, gw.account.BillingState);
        dataReadOnly.put(orgBillingState.shortName, toString(orgBillingState.readOnly));
        dataHidden.put(orgBillingState.shortName, toString(orgBillingState.isHidden));

        //orgBillingPostalCode = new FieldSetting('op',false,false,true);
        if (orgBillingPostalCode.hasDefaultValue && gw.account.BillingPostalCode != null) data.put (orgBillingPostalCode.shortName, gw.account.BillingPostalCode);
        dataReadOnly.put(orgBillingPostalCode.shortName, toString(orgBillingPostalCode.readOnly));
        dataHidden.put(orgBillingPostalCode.shortName, toString(orgBillingPostalCode.isHidden));

        //orgBillingCountry = new FieldSetting('ou');
        if (orgBillingCountry.hasDefaultValue && gw.account.BillingCountry != null) data.put (orgBillingCountry.shortName, gw.account.BillingCountry);
        dataReadOnly.put(orgBillingCountry.shortName, toString(orgBillingCountry.readOnly));
        dataHidden.put(orgBillingCountry.shortName, toString(orgBillingCountry.isHidden));

        //orgRegion = new FieldSetting('or');
        if (orgRegion.hasDefaultValue && gw.account.Region__c != null) data.put(orgRegion.shortName, gw.account.Region__c);
        dataReadOnly.put(orgRegion.shortName, toString(orgRegion.readOnly));
        dataHidden.put(orgRegion.shortName, toString(orgRegion.isHidden));

        //orgPhone = new FieldSetting('oh',false,false,true);
        if (orgPhone.hasDefaultValue && gw.account.Phone != null) data.put(orgPhone.shortName, gw.account.Phone);
        dataReadOnly.put(orgPhone.shortName, toString(orgPhone.readOnly));
        dataHidden.put(orgPhone.shortName, toString(orgPhone.isHidden));

        //orgFax = new FieldSetting('of',false,false,true);
        if (orgFax.hasDefaultValue && gw.account.Fax != null) data.put(orgFax.shortName, gw.account.Fax);
        dataReadOnly.put(orgFax.shortName, toString(orgFax.readOnly));
        dataHidden.put(orgFax.shortName, toString(orgFax.isHidden));

        //orgWebsite = new FieldSetting('ow',false,false,true);
        if (orgWebsite.hasDefaultValue && gw.account.Website != null) data.put(orgWebsite.shortName, gw.account.Website);
        dataReadOnly.put(orgWebsite.shortName, toString(orgWebsite.readOnly));
        dataHidden.put(orgWebsite.shortName, toString(orgWebsite.isHidden));

        //orgEmail = new FieldSetting('oe',false,false,true);
        if (orgEmail.hasDefaultValue && gw.account.Email__c != null) data.put(orgEmail.shortName, gw.account.Email__c);
        dataReadOnly.put(orgEmail.shortName, toString(orgEmail.readOnly));
        dataHidden.put(orgEmail.shortName, toString(orgEmail.isHidden));

        //orgType = new FieldSetting('oy');
        if (orgType.hasDefaultValue && gw.account.Type != null) data.put(orgType.shortName, gw.account.Type);
        dataReadOnly.put(orgType.shortName, toString(orgType.readOnly));
        dataHidden.put(orgType.shortName, toString(orgType.isHidden));

        //orgTradeStatus = new FieldSetting('od');
        if (orgTradeStatus.hasDefaultValue && gw.account.Trade_Status__c != null) data.put(orgTradeStatus.shortName, gw.account.Trade_Status__c);
        dataReadOnly.put(orgTradeStatus.shortName, toString(orgTradeStatus.readOnly));
        dataHidden.put(orgTradeStatus.shortName, toString(orgTradeStatus.isHidden));

        //orgSolicitCode = new FieldSetting('oo');
        if (orgSolicitCode.hasDefaultValue && gw.account.Solicit_Codes__c != null) data.put(orgSolicitCode.shortName, gw.account.Solicit_Codes__c);
        dataReadOnly.put(orgSolicitCode.shortName, toString(orgSolicitCode.readOnly));
        dataHidden.put(orgSolicitCode.shortName, toString(orgSolicitCode.isHidden));

        //orgConstituentCode = new FieldSetting('og');
        if (orgConstituentCode.hasDefaultValue && gw.account.Constituent_Codes__c != null) data.put(orgConstituentCode.shortName, gw.account.Constituent_Codes__c);
        dataReadOnly.put(orgConstituentCode.shortName, toString(orgConstituentCode.readOnly));
        dataHidden.put(orgConstituentCode.shortName, toString(orgConstituentCode.isHidden));
        
        //Shareplan
        //shareplanFrequency = new FieldSetting('sf');
        if (shareplanFrequency.hasDefaultValue && gw.recurringDonation.Frequency__c != null) data.put(shareplanFrequency.shortName, gw.recurringDonation.Frequency__c);
        dataReadOnly.put(shareplanFrequency.shortName, toString(shareplanFrequency.readOnly));
        dataHidden.put(shareplanFrequency.shortName, toString(shareplanFrequency.isHidden));
        
        //shareplanStartDate = new FieldSetting('ss');
        if (shareplanStartDate.hasDefaultValue && gw.recurringDonation.Start_Date__c != null) data.put(shareplanStartDate.shortName, gw.recurringDonation.Start_Date__c.format());
        dataReadOnly.put(shareplanStartDate.shortName, toString(shareplanStartDate.readOnly));
        dataHidden.put(shareplanStartDate.shortName, toString(shareplanStartDate.isHidden));
/*
        //shareplanWithdrawalDate = new FieldSetting('sw');
        if (shareplanWithdrawalDate.hasDefaultValue && gw.recurringDonation.Withdrawal_Date__c != null) data.put (shareplanWithdrawalDate.shortName, gw.recurringDonation.Withdrawal_Date__c);
        dataReadOnly.put(shareplanWithdrawalDate.shortName, toString(shareplanWithdrawalDate.readOnly));
        dataHidden.put(shareplanWithdrawalDate.shortName, toString(shareplanWithdrawalDate.isHidden));
*/
        //shareplanEndDate = new FieldSetting('se');
        if (shareplanEndDate.hasDefaultValue && gw.recurringDonation.End_Date__c != null) data.put(shareplanEndDate.shortName, gw.recurringDonation.End_Date__c.format());
        dataReadOnly.put(shareplanEndDate.shortName, toString(shareplanEndDate.readOnly));
        dataHidden.put(shareplanEndDate.shortName, toString(shareplanEndDate.isHidden));

        //shareplanNumberOfPayments = new FieldSetting('sn');
        if (shareplanNumberOfPayments.hasDefaultValue && gw.recurringDonation.Of_Payments__c != null) data.put(shareplanNumberOfPayments.shortName, gw.recurringDonation.Of_Payments__c.format());
        dataReadOnly.put(shareplanNumberOfPayments.shortName, toString(shareplanNumberOfPayments.readOnly));
        dataHidden.put(shareplanNumberOfPayments.shortName, toString(shareplanNumberOfPayments.isHidden));

        //shareplanBankName = new FieldSetting('sb');
        if (shareplanBankName.hasDefaultValue && gw.recurringDonation.Bank_Name__c != null) data.put(shareplanBankName.shortName, gw.recurringDonation.Bank_Name__c);
        dataReadOnly.put(shareplanBankName.shortName, toString(shareplanBankName.readOnly));
        dataHidden.put(shareplanBankName.shortName, toString(shareplanBankName.isHidden));

        //shareplanBankCity = new FieldSetting('sc');
        if (shareplanBankCity.hasDefaultValue && gw.recurringDonation.Bank_City__c != null) data.put (shareplanBankCity.shortName, gw.recurringDonation.Bank_City__c);
        dataReadOnly.put(shareplanBankCity.shortName, toString(shareplanBankCity.readOnly));
        dataHidden.put(shareplanBankCity.shortName, toString(shareplanBankCity.isHidden));

        //shareplanBranchNo = new FieldSetting('sr',false,false,true);
        if (shareplanBranchNo.hasDefaultValue && gw.recurringDonation.Branch_Num__c != null) data.put(shareplanBranchNo.shortName, gw.recurringDonation.Branch_Num__c);
        dataReadOnly.put(shareplanBranchNo.shortName, toString(shareplanBranchNo.readOnly));
        dataHidden.put(shareplanBranchNo.shortName, toString(shareplanBranchNo.isHidden));

        //shareplanInstitutionNo = new FieldSetting('si',false,false,true);
        if (shareplanInstitutionNo.hasDefaultValue && gw.recurringDonation.Institution_Num__c != null) data.put(shareplanInstitutionNo.shortName, gw.recurringDonation.Institution_Num__c);
        dataReadOnly.put(shareplanInstitutionNo.shortName, toString(shareplanInstitutionNo.readOnly));
        dataHidden.put(shareplanInstitutionNo.shortName, toString(shareplanInstitutionNo.isHidden));

        //shareplanAccountNo = new FieldSetting('sa',false,false,true);
        if (shareplanAccountNo.hasDefaultValue && gw.recurringDonation.Account__c != null) data.put(shareplanAccountNo.shortName, gw.recurringDonation.Account__c);
        dataReadOnly.put(shareplanAccountNo.shortName, toString(shareplanAccountNo.readOnly));
        dataHidden.put(shareplanAccountNo.shortName, toString(shareplanAccountNo.isHidden));

        //shareplanCCExpiryDate = new FieldSetting('sx',false,false,true);
        if (shareplanCCExpiryDate.hasDefaultValue && gw.recurringDonation.Credit_Card_Expiry_Date__c != null) data.put(shareplanCCExpiryDate.shortName, gw.recurringDonation.Credit_Card_Expiry_Date__c.format());
        dataReadOnly.put(shareplanCCExpiryDate.shortName, toString(shareplanCCExpiryDate.readOnly));
        dataHidden.put(shareplanCCExpiryDate.shortName, toString(shareplanCCExpiryDate.isHidden));

        //Gift
        //giftDate = new FieldSetting('gd');
        if (giftDate.hasDefaultValue && gw.gift.Gift_Date__c != null) data.put(giftDate.shortName, gw.gift.Gift_Date__c.format());
        dataReadOnly.put(giftDate.shortName, toString(giftDate.readOnly));
        dataHidden.put(giftDate.shortName, toString(giftDate.isHidden));
        
        //giftChannel = new FieldSetting('gc');
        if (giftChannel.hasDefaultValue && gw.gift.Channel__c != null) data.put(giftChannel.shortName, gw.gift.Channel__c);
        dataReadOnly.put(giftChannel.shortName, toString(giftChannel.readOnly));
        dataHidden.put(giftChannel.shortName, toString(giftChannel.isHidden));
        
        //giftAmount = new FieldSetting('gt');
        if (giftAmount.hasDefaultValue && gw.payment.Amount__c != null) data.put(giftAmount.shortName, gw.payment.Amount__c.format());
        dataReadOnly.put(giftAmount.shortName, toString(giftAmount.readOnly));
        dataHidden.put(giftAmount.shortName, toString(giftAmount.isHidden));
        
        //giftType = new FieldSetting('gy');
        if (giftType.hasDefaultValue && gw.gift.Gift_Type__c != null) data.put(giftType.shortName, gw.gift.Gift_Type__c);
        dataReadOnly.put(giftType.shortName, toString(giftType.readOnly));
        dataHidden.put(giftType.shortName, toString(giftType.isHidden));
        
        //giftTribute = new FieldSetting('gr');
        //if (giftTribute.hasDefaultValue && gw.gift.Tribute__c != null) data.put(giftTribute.shortName, gw.gift.Tribute__c);
        //dataReadOnly.put(giftTribute.shortName, toString(giftTribute.readOnly));
        //dataHidden.put(giftTribute.shortName, toString(giftTribute.isHidden));
        
        //giftFoundationCredit = new FieldSetting('gf');
        if (giftFoundationCredit.hasDefaultValue && gw.gift.Foundation_Credit__c != null) data.put(giftFoundationCredit.shortName, gw.gift.Foundation_Credit__c);
        dataReadOnly.put(giftFoundationCredit.shortName, toString(giftFoundationCredit.readOnly));
        dataHidden.put(giftFoundationCredit.shortName, toString(giftFoundationCredit.isHidden));
        
        //giftEvent = new FieldSetting('ge');
        if (giftEvent.hasDefaultValue && gw.gift.Event__c != null) data.put(giftEvent.shortName, gw.gift.Event__c);
        dataReadOnly.put(giftEvent.shortName, toString(giftEvent.readOnly));
        dataHidden.put(giftEvent.shortName, toString(giftEvent.isHidden));
        
        //giftReference = new FieldSetting('gn');
        if (giftReference.hasDefaultValue && gw.gift.Reference__c != null) data.put(giftReference.shortName, gw.gift.Reference__c);
        dataReadOnly.put(giftReference.shortName, toString(giftReference.readOnly));
        dataHidden.put(giftReference.shortName, toString(giftReference.isHidden));
        
        //giftSubject = new FieldSetting('gs');
        if (giftSubject.hasDefaultValue && gw.noteSubject != null) data.put(giftSubject.shortName, gw.noteSubject);
        dataReadOnly.put(giftSubject.shortName, toString(giftSubject.readOnly));
        dataHidden.put(giftSubject.shortName, toString(giftSubject.isHidden));
        
        //giftNotes = new FieldSetting('go');
        if (giftNotes.hasDefaultValue && gw.noteBody != null) data.put(giftNotes.shortName, gw.noteBody);
        dataReadOnly.put(giftNotes.shortName, toString(giftNotes.readOnly));
        dataHidden.put(giftNotes.shortName, toString(giftNotes.isHidden));
        
        //giftProduct = new FieldSetting('gp');
        //if (giftProduct.hasDefaultValue && gw.gift.Product__c != null) data.put(giftProduct.shortName, gw.gift.Product__c);
        //dataReadOnly.put(giftProduct.shortName, toString(giftProduct.readOnly));
        //dataHidden.put(giftProduct.shortName, toString(giftProduct.isHidden));

        //giftMembership = new FieldSetting('gm');
        //if (giftMembership.hasDefaultValue && gw.gift.Membership__c != null) data.put (giftMembership.shortName, gw.gift.Membership__c);
        //dataReadOnly.put(giftMembership.shortName, toString(giftMembership.readOnly));
        //dataHidden.put(giftMembership.shortName, toString(giftMembership.isHidden));
        
        //giftPrimarySolicitor = new FieldSetting('ga');
        if (giftPrimarySolicitor.hasDefaultValue && gw.gift.Primary_Solicitor__c != null) data.put(giftPrimarySolicitor.shortName, gw.gift.Primary_Solicitor__c);
        dataReadOnly.put(giftPrimarySolicitor.shortName, toString(giftPrimarySolicitor.readOnly));
        dataHidden.put(giftPrimarySolicitor.shortName, toString(giftPrimarySolicitor.isHidden));
        
        if (giftInternalSolicitor.hasDefaultValue && gw.gift.Internal_Solicitor__c != null) data.put(giftInternalSolicitor.shortName, gw.gift.Internal_Solicitor__c);
        dataReadOnly.put(giftInternalSolicitor.shortName, toString(giftInternalSolicitor.readOnly));
        dataHidden.put(giftInternalSolicitor.shortName, toString(giftInternalSolicitor.isHidden));

        //giftLetter = new FieldSetting('gl');
        if (giftLetter.hasDefaultValue && gw.gift.Letter__c != null) data.put(giftLetter.shortName, gw.gift.Letter__c);
        dataReadOnly.put(giftLetter.shortName, toString(giftLetter.readOnly));
        dataHidden.put(giftLetter.shortName, toString(giftLetter.isHidden));
        
        //Payment
        //paymentType = new FieldSetting('pt');
        if (paymentType.hasDefaultValue && gw.payment.Payment_Type__c != null) data.put (paymentType.shortName, gw.payment.Payment_Type__c);
        dataReadOnly.put(paymentType.shortName, toString(paymentType.readOnly));
        dataHidden.put(paymentType.shortName, toString(paymentType.isHidden));

        //paymentCCType = new FieldSetting('pc');
        if (paymentCCType.hasDefaultValue && gw.payment.Credit_Card_Type__c != null) data.put(paymentCCType.shortName, gw.payment.Credit_Card_Type__c);
        dataReadOnly.put(paymentCCType.shortName, toString(paymentCCType.readOnly));
        dataHidden.put(paymentCCType.shortName, toString(paymentCCType.isHidden));

        //paymentChequeDate = new FieldSetting('ph');
        if (paymentChequeDate.hasDefaultValue && gw.payment.Cheque_Date__c != null) data.put(paymentChequeDate.shortName, gw.payment.Cheque_Date__c.format());
        dataReadOnly.put(paymentChequeDate.shortName, toString(paymentChequeDate.readOnly));
        dataHidden.put(paymentChequeDate.shortName, toString(paymentChequeDate.isHidden));

        //paymentChequeNo = new FieldSetting('pq');
        if (paymentChequeNo.hasDefaultValue && gw.payment.Cheque_Num__c != null) data.put(paymentChequeNo.shortName, gw.payment.Cheque_Num__c);
        dataReadOnly.put(paymentChequeNo.shortName, toString(paymentChequeNo.readOnly));
        dataHidden.put(paymentChequeNo.shortName, toString(paymentChequeNo.isHidden));

        //paymentDateDeposited = new FieldSetting('pd');
        if (paymentDateDeposited.hasDefaultValue && gw.payment.Date_Deposited__c != null) data.put(paymentDateDeposited.shortName, gw.payment.Date_Deposited__c.format());
        dataReadOnly.put(paymentDateDeposited.shortName, toString(paymentDateDeposited.readOnly));
        dataHidden.put(paymentDateDeposited.shortName, toString(paymentDateDeposited.isHidden));

        //paymentDate = new FieldSetting('pa');
        if (paymentDate.hasDefaultValue && gw.payment.Date__c != null) data.put(paymentDate.shortName, gw.payment.Date__c.format());
        dataReadOnly.put(paymentDate.shortName, toString(paymentDate.readOnly));
        dataHidden.put(paymentDate.shortName, toString(paymentDate.isHidden));

        //paymentStatus = new FieldSetting('ps');
        if (paymentStatus.hasDefaultValue && gw.payment.Status__c != null) data.put(paymentStatus.shortName, gw.payment.Status__c);
        dataReadOnly.put(paymentStatus.shortName, toString(paymentStatus.readOnly));
        dataHidden.put(paymentStatus.shortName, toString(paymentStatus.isHidden));

        //Receipt
        //receiptType = new FieldSetting('rt');
        if (receiptType.hasDefaultValue && gw.gift.Receipt_Type__c != null) data.put(receiptType.shortName, gw.gift.Receipt_Type__c);
        dataReadOnly.put(receiptType.shortName, toString(receiptType.readOnly));
        dataHidden.put(receiptType.shortName, toString(receiptType.isHidden));
        
        //receiptNotes = new FieldSetting('rn');
        if (receiptNotes.hasDefaultValue && gw.receipt.Notes__c != null) data.put(receiptNotes.shortName, gw.receipt.Notes__c);
        dataReadOnly.put(receiptNotes.shortName, toString(receiptNotes.readOnly));
        dataHidden.put(receiptNotes.shortName, toString(receiptNotes.isHidden));
        
        if (receiptAmountEligible.hasDefaultValue && gw.receipt.Amount_Not_Eligible__c != null) data.put(receiptAmountEligible.shortName, gw.receipt.Amount_Not_Eligible__c.format());
        dataReadOnly.put(receiptAmountEligible.shortName, toString(receiptAmountEligible.readOnly));
        dataHidden.put(receiptAmountEligible.shortName, toString(receiptAmountEligible.isHidden));        
        
        //Gift allocation
        //giftDetailAmount = new FieldSetting('df');
        if (giftDetailAmount.hasDefaultValue && gw.giftDetail.Amount__c != null) data.put (giftDetailAmount.shortName, gw.giftDetail.Amount__c.format());
        dataReadOnly.put(giftDetailAmount.shortName, toString(giftDetailAmount.readOnly));
        dataHidden.put(giftDetailAmount.shortName, toString(giftDetailAmount.isHidden));
        
        //giftDetailFund = new FieldSetting('du');
        if (giftDetailFund.hasDefaultValue && gw.giftDetail.Fund__c != null) data.put(giftDetailFund.shortName, gw.giftDetail.Fund__c);
        dataReadOnly.put(giftDetailFund.shortName, toString(giftDetailFund.readOnly));
        dataHidden.put(giftDetailFund.shortName, toString(giftDetailFund.isHidden));
        
        //giftDetailCampaign = new FieldSetting('dc');
        if (giftDetailCampaign.hasDefaultValue && gw.giftDetail.New_Campaign__c != null) data.put (giftDetailCampaign.shortName, gw.giftDetail.New_Campaign__c);
        dataReadOnly.put(giftDetailCampaign.shortName, toString(giftDetailCampaign.readOnly));
        dataHidden.put(giftDetailCampaign.shortName, toString(giftDetailCampaign.isHidden));

        //giftDetailPackage = new FieldSetting('dpkg');
        // changes bikram
        
        System.debug('gw.gift.Package_Name__c--------- '+gw.gift.Package_Name__c);
        System.debug('giftDetail.Appeal__c--------- '+gw.giftDetail.Appeal__c);
        if (giftDetailPackage .hasDefaultValue && gw.gift.Package_Name__c != null) data.put (giftDetailPackage .shortName, gw.gift.Package_Name__c);
        dataReadOnly.put(giftDetailPackage.shortName, toString(giftDetailPackage.readOnly));
        dataHidden.put(giftDetailPackage.shortName, toString(giftDetailPackage.isHidden));
        System.debug('giftDetailPackage.shortName---------'+giftDetailPackage.shortName);  
        System.debug('giftDetailPackage.isHidden---------'+giftDetailPackage.isHidden);    
        /*
        if (giftDetailPackage .hasDefaultValue && gw.giftDetail.Package__c != null) data.put (giftDetailPackage .shortName, gw.giftDetail.Package__c);
        dataReadOnly.put(giftDetailPackage.shortName, toString(giftDetailPackage.readOnly));
        dataHidden.put(giftDetailPackage.shortName, toString(giftDetailPackage.isHidden));
        */
        //giftDetailAppeal = new FieldSetting('de');
        
        if (giftDetailAppeal.hasDefaultValue && gw.giftDetail.Appeal__c != null) data.put (giftDetailAppeal.shortName, gw.giftDetail.Appeal__c);
        dataReadOnly.put(giftDetailAppeal.shortName, toString(giftDetailAppeal.readOnly));
        dataHidden.put(giftDetailAppeal.shortName, toString(giftDetailAppeal.isHidden));
        
        if (giftDetailProduct.hasDefaultValue && gw.giftDetail.Product__c != null) data.put (giftDetailProduct.shortName, gw.giftDetail.Product__c);
        dataReadOnly.put(giftDetailProduct.shortName, toString(giftDetailProduct.readOnly));
        dataHidden.put(giftDetailProduct.shortName, toString(giftDetailProduct.isHidden));        
        
        //giftDetailPackage = new FieldSetting('dp');
        if (giftDetailTribute.hasDefaultValue && gw.giftDetail.Tribute__c != null) data.put (giftDetailTribute.shortName, gw.giftDetail.Tribute__c);
        dataReadOnly.put(giftDetailTribute.shortName, toString(giftDetailTribute.readOnly));
        dataHidden.put(giftDetailTribute.shortName, toString(giftDetailTribute.isHidden));
        
        //giftDetailDescription = new FieldSetting('dd');
        if (giftDetailDescription.hasDefaultValue && gw.giftDetail.Description__c != null) data.put (giftDetailDescription.shortName, gw.giftDetail.Description__c);
        dataReadOnly.put(giftDetailDescription.shortName, toString(giftDetailDescription.readOnly));
        dataHidden.put(giftDetailDescription.shortName, toString(giftDetailDescription.isHidden));

        User user = [SELECT Id, BatchDefaults__c FROM User WHERE Id = :UserInfo.getUserId()];
        if (user != null) {
            user.BatchDefaults__c = toXML(data);
            user.BatchHiddenFields__c = toXML(dataReadonly);
            user.BatchReadonlys__c = toXML(dataHidden);
            update user;
        }
        System.debug('kpkpkpp---');
    }
    
    private Map<string, string> doParse(string xml) {
        Dom.Document xtr = new Dom.Document();
        Map<string, string> data = new Map<string, string>();
        if (xml == null || xml == '') return data;
        xtr.load(xml);
        
        string[] elements = new string[] { 'defaults' };
        Dom.XMLNode rootNode = xtr.getRootElement();
        
        List<Dom.XMLNode> nodes = rootNode.getChildElements();
        for(Dom.XMLNode child : nodes) {
            Dom.Xmlnodetype nType = child.getNodeType();
            if (nType == Dom.Xmlnodetype.ELEMENT) {
                data.put(child.getName(), child.getText());
            }
        }
        return data;
    }
    private string toXML(Map<string, string> data) {
        string builder = '';
        builder += '<defaults>';
        for (string key : data.keySet()) {
            string element = key;
            string value = (string)data.get(element);
            if (value != null && value != '') {
                builder += '<' + element + '>' + value + '</' + element + '>';
            }
        }
        builder += '</defaults>';
        system.debug('Generated XML: ' + builder);
        return builder;
    }
    private string getStringValue(Map<string, string> data, string propertyName){
        string retVal = null;
        if (propertyName != null) retVal = (string)data.get(propertyName);
        //system.debug('Property: ' + propertyName + ' Value: ' + retVal);
        return retVal;
    }
    private Boolean getBooleanValue(Map<string, string> data, string propertyName){
        string retVal = null;
        if (propertyName != null) retVal = (string)data.get(propertyName);
        system.debug('Data: '+data+' Property: ' + propertyName + ' Value: ' + retVal);
        return toBoolean(retVal);
    }
    private Date getDateValue(Map<string, string> data, string propertyName){
        string retVal = null;
        if (propertyName != null) retVal = (string)data.get(propertyName);
        //system.debug('Property: ' + propertyName + ' Value: ' + retVal);
        return toDate(retVal);
    }
    private Decimal getDecimalValue(Map<string, string> data, string propertyName){
        string retVal = null;
        if (propertyName != null) retVal = (string)data.get(propertyName);
        //system.debug('Property: ' + propertyName + ' Value: ' + retVal);
        return toDecimal(retVal);
    }
    private static String toString(Boolean value){
        if (value != null && value) return 'true';
        else return null;
    }
    
    private static Boolean toBoolean (string value) {
        if (value == null || value == 'false') return false;
        else return true;
    }
    
    private static Decimal toDecimal (string value) {
        if (value == null || value == '') return null;
        else return Decimal.valueOf(value);
    }
    
    private static Date toDate (string value) {
        if (value == null || value == '') return null;
        else return Date.parse (value);
    }
    
}