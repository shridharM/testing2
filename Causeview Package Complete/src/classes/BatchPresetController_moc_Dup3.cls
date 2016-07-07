public class BatchPresetController_moc_Dup3 {
	public String successMessage{get;set;}
    
    //sorting Related start
    public String startValue{get;set;}
    public String stopValue{get;set;}
    public String classValue{get;set;}
    //end
    
    public Boolean isPresetSaved{get;set;}
    public Boolean isCloned{get;set;}

    public Boolean isSelectPreset{get;set;}
    public Boolean isShowPreset{get;set;}
    public Boolean isNewPreset{get;set;}
    
    public List<String> conSelected{get;set;}
    public List<String> accSelected{get;set;}
    public List<String> rgfSelected{get;set;}
    public List<String> trnxSelected{get;set;}
    public List<String> pymtSelected{get;set;}
    public List<String> rcptSelected{get;set;}
    public List<String> giftDetailSelected{get;set;}
    public List<String> eventRegSelected{get;set;}
    
    public Batch_Template__c temp{get;set;}

    public Batch_Template__c template{get;set;}
    public List<PresetWrapper> contactFields{get;set;}
    public List<PresetWrapper> accountFields{get;set;}
    public List<PresetWrapper> RecurringGiftFields{get;set;}
    public List<PresetWrapper> TransactionFields{get;set;}
    public List<PresetWrapper> PaymentFields{get;set;}
    public List<PresetWrapper> ReceiptFields{get;set;}
    public List<PresetWrapper> GiftDetailFields{get;set;}
    public List<PresetWrapper> eventRegFields{get;set;}
    
    Set<string> conPickValues = new Set<string>();
    Set<string> accPickValues = new Set<string>();
    Set<string> rgfPickValues = new Set<string>();
    Set<string> trnxPickValues = new Set<string>();
    Set<string> pymtPickValues = new Set<string>();
    Set<string> rcptPickValues = new Set<string>();
    Set<string> giftDetailPickValues = new Set<string>();
    Set<string> eventRegPickValues = new Set<string>();
    
    Map<String, PresetWrapper> contactFieldsMap = new Map<String, PresetWrapper>();
    Map<String, PresetWrapper> accountFieldsMap = new Map<String, PresetWrapper>();
    Map<String, PresetWrapper> recGiftFieldsMap = new Map<String, PresetWrapper>();
    Map<String, PresetWrapper> tranxFieldsMap = new Map<String, PresetWrapper>();
    Map<String, PresetWrapper> paymentFieldsMap = new Map<String, PresetWrapper>();
    Map<String, PresetWrapper> receiptFieldsMap = new Map<String, PresetWrapper>();
    Map<String, PresetWrapper> giftDetailFieldsMap = new Map<String, PresetWrapper>();
    Map<String, PresetWrapper> eventRegFieldsMap = new Map<String, PresetWrapper>();

    private RecordType RT;    
    private BatchPresetHelper_moc objBPH;
    private String templateId;
    
	public boolean isEditMode {get;set;}
    public BatchPresetController_moc_Dup3(ApexPages.StandardController controller) {
        isPresetSaved = false;
        isCloned = false;

        isSelectPreset = false;
        isShowPreset = true;
        
        conSelected = new List<String>();
        accSelected = new List<String>();
        rgfSelected = new List<String>();
        trnxSelected = new List<String>();
        pymtSelected = new List<String>();
        rcptSelected = new List<String>();
        giftDetailSelected = new List<String>();
        eventRegSelected = new List<String>();
        
        contactFields = new List<PresetWrapper>();
        accountFields = new List<PresetWrapper>();
        RecurringGiftFields = new List<PresetWrapper>();
        TransactionFields = new List<PresetWrapper>();
        PaymentFields = new List<PresetWrapper>();
        ReceiptFields = new List<PresetWrapper>();
        GiftDetailFields = new List<PresetWrapper>();
        eventRegFields = new List<PresetWrapper>();
        
        temp = new Batch_Template__c();
        temp.Type__c = 'Global';

        template = new Batch_Template__c();
        template.Type__c = 'Global';
        objBPH = new BatchPresetHelper_moc();

        RT = [SELECT Id FROM RecordType WHERE SobjectType = 'causeview__Batch_Template__c' AND Name = 'Parent' AND NamespacePrefix = 'causeview'];

        templateId = ApexPages.currentPage().getParameters().get('id');
        successMessage = ApexPages.currentPage().getParameters().get('msg');
        system.debug('templateId==>'+templateId);
        
        if(templateId != '' && templateId != null) {
            editPresetTemplate();
            createPaymentFieldIdMap();
            isEditMode = true;
        } else {
        	isEditMode = false;
            newPresetTemplate();
        }

/*        String isNew = ApexPages.currentPage().getParameters().get('isNew');
        if(isNew == 'true') {
            newPresetTemplate();
        }
*/
    	
    }

    Private String paymentTypesSelected = '';
    public List<String> paymentTypesToAdd{get;set;}
    public List<String> paymentTypesToRemove{get;set;}

    public String getPaymentTypeFields() {
        return objBPH.getPaymentTypeFields();
    }
	
	
	public map<string,string> fieldIdMap {get;set;}
	public string fieldIdMapStr {get;set;}
	public void createPaymentFieldIdMap(){
		
		List<SelectOption> optionsToRemove = getPTypePickListOptionsToRemove();
        System.debug('optionsToRemove---   '+optionsToRemove);
        list<string> paymentTypeKeyList = new list<string>(); 
        for(SelectOption selOption : optionsToRemove){
    		System.debug('selOption--val-   '+selOption.getValue());
    		if(selOption.getValue() == '')continue;
    		paymentTypeKeyList.add(selOption.getValue());
        }
        System.debug('paymentTypeKeyList---   '+paymentTypeKeyList);
		
		Map<String, List<String>> PaymentTypeFieldMap = objBPH.getPaymentTypeFieldMap();
		if(!PaymentTypeFieldMap.isEmpty()){
			fieldIdMap = new map<string,string>();
			fieldIdMapStr = '';
			for(string keyStr : paymentTypeKeyList){
				//if(keyStr == 'Cheque')continue;
				list<string> fieldList = PaymentTypeFieldMap.get(keyStr);
				if(!fieldList.isEmpty()){
					for(string str : fieldList){
						fieldIdMap.put(str,keyStr);
	            		fieldIdMapStr = fieldIdMapStr+':'+str;
					}
				}
			}
		}
		
	}
	
    public void addPaymentTypes() {
//        isPresetSaved = false;
		
		System.debug('paymentTypesToAdd---   '+ paymentTypesToAdd+'    '+paymentTypesSelected);
		System.debug('fieldIdMap---   ' + fieldIdMap);
        System.debug('####### paymentTypesToAdd #######' + paymentTypesToAdd);
        System.debug('####### paymentTypesSelected  #######' + paymentTypesSelected);
        System.debug('####### objBPH.getPaymentTypes()  #######' + objBPH.getPaymentTypes());
        System.debug('####### objBPH.getPaymentTypeFieldMap()  #######' + objBPH.getPaymentTypeFieldMap());
        System.debug('####### paymentFieldsMap  #######' + paymentFieldsMap);
        System.debug('####### PaymentFields  #######' + PaymentFields);

        for(String type : paymentTypesToAdd) {
            if(!paymentTypesSelected.contains(type + ',')) {
                paymentTypesSelected += type + ',';
            }
            if(objBPH.getPaymentTypes().contains(type + ',')) {
                for( String field : objBPH.getPaymentTypeFieldMap().get(type) ) {
                    if(paymentFieldsMap.get(field) != null) {
                        PaymentFields.add(paymentFieldsMap.get(field));
                    }
                    paymentFieldsMap.remove(field);
                }
            }
        }
        System.debug('####### PaymentFields 1 #######' + PaymentFields);
        //bik
        createPaymentFieldIdMap();
    }

    public void removePaymentTypes() {
        isPresetSaved = false;

        String temp = '';
        for(String type : paymentTypesSelected.split(',', 0)) {
            if(!( (new Set<String>(paymentTypesToRemove)).contains(type) || temp.contains(type))) {
                temp += type + ',';
            }
        }
        paymentTypesSelected = temp;

        //Remove all Payment Type Fields.
            System.debug('####### PaymentFields #########'+PaymentFields);
        for(Integer i=0; i < PaymentFields.size(); i++) {
            System.debug('####### PaymentFields.size() #########'+PaymentFields.size());
            System.debug('####### objBPH.getPaymentTypeFields() #########'+objBPH.getPaymentTypeFields()+'    '+i);
//            System.debug('####### PaymentFields[i].fieldName #########'+PaymentFields[i].fieldName);
            if(PaymentFields[i] != null && objBPH.getPaymentTypeFields().contains(PaymentFields[i].fieldName)) {
                paymentFieldsMap.put(PaymentFields[i].fieldName, PaymentFields[i]);
                PaymentFields.remove(i);
                i--;
            }
        }

        //Add all Fields that belong to selected Payment Types
        for(String type : paymentTypesSelected.split(',', 0)) {
            LIST<String> fields = objBPH.getPaymentTypeFieldMap().get(type);
            if(fields != null) {
                for( String field : fields ) {
                    if(paymentFieldsMap.get(field) != null) {
                        PaymentFields.add(paymentFieldsMap.get(field));
                    }
                    paymentFieldsMap.remove(field);
                }
            }
        }
        System.debug('paymentTypesToAdd---   ' + paymentTypesToAdd+'    '+paymentTypesSelected);
    }

    public List<SelectOption> getPTypePickListOptionsToAdd() {
        return getPTypePickListOptions(true);
    }

    public List<SelectOption> getPTypePickListOptionsToRemove() {
        List<SelectOption> optionsToRemove = getPTypePickListOptions(false);
        if(optionsToRemove.size() > 0) {
            optionsToRemove.add(0, new SelectOption('', '--Choosen--', true));
        } else {
            optionsToRemove.add(new SelectOption('', '--Choosen--', true));
        }

        return optionsToRemove;
    }
    private List<SelectOption> getPTypePickListOptions(Boolean toAdd) {
        List<SelectOption> optionsToAdd = new List<SelectOption>();
        List<SelectOption> optionsToRemove = new List<SelectOption>();
        optionsToAdd.add(new SelectOption('', '--Available--', true));

        for(String type : objBPH.getPaymentTypes().split(',', 0)) {
            //Add options if the Type is not in "paymentTypesSelected".
            if(!paymentTypesSelected.contains(type + ',')) {
                optionsToAdd.add(new SelectOption(type.trim(), type.trim()));
            } else {
                optionsToRemove.add(new SelectOption(type.trim(), type.trim()));
            }
        }
        return toAdd ? optionsToAdd : optionsToRemove;
    }

    public List<SelectOption> getPaymentTypePickListOptions() {
        List<SelectOption> options = getPTypePickListOptions(false);
        if(options.size() > 0) {
            options.add(0, new SelectOption('', '--None--'));
        } else {
            options.add(new SelectOption('', '--None--'));
        }

        return options;
    }
    
    public List<SelectOption> getConPickListOptions() {
        return objBPH.pickListOptions(contactFieldsMap, conPickValues, false);
    }
    
    public List<SelectOption> getAccPickListOptions() {
        return objBPH.pickListOptions(accountFieldsMap, accPickValues, false);
    }
    
    public List<SelectOption> getRgfPickListOptions() {
        return objBPH.pickListOptions(recGiftFieldsMap, rgfPickValues, false);
    }
    
    public List<SelectOption> getTrnxPickListOptions() {
        return objBPH.pickListOptions(tranxFieldsMap, trnxPickValues, false);
    }
    
    public List<SelectOption> getPymtPickListOptions() {
        return objBPH.pickListOptions(paymentFieldsMap, pymtPickValues, true);
    }
    
    public List<SelectOption> getRcptPickListOptions() {
        return objBPH.pickListOptions(receiptFieldsMap, rcptPickValues, false);
    }
    
    public List<SelectOption> getDGPickListOptions() {
        return objBPH.pickListOptions(giftDetailFieldsMap, giftDetailPickValues, false);
    }
    
    public List<SelectOption> getEventPickListOptions() {
        return objBPH.pickListOptions(eventRegFieldsMap, eventRegPickValues, false);
    }
    
    public pageReference showTemplate() {
        isSelectPreset = false;
        isShowPreset = true;
        
        return null;
    }
    public List<Batch_Template__c> getViewPresets() {
        List<Batch_Template__c> presetTemplates;
        if(RT == null) {
            return null;
        }
        if(temp.Type__c == 'Personal') {
            presetTemplates = [SELECT Id,Name,Type__c FROM Batch_Template__c WHERE Type__c =: temp.Type__c And RecordTypeId =: RT.Id And CreatedById =: UserInfo.getUserId() Order By Name];    //WHERE Type__c =: template.Type__c
        } else {
            presetTemplates = [SELECT Id,Name,Type__c FROM Batch_Template__c WHERE Type__c =: temp.Type__c And RecordTypeId =: RT.Id Order By Name];    //WHERE Type__c =: template.Type__c
        }
        isSelectPreset = false;
        isShowPreset = true;
        
        return presetTemplates;
    }

    public pageReference CreateNewPresetTemplate() {
        PageReference pageRef = new PageReference('/apex/EditBatchPreset_moc');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pageReference newPresetTemplate() {
        
        isNewPreset = true;
/*        if(template.Type__c == 'Event Registration')
            isEventPreset = true;
        else
            isEventPreset = false;
*/            
        if(contactFields.size() == 0)
            objBPH.bildFieldsMap(contactFieldsMap, contactFields, 'Contact', isNewPreset);
        if(accountFields.size() == 0)
            objBPH.bildFieldsMap(accountFieldsMap, accountFields, 'Account',isNewPreset);
        if(RecurringGiftFields.size() == 0)
            objBPH.bildFieldsMap(recGiftFieldsMap, RecurringGiftFields, 'causeview__Recurring_Donation__c', isNewPreset);
        if(TransactionFields.size() == 0)
            objBPH.bildFieldsMap(tranxFieldsMap, TransactionFields, 'causeview__Gift__c',isNewPreset);
        if(PaymentFields.size() == 0)
            objBPH.bildFieldsMap(paymentFieldsMap, PaymentFields, 'causeview__Payment__c', isNewPreset);
        if(ReceiptFields.size() == 0)
            objBPH.bildFieldsMap(receiptFieldsMap, ReceiptFields, 'causeview__Receipt__c', isNewPreset);
        if(GiftDetailFields.size() == 0)
            objBPH.bildFieldsMap(giftDetailFieldsMap, GiftDetailFields, 'causeview__Gift_Detail__c', isNewPreset);
/*        if(eventRegFields.size() == 0 && isEventPreset == true)
            objBPH.bildFieldsMap(eventRegFieldsMap, eventRegFields, 'causeview__Event_Registration__c', isNewPreset);
*/            
        return null;
    }

    public PageReference editAPresetTemplate() {
        templateId = ApexPages.currentPage().getParameters().get('templateId');
        PageReference pageRef = new PageReference('/apex/EditBatchPreset_moc?id=' + templateId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference editPresetTemplate() {

        isPresetSaved = true;
        
        isNewPreset = false;
/*        if(template.Type__c == 'Event Registration')
            isEventPreset = true;
        else
            isEventPreset = false;
*/            
        Batch_Template__c presetTemplate = [SELECT Id,Name,AccountFieldsXml__c,ContactFieldXml__c,GiftDetailFieldsXml__c,PaymentFieldsXml__c,ReceiptFieldsXml__c,
                                                RecurringGiftFieldsXml__c,TransactionFieldsXml__c,EventRegistrationsFieldsXml__c,Type__c,Transaction_Type__c,RecordType.Name FROM Batch_Template__c Where Id =: templateId];

        if(presetTemplate.RecordType.Name == 'Cloned') {
            isCloned = true;
        }
        
        template.Name = presetTemplate.Name;
        template.Type__c = presetTemplate.Type__c;
        template.Transaction_Type__c = presetTemplate.Transaction_Type__c;
        
        BatchPresetHelper_moc obj_BPH = new BatchPresetHelper_moc();
        if(contactFields.size() == 0) {
            contactFields = obj_BPH.readXML(presetTemplate.ContactFieldXml__c, 'Contact');
            obj_BPH.bildFieldsMap(contactFieldsMap, contactFields, 'Contact', isNewPreset);
        }
        if(accountFields.size() == 0) {
            accountFields = obj_BPH.readXML(presetTemplate.AccountFieldsXml__c, 'Account');
            obj_BPH.bildFieldsMap(accountFieldsMap, accountFields, 'Account', isNewPreset);
        }
        if(RecurringGiftFields.size() == 0) {
            RecurringGiftFields = obj_BPH.readXML(presetTemplate.RecurringGiftFieldsXml__c, 'causeview__Recurring_Donation__c');
            obj_BPH.bildFieldsMap(recGiftFieldsMap, RecurringGiftFields, 'causeview__Recurring_Donation__c', isNewPreset);
        }
        if(TransactionFields.size() == 0) {
            TransactionFields = obj_BPH.readXML(presetTemplate.TransactionFieldsXml__c, 'causeview__Gift__c');
            obj_BPH.bildFieldsMap(tranxFieldsMap, TransactionFields, 'causeview__Gift__c', isNewPreset);
        }
        if(PaymentFields.size() == 0) {
            PaymentFields = obj_BPH.readXML(presetTemplate.PaymentFieldsXml__c, 'causeview__Payment__c');
            //Get Payment Types Selected.
            paymentTypesSelected = obj_BPH.paymentTypesSelected;
/*            for(String type : obj_BPH.getPaymentTypes().split(',', 0)) {
                if(!paymentTypesSelected.contains(type)) {
                    pymtPickValues.add(type);
                }
            }
*/
            obj_BPH.bildFieldsMap(paymentFieldsMap, PaymentFields, 'causeview__Payment__c', isNewPreset);
        }
        if(ReceiptFields.size() == 0) {
            ReceiptFields = obj_BPH.readXML(presetTemplate.ReceiptFieldsXml__c, 'causeview__Receipt__c');
            obj_BPH.bildFieldsMap(receiptFieldsMap, ReceiptFields, 'causeview__Receipt__c', isNewPreset);
        }
        if(GiftDetailFields.size() == 0) {
            GiftDetailFields = obj_BPH.readXML(presetTemplate.GiftDetailFieldsXml__c, 'causeview__Gift_Detail__c');
            obj_BPH.bildFieldsMap(giftDetailFieldsMap, GiftDetailFields, 'causeview__Gift_Detail__c', isNewPreset);
        }
/*        if(eventRegFields.size() == 0 && isEventPreset == true) {
            eventRegFields = obj_BPH.readXML(presetTemplate.EventRegistrationsFieldsXml__c, 'causeview__Event_Registration__c');
            obj_BPH.bildFieldsMap(eventRegFieldsMap, eventRegFields, 'causeview__Event_Registration__c', isNewPreset);
        }
*/        

        templateId = presetTemplate.Id;
        
        return null;
    }
    
    public string objectRecordsIndexStr {get;set;}
    
    public string IndexListStr0 {get;set;}
    public string IndexListStr1 {get;set;}
    public string IndexListStr2 {get;set;}
    public string IndexListStr3 {get;set;}
    public string IndexListStr4 {get;set;}
    public string IndexListStr5 {get;set;}
    public string IndexListStr6 {get;set;}
    
    public list<PresetWrapper> buildPresetWrapperListAsPerIndex(string objectName,list<Integer> indexList){
        list<PresetWrapper> recordList_Temp = new list<PresetWrapper>();
        for(Integer index : indexList){
            if(objectName == 'Contact')recordList_Temp.add(contactFields.get(index));
            if(objectName == 'Account')recordList_Temp.add(accountFields.get(index)); 
            if(objectName == 'causeview__Recurring_Donation__c')recordList_Temp.add(RecurringGiftFields.get(index));
            if(objectName == 'causeview__Gift__c')recordList_Temp.add(TransactionFields.get(index));
            if(objectName == 'causeview__Payment__c')recordList_Temp.add(PaymentFields.get(index));
            if(objectName == 'causeview__Receipt__c')recordList_Temp.add(ReceiptFields.get(index));
            if(objectName == 'causeview__Gift_Detail__c')recordList_Temp.add(GiftDetailFields.get(index));
        }
        return recordList_Temp;
    }
    
    public list<Integer> createIndexList(string IndexListStr_Temp){
        list<Integer> indexList = new list<Integer>();
        if(IndexListStr_Temp.contains(',')){
            list<string> idStrList = IndexListStr_Temp.split(',');
            if(idStrList != null && !idStrList.isEmpty()){
                for(string idStr : idStrList){
                    if(idStr.contains(':')){
                        string indexVal = idStr.split(':')[1];
                        integer indexVal_Int = Integer.valueOf(indexVal);
                        system.debug('indexVal_Int---   '+indexVal_Int);
                        indexList.add(indexVal_Int);
                    }
                }
            }
        }
        return indexList;
    }
    
    public void SaveOrderListForAll(){
        string IndexListStr_Temp;
        if(!IndexListStr0.contains('done') && IndexListStr0.contains(',')){
            IndexListStr_Temp = IndexListStr0;
            list<Integer> indexList = createIndexList(IndexListStr_Temp);
            list<PresetWrapper> recordList_Temp;
            if(indexList !=null && !indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex('Contact',indexList);
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('contactFields--and--recordList_Temp---size   '+contactFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == contactFields.size()){
                    contactFields.clear();
                    contactFields.addAll(recordList_Temp);
                }
            }
            //bik
        }
        if(!IndexListStr1.contains('done') && IndexListStr1.contains(',')){
            IndexListStr_Temp = IndexListStr1;
            list<Integer> indexList = createIndexList(IndexListStr_Temp);
            list<PresetWrapper> recordList_Temp;
            if(indexList !=null && !indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex('Account',indexList);
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('accountFields--and--recordList_Temp---size   '+accountFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == accountFields.size()){
                    accountFields.clear();
                    accountFields.addAll(recordList_Temp);
                }
            }
            //bik
        }
        
        if(!IndexListStr2.contains('done') && IndexListStr2.contains(',')){
            IndexListStr_Temp = IndexListStr2;
            list<Integer> indexList = createIndexList(IndexListStr_Temp);
            list<PresetWrapper> recordList_Temp;
            if(indexList !=null && !indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex('causeview__Recurring_Donation__c',indexList);
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('RecurringGiftFields--and--recordList_Temp---size   '+RecurringGiftFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == RecurringGiftFields.size()){
                    RecurringGiftFields.clear();
                    RecurringGiftFields.addAll(recordList_Temp);
                }
            }
            //bik
        }
        
        if(!IndexListStr3.contains('done') && IndexListStr3.contains(',')){
            IndexListStr_Temp = IndexListStr3;
            list<Integer> indexList = createIndexList(IndexListStr_Temp);
            list<PresetWrapper> recordList_Temp;
            if(indexList !=null && !indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex('causeview__Gift__c',indexList);
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('TransactionFields--and--recordList_Temp---size   '+TransactionFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == TransactionFields.size()){
                    TransactionFields.clear();
                    TransactionFields.addAll(recordList_Temp);
                }
            }
            //bik
        }
        
        if(!IndexListStr4.contains('done') && IndexListStr4.contains(',')){
            IndexListStr_Temp = IndexListStr4;
            list<Integer> indexList = createIndexList(IndexListStr_Temp);
            list<PresetWrapper> recordList_Temp;
            if(indexList !=null && !indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex('causeview__Payment__c',indexList);
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('PaymentFields--and--recordList_Temp---size   '+PaymentFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == PaymentFields.size()){
                    PaymentFields.clear();
                    PaymentFields.addAll(recordList_Temp);
                }
            }
            //bik
        }
        
        if(!IndexListStr5.contains('done') && IndexListStr5.contains(',')){
            IndexListStr_Temp = IndexListStr5;
            list<Integer> indexList = createIndexList(IndexListStr_Temp);
            list<PresetWrapper> recordList_Temp;
            if(indexList !=null && !indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex('causeview__Receipt__c',indexList);
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('ReceiptFields--and--recordList_Temp---size   '+ReceiptFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == ReceiptFields.size()){
                    ReceiptFields.clear();
                    ReceiptFields.addAll(recordList_Temp);
                }
            }
            //bik
        }
        
        if(!IndexListStr6.contains('done') && IndexListStr6.contains(',')){
            IndexListStr_Temp = IndexListStr6;
            list<Integer> indexList = createIndexList(IndexListStr_Temp);
            list<PresetWrapper> recordList_Temp;
            if(indexList !=null && !indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex('causeview__Gift_Detail__c',indexList);
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('GiftDetailFields--and--recordList_Temp---size   '+GiftDetailFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == GiftDetailFields.size()){
                    GiftDetailFields.clear();
                    GiftDetailFields.addAll(recordList_Temp);
                }
            }
            //bik
        }
    }
    
    public void addInPreset(){

        isPresetSaved = false;
        
        String objectName = ApexPages.currentPage().getParameters().get('ObjectType');
        string IndexListStr_Temp;
                
        if(objectName == 'Contact')IndexListStr_Temp = IndexListStr0;
        if(objectName == 'Account')IndexListStr_Temp = IndexListStr1;
        if(objectName == 'causeview__Recurring_Donation__c')IndexListStr_Temp = IndexListStr2;
        if(objectName == 'causeview__Gift__c')IndexListStr_Temp = IndexListStr3;
        if(objectName == 'causeview__Payment__c')IndexListStr_Temp = IndexListStr4;
        if(objectName == 'causeview__Receipt__c')IndexListStr_Temp = IndexListStr5;
        if(objectName == 'causeview__Gift_Detail__c')IndexListStr_Temp = IndexListStr6;
        
        // change index bik
        System.debug('IndexListStr_Temp------   '+objectName+' kkk '+IndexListStr_Temp+'    '+contactFields);
        list<Integer> indexList = new list<Integer>();
        if(IndexListStr_Temp.contains(',')){
            list<string> idStrList = IndexListStr_Temp.split(',');
            if(idStrList != null && !idStrList.isEmpty()){
                for(string idStr : idStrList){
                    if(idStr.contains(':')){
                        string indexVal = idStr.split(':')[1];
                        integer indexVal_Int = Integer.valueOf(indexVal);
                        system.debug('indexVal_Int---   '+indexVal_Int);
                        indexList.add(indexVal_Int);
                    }
                }
            }
        }
        list<PresetWrapper> recordList_Temp;
        if(!indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex(objectName,indexList);
        //bik
        
        if(objectName == 'Contact') {
            if(conSelected.size()>0)
            {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('contactFields--and--recordList_Temp---size   '+contactFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == contactFields.size()){
                    contactFields.clear();
                    contactFields.addAll(recordList_Temp);
                }
            }
            //bik
            for(String pwSelected : conSelected){
                System.debug('pwSelected------   '+pwSelected);
                conPickValues.remove(pwSelected);
                contactFields.add(contactFieldsMap.get(pwSelected));
                contactFieldsMap.remove(pwSelected);
            }
            }
        }
        else if(objectName == 'Account') {
            if(accSelected.size()>0)
            {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('accountFields--and--recordList_Temp---size   '+accountFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == accountFields.size()){
                    accountFields.clear();
                    accountFields.addAll(recordList_Temp);
                }
            }
            //bik
            for(String pwSelected : accSelected){
                accPickValues.remove(pwSelected);
                accountFields.add(accountFieldsMap.get(pwSelected));
                accountFieldsMap.remove(pwSelected);
            }
            }
        }
        else if(objectName == 'causeview__Recurring_Donation__c') {
            if(rgfSelected.size()>0)
            {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('RecurringGiftFields--and--recordList_Temp---size   '+RecurringGiftFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == RecurringGiftFields.size()){
                    RecurringGiftFields.clear();
                    RecurringGiftFields.addAll(recordList_Temp);
                }
            }
            //bik
            for(String pwSelected : rgfSelected){
                rgfPickValues.remove(pwSelected);
                RecurringGiftFields.add(recGiftFieldsMap.get(pwSelected));
                recGiftFieldsMap.remove(pwSelected);
            }
            }
        } 
        else if(objectName == 'causeview__Gift__c') { 
            if(trnxSelected.size()>0)
            {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('TransactionFields--and--recordList_Temp---size   '+TransactionFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == TransactionFields.size()){
                    TransactionFields.clear();
                    TransactionFields.addAll(recordList_Temp);
                }
            }
            //bik
            
            for(String pwSelected : trnxSelected){
                trnxPickValues.remove(pwSelected);
                TransactionFields.add(tranxFieldsMap.get(pwSelected));
                tranxFieldsMap.remove(pwSelected);
            }
            }
        } 
        else if(objectName == 'causeview__Payment__c') {  
            if(pymtSelected.size()>0)
            {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('PaymentFields--and--recordList_Temp---size   '+PaymentFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == PaymentFields.size()){
                    PaymentFields.clear();
                    PaymentFields.addAll(recordList_Temp);
                }
            }
            //bik
            
            for(String pwSelected : pymtSelected){
/*                if(objBPH.getPaymentTypes().contains(pwSelected)) {
                    for( String field : objBPH.getPaymentTypeFieldMap().get(pwSelected) ) {
                        PaymentFields.add(paymentFieldsMap.get(field));
                        paymentFieldsMap.remove(field);
                    }
                } else {
*/                PaymentFields.add(paymentFieldsMap.get(pwSelected));
                paymentFieldsMap.remove(pwSelected);
                pymtPickValues.remove(pwSelected);
            }
            }
        } 
        else if(objectName == 'causeview__Receipt__c') { 
            if(rcptSelected.size()>0)
            {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('ReceiptFields--and--recordList_Temp---size   '+ReceiptFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == ReceiptFields.size()){
                    ReceiptFields.clear();
                    ReceiptFields.addAll(recordList_Temp);
                }
            }
            //bik
            for(String pwSelected : rcptSelected){
                rcptPickValues.remove(pwSelected);
                ReceiptFields.add(receiptFieldsMap.get(pwSelected));
                receiptFieldsMap.remove(pwSelected);
            }
            }
        }
        else if(objectName == 'causeview__Gift_Detail__c') { 
            System.debug('objectName--------   '+objectName+'    '+recordList_Temp);
            if(giftDetailSelected.size()>0)
            {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('GiftDetailFields--and--recordList_Temp---size   '+GiftDetailFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == GiftDetailFields.size()){
                    GiftDetailFields.clear();
                    GiftDetailFields.addAll(recordList_Temp);
                }
            }
            //bik
            for(String pwSelected : giftDetailSelected){
                giftDetailPickValues.remove(pwSelected);
                GiftDetailFields.add(giftDetailFieldsMap.get(pwSelected));
                giftDetailFieldsMap.remove(pwSelected);
            }
            }
        }
