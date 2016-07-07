/*This apex class used as controller to export GL report(allocations)
in "PostToFinance" visualforce to display records, 
and "AllocationCSVPage" and "AllocationExcelPage" visulaforce page to export reports.*/

public class PostToFinanceController{ 
    public string fromDate {get;set;}
    public string toDate {get;set;}
    public Boolean isTrue {get;set;}
    public List<csvExportWrapper> allocations {get;set;}
    transient public List<cv_pkg_dev_I__Gift_Detail__c> allocationRecords {get;set;}
    public List<csvExportWrapper> csvRecords {get;set;}
    public string fileFormat {get;set;}
    private integer totalRecs = 0;
    private integer OffsetSize = 0;
    private integer LimitSize = 1500;
    public integer pageNumber {get; set;}
    public integer totalPages {get; set;}
    public List<List<csvExportWrapper>> listCSVRecords {get; set;}
    public List<List<csvExportWrapper>> listExportRecords {get; set;}
    public string reportDateTime {get;set;}
    public boolean jobProcess {get;set;}
    set<id> allocIds;
    public integer pollarInterval {
    		get{
    			if(allocIds.size()>600){
    				return 8;	
    			}else{
    				return 5;
    			}	
    		}
    	}
    
    public PostToFinanceController(){
            jobProcess = false;
        allocationRecords = new List<cv_pkg_dev_I__Gift_Detail__c>();
        allocations = new List<csvExportWrapper>();
        listCSVRecords = new List<List<csvExportWrapper>>();
        isTrue = true;
        fileFormat = 'CSV';
            
        callSearchAllocationMethod();
    }
     
    
    /*If a user do a new search for records between from and to date then this method will get call.
    This method will call another method searchAllocation() to search records*/
    public void callSearchAllocationMethod(){
        pageNumber = 1;
        OffsetSize = 0;
        searchAllocation();
    }
    /*This method search allocation records between from and to date*/
    public void searchAllocation(){
        allocationRecords = new List<cv_pkg_dev_I__Gift_Detail__c>();
        allocations = new List<csvExportWrapper>();
        listCSVRecords = new List<List<csvExportWrapper>>();
        Date fromDt;Date toDt;
        if((fromDate == null && toDate == null) || fromDate == '' && toDate == '')
       { 
            Date daysBack= date.today();
            fromDate = String.valueOf(daysBack.addDays(-7));
            toDate = String.valueOf(daysBack);
                        
          allocationRecords = [select Name, cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Allocation_Date__c, cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__Fund__r.cv_pkg_dev_I__Fund_Code__c, cv_pkg_dev_I__Gift__r.cv_pkg_dev_I__Gift_Date__c, cv_pkg_dev_I__Payment__r.cv_pkg_dev_I__Status__c,
                                    cv_pkg_dev_I__Fund__r.cv_pkg_dev_I__Fund_Name__c, cv_pkg_dev_I__Accounting_Code__c, cv_pkg_dev_I__GL_Auto_Credit_Account__c, cv_pkg_dev_I__GL_Auto_Debit_Account__c from cv_pkg_dev_I__Gift_Detail__c 
                                    where  cv_pkg_dev_I__Posted_to_Finance__c =: null AND cv_pkg_dev_I__Allocation_Date__c >=:daysBack.addDays(-7) and cv_pkg_dev_I__Allocation_Date__c <=:daysBack Order By cv_pkg_dev_I__Allocation_Date__c ASC NULLS LAST];
                                    
            system.debug('hi'+ allocationRecords );
       }
       else
        {         
            fromDt = Date.valueOf(fromDate);
            toDt = Date.valueOf(toDate);
       
       
            allocationRecords = [select Name, cv_pkg_dev_I__Constituent__c, cv_pkg_dev_I__Allocation_Date__c, cv_pkg_dev_I__Amount__c, cv_pkg_dev_I__Fund__r.cv_pkg_dev_I__Fund_Code__c, cv_pkg_dev_I__Gift__r.cv_pkg_dev_I__Gift_Date__c,cv_pkg_dev_I__Payment__r.cv_pkg_dev_I__Status__c,
                                     cv_pkg_dev_I__Accounting_Code__c, cv_pkg_dev_I__Fund__r.cv_pkg_dev_I__Fund_Name__c, cv_pkg_dev_I__GL_Auto_Credit_Account__c, cv_pkg_dev_I__GL_Auto_Debit_Account__c from cv_pkg_dev_I__Gift_Detail__c 
                                    where cv_pkg_dev_I__Allocation_Date__c >=: fromDt AND cv_pkg_dev_I__Allocation_Date__c <=: toDt AND cv_pkg_dev_I__Posted_to_Finance__c =: null  Order By cv_pkg_dev_I__Allocation_Date__c ASC  NULLS LAST];
            //totalRecs = [select count() from cv_pkg_dev_I__Gift_Detail__c where cv_pkg_dev_I__Allocation_Date__c >=: fromDt AND cv_pkg_dev_I__Allocation_Date__c <=: toDt AND cv_pkg_dev_I__Posted_to_Finance__c =: null Limit 25000];
         }
         //  
            if(allocationRecords.size()>0){
                isTrue = true;    //isTrue is used to show records or message in visualforce page, if true then show table records
                totalRecs = allocationRecords.size();    
            }else
            {
                isTrue = false;    //isTrue is used to show records or message in visualforce page, if false then show message "No Record Found!"
                totalRecs = 0;
            }
            if(totalRecs != 0){
                totalPages = (Math.mod(totalRecs, LimitSize) == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize) + 1);    //To display number of pages of records in visualforce page, if more than 1500 records then display number of pages according to records
            }else
            {
                totalPages = 1;
            }
            if(totalRecs >= OffsetSize+LimitSize){    //checking if total number of records greater than offset + Limit size value  
                for(Integer i = OffsetSize; i<OffsetSize+LimitSize; i++){    //In VF page, we can display only 1000 records in one table so created a list of list and putting records in that list to display more than 1000 records.
                    allocations.add(new csvExportWrapper(allocationRecords[i]));
                    if(allocations.size() == 1000){
                        listCSVRecords.add(allocations);
                        allocations = new List<csvExportWrapper>();
                    }
                }
                if(!allocations.isEmpty()){
                    listCSVRecords.add(allocations);
                    allocations = new List<csvExportWrapper>();
                }
            }else
            {
                for(Integer i = OffsetSize; i<totalRecs; i++){
                    allocations.add(new csvExportWrapper(allocationRecords[i]));
                    if(allocations.size() == 1000){
                        listCSVRecords.add(allocations);
                        allocations = new List<csvExportWrapper>();
                    }
                }
                if(!allocations.isEmpty()){                     
                    listCSVRecords.add(allocations);
                    allocations = new List<csvExportWrapper>();
                }
            }
            allocationRecords.clear();
            System.debug('Limit =='+Limits.getcputime());
        }
    
    /* This method updates the records those will be exported
    and put records into list of list from which those will be exported.*/
    public pagereference exportAllocationRecords(){
        allocIds = new set<id>();
        reportDateTime = 'GLReport'+ currentDateTime();
        allocationRecords = new List<cv_pkg_dev_I__Gift_Detail__c>();
        csvRecords = new List<csvExportWrapper>();
        listExportRecords = new List<List<csvExportWrapper>>();
        for(List<csvExportWrapper> alloc : listCSVRecords){
            system.debug('------testing loop-');
            for(csvExportWrapper a : alloc){
                if(a.selected){
                    //a.allocation.cv_pkg_dev_I__Posted_to_Finance__c = system.Today();
                    allocIds.add(a.allocation.id);
                    csvRecords.add(new csvExportWrapper(a.allocation));
                    if(csvRecords.size() == 1000){
                        listExportRecords.add(csvRecords);
                        csvRecords = new List<csvExportWrapper>();
                    }
                }
            }
        }
        if(!csvRecords.isEmpty()){
            listExportRecords.add(csvRecords);
            csvRecords = new List<csvExportWrapper>();
        }
        system.debug('Selected Allocations=='+allocationRecords.size());
        if(allocIds.size() > 0){   
                jobProcess= true;        
            Util.allocationUpdate(allocIds);    //updating allocation records(user story #102396768)
        }
        allocationRecords.clear();        
        //callSearchAllocationMethod();    //calling this method to display records after updation of allocation record
        system.debug('CPU TIME After update'+limits.getcputime());
        return null;
    }
    
   
    //this method call the page to export records in which file type user choose         
    public pagereference exportPage(){
        system.debug(fileFormat+'CPU Time==='+jobProcess);
        if(fileFormat == 'CSV'){
            system.debug('CPU Time===');
            return Page.AllocationCSVPage;
        }else
        if(fileFormat == 'Excel'){
            return Page.AllocationExcelPage;
        }
        return null;
    }
    //To display file formats on VF page
    public list<SelectOption> getFileFormatList()
    {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('CSV', 'CSV'));
        options.add(new SelectOption('Excel', 'Excel'));
        return options;
    }
    //this method is used to come back on first page of records
    public void FirstPage()
    {
        OffsetSize = 0;
        pageNumber = 1;
        searchAllocation();
    }
    //this method is used come back on previous page
    public void previous()
    {
        OffsetSize = OffsetSize - LimitSize;
        pageNumber--;
        searchAllocation();
    }
    //this method is used to go on next page
    public void next()
    {
        OffsetSize = OffsetSize + LimitSize;
        pageNumber++;
        searchAllocation();
    }
    //this method is used to go on last page
    public void LastPage()
    {
        OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
        pageNumber = (Math.mod(totalRecs, LimitSize) == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize) + 1);
        searchAllocation();
    }
    //to make previous and first page button active or inactive
    public boolean getprev()
    {
        if(OffsetSize == 0)
        return true;
        else
        return false;
    }
    //to make next and last page button active or inactive
    public boolean getnxt()
    {
        if((OffsetSize + LimitSize) > totalRecs)
        return true;
        else
        return false;
    }
    public string currentDateTime(){
        Integer YearInt = Date.Today().year();
        Integer monthInt = Date.Today().month();
        Integer dayInt = Date.Today().Day();
        Integer hourInt = Datetime.Now().Hour();
        Integer minInt = Datetime.Now().minute();
        Integer secInt = Datetime.Now().second();
        String concatenatedDateTime = String.valueof(YearInt)+String.valueof(monthInt)+String.valueof(dayInt)+String.valueof(hourInt)+String.valueof(minInt)+String.valueof(secInt);
        return concatenatedDateTime;
    }
    
    //user story #102396768
    public PageReference pausingExecution()
    {
            PageReference pgref;
            system.debug('====job[0].Status=');            
            list<AsyncApexJob> job =[SELECT id, Status FROM AsyncApexJob WHERE CreatedDate = today AND MethodName = 'allocationUpdate' AND CreatedById =: UserInfo.getUserId()  ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
            if(job.size()>0){
                system.debug(job[0].id+'====job[0].Status='+job[0].Status);
                if(job[0].Status == 'Queued' || job[0].Status=='Preparing' || job[0].Status=='Processing'){
                    return null ;
                }
                if(job[0].Status == 'Completed' ){
                    jobProcess= false;
                    callSearchAllocationMethod();                    
                    //pgref = exportPage();
                }
                if(job[0].Status == 'Aborted' || job[0].Status == 'Failed' || job[0].Status == 'Holding' ){
                    //difene error
                    jobProcess= false;
                    job[0].addError('Error occurred during updating Allocations');
                    return null;
                }
            }
            return null;
    }
    
    //wrapper class          
    public class csvExportWrapper{
        public cv_pkg_dev_I__Gift_Detail__c allocation{get;set;}
        public string debit{get;set;}
        public string credit{get;set;}
        Public string allocationDate {get;set;}
        Public string allocationDate1 {get;set;}
        Public string reference{get;set;}
        public boolean selected{get;set;}
        Public string transactionDate {get;set;}
        public csvExportWrapper(cv_pkg_dev_I__Gift_Detail__c a){
            allocation = a;
            allocationDate1=string.valueOf(a.cv_pkg_dev_I__Allocation_Date__c);
            selected = false;
            transactionDate = string.valueOf(a.cv_pkg_dev_I__Gift__r.cv_pkg_dev_I__Gift_Date__c);
            if(a.cv_pkg_dev_I__Payment__r.cv_pkg_dev_I__Status__c == 'Committed'){
                allocationDate = string.valueOf(a.cv_pkg_dev_I__Gift__r.cv_pkg_dev_I__Gift_Date__c);
            }else
            {
                allocationDate = string.valueOf(a.cv_pkg_dev_I__Allocation_Date__c);
            }
            reference = parseReference(a);
            debit = 'D';
            Credit = 'C';
        }
        
        public String parseReference(cv_pkg_dev_I__Gift_Detail__c allocation){
            Pattern myPattern = Pattern.compile('>(.*?)</a>');
            Matcher MyMatcher = MyPattern.matcher(allocation.Constituent__c);
            MyMatcher.find();
            string constituent = MyMatcher.group(1);
            return constituent;
        }

    }
}
