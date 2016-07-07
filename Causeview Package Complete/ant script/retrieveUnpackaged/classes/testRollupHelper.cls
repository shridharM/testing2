//Test RollupHelper Class
@isTest
Public class testRollupHelper{
                            
    static testMethod void testRollupHelper() {/*
        RollupHelper RH = new RollupHelper();
        RecordType Rt = [Select Id From RecordType Where Name='Household' AND NamespacePrefix = 'causeview'];
        EmailTemplate el = [SELECT Name FROM EmailTemplate WHERE Name = 'Receipt Template'];
        \*Id folderId = [Select f.Name, f.Id From Folder f where f.Name = 'My Personal Email Templates'].Id;
        
        EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = folderId, TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
        insert e;*\
        cv_pkg_dev_I__App_Settings__c app = new cv_pkg_dev_I__App_Settings__c(cv_pkg_dev_I__Appeal_RecordType_Id__c = '123', cv_pkg_dev_I__Campaign_RecordType_Id__c = '123', 
            cv_pkg_dev_I__Event_RecordType_Id__c = '123', cv_pkg_dev_I__Actionpages_URL__c = 'www.example.com', cv_pkg_dev_I__Appeal_Donate_Now_Form_Id__c = 'sdfd', cv_pkg_dev_I__Event_Registration_Form_Id__c = 'dsf',
            cv_pkg_dev_I__Form_URL__c = 'www.example.com', cv_pkg_dev_I__Free_Event_Registration_Form_Id__c = 'gfdf', cv_pkg_dev_I__CV_Account_Id__c = '123', cv_pkg_dev_I__Default_Actionpages_Campaign__c = 'jdksf',
            cv_pkg_dev_I__Individual_App_RecordtypeId__c = '123', cv_pkg_dev_I__Enable_Recurring_Receipts__c = true);
        insert app;
            
        Account a = new Account(name='testAccount', Email__c='test@account.com', RecordTypeId=Rt.Id);
        Insert a;
        
        Account a1 = new Account(name='testAccount1', Email__c='test1@account.com', RecordTypeId=Rt.Id);
        Insert a1;
        
        cv_pkg_dev_I__givingpowerSettings__c givingpowerSetting = new cv_pkg_dev_I__givingpowerSettings__c(Name='Settings',cv_pkg_dev_I__EmailTemplateId__c = el.id,
            cv_pkg_dev_I__ReceiptEmailDocId__c = '1233', cv_pkg_dev_I__ReceiptPDFDocId__c = '123', cv_pkg_dev_I__ConsolidatedReceiptPDFDocId__c = '123', cv_pkg_dev_I__Recurring_Batch_Size__c = 5, cv_pkg_dev_I__Rollup_Batch_Size__c = 50);
        insert givingpowerSetting;
        
        BatchSettings__c bs = new BatchSettings__c(Name='Default', cv_pkg_dev_I__BatchFormID__c='123', cv_pkg_dev_I__BatchReportId__c='123',
           cv_pkg_dev_I__BucketAccountId__c=a.Id, cv_pkg_dev_I__CurrencyCode__c='123', cv_pkg_dev_I__RegularGiftRecordTypeId__c=Rt.Id);
        Insert bs; 
              
        Contact c = new Contact(lastName='testContact', Email='test@contact.com', Household__c=a.Id, Total_Fiscal_Transaction_Amount__c=2000,
                                Total_Lifetime_Transaction_Amount__c=2000, Total_Fiscal_Year_Giving__c=20, Total_Lifetime_Giving__c=10, Total_Lifetime_Fundraising__c=20);
        Insert c;
        npe5__Affiliation__c affiliation = new npe5__Affiliation__c(npe5__Organization__c = a.id, npe5__Contact__c = c.id, cv_pkg_dev_I__Apply_Soft_Credit__c = true);
        Insert affiliation;
        
        npe5__Affiliation__c affiliation1 = new npe5__Affiliation__c(npe5__Organization__c = a1.id, npe5__Contact__c = c.id, cv_pkg_dev_I__Apply_Soft_Credit__c = true);
        Insert affiliation1;
        
        npe4__Relationship__c relationship = new npe4__Relationship__c(npe4__Contact__c = c.id, npe4__RelatedContact__c = c.id, cv_pkg_dev_I__Apply_Soft_Credit__c = true);
        insert relationship;
        
        Recurring_Donation__c rd = new Recurring_Donation__c(cv_pkg_dev_I__Constituent__c = c.Id, cv_pkg_dev_I__Start_Date__c = system.today());
        Insert rd;
        
        cv_pkg_dev_I__RD_Allocation__c rdAllocation = new cv_pkg_dev_I__RD_Allocation__c(cv_pkg_dev_I__Recurring_Gift__c = rd.Id, Active__c = true, cv_pkg_dev_I__Amount__c = 100.00);
        Insert rdAllocation;
        
        Gift__c d1 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null, RecordType=Rt); 
        Insert d1;
        Receipt__c r = new Receipt__c(Gift__c=d1.Id, Auto_Email_Receipt__c=true);
        Insert r;
        Gift__c d2 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=null, Organization__c=a.Id, RecordType=Rt); 
        Insert d2;
        Gift__c d3 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today().addYears(-1), Constituent__c=null, Organization__c=a.Id, RecordType=Rt); 
        Insert d3;
        Gift__c d4 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today().addYears(-2), Constituent__c=null, Organization__c=a.Id, RecordType=Rt); 
        Insert d4;
        Gift__c d5 = new Gift__c(Gift_Type__c='Recurring', Gift_Date__c=System.today().addYears(-2), Constituent__c=c.id, Organization__c=null, RecordType=Rt, cv_pkg_dev_I__Recurring_Donation__c = rd.id, cv_pkg_dev_I__Receipt_Type__c = 'No Receipt'); 
        Insert d5;

        campaign cn = new campaign(Name='campaign');
        Insert cn;
        Event_Registration__c e1 = new Event_Registration__c(Transaction__c=d1.Id, Registration_Date__c=System.Today(),Individual__c=c.id, Event__c=cn.Id);
        Insert e1;
       
        Payment__c p = new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash',
                                        Status__c='Approved', Donation__c = d1.Id, Receipt__c=null);
        Insert p;
        
        Payment__c p1 = new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash',
                                        Status__c='Approved', Donation__c = d2.Id, Receipt__c=null);
        Insert p1;
        
        Payment__c p2 = new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='check',
                                        Status__c='Declined', Donation__c = d5.Id);
        Insert p2;
        List<sObject> listObject = new List<sObject>();

        system.debug('<==r==>'+r);
        Test.startTest();
        system.debug('<==Inside Test==>');
        RollupHelper.GuestRegistrations(new Set<Gift__c>{d1, d2});

        RollupHelper.RecalculateTotalHouseholdGiving(new set<Id>());
        RollupHelper.RecalculateTotalHouseholdGiving(new set<Id>{a.Id});

        RollupHelper.RecalculateTotalGivingForOrg(new set<Id>());
        RollupHelper.RecalculateTotalGivingForOrg(new set<Id>{a.Id});

        RollupHelper.RecalculateTotalGiving(new set<Id>());
        RollupHelper.RecalculateTotalGiving(new set<Id>{c.Id});

        RollupHelper.CreateIndividualSoftCredits(new List<Gift__c>{d1, d2});
        RollupHelper.CreateOrganizationSoftCredits(new List<Gift__c>{d1, d2});

        RollupHelper.RecalculateGiftDatesForOrg(new set<Id>{a.Id});
        RollupHelper.RecalculateGiftDates(new set<Id>{c.Id});

        RollupHelper.issueReceipts(new set<Id>{r.Id});
        RollupHelper.issueReceipts(new set<Id>{c.id});

//        Insert p;
       c = [Select Id, (Select Id, Status__c, Amount__c From Gifts__r) From Contact WHERE Id = :c.Id];
        RollupHelper.executeConsolidatedReceiptBatch(new List<Contact>{c});

        RollupHelper.executeNewYearTransactionsBatch(new List<Gift__C>{d1,d2});

        //RollupHelper.createGiftDetails(new set<String>{':'});
        //RollupHelper.createGiftDetails(new set<String>{'a:b'});
        RollupHelper.CreateTodayRecurringBatch();
        RollupHelper.newGPServiceInstance();
        RollupHelper.maskCardNumber('abcdefghijkl');
        RollupHelper.findItems('abc', 'abc', listObject);
        RollupHelper.UpdateGDs(c.id);
        Test.stopTest();*/
    }
}