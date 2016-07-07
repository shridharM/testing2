public class BatchPresetController_moc_Dup {
    
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
    @TestVisible private String templateId;
    

    public BatchPresetController_moc_Dup(ApexPages.StandardController controller) {
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

        RT = [SELECT Id FROM RecordType WHERE SobjectType = 'cv_pkg_dev_I__Batch_Template__c' AND Name = 'Parent' AND NamespacePrefix = 'causeview'];

        templateId = ApexPages.currentPage().getParameters().get('id');
        system.debug('templateId==>'+templateId);
        if(templateId != '' && templateId != null) {
            editPresetTemplate();
        } else {
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

    public void addPaymentTypes() {
//        isPresetSaved = false;

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
            objBPH.bildFieldsMap(recGiftFieldsMap, RecurringGiftFields, 'cv_pkg_dev_I__Recurring_Donation__c', isNewPreset);
        if(TransactionFields.size() == 0)
            objBPH.bildFieldsMap(tranxFieldsMap, TransactionFields, 'cv_pkg_dev_I__Gift__c',isNewPreset);
        if(PaymentFields.size() == 0)
            objBPH.bildFieldsMap(paymentFieldsMap, PaymentFields, 'cv_pkg_dev_I__Payment__c', isNewPreset);
        if(ReceiptFields.size() == 0)
            objBPH.bildFieldsMap(receiptFieldsMap, ReceiptFields, 'cv_pkg_dev_I__Receipt__c', isNewPreset);
        if(GiftDetailFields.size() == 0)
            objBPH.bildFieldsMap(giftDetailFieldsMap, GiftDetailFields, 'cv_pkg_dev_I__Gift_Detail__c', isNewPreset);
/*        if(eventRegFields.size() == 0 && isEventPreset == true)
            objBPH.bildFieldsMap(eventRegFieldsMap, eventRegFields, 'cv_pkg_dev_I__Event_Registration__c', isNewPreset);
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
                                                RecurringGiftFieldsXml__c,TransactionFieldsXml__c,EventRegistrationsFieldsXml__c,Type__c,RecordType.Name FROM Batch_Template__c Where Id =: templateId];

        if(presetTemplate.RecordType.Name == 'Cloned') {
            isCloned = true;
        }
        
        template.Name = presetTemplate.Name;
        template.Type__c = presetTemplate.Type__c;
        
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
            RecurringGiftFields = obj_BPH.readXML(presetTemplate.RecurringGiftFieldsXml__c, 'cv_pkg_dev_I__Recurring_Donation__c');
            obj_BPH.bildFieldsMap(recGiftFieldsMap, RecurringGiftFields, 'cv_pkg_dev_I__Recurring_Donation__c', isNewPreset);
        }
        if(TransactionFields.size() == 0) {
            TransactionFields = obj_BPH.readXML(presetTemplate.TransactionFieldsXml__c, 'cv_pkg_dev_I__Gift__c');
            obj_BPH.bildFieldsMap(tranxFieldsMap, TransactionFields, 'cv_pkg_dev_I__Gift__c', isNewPreset);
        }
        if(PaymentFields.size() == 0) {
            PaymentFields = obj_BPH.readXML(presetTemplate.PaymentFieldsXml__c, 'cv_pkg_dev_I__Payment__c');
            //Get Payment Types Selected.
            paymentTypesSelected = obj_BPH.paymentTypesSelected;
/*            for(String type : obj_BPH.getPaymentTypes().split(',', 0)) {
                if(!paymentTypesSelected.contains(type)) {
                    pymtPickValues.add(type);
                }
            }
*/
            obj_BPH.bildFieldsMap(paymentFieldsMap, PaymentFields, 'cv_pkg_dev_I__Payment__c', isNewPreset);
        }
        if(ReceiptFields.size() == 0) {
            ReceiptFields = obj_BPH.readXML(presetTemplate.ReceiptFieldsXml__c, 'cv_pkg_dev_I__Receipt__c');
            obj_BPH.bildFieldsMap(receiptFieldsMap, ReceiptFields, 'cv_pkg_dev_I__Receipt__c', isNewPreset);
        }
        if(GiftDetailFields.size() == 0) {
            GiftDetailFields = obj_BPH.readXML(presetTemplate.GiftDetailFieldsXml__c, 'cv_pkg_dev_I__Gift_Detail__c');
            obj_BPH.bildFieldsMap(giftDetailFieldsMap, GiftDetailFields, 'cv_pkg_dev_I__Gift_Detail__c', isNewPreset);
        }
/*        if(eventRegFields.size() == 0 && isEventPreset == true) {
            eventRegFields = obj_BPH.readXML(presetTemplate.EventRegistrationsFieldsXml__c, 'cv_pkg_dev_I__Event_Registration__c');
            obj_BPH.bildFieldsMap(eventRegFieldsMap, eventRegFields, 'cv_pkg_dev_I__Event_Registration__c', isNewPreset);
        }
*/        

        templateId = presetTemplate.Id;
        
        return null;
    }
     
    public void addInPreset(){

        isPresetSaved = false;
        
        String objectName = ApexPages.currentPage().getParameters().get('ObjectType');
        if(objectName == 'Contact') {
            if(conSelected.size()>0)
            {
            for(String pwSelected : conSelected){
                conPickValues.remove(pwSelected);
                contactFields.add(contactFieldsMap.get(pwSelected));
                contactFieldsMap.remove(pwSelected);
            }
            }
        }
        else if(objectName == 'Account') {
            if(accSelected.size()>0)
            {
            for(String pwSelected : accSelected){
                accPickValues.remove(pwSelected);
                accountFields.add(accountFieldsMap.get(pwSelected));
                accountFieldsMap.remove(pwSelected);
            }
            }
        }
        else if(objectName == 'cv_pkg_dev_I__Recurring_Donation__c') {
            if(rgfSelected.size()>0)
            {
            for(String pwSelected : rgfSelected){
                rgfPickValues.remove(pwSelected);
                RecurringGiftFields.add(recGiftFieldsMap.get(pwSelected));
                recGiftFieldsMap.remove(pwSelected);
            }
            }
        } 
        else if(objectName == 'cv_pkg_dev_I__Gift__c') {
            if(trnxSelected.size()>0)
            {
            for(String pwSelected : trnxSelected){
                trnxPickValues.remove(pwSelected);
                TransactionFields.add(tranxFieldsMap.get(pwSelected));
                tranxFieldsMap.remove(pwSelected);
            }
            }
        } 
        else if(objectName == 'cv_pkg_dev_I__Payment__c') {
            if(pymtSelected.size()>0)
            {
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
        else if(objectName == 'cv_pkg_dev_I__Receipt__c') {
            if(rcptSelected.size()>0)
            {
            for(String pwSelected : rcptSelected){
                rcptPickValues.remove(pwSelected);
                ReceiptFields.add(receiptFieldsMap.get(pwSelected));
                receiptFieldsMap.remove(pwSelected);
            }
            }
        }
        else if(objectName == 'cv_pkg_dev_I__Gift_Detail__c') {
            if(giftDetailSelected.size()>0)
            {
            for(String pwSelected : giftDetailSelected){
                giftDetailPickValues.remove(pwSelected);
                GiftDetailFields.add(giftDetailFieldsMap.get(pwSelected));
                giftDetailFieldsMap.remove(pwSelected);
            }
            }
        }
/*        else if(objectName == 'cv_pkg_dev_I__Event_Registration__c') {
            for(String pwSelected : eventRegSelected){
                eventRegPickValues.remove(pwSelected);
                eventRegFields.add(eventRegFieldsMap.get(pwSelected));
                eventRegFieldsMap.remove(pwSelected);
            }
        }
*/    }
    
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
/*        else if(objectName == 'cv_pkg_dev_I__Event_Registration__c') {
            pw = eventRegFields[listIndex];
            eventRegPickValues.add(pw.fieldName);
            eventRegFields.remove(listIndex);
            eventRegFieldsMap.put(pw.fieldName, pw);
        }
*/    }
    
    public pageReference saveBatchPreset() {

        if(getPaymentTypePickListOptions().size() < 2) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select at least one Payment Type'));
            return null;
        }

        try {
            
            if(template.Name == null || template.Name == '')
                throw new MyCustomException('Template Name can not be empty.');

            BatchPresetHelper_moc objBPXMLP = new BatchPresetHelper_moc();
            if(templateId != null && templateId != '') {
                Batch_Template__c presetTemplate = [SELECT Id,Name,AccountFieldsXml__c,ContactFieldXml__c,GiftDetailFieldsXml__c,PaymentFieldsXml__c,ReceiptFieldsXml__c,
                                                        RecurringGiftFieldsXml__c,TransactionFieldsXml__c,EventRegistrationsFieldsXml__c,Type__c FROM Batch_Template__c Where Id =: templateId];
                presetTemplate.Name = template.Name;
                presetTemplate.Type__c = template.Type__c;
                presetTemplate.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields, null);
                presetTemplate.ContactFieldXml__c =  objBPXMLP.writeXML('Contact', contactFields, null);
                system.debug('displaying here    '+contactFields);
                presetTemplate.RecurringGiftFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Recurring_Donation__c', RecurringGiftFields, null);
                presetTemplate.TransactionFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Gift__c', TransactionFields, null);
                presetTemplate.PaymentFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Payment__c', PaymentFields, paymentTypesSelected);
                presetTemplate.ReceiptFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Receipt__c', ReceiptFields, null);
                presetTemplate.GiftDetailFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Gift_Detail__c', GiftDetailFields, null);
//                presetTemplate.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Event_Registration__c', eventRegFields);
                
                update presetTemplate;
            }
            else {
                Batch_Template__c obj_BPT = new Batch_Template__c();
                obj_BPT.RecordTypeId = RT.Id;
                obj_BPT.Name = template.Name;
                obj_BPT.Type__c = template.Type__c;
                obj_BPT.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields, null);
                obj_BPT.ContactFieldXml__c =  objBPXMLP.writeXML('Contact', contactFields, null);
                obj_BPT.RecurringGiftFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Recurring_Donation__c', RecurringGiftFields, null);
                obj_BPT.TransactionFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Gift__c', TransactionFields, null);
                obj_BPT.PaymentFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Payment__c', PaymentFields, paymentTypesSelected);
                obj_BPT.ReceiptFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Receipt__c', ReceiptFields, null);
                obj_BPT.GiftDetailFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Gift_Detail__c', GiftDetailFields, null);
                obj_BPT.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML('cv_pkg_dev_I__Event_Registration__c', eventRegFields, null);
                
                insert obj_BPT;
                templateId = obj_BPT.Id;
            }
            
            PageReference pageRef = new PageReference('/apex/EditBatchPreset_moc?id=' + templateId);
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
        
        PageReference pageRef = new PageReference('/apex/EditBatchPreset_moc');
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

    public pageReference createNewBatch() {
        String key = Gift_Batch__c.SObjectType.getDescribe().getKeyPrefix();
//        PageReference pageRef = new PageReference('/apex/BatchProcessingInterface?templateId='+templateId);
        PageReference pageRef = new PageReference('/'+key+'/e');
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