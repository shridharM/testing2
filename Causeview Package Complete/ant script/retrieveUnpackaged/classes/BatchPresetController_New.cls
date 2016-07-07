public class BatchPresetController_New {

    public Boolean isEventPreset{get;set;}
    public Id selectedBatchTemplate{get;set;}

    public Boolean isMyBatchPresets{get;set;}
    private Boolean isNewPreset;
    public Boolean isPresetSaved{get;set;}
    
    public List<String> conSelected{get;set;}
    public List<String> accSelected{get;set;}
    public List<String> rgfSelected{get;set;}
    public List<String> trnxSelected{get;set;}
    public List<String> pymtSelected{get;set;}
    public List<String> rcptSelected{get;set;}
    public List<String> giftDetailSelected{get;set;}
    public List<String> eventRegSelected{get;set;}
    
    public Batch_Template__c template{get;set;}
    private String templateId;

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
    
    BatchPresetController objBPC;

    public BatchPresetController_New(ApexPages.StandardController controller) {

        //Redirect to Batch Presets Tab
        isMyBatchPresets = false;
        if(ApexPages.currentPage().getParameters().get('isMyBatchPresets') == 'true') {
            isMyBatchPresets = true;
        } else {
            selectedBatchTemplate = null;

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
            
            template = new Batch_Template__c();
    
            objBPC = new BatchPresetController();
    
            templateId = ApexPages.currentPage().getParameters().get('Id');
                //When an Existing Batch Preset is edited.
            if(templateId != null) {
                isNewPreset = false;
                isPresetSaved = true;
                presetTemplateData();
    
            } else {    //When a new Batch Preset is created.
    
                isNewPreset = true;
                isPresetSaved = false;
    
                getConPickListOptions();
                getAccPickListOptions();
                getRgfPickListOptions();
                getTrnxPickListOptions();
                getPymtPickListOptions();
                getRcptPickListOptions();
                getDGPickListOptions();
                getEventPickListOptions();
            }
        }
    }

    public pageReference openBatchPresetsTab() { 
        PageReference pageRef = new PageReference('/' + Batch_Template__c.sObjectType.getDescribe().getKeyPrefix());
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void addInPreset(){

        isPresetSaved = false;
        
        String objectName = ApexPages.currentPage().getParameters().get('ObjectType');
        if(objectName == 'Contact') {
            for(String pwSelected : conSelected){
                conPickValues.remove(pwSelected);
                contactFields.add(contactFieldsMap.get(pwSelected));
                contactFieldsMap.remove(pwSelected);
            }
        }
        else if(objectName == 'Account') {
            for(String pwSelected : accSelected){
                accPickValues.remove(pwSelected);
                accountFields.add(accountFieldsMap.get(pwSelected));
                accountFieldsMap.remove(pwSelected);
            }
        }
        else if(objectName == 'cv_pkg_dev_I__Recurring_Donation__c') {
            for(String pwSelected : rgfSelected){
                rgfPickValues.remove(pwSelected);
                RecurringGiftFields.add(recGiftFieldsMap.get(pwSelected));
                recGiftFieldsMap.remove(pwSelected);
            }
        } 
        else if(objectName == 'cv_pkg_dev_I__Gift__c') {
            for(String pwSelected : trnxSelected){
                trnxPickValues.remove(pwSelected);
                TransactionFields.add(tranxFieldsMap.get(pwSelected));
                tranxFieldsMap.remove(pwSelected);
            }
        } 
        else if(objectName == 'cv_pkg_dev_I__Payment__c') {
            for(String pwSelected : pymtSelected){
                pymtPickValues.remove(pwSelected);
                PaymentFields.add(paymentFieldsMap.get(pwSelected));
                paymentFieldsMap.remove(pwSelected);
            }
        } 
        else if(objectName == 'cv_pkg_dev_I__Receipt__c') {
            for(String pwSelected : rcptSelected){
                rcptPickValues.remove(pwSelected);
                ReceiptFields.add(receiptFieldsMap.get(pwSelected));
                receiptFieldsMap.remove(pwSelected);
            }
        }
        else if(objectName == 'cv_pkg_dev_I__Gift_Detail__c') {
            for(String pwSelected : giftDetailSelected){
                giftDetailPickValues.remove(pwSelected);
                GiftDetailFields.add(giftDetailFieldsMap.get(pwSelected));
                giftDetailFieldsMap.remove(pwSelected);
            }
        }
        else if(objectName == 'cv_pkg_dev_I__Event_Registration__c') {
            for(String pwSelected : eventRegSelected){
                eventRegPickValues.remove(pwSelected);
                eventRegFields.add(eventRegFieldsMap.get(pwSelected));
                eventRegFieldsMap.remove(pwSelected);
            }
        }
    }
    
    public void removeFromPreset() {

        isPresetSaved = false;
        
        PresetWrapper pw;
        String objectName = ApexPages.currentPage().getParameters().get('ObjectType');
        Integer listIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
        if(objectName == 'Contact') {
            pw = contactFields[listIndex];
            conPickValues.add(pw.fieldName);
            contactFields.remove(listIndex);
            contactFieldsMap.put(pw.fieldName, pw);
        }
        else if(objectName == 'Account') {
            pw = accountFields[listIndex];
            accPickValues.add(pw.fieldName);
            accountFields.remove(listIndex);
            accountFieldsMap.put(pw.fieldName, pw);
        }
        else if(objectName == 'cv_pkg_dev_I__Recurring_Donation__c') {
            pw = RecurringGiftFields[listIndex];
            rgfPickValues.add(pw.fieldName);
            RecurringGiftFields.remove(listIndex);
            recGiftFieldsMap.put(pw.fieldName, pw);
        } 
        else if(objectName == 'cv_pkg_dev_I__Gift__c') {
            pw = TransactionFields[listIndex];
            trnxPickValues.add(pw.fieldName);
            TransactionFields.remove(listIndex);
            tranxFieldsMap.put(pw.fieldName, pw);
        } 
        else if(objectName == 'cv_pkg_dev_I__Payment__c') {
            pw = PaymentFields[listIndex];
            pymtPickValues.add(pw.fieldName);
            PaymentFields.remove(listIndex);
            paymentFieldsMap.put(pw.fieldName, pw);
        } 
        else if(objectName == 'cv_pkg_dev_I__Receipt__c') {
            pw = ReceiptFields[listIndex];
            rcptPickValues.add(pw.fieldName);
            ReceiptFields.remove(listIndex);
            receiptFieldsMap.put(pw.fieldName, pw);
        }
        else if(objectName == 'cv_pkg_dev_I__Gift_Detail__c') {
            pw = GiftDetailFields[listIndex];
            giftDetailPickValues.add(pw.fieldName);
            GiftDetailFields.remove(listIndex);
            giftDetailFieldsMap.put(pw.fieldName, pw);
        }
        else if(objectName == 'cv_pkg_dev_I__Event_Registration__c') {
            pw = eventRegFields[listIndex];
            eventRegPickValues.add(pw.fieldName);
            eventRegFields.remove(listIndex);
            eventRegFieldsMap.put(pw.fieldName, pw);
        }
    }
    
    public List<SelectOption> getConPickListOptions() {
        
        return pickListOptions(contactFieldsMap, conPickValues, contactFields, 'Contact');
    }
    
    public List<SelectOption> getAccPickListOptions() {
        
        return pickListOptions(accountFieldsMap, accPickValues, accountFields, 'Account');
    }
    
    public List<SelectOption> getRgfPickListOptions() {
        
        return pickListOptions(recGiftFieldsMap, rgfPickValues, RecurringGiftFields, 'cv_pkg_dev_I__Recurring_Donation__c');
    }
    
    public List<SelectOption> getTrnxPickListOptions() {
        
        return pickListOptions(tranxFieldsMap, trnxPickValues, TransactionFields, 'cv_pkg_dev_I__Gift__c');
    }
    
    public List<SelectOption> getPymtPickListOptions() {
        
        return pickListOptions(paymentFieldsMap, pymtPickValues, PaymentFields, 'cv_pkg_dev_I__Payment__c');
    }
    
    public List<SelectOption> getRcptPickListOptions() {
        
        return pickListOptions(receiptFieldsMap, rcptPickValues, ReceiptFields, 'cv_pkg_dev_I__Receipt__c');
    }
    
    public List<SelectOption> getDGPickListOptions() {
        
        return pickListOptions(giftDetailFieldsMap, giftDetailPickValues, GiftDetailFields, 'cv_pkg_dev_I__Gift_Detail__c');
    }
    
    public List<SelectOption> getEventPickListOptions() {
        
        return pickListOptions(eventRegFieldsMap, eventRegPickValues, eventRegFields, 'cv_pkg_dev_I__Event_Registration__c');
    }
    
    
    private List<SelectOption> pickListOptions(Map<String,PresetWrapper> fieldsMap, Set<String> pickValues, List<PresetWrapper> dataList, String objectName) {
        
        List<string> tempList = new List<String>();
        List<SelectOption> options = new List<SelectOption>();

System.debug('#######  pickListOptions start fieldsMap ##########'+fieldsMap);
System.debug('#######  pickListOptions start pickValues ##########'+pickValues);
System.debug('#######  pickListOptions start dataList ##########'+dataList);
System.debug('#######  pickListOptions start objectName ##########'+objectName);
        
        if(fieldsMap.size() == 0) {
            if(isNewPreset == true) {
                for(PresetWrapper pw : objBPC.discribeObjects(objectName)) {
                    if(pw.isRequired == true)
                        dataList.add(pw);
                    else
                        fieldsMap.put(pw.fieldName, pw);
                }
            }
            else {
                for(PresetWrapper pw : objBPC.discribeObjects(objectName))
                    fieldsMap.put(pw.fieldName, pw);
                
                for(PresetWrapper edit_pw :dataList)
                    fieldsMap.remove(edit_pw.fieldName);
            }
        }
        
        if(options.size() == 0 && pickValues.size() == 0) {
            pickValues.addAll(fieldsMap.keySet());
            tempList.addAll(pickValues);
            tempList.sort();
            for(String fieldName : tempList)
                options.add(new SelectOption(fieldName, fieldsMap.get(fieldName).fieldLable));
        }
        else {
            tempList.addAll(pickValues);
            tempList.sort();
            for(String fieldName : tempList)
                options.add(new SelectOption(fieldName, fieldsMap.get(fieldName).fieldLable));
        }

System.debug('#######  pickListOptions end fieldsMap ##########'+fieldsMap);
System.debug('#######  pickListOptions end pickValues ##########'+pickValues);
System.debug('#######  pickListOptions end dataList ##########'+dataList);
System.debug('#######  pickListOptions end objectName ##########'+objectName);

        return options;
    }



    //ash

/*    public List<Batch_Template__c> getViewPresets() {
        List<Batch_Template__c> presetTemplates = [SELECT Id,Name,Type__c FROM Batch_Template__c WHERE Type__c = 'Personal' OR (Type__c = 'Global' AND CreatedById = :UserInfo.getUserId()) Order By Name];    // WHERE Type__c = :template.Type__c
        return presetTemplates;
    }
*/
    public List<SelectOption> getPresetTemplateOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for(Batch_Template__c template : [SELECT Id,Name,Type__c FROM Batch_Template__c WHERE Type__c = 'Personal' OR (Type__c = 'Global' AND CreatedById = :UserInfo.getUserId()) Order By Name LIMIT 100]) {
            options.add(new SelectOption(template.Id, template.Name));
        }
        return options;
    }

    public void presetTemplateData() {

System.debug('####### presetTemplateData start   ##########');
System.debug('####### presetTemplateData start contactFields  ##########'+contactFields);
System.debug('####### presetTemplateData start accountFields  ##########'+accountFields);

            
        Batch_Template__c presetTemplate = [SELECT Id,Name,AccountFieldsXml__c,ContactFieldXml__c,GiftDetailFieldsXml__c,PaymentFieldsXml__c,ReceiptFieldsXml__c,
                                                RecurringGiftFieldsXml__c,TransactionFieldsXml__c,EventRegistrationsFieldsXml__c,Type__c FROM Batch_Template__c Where Id =: templateId];
        
        template.Name = presetTemplate.Name;
        template.Type__c = presetTemplate.Type__c;
        
        BatchPresetXMLParser obj_BPXMLP = new BatchPresetXMLParser();
        if(contactFields.size() == 0)
                contactFields = obj_BPXMLP.readXML(presetTemplate.ContactFieldXml__c, 'Contact');
        if(accountFields.size() == 0)
            accountFields = obj_BPXMLP.readXML(presetTemplate.AccountFieldsXml__c, 'Account');
        if(RecurringGiftFields.size() == 0)
                RecurringGiftFields = obj_BPXMLP.readXML(presetTemplate.RecurringGiftFieldsXml__c, 'cv_pkg_dev_I__Recurring_Donation__c');
        if(TransactionFields.size() == 0)
            TransactionFields = obj_BPXMLP.readXML(presetTemplate.TransactionFieldsXml__c, 'cv_pkg_dev_I__Gift__c');
        if(PaymentFields.size() == 0)
            PaymentFields = obj_BPXMLP.readXML(presetTemplate.PaymentFieldsXml__c, 'cv_pkg_dev_I__Payment__c');
        if(ReceiptFields.size() == 0)
            ReceiptFields = obj_BPXMLP.readXML(presetTemplate.ReceiptFieldsXml__c, 'cv_pkg_dev_I__Receipt__c');
        if(GiftDetailFields.size() == 0)
            GiftDetailFields = obj_BPXMLP.readXML(presetTemplate.GiftDetailFieldsXml__c, 'cv_pkg_dev_I__Gift_Detail__c');
/*        if(eventRegFields.size() == 0 && isEventPreset == true)
            eventRegFields = obj_BPXMLP.readXML(presetTemplate.EventRegistrationsFieldsXml__c, 'cv_pkg_dev_I__Event_Registration__c');
*/

System.debug('####### presetTemplateData end presetTemplate  ##########'+presetTemplate);
System.debug('####### presetTemplateData end contactFields  ##########'+contactFields);
System.debug('####### presetTemplateData end accountFields  ##########'+accountFields);


    }

    public pageReference editBatchPreset() {
        templateId = ApexPages.currentPage().getParameters().get('templateId');
        if(templateId != null) {
/*            contactFields.clear();
            accountFields.clear();
            RecurringGiftFields.clear();
            TransactionFields.clear();
            PaymentFields.clear();
            ReceiptFields.clear();
            GiftDetailFields.clear();
            eventRegFields.clear();
            
            presetTemplateData();
*/
            PageReference pageRef = new PageReference('/apex/NewBatchPreset_New?Id='+templateId);
            pageRef.setRedirect(true);
            return pageRef; 
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select a proper Template'));
        return null;
    }
    
    public pageReference newBatchPreset() {
        
        templateId = null;
        template.Name = null;
/*
        contactFields.clear();
        accountFields.clear();
        RecurringGiftFields.clear();
        TransactionFields.clear();
        PaymentFields.clear();
        ReceiptFields.clear();
        GiftDetailFields.clear();
        eventRegFields.clear();
        
        newBatchPresetData();
*/
        PageReference pageRef = new PageReference('/apex/NewBatchPreset_New?');
        pageRef.setRedirect(false);
        return pageRef;
    }

    public pageReference cancel() {
        PageReference pageRef = new PageReference('/apex/BatchPresets?');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public pageReference cloneBatchPreset() {
        isPresetSaved = false;
        template.Name = null;
        templateId = null;
        PageReference pageRef = new PageReference('/apex/NewBatchPreset_New?');
        pageRef.setRedirect(false);
        return pageRef;
    }

    public pageReference createNewBatch() {
        PageReference pageRef = new PageReference('/apex/BatchProcessingInterface?templateId=' + templateId);
        pageRef.setRedirect(false);
        return pageRef;
    }

    public pageReference saveBatchPreset() {
        try {
            
            if(template.Name == null || template.Name == '')
                throw new MyCustomException('Template Name can not be empty.');
            
            BatchPresetXMLParser objBPXMLP = new BatchPresetXMLParser();

            if(templateId != null) {
                Batch_Template__c presetTemplate = [SELECT Id,Name,AccountFieldsXml__c,ContactFieldXml__c,GiftDetailFieldsXml__c,PaymentFieldsXml__c,ReceiptFieldsXml__c,
                                                        RecurringGiftFieldsXml__c,TransactionFieldsXml__c,EventRegistrationsFieldsXml__c,Type__c FROM Batch_Template__c Where Id =: templateId];
                presetTemplate.Name = template.Name;
                presetTemplate.Type__c = template.Type__c;
                presetTemplate.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields);
                presetTemplate.ContactFieldXml__c =  objBPXMLP.writeXML('Contact', contactFields);
                presetTemplate.RecurringGiftFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Recurring_Donation__c', RecurringGiftFields);
                presetTemplate.TransactionFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Gift__c', TransactionFields);
                presetTemplate.PaymentFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Payment__c', PaymentFields);
                presetTemplate.ReceiptFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Receipt__c', ReceiptFields);
                presetTemplate.GiftDetailFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Gift_Detail__c', GiftDetailFields);
                presetTemplate.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Event_Registration__c', eventRegFields);
                
                update presetTemplate;
            }
            else {
                Batch_Template__c obj_BPT = new Batch_Template__c();
                obj_BPT.Name = template.Name;
                obj_BPT.Type__c = template.Type__c;
                obj_BPT.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields);
                obj_BPT.ContactFieldXml__c =  objBPXMLP.writeXML('Contact', contactFields);
                obj_BPT.RecurringGiftFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Recurring_Donation__c', RecurringGiftFields);
                obj_BPT.TransactionFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Gift__c', TransactionFields);
                obj_BPT.PaymentFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Payment__c', PaymentFields);
                obj_BPT.ReceiptFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Receipt__c', ReceiptFields);
                obj_BPT.GiftDetailFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Gift_Detail__c', GiftDetailFields);
                obj_BPT.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Event_Registration__c', eventRegFields);
                
                insert obj_BPT;
                templateId = obj_BPT.Id;
            }

            isPresetSaved = true;

/*            PageReference pageRef = new PageReference('/apex/BatchPresets?');
            pageRef.setRedirect(true);
*/
//            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch Preset Saved Successfully'));
            return null;
        }
        catch(Exception e){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }


    
    public class MyCustomException extends exception{}
}