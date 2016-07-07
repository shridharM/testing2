public with sharing class CustomEventLookupController {
    
    public list<campaign> events {get;set;}
    public list<cv_pkg_dev_I__Promotion_Code__c> PromotionCodes {get;set;}
    public string searchString{get;set;}
    public string objName{get;set;}
    
    public CustomEventLookupController() {
        events = new list<campaign>();
        PromotionCodes = new list<cv_pkg_dev_I__Promotion_Code__c>();
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        runSearch();  
    }
    
    public CustomEventLookupController(String strSearchString) {
        events = new list<campaign>();
         PromotionCodes = new list<cv_pkg_dev_I__Promotion_Code__c>();
        // get the current search string
        searchString = strSearchString;
        runSearch();  
    }
    
    // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        performSearch(searchString);               
    } 
    
    
    private void performSearch(string searchString) {
        
        String soql = '';
        objName = System.currentPageReference().getParameters().get('objName');
        string eventId = System.currentPageReference().getParameters().get('eventName');
        list<string> eventIdList = new list<string>();
		eventIdList.add(eventId);        
        system.debug('---objName--'+objName);
        if(searchString != '' && searchString != null){
            if(searchString.contains('\\')){
                searchString=searchString.replaceAll('\\\\', '\\\\\\\\');              
            }          
            if(searchString.contains('\'')){
                searchString=searchString.replaceAll('\'', '\\\\\'');              
            }  
        }
        if(objName=='Event'){
            soql = 'select id, name, RecordType.Name FROM campaign WHERE RecordType.Name IN (\'event\')';
            if(searchString != '' && searchString != null){
                soql = soql +  ' and Name LIKE \'%' + searchString +'%\'';            
            }
            
            
            list<campaign> campaignsTemp = database.query(soql);
            
            for(campaign campaignTemp : campaignsTemp){
                if(campaignTemp.Name.contains('\'')){
                    // if campaign.Name contains single quote or back slash then it will creates error in visual force page(customEventLookup). So to escape the meaning of single quote
                    // or back slash we are appending back slash.    
                    
                    campaignTemp.Name = campaignTemp.Name.replaceAll('\\\\', '\\\\\\\\'); 
                    campaignTemp.Name = campaignTemp.Name.replaceAll('\'', '\\\\\'');   
                }
            }
            
            events= campaignsTemp;
        }
        if(objName=='Promotion Code'){
            soql = 'select id, Name, cv_pkg_dev_I__Event__r.Name, cv_pkg_dev_I__Description__c  FROM cv_pkg_dev_I__Promotion_Code__c where cv_pkg_dev_I__Event__c IN :eventIdList';//:'+eventIdList;
            if(searchString != '' && searchString != null){
                soql = soql +  ' and Name LIKE \'%' + searchString +'%\'';            
            }
            
            
            list<cv_pkg_dev_I__Promotion_Code__c> promotionCodesTemp = database.query(soql);
            system.debug('---promotionCodesTemp---'+promotionCodesTemp.size());
            PromotionCodes= promotionCodesTemp;
            for(cv_pkg_dev_I__Promotion_Code__c promotionCodeTemp : promotionCodesTemp){
                if(promotionCodeTemp.Name.contains('\'')){
                    // if campaign.Name contains single quote or back slash then it will creates error in visual force page(customEventLookup). So to escape the meaning of single quote
                    // or back slash we are appending back slash. As cv_pkg_dev_I__Promotion_Code__c.Name is only readable we are using promotionCodeTemp.cv_pkg_dev_I__Description__c field to just pass the value to page.
                	// and its value will not be affected in database as we are not updating it.   
                    promotionCodeTemp.cv_pkg_dev_I__Description__c   = promotionCodeTemp.Name.replaceAll('\\\\', '\\\\\\\\'); 
                    promotionCodeTemp.cv_pkg_dev_I__Description__c   = promotionCodeTemp.cv_pkg_dev_I__Description__c .replaceAll('\\\\', '\\\\\\\\'); 
                    promotionCodeTemp.cv_pkg_dev_I__Description__c   = promotionCodeTemp.cv_pkg_dev_I__Description__c .replaceAll('\'', '\\\\\'');   
                }
            }
            
            PromotionCodes= promotionCodesTemp;
            system.debug('----PromotionCodes-'+PromotionCodes.size());
        }
        
    }
    
    
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    
}