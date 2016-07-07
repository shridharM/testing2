public class FraudulentPaymentsInterfaceController {    
    public List<PaymentWrapper> lstWrapper {get;set;}
    public List<PaymentWrapper> lstSetController{get;set;}
    public integer LimitSize = 0;
    public integer totalRecs = 0;
    public integer pageNumber {get; set;}
    public integer totalPages {get; set;}
    
    public CustomIterable obj;
    
    public FraudulentPaymentsInterfaceController() 
    {
        retrievePayments();
    }
    
    public void retrievePayments() {
        set<id> giftIds = new set<id>();
        set<id> rdGiftIds = new set<id>();
        set<id> contactIds = new set<id>();
        set<id> accountIds = new set<id>();
        map<id, list<causeview__Payment__c>> giftToPayMap = new map<id, list<causeview__Payment__c>>();
        map<id, list<causeview__Payment__c>> contactToPayMap = new map<id, list<causeview__Payment__c>>();
        map<id, list<causeview__Payment__c>> accountToPayMap = new map<id, list<causeview__Payment__c>>();
        map<id, list<causeview__Payment__c>> rdGiftToPayMap = new map<id, list<causeview__Payment__c>>();
        map<id, causeview__Payment__c> paymentsCanBeDeleted = new map<id, causeview__Payment__c>();
        List<causeview__Gift__c> gifts =new List<causeview__Gift__c>();
        List<causeview__Payment__c> lstPayment =new List<causeview__Payment__c>();
        List<causeview__Payment__c> lstPaymentRetrieved =new List<causeview__Payment__c>();
        
        set<causeview__Payment__c> paymentsCanNotBeDeleted =new set<causeview__Payment__c>();
        lstPaymentRetrieved = [SELECT id,name, causeview__Amount__c, causeview__Gift_Aid_Declaration__c, causeview__Donation__c, causeview__Donation__r.causeview__Constituent__c, causeview__Donation__r.causeview__Organization__c, causeview__Donation__r.causeview__Recurring_Donation__c, causeview__Status__c, causeview__Payment_Type__c, causeview__Date__c, (SELECT name, causeview__Posted_to_Finance__c from causeview__Allocations__r) FROM causeview__Payment__c WHERE causeview__iATS_Potentially_Fraudulent_Payment__c	= true];                        
        for(causeview__Payment__c pay : lstPaymentRetrieved){
            boolean postToFinance = false;
            for(causeview__Gift_Detail__c gd : pay.causeview__Allocations__r){
                if(gd.causeview__Posted_to_Finance__c != null ){
                    postToFinance = true;
                }
            }
            if(!postToFinance){
                lstPayment.add(pay);
            }
        }
        for(causeview__Payment__c p : lstPayment){
            paymentsCanBeDeleted.put(p.id, p);
			giftIds.add(p.causeview__Donation__c);
            
            if(giftToPayMap.containsKey(p.causeview__Donation__c)){
                giftToPayMap.get(p.causeview__Donation__c).add(p);
                
            }else{
                List<causeview__Payment__c>  paymentList =new List<causeview__Payment__c>();
                paymentList.add(p);
                giftToPayMap.put(p.causeview__Donation__c, paymentList);
                
            }   
            if(contactToPayMap.containsKey(p.causeview__Donation__r.causeview__Constituent__c)){
                contactToPayMap.get(p.causeview__Donation__r.causeview__Constituent__c).add(p);
            }else{				
                List<causeview__Payment__c>  paymentList =new List<causeview__Payment__c>();
                paymentList.add(p);
                contactToPayMap.put(p.causeview__Donation__r.causeview__Constituent__c, paymentList);
                
            }
            if(accountToPayMap.containsKey(p.causeview__Donation__r.causeview__Organization__c)){
                accountToPayMap.get(p.causeview__Donation__r.causeview__Organization__c).add(p);
            }else{				
                List<causeview__Payment__c>  paymentList =new List<causeview__Payment__c>();
                paymentList.add(p);
                accountToPayMap.put(p.causeview__Donation__r.causeview__Organization__c, paymentList);
                
            }
            if(rdGiftToPayMap.containsKey(p.causeview__Donation__r.causeview__Recurring_Donation__c)){
                rdGiftToPayMap.get(p.causeview__Donation__r.causeview__Recurring_Donation__c).add(p);
            }else{
                List<causeview__Payment__c>  paymentList =new List<causeview__Payment__c>();
                paymentList.add(p);
                rdGiftToPayMap.put(p.causeview__Donation__r.causeview__Recurring_Donation__c, paymentList);
                
            }
        }        
        gifts = [select id, name, causeview__Recurring_Donation__c, causeview__Constituent__c, causeview__Organization__c, (SELECT Name FROM causeview__Recurring_Payments__r) FROM causeview__Gift__c WHERE id in : giftIds];        
        for(causeview__Gift__c  g : gifts){            
            if(g.causeview__Recurring_Payments__r.size()>1){                
                for(causeview__Payment__c p : giftToPayMap.get(g.id)){                     
                    paymentsCanNotBeDeleted.add(p);
                    paymentsCanBeDeleted.remove(p.id);
                }
                                
            }else{                                  
                rdGiftIds.add(g.causeview__Recurring_Donation__c);
                contactIds.add(g.causeview__Constituent__c);
                accountIds.add(g.causeview__Organization__c);
            }            
        }        
       list<contact> contacts  =[ SELECT Name, (SELECT Name FROM causeview__Gifts__r) FROM Contact WHERE id in : contactIds];
        for(contact  c : contacts){
            if(c.causeview__Gifts__r.size()>1){
                for(causeview__Payment__c p : contactToPayMap.get(c.id)){
                    paymentsCanNotBeDeleted.add(p);
                    paymentsCanBeDeleted.remove(p.id);                    
                }                 
            }        
        }        
        list<account> accounts  =[ SELECT Name, (SELECT Name FROM causeview__Orders__r) FROM Account WHERE id in : accountIds];
        for(account  a : accounts){
            if(a.causeview__Orders__r.size()>1){
                for(causeview__Payment__c p : accountToPayMap.get(a.id)){
                    paymentsCanNotBeDeleted.add(p);
                    paymentsCanBeDeleted.remove(p.id);                    
                }                 
            }        
        }
        list<causeview__Recurring_Donation__c> rdGifts  =[ SELECT Name, (SELECT Name FROM causeview__Orders__r) FROM causeview__Recurring_Donation__c WHERE id in : rdGiftIds];
        for(causeview__Recurring_Donation__c  rd : rdGifts){
            if(rd.causeview__Orders__r.size()>1){
                for(causeview__Payment__c p : rdGiftToPayMap.get(rd.id)){
                    paymentsCanNotBeDeleted.add(p);
                    paymentsCanBeDeleted.remove(p.id) ;
                }                                    
            }           
        }
        prepareWrapper(paymentsCanBeDeleted.values(), paymentsCanNotBeDeleted);                
    }
    
    public void prepareWrapper(list<causeview__Payment__c> paymentsCanBeDeleted, set<causeview__Payment__c> paymentsCanNotBeDeleted){        
        lstWrapper =  new List<PaymentWrapper>();
        lstSetController = new List<PaymentWrapper>();
        for(causeview__Payment__c pay : paymentsCanBeDeleted )
        {
            lstWrapper.add(new PaymentWrapper(pay ,false, true));
        }
        for(causeview__Payment__c pay : paymentsCanNotBeDeleted )
        {
            lstWrapper.add(new PaymentWrapper(pay ,false, false));
        }
        obj = new CustomIterable (lstWrapper); 
        obj.setPageSize = 50;
        totalRecs = paymentsCanBeDeleted.size() + paymentsCanNotBeDeleted.size();
        LimitSize = obj.setPageSize;
        if(totalRecs > 0){
            totalPages = (Math.mod(totalRecs, LimitSize) == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize) + 1);    //To display number of pages of records in visualforce page, if more than 1500 records then display number of pages according to records
        }else
        {
            totalPages = 1;
        }
        pageNumber = 0;
        next(); 
    }
    
    public Boolean hasNext {
        get 
        {
            return obj.hasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get 
        {
            return obj.hasPrevious();
        }
        set;
    }
    
    public void fistPage() 
    {
        pageNumber = 1;
        lstSetController = obj.fistPage();
    }
    
    public void next() 
    {
        pageNumber++;
        lstSetController = obj.next();
    }
    
    public void previous() 
    {
        pageNumber--;
        lstSetController = obj.previous();
    }
    
    public void lastPage() 
    {
        pageNumber = (Math.mod(totalRecs, LimitSize) == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize) + 1);
        lstSetController = obj.lastPage();
    }    
    
    public pageReference deleteSelected() 
    {        
        set<id> payIds = new set<id>();
        set<id> giftIds = new set<id>();
        set<id> rdGiftsIds = new set<id>();
        set<id> contactIds = new set<id>();
        set<id> accountIds = new set<id>();
        set<id> gAidIds = new set<id>();
        set<causeview__Payment__c> paymentsToBeDeleted = new set<causeview__Payment__c>();
        list<causeview__Payment__c> payments = new list<causeview__Payment__c>();
        set<causeview__Installment_Fulfillment__c> instFullfills = new set<causeview__Installment_Fulfillment__c>();
        set<causeview__Gift_Detail__c> allocations = new set<causeview__Gift_Detail__c>();
        set<causeview__Receipt__c> receipts = new set<causeview__Receipt__c>();
        set<causeview__Solicitor__c> softCredits = new set<causeview__Solicitor__c>();
        set<causeview__RD_Allocation__c> rdAllocations = new set<causeview__RD_Allocation__c>();
        list<causeview__Gift__c> gifts = new list<causeview__Gift__c>();        
        list<causeview__Recurring_Donation__c> rdGifts =  new list<causeview__Recurring_Donation__c>();
        list<causeview__Gift_Aid_Declaration__c> gADeclarations =  new list<causeview__Gift_Aid_Declaration__c>();   
        
        try{
            for(PaymentWrapper Pwrap : lstWrapper){            
                if(Pwrap.isSelected){                
                    payIds.add(Pwrap.pay.id);
                    giftIds.add(Pwrap.pay.causeview__Donation__c);
                    gAidIds.add(Pwrap.pay.causeview__Gift_Aid_Declaration__c);                
                }
            }
            payments = [select id, name, (SELECT Name FROM causeview__Installment_Fulfillments__r), (SELECT Name FROM causeview__Payments__r), (SELECT Name FROM causeview__Allocations__r) from causeview__Payment__c where id in : payIds];
            for(causeview__Payment__c p : payments){
                for(causeview__Installment_Fulfillment__c inF : p.causeview__Installment_Fulfillments__r){
                    instFullfills.add(inF);
                }
                for(causeview__Payment__c pTD : p.causeview__Payments__r){
                    paymentsToBeDeleted.add(pTD);
                }
                for(causeview__Gift_Detail__c gD : p.causeview__Allocations__r){
                    allocations.add(gD);
                }
            }
            list<causeview__Gift_Detail__c>  allocationsToDelete = new list<causeview__Gift_Detail__c>(allocations);
            list<causeview__Installment_Fulfillment__c>  instFullfillsToDelete = new list<causeview__Installment_Fulfillment__c>(instFullfills);            
            list<causeview__Payment__c>  refundsToBeDeleted = new list<causeview__Payment__c>(paymentsToBeDeleted);
            Database.delete(allocationsToDelete, false);
            Database.delete(instFullfillsToDelete, false);
            Database.delete(refundsToBeDeleted, false);
            Database.delete(payments, false);
            allocationsToDelete.clear();
            refundsToBeDeleted.clear();
            instFullfillsToDelete.clear();
            allocations.clear();
            allocations.clear();
            
            gifts = [SELECT Name, causeview__Recurring_Donation__c,	causeview__Constituent__c, causeview__Organization__c, (SELECT Name FROM causeview__Recurring_Payments__r), (SELECT Name FROM causeview__Gift_Allocations__r), (SELECT Name FROM causeview__Soft_Credits__r), (SELECT Name FROM causeview__Receipts__r) FROM causeview__Gift__c WHERE id in : giftIds];        
            for(causeview__Gift__c g: gifts){
                rdGiftsIds.add(g.causeview__Recurring_Donation__c);
                contactIds.add(g.causeview__Constituent__c);
                accountIds.add(g.causeview__Organization__c);
                for(causeview__Gift_Detail__c gD : g.causeview__Gift_Allocations__r){
                    allocations.add(gD);
                }
                for(causeview__Receipt__c recpt : g.causeview__Receipts__r){
                    receipts.add(recpt);
                }
                for(causeview__Solicitor__c sC : g.causeview__Soft_Credits__r){
                    softCredits.add(sC);
                }
                for(causeview__Payment__c pTD : g.causeview__Recurring_Payments__r){
                    paymentsToBeDeleted.add(pTD);
                }
                
            } 
            list<causeview__Receipt__c>  receiptsToDelete = new list<causeview__Receipt__c>(receipts);
            Database.delete(receiptsToDelete, false);
            list<causeview__Solicitor__c>  softCreditsToDelete = new list<causeview__Solicitor__c>(softCredits);
            Database.delete(softCreditsToDelete, false);
            
            rdGifts = [SELECT Name, (SELECT Name FROM causeview__Recurring_Gift_Allocations__r) FROM causeview__Recurring_Donation__c WHERE id in : rdGiftsIds];        
            gADeclarations = [SELECT Name FROM causeview__Gift_Aid_Declaration__c WHERE id in : gAidIds];      
            
            for(causeview__Recurring_Donation__c rd: rdGifts){            
                for(causeview__RD_Allocation__c gD : rd.causeview__Recurring_Gift_Allocations__r){
                    rdAllocations.add(gD);
                }
            }      
            
            list<causeview__RD_Allocation__c>  rdAllocationsToDelete =new  list<causeview__RD_Allocation__c>(rdAllocations);
            Database.delete(rdAllocationsToDelete, false);
            Database.delete(gADeclarations, false);
            Database.delete(rdGifts, false);
            Database.delete(gifts, false);
            
            list<contact> contactToDelete = [SELECT Name FROM contact WHERE id in :contactIds ];
            Database.delete(contactToDelete, false);
            list<account> accountToDelete = [SELECT Name FROM account WHERE id in :accountIds ];
            Database.delete(accountToDelete, false);
        }catch(exception e){            
            if(e.getMessage() != null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in deleteing records'));
            }
        }
        retrievePayments();
        return null;
    }
    
    public class PaymentWrapper
    {
        public Boolean isSelected {get;set;}
        public Boolean canDelete {get;set;}        
        public causeview__Payment__c pay{get;set;}        
        public PaymentWrapper(causeview__Payment__c pay,Boolean isSelected, Boolean canDelete)
        {
            this.pay= pay;
            this.isSelected= isSelected;
            this.canDelete= canDelete;            
        }
        
    }
    public class  CustomIterable implements Iterator<list<PaymentWrapper>>
    { 
        list<PaymentWrapper> InnerList{get; set;}
        list<PaymentWrapper> ListRequested{get; set;}
        
        Integer i {get; set;} 
        public Integer setPageSize {get; set;} 
        
        public CustomIterable(List<PaymentWrapper> lstPayWr)
        {
            InnerList = new list<PaymentWrapper >(); 
            ListRequested = new list<PaymentWrapper >();     
            InnerList = lstPayWr;
            setPageSize = 10;
            i = 0; 
        }   
        
        public boolean hasNext(){ 
            if(i >= InnerList.size()) {
                return false; 
            } else {
                return true; 
            }
        } 
        
        public boolean hasPrevious(){ 
            system.debug('I am in hasPrevious' + i);
            if(i <= setPageSize) {
                return false; 
            } else {
                return true; 
            }
        }   
        
        public list<PaymentWrapper > fistPage(){       
            system.debug('i value is ' + i);            
            ListRequested = new list<PaymentWrapper >(); 
            integer startNumber;
            integer size = InnerList.size();             
            startNumber = 0;
            i = setPageSize;                
            for(integer start = startNumber; start < i; start++)
            {
                ListRequested.add(InnerList[start]);
            }            
            return ListRequested;
        }
        
        public list<PaymentWrapper > next(){       
            system.debug('i value is ' + i);            
            ListRequested = new list<PaymentWrapper >(); 
            integer startNumber;
            integer size = InnerList.size();
            if(hasNext())
            {  
                if(size <= (i + setPageSize))
                {
                    startNumber = i;
                    i = size;
                }
                else
                {
                    i = (i + setPageSize);
                    startNumber = (i - setPageSize);
                }
                
                system.debug('i value is =====' + i);
                system.debug('i value is 2==== ' + (i - setPageSize));
                
                for(integer start = startNumber; start < i; start++)
                {
                    ListRequested.add(InnerList[start]);
                }
            } 
            return ListRequested;
        } 
        
        public list<PaymentWrapper > previous(){            
            ListRequested = new list<PaymentWrapper >(); 
            system.debug('i value is previous before =====' + i);
            integer size = InnerList.size(); 
            if(i == size)
            {
                if(math.mod(size, setPageSize) > 0)
                {    
                    i = size - math.mod(size, setPageSize);
                }
                else
                {
                    i = (size - setPageSize);
                } 
            }
            else
            {
                i = (i - setPageSize);
            }
            
            system.debug('i value is previous =====' + i);
            system.debug('i value is 2previous ==== ' + (i - setPageSize));
            
            for(integer start = (i - setPageSize); start < i; ++start)
            {
                ListRequested.add(InnerList[start]);
            } 
            return ListRequested;
        }
        
        public list<PaymentWrapper > lastPage(){       
            system.debug('i value is ' + i);            
            ListRequested = new list<PaymentWrapper >(); 
            integer startNumber;
            integer size = InnerList.size();             
            startNumber = size - setPageSize;
            i = size;                
            for(integer start = startNumber; start < i; start++)
            {
                ListRequested.add(InnerList[start]);
            }            
            return ListRequested;
        }
    }    
}