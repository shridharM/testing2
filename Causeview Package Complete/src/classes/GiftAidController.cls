public with sharing class GiftAidController {
//To be claimed: START    
    public integer toBeTotalRecs {
      get {return toBeTotalRecs;}
      set {toBeTotalRecs = value;}}
    public integer toBeOffsetSize {
      get {return toBeOffsetSize;}
      set {toBeOffsetSize = value;}}    
    public integer toBeLimitSize {
      get {return toBeLimitSize;}
      set {toBeLimitSize = value;}}    
    public list<causeview__Payment__c> getToBeList{get;set;}    
    public list<causeview__Payment__c> listOfToBeClaimed{get;set;}
    public Decimal sumToBeClaimed{get;set;}     
    public list<selectoption> perPageNumbers { get; set; }
    public integer perPageSelection { get; set; }    
    public PageReference assignPerPage() {
        toBeLimitSize = perPageSelection;    
        return null;
    }
    
    //Pagination                
    public list<causeview__Payment__c> getToBeList() {
        list<causeview__Payment__c> toBeList = Database.Query('SELECT Id, causeview__Constituent__c, Gift_Aid_Declaration__c, Name, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Not claimed\' AND Gift_Aid_Eligible__c = true ORDER BY causeview__Date__c DESC LIMIT :toBeLimitSize OFFSET :toBeOffsetSize');
        return toBeList;}
    public void FirstPage() {toBeOffsetSize = 0;}
    public void previous() {toBeOffsetSize = toBeOffsetSize - toBeLimitSize;} 
    public void next(){toBeOffsetSize = toBeOffsetSize + toBeLimitSize;}
    public void LastPage() {toBeOffsetSize = toBeTotalRecs - math.mod(toBeTotalRecs,toBeLimitSize);}
    public boolean getprev() {
        if(toBeOffsetSize == 0)return true;
        else return false;}
    public boolean getnxt() {
        if((toBeOffsetSize + toBeLimitSize) > toBeTotalRecs) return true;
    else return false;}         
//To be claimed: END   

//Claimed not received: START
    public integer cnrTotalRecs {
      get {return cnrTotalRecs;}
      set {cnrTotalRecs = value;}}
    public integer cnrOffsetSize {
      get {return cnrOffsetSize;}
      set {cnrOffsetSize = value;}}    
    public integer cnrLimitSize {
      get {return cnrLimitSize;}
      set {cnrLimitSize = value;}}    
    public list<causeview__Payment__c> getcnrList{get;set;}    
    public list<causeview__Payment__c> listOfcnr{get;set;}
    public Decimal sumNotReceived{get;set;}     
    public list<selectoption> cnrperPageNumbers { get; set; }
    public integer cnrperPageSelection { get; set; }    
    public PageReference cnrassignPerPage() {
        cnrLimitSize = cnrperPageSelection;    
        return null;}
    
    //Pagination                
    public list<causeview__Payment__c> getcnrList() {
        list<causeview__Payment__c> cnrList = Database.Query('SELECT Id, Name, causeview__Constituent__c, Gift_Aid_Declaration__c, causeview__Date__c, Gift_Aid_Amount__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Claimed not received\' AND Gift_Aid_Eligible__c = true ORDER BY causeview__Date__c DESC LIMIT :cnrLimitSize OFFSET :cnrOffsetSize');        
        return cnrList;}
    public void cnrFirstPage() {cnrOffsetSize = 0;}
    public void cnrprevious() {cnrOffsetSize = cnrOffsetSize - cnrLimitSize;} 
    public void cnrnext(){cnrOffsetSize = cnrOffsetSize + cnrLimitSize;}
    public void cnrLastPage() {cnrOffsetSize = cnrTotalRecs - math.mod(cnrTotalRecs,cnrLimitSize);}
    public boolean getcnrprev() {
        if(cnrOffsetSize == 0) return true;
        else return false;
    }
    public boolean getcnrnxt() {
        if((cnrOffsetSize + cnrLimitSize) > cnrTotalRecs) return true;
    else return false;}
//Claimed not received: END

//Received: START
    public integer receivedTotalRecs {
      get {return receivedTotalRecs;}
      set {receivedTotalRecs = value;}}    
    public integer receivedOffsetSize {
      get {return receivedOffsetSize;}
      set {receivedOffsetSize = value;}}    
    public integer receivedLimitSize {
      get {return receivedLimitSize;}
      set {receivedLimitSize = value;}}    
    public list<causeview__Payment__c> getreceivedList{get;set;}    
    public list<causeview__Payment__c> listOfreceived{get;set;}
    public Decimal sumReceived{get;set;}     
    public list<selectoption> receivedperPageNumbers { get; set; }
    public integer receivedperPageSelection { get; set; }    
    public PageReference receivedassignPerPage() {
        receivedLimitSize = receivedperPageSelection;    
        return null;}
    
    //Pagination                
    public list<causeview__Payment__c> getreceivedList() {
        list<causeview__Payment__c> receivedList = Database.Query('SELECT Id, Name, Gift_Aid_Declaration__c, causeview__Constituent__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c, Gift_Aid_Received_Date__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Received\' ORDER BY causeview__Date__c DESC LIMIT :receivedLimitSize OFFSET :receivedOffsetSize');      
        return receivedList;}
    public void receivedFirstPage() {receivedOffsetSize = 0;}
    public void receivedprevious() {receivedOffsetSize = receivedOffsetSize - receivedLimitSize;} 
    public void receivednext(){receivedOffsetSize = receivedOffsetSize + receivedLimitSize;}
    public void receivedLastPage() {receivedOffsetSize = receivedTotalRecs - math.mod(receivedTotalRecs,receivedLimitSize);}
    public boolean getreceivedprev() {
        if(receivedOffsetSize == 0) return true;
        else return false;
    }
    public boolean getreceivednxt() {
        if((receivedOffsetSize + receivedLimitSize) > receivedTotalRecs) return true;
    else return false;}
//Received: END    

//Rejected: START
    public integer rejectedTotalRecs {
      get {return rejectedTotalRecs;}
      set {rejectedTotalRecs = value;}}    
    public integer rejectedOffsetSize {
      get {return rejectedOffsetSize;}
      set {rejectedOffsetSize = value;}}    
    public integer rejectedLimitSize {
      get {return rejectedLimitSize;}
      set {rejectedLimitSize = value;}}    
    public list<causeview__Payment__c> getrejectedList{get;set;}    
    public list<causeview__Payment__c> listOfrejected{get;set;}
    public Decimal sumRejected{get;set;}     
    public list<selectoption> rejectedperPageNumbers { get; set; }
    public integer rejectedperPageSelection { get; set; }
    public PageReference rejectedassignPerPage() {
        rejectedLimitSize = rejectedperPageSelection;    
        return null;}
    
    //Pagination                
    public list<causeview__Payment__c> getrejectedList() {
        list<causeview__Payment__c> rejectedList = Database.Query('SELECT Id, Name, Gift_Aid_Declaration__c, causeview__Constituent__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Rejected\' ORDER BY causeview__Date__c DESC LIMIT :rejectedLimitSize OFFSET :rejectedOffsetSize');
        return rejectedList;}
    public void rejectedFirstPage() {rejectedOffsetSize = 0;}
    public void rejectedprevious() {rejectedOffsetSize = rejectedOffsetSize - rejectedLimitSize;} 
    public void rejectednext(){rejectedOffsetSize = rejectedOffsetSize + rejectedLimitSize;}
    public void rejectedLastPage() {rejectedOffsetSize = rejectedTotalRecs - math.mod(rejectedTotalRecs,rejectedLimitSize);}
    public boolean getrejectedprev() {
        if(rejectedOffsetSize == 0) return true;
        else return false;
    }
    public boolean getrejectednxt() {
        if((rejectedOffsetSize + rejectedLimitSize) > rejectedTotalRecs) return true;
    else return false;
    }
//Rejected: END
    
//CSV: START
    public string contentType { get; set; }
//CSV: END


//=========================================Constructor==============================================================================
    public GiftAidController(){
//=========================================Constructor==============================================================================        
        //To be claimed 
        sumToBeClaimed = (Decimal)[SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Not claimed'][0].get('sum');      
        toBeTotalRecs = 0;
        toBeOffsetSize = 0;
        toBeLimitSize= 10;
        toBeTotalRecs = [SELECT count() FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Not claimed' AND causeview__Gift_Aid_Eligible__c = true ];
        list<causeview__Payment__c> toBeList = Database.Query('SELECT Id, causeview__Constituent__c, Gift_Aid_Declaration__c, Name, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Not claimed\' AND Gift_Aid_Eligible__c = true ORDER BY causeview__Date__c DESC LIMIT :toBeLimitSize OFFSET :toBeOffsetSize');
        if(toBeTotalRecs <= 10){
            perPageNumbers = new list<selectoption>();
            perPageNumbers.add(new selectoption(String.valueOf(toBeTotalRecs),'Showing All'));  
        }else{
            perPageNumbers = new list<selectoption>();
            perPageNumbers.add(new selectoption('10','10'));
            perPageNumbers.add(new selectoption('25','25'));
            perPageNumbers.add(new selectoption('50','50'));
            perPageNumbers.add(new selectoption(String.valueOf(toBeTotalRecs),'Show All'));  
        }
      
        //Claimed not received                 

        sumNotReceived = (Decimal)[SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Claimed not received'][0].get('sum');
        cnrTotalRecs = 0;
        cnrOffsetSize = 0;
        cnrLimitSize= 10; 
        cnrTotalRecs = [SELECT count() FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Claimed not received'];  
        list<causeview__Payment__c> cnrList = Database.Query('SELECT Id, Name, causeview__Constituent__c, Gift_Aid_Declaration__c, causeview__Date__c, Gift_Aid_Amount__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Claimed not received\' AND Gift_Aid_Eligible__c = true ORDER BY causeview__Date__c DESC LIMIT :cnrLimitSize OFFSET :cnrOffsetSize');
        if(cnrTotalRecs <= 10){
            cnrperPageNumbers = new list<selectoption>();
            cnrperPageNumbers.add(new selectoption(String.valueOf(cnrTotalRecs),'Showing All'));         
        }else{
            cnrperPageNumbers = new list<selectoption>();
            cnrperPageNumbers.add(new selectoption('10','10'));
            cnrperPageNumbers.add(new selectoption('25','25'));
            cnrperPageNumbers.add(new selectoption('50','50'));   
            cnrperPageNumbers.add(new selectoption(String.valueOf(cnrTotalRecs),'Show All'));         
        }
      
        //Received
        
        sumReceived = (Decimal)[SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Received'][0].get('sum');
        receivedTotalRecs = 0;
        receivedOffsetSize = 0;
        receivedLimitSize= 10;
        receivedTotalRecs = [SELECT count() FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Received']; 
        list<causeview__Payment__c> receivedList = Database.Query('SELECT Id, Name, Gift_Aid_Declaration__c, causeview__Constituent__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c, Gift_Aid_Received_Date__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Received\' ORDER BY causeview__Date__c DESC LIMIT :receivedLimitSize OFFSET :receivedOffsetSize');
        if(receivedTotalRecs <= 10){
            receivedperPageNumbers = new list<selectoption>(); 
            receivedperPageNumbers.add(new selectoption(String.valueOf(receivedTotalRecs),'Showing All'));
            
        }else{
            receivedperPageNumbers = new list<selectoption>();
            receivedperPageNumbers.add(new selectoption('10','10'));
            receivedperPageNumbers.add(new selectoption('25','25'));
            receivedperPageNumbers.add(new selectoption('50','50'));    
            receivedperPageNumbers.add(new selectoption(String.valueOf(receivedTotalRecs),'Show All'));
        }

        //Rejected

        sumRejected = (Decimal)[SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Rejected'][0].get('sum');
        rejectedTotalRecs = 0;
        rejectedOffsetSize = 0;
        rejectedLimitSize= 10;
        rejectedTotalRecs = [SELECT count() FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Rejected'];
        list<causeview__Payment__c> rejectedList = Database.Query('SELECT Id, Name, Gift_Aid_Declaration__c, causeview__Constituent__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Rejected\' ORDER BY causeview__Date__c DESC LIMIT :rejectedLimitSize OFFSET :rejectedOffsetSize');
        if(rejectedTotalRecs <= 10){
            rejectedperPageNumbers = new list<selectoption>();
            rejectedperPageNumbers.add(new selectoption(String.valueOf(rejectedTotalRecs),'Showing All'));          
        }else{
            rejectedperPageNumbers = new list<selectoption>();
            rejectedperPageNumbers.add(new selectoption('10','10'));
            rejectedperPageNumbers.add(new selectoption('25','25'));
            rejectedperPageNumbers.add(new selectoption('50','50'));    
            rejectedperPageNumbers.add(new selectoption(String.valueOf(rejectedTotalRecs),'Show All'));          
        }           
        contentType = 'text/html'; //CSV
    }
    
    public PageReference exportToCSV() {
        PageReference ref = new PageReference('/apex/exportGiftAid');
    return ref;}
}