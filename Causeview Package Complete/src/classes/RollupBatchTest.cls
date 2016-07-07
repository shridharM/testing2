@isTest
Public class RollupBatchTest{
    public static testMethod void RollupBatchTest(){
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = '123', causeview__Campaign_RecordType_Id__c = '123', 
            causeview__Event_RecordType_Id__c = '123', causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;
        
        RecordType retype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Household' AND NamespacePrefix = 'causeview' Limit 1];
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];  
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes.Id, causeview__BucketAccountId__c = a.Id, causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact(FirstName = 'Test', LastName = 'Test');
        insert contacts;
        
        Contact contacts1 = new Contact(FirstName = 'Test', LastName = 'Test');
        insert contacts1;
        
        Account acObj = new Account (Name = 'Test Household', RecordTypeId = retype.Id);
        Insert acObj;
        
        contacts.Household__c = acObj.Id;
        update contacts;
        
        causeview__Gift__c gift = new causeview__Gift__c();
        gift.causeview__Status__c = 'Active';
        gift.causeview__Constituent__c = contacts.Id;
        gift.causeview__Gift_Date__c = system.today();
        gift.causeview__Gift_Type__c  = 'One Time Gift';
        gift.RecordTypeId  = rtypes.Id;
        gift.Status__c = 'Active';
        Insert gift;
        
        causeview__Gift__c gift1 = new causeview__Gift__c();
        gift1.causeview__Status__c = 'Active';
        gift1.causeview__Constituent__c = contacts1.Id;
        gift1.causeview__Gift_Date__c = system.today();
        gift1.causeview__Gift_Type__c  = 'One Time Gift';
        gift1.RecordTypeId  = rtypes.Id;
        gift1.Status__c = 'Active';
        Insert gift1;
        
        causeview__Payment__c payment = new causeview__Payment__c();
        payment.causeview__Date__c = System.Today();
        payment.causeview__Amount__c = 1000.00;
        payment.causeview__Payment_Type__c = 'other';
        payment.causeview__Donation__c = gift.Id;
        payment.causeview__Status__c = 'Approved';
        Insert payment;
        
        Solicitor__c softCredit = new Solicitor__c(Gift__c=gift1.id, Solicitor__c = contacts1.id);
        insert softCredit;
        /*RollupBatch r = new RollupBatch();
        //Database.executeBatch(r); 
        Database.QueryLocator QL;
        Database.BatchableContext BC; 
        List<Contact> contList = new List<Contact>();
        QL = r.start(bc);
        Database.QueryLocatorIterator QIT =  QL.iterator();
        while (QIT.hasNext())
        {
            Contact Acc = (Contact)QIT.next();            
            System.debug(Acc);
            contList.add(Acc);
        } 
        r.execute(BC, contList); */
    }
}