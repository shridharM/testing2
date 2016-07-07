public with sharing class RecurringGiftManagementExtension {

    private final String ERROR_SYSTEM_UNAVALIABLE = 'The system is temporarly unavaliable, Please try again later.';
    private final String ERROR_INVALID_DATA = 'The data that you have entered was invalid.';
    private final String ERROR_PROCESSING = 'A unexpected error occured while processing your request, Please contact the system administrator.';
    private final String BANK_ERROR_CODE = '900';
    private final String GENERIC_ERROR_CODE = '823';
    private final Integer REQUEST_TIMEOUT = 120000;

    private Date originalBeginDate;
    private BatchGateway4.GatewaySoap Gateway;
    private Boolean FirstTime;
    private Contact individual;

    public String recurringGiftId { get; set; }
    public String recurringGiftName { get; set; }
    public String status { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public decimal amount { get; set; }
    public String frequency { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String postalCode { get; set; }
    public String country { get; set; }
    public String accountType { get; set; }
    public String ccAccountType { get; set; }
    public String achAccountType { get; set; }
    public String accountNumber { get; set; }
    public String routingNumber { get; set; }
    public String expirationDate { get; set; }
    public String sortCode1 { get; set; }
    public String sortCode2 { get; set; }
    public String sortCode3 { get; set; }
    public Date beginDate { get; set; }
    public Decimal scheduleDate { get; set; }
    public Date nextPaymentDate { get; set; }
    public String paymentType { get; set; }
    public Boolean isCC { get; set; }
    public String cancellationReason { get; set; }

    public Boolean UkCancelled { get; set; }
    public Boolean IsReferenceNumberIats { get; set; }
    public Boolean Success { get; set; }
    public List<SelectOption> CountriesList { get; set; }
    public String SelectedCountry { get; set; }
    public List<String> errors;
    public List<String> validationErrors;
    public BatchGateway4.RecurringProfile recurringProfile { get; set; }
    public causeview__Recurring_Donation__c currentRecord { get; set; }
    public List<causeview__RD_Allocation__c> Allocations { get; set; }
    public List<SelectOption> ScheduleDateOptions { get; set; }
    public List<SelectOption> StatusOptions { get; set; }
    public List<SelectOption> FrequencyOptions { get; set; }

    public String RoutingNumberTitle { get; set; }
    public String AllocationTitle { get; set; }

    public RecurringGiftManagementExtension() {
        Initialize();
    }

    public RecurringGiftManagementExtension(ApexPages.StandardController stdController) {
        Initialize();
    }

    private void Initialize() {
        recurringGiftId = ApexPages.currentPage().getParameters().get('id');
        currentRecord = null;

        if (recurringGiftId != null && !String.isBlank(recurringGiftId)) {

            causeview__Recurring_Donation__c[] records = [SELECT causeview__Reference__c, causeview__Type__c, causeview__Sort_Code__c, causeview__Account__c, 
                causeview__Status__c, causeview__Start_Date__c, causeview__Amount__c, causeview__Constituent__r.Id, causeview__Schedule_Date__c,
                causeview__Credit_Card_Expiry_Date__c, causeview__Credit_Card_Type__c, causeview__Credit_Card__c, causeview__Frequency__c, causeview__Cancellation_Reason__c, 
                causeview__Next_Payment_Date__c, causeview__New_Payment_Start_Date__c, causeview__Branch_Num__c, Id, Name 
                FROM causeview__Recurring_Donation__c
                WHERE Id = :recurringGiftId];

            if (records != null && records.size() > 0) {
                
                IsReferenceNumberIats = IsGatewayIats(records[0].causeview__Reference__c);

                Allocations = [SELECT causeview__Amount__c, causeview__New_Campaign__r.Name, causeview__Fund__r.Name, Id, Name 
                FROM causeview__RD_Allocation__c 
                WHERE causeview__Recurring_Gift__c = :recurringGiftId AND causeview__Active__c = true];

                if (AreAllocationsInitialized()) {
                    
                    List<Contact> contacts = [SELECT Id, firstname, lastname, mailingState, 
                        MailingPostalCode, MailingCountry, MailingStreet, MailingCity
                        FROM contact 
                        WHERE Id =: records[0].causeview__Constituent__r.Id];

                    if (contacts != null && contacts.size() > 0) {
                        currentRecord = records[0];
                        individual = contacts[0];

                        Success = false;
                        FirstTime = true;

                        InitializeTitles();
                        InitializeGateway();
                        InitializeProperties();
                        InitializeStatusDropDown();
                        InitializeCountryDropDown();
                        InitializeFrequencyDropDown();
                        InitializeScheduleDateDropDown();
                    }
                }
            }
        }
    }

    public PageReference redirect() {
        if (currentRecord == null) {
            return CreateErrorPageReference();
        } else  { 
            if (IsRecurringGiftOffline()) {
                return CreateRedirectToDefaultEditPage();
            } else {
                return null;
            }
        }
    }
    
    public PageReference updateProfile() {
        PageReference pageRef = null;
        
        try
        {        
            if (currentRecord != null) {
                errors = new List<String>();
                AssignRecurringProfile();
                FirstTime = false;
                
                if (!Test.isRunningTest()) {
                    try {
                        BatchGateway4.TransactionResult updateResult = Gateway.UpdateRecurringGift(recurringProfile);
                        
                        if (updateResult != null) {

                            if (updateResult.TransactionStatus == 'success') {
                                if (DoesResultHaveErrors(updateResult)) {
                                    HandleErrors(updateResult);
                                } else {
                                    UpdateRecurringGift(); 
                                }
                            } else {
                                if (DoesResultHaveErrors(updateResult)) {
                                    HandleErrors(updateResult);
                                }
                            }
                        } else {
                            errors = new List<String> {
                                ERROR_SYSTEM_UNAVALIABLE
                            };
                        }
                    } catch (Exception ex) {
                        if (ex.getMessage().contains('XML')) {
                            errors.add(ERROR_INVALID_DATA);
                        } else {
                            errors.add(GetExceptionMessage(ex));
                        }
                    }
                }
            } else {
                pageRef = CreateErrorPageReference();
            }
        } catch (Exception ex) {
            errors.add(GetExceptionMessage(ex));
        }

        return pageRef;
    }
    
    public PageReference cancel(){
        String retUrl = '/' + recurringGiftId;
        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public String[] getErrors() {
        return errors;
    }

    public String[] getValidationErrors() {
        return validationErrors;
    }

    private PageReference CreateRedirectToDefaultEditPage() {
        String retUrl = '/' + recurringGiftId + '/e?nooverride=1&retURL=' + recurringGiftId;
        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }

    private void InitializeTitles() {
        AllocationTitle = 'Recurring Gift Allocation';

        if (IsThereMoreThanOneAllocation()) {
            AllocationTitle += 's';
        }

        RoutingNumberTitle = 'Routing Number';

        String locale = UserInfo.getLocale();

        if (IsLocaleCanada(locale)) {
            RoutingNumberTitle = 'Bank and Transit Number';
        } else if (IsLocaleAustralia(locale)) {
            RoutingNumberTitle = 'BSB Number';
        }
    }

    private void InitializeGateway() {
        Gateway = new BatchGateway4.GatewaySoap();
        Gateway.timeout_x = REQUEST_TIMEOUT;

        if (!Test.isRunningTest()) {
            causeview__BatchSettings__c settingObj = causeview__BatchSettings__c.getInstance('Default');

            if (settingObj != null) {
                Gateway.endpoint_x = settingObj.GatewayUrl__c;
            }
        }
    }

    private void InitializeProperties() {
        status = currentRecord.causeview__Status__c;

        ValidateCurrentRecord();

        recurringGiftName = currentRecord.name;
        beginDate = currentRecord.causeview__Start_Date__c;
        originalBeginDate = currentRecord.causeview__Start_Date__c;

        if (IsNewPaymentStartDateAssigned()) {
            beginDate = currentRecord.causeview__New_Payment_Start_Date__c;
            originalBeginDate = currentRecord.causeview__New_Payment_Start_Date__c;
        }
        
        if (IsScheduleDateAssigned()) {
            scheduleDate = currentRecord.causeview__Schedule_Date__c;
        } else {
            scheduleDate = beginDate.day();
        }
        
        firstName = individual.firstname;
        lastName = individual.lastname;
        amount = currentRecord.causeview__Amount__c;
        frequency = currentRecord.causeview__Frequency__c;
        address = individual.MailingStreet;
        city = individual.MailingCity;
        state = individual.MailingState;
        postalCode = individual.MailingPostalCode;

        if (individual.MailingCountry == null || individual.MailingCountry == '') {
            User currentUser = [SELECT Country FROM User WHERE Id =:UserInfo.getUserId()];
            if (currentUser != null && currentUser.Country != null) {
                country = currentUser.Country;
            }
        } else {
            country = individual.MailingCountry;
        }
        
        accountNumber = currentRecord.causeview__Account__c;
        nextPaymentDate = currentRecord.causeview__Next_Payment_Date__c;
        paymentType = currentRecord.causeview__Type__c;
        cancellationReason = currentRecord.causeview__Cancellation_Reason__c;
        isCC = false;

        if (IsPaymentTypeCreditCard()) {
            isCC = true;
            if (currentRecord.causeview__Credit_Card_Expiry_Date__c != null) {
                Integer year = currentRecord.causeview__Credit_Card_Expiry_Date__c.year();
                Integer month = currentRecord.causeview__Credit_Card_Expiry_Date__c.month();
                String stringMonth = (month < 10) ? '0' + String.valueOf(month) : String.valueOf(month);
                expirationDate = stringMonth + '/' + String.valueOf(year).right(2);
            } else {
                expirationDate = null;
            }
            accountNumber = currentRecord.causeview__Credit_Card__c;
            ccAccountType = ConvertCreditCardTypeToIats();
        } else if (IsPaymentTypeAch()) {
            routingNumber = currentRecord.causeview__Branch_Num__c;
        } else if (IsPaymentTypeUkDirectDebit()) {
            UkCancelled = (FirstTime && IsStatusCancelled());
            routingNumber = currentRecord.causeview__Sort_Code__c;
            if (routingNumber != null && routingNumber != '') {
	            sortCode1 = routingNumber.substring(0, 2);
	            sortCode2 = routingNumber.substring(2, 4);
	            sortCode3 = '**';
            } else {
            	sortCode1 = '';
	            sortCode2 = '';
	            sortCode3 = '';
            }
            accountType = 'Undefined';
        }
    }

    private void InitializeCountryDropDown() {
        if (!Test.isRunningTest()) {
            BatchGateway4.CountryHelper countries = Gateway.GetCountries();
            if (countries != null) {
                CountriesList = new List<SelectOption>();
                if (countries.Countries != null && countries.Countries.Country.size() > 0) {
                    for (Integer i = 0; i < countries.Countries.Country.size(); i++) {
                        BatchGateway4.Country tempCountry = countries.Countries.Country[i];
                        CountriesList.add(new SelectOption(tempCountry.CountryCode, tempCountry.DisplayName));
                        if (country == tempCountry.DisplayName) {
                            SelectedCountry = tempCountry.CountryCode;
                        }
                    }
                }
            }
        }
    }

    private void InitializeScheduleDateDropDown() {
        ScheduleDateOptions = new List<SelectOption>();

        for (Integer day = 1; day <= 31; day++) {
            ScheduleDateOptions.add(new SelectOption(string.valueOf(day), string.valueOf(day)));
        }
    }

    private void InitializeStatusDropDown() {
        StatusOptions = new List<SelectOption>();

        StatusOptions.add(new SelectOption('Active', 'Active'));
        StatusOptions.add(new SelectOption('On Hold', 'On Hold'));
        StatusOptions.add(new SelectOption('Cancelled', 'Cancelled'));
    }

    private void InitializeFrequencyDropDown() {
        FrequencyOptions = new List<SelectOption>();

        if (currentRecord.causeview__Frequency__c == 'Weekly') {
            FrequencyOptions.add(new SelectOption('Weekly', 'Weekly'));
        }

        FrequencyOptions.add(new SelectOption('Monthly', 'Monthly'));
        FrequencyOptions.add(new SelectOption('Quarterly', 'Quarterly'));
        FrequencyOptions.add(new SelectOption('Annually', 'Annually'));
    }

    private void AssignRecurringProfile() {
        recurringProfile = new BatchGateway4.RecurringProfile();

        if (IsPaymentTypeCreditCard()) {
            accountType = ccAccountType;
        } else {
            accountType = 'Undefined';
        }
		
		if(accountNumber != null && accountNumber != '') {
        	recurringProfile.AccountNumber = accountNumber;
		}
        recurringProfile.AccountType = accountType;
        recurringProfile.Address = address;

        Decimal newAmount = 0;
        for (causeview__RD_Allocation__c allocation : Allocations) {
            allocation.causeview__Amount__c = allocation.causeview__Amount__c.setScale(2);
            newAmount += allocation.causeview__Amount__c;
        }

        recurringProfile.Amount = newAmount.setScale(2);
        recurringProfile.BeginDate = beginDate;
        recurringProfile.ScheduleDate = Integer.valueOf(scheduleDate);
        recurringProfile.City = city;
        recurringProfile.Country = country;
        recurringProfile.CustomerCode = currentRecord.causeview__Reference__c;
        recurringProfile.Cvv = '';
        recurringProfile.FirstName = firstName;      
        recurringProfile.Frequency = frequency;
        recurringProfile.IsCC = isCC;
        recurringProfile.LastName = lastName;

        if (nextPaymentDate == null) {
            nextPaymentDate = DetermineNextPaymentDate();
        }

        recurringProfile.NextPaymentDate = nextPaymentDate;
        recurringProfile.PaymentType = paymentType;
        recurringProfile.PostalCode = postalCode;

        if (IsPaymentTypeUkDirectDebit()) {
            recurringProfile.RoutingNumber = sortCode1 + sortCode2 + sortCode3;
            recurringProfile.AccountType = 'Undefined';
        } else if (IsPaymentTypeAch()) {
        	if (routingNumber != null && routingNumber != '') {
            	recurringProfile.RoutingNumber = routingNumber;
        	} else {
        		recurringProfile.RoutingNumber = '';
        	}
        } else if (IsPaymentTypeCreditCard()) {
            recurringProfile.ExpirationDate = expirationDate;
        }

        recurringProfile.State = state;
        recurringProfile.Status = status;
    }

    public void UpdateRecurringGift() {
        Success = true; 

        if (DidBeginDateChange()) {
            currentRecord.causeview__New_Payment_Start_Date__c = beginDate;
            currentRecord.causeview__Next_Payment_Date__c = DetermineNextPaymentDate();
        }   
        
        currentRecord.causeview__Status__c = status;
        currentRecord.causeview__Frequency__c = frequency;
        //currentRecord.causeview__Account__c = MaskAccountNumber();

        if (IsPaymentTypeUkDirectDebit()) {
            currentRecord.causeview__Sort_Code__c = sortCode1 + sortCode2 + sortCode3;
        } else if (IsPaymentTypeAch()) {
            currentRecord.causeview__Branch_Num__c = MaskRoutingNumber();
            //usert story :https://www.pivotaltracker.com/story/show/119538481
            currentRecord.causeview__Account__c = MaskAccountNumber();
        } else if (IsPaymentTypeCreditCard()) {
            currentRecord.causeview__Credit_Card__c = MaskAccountNumber();
            currentRecord.causeview__Credit_Card_Type__c = ConvertCreditCardTypeFromIats();
            currentRecord.causeview__Credit_Card_Expiry_Date__c = ParseCreditCardExpiry();
        }

        currentRecord.causeview__Cancellation_Reason__c = null;
        currentRecord.causeview__End_Date__c = null;

        if (IsStatusCancelled()) {
            currentRecord.causeview__End_Date__c = Date.today();
            currentRecord.causeview__Next_Payment_Date__c = null;
            currentRecord.causeview__Schedule_Date__c = null;
            currentRecord.causeview__Cancellation_Reason__c = cancellationReason;
        } else if (IsStatusOnHold()) {
            currentRecord.causeview__Next_Payment_Date__c = null;
            currentRecord.causeview__Schedule_Date__c = null;
        } else {

            if (DidBeginDateChange()) {
                currentRecord.causeview__New_Payment_Start_Date__c = beginDate;
            }

            currentRecord.causeview__Schedule_Date__c = scheduleDate;  
            currentRecord.causeview__Next_Payment_Date__c = DetermineNextPaymentDate();
        }

        individual.MailingStreet = address;
        individual.MailingCity = city;
        individual.MailingState = state;
        individual.MailingPostalCode = postalCode;
        individual.MailingCountry = country;

        try {
            update currentRecord;
            update Allocations;
            update individual;
        } catch (DmlException ex) {
            Success = false;          
            errors.add(GetExceptionMessage(ex));
        }
    }

    public void AddValidationError(string message) {
        if (validationErrors == null) {
            validationErrors = new List<String>();
            Success = false;
        }
        
        validationErrors.add(message);
    }

    private String MaskAccountNumber() {
    	if(accountNumber != null && accountNumber != '') {
	        String maskedAccountNumber = '';
	        String lastFourAccountNumber = accountNumber.substring(accountNumber.length() - 4, accountNumber.length());
	        for (Integer i = 0; i < accountNumber.length() - 4; i++) {
	            maskedAccountNumber += '*';
	        }
	        return maskedAccountNumber + lastFourAccountNumber;
    	} else {
    		return '';
    	}
    }

    private String MaskRoutingNumber() {
    	if(routingNumber != null && routingNumber != '') {
	        String maskedRoutingNumber = routingNumber.substring(0, 4);
	        for (Integer i = 0; i < routingNumber.length() - 4; i++) {
	            maskedRoutingNumber += '*';
	        }
	        return maskedRoutingNumber;
    	} else {
    		return '';
    	}
    }

    private String ConvertCreditCardTypeToIats() {
        String cardType = currentRecord.causeview__Credit_Card_Type__c;
        if (cardType == 'Visa') {
            return 'VISA';
        } else if (cardType == 'MasterCard') {
            return 'MC';
        } else if (cardType == 'American Express') {
            return'AMX';
        } else {
            return 'DSC';
        }
    }

    private String ConvertCreditCardTypeFromIats() {
        String cardType = accountType;
        if (cardType == 'VISA') {
            return 'Visa';
        } else if (cardType == 'MC') {
            return 'MasterCard';
        } else if (cardType == 'AMX') {
            return 'American Express';
        } else {
            return 'Discover';
        }
    }

    private Date ParseCreditCardExpiry() {
        if (expirationDate != null && expirationDate != '') {
            String[] expiry = expirationDate.split('/');
            Integer month = Integer.valueOf(expiry[0]);
            Integer year = 2000 + Integer.valueOf(expiry[1]);
            return Date.newInstance(year, month, 1);
        } else {
            return null;
        }        
    }

    private Date DetermineNextPaymentDate() {
        if (IsFrequencyMonthly()) {
            return GetNextPaymentDate(1);
        } else if (IsFrequencyQuarterly()) {
            return GetNextPaymentDate(3);
        } else { // annually
            return GetNextPaymentDate(12);
        } 
    }

    private Date GetNextPaymentDate(Integer monthOffset) {
        Date paymentDateWithOffset = beginDate.addMonths(monthOffset);
        Integer daysInNextPaymentDateMonth = Date.daysInMonth(paymentDateWithOffset.year(), paymentDateWithOffset.month());
        Integer dayToUse = (!IsScheduleDateSameAsBeginDate()) ? Integer.valueOf(scheduleDate) : beginDate.day();
        Integer monthToUse = (scheduleDate >= beginDate.day()) ? beginDate.month() : paymentDateWithOffset.month();

        if (daysInNextPaymentDateMonth < dayToUse) {
            return Date.newInstance(paymentDateWithOffset.year(), paymentDateWithOffset.month(), daysInNextPaymentDateMonth);
        } else {
            return Date.newInstance(paymentDateWithOffset.year(), paymentDateWithOffset.month(), dayToUse);
        }
    }

    private boolean DoesResultHaveErrors(BatchGateway4.TransactionResult result) {
        return (result.Errors != null && result.Errors.ErrorMessages.size() > 0);
    }

    private void HandleErrors(BatchGateway4.TransactionResult result) {
        for (Integer i = 0; i < result.Errors.ErrorMessages.size(); i++) {
            if (result.Errors.ErrorMessages[i].ErrorCode == GENERIC_ERROR_CODE) {
                errors.add(ERROR_PROCESSING);
            } else if (result.Errors.ErrorMessages[i].ErrorCode == BANK_ERROR_CODE) {
                if (result.Errors.ErrorMessages[i].Error.contains('cancelled')) {
                    UpdateRecurringGift(); 
                } else {
                    errors.add('Bank Error: ' + result.Errors.ErrorMessages[i].Error);    
                }
            } else {
                errors.add('Gateway Error: ' + result.Errors.ErrorMessages[i].Error);
            }
        }
    }

    private void ValidateCurrentRecord() {
        if (!IsStatusOnHold() && !IsStatusCancelled()) {
            if (currentRecord.causeview__Next_Payment_Date__c == null) {
                AddValidationError('Please ensure the next payment date is populated on the recurring gift.');
            }
        }  
    }

    private PageReference CreateErrorPageReference() {
        PageReference pageRef = new PageReference('/' + recurringGiftId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    private String GetExceptionMessage(Exception ex) {
        return ex.getMessage().replace('\'', '').replace('\n', '');
    }

    private Boolean IsScheduleDateSameAsBeginDate() {
        return scheduleDate == beginDate.day();
    }

    private Boolean IsGatewayIats(String recurringId) {
        if (recurringId != null && recurringId != '') {
            return Pattern.matches('[A-Z][0-9]+', recurringId);
        } else {
            return false;
        }
    }

    private Boolean IsFrequencyMonthly() {
        return (frequency == 'Monthly');
    }

    private Boolean IsFrequencyQuarterly() {
        return (frequency == 'Quarterly');
    }

    private Boolean IsStatusCancelled() {
        return (status == 'Cancelled');
    }

    private Boolean IsStatusOnHold() {
        return (status == 'On Hold');
    }

    private Boolean IsPaymentTypeCreditCard() {
        return (paymentType == 'Credit Card');
    }

    private Boolean IsPaymentTypeAch() {
        return (paymentType == 'ACH/PAD' || paymentType == 'ACH/EFT');
    }

    private Boolean IsPaymentTypeUkDirectDebit() {
        return (paymentType == 'UK Direct Debit');
    }

    private Boolean IsLocaleCanada(String locale) {
        return (locale == 'en_CA');
    }

    private Boolean IsLocaleAustralia(String locale) {
        return (locale == 'en_AU');
    }

    private Boolean DidBeginDateChange() {
        return (originalBeginDate != beginDate);
    }

    private Boolean IsNewPaymentStartDateAssigned() {
        return (currentRecord.causeview__New_Payment_Start_Date__c != null);
    }

    private Boolean AreAllocationsInitialized() {
        return (Allocations != null && Allocations.size() > 0);
    }

    private Boolean IsThereMoreThanOneAllocation() {
        return (Allocations.size() > 1);
    }

    private Boolean IsScheduleDateAssigned() {
        return (currentRecord.causeview__Schedule_Date__c != null);
    }

    private Boolean IsRecurringGiftOffline() {
        return ((!IsPaymentTypeCreditCard() && !IsPaymentTypeAch() && !IsPaymentTypeUkDirectDebit()) || (paymentType == null || paymentType == ''));
    }
}
