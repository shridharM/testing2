@isTest(SeeAllData=true)
private class missingPaymentAllocationsBatchTest {
    static testmethod void test() {
        Account a = new Account(Name = 'sdsd');
        insert a;

        Contact contacts = new Contact();
        contacts.LastName = 'Constituent Test';
        Insert contacts;

        causeview__Recurring_Donation__c recurringGift = new causeview__Recurring_Donation__c();
        recurringGift.causeview__Constituent__c = contacts.Id;
        recurringGift.causeview__Start_Date__c = system.Today();
        recurringGift.causeview__Credit_Card_Type__c = 'Visa';
        recurringGift.causeview__Credit_Card__c = '4222222222222220';
        recurringGift.causeview__Credit_Card_Expiry_Date__c = system.Today()+2000;
        Insert recurringGift;

        causeview__Gift__c gift = new causeview__Gift__c();
        gift.causeview__Recurring_Donation__c = recurringGift.Id;
        gift.causeview__Status__c = 'Active';
        gift.causeview__Constituent__c = contacts.Id;
        gift.causeview__Gift_Date__c = system.today();
        gift.causeview__Gift_Type__c  = 'Recurring';
        Insert gift;

        causeview__Gift__c gift1 = new causeview__Gift__c();
        gift1.causeview__Recurring_Donation__c = recurringGift.Id;
        gift1.causeview__Status__c = 'Active';
        gift1.causeview__Organization__c = a.Id;
        gift1.causeview__Gift_Date__c = system.today();
        gift1.causeview__Gift_Type__c  = 'Recurring';
        Insert gift1;

        causeview__Payment__c payment = new causeview__Payment__c();
        payment.causeview__Date__c = System.Today();
        payment.causeview__Amount__c = 1000.00;
        payment.causeview__Payment_Type__c = 'other';
        payment.causeview__Donation__c = gift.Id;
        payment.causeview__Status__c = 'Approved';
        Insert payment;

        causeview__Payment__c payment1 = new causeview__Payment__c();
        payment1.causeview__Date__c = System.Today()+365;
        payment1.causeview__Amount__c = 1000.00;
        payment1.causeview__Payment_Type__c = 'other';
        payment1.causeview__Donation__c = gift.Id;
        payment1.causeview__Status__c = 'Approved';
        Insert payment1;
        system.debug('payment1==>'+payment1);
      Test.startTest();
       missingPaymentAllocationsBatch pBatch = new missingPaymentAllocationsBatch();
       pBatch.query = 'SELECT ID, Name, causeview__Amount__c, causeview__Status__c, causeview__Description__c, causeview__Donation__c, causeview__Donation__r.Name, causeview__Donation__r.causeview__Recurring_Donation__c, causeview__Donation__r.causeview__Recurring_Donation__r.Name FROM causeview__Payment__c WHERE ID NOT IN (SELECT causeview__Payment__c FROM causeview__Gift_Detail__c) AND causeview__Donation__r.causeview__Gift_Type__c = \'Recurring\' AND causeview__Status__c = \'Approved\'  AND causeview__Amount__c >0 AND causeview__Date__c >= 2013-01-01 AND (causeview__Payment_Type__c = \'Credit Card\' OR causeview__Payment_Type__c = \'ACH/PAD\') LIMIT 200';
       Database.executeBatch(pBatch);
      Test.stopTest();
    }
}