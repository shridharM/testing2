public class BatchPresetHelper_moc {

    Public String paymentTypesSelected = '';
    Public String giftTypePicklistValues = '';
    
    //get SelectOption/picklist values for new/edit batch preset template.
    public List<SelectOption> pickListOptions(Map<String,PresetWrapper> fieldsMap, Set<String> pickValues, Boolean isPayment) {
        
        List<string> tempList = new List<String>();
        List<SelectOption> options = new List<SelectOption>();

        if(pickValues.size() == 0) {
//            pickValues.addAll(getPaymentTypes().split(',', 0));

            pickValues.addAll(fieldsMap.keySet());
            tempList.addAll(pickValues);
//            tempList.sort();
            for(String fieldName : tempList) {
                // Do not add options if the fields are from Payment Type Map.
                if( !(isPayment && getPaymentTypeFields().contains(fieldName)) && fieldsMap.get(fieldName) != null ) {
                    if(fieldsMap.get(fieldName).fieldLable == 'Business Phone') fieldsMap.get(fieldName).fieldLable = 'Phone';
                    options.add(new SelectOption(fieldName, fieldsMap.get(fieldName).fieldLable));
                }
            }
        }
        else {
            tempList.addAll(pickValues);
//            tempList.sort();
            for(String fieldName : tempList) {
                // Do not add options if the fields are from Payment Type Map.
                if( !(isPayment && getPaymentTypeFields().contains(fieldName)) ) {
                    options.add(new SelectOption(fieldName, fieldsMap.get(fieldName).fieldLable));
                }
            }
        }

        return selectOptionSortByLabel(options);
    }

    public String getPaymentTypes() {
        list<Schema.PicklistEntry> values = causeview__Payment__c.causeview__Payment_Type__c.getDescribe().getPickListValues();
        String paymentTypes = '';
        for (Schema.PicklistEntry a : values) { 
            paymentTypes += a.getValue() + ',';
        }

        //return 'Credit Card,Credit Card - Offline,Check,Cash,ACH/PAD,Stock,In Kind,Other,Cheque';
        return paymentTypes;
    }

    public String getPaymentTypeFields() {
        return 'causeview__Credit_Card_Number__c, causeview__Credit_Card_Type__c, causeview__Cheque_Num__c, ' +
               'causeview__Cheque_Date__c, causeview__Date_Deposited__c, causeview__Account_Number__c, ' +
               'causeview__Routing_Branch_Number__c, causeview__Account_Type__c';
    }

    public Map<String, List<String>> getPaymentTypeFieldMap() {
        Map<String, List<String>> paymentTypeFieldMap = new Map<String, List<String>>();
        paymentTypeFieldMap.put('Credit Card', new List<String> {'causeview__Credit_Card_Number__c', 'causeview__Credit_Card_Type__c'});
        //paymentTypeFieldMap.put('Credit Card - Offline', new List<String> {'causeview__Credit_Card_Number__c', 'causeview__Credit_Card_Type__c'}); //madhu cc offline
        paymentTypeFieldMap.put('Credit Card - Offline', new List<String> {'causeview__Date_Deposited__c'});    //madhu cc offline
        paymentTypeFieldMap.put('Check', new List<String> {'causeview__Cheque_Num__c', 'causeview__Cheque_Date__c', 'causeview__Date_Deposited__c'});
        paymentTypeFieldMap.put('Cheque', new List<String> {'causeview__Cheque_Num__c', 'causeview__Cheque_Date__c', 'causeview__Date_Deposited__c'});
        paymentTypeFieldMap.put('Cash', new List<String> {'causeview__Date_Deposited__c'});
        paymentTypeFieldMap.put('Other', new List<String> {'causeview__Date_Deposited__c'});
        paymentTypeFieldMap.put('Stock', new List<String> {'causeview__Date_Deposited__c'});
        paymentTypeFieldMap.put('ACH/PAD', new List<String> {'causeview__Account_Number__c', 'causeview__Account_Type__c', 'causeview__Routing_Branch_Number__c'});
        paymentTypeFieldMap.put('In Kind', new List<String> {'causeview__Date_Deposited__c'});
        paymentTypeFieldMap.put('Property', new List<String> {'causeview__Date_Deposited__c'});
        return paymentTypeFieldMap;
    }
    
    public void bildFieldsMap(Map<String, PresetWrapper> fieldsMap, List<PresetWrapper> dataList, String objectName, Boolean isNewPreset) {
        if(isNewPreset == true) {
            System.debug('####### discribeObjects(objectName) ######' + discribeObjects(objectName));
            System.debug('####### discribeObjects(objectName) ######' + objectName);         
            for(PresetWrapper pw : discribeObjects(objectName)) {
                if(pw.isRequired)
                    dataList.add(pw);
                else
                    fieldsMap.put(pw.fieldName, pw);
            }
        }
        else {
            for(PresetWrapper pw : discribeObjects(objectName))
                fieldsMap.put(pw.fieldName, pw);
            
            for(PresetWrapper edit_pw :dataList)
                fieldsMap.remove(edit_pw.fieldName);
        }
    }
    
    //discribe sObject to get field lable, API Name and create PresetWrapper object
    public List<PresetWrapper> discribeObjects(String sObjectType) {
        
        List<PresetWrapper> PW_List = new List<PresetWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        Set<String> fieldsToExclude = new Set<String>();
        Set<String> requiredFields = new Set<String>();
        if(objSchema.getDescribe().FieldSets.getMap().get('causeview__Fields_To_Exclude_From_Batch_Template') != null) {
            List<Schema.FieldSetMember> fieldSetMemberList = objSchema.getDescribe().FieldSets.getMap().get('causeview__Fields_To_Exclude_From_Batch_Template').getFields();
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                fieldsToExclude.add(fieldSetMemberObj.getFieldPath());
            }
        }
        if(objSchema.getDescribe().FieldSets.getMap().get('causeview__Required_Fields_for_Batch_Templates') != null) {
            List<Schema.FieldSetMember> fieldSetMemberList = objSchema.getDescribe().FieldSets.getMap().get('causeview__Required_Fields_for_Batch_Templates').getFields();
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                requiredFields.add(fieldSetMemberObj.getFieldPath());
            }
        }
        
        for (String fieldName: fieldMap.keySet()) { 
            
            Schema.DescribeFieldResult desribeResult = fieldMap.get(fieldName).getDescribe();

            fieldName = desribeResult.getName();
            
            if(desribeResult.isAccessible() && !desribeResult.isAutoNumber() && !desribeResult.isCalculated() && desribeResult.isCreateable() 
                && !desribeResult.isDeprecatedAndHidden() && fieldName != 'OwnerId' && desribeResult.getLabel() != '(DEPRECATED)') {
            
                if(!(fieldsToExclude.contains(fieldName) || (sObjectType == 'causeview__Solicitor__c'))                                       
                    || (sObjectType == 'causeview__Solicitor__c' && (fieldName == 'causeview__Solicitor__c' || fieldName == 'causeview__Organization_Solicitor__c'
                        || fieldName == 'causeview__Role__c' || fieldName == 'causeview__Custom_Amount__c'))
                    )    //|| (sObjectType == 'causeview__Payment__c' && fieldName == 'causeview__Donation__c') 
                          //|| (sObjectType == 'causeview__Gift_Detail__c' && (fieldName == 'causeview__Gift__c' || fieldName == 'causeview__Payment__c')                      
                          //|| (sObjectType == 'causeview__Solicitor__c'))|| (sObjectType == 'causeview__Recurring_Donation__c' && fieldName == 'causeview__of_Payments__c') 
                {
                    PresetWrapper pw = new PresetWrapper(objSchema);
                    pw.fieldLable = desribeResult.getLabel();
                    pw.fieldName = fieldName;
                    pw.fieldType = String.valueOf(desribeResult.getType());
                    pw.fieldValue = null;
                    pw.isHidden = false;
                    pw.isReadOnly = false;
                    pw.isForSummary = false;
                    if(desribeResult.isCreateable() && !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate())
                        pw.isRequired = true;
                    else
                        pw.isRequired = false;

                    //Payment Type Field Mappings.
                        //Make Payment Type field as required and summary.
                    if(pw.fieldName == 'causeview__Payment_Type__c') {
//                        pw.isRequired = true;
                        pw.isForSummary = true;
                    }
                    //Make Payment Amount field required.
                    if(sObjectType == 'causeview__Payment__c' && pw.fieldName == 'causeview__Amount__c') {
//                        pw.isRequired = true;
                    }

                    if(requiredFields.contains(pw.fieldName)) {
                        pw.isRequired = true;
                    }
                    
                    system.debug('Nitin FirstName'+pw.fieldName);

                    //Populate picklist values if field type is picklist
                    if(pw.fieldType == 'PICKLIST' || pw.fieldType == 'MULTIPICKLIST') {
                        list<Schema.PicklistEntry> values = fieldMap.get(pw.fieldName).getDescribe().getPickListValues();
                        for (Schema.PicklistEntry a : values) { 
                            pw.picklistValues.add(a.getValue());
                        }
                    }

                    
                    PW_List.add(pw);
                }
            }
        }
        
        return PW_List;  
    }
    
    //Convert PresetWrapper object information into XML to store template information.
    public String writeXML(String ObjectType, List<PresetWrapper> dataToWrite, String paymentTypesSelected) {
        
        XmlStreamWriter w = new XmlStreamWriter();
        
        w.writeStartElement(null, ObjectType, null);
        // Write Payment Types selected.
        if(paymentTypesSelected != null) {
            w.writeAttribute(null, null, 'PTypes', paymentTypesSelected);
        }
        // Write Gift Type Picklist Values
            system.debug('##########    giftTypePicklistValues 1    #############' + giftTypePicklistValues);
        if(ObjectType == 'causeview__Gift__c' && giftTypePicklistValues != null) {
            system.debug('##########    giftTypePicklistValues 2    #############' + giftTypePicklistValues);
            w.writeAttribute(null, null, 'GiftTypes', giftTypePicklistValues);
        }
        for(PresetWrapper obj_PW : dataToWrite) {
            
            if(obj_PW.sObjectType.get(obj_PW.fieldName) == null && obj_PW.isReadOnly == true)
                throw new PresetWrapper.MyCustomException('You can not make field as Read Only without default value. Please assign default value to '+obj_PW.fieldLable);
            
            w.writeStartElement(null, 'fields', null);
            w.writeAttribute(null, null, 'Lable', obj_PW.fieldLable);
            w.writeAttribute(null, null, 'Name', obj_PW.fieldName);
            w.writeAttribute(null, null, 'Type', obj_PW.fieldType);
            
            if(obj_PW.sObjectType.get(obj_PW.fieldName) != null)
                w.writeAttribute(null, null, 'Value', String.valueOf(obj_PW.sObjectType.get(obj_PW.fieldName)));
            else
                w.writeAttribute(null, null, 'Value', 'null');
            
            w.writeAttribute(null, null, 'isHidden', String.valueOf(obj_PW.isHidden));
            w.writeAttribute(null, null, 'ReadOnly', String.valueOf(obj_PW.isReadOnly));
            w.writeAttribute(null, null, 'Req', String.valueOf(obj_PW.isRequired));
            w.writeAttribute(null, null, 'Summ', String.valueOf(obj_PW.isForSummary));
            w.writeEndElement(); //end fields
        }
        w.writeEndElement(); //end objectType
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        
        return xmlOutput;
    }
    
    //Read and convert stored template information from XML to PresetWrapper objects.
    public List<PresetWrapper> readXML(String xmlString, String sObjectType) {
        
        List<PresetWrapper> presetDataList = new List<PresetWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(sObjectType);

        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
        
        XmlStreamReader reader = new XmlStreamReader(xmlString);
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                // Read Payment Types selected.
                if(sObjectType == 'causeview__Payment__c' && reader.getLocalName() == 'causeview__Payment__c') {
                    paymentTypesSelected = reader.getAttributeValue(null, 'PTypes');
                }
                // Read Gift Type Picklist Values
                if(sObjectType == 'causeview__Gift__c' && reader.getLocalName() == 'causeview__Gift__c') {
                    giftTypePicklistValues = reader.getAttributeValue(null, 'GiftTypes');
                    system.debug('##########    giftTypePicklistValues 3   #############' + giftTypePicklistValues);
                }
                if (reader.getLocalName() == 'fields') {
                    
                    PresetWrapper pw = new PresetWrapper(objSchema);
                    
                    pw.fieldLable = reader.getAttributeValue(null, 'Lable');
                    pw.fieldName = reader.getAttributeValue(null, 'Name');
                    pw.fieldType = reader.getAttributeValue(null, 'Type');
                    if(reader.getAttributeValue(null, 'Value') != 'null')
                        pw.fieldValue = reader.getAttributeValue(null, 'Value');
                    else
                        pw.fieldValue = null;
                    
                    if(pw.fieldValue != null && pw.fieldValue != 'null') {
                        if(pw.fieldType == 'BOOLEAN')
                            pw.sObjectType.put(pw.fieldName, Boolean.valueOf(pw.fieldValue));
                        else if(pw.fieldType == 'DOUBLE' || pw.fieldType == 'CURRENCY' || pw.fieldType == 'PERCENT')
                            pw.sObjectType.put(pw.fieldName, Double.valueOf(pw.fieldValue));
                        else if(pw.fieldType == 'DATE')
                            pw.sObjectType.put(pw.fieldName, convertDate(pw.fieldValue));
                        else if(pw.fieldType == 'DATETIME')
                            pw.sObjectType.put(pw.fieldName, DateTime.valueofGmt(pw.fieldValue));
                        else if(pw.fieldType == 'INTEGER')
                            pw.sObjectType.put(pw.fieldName, Integer.valueOf(pw.fieldValue));
                        else {
                        System.debug('#########    pw.fieldName    ##########' + pw.fieldName);
                        System.debug('#########    pw.fieldValue    ##########' + pw.fieldValue);
                        System.debug('#########    pw.fieldType    ##########' + pw.fieldType);
                            pw.sObjectType.put(pw.fieldName, pw.fieldValue);
                        }
                    }
                    else
                        pw.sObjectType.put(pw.fieldName, pw.fieldValue);
                        
                    pw.isHidden = Boolean.valueOf(reader.getAttributeValue(null, 'isHidden'));
                    pw.isReadOnly = Boolean.valueOf(reader.getAttributeValue(null, 'ReadOnly'));
                    pw.isRequired = Boolean.valueOf(reader.getAttributeValue(null, 'Req'));
                    pw.isForSummary = Boolean.valueOf(reader.getAttributeValue(null, 'Summ'));
                    
                    //Populate picklist values if field type is picklist
                    if(pw.fieldType == 'PICKLIST' || pw.fieldType == 'MULTIPICKLIST') {
                        list<Schema.PicklistEntry> values = fieldMap.get(pw.fieldName).getDescribe().getPickListValues();
                        for (Schema.PicklistEntry a : values) { 
                            pw.picklistValues.add(a.getValue());
                            /*if(!(pw.fieldName == 'causeview__Gift_Type__c' && (a.getValue() == 'Event Registration' || a.getValue() == 'Product Sale' || a.getValue() =='Grant'))){    //added by nitin
                            }*/
                        }
                    }
                    
                    if(pw.fieldName == 'causeview__Gift_Type__c' && giftTypePicklistValues != null) {
                        pw.picklistValues.clear();
                        for(String val : giftTypePicklistValues.split('~`~', 0)) {
                            if(val != '') {
                                pw.picklistValues.add(val);
                            }
                        }
                    }

                    presetDataList.add(pw);
                } 
            }
            reader.next();
        }
        
        return presetDataList;
    }
    
    //Convert date string in date instance.
    public Date convertDate(string stringDate) {
        
        String[] strDateDivided = stringDate.split(' ');
        strDateDivided = strDateDivided[0].split('-');
        
        Integer year = Integer.ValueOf(strDateDivided[0]);
        Integer month = Integer.ValueOf(strDateDivided[1]);
        Integer day = Integer.ValueOf(strDateDivided[2]);
        
        return date.newinstance(year, month, day);
    }
    
    //Sort picklist option by field's label.
    public list<selectOption> selectOptionSortByLabel(list<selectOption> selectOptionsToSort) {
        
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1)
            return selectOptionsToSort;
        
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
        
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort) {
            if(SO.getLabel() <= pivotValue.getLabel()) {
                lessSelectOption.add(SO);
            }
            else if(SO.getLabel() > pivotValue.getLabel()) {
                greaterSelectOption.add(SO);   
            }
        }
        
        list<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        
        return SortedSelectOptions;
    }
    
}
