@isTest
public class TestTotalGAEligibleAllocationsRollUp{
    public static testMethod void TotalGAEligibleAllocationsRollUp(){        
        
        Map<String, String> rtype_Map = new Map<String, String>();
        List<RecordType> recordtypelist=[ SELECT Id,Name FROM RecordType];
        for(RecordType r:recordtypelist) {
            rtype_Map.put(r.Name,r.id); } 
            
           
        
        causeview__BatchSettings__c bs = new causeview__BatchSettings__c();
        bs.Name='Default'; 
        bs.causeview__Unknown_Guest_Id__c='003F000001NGgNjIAL';
        bs.causeview__CurrencyCode__c='CAD';
        bs.causeview__BatchFormID__c ='a0JC000000YZxr8'; 
        bs.causeview__BatchReportId__c ='00OF000000524ozMAA'; 
        bs.causeview__RegularGiftRecordTypeId__c='012F0000000r5T8IAI'; 
        bs.causeview__BucketAccountId__c ='001F00000135zxEIAQ'; 
        bs.causeview__LockBucketAccount__c =true; 
        bs.causeview__GatewayUrl__c ='https://api.cv_pkg_dev_2.com/v2.1/Gateway.asmx'; 
        bs.causeview__Data_Migration_Mode__c=false;
        insert bs;
        
        causeview__App_Settings__c app = new causeview__App_Settings__c(causeview__Appeal_RecordType_Id__c = rtype_Map.get('Appeal'), causeview__Campaign_RecordType_Id__c = rtype_Map.get('Campaign'), 
            causeview__Event_RecordType_Id__c = rtype_Map.get('Event'), causeview__Actionpages_URL__c = 'www.example.com', causeview__Appeal_Donate_Now_Form_Id__c = 'sdfd', causeview__Event_Registration_Form_Id__c = 'dsf',
            causeview__Form_URL__c = 'www.example.com', causeview__Free_Event_Registration_Form_Id__c = 'gfdf', causeview__CV_Account_Id__c = '123', causeview__Default_Actionpages_Campaign__c = 'jdksf',
            causeview__Individual_App_RecordtypeId__c = '123', causeview__Enable_Recurring_Receipts__c = false, causeview__Gift_Aid_Enable__c = true );
        insert app; 
        
        
        
        Account a = new Account(Name = 'Platy IT');
        insert a;
        
        
        contact c= new contact();
        c.FirstName='firstname';
        c.lastname='lastname';
        c.MailingStreet='TestStreet';
        c.MailingPostalCode='AP9078';
        c.AccountId = a.Id;
        insert c;      
        
        
        causeview__Gift__c g= new causeview__Gift__c();
        g.causeview__Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
        
        causeview__Payment__c p1 = new causeview__Payment__c();
        p1.causeview__Donation__c = g.Id; 
        p1.Gift_Aid_Claim_Status__c='Rejected';
        insert p1;      
        
        p1.Gift_Aid_Claim_Status__c=null;
        update p1;
        
        Gift_Aid_Declaration__c d= new Gift_Aid_Declaration__c();
        d.Donor__c=c.id;
        d.Next_Fiscal_Date__c= date.today();
        insert d;    
        d.Type__c='This donation, and all future';
        update d;
        
        // for the user story-Gift-Aid Test Coverage(updateAllocationGAEligibleField trigger is not covered)
        //shridhar
        
        causeview__Fund__c fund = new causeview__Fund__c();
        fund.causeview__Fund_Name__c = 'Test Fund';
        insert fund;
        
        
        
        
        Campaign  appeal  = new Campaign();
        appeal.Name='appeal test';
        appeal.RecordTypeId = rtype_Map.get('Appeal');
        insert appeal;
        
        causeview__Gift_Detail__c allocation = new causeview__Gift_Detail__c();
        allocation.causeview__New_Campaign__c  = appeal.id;
        allocation.causeview__Fund__c = fund.id;
        allocation.causeview__Gift__c=g.id;
        allocation.causeview__Payment__c=p1.id;
        allocation.causeview__Amount__c=20;
        insert allocation;
        
        update fund;
        //test coverage for TotalGiftAidRollUp trigger
        causeview__Payment__c pay = new causeview__Payment__c();
        pay.causeview__Date__c=Date.today();
        pay.causeview__Amount__c=20;
        pay.causeview__Status__c='Approved';
        pay.causeview__Payment_Type__c ='cash';
        pay.causeview__Donation__c=g.Id;
        insert pay;
        //---------
    }
}
