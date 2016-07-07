@isTest
Public class RollupBatchTest{
    public static testMethod void RollupBatchTest(){
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = '123', cv_pkg_dev_I__Campaign_RecordType_Id__c = '123', 
            cv_pkg_dev_I__Event_RecordType_Id__c = '123', cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = false);
        insert app;
        
        RecordType retype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Household' AND NamespacePrefix = 'causeview' Limit 1];
        RecordType rtypes = [Select Name, Id From RecordType where Name = 'Gift' AND NamespacePrefix = 'causeview' LIMIT 1];  
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        cv_pkg_dev_I__BatchSettings__c cs2 = new cv_pkg_dev_I__BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, cv_pkg_dev_I__BatchFormID__c = 'sadas',   cv_pkg_dev_I__BatchReportId__c = 'asdasd', cv_pkg_dev_I__RegularGiftRecordTypeId__c = rtypes.Id, cv_pkg_dev_I__BucketAccountId__c = a.Id, cv_pkg_dev_I__CurrencyCode__c = 'CAD', cv_pkg_dev_I__GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact(FirstName = 'Test', LastName = 'Test');
        insert contacts;
        
        Contact contacts1 = new Contact(FirstName = 'Test', LastName = 'Test');
        insert contacts1;
        
        Account acObj = new Account (Name = 'Test Household', RecordTypeId = retype.Id);
        Insert acObj;
        
        contacts.Household__c = acObj.Id;
        update contacts;
        
        cv_pkg_dev_I__Gift__c gift = new cv_pkg_dev_I__Gift__c();
        gift.cv_pkg_dev_I__Status__c = 'Active';
        gift.cv_pkg_dev_I__Constituent__c = contacts.Id;
        gift.cv_pkg_dev_I__Gift_Date__c = system.today();
        gift.cv_pkg_dev_I__Gift_Type__c  = 'One Time Gift';
        gift.Status__c = 'Active';
        Insert gift;
        
        cv_pkg_dev_I__Gift__c gift1 = new cv_pkg_dev_I__Gift__c();
        gift1.cv_pkg_dev_I__Status__c = 'Active';
        gift1.cv_pkg_dev_I__Constituent__c = contacts1.Id;
        gift1.cv_pkg_dev_I__Gift_Date__c = system.today();
        gift1.cv_pkg_dev_I__Gift_Type__c  = 'One Time Gift';
        gift1.Status__c = 'Active';
        Insert gift1;
        
        cv_pkg_dev_I__Payment__c payment = new cv_pkg_dev_I__Payment__c();
        payment.cv_pkg_dev_I__Date__c = System.Today();
        payment.cv_pkg_dev_I__Amount__c = 1000.00;
        payment.cv_pkg_dev_I__Payment_Type__c = 'other';
        payment.cv_pkg_dev_I__Donation__c = gift.Id;
        payment.cv_pkg_dev_I__Status__c = 'Approved';
        Insert payment;
        
        Solicitor__c softCredit = new Solicitor__c(Gift__c=gift1.id, Solicitor__c = contacts1.id);
        insert softCredit;
        RollupBatch r = new RollupBatch();
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
        r.execute(BC, contList); 
    }
}