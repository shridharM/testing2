@isTest
private class TestReceiptLetterTrigger 
{
  static testMethod void TestAutoLetter() {
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;       
       
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
     
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;        
        
        Letter__c l = new Letter__c(Name__c = 'Sample');
        insert l;
        
        RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
        Campaign a_p = new Campaign(Name = 'asdads', Letter__c = l.Id, RecordTypeId=recType.id);
        insert a_p;
        
        
        Gift__c g1 = new Gift__c(Letter__c = null, Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g1.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_p.Id, Amount__c = 100);
        insert gd1;
       
        
           
    } 
  static testMethod void testCreditDetailsUpdation() {
        
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;          
        
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        EmailTemplate et = [SELECT id FROM EmailTemplate Limit 1];
        system.debug('Nitin et==='+et);
        givingpowerSettings__c gps = new givingpowerSettings__c(
            DupeConsolidatedReceiptPDFDocId__c = '012A000000128DT', ConsolidatedReceiptPDFDocId__c = '012A000000128DA',
            Name = 'Settings', causeview__EmailTemplateId__c = et.id, causeview__ReceiptEmailDocId__c = '012A000000128Df',
            causeview__ReceiptPDFDocId__c = '012A000000128Dr');
        Insert gps;
     
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        causeview__BatchSettings__c bs= new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert bs;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;        
        
        Gift__c g = new Gift__c(Letter__c = null, Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g;
         
    
     
     Payment__c p1 = new Payment__c();
     p1.CC_Reference__c = 'SESESE';
     p1.Donation__c = g.Id;
     p1.Amount__c = 65;
     p1.Status__c = 'Approved';
     insert p1;
     
     Receipt__c receipt = new Receipt__c();
     receipt.Constituent__c = c.Id;
     receipt.Gift__c = g.Id;
     receipt.Receipt_Date__c = Date.Today();
     receipt.Status__c = 'To Be Issued';
     receipt.Auto_Email_Receipt__c = true;
     insert receipt;
     
     
        }
    
    static testMethod void ReceiptRichTextTrigger() {
    
         RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'causeview__Receipt__c' AND Name = 'Pending' LIMIT 1];

        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

         causeview__BatchSettings__c bs= new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rt.Id, causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
         insert bs;
         
        
         Contact c = new Contact(LastName = 'dsadasd', Email = 'breakeven@breakeveninc.com');
         insert c;
         
         Letter__c l = new Letter__c(Name__c = 'testLetter');
         l.Introduction_Text_Block_Rich_Text__c = 'Introduction';
         l.Text_Block__c = 'TextBlock';
         l.Signature_Rich_Text__c = 'signature';
         l.Email_Subject__c = 'Email subject';
         l.Custom_Rich_Text_1__c = 'custom text 1';
         l.Custom_Rich_Text_2__c = 'custom text 2';
         l.Custom_Rich_Text_3__c = 'custom text 3';
         insert l;

         Gift__c g = new Gift__c(Constituent__c = c.Id, Letter__c = l.Id);
         insert g;
         Receipt__c r = new Receipt__c(RecordTypeId = rt.Id, Constituent__c = c.Id, Gift__c = g.Id);
         r.Introduction_Text_Block_Rich_Text__c = null;
         r.Body_Text_Block_Rich_Text__c = null;
         r.Signature_Rich_Text__c = null;
         r.Email_Subject__c = null;
         r.Custom_Rich_Text_1__c = null;
         r.Custom_Rich_Text_2__c = null;
         r.Custom_Rich_Text_3__c = null;
         insert r;
     }
     
      static testMethod void receiptUpdateOnTransaction() {
    
         RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'causeview__Receipt__c' AND Name = 'Pending' LIMIT 1];

        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

         causeview__BatchSettings__c bs= new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rt.Id, causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
         insert bs;
         
        
         Contact c = new Contact(LastName = 'dsadasd', Email = 'breakeven@breakeveninc.com');
         insert c;
         
         Letter__c l = new Letter__c(Name__c = 'testLetter');
         l.Introduction_Text_Block_Rich_Text__c = 'Introduction';
         l.Text_Block__c = 'TextBlock';
         l.Signature_Rich_Text__c = 'signature';
         l.Email_Subject__c = 'Email subject';
         l.Custom_Rich_Text_1__c = 'custom text 1';
         l.Custom_Rich_Text_2__c = 'custom text 2';
         l.Custom_Rich_Text_3__c = 'custom text 3';
         insert l;
         
         Letter__c l1 = new Letter__c(Name__c = 'testLetter1');
         l1.Introduction_Text_Block_Rich_Text__c = 'Introduction1';
         l1.Text_Block__c = 'TextBlock1';
         l1.Signature_Rich_Text__c = 'signature1';
         l1.Email_Subject__c = 'Email subject1';
         l1.Custom_Rich_Text_1__c = 'custom text 11';
         l1.Custom_Rich_Text_2__c = 'custom text 21';
         l1.Custom_Rich_Text_3__c = 'custom text 31';
         insert l1;

         Gift__c g = new Gift__c(Constituent__c = c.Id, Letter__c = l.Id);
         insert g;
         Receipt__c r = new Receipt__c(RecordTypeId = rt.Id, Constituent__c = c.Id, Gift__c = g.Id);
         r.Introduction_Text_Block_Rich_Text__c = null;
         r.Body_Text_Block_Rich_Text__c = null;
         r.Signature_Rich_Text__c = null;
         r.Email_Subject__c = null;
         r.Custom_Rich_Text_1__c = null;
         r.Custom_Rich_Text_2__c = null;
         r.Custom_Rich_Text_3__c = null;
         insert r;
         
         g.Letter__c = l1.Id;
         update g;
        }
     
     static testMethod void sysTransUpdateALL() {
        
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.Name, r.Id);
        }
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtypes_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false);
        insert app;          
        
        causeview__aNums__c cs1 = new causeview__aNums__c( Name = 'Default', causeview__OrgPrefix__c = 'ORG', causeview__OrgLength__c = 8, causeview__OrgCount__c = 1, causeview__ContactPrefix__c = 'CON', causeview__ContactLength__c = 8, causeview__ContactCount__c = 1);
        insert cs1; 
        
        causeview__FormSettings__c fs1 = new causeview__FormSettings__c( Name = 'Default', causeview__Contact__c = 'TBD', causeview__Donation__c = 'TBD', causeview__RSVP__c = 'TBD', causeview__RSVP_Free__c = 'TBD');
        insert fs1;        

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        causeview__BatchSettings__c cs2 = new causeview__BatchSettings__c( Name = 'Default', causeview__BatchFormID__c = 'sadas',   causeview__BatchReportId__c = 'asdasd', causeview__RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), causeview__BucketAccountId__c = a.Id,    causeview__CurrencyCode__c = 'CAD', causeview__GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c;        
        RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
        Campaign a_p = new Campaign(Name = 'asdads', RecordTypeId=recType.id);
        insert a_p;
        
        Gift__c g1 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g1;
        Event_Registration__c er = new Event_Registration__c(Individual__c = c.Id, Transaction__c = g1.Id, Registration_Date__c = Date.Today(), Event__c = a_p.Id);
        insert er;
        
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g1.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = a_p.Id, Amount__c = 100);
        insert gd1;
        
       
    
        
    } 
}