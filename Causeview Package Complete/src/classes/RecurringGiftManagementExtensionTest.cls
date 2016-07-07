@isTest
global class RecurringGiftManagementExtensionTest {

    public static testMethod void testNoIdInUrl() {
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        String nextPage = controller.updateProfile().getUrl();

        // Verify that the page fails when there are no url parameters
        //System.assertEquals('/', nextPage);
    }
    
    public static testMethod void testRedirectValid() {
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        String actualRedirect = controller.redirect().getUrl();

        //System.assertEquals('/', actualRedirect, 'Redirect url was not correct');
    }

    public static testMethod void testAddValidationError() {
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        String validationMessage = 'Test';
        controller.AddValidationError(validationMessage);

        String[] validationErrors = controller.getValidationErrors();

        System.assertEquals(validationMessage, validationErrors[0], 'Validation Error was not the same.');
    }

    public static testMethod void testOfflineRecurringGift() {
        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c offlineRecord = InitializeOffline(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(offlineRecord);    

        ApexPages.currentPage().getParameters().put('id', offlineRecord.Id);   

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();         
        String actualRedirect = controller.redirect().getUrl();
        String expectedRedirect = '/' + offlineRecord.Id + '/e?nooverride=1&retURL=' + offlineRecord.Id;

        System.assertEquals(expectedRedirect, actualRedirect, 'Offline redirect urls were not the same.');
    }
    
    public static testMethod void testRedirectInValid() {
        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        PageReference actualRedirect = controller.redirect();

        System.assertEquals(null, actualRedirect, 'Redirect url was not correct');
    }

    public static testMethod void testCancel() {
        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        String cancelPage = controller.cancel().getUrl();

        System.assertEquals('/' + ukDirectDebitRecord.Id, cancelPage, 'Cancel Url was not correct.');
    }

    public static testMethod void testGetErrors() {
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();

        // Test getErrors
        List<String> expectedErrors = new List<String>();
        expectedErrors.add('Gateway down.');
        expectedErrors.add('Incorrect Data');

        controller.errors = expectedErrors;
        String[] actualErrors = controller.getErrors();
        System.assertEquals(actualErrors[0], expectedErrors[0], 'Error 1 was not correct.');
        System.assertEquals(actualErrors[1], expectedErrors[1], 'Error 2 was not correct.');
    }

    public static testMethod void testUpdateRecurringGiftUkDirectDebit() {
        
        Decimal amount = 2.12;
        String sortCode = '000000';
        String accountNumber = '87654321';
        String status = 'On Hold';
                  
        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        // instantiate a new controller with updated amount
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.Allocations[0].causeview__Amount__c = amount;
        controller.accountNumber = accountNumber;
        controller.routingNumber = sortCode;
        controller.status = status;

        controller.UpdateRecurringGift();

        ukDirectDebitRecord = [SELECT Id, causeview__Amount__c, causeview__Account__c, causeview__Sort_Code__c, causeview__Status__c FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        String maskedAccountNumber = '****' + accountNumber.substring(accountNumber.length() - 4, accountNumber.length());
        sortCode = sortCode.substring(0, 4) + '**';

        System.assertEquals(amount, ukDirectDebitRecord.causeview__Amount__c, 'Amounts were not equal.');
        System.assertEquals(maskedAccountNumber, ukDirectDebitRecord.causeview__Account__c, 'Account numbers were not equal.');
        System.assertEquals(sortCode, ukDirectDebitRecord.causeview__Sort_Code__c, 'Sort Codes were not equal.');
        System.assertEquals(status, ukDirectDebitRecord.causeview__Status__c, 'Status was not equal.');
    }

    public static testMethod void testUpdateRecurringGiftAch() {
        
        Decimal amount = 2.12;
        String routingNumber = '111111111';
        String accountNumber = '12345678';
        String status = 'On Hold';
                  
        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c achRecord = InitializeAch(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(achRecord);

        ApexPages.currentPage().getParameters().put('id', achRecord.Id);

        // instantiate a new controller with updated amount
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.Allocations[0].causeview__Amount__c = amount;
        controller.accountNumber = accountNumber;
        controller.routingNumber = routingNumber;
        controller.status = status;

        controller.UpdateRecurringGift();

        achRecord = [SELECT Id, causeview__Amount__c, causeview__Account__c, causeview__Branch_Num__c, causeview__Status__c FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        String maskedAccountNumber = '****' + accountNumber.substring(accountNumber.length() - 4, accountNumber.length());
        String maskedRoutingNumber = routingNumber.substring(0, 4);

        for (Integer i = 0; i < routingNumber.length() - 4; i++) {
            maskedRoutingNumber += '*';
        }

        System.assertEquals(amount, achRecord.causeview__Amount__c, 'Amounts were not equal.');
        System.assertEquals(maskedAccountNumber, achRecord.causeview__Account__c, 'Account numbers were not equal.');
        System.assertEquals(maskedRoutingNumber, achRecord.causeview__Branch_Num__c, 'Routing numbers were not equal.');
        System.assertEquals(status, achRecord.causeview__Status__c, 'Status was not equal.');
    }

    public static testMethod void testUpdateRecurringGiftCreditCard() {
        
        Decimal amount = 2.12;
        String creditCardNumber = '5111111111111118';
        String cardType = 'MC';
        String frequency = 'Quarterly';
                  
        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(ccRecord);

        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);

        // instantiate a new controller with updated amount
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.Allocations[0].causeview__Amount__c = amount;
        controller.accountNumber = creditCardNumber;
        controller.accountType = cardType;
        controller.frequency = frequency;

        controller.UpdateRecurringGift();

        ccRecord = [SELECT Id, causeview__Amount__c, causeview__Credit_Card_Type__c, causeview__Credit_Card__c, causeview__Credit_Card_Expiry_Date__c, causeview__Frequency__c FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        String maskedCreditCardNumber = '';
        String lastFourAccountNumber = creditCardNumber.substring(creditCardNumber.length() - 4, creditCardNumber.length());
        for (Integer i = 0; i < creditCardNumber.length() - 4; i++) {
            maskedCreditCardNumber += '*';
        }

        maskedCreditCardNumber = maskedCreditCardNumber + lastFourAccountNumber;

        cardType = 'MasterCard';

        System.assertEquals(amount, ccRecord.causeview__Amount__c, 'Amounts were not equal.');
        System.assertEquals(maskedCreditCardNumber, ccRecord.causeview__Credit_Card__c, 'Credit Card numbers were not equal.');
        System.assertEquals(cardType, ccRecord.causeview__Credit_Card_Type__c, 'Credit Card types were not equal.');
        System.assertEquals(frequency, ccRecord.causeview__Frequency__c, 'Frequency was not equal.');
    }

    public static testMethod void testUpdateRecurringGiftCancelledUkDirectDebit() {
        
        String status = 'Cancelled';
                  
        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        // instantiate a new controller with updated amount
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.status = status;

        controller.UpdateRecurringGift();

        ukDirectDebitRecord = [SELECT Id, causeview__Status__c FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        System.assertEquals(status, ukDirectDebitRecord.causeview__Status__c, 'Status was not equal.');
    }

    public static testMethod void testUpdateRecurringGiftNextPaymentDateUkDirectDebit() {
        
        Date scheduleDate = Date.newInstance(2016, 03, 14);
                  
        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        Date nextPaymentDate = scheduleDate.addMonths(1);

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.beginDate = nextPaymentDate;

        controller.UpdateRecurringGift();

        ukDirectDebitRecord = [SELECT Id, causeview__Next_Payment_Date__c FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        nextPaymentDate = nextPaymentDate.addMonths(1);
        System.assertEquals(nextPaymentDate, ukDirectDebitRecord.causeview__Next_Payment_Date__c, 'Next payment date was not equal.');
    }

    public static testMethod void testUpdateProfile() {
        Decimal amount = 2.12;

        Contact individual = InitializeContact();
        causeview__Recurring_Donation__c achRecord = InitializeAch(individual);
        causeview__RD_Allocation__c allocation = InitializeAllocation(achRecord);

        ApexPages.currentPage().getParameters().put('id', achRecord.Id);     

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.Allocations[0].causeview__Amount__c = amount;

        PageReference updateProfilePageReference = controller.updateProfile();
        controller.UpdateRecurringGift();

        achRecord = [SELECT Id, causeview__Amount__c, causeview__Account__c, causeview__Branch_Num__c, causeview__Status__c FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        System.assertEquals(amount, achRecord.causeview__Amount__c, 'Amounts were not equal.');
    }

    private static Contact InitializeContact() {
        Contact individual = new Contact(
            firstName = 'QA',
            lastName = 'Tester',
            MailingStreet = '355 Apple Creek Blvd.',
            MailingCity = 'Markham',
            MailingState = 'Ontario', 
            MailingPostalCode = 'L3R 9X7',
            MailingCountry = 'Canada'
            );

        insert individual;

        individual = [SELECT Id FROM Contact WHERE MailingCountry = 'Canada'];

        return individual;
    }

    private static causeview__Recurring_Donation__c InitializeAch(Contact individual) {
        causeview__Recurring_Donation__c achRecord = new causeview__Recurring_Donation__c(
            causeview__Amount__c = 1.00,
            causeview__Reference__c = 'A226854',
            causeview__Type__c = 'ACH/PAD',
            causeview__Start_Date__c = Date.newInstance(2016, 03, 14),
            causeview__Schedule_Date__c = 14,
            causeview__Frequency__c = 'Monthly', 
            causeview__Status__c = 'Active',
            causeview__Account__c = '**3456',
            causeview__Branch_Num__c = '12300000',
            causeview__Constituent__c = individual.Id
            );

        insert achRecord;

        achRecord = [SELECT Id FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        return achRecord;
    }

    private static causeview__Recurring_Donation__c InitializeCreditCard(Contact individual) {
        causeview__Recurring_Donation__c ccRecord = new causeview__Recurring_Donation__c(
            causeview__Amount__c = 1.00,
            causeview__Reference__c = 'A226854',
            causeview__Type__c = 'Credit Card',
            causeview__Start_Date__c = Date.newInstance(2016, 03, 14),
            causeview__Schedule_Date__c = 14,
            causeview__Frequency__c = 'Monthly', 
            causeview__Status__c = 'Active',
            causeview__Credit_Card__c = '************2220',
            causeview__Credit_Card_Type__c = 'Visa',
            causeview__Credit_Card_Expiry_Date__c = Date.newInstance(2025, 1, 1),
            causeview__Constituent__c = individual.Id
            );

        insert ccRecord;

        ccRecord = [SELECT Id FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        return ccRecord;
    }

    private static causeview__Recurring_Donation__c InitializeOffline(Contact individual) {
        causeview__Recurring_Donation__c ccRecord = new causeview__Recurring_Donation__c(
            causeview__Amount__c = 1.00,
            causeview__Reference__c = null,
            causeview__Type__c = 'Cash',
            causeview__Start_Date__c = Date.newInstance(2016, 03, 14),
            causeview__Schedule_Date__c = 14,
            causeview__Frequency__c = 'Monthly', 
            causeview__Status__c = 'Active',
            causeview__Constituent__c = individual.Id
            );

        insert ccRecord;

        ccRecord = [SELECT Id FROM causeview__Recurring_Donation__c WHERE causeview__Amount__c = 1.00];

        return ccRecord;
    }

    private static causeview__Recurring_Donation__c InitializeUkDirectDebitGift(Contact individual) {
        causeview__Recurring_Donation__c ukDirectDebitRecord = new causeview__Recurring_Donation__c(
            causeview__Amount__c = 1.00,
            causeview__Reference__c = 'A226854',
            causeview__Type__c = 'UK Direct Debit',
            causeview__Start_Date__c = Date.newInstance(2016, 03, 14),
            causeview__Schedule_Date__c = 14,
            causeview__Frequency__c = 'Monthly', 
            causeview__Status__c = 'Active',
            causeview__Account__c = '****4321',
            causeview__Sort_Code__c = '000000',
            causeview__Constituent__c = individual.Id
            );

        insert ukDirectDebitRecord;

        ukDirectDebitRecord = [SELECT Id FROM causeview__Recurring_Donation__c WHERE causeview__Reference__c = 'A226854'];

        return ukDirectDebitRecord;
    }

    private static causeview__RD_Allocation__c InitializeAllocation(causeview__Recurring_Donation__c gift) {
        causeview__RD_Allocation__c allocation = new causeview__RD_Allocation__c(
            causeview__Amount__c = 1.00,
            causeview__Recurring_Gift__c = gift.Id
            );

        insert allocation;

        return allocation;
    }
}
