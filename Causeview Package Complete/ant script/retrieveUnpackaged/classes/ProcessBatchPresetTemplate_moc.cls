public with sharing class ProcessBatchPresetTemplate_moc {
    
    public static Map<string,map<string,string>> readAndProcessTemplate(Id templateId){
        Batch_Template__c template = [Select b.Type__c, b.TransactionFieldsXml__c, b.RecurringGiftFieldsXml__c, b.ReceiptFieldsXml__c, 
                                            b.PaymentFieldsXml__c, b.GiftDetailFieldsXml__c, b.EventRegistrationsFieldsXml__c, 
                                            b.ContactFieldXml__c, b.AccountFieldsXml__c From Batch_Template__c b where id= :templateId];
                                            
        Map<string,map<string,string>> templateMap = new Map<string,map<string,string>>();
        if(template.ContactFieldXml__c != null){
            map<string,string> contactMap = createMap(template.ContactFieldXml__c);
            if(!contactMap.isEmpty()) templateMap.put('Contact',contactMap);
        }
        if(template.AccountFieldsXml__c != null){
            map<string,string> accountMap = createMap(template.AccountFieldsXml__c);
            if(!accountMap.isEmpty()) templateMap.put('Account',accountMap);
        }
        if(template.TransactionFieldsXml__c != null){
            map<string,string> transactionMap = createMap(template.TransactionFieldsXml__c);
            if(!transactionMap.isEmpty()) templateMap.put('cv_pkg_dev_I__Gift__c',transactionMap);
        }
        if(template.RecurringGiftFieldsXml__c != null){
            map<string,string> recurringGiftMap = createMap(template.RecurringGiftFieldsXml__c);
            if(!recurringGiftMap.isEmpty()) templateMap.put('cv_pkg_dev_I__Recurring_Donation__c',recurringGiftMap);
        }
        if(template.PaymentFieldsXml__c != null){
            map<string,string> paymentMap = createMap(template.PaymentFieldsXml__c);
            if(!paymentMap.isEmpty()) templateMap.put('cv_pkg_dev_I__Payment__c',paymentMap);
        }
        if(template.ReceiptFieldsXml__c != null){
            map<string,string> receiptMap = createMap(template.ReceiptFieldsXml__c);
            if(!receiptMap.isEmpty()) templateMap.put('cv_pkg_dev_I__Receipt__c',receiptMap);
        }
        if(template.GiftDetailFieldsXml__c != null){
            map<string,string> giftDetailMap = createMap(template.GiftDetailFieldsXml__c);
            if(!giftDetailMap.isEmpty()) templateMap.put('cv_pkg_dev_I__Gift_Detail__c',giftDetailMap);
        }
        if(template.EventRegistrationsFieldsXml__c != null){
            map<string,string> eventRegistrationsMap = createMap(template.EventRegistrationsFieldsXml__c);
            if(!eventRegistrationsMap.isEmpty()) templateMap.put('cv_pkg_dev_I__Event_Registration__c',eventRegistrationsMap);
        }
        
        System.debug('templateMap---------'+templateMap);
        return templateMap;
    }
    
    static map<string,string> createMap(string strXML){
        map<string,string> objMap = new map<string,string>(); 
        XmlStreamReader xmlReader = new XmlStreamReader(strXML);
        while(xmlReader.hasNext()) {
            if (xmlReader.getEventType() == XmlTag.START_ELEMENT) {
                if (xmlReader.getLocalName() == 'fields') {
                    //System.debug('value------ '+xmlReader.getAttributeValue(null,'Summ'));
                    if(xmlReader.getAttributeValue(null,'Summ') == 'true'){
                        string fieldLabel = xmlReader.getAttributeValue(null,'Lable');
                        string fieldName = xmlReader.getAttributeValue(null,'Name');
                        if(xmlReader.getAttributeValue(null,'Type') == 'REFERENCE'){
                            fieldName = fieldName+'-REF';
                        }
                        System.debug('fieldLabel---------fieldName-----'+fieldLabel+'    '+fieldName);
                        objMap.put(fieldLabel,fieldName);
                        
                    }
                }
            }
            xmlReader.next();
        }
        System.debug('objMap-------'+objMap);
        return objMap;
    }
}