public with sharing class BatchPresetController_New1 {
    
    public String selectedTab{get;set;}
    public Boolean isSelectPreset{get;set;}
    public Boolean isShowPreset{get;set;}
    public Boolean isEventPreset{get;set;}
    
    public List<PresetWrapper> contactFields{get;set;}
    public List<PresetWrapper> accountFields{get;set;}
    public List<PresetWrapper> RecurringGiftFields{get;set;}
    public List<PresetWrapper> TransactionFields{get;set;}
    public List<PresetWrapper> PaymentFields{get;set;}
    public List<PresetWrapper> ReceiptFields{get;set;}
    public List<PresetWrapper> GiftDetailFields{get;set;}
    public List<PresetWrapper> eventRegFields{get;set;}
    public Batch_Template__c template{get;set;}
    
    
    public BatchPresetController_New1() {
        isSelectPreset = true;
        isShowPreset = false;
        
        contactFields = new List<PresetWrapper>();
        accountFields = new List<PresetWrapper>();
        RecurringGiftFields = new List<PresetWrapper>();
        TransactionFields = new List<PresetWrapper>();
        PaymentFields = new List<PresetWrapper>();
        ReceiptFields = new List<PresetWrapper>();
        GiftDetailFields = new List<PresetWrapper>();
        eventRegFields = new List<PresetWrapper>();
        
        
        leftselected = new List<String>();
        template = new Batch_Template__c();
        contactFieldsMap = new Map<String, PresetWrapper>();
    }
    
    public List<PresetWrapper> getContFields() {
        BatchPresetController objBPC = new BatchPresetController();
        
        return objBPC.discribeObjects('Contact');
    }
    
    Public List<String> leftselected{get;set;}
    public Map<String, PresetWrapper> contactFieldsMap{get;set;}
    Set<string> leftvalues = new Set<string>();
    
    
    public void selectclick(){
        for(String pwSelected : leftselected){
            leftvalues.remove(pwSelected);
            contactFields.add(contactFieldsMap.get(pwSelected));
        }
        
    }
    
    public String getMapVal() {
        Map<String, PresetWrapper> FieldsMap = new Map<String, PresetWrapper>();
        BatchPresetController objBPC = new BatchPresetController();
        for(PresetWrapper pw : objBPC.discribeObjects('Contact')) {
            FieldsMap.put(pw.fieldName, pw);
        }
        
        String JSONString = JSON.serialize(FieldsMap);
        System.debug(JSONString);
        return JSONString;
    }
    
    public PageReference unselectclick(){        
        
        System.debug('print List Index ===> '+ApexPages.currentPage().getParameters().get('index'));
        Integer listIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
        PresetWrapper pw = contactFields[listIndex];
        leftvalues.add(pw.fieldName);
        contactFields.remove(listIndex);
        
        return null;
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        
        BatchPresetController objBPC = new BatchPresetController();
        for(PresetWrapper pw : objBPC.discribeObjects('Contact')) {
            contactFieldsMap.put(pw.fieldName, pw);
        }
        
        if(options.size() == 0 && leftselected.size() == 0 && leftvalues.size() == 0) {
            leftvalues.addAll(contactFieldsMap.keySet());
            tempList.addAll(leftvalues);
            tempList.sort();
            for(String fieldName : tempList)
                options.add(new SelectOption(fieldName, contactFieldsMap.get(fieldName).fieldLable));
        }
        else {
            tempList.addAll(leftvalues);
            tempList.sort();
            for(String fieldName : tempList)
                options.add(new SelectOption(fieldName, contactFieldsMap.get(fieldName).fieldLable));
        }
        return options;
    }
}