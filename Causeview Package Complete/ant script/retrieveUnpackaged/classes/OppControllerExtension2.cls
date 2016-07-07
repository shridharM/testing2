public with sharing class OppControllerExtension2 {
    public Opportunity SelectedOpp {get; set;}
    public Account theAcc {get; set;}

    public List<PaymentWrapper> theWrappers {get; set;}

    public List<Task> theTasks {get; set;}    
    public Decimal totalAmount {get; set;}   
    public decimal Index { get; set; }
    public decimal Index2 { get; set; }
    public decimal Index3 { get; set; }    
    public decimal gdIndex { get; set; }
    public decimal wrapperIndex { get; set; } 
    public boolean isConverted { get; set; }     
    public Gift__c trans {get; set;} 
    public List<cv_pkg_dev_I__Gift_Detail__c> giftdetaillist { get; set; }
    
    public OppControllerExtension2(ApexPages.StandardController stdController) {
         this.SelectedOpp = (Opportunity)stdController.getRecord();

         List<Opportunity> opps = [Select o.AccountId, o.RecordTypeId, o.Amount, o.CloseDate, o.CreatedDate, o.Description, o.ExpectedRevenue, o.ForecastCategory, 
                                  o.CurrentGenerators__c, o.DeliveryInstallationStatus__c, o.MainCompetitors__c, o.OrderNumber__c, 
                                  o.TrackingNumber__c, o.HasOpportunityLineItem, o.Id, o.IsClosed, o.IsDeleted, o.IsPrivate, o.IsWon, o.LastActivityDate, o.LastModifiedDate,
                                  o.LeadSource, o.Name, o.NextStep, o.Probability, o.StageName, o.SystemModstamp,
                                  o.TotalOpportunityQuantity, o.Type, o.Individual__c from Opportunity o WHERE id=:SelectedOpp.Id];    //o.Fiscal, o.FiscalQuarter, o.FiscalYear,
        if(opps != null && opps.size() != 0)        
        { SelectedOpp = opps[0]; 
        }
        
        //if(SelectedOpp.StageName
        
        List<Gift__c> theGifts = [SELECT Id FROM Gift__c WHERE Proposal__c = :SelectedOpp.Id];
        
        isConverted = theGifts.size() > 0;
        
        if (isConverted)
        { 
            trans = theGifts[0];
            SelectedOpp.addError('This Opportunity has already been converted to a transaction'); 
        }
        
        if (SelectedOpp.AccountId != null)
        { theAcc = [SELECT Name FROM Account WHERE Id=:SelectedOpp.AccountId]; }
        Index = 0;
        Index2 = 0;
        Index3 = 0;
        
        theWrappers = new List<PaymentWrapper>();
        theWrappers.add(new PaymentWrapper(new Payment__c()));
        system.debug('theWrappers==>'+theWrappers);
        //theAllocations = new List<Gift_Detail__c>();
        theTasks = new List<Task>();
        giftdetaillist = new List<cv_pkg_dev_I__Gift_Detail__c>();

    }

    public void removePayment()
    {
        integer count = 0;    
    
        Index = Decimal.valueOf(ApexPages.currentPage().getParameters().get('wrapperIndex'));
        integer selectedIndex = Index.intValue();
    
        for(PaymentWrapper pw : theWrappers)
        {
            count++;
            if (count == selectedIndex )
            { break; }
        }
    
        if (count != 0) {
            PaymentWrapper selected = theWrappers.remove(count-1);
        }
    }
    
    public void addPayment()
    {
       theWrappers.add(new PaymentWrapper(new Payment__c()));
    }    
    public void removeAllocation()
    {
        integer count = 0;
        integer gdCount = 0;    
    
        gdIndex = Decimal.valueOf(ApexPages.currentPage().getParameters().get('gdIndex'));
        integer gdSelectedIndex = gdIndex.intValue();
        system.debug('gdIndex=>'+gdIndex);
        wrapperIndex = Decimal.valueOf(ApexPages.currentPage().getParameters().get('wrapperIndex'));        
        integer selectedIndex = wrapperIndex.intValue();
        system.debug('wrapperIndex=>'+wrapperIndex);
        for(PaymentWrapper pw : theWrappers)
        {
            system.debug('theWrappers==>'+pw);
            system.debug('theWrappers==>'+pw.theGiftDetails[0]);
            count++;
            if (count == selectedIndex )
            { break; }       
        }
        system.debug('count==>'+count);
        system.debug('count==>'+theWrappers[count-1].theGiftDetails);
        for (Gift_Detail__c gd : theWrappers[count-1].theGiftDetails)
        {
            gdCount++;
            if (gdCount == gdSelectedIndex )
            {
                break; 
            } 
        }            
        system.debug('gdCount==>'+gdCount);
        if (count != 0 && gdCount != 0) {
            theWrappers[count-1].theGiftDetails.remove(gdCount-1);
        }
        system.debug('gdCount==>'+theWrappers[count-1].theGiftDetails.size());
        system.debug('count123==>'+theWrappers[count-1].theGiftDetails);
    }
    public void addAllocation()
    {
        Index2 = Decimal.valueOf(ApexPages.currentPage().getParameters().get('gdIndex'));
        system.debug('Index2==>'+Index2);
        integer selectedIndex = Index2.intValue();    
        theWrappers[selectedIndex - 1].theGiftDetails.add(new Gift_Detail__c());
        system.debug('Allocation add -- '+theWrappers);
    }    
    public void removeTask()
    {
        integer count = 0;    
    
        Index3 = Decimal.valueOf(ApexPages.currentPage().getParameters().get('Index3'));
        integer selectedIndex = Index3.intValue();
    
        for(Task p : theTasks)
        {
            count++;
            if (count == selectedIndex )
            { break; }
        }
    
        if (count != 0) {
            Task selected = theTasks.remove(count-1);
        }
    }
    public void addTask()
    {
       theTasks.add(new Task(OwnerId = UserInfo.getUserId()));
    }      
    
    public PageReference Submit() {
        Savepoint sp = Database.setSavepoint();
        Double pTotal = 0;
        Double aTotal = 0;
        String BucketAccountId = '';
        String RegGiftRTID = '';
        Gift__c theTrans = new Gift__c();
        OpportunityContactRole cr = new OpportunityContactRole();
        
        //try 
        //{
            BatchSettings__c settings = BatchSettings__c.getInstance('Default');
            
            if (settings != null) { 
                BucketAccountId = settings.BucketAccountId__c; 
                RegGiftRTID = settings.RegularGiftRecordTypeId__c; 
            }

                //If Appeal record is not of type Appeal or Event, Send Error message.
            List<Id> appealIDs = new List<Id>();
            
            for (PaymentWrapper pw : theWrappers)
            { 
                pTotal += pw.thePayment.Amount__c; 
            
                for (Gift_Detail__c gd : pw.theGiftDetails)
                { aTotal += gd.Amount__c; appealIDs.add(gd.New_Campaign__c); }       
            }

            RecordType RTP = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Campaign' AND NamespacePrefix = 'causeview'];
            List<Campaign> cmpList = [Select Id, RecordTypeId, Name From Campaign Where RecordTypeId = :RTP.Id AND Id IN :appealIDs];
            if (cmpList != null && cmpList.size() > 0) {
                theTrans.addError('Appeal: "' + cmpList[0].Name + '" must be of type Appeal or Event.');
                return null;
            }
        
            //if payments total > opp amount -error
            if (pTotal > SelectedOpp.Amount)
            { theTrans.addError('The sum of all entered payments is greater than the Opportunities Value'); return null; }
            
            //if allocations total != payment total -error
            if (aTotal != pTotal)
            { theTrans.addError('The sum of all entered Allocations is not equal to the sum of all entered payments');  return null; }
                    
            //In case of Opportunities with no designated Organization, consider the Individual ID.
            if (SelectedOpp.AccountId == null)
            {
                theTrans.Constituent__c = SelectedOpp.Individual__c;
            }
            //In case of Opportunities with designated Organization, consider the Organization ID.
            else
            {
                theTrans.Organization__c = SelectedOpp.AccountId;
            }        

            //(In case of Opportunities with no designated Organization)
            //Add selected Opportunity's ContactId to Transaction Constituent__c field, if selected Opportunity's AccountId == null and,
            //     the Transaction's Constituent__c == null.
            if(SelectedOpp.AccountId == null && theTrans.Constituent__c == null) {
                theTrans.Constituent__c = SelectedOpp.Individual__c;
            }
            
            //create transaction, add payments underneith, add giftdetails underneith, add tasks
            theTrans.Expected_Amount__c = SelectedOpp.Amount;
            theTrans.Gift_Date__c = SelectedOpp.CloseDate;
            theTrans.Status__c = 'In Progress';
            theTrans.Proposal__c = SelectedOpp.Id;
            RecordType rt = [select id, name from RecordType where SobjectType='cv_pkg_dev_I__Gift__c' AND name='Grant'];
            // Commented out by Vahid - Not being used.  In some cases Record type "Grant" is added by clients and the line 
            // below caused an error since the query returns 2 records and value is not being assigned to a list
            //RecordType grant_rt = [select id, name from RecordType where SobjectType='Opportunity' AND name='Grant'];            
            if (rt.Id == SelectedOpp.RecordTypeId) {
                theTrans.RecordTypeId = rt.Id;
            }
            else {
                theTrans.RecordTypeId = RegGiftRTID;
            } 
            try {
                insert theTrans;
            }
            catch
            (Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));                
                return null;
            }
            
            rt = [select id, name from RecordType where SobjectType='cv_pkg_dev_I__Payment__c' AND name='Standard'];
            for (PaymentWrapper pw : theWrappers)
            { 
                pw.thePayment.Donation__c = theTrans.Id; pw.thePayment.RecordTypeId = rt.Id;         
                for (Gift_Detail__c gd : pw.theGiftDetails)
                { gd.Gift__c = theTrans.Id; gd.Allocation_Date__c = pw.thePayment.Date__c; }        
            }
            
            for (Task t : theTasks)
            {
                t.WhatId = theTrans.Id;
                t.WhoId = cr.ContactId;
            }
            
            List<Payment__c> pToBeInserted = new List<Payment__c>();
            List<Gift_Detail__c> gdToBeInserted = new List<Gift_Detail__c>();        
            for (PaymentWrapper pw : theWrappers)
            {
                pToBeInserted.add(pw.thePayment);
                if (pw.isRemind)
                {
                    theTasks.add(new Task(ActivityDate = (pw.thePayment.Date__c - pw.daysBefore), OwnerId = UserInfo.getUserId(), WhatId = theTrans.Id, WhoId = cr.ContactId, Subject = 'Reminder - ' + SelectedOpp.Name + ' follow-up', Description = 'Reminder - ' + SelectedOpp.Name + ' follow-up'));       
                }
            }
            insert pToBeInserted;
            for (PaymentWrapper pw : theWrappers)
            {
                for (Gift_Detail__c gd : pw.theGiftDetails)
                {
                    gd.Payment__c = pw.thePayment.Id;
                    gdToBeInserted.add(gd);
                }
            }
            insert gdToBeInserted;
            insert theTasks;                
                    
            SelectedOpp.StageName = 'Converted to Transaction';
            update SelectedOpp;
            
            PageReference pr = new ApexPages.StandardController(theTrans).view();
            pr.setRedirect(true);
        
            return pr;
        /*}
        catch (Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,String.valueOf(ex.getLineNumber())));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));                
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getStackTraceString()));
            return null;            
        }*/
    }
    
    public PageReference goToTrans() {
        PageReference pr = new ApexPages.StandardController(trans).view();
        pr.setRedirect(true);
    
        return pr;
    }
    
    public void nilMethod() { } 
    
    //** Used to feed Javascript to Dynamicly populate fund when an Appeal is selected ** //  
    public class BatchAllocationSetting {
        public string LetterId { get; set; }
        public string LetterName { get; set; }
        
        public string FundId { get; set; }
        public string FundName { get; set; }
        
        public BatchAllocationSetting() { }
        public BatchAllocationSetting(string l, string f)
        {
            LetterId = l;
            FundId = f;
        }
    }    
    @RemoteAction
    public static BatchAllocationSetting GetAppealDefaults(string appealId) {
        List<Campaign> camps = [SELECT Id, Name, Letter__c, Letter__r.Name, Fund__c, Fund__r.Name FROM Campaign WHERE Id = :appealId];
        if (camps!=null && camps.size()>0) {
            BatchAllocationSetting setting = new BatchAllocationSetting(camps[0].Letter__c, camps[0].Fund__c);
            if (camps[0].Letter__c!=null)
                setting.LetterName = camps[0].Letter__r.Name;
            if (camps[0].Fund__c!=null)
                setting.FundName = camps[0].Fund__r.Name;
            return setting;   
        }
        else
            return new BatchAllocationSetting();
    }          
}