/*        else if(objectName == 'causeview__Event_Registration__c') {
            for(String pwSelected : eventRegSelected){
                eventRegPickValues.remove(pwSelected);
                eventRegFields.add(eventRegFieldsMap.get(pwSelected));
                eventRegFieldsMap.remove(pwSelected);
            }
        }
*/    }
    
    public string removalIndex1 {get;set;}
    public void removeFromPreset() {

        isPresetSaved = false;
        
        PresetWrapper pw;
        String objectName = ApexPages.currentPage().getParameters().get('ObjectType');
        Integer listIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
        System.debug('remove---   '+removalIndex1+'   '+objectName+'    '+listIndex+'   '+contactFields);
        integer removalIndex_Temp = Integer.valueOf(removalIndex1)-1;
        
        //bik
        //SaveOrderListForAll();
        string IndexListStr_Temp;
                
        if(objectName == 'Contact')IndexListStr_Temp = IndexListStr0;
        if(objectName == 'Account')IndexListStr_Temp = IndexListStr1;
        if(objectName == 'causeview__Recurring_Donation__c')IndexListStr_Temp = IndexListStr2;
        if(objectName == 'causeview__Gift__c')IndexListStr_Temp = IndexListStr3;
        if(objectName == 'causeview__Payment__c')IndexListStr_Temp = IndexListStr4;
        if(objectName == 'causeview__Receipt__c')IndexListStr_Temp = IndexListStr5;
        if(objectName == 'causeview__Gift_Detail__c')IndexListStr_Temp = IndexListStr6;
        
        // change index bik
        System.debug('IndexListStr_Temp------   '+objectName+' kkk '+IndexListStr_Temp);
        list<Integer> indexList = new list<Integer>();
        if(IndexListStr_Temp.contains(',')){
            list<string> idStrList = IndexListStr_Temp.split(',');
            if(idStrList != null && !idStrList.isEmpty()){
                for(string idStr : idStrList){
                    if(idStr.contains(':')){
                        string indexVal = idStr.split(':')[1];
                        integer indexVal_Int = Integer.valueOf(indexVal);
                        system.debug('indexVal_Int---   '+indexVal_Int);
                        indexList.add(indexVal_Int);
                    }
                }
            }
        }
        list<PresetWrapper> recordList_Temp;
        if(!indexList.isEmpty())recordList_Temp = buildPresetWrapperListAsPerIndex(objectName,indexList);
        //bik
        
        if(objectName == 'Contact') {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('contactFields--and--recordList_Temp---size   '+contactFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == contactFields.size()){
                    contactFields.clear();
                    contactFields.addAll(recordList_Temp);
                }
            }
            //bik
            
            pw = contactFields[removalIndex_Temp];
            conPickValues.add(pw.fieldName);
            contactFields.remove(removalIndex_Temp);
            contactFieldsMap.put(pw.fieldName, pw);
        }
        else if(objectName == 'Account') {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('accountFields--and--recordList_Temp---size   '+accountFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == accountFields.size()){
                    accountFields.clear();
                    accountFields.addAll(recordList_Temp);
                }
            }
            //bik
            
            pw = accountFields[removalIndex_Temp];
            accPickValues.add(pw.fieldName);
            accountFields.remove(removalIndex_Temp);
            accountFieldsMap.put(pw.fieldName, pw);
        }
        else if(objectName == 'causeview__Recurring_Donation__c') {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('RecurringGiftFields--and--recordList_Temp---size   '+RecurringGiftFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == RecurringGiftFields.size()){
                    RecurringGiftFields.clear();
                    RecurringGiftFields.addAll(recordList_Temp);
                }
            }
            //bik
            pw = RecurringGiftFields[removalIndex_Temp];
            rgfPickValues.add(pw.fieldName);
            RecurringGiftFields.remove(removalIndex_Temp);
            recGiftFieldsMap.put(pw.fieldName, pw);
        } 
        else if(objectName == 'causeview__Gift__c') {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('TransactionFields--and--recordList_Temp---size   '+TransactionFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == TransactionFields.size()){
                    TransactionFields.clear();
                    TransactionFields.addAll(recordList_Temp);
                }
            }
            //bik
            pw = TransactionFields[removalIndex_Temp];
            trnxPickValues.add(pw.fieldName);
            TransactionFields.remove(removalIndex_Temp);
            tranxFieldsMap.put(pw.fieldName, pw);
        } 
        else if(objectName == 'causeview__Payment__c') {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('PaymentFields--and--recordList_Temp---size   '+PaymentFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == PaymentFields.size()){
                    PaymentFields.clear();
                    PaymentFields.addAll(recordList_Temp);
                }
            }
            //bik
            pw = PaymentFields[removalIndex_Temp];
            pymtPickValues.add(pw.fieldName);
            PaymentFields.remove(removalIndex_Temp);
            paymentFieldsMap.put(pw.fieldName, pw);
        } 
        else if(objectName == 'causeview__Receipt__c') {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('ReceiptFields--and--recordList_Temp---size   '+ReceiptFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == ReceiptFields.size()){
                    ReceiptFields.clear();
                    ReceiptFields.addAll(recordList_Temp);
                }
            }
            //bik
            pw = ReceiptFields[removalIndex_Temp];
            rcptPickValues.add(pw.fieldName);
            ReceiptFields.remove(removalIndex_Temp);
            receiptFieldsMap.put(pw.fieldName, pw);
        }
        else if(objectName == 'causeview__Gift_Detail__c') {
            //bik
            if(recordList_Temp != null && !recordList_Temp.isEmpty()){
                system.debug('GiftDetailFields--and--recordList_Temp---size   '+GiftDetailFields.size()+'    '+recordList_Temp.size());
                if(recordList_Temp.size() == GiftDetailFields.size()){
                    GiftDetailFields.clear();
                    GiftDetailFields.addAll(recordList_Temp);
                }
            }
            //bik
            pw = GiftDetailFields[removalIndex_Temp];
            giftDetailPickValues.add(pw.fieldName);
            GiftDetailFields.remove(removalIndex_Temp);
            giftDetailFieldsMap.put(pw.fieldName, pw);
        }
/*        else if(objectName == 'causeview__Event_Registration__c') {
            pw = eventRegFields[listIndex];
            eventRegPickValues.add(pw.fieldName);
            eventRegFields.remove(listIndex);
            eventRegFieldsMap.put(pw.fieldName, pw);
        }
*/    }
    
    public pageReference saveBatchPreset() {
		System.debug('Transaction Type--- '+template.Transaction_Type__c);
        if(getPaymentTypePickListOptions().size() < 2) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select at least one Payment Type'));
            return null;
        }

        try {
            
            if(template.Name == null || template.Name == '')
                throw new MyCustomException('Template Name can not be empty.');

            BatchPresetHelper_moc objBPXMLP = new BatchPresetHelper_moc();
            if(templateId != null && templateId != '') {
                SaveOrderListForAll();
                Batch_Template__c presetTemplate = [SELECT Id,Name,AccountFieldsXml__c,ContactFieldXml__c,GiftDetailFieldsXml__c,PaymentFieldsXml__c,ReceiptFieldsXml__c,
                                                        RecurringGiftFieldsXml__c,TransactionFieldsXml__c,EventRegistrationsFieldsXml__c,Type__c,Transaction_Type__c FROM Batch_Template__c Where Id =: templateId];
                presetTemplate.Name = template.Name;
                presetTemplate.Type__c = template.Type__c;
                presetTemplate.Transaction_Type__c = template.Transaction_Type__c;
                
                presetTemplate.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields, null);
                presetTemplate.ContactFieldXml__c =  objBPXMLP.writeXML('Contact', contactFields, null);
                system.debug('displaying here    '+contactFields);
                presetTemplate.RecurringGiftFieldsXml__c = objBPXMLP.writeXML('causeview__Recurring_Donation__c', RecurringGiftFields, null);
                presetTemplate.TransactionFieldsXml__c = objBPXMLP.writeXML('causeview__Gift__c', TransactionFields, null);
                presetTemplate.PaymentFieldsXml__c = objBPXMLP.writeXML('causeview__Payment__c', PaymentFields, paymentTypesSelected);
                presetTemplate.ReceiptFieldsXml__c = objBPXMLP.writeXML('causeview__Receipt__c', ReceiptFields, null);
                presetTemplate.GiftDetailFieldsXml__c = objBPXMLP.writeXML('causeview__Gift_Detail__c', GiftDetailFields, null);
//                presetTemplate.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML('causeview__Event_Registration__c', eventRegFields);
                
                update presetTemplate;
            }
            else {
                SaveOrderListForAll();
                Batch_Template__c obj_BPT = new Batch_Template__c();
                obj_BPT.RecordTypeId = RT.Id;
                obj_BPT.Name = template.Name;
                obj_BPT.Type__c = template.Type__c;
                obj_BPT.Transaction_Type__c = template.Transaction_Type__c;
                obj_BPT.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields, null);
                obj_BPT.ContactFieldXml__c =  objBPXMLP.writeXML('Contact', contactFields, null);
                obj_BPT.RecurringGiftFieldsXml__c = objBPXMLP.writeXML('causeview__Recurring_Donation__c', RecurringGiftFields, null);
                obj_BPT.TransactionFieldsXml__c = objBPXMLP.writeXML('causeview__Gift__c', TransactionFields, null);
                obj_BPT.PaymentFieldsXml__c = objBPXMLP.writeXML('causeview__Payment__c', PaymentFields, paymentTypesSelected);
                obj_BPT.ReceiptFieldsXml__c = objBPXMLP.writeXML('causeview__Receipt__c', ReceiptFields, null);
                obj_BPT.GiftDetailFieldsXml__c = objBPXMLP.writeXML('causeview__Gift_Detail__c', GiftDetailFields, null);
                obj_BPT.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML('causeview__Event_Registration__c', eventRegFields, null);
                
                insert obj_BPT;
                templateId = obj_BPT.Id;
            }
            
            //PageReference pageRef = new PageReference('/apex/EditBatchPreset_moc?id=' + templateId);
            //PageReference pageRef = new PageReference('/apex/EditBatchPreset_moc_DupPage3?id=' + templateId);
            PageReference pageRef = new PageReference('/apex/EditBatchPreset_moc_DupPage3?id=' + templateId+'&msg=Batch Template has been saved!');
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(Exception e){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
    
    public PageReference clonePresetTemplate() {
        isPresetSaved = false;

        template.Name = null;
        templateId = null;
        //isEditMode = true;
        PageReference pageRef = new PageReference('/apex/EditBatchPreset_moc_DupPage3');
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    public pageReference cancel() {
        PageReference pageRef = new PageReference('/apex/BatchPresets_moc');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pageReference deletePreset() {
        if(templateId != null && templateId != '') {
            Batch_Template__c presetTemplate = [SELECT Id,Name FROM Batch_Template__c WHERE Id =: templateId];
            delete presetTemplate;
            PageReference pageRef = new PageReference('/apex/BatchPresets_moc');
            pageRef.setRedirect(true);
            return pageRef;
        }
        
        return null;
    }
    string templatelookupFieldId;
    public string getFieldId(String field_label){
        // Obtain the magic ids
        PageReference p = new PageReference('/' + causeview__Gift_Batch__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1');
        String html;
        if(!test.isrunningtest()){
        	html = p.getContent().toString();
        }else{
        	html = 'test content';
        }
        System.debug('html---  '+html);
        Map<String, String> labelToId = new Map<String, String>();
        Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
        while (m.find()) {
            String label = m.group(3);
            String id = m.group(1);
            if(label.equalsIgnoreCase(field_label))
                return id; // return field Id.
        }
        return '';
    }
    
    public pageReference createNewBatch() {
        String key = Gift_Batch__c.SObjectType.getDescribe().getKeyPrefix();
//        PageReference pageRef = new PageReference('/apex/BatchProcessingInterface?templateId='+templateId);
        //PageReference pageRef = new PageReference('/'+key+'/e');
        Schema.SObjectType schema_giftBatchObj = Schema.getGlobalDescribe().get('causeview__Gift_Batch__c');
        Map<String, Schema.SObjectField> fieldMap = schema_giftBatchObj.getDescribe().fields.getMap();
        string fieldLabelName = fieldMap.get('Template_Name__c').getDescribe().getlabel();
        
        templatelookupFieldId = getFieldId(fieldLabelName);
        System.debug('templatelookupFieldId--   '+templatelookupFieldId+'     '+template);
        //string strTemplateName = template.name.replaceAll('[^a-z^A-z^0-9]', '');
        String strTemplateName = EncodingUtil.urlEncode(template.name, 'UTF-8');
        System.debug('strTemplateName--   '+strTemplateName);
        
        PageReference pageRef;
        if(templatelookupFieldId!='' && templatelookupFieldId.contains('CF')){
            pageRef = new PageReference('/'+key+'/e'+'?'+templatelookupFieldId+'='+strTemplateName+'&'+templatelookupFieldId+'_lkid'+'='+templateId);
        }else{
            pageRef = new PageReference('/'+key+'/e');
        }
        pageRef.setRedirect(true);
        return pageRef;    
    }
    
  
    //sorting Related start
    public void updateListValue()
    {
       
        integer v1 = Integer.valueof(startValue);
        integer v2 = Integer.valueof(stopValue);
        system.debug('cvalue   '+classValue);
        PresetWrapper s;
        if(classValue.equals('ConDetailsortable ui-sortable'))
        {
            if(v1!=v2)
            { 
                if(v2>=contactFields.size()-1)
                {
                    s = contactFields[v1];
                    contactFields.remove(v1);
                    contactFields.add(s); 
                   
                   //system.debug('here is new val12 '+v1 + '   '+v2+'  '+s+ '  '+GiftDetailFields.size());
               
                }
                else
                {
                    s = contactFields.remove(v1);
                    contactFields.add(v2,s);
                    system.debug('here is new val '+v1 + '   '+v2+'   '+s+'   '+contactFields);
                }
            }
        }
        
        if(classValue.equals('AccDetailsortable ui-sortable'))
        {
            if(v1!=v2)
            { 
                if(v2>=accountFields.size()-1)
                {
                    s = accountFields[v1];
                    accountFields.remove(v1);
                    accountFields.add(s); 
                   
                   //system.debug('here is new val12 '+v1 + '   '+v2+'  '+s+ '  '+GiftDetailFields.size());
               
                }
                else
                {
                    s = accountFields.remove(v1);
                    accountFields.add(v2,s);
                    system.debug('here is new val '+v1 + '   '+v2);
                }
            }
        }
        
        if(classValue.equals('RfgDetailsortable ui-sortable'))
        {
            if(v1!=v2)
            { 
                if(v2>=RecurringGiftFields.size()-1)
                {
                    s = RecurringGiftFields[v1];
                    RecurringGiftFields.remove(v1);
                    RecurringGiftFields.add(s); 
                   
                   //system.debug('here is new val12 '+v1 + '   '+v2+'  '+s+ '  '+GiftDetailFields.size());
               
                }
                else
                {
                    s = RecurringGiftFields.remove(v1);
                    RecurringGiftFields.add(v2,s);
                    system.debug('here is new val '+v1 + '   '+v2);
                }
            }
        }
        
        if(classValue.equals('giftDetailsortable ui-sortable'))
        {
            if(v1!=v2)
            { 
                if(v2>=TransactionFields.size()-1)
                {
                    s = TransactionFields[v1];
                    TransactionFields.remove(v1);
                    TransactionFields.add(s); 
                   
                   //system.debug('here is new val12 '+v1 + '   '+v2+'  '+s+ '  '+GiftDetailFields.size());
               
                }
                else
                {
                    s = TransactionFields.remove(v1);
                    TransactionFields.add(v2,s);
                    system.debug('here is new val '+v1 + '   '+v2);
                }
            }
        }
        
        if(classValue.equals('pymtDetailsortable ui-sortable'))
        {
            if(v1!=v2)
            {
                if(v2>=PaymentFields.size()-1)
                {
                    s = PaymentFields[v1];
                    PaymentFields.remove(v1);
                    PaymentFields.add(s); 
                   
                   //system.debug('here is new val12 '+v1 + '   '+v2+'  '+s+ '  '+GiftDetailFields.size());
               
                }
                else
                {
                    s = PaymentFields.remove(v1);
                    PaymentFields.add(v2,s);
                    system.debug('here is new val '+v1 + '   '+v2);
                }
            }
        }
        
        if(classValue.equals('rcptDetailsortable ui-sortable'))
        {
            if(v1!=v2)
            {
                if(v2>=ReceiptFields.size()-1)
                {
                    s = ReceiptFields[v1];
                    ReceiptFields.remove(v1);
                    ReceiptFields.add(s); 
                   
                   //system.debug('here is new val12 '+v1 + '   '+v2+'  '+s+ '  '+GiftDetailFields.size());
               
                }
                else
                {
                    s = ReceiptFields.remove(v1);
                    ReceiptFields.add(v2,s);
                    system.debug('here is new val '+v1 + '   '+v2);
                }
            }
        }
        
        if(classValue.equals('gdDetailsortable ui-sortable'))
        {
            if(v1!=v2)
            {
                if(v2>=GiftDetailFields.size()-1)
                {
                    s = GiftDetailFields[v1];
                    GiftDetailFields.remove(v1);
                    GiftDetailFields.add(s); 
                   
                   //system.debug('here is new val12 '+v1 + '   '+v2+'  '+s+ '  '+GiftDetailFields.size());
               
                }
                else
                {
                    s = GiftDetailFields.remove(v1);
                    GiftDetailFields.add(v2,s);
                    system.debug('here is new val '+v1 + '   '+v2);
                }
            }
        }
         
    }
    //end
    //yy
   
    public class MyCustomException extends exception{}
}