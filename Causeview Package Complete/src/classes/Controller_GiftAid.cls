/* public with sharing class Controller_GiftAid {
//QUERY BUILDER
    private String fields = 'ID, causeview__Constituent__c, Gift_Aid_Declaration__r.Donor__r.Title, Gift_Aid_Declaration__r.Donor__r.Salutation, Name, First_Name__c, Last_Name__c, Gift_Aid_Claim_Status__c, House_Number__c, Postal_Code__c, Gift_Aid_Declaration__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Date__c, Gift_Aid_Received_Date__c';
    private String criteria = 'WHERE Gift_Aid_Eligible__c = true AND Gift_Aid_Amount__c > 0 AND Gift_Aid_Declaration__c != \'\'';
    //SORT BY
    private String sortbyPaymentDate = 'ORDER BY causeview__Date__c DESC,Gift_Aid_Declaration__c DESC';
    private String sortbyClaimDate = 'ORDER BY Gift_Aid_Claim_Date__c DESC';
    private String sortbyReceivedDate = 'ORDER BY Gift_Aid_Received_Date__c DESC';
    //GIFT AID STATUS
    private String tobeclaimed = 'AND Gift_Aid_Claim_Status__c = \'Not claimed\'';
    private String claimedNotReceived = 'AND Gift_Aid_Claim_Status__c = \'Claimed not received\'';
    private String received = 'AND Gift_Aid_Claim_Status__c = \'Received\'';
    private String rejected = 'AND Gift_Aid_Claim_Status__c = \'Rejected\'';
    //QUERY
    private String tbcQuery = 'SELECT '+ fields +' FROM causeview__Payment__c '+ criteria +' AND Gift_Aid_Claim_Status__c = \'Not claimed\' ' + sortbyPaymentDate;
    private String cnrQuery = 'SELECT '+ fields +' FROM causeview__Payment__c '+ criteria +' AND Gift_Aid_Claim_Status__c = \'Claimed not received\' ' + sortbyClaimDate;
    private String recQuery = 'SELECT '+ fields +' FROM causeview__Payment__c '+ criteria +' AND Gift_Aid_Claim_Status__c = \'Received\' ' + sortbyReceivedDate;
    private String rejQuery = 'SELECT '+ fields +' FROM causeview__Payment__c '+ criteria +' AND Gift_Aid_Claim_Status__c = \'Rejected\' ' + sortbyPaymentDate;
//FOR LOADING SCREEN
    public boolean jobProcess {get;set;}
    public boolean claimChangeJob {get;set;}
    public integer tbc_pollarInterval {get{if(tbc_IDs.size()>600){return 7;}else{return 5;}}}
    public integer cnr_pollarInterval {get{if(cnr_IDs.size()>600){return 7;}else{return 5;}}}
//EXPORT FILE
    DateTime d = datetime.now();
    String currentMonth= d.format('MMMMM');
    String currentYear = String.valueOf(d.year());
    public String exportFileName = 'Gift_Aid_'+currentMonth+'-'+currentYear;
    public String exportContentType {get{return 'text/csv#'+exportFileName+'.csv';}}
    Set<ID> tbc_IDs;
    //POSSIBLE BUG: issues arise where header does not go to a new line test using \r\n
    public string header{get{return 'Title,First Name,Last Name,House Name or number,Postalcode,,,Donation Date,Amount\n';}}//csv header
    public List<wrapper> lstwrapper {get; set;}     //wrapper to access values
    public class wrapper{                           //wrapper for each record
        public String title {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String house {get; set;}
        public String postal {get; set;}
        public String donorName {get; set;}
        public Date giftDate{get; set;}
        public Decimal giftAmount{get; set;}
    }
    public string Filetype{get;set;}                //file type for spreadsheet {csv/xls}
    public boolean isExcel {get;set;}               //bool if filetype is excel
    public boolean isCsv {get;set;}                 //bool if filetype is csv
    public String successfulExport {get;set;}
    public boolean selectAll {get;set;}
    public string contentType {get;set;}
//START-BLOCK: TO BE CLAIMED
//TODO: Rename variables appropriately
    public class wrapPayment {
        public causeview__Payment__c pay {get; set;}
        public Boolean selected {get; set;}
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapPayment( causeview__Payment__c p)
        {
            pay = p;
            selected = false;
        }
    }//END: wrapPayment
    public Integer pageSize { get; set; }           //number of records per page
    public Integer pageNumber { get; set; }         //current page number
    public Integer numberOfPages { get; set; }      //total number of pages
    public List<causeview__Payment__c> tbcList{get{return Database.Query(tbcQuery);}}
    public List<wrapPayment> wrapPaymentList    //Our collection of the class/wrapper objects wrapPayment
        {get{
            if ( wrapPaymentList == null ){
                wrapPaymentList = new List<wrapPayment>();
                for (causeview__Payment__c p:tbcList){wrapPaymentList.add( new wrapPayment( p ) );}
            }
            return wrapPaymentList;
        }
        private set;
    }//END: wrapPaymentList
    private List<List<wrapPayment>> list_Pages
        {get{
            if ( list_Pages == null ){
                list_Pages = new List<List<wrapPayment>>();
                Integer numInPage = pageSize;
                List<wrapPayment> thePage;
                if(wrapPaymentList.size() > 0) {
                    for ( wrapPayment pPay : wrapPaymentList )
                    {
                        if ( numInPage >= pageSize )
                        {
                            thePage = new List<wrapPayment>();
                            list_Pages.add( thePage );
                            numInPage = 0;
                        }
                        thePage.add( pPay );
                        numInPage++;
                    }
                }
            }
            System.debug('list_Pages.size(): '+list_Pages.size());
            if(list_Pages.size() >0){numberOfPages = list_Pages.size() - 1;}
            return list_Pages;
        }
        private set;
    }//END: list_Pages
    public List<wrapPayment> currentPage  { get {
        If(list_Pages!=null && list_Pages.size() > 0){
            return list_Pages[ pageNumber ];
        }else{
            return null;
        }
    }}//END: currentPage
    public Boolean isFirst     { get { return pageNumber != 0; } }
    public Boolean isLast      { get { return pageNumber != list_Pages.size() - 1; } }
    public Boolean hasPrevious     { get { return pageNumber > 0; } }
    public Boolean hasNext         { get { return pageNumber < list_Pages.size() - 1; } }
    public void first() { if ( isFirst ) pageNumber = 0; }
    public void last() { pageNumber = list_Pages.size() - 1; }
    public void previousPage()         { if ( hasPrevious  ) pageNumber--; }
    public void nextPage()             { if ( hasNext      ) pageNumber++; }
    public Integer toBeTotalRecs {get{return Database.countQuery('SELECT count() FROM causeview__Payment__c '+ criteria + tobeclaimed);} private set;}
    public double sumToBeClaimed {get{sumToBeClaimed = (double)Database.Query('SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c '+ criteria + tobeclaimed)[0].get('sum');return sumToBeClaimed=(sumToBeClaimed==null?0:sumToBeClaimed);} private set;}
    public List<selectoption> perPageNumbers { get; set; }
    public String perPageSelection { get; set; }
    public void assignPerPage() {
        pageSize = Integer.valueOf(perPageSelection);
        wrapPaymentList = null;
        list_Pages  = null;
        pageNumber = 0;
    }//END: assignPerPage
//END-BLOCK: TO BE CLAIMED
//START-BLOCK: CLAIMED NOT RECEIVED
    Set<ID> cnr_IDs;
    public class cnrWrapPayment {
        public causeview__Payment__c pay {get; set;}
        public Boolean selected {get; set;}
        public cnrWrapPayment( causeview__Payment__c p){
            pay = p;
            selected = false;
        }
    }//END: cnrWrapPayment
    public Integer cnrPageSize { get; set; }            //number of records per page
    public Integer cnrPageNumber { get; set; }          //current page number
    public Integer cnrNumberOfPages { get; set; }       //total number of pages
    public List<causeview__Payment__c> cnrList{get{return Database.Query(cnrQuery);}}
    public List<cnrWrapPayment> cnrWrapPaymentList    //Our collection of the class/wrapper objects wrapPayment
        {get{
            if ( cnrWrapPaymentList == null ){
                cnrWrapPaymentList = new List<cnrWrapPayment>();
                for (causeview__Payment__c p:cnrList)
                {   //  As each contact is processed we create a new cContact object
                    //  and add it to the contactList
                    cnrWrapPaymentList.add( new cnrWrapPayment( p ) );
                }
            }
        return cnrWrapPaymentList;
        }
        private set;
    }
    private List<List<cnrWrapPayment>> cnr_list_Pages
        {get{
            if ( cnr_list_Pages == null ){
                cnr_list_Pages = new List<List<cnrWrapPayment>>();
                Integer numInPage = cnrPageSize;
                List<cnrWrapPayment> thePage;
                if(cnrWrapPaymentList.size() > 0) {
                    for ( cnrWrapPayment pPay : cnrWrapPaymentList )
                    {
                        if ( numInPage >= cnrPageSize )
                        {
                            thePage = new List<cnrWrapPayment>();
                            cnr_list_Pages.add( thePage );
                            numInPage = 0;
                        }
                        thePage.add( pPay );
                        numInPage++;
                    }
                }
            }
        if(cnr_list_Pages.size() >0){cnrNumberOfPages = cnr_list_Pages.size() - 1;}
        return cnr_list_Pages;
        }
        private set;
    }
    public List<cnrWrapPayment> cnrCurrentPage  { get {
        If(cnr_list_Pages!=null && cnr_list_Pages.size() > 0){
            return cnr_list_Pages[ cnrPageNumber ];
        }else{
            return null;
        }
    }}
    public Boolean cnr_isFirst     { get { return cnrPageNumber != 0; } }
    public Boolean cnr_isLast      { get { return cnrPageNumber != cnr_list_Pages.size() - 1; } }
    public Boolean cnr_hasPrevious     { get { return cnrPageNumber > 0; } }
    public Boolean cnr_hasNext         { get { return cnrPageNumber < cnr_list_Pages.size() - 1; } }
    public void cnr_first() { if ( cnr_isFirst ) cnrPageNumber = 0; }
    public void cnr_last() { cnrPageNumber = cnr_list_Pages.size() - 1; }
    public void cnr_previousPage()         { if ( cnr_hasPrevious  ) cnrPageNumber--; }
    public void cnr_nextPage()             { if ( cnr_hasNext      ) cnrPageNumber++; }
    public Integer cnr_TotalRecs {get{return Database.countQuery('SELECT count() FROM causeview__Payment__c '+ criteria + claimedNotReceived);} private set;}
    public double cnr_Sum {get{cnr_Sum = (double)Database.Query('SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c '+ criteria + claimedNotReceived)[0].get('sum');return cnr_Sum=(cnr_Sum==null?0:cnr_Sum);} private set;}
    public List<selectoption> cnr_perPageNumbers { get; set; }
    public String cnr_perPageSelection { get; set; }
    public void cnr_assignPerPage() {
        cnrPageSize = Integer.valueOf(cnr_perPageSelection);
        cnrWrapPaymentList = null;
        cnr_list_Pages  = null;
        cnrPageNumber = 0;
        //checkAll();
    }
    public List<selectoption> claimedStatusTo { get; set; }         //Select Options
    public String changeClaimedTo { get; set; }                     //Selected Value of Select Options
//END-BLOCK: CLAIMED NOT RECEIVED
//START-BLOCK: RECEIVED
    public integer receivedOffsetSize {
      get {return receivedOffsetSize;}
      set {receivedOffsetSize = value;}}
    public integer receivedLimitSize {
      get {return receivedLimitSize;}
      set {receivedLimitSize = value;}}
    public list<causeview__Payment__c> getreceivedList{get;set;}
    public list<causeview__Payment__c> listOfreceived{get;set;}
    public Integer receivedTotalRecs {get{return Database.countQuery('SELECT count() FROM causeview__Payment__c '+ criteria + received);} private set;}
    public double sumReceived {get{sumReceived = (double)Database.Query('SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c '+ criteria + received)[0].get('sum');return sumReceived=(sumReceived==null?0:sumReceived);} private set;}
    public list<selectoption> receivedperPageNumbers { get; set; }
    public integer receivedperPageSelection { get; set; }
    public PageReference receivedassignPerPage() {
        receivedLimitSize = receivedperPageSelection;
        return null;}
    public list<causeview__Payment__c> getreceivedList() {
        list<causeview__Payment__c> receivedList = Database.Query(recQuery + ' LIMIT :receivedLimitSize OFFSET :receivedOffsetSize');
        return receivedList;}
    public void receivedFirstPage() {
        receivedOffsetSize = 0;}
    public void receivedprevious() {
        receivedOffsetSize = receivedOffsetSize - receivedLimitSize;}
    public void receivednext(){
        receivedOffsetSize = receivedOffsetSize + receivedLimitSize;}
    public void receivedLastPage() {
        receivedOffsetSize = receivedTotalRecs - math.mod(receivedTotalRecs,receivedLimitSize);}
    public boolean getreceivedprev() {
        if(receivedOffsetSize == 0)return true;
        else return false;}
    public boolean getreceivednxt() {
        if((receivedOffsetSize + receivedLimitSize) >= receivedTotalRecs) return true;
        else return false;}
//END-BLOCK: RECEIVED
//START-BLOCK: REJECTED
    public integer rejectedOffsetSize {
      get {return rejectedOffsetSize;}
      set {rejectedOffsetSize = value;}}
    public integer rejectedLimitSize {
      get {return rejectedLimitSize;}
      set {rejectedLimitSize = value;}}
    public list<causeview__Payment__c> getrejectedList{get;set;}
    public list<causeview__Payment__c> listOfrejected{get;set;}
    public Integer rejectedTotalRecs {get{return Database.countQuery('SELECT count() FROM causeview__Payment__c '+ criteria + rejected);} private set;}
    public double sumRejected {get{sumRejected = (double)Database.Query('SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c '+ criteria + rejected)[0].get('sum');return sumRejected=(sumRejected==null?0:sumRejected);} private set;}
    public list<selectoption> rejectedperPageNumbers { get; set; }
    public integer rejectedperPageSelection { get; set; }
    public PageReference rejectedassignPerPage() {
        rejectedLimitSize = rejectedperPageSelection;
        return null;}
    //Pagination
    public list<causeview__Payment__c> getrejectedList() {
        list<causeview__Payment__c> rejectedList = Database.Query(rejQuery + ' LIMIT :receivedLimitSize OFFSET :receivedOffsetSize');
        return rejectedList;}
    public void rejectedFirstPage() {
        rejectedOffsetSize = 0;}
    public void rejectedprevious() {
        rejectedOffsetSize = rejectedOffsetSize - rejectedLimitSize;}
    public void rejectednext(){
        rejectedOffsetSize = rejectedOffsetSize + rejectedLimitSize;}
    public void rejectedLastPage() {
        rejectedOffsetSize = rejectedTotalRecs - math.mod(rejectedTotalRecs,rejectedLimitSize);}
    public boolean getrejectedprev() {
        if(rejectedOffsetSize == 0) return true;
        else return false;}
    public boolean getrejectednxt() {
        if((rejectedOffsetSize + rejectedLimitSize) >= rejectedTotalRecs) return true;
        else return false;}
//END-BLOCK: REJECTED
//=========================================Constructor=========================================/
    public Controller_GiftAid(){
        Filetype = '';                          //TODO: Implementation for EXPORT file name
        jobProcess = false;                     //TBC ActionPoller Status
        claimChangeJob = false;                 //CNR ActionPoller Status
        updateAll();                            //Re-initialize variables
        contentType = 'text/html';              //Set VisualForce page content type
    }//END: Controller_GiftAid
//=========================================Constructor=========================================/
    public void updateAll(){
        callTBC();
        callCNR();
        callREC();
        callREJ();
        if(successfulExport!=null){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,successfulExport));}
    }//END: updateAll

    public void callTBC(){
        wrapPaymentList = null;
        list_Pages  = null;
        pageSize = 10;
        pageNumber = 0;
        sumToBeClaimed = 0;
        toBeTotalRecs = 0;

        //if(toBeTotalRecs==0){
        //    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No records to be claimed.');
        //    ApexPages.addMessage(myMsg);
        //}

        //Select Options {10,25,50,Show All}
        //TODO: Build method to handle this assignment
        if(toBeTotalRecs<=10){perPageNumbers = new list<selectoption>();perPageNumbers.add(new selectoption(String.valueOf(toBeTotalRecs),'Showing All'));}else{perPageNumbers = new list<selectoption>();perPageNumbers.add(new selectoption('10','10'));perPageNumbers.add(new selectoption('25','25'));perPageNumbers.add(new selectoption('50','50'));perPageNumbers.add(new selectoption('100','100'));perPageNumbers.add(new selectoption('200','200'));perPageNumbers.add(new selectoption(String.valueOf(toBeTotalRecs),'Show All'));}
    }//END: callTBC

    public void callCNR(){
        cnrPageSize = 10;
        cnrPageNumber = 0;
        cnrWrapPaymentList = null;
        cnr_list_Pages  = null;
        cnr_Sum = 0;
        cnr_TotalRecs = 0;
        //Select Options {Received,Rejected}
        claimedStatusTo = new list<selectoption>();claimedStatusTo.add(new selectoption('Received','Received'));claimedStatusTo.add(new selectoption('Rejected','Rejected'));
        //Select Options {10,25,50,Show All}
        if(cnr_TotalRecs <= 10){cnr_perPageNumbers = new list<selectoption>();cnr_perPageNumbers.add(new selectoption(String.valueOf(cnr_TotalRecs),'Showing All'));}else{cnr_perPageNumbers = new list<selectoption>();cnr_perPageNumbers.add(new selectoption('10','10'));cnr_perPageNumbers.add(new selectoption('25','25'));cnr_perPageNumbers.add(new selectoption('50','50'));cnr_perPageNumbers.add(new selectoption('100','100'));cnr_perPageNumbers.add(new selectoption('200','200'));cnr_perPageNumbers.add(new selectoption(String.valueOf(cnr_TotalRecs),'Show All'));}
    }//END: callCNR

    public void callREC(){
        sumReceived = 0;
        receivedTotalRecs = 0;
        receivedOffsetSize = 0;
        receivedLimitSize= 10;
        //TODO: set in property
        list<causeview__Payment__c> receivedList = Database.Query('SELECT Id, Name, Gift_Aid_Declaration__c, causeview__Constituent__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c, Gift_Aid_Received_Date__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Received\' AND Gift_Aid_Amount__c > 0 ORDER BY causeview__Date__c DESC LIMIT :receivedLimitSize OFFSET :receivedOffsetSize');
        if(receivedTotalRecs <= 10){receivedperPageNumbers = new list<selectoption>();receivedperPageNumbers.add(new selectoption(String.valueOf(receivedTotalRecs),'Showing All'));}else{receivedperPageNumbers = new list<selectoption>();receivedperPageNumbers.add(new selectoption('10','10'));receivedperPageNumbers.add(new selectoption('25','25'));receivedperPageNumbers.add(new selectoption('50','50'));receivedperPageNumbers.add(new selectoption('100','100'));receivedperPageNumbers.add(new selectoption('200','200'));receivedperPageNumbers.add(new selectoption(String.valueOf(receivedTotalRecs),'Show All'));}
    }//END: callREC

    public void callREJ(){
        sumRejected = 0;
        rejectedTotalRecs = 0;
        rejectedOffsetSize = 0;
        rejectedLimitSize= 10;
        //TODO: set in property
        list<causeview__Payment__c> rejectedList = Database.Query('SELECT Id, Name, Gift_Aid_Declaration__c, causeview__Constituent__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Rejected\' AND Gift_Aid_Amount__c > 0 ORDER BY causeview__Date__c DESC LIMIT :rejectedLimitSize OFFSET :rejectedOffsetSize');
        if(rejectedTotalRecs <= 10){rejectedperPageNumbers = new list<selectoption>();rejectedperPageNumbers.add(new selectoption(String.valueOf(rejectedTotalRecs),'Showing All'));}else{rejectedperPageNumbers = new list<selectoption>();rejectedperPageNumbers.add(new selectoption('10','10'));rejectedperPageNumbers.add(new selectoption('25','25'));rejectedperPageNumbers.add(new selectoption('50','50'));rejectedperPageNumbers.add(new selectoption('100','100'));rejectedperPageNumbers.add(new selectoption('200','200'));rejectedperPageNumbers.add(new selectoption(String.valueOf(rejectedTotalRecs),'Show All'));}
    }//END: callREJ

    public PageReference pausingExecution(){
            PageReference pgref;
            system.debug('====job[0].Status=');
            list<AsyncApexJob> job =[SELECT id, Status FROM AsyncApexJob WHERE CreatedDate = today AND MethodName = 'updateGiftAidPayments' AND CreatedById =: UserInfo.getUserId()  ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
            if(job.size()>0){
                system.debug(job[0].id+'====job[0].Status='+job[0].Status);
                if(job[0].Status == 'Queued' || job[0].Status=='Preparing' || job[0].Status=='Processing'){
                    return null ;
                }
                if(job[0].Status == 'Completed' ){
                    jobProcess= false;
                    updateAll();
                }
                if(job[0].Status == 'Aborted' || job[0].Status == 'Failed' || job[0].Status == 'Holding' ){
                    jobProcess= false;
                    job[0].addError('Error occurred during updating Allocations');
                    return null;
                }
            }
            return null;
    }

    public PageReference pausingExecutionForClaimed(){
            PageReference pgref;
            system.debug('====job[0].Status=');
            list<AsyncApexJob> job =[SELECT id, Status FROM AsyncApexJob WHERE CreatedDate = today AND MethodName = 'updateClaimedPayments' AND CreatedById =: UserInfo.getUserId()  ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
            if(job.size()>0){
                system.debug(job[0].id+'====job[0].Status='+job[0].Status);
                if(job[0].Status == 'Queued' || job[0].Status=='Preparing' || job[0].Status=='Processing'){
                    return null ;
                }
                if(job[0].Status == 'Completed' ){
                    claimChangeJob= false;
                    updateAll();
                }
                if(job[0].Status == 'Aborted' || job[0].Status == 'Failed' || job[0].Status == 'Holding' ){
                    claimChangeJob= false;
                    job[0].addError('Error occurred during updating Allocations');
                    return null;
                }
            }
            return null;
    }

    public PageReference processSelected(){
        PageReference ref = null;
        //List<causeview__Payment__c> selectedPayments = new List<causeview__Payment__c>();
        lstwrapper = new List<wrapper>();
        tbc_IDs = new set<id>();

        if (validate_list_data() == true) {
            jobProcess= true;
            //DEBUG
            //System.debug('selectAll: '+selectAll);
            //System.debug('wrapPaymentList.size(): '+wrapPaymentList.size());
            //System.debug('wrapPaymentList: '+wrapPaymentList);
            for ( wrapPayment pPay : wrapPaymentList ){
                System.debug('selected: '+pPay.selected);
                if ( pPay.selected ) {
                    wrapper w = new wrapper();
                    //FIX: New line in Long Text Area
                    String tempString = pPay.pay.House_Number__c;
                    tempString = tempString.replace('\r\n', ' ');
                    tempString = tempString.replace('\n', ' ');
                    tempString = tempString.replace('\r', ' ');
                    tempString = tempString.replace(',', ' ');

                    //Parse Date DD/MM/YY
                    //Date tempDate = pPay.pay.causeview__Date__c;
                    //w.formattedDate =  String.valueOf(tempDate.year())+ '/' + String.valueOf(tempDate.month()) + '/' + String.valueOf(tempDate.year());

                    String tempTitle = pPay.pay.Gift_Aid_Declaration__r.Donor__r.Title;
                    String tempSalutation = pPay.pay.Gift_Aid_Declaration__r.Donor__r.Salutation;
                    String commitTitle;
                    System.debug('tempTitle'+tempTitle);
                    System.debug('tempSalutation'+tempSalutation);
                    if(tempTitle==null){tempTitle = tempSalutation;}
                    tempTitle = tempTitle.replace('.', '');
                    if(tempTitle.length() > 4)
                        {commitTitle = tempTitle.left(4);}else{commitTitle = tempTitle;}
                    //if more than 4 character then shorten
                    w.title = commitTitle;
                    //maximum 35 characters
                    w.firstName = pPay.pay.First_Name__c;
                    //maximum 35 characters
                    w.lastName = pPay.pay.Last_Name__c;
                    w.house = tempString;
                    //using capital letters and include a space, for example, S19 2BD
                    w.postal = pPay.pay.Postal_Code__c;
                    w.giftDate = pPay.pay.causeview__Date__c;
                    w.giftAmount = pPay.pay.Gift_Aid_Amount__c ;

                    //System.debug(w);
                    //Add to List wrapper for export
                    lstwrapper.add(w);

                    //selectedPayments.add(pPay.pay);
                    tbc_IDs.add(pPay.pay.ID);
                }
            }
            //DEBUG
            //System.debug('lstwrapper.size(): '+lstwrapper.size());
            //System.debug('tbc_IDs.size(): '+tbc_IDs.size());
            updateGiftAidPayments(tbc_IDs);
            //ref = new PageReference('/apex/exportGiftAid');
            //ref.setRedirect(false);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Success: Document Porcessed.');
            //ApexPages.addMessage(myMsg);
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'You haven\'t selected any records to process.'));
        }
        //When using export html gift aid schedule
        //ref.getHeaders().put('content-disposition', 'attachment; filename=GiftAid.xls');
        return ref;
    }//END: processSelected

    public PageReference processClaimed(){
        System.debug('processClaimed');
        PageReference ref = null;
        Set<id> claimedIDs = new set<id>();
        //PageReference ref = new PageReference('/apex/Gift_Aid');
        //ref.setRedirect(true);
        //TODO: Validation
        for ( cnrWrapPayment pPay : cnrWrapPaymentList ){
            if ( pPay.selected ) {
                claimedIDs.add(pPay.pay.ID);
                System.debug('claimed Payment: '+ pPay.pay.ID);
            }
        }

        if (claimedIDs.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'You haven\'t selected any records to process.'));
        }else {
            System.debug('processClaimed: Not Empty');
            claimChangeJob= true;
            System.debug('claimChangeJob: '+ claimChangeJob);
            updateClaimedPayments(claimedIDs,changeClaimedTo);
        }

        return ref;
    }//END: processClaimed

    //TODO: change name updateToBeClaimedPayments
    @future
    public static void updateGiftAidPayments(Set<ID> tbc_IDs){
        System.debug('tbc_IDs.size(): '+ tbc_IDs.size());
        List<causeview__Payment__c> payments = new List<causeview__Payment__c>();
        payments= [select id, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c from causeview__Payment__c where id in :tbc_IDs ];

        for(causeview__Payment__c p: payments){
            p.Gift_Aid_Claim_Status__c = 'Claimed Not Received';
            p.Gift_Aid_Claim_Date__c = Date.today();
        }
        update payments;
    }//END: updateGiftAidPayments

    @future
    public static void updateClaimedPayments(Set<ID> cnr_IDs, String status){
        List<causeview__Payment__c> payments = [select ID, Gift_Aid_Claim_Status__c, Gift_Aid_Received_Date__c FROM causeview__Payment__c WHERE ID in :cnr_IDs ];
        for(causeview__Payment__c p: payments){
            p.Gift_Aid_Claim_Status__c = status;
            p.Gift_Aid_Received_Date__c = Date.today();
        }
        update payments;
    }//END: updateClaimedPayments

    public pagereference exportPage(){
        system.debug('CPU Time==='+jobProcess);
        if(!lstwrapper.isEmpty()){
            return Page.exportGiftAid;
            successfulExport = 'Success: Gift-Aid Payments Porcessed. Downloading Gift-Aid Schedule. ';
            for(wrapPayment p: wrapPaymentList){
                p.selected = false;
            }
        }
        lstwrapper = new List<wrapper>();
        selectAll = false;
        return null;
    }//END: exportPage

    //TODO: Accept (wrapPaymentList, wrapPayment)
    public boolean validate_list_data() {
        boolean DataIsValid = true;
        List<causeview__Payment__c> selectedPayments = new List<causeview__Payment__c>();
        for ( wrapPayment pPay : wrapPaymentList ){
            if ( pPay.selected ) {
                selectedPayments.add(pPay.pay);
            }
        }
        if (selectedPayments.isEmpty()) {
            DataIsValid = false;
        }
        return DataIsValid;
    }//END: validate_list_data

    //TODO: Deprecate
    public PageReference redirectApex() {
        PageReference ref = new PageReference('/apex/Gift_Aid');
        ref.setRedirect(true);
        return ref;
    }

    //TODO: Deprecate
    public void checkAll() {
        for(wrapPayment p: wrapPaymentList){
            if(selectAll){
                p.selected = true;
            }else{
                p.selected = false;
            }
            System.Debug(p.selected);
        }
    }
}//END: */

//*******************************************************************************NEW CODE *********************************

//New Code  18-FEB-2016
public with sharing class Controller_GiftAid {
//QUERY BUILDER
    private String fields = 'ID, causeview__Constituent__c, Gift_Aid_Declaration__r.Donor__r.Title, Gift_Aid_Declaration__r.Donor__r.Salutation, Name, First_Name__c, Last_Name__c, Gift_Aid_Claim_Status__c, House_Number__c, Postal_Code__c, Gift_Aid_Declaration__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Date__c, Gift_Aid_Received_Date__c';
    private String criteria = 'WHERE Gift_Aid_Eligible__c = true AND Gift_Aid_Amount__c > 0 AND Gift_Aid_Declaration__c != \'\'';
    //SORT BY
    private String sortbyPaymentDate = 'ORDER BY causeview__Date__c DESC,Gift_Aid_Declaration__c DESC';
    private String sortbyClaimDate = 'ORDER BY Gift_Aid_Claim_Date__c DESC';
    private String sortbyReceivedDate = 'ORDER BY Gift_Aid_Received_Date__c DESC';
    //GIFT AID STATUS
    private String tobeclaimed = 'AND Gift_Aid_Claim_Status__c = \'Not claimed\'';
    private String claimedNotReceived = 'AND Gift_Aid_Claim_Status__c = \'Claimed not received\'';
    private String received = 'AND Gift_Aid_Claim_Status__c = \'Received\'';
    private String rejected = 'AND Gift_Aid_Claim_Status__c = \'Rejected\'';
    //QUERY
    private String tbcQuery = 'SELECT '+ fields +' FROM causeview__Payment__c '+ criteria +' AND Gift_Aid_Claim_Status__c = \'Not claimed\' ' + sortbyPaymentDate;
    private String cnrQuery = 'SELECT '+ fields +' FROM causeview__Payment__c '+ criteria +' AND Gift_Aid_Claim_Status__c = \'Claimed not received\' ' + sortbyClaimDate;
    private String recQuery = 'SELECT '+ fields +' FROM causeview__Payment__c '+ criteria +' AND Gift_Aid_Claim_Status__c = \'Received\' ' + sortbyReceivedDate;
    private String rejQuery = 'SELECT '+ fields +' FROM causeview__Payment__c '+ criteria +' AND Gift_Aid_Claim_Status__c = \'Rejected\' ' + sortbyPaymentDate;
//FOR LOADING SCREEN
    public boolean jobProcess {get;set;}
    public boolean claimChangeJob {get;set;}
    public integer tbc_pollarInterval {get{if(tbc_IDs.size()>600){return 7;}else{return 5;}}}
    public integer cnr_pollarInterval {get{if(cnr_IDs.size()>600){return 7;}else{return 5;}}}
//EXPORT FILE
    DateTime d = datetime.now();
    String currentMonth= d.format('MMMMM');
    String currentYear = String.valueOf(d.year());
    public String exportFileName = 'Gift_Aid_'+currentMonth+'-'+currentYear;
    public String exportContentType {get{return 'text/csv#'+exportFileName+'.csv';}}
    Set<ID> tbc_IDs;
    //POSSIBLE BUG: issues arise where header does not go to a new line test using \r\n
    public string header{get{return 'Title,First Name,Last Name,House Name or number,Postalcode,,,Donation Date,Amount\n';}}//csv header
    public List<wrapper> lstwrapper {get; set;}     //wrapper to access values
    public class wrapper{                           //wrapper for each record
        public String title {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String house {get; set;}
        public String postal {get; set;}
        public String donorName {get; set;}
        public Date giftDate{get; set;}
        public Decimal giftAmount{get; set;}
    }
    public string Filetype{get;set;}                //file type for spreadsheet {csv/xls}
    public boolean isExcel {get;set;}               //bool if filetype is excel
    public boolean isCsv {get;set;}                 //bool if filetype is csv
    public String successfulExport {get;set;}
    public boolean selectAll {get;set;}
    public string contentType {get;set;}
//START-BLOCK: TO BE CLAIMED
//TODO: Rename variables appropriately
    public class wrapPayment {
        public causeview__Payment__c pay {get; set;}
        public Boolean selected {get; set;}
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapPayment( causeview__Payment__c p)
        {
            pay = p;
            selected = false;
        }
    }//END: wrapPayment
    public Integer pageSize { get; set; }           //number of records per page
    public Integer pageNumber { get; set; }         //current page number
    public Integer numberOfPages { get; set; }      //total number of pages
    public List<causeview__Payment__c> tbcList{get{return Database.Query(tbcQuery);}}
    public List<wrapPayment> wrapPaymentList    //Our collection of the class/wrapper objects wrapPayment
        {get{
            if ( wrapPaymentList == null ){
                wrapPaymentList = new List<wrapPayment>();
                for (causeview__Payment__c p:tbcList){wrapPaymentList.add( new wrapPayment( p ) );}
            }
            return wrapPaymentList;
        }
        private set;
    }//END: wrapPaymentList
    private List<List<wrapPayment>> list_Pages
        {get{
            if ( list_Pages == null ){
                list_Pages = new List<List<wrapPayment>>();
                Integer numInPage = pageSize;
                List<wrapPayment> thePage;
                if(wrapPaymentList.size() > 0) {
                    for ( wrapPayment pPay : wrapPaymentList )
                    {
                        if ( numInPage >= pageSize )
                        {
                            thePage = new List<wrapPayment>();
                            list_Pages.add( thePage );
                            numInPage = 0;
                        }
                        thePage.add( pPay );
                        numInPage++;
                    }
                }
            }
            System.debug('list_Pages.size(): '+list_Pages.size());
            if(list_Pages.size() >0){numberOfPages = list_Pages.size() - 1;}
            return list_Pages;
        }
        private set;
    }//END: list_Pages
    public List<wrapPayment> currentPage  { get {
        If(list_Pages!=null && list_Pages.size() > 0){
            return list_Pages[ pageNumber ];
        }else{
            return null;
        }
    }}//END: currentPage
    public Boolean isFirst     { get { return pageNumber != 0; } }
    public Boolean isLast      { get { return pageNumber != list_Pages.size() - 1; } }
    public Boolean hasPrevious     { get { return pageNumber > 0; } }
    public Boolean hasNext         { get { return pageNumber < list_Pages.size() - 1; } }
    public void first() { if ( isFirst ) pageNumber = 0; }
    public void last() { pageNumber = list_Pages.size() - 1; }
    public void previousPage()         { if ( hasPrevious  ) pageNumber--; }
    public void nextPage()             { if ( hasNext      ) pageNumber++; }
    public Integer toBeTotalRecs {get{return Database.countQuery('SELECT count() FROM causeview__Payment__c '+ criteria + tobeclaimed);} private set;}
    public double sumToBeClaimed {get{sumToBeClaimed = (double)Database.Query('SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c '+ criteria + tobeclaimed)[0].get('sum');return sumToBeClaimed=(sumToBeClaimed==null?0:sumToBeClaimed);} private set;}
    public List<selectoption> perPageNumbers { get; set; }
    public String perPageSelection { get; set; }
    public void assignPerPage() {
        pageSize = Integer.valueOf(perPageSelection);
        wrapPaymentList = null;
        list_Pages  = null;
        pageNumber = 0;
    }//END: assignPerPage
//END-BLOCK: TO BE CLAIMED
//START-BLOCK: CLAIMED NOT RECEIVED
    Set<ID> cnr_IDs;
    public class cnrWrapPayment {
        public causeview__Payment__c pay {get; set;}
        public Boolean selected {get; set;}
        public cnrWrapPayment( causeview__Payment__c p){
            pay = p;
            selected = false;
        }
    }//END: cnrWrapPayment
    public Integer cnrPageSize { get; set; }            //number of records per page
    public Integer cnrPageNumber { get; set; }          //current page number
    public Integer cnrNumberOfPages { get; set; }       //total number of pages
    public List<causeview__Payment__c> cnrList{get{return Database.Query(cnrQuery);}}
    public List<cnrWrapPayment> cnrWrapPaymentList    //Our collection of the class/wrapper objects wrapPayment
        {get{
            if ( cnrWrapPaymentList == null ){
                cnrWrapPaymentList = new List<cnrWrapPayment>();
                for (causeview__Payment__c p:cnrList)
                {   //  As each contact is processed we create a new cContact object
                    //  and add it to the contactList
                    cnrWrapPaymentList.add( new cnrWrapPayment( p ) );
                }
            }
        return cnrWrapPaymentList;
        }
        private set;
    }
    private List<List<cnrWrapPayment>> cnr_list_Pages
        {get{
            if ( cnr_list_Pages == null ){
                cnr_list_Pages = new List<List<cnrWrapPayment>>();
                Integer numInPage = cnrPageSize;
                List<cnrWrapPayment> thePage;
                if(cnrWrapPaymentList.size() > 0) {
                    for ( cnrWrapPayment pPay : cnrWrapPaymentList )
                    {
                        if ( numInPage >= cnrPageSize )
                        {
                            thePage = new List<cnrWrapPayment>();
                            cnr_list_Pages.add( thePage );
                            numInPage = 0;
                        }
                        thePage.add( pPay );
                        numInPage++;
                    }
                }
            }
        if(cnr_list_Pages.size() >0){cnrNumberOfPages = cnr_list_Pages.size() - 1;}
        return cnr_list_Pages;
        }
        private set;
    }
    public List<cnrWrapPayment> cnrCurrentPage  { get {
        If(cnr_list_Pages!=null && cnr_list_Pages.size() > 0){
            return cnr_list_Pages[ cnrPageNumber ];
        }else{
            return null;
        }
    }}
    public Boolean cnr_isFirst     { get { return cnrPageNumber != 0; } }
    public Boolean cnr_isLast      { get { return cnrPageNumber != cnr_list_Pages.size() - 1; } }
    public Boolean cnr_hasPrevious     { get { return cnrPageNumber > 0; } }
    public Boolean cnr_hasNext         { get { return cnrPageNumber < cnr_list_Pages.size() - 1; } }
    public void cnr_first() { if ( cnr_isFirst ) cnrPageNumber = 0; }
    public void cnr_last() { cnrPageNumber = cnr_list_Pages.size() - 1; }
    public void cnr_previousPage()         { if ( cnr_hasPrevious  ) cnrPageNumber--; }
    public void cnr_nextPage()             { if ( cnr_hasNext      ) cnrPageNumber++; }
    public Integer cnr_TotalRecs {get{return Database.countQuery('SELECT count() FROM causeview__Payment__c '+ criteria + claimedNotReceived);} private set;}
    public double cnr_Sum {get{cnr_Sum = (double)Database.Query('SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c '+ criteria + claimedNotReceived)[0].get('sum');return cnr_Sum=(cnr_Sum==null?0:cnr_Sum);} private set;}
    public List<selectoption> cnr_perPageNumbers { get; set; }
    public String cnr_perPageSelection { get; set; }
    public void cnr_assignPerPage() {
        cnrPageSize = Integer.valueOf(cnr_perPageSelection);
        cnrWrapPaymentList = null;
        cnr_list_Pages  = null;
        cnrPageNumber = 0;
        //checkAll();
    }
    public List<selectoption> claimedStatusTo { get; set; }         //Select Options
    public String changeClaimedTo { get; set; }                     //Selected Value of Select Options
//END-BLOCK: CLAIMED NOT RECEIVED
//START-BLOCK: RECEIVED
    public integer receivedOffsetSize {
      get {return receivedOffsetSize;}
      set {receivedOffsetSize = value;}}
    public integer receivedLimitSize {
      get {return receivedLimitSize;}
      set {receivedLimitSize = value;}}
    public list<causeview__Payment__c> getreceivedList{get;set;}
    public list<causeview__Payment__c> listOfreceived{get;set;}
    public Integer receivedTotalRecs {get{return Database.countQuery('SELECT count() FROM causeview__Payment__c '+ criteria + received);} private set;}
    public double sumReceived {get{sumReceived = (double)Database.Query('SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c '+ criteria + received)[0].get('sum');return sumReceived=(sumReceived==null?0:sumReceived);} private set;}
    public list<selectoption> receivedperPageNumbers { get; set; }
    public integer receivedperPageSelection { get; set; }
    public PageReference receivedassignPerPage() {
        receivedLimitSize = receivedperPageSelection;
        return null;}
    public list<causeview__Payment__c> getreceivedList() {
        list<causeview__Payment__c> receivedList = Database.Query(recQuery + ' LIMIT :receivedLimitSize OFFSET :receivedOffsetSize');
        return receivedList;}
    public void receivedFirstPage() {
        receivedOffsetSize = 0;}
    public void receivedprevious() {
        receivedOffsetSize = receivedOffsetSize - receivedLimitSize;}
    public void receivednext(){
        receivedOffsetSize = receivedOffsetSize + receivedLimitSize;}
    public void receivedLastPage() {
        receivedOffsetSize = receivedTotalRecs - math.mod(receivedTotalRecs,receivedLimitSize);}
    public boolean getreceivedprev() {
        if(receivedOffsetSize == 0)return true;
        else return false;}
    public boolean getreceivednxt() {
        if((receivedOffsetSize + receivedLimitSize) >= receivedTotalRecs) return true;
        else return false;}
//END-BLOCK: RECEIVED
//START-BLOCK: REJECTED
    public integer rejectedOffsetSize {
      get {return rejectedOffsetSize;}
      set {rejectedOffsetSize = value;}}
    public integer rejectedLimitSize {
      get {return rejectedLimitSize;}
      set {rejectedLimitSize = value;}}
    public list<causeview__Payment__c> getrejectedList{get;set;}
    public list<causeview__Payment__c> listOfrejected{get;set;}
    public Integer rejectedTotalRecs {get{return Database.countQuery('SELECT count() FROM causeview__Payment__c '+ criteria + rejected);} private set;}
    public double sumRejected {get{sumRejected = (double)Database.Query('SELECT SUM(Gift_Aid_Amount__c)sum FROM causeview__Payment__c '+ criteria + rejected)[0].get('sum');return sumRejected=(sumRejected==null?0:sumRejected);} private set;}
    public list<selectoption> rejectedperPageNumbers { get; set; }
    public integer rejectedperPageSelection { get; set; }
    public PageReference rejectedassignPerPage() {
        rejectedLimitSize = rejectedperPageSelection;
        return null;}
    //Pagination
    public list<causeview__Payment__c> getrejectedList() {
        list<causeview__Payment__c> rejectedList = Database.Query(rejQuery + ' LIMIT :receivedLimitSize OFFSET :receivedOffsetSize');
        return rejectedList;}
    public void rejectedFirstPage() {
        rejectedOffsetSize = 0;}
    public void rejectedprevious() {
        rejectedOffsetSize = rejectedOffsetSize - rejectedLimitSize;}
    public void rejectednext(){
        rejectedOffsetSize = rejectedOffsetSize + rejectedLimitSize;}
    public void rejectedLastPage() {
        rejectedOffsetSize = rejectedTotalRecs - math.mod(rejectedTotalRecs,rejectedLimitSize);}
    public boolean getrejectedprev() {
        if(rejectedOffsetSize == 0) return true;
        else return false;}
    public boolean getrejectednxt() {
        if((rejectedOffsetSize + rejectedLimitSize) >= rejectedTotalRecs) return true;
        else return false;}
//END-BLOCK: REJECTED
//=========================================Constructor=========================================/
    public Controller_GiftAid(){
        Filetype = '';                          //TODO: Implementation for EXPORT file name
        jobProcess = false;                     //TBC ActionPoller Status
        claimChangeJob = false;                 //CNR ActionPoller Status
        updateAll();                            //Re-initialize variables
        contentType = 'text/html';              //Set VisualForce page content type
    }//END: Controller_GiftAid
//=========================================Constructor=========================================/
    public void updateAll(){
        callTBC();
        callCNR();
        callREC();
        callREJ();
        if(successfulExport!=null){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,successfulExport));}
    }//END: updateAll

    public void callTBC(){
        wrapPaymentList = null;
        list_Pages  = null;
        pageSize = 10;
        pageNumber = 0;
        sumToBeClaimed = 0;
        toBeTotalRecs = 0;

        //if(toBeTotalRecs==0){
        //    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No records to be claimed.');
        //    ApexPages.addMessage(myMsg);
        //}

        //Select Options {10,25,50,Show All}
        //TODO: Build method to handle this assignment
        if(toBeTotalRecs<=10){perPageNumbers = new list<selectoption>();perPageNumbers.add(new selectoption(String.valueOf(toBeTotalRecs),'Showing All'));}else{perPageNumbers = new list<selectoption>();perPageNumbers.add(new selectoption('10','10'));perPageNumbers.add(new selectoption('25','25'));perPageNumbers.add(new selectoption('50','50'));perPageNumbers.add(new selectoption('100','100'));perPageNumbers.add(new selectoption('200','200'));perPageNumbers.add(new selectoption(String.valueOf(toBeTotalRecs),'Show All'));}
    }//END: callTBC

    public void callCNR(){
        cnrPageSize = 10;
        cnrPageNumber = 0;
        cnrWrapPaymentList = null;
        cnr_list_Pages  = null;
        cnr_Sum = 0;
        cnr_TotalRecs = 0;
        //Select Options {Received,Rejected}
        claimedStatusTo = new list<selectoption>();claimedStatusTo.add(new selectoption('Received','Received'));claimedStatusTo.add(new selectoption('Rejected','Rejected'));
        //Select Options {10,25,50,Show All}
        if(cnr_TotalRecs <= 10){cnr_perPageNumbers = new list<selectoption>();cnr_perPageNumbers.add(new selectoption(String.valueOf(cnr_TotalRecs),'Showing All'));}else{cnr_perPageNumbers = new list<selectoption>();cnr_perPageNumbers.add(new selectoption('10','10'));cnr_perPageNumbers.add(new selectoption('25','25'));cnr_perPageNumbers.add(new selectoption('50','50'));cnr_perPageNumbers.add(new selectoption('100','100'));cnr_perPageNumbers.add(new selectoption('200','200'));cnr_perPageNumbers.add(new selectoption(String.valueOf(cnr_TotalRecs),'Show All'));}
    }//END: callCNR

    public void callREC(){
        sumReceived = 0;
        receivedTotalRecs = 0;
        receivedOffsetSize = 0;
        receivedLimitSize= 10;
        //TODO: set in property
        list<causeview__Payment__c> receivedList = Database.Query('SELECT Id, Name, Gift_Aid_Declaration__c, causeview__Constituent__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c, Gift_Aid_Received_Date__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Received\' AND Gift_Aid_Amount__c > 0 ORDER BY causeview__Date__c DESC LIMIT :receivedLimitSize OFFSET :receivedOffsetSize');
        if(receivedTotalRecs <= 10){receivedperPageNumbers = new list<selectoption>();receivedperPageNumbers.add(new selectoption(String.valueOf(receivedTotalRecs),'Showing All'));}else{receivedperPageNumbers = new list<selectoption>();receivedperPageNumbers.add(new selectoption('10','10'));receivedperPageNumbers.add(new selectoption('25','25'));receivedperPageNumbers.add(new selectoption('50','50'));receivedperPageNumbers.add(new selectoption('100','100'));receivedperPageNumbers.add(new selectoption('200','200'));receivedperPageNumbers.add(new selectoption(String.valueOf(receivedTotalRecs),'Show All'));}
    }//END: callREC

    public void callREJ(){
        sumRejected = 0;
        rejectedTotalRecs = 0;
        rejectedOffsetSize = 0;
        rejectedLimitSize= 10;
        //TODO: set in property
        list<causeview__Payment__c> rejectedList = Database.Query('SELECT Id, Name, Gift_Aid_Declaration__c, causeview__Constituent__c, causeview__Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = \'Rejected\' AND Gift_Aid_Amount__c > 0 ORDER BY causeview__Date__c DESC LIMIT :rejectedLimitSize OFFSET :rejectedOffsetSize');
        if(rejectedTotalRecs <= 10){rejectedperPageNumbers = new list<selectoption>();rejectedperPageNumbers.add(new selectoption(String.valueOf(rejectedTotalRecs),'Showing All'));}else{rejectedperPageNumbers = new list<selectoption>();rejectedperPageNumbers.add(new selectoption('10','10'));rejectedperPageNumbers.add(new selectoption('25','25'));rejectedperPageNumbers.add(new selectoption('50','50'));rejectedperPageNumbers.add(new selectoption('100','100'));rejectedperPageNumbers.add(new selectoption('200','200'));rejectedperPageNumbers.add(new selectoption(String.valueOf(rejectedTotalRecs),'Show All'));}
    }//END: callREJ

    public PageReference pausingExecution(){
            PageReference pgref;
            system.debug('====job[0].Status=');
            list<AsyncApexJob> job =[SELECT id, Status FROM AsyncApexJob WHERE CreatedDate = today AND MethodName = 'updateGiftAidPayments' AND CreatedById =: UserInfo.getUserId()  ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
            if(job.size()>0){
                system.debug(job[0].id+'====job[0].Status='+job[0].Status);
                if(job[0].Status == 'Queued' || job[0].Status=='Preparing' || job[0].Status=='Processing'){
                    return null ;
                }
                if(job[0].Status == 'Completed' ){
                    jobProcess= false;
                    updateAll();
                }
                if(job[0].Status == 'Aborted' || job[0].Status == 'Failed' || job[0].Status == 'Holding' ){
                    jobProcess= false;
                    job[0].addError('Error occurred during updating Allocations');
                    return null;
                }
            }
            return null;
    }

    public PageReference pausingExecutionForClaimed(){
            PageReference pgref;
            system.debug('====job[0].Status=');
            list<AsyncApexJob> job =[SELECT id, Status FROM AsyncApexJob WHERE CreatedDate = today AND MethodName = 'updateClaimedPayments' AND CreatedById =: UserInfo.getUserId()  ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
            if(job.size()>0){
                system.debug(job[0].id+'====job[0].Status='+job[0].Status);
                if(job[0].Status == 'Queued' || job[0].Status=='Preparing' || job[0].Status=='Processing'){
                    return null ;
                }
                if(job[0].Status == 'Completed' ){
                    claimChangeJob= false;
                    updateAll();
                }
                if(job[0].Status == 'Aborted' || job[0].Status == 'Failed' || job[0].Status == 'Holding' ){
                    claimChangeJob= false;
                    job[0].addError('Error occurred during updating Allocations');
                    return null;
                }
            }
            return null;
    }

    public PageReference processSelected(){
        PageReference ref = null;
        //List<causeview__Payment__c> selectedPayments = new List<causeview__Payment__c>();
        lstwrapper = new List<wrapper>();
        tbc_IDs = new set<id>();

        if (validate_list_data() == true) {
            jobProcess= true;
            //DEBUG
            //System.debug('selectAll: '+selectAll);
            //System.debug('wrapPaymentList.size(): '+wrapPaymentList.size());
            //System.debug('wrapPaymentList: '+wrapPaymentList);
            for ( wrapPayment pPay : wrapPaymentList ){
                System.debug('selected: '+pPay.selected);
                if ( pPay.selected ) {
                    wrapper w = new wrapper();
                                                           
                    //Parse Date DD/MM/YY
                    //Date tempDate = pPay.pay.causeview__Date__c;
                    //w.formattedDate =  String.valueOf(tempDate.year())+ '/' + String.valueOf(tempDate.month()) + '/' + String.valueOf(tempDate.year());
                    String tempTitle;
                    if(tempTitle!=null){
                        tempTitle = pPay.pay.Gift_Aid_Declaration__r.Donor__r.Title;
                    }
                    else{
                        tempTitle = 'notitle';
                        System.debug('tempTitle: '+tempTitle);
                    }                                        
                    String commitTitle;
                    if(tempTitle=='notitle')
                    {
                         w.title = '';
                    }                       
                    else
                    {
                        tempTitle = tempTitle.replace('.', '');
                        //if more than 4 character then shorten
                        if(tempTitle.length() > 4){commitTitle = tempTitle.left(4);}else{commitTitle = tempTitle;}
                        w.title = commitTitle;
                    }
                                                         
                                        
                    if(pPay.pay.First_Name__c!=null)
                    {
                        //maximum 35 characters
                        w.firstName = pPay.pay.First_Name__c;
                    }
                    else
                    {
                        w.firstName = 'No First Name';
                    }

                    if(pPay.pay.Last_Name__c!=null)
                    {
                        //maximum 35 characters
                        w.lastName = pPay.pay.Last_Name__c;
                    }
                    else
                    {
                        w.firstName = 'No Last Name';
                    }
                                        
                    if(pPay.pay.House_Number__c!=null)
                    {
                        String tempString = pPay.pay.House_Number__c;
                        //FIX: New line in Long Text Area
                        tempString = tempString.replace('\r\n', ' ');
                        tempString = tempString.replace('\n', ' ');
                        tempString = tempString.replace('\r', ' ');
                        tempString = tempString.replace(',', ' ');
                        w.house = tempString;
                    }
                    else
                    {
                        w.house = 'No House Number';
                    } 

                    if(pPay.pay.Postal_Code__c!=null)
                    {
                        //using capital letters and include a space, for example, S19 2BD
                        w.postal = pPay.pay.Postal_Code__c;
                    }
                    else
                    {
                        w.postal = 'No Postal Code';
                    } 
                    
                    w.giftDate = pPay.pay.causeview__Date__c;
                    w.giftAmount = pPay.pay.Gift_Aid_Amount__c;
                    
                    System.debug(w);
                    //Add to List wrapper for export
                    lstwrapper.add(w);

                    //selectedPayments.add(pPay.pay);
                    tbc_IDs.add(pPay.pay.ID);
                }
            }
            //DEBUG
            //System.debug('lstwrapper.size(): '+lstwrapper.size());
            //System.debug('tbc_IDs.size(): '+tbc_IDs.size());
            updateGiftAidPayments(tbc_IDs);
            //ref = new PageReference('/apex/exportGiftAid');
            //ref.setRedirect(false);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Success: Document Porcessed.');
            //ApexPages.addMessage(myMsg);
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'You haven\'t selected any records to process.'));
        }
        //When using export html gift aid schedule
        //ref.getHeaders().put('content-disposition', 'attachment; filename=GiftAid.xls');
        return ref;
    }//END: processSelected

    public PageReference processClaimed(){
        System.debug('processClaimed');
        PageReference ref = null;
        Set<id> claimedIDs = new set<id>();
        //PageReference ref = new PageReference('/apex/Gift_Aid');
        //ref.setRedirect(true);
        //TODO: Validation
        for ( cnrWrapPayment pPay : cnrWrapPaymentList ){
            if ( pPay.selected ) {
                claimedIDs.add(pPay.pay.ID);
                System.debug('claimed Payment: '+ pPay.pay.ID);
            }
        }

        if (claimedIDs.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'You haven\'t selected any records to process.'));
        }else {
            System.debug('processClaimed: Not Empty');
            claimChangeJob= true;
            System.debug('claimChangeJob: '+ claimChangeJob);
            updateClaimedPayments(claimedIDs,changeClaimedTo);
        }

        return ref;
    }//END: processClaimed

    //TODO: change name updateToBeClaimedPayments
    @future
    public static void updateGiftAidPayments(Set<ID> tbc_IDs){
        System.debug('tbc_IDs.size(): '+ tbc_IDs.size());
        List<causeview__Payment__c> payments = new List<causeview__Payment__c>();
        payments= [select id, Gift_Aid_Claim_Status__c, Gift_Aid_Claim_Date__c from causeview__Payment__c where id in :tbc_IDs ];

        for(Payment__c p: payments){
            p.Gift_Aid_Claim_Status__c = 'Claimed Not Received';
            p.Gift_Aid_Claim_Date__c = Date.today();
        }
        update payments;
    }//END: updateGiftAidPayments

    @future
    public static void updateClaimedPayments(Set<ID> cnr_IDs, String status){
        List<Payment__c> payments = [select ID, Gift_Aid_Claim_Status__c, Gift_Aid_Received_Date__c FROM causeview__Payment__c WHERE ID in :cnr_IDs ];
        for(Payment__c p: payments){
            p.Gift_Aid_Claim_Status__c = status;
            p.Gift_Aid_Received_Date__c = Date.today();
        }
        update payments;
    }//END: updateClaimedPayments

    public pagereference exportPage(){
        system.debug('CPU Time==='+jobProcess);
        if(!lstwrapper.isEmpty()){
            return Page.exportGiftAid;
            successfulExport = 'Success: Gift-Aid Payments Porcessed. Downloading Gift-Aid Schedule. ';
            for(wrapPayment p: wrapPaymentList){
                p.selected = false;
            }
        }
        lstwrapper = new List<wrapper>();
        selectAll = false;
        return null;
    }//END: exportPage

    //TODO: Accept (wrapPaymentList, wrapPayment)
    public boolean validate_list_data() {
        boolean DataIsValid = true;
        List<causeview__Payment__c> selectedPayments = new List<causeview__Payment__c>();
        for ( wrapPayment pPay : wrapPaymentList ){
            if ( pPay.selected ) {
                selectedPayments.add(pPay.pay);
            }
        }
        if (selectedPayments.isEmpty()) {
            DataIsValid = false;
        }
        return DataIsValid;
    }//END: validate_list_data

    //TODO: Deprecate
    public PageReference redirectApex() {
        PageReference ref = new PageReference('/apex/Gift_Aid');
        ref.setRedirect(true);
        return ref;
    }

    //TODO: Deprecate
    public void checkAll() {
        for(wrapPayment p: wrapPaymentList){
            if(selectAll){
                p.selected = true;
            }else{
                p.selected = false;
            }
            System.Debug(p.selected);
        }
    }
}//END: