public with sharing class BatchTransactionsController_moc {
    public cv_pkg_dev_I__Gift_Batch__c causeViewGiftBatch {get;set;}
    public List<cv_pkg_dev_I__Gift__c> giftList {get;set;}
    public Map<id,List<string>> transactionFieldmap {get;set;}
    public List<string> transactionColumnList {get;set;}
    public List<Selectoption> selOptionList {get;set;}
    public string selOptionValue {get;set;}
    public BatchReconciliation Recon{get;set;}
    public Boolean isCommitedBatch{get;set;}
    
    List<string> strList;
    Map<string,map<string,string>> BatchPresetTemplateMap;
    List<string> columnList;
    List<string> objNameList;
    Map<id,List<string>> objFieldAndValueMap;
    List<string> contactFieldKeyValuesList;
    Map<id,string> objIdAndFieldValueMap;
    Map<String, Schema.SObjectType> allObjDescribedInfo = Schema.getGlobalDescribe();
    Map<string,string> checkFieldTypeAndReturnRelationshipMap = new Map<string,string>(); 
    Map<string,string> checkObjectFieldTypeMap = new Map<string,string>();
    string mainQry = 'Select ';
    String recordId;
    
    public BatchTransactionsController_moc(ApexPages.StandardController std){
        //string recordId = Apexpages.currentPage().getParameters().get('id');
        System.debug('std---------'+std.getId());
        giftList = new List<cv_pkg_dev_I__Gift__c>();
        isCommitedBatch = false;
        recordId = std.getId();
        System.debug('recordId-------------'+recordId);         
        if(recordId == null)return;
        selOptionValue = 'All';
        selOptionList = new List<Selectoption>{new Selectoption('All','All Gifts'),new Selectoption('Pending','Pending'),new Selectoption('Failed','Failed')};
        setUp(recordId);
        updateReconciliation();
        
        System.debug('limit----getScriptStatements--stmts----'+Limits.getScriptStatements());
    }
    
    public void createCauseViewGiftBatchList(){
        System.debug('recordId--------'+recordId+'     '+selOptionValue);
        setUp(recordId);
    }
    public void setUp(string recordId){
        mainQry = 'Select ';
        List<cv_pkg_dev_I__Gift_Batch__c> causeViewGiftBatchList = [Select c.Template_Name__r.Name, c.Template_Name__c, c.cv_pkg_dev_I__Cash_Gifts__c, c.cv_pkg_dev_I__Cash__c, c.cv_pkg_dev_I__Cheque_Gifts__c, c.cv_pkg_dev_I__Cheque__c, c.cv_pkg_dev_I__Credit_Card_Gifts__c, c.cv_pkg_dev_I__Credit_Card__c, c.cv_pkg_dev_I__Direct_Deposit_Gifts__c, c.cv_pkg_dev_I__Direct_Deposit__c, c.cv_pkg_dev_I__Other_Gifts__c, c.cv_pkg_dev_I__Other__c, c.cv_pkg_dev_I__Total_Gift__c, c.cv_pkg_dev_I__Total_Gift_Amount__c, c.cv_pkg_dev_I__Shareplan__c, c.Name, c.cv_pkg_dev_I__Open_Date__c, c.cv_pkg_dev_I__Name__c, c.cv_pkg_dev_I__Close_Date__c, c.cv_pkg_dev_I__Shareplan_Gifts__c From cv_pkg_dev_I__Gift_Batch__c c where id = :recordId];
        System.debug('causeViewGiftBatchList-------------'+causeViewGiftBatchList);         
        if(!causeViewGiftBatchList.isEmpty()) {
            causeViewGiftBatch = causeViewGiftBatchList[0];
            System.debug('causeViewGiftBatch--Template_Name__c-------------'+causeViewGiftBatch.Template_Name__c);
            if(causeViewGiftBatch.Template_Name__c != null) {
                BatchPresetTemplateMap = ProcessBatchPresetTemplate_moc.readAndProcessTemplate(causeViewGiftBatch.Template_Name__c);
                if(BatchPresetTemplateMap == null || BatchPresetTemplateMap.isEmpty()) return;
                createObjectFieldTypeMap(BatchPresetTemplateMap);
                System.debug('BatchPresetTemplateMap--------- '+BatchPresetTemplateMap.keySet());
                string giftTransactionQuery ;
                giftTransactionQuery = buildQryStr(BatchPresetTemplateMap);
                System.debug('giftTransactionQuery--------- '+giftTransactionQuery);
                if(giftTransactionQuery != null && giftTransactionQuery != ''){
                    giftList = Database.query(giftTransactionQuery);
                    System.debug('giftList--------- '+giftList.size()+'      '+giftList);
                    if(!giftList.isEmpty()){
                        createTransactionList(giftList);
                        System.debug('transactionColumnList------------'+transactionColumnList);
                    }
                }
            }
        }
    }
    void createQueryStr(string objType, string str,string fieldQueryName){
        System.debug('str-----fieldQueryName-----'+str+'      '+fieldQueryName);
        map<string,string> contactMap = BatchPresetTemplateMap.get(str);
        System.debug('contactMap.keySet-------------------'+contactMap.keySet());
        if(!contactMap.isEmpty()){
            columnList.addAll(contactMap.keySet());
            string childQryStr;
            if(objType == 'child') childQryStr = '(Select ';
            for(string strField : contactMap.keySet()){
                if(contactMap.get(strField).endsWith('-REF')){
                    string strFieldVal = checkFieldTypeAndReturnRelationshipMap.get(str+'-'+contactMap.get(strField).removeEnd('-REF'));
                    System.debug('strFieldVal-----------strFieldVal2------'+strFieldVal);
                    if(strFieldVal != null){
                        if(objType == 'self'){
                            mainQry += strFieldVal +',';
                        }else if(objType == 'child'){
                            childQryStr += strFieldVal +',';    
                        }else if(objType == 'parent'){
                            mainQry = mainQry + fieldQueryName+'.' + strFieldVal + ','; 
                        }
                    }
                }else{
                    if(objType == 'self'){
                        mainQry += contactMap.get(strField)+ ',';
                    }else if(objType == 'child'){
                        childQryStr += contactMap.get(strField) + ',';
                    }else if(objType == 'parent'){
                        mainQry = mainQry + fieldQueryName+'.' + contactMap.get(strField) + ',';
                    }
                }
            }
            if(objType == 'child') {
                childQryStr = childQryStr.removeEnd(',') + ' From '+fieldQueryName+' limit 1)'+ ',';
                mainQry = mainQry + childQryStr;
            }
        }
    }
    
    void createObjectFieldTypeMap(Map<string,map<string,string>> BatchPresetTemplateMap){
        for(string objName : BatchPresetTemplateMap.keySet()){
            Map<string,string> fieldMap = BatchPresetTemplateMap.get(objName);
            if(fieldMap != null && !fieldMap.isEmpty()){
                Schema.SObjectType targetType = allObjDescribedInfo.get(objName);
                Schema.DescribeSObjectResult r = targetType.getDescribe();
                for(string strfieldName : fieldMap.keySet()){
                    System.debug('fieldName------hhhhh------'+fieldMap.get(strfieldName));
                    string fieldName = fieldMap.get(strfieldName);
                    if(fieldName.endsWith('-REF')) fieldName = fieldName.removeEnd('-REF');
                    Schema.SObjectField field = r.fields.getMap().get(fieldName);
                    Schema.DescribeFieldResult F = field.getDescribe();
                    string str = F.getRelationshipName();
                    string fieldType = string.valueOf(F.gettype());
                    System.debug('str-----------'+str+'    '+fieldType);
                    if(fieldType == 'Reference'){
                        checkFieldTypeAndReturnRelationshipMap.put(objName+'-'+fieldname,str+'.name');
                    }
                    checkObjectFieldTypeMap.put(objName+'-'+fieldname,fieldType);
                }
            } 
        }       
    }
    string buildQryStr(Map<string,map<string,string>> BatchPresetTemplateMap){
        columnList = new List<string>();
        for(string str : BatchPresetTemplateMap.keySet()){
            if(str == 'Contact')createQueryStr('parent','Contact','cv_pkg_dev_I__Constituent__r');
            if(str == 'Account')createQueryStr('parent','Account','cv_pkg_dev_I__Organization__r');
            if(str == 'cv_pkg_dev_I__Gift__c')createQueryStr('self','cv_pkg_dev_I__Gift__c','');
            if(str == 'cv_pkg_dev_I__Recurring_Donation__c')createQueryStr('parent','cv_pkg_dev_I__Recurring_Donation__c','cv_pkg_dev_I__Recurring_Donation__r');
            if(str == 'cv_pkg_dev_I__Payment__c')createQueryStr('child','cv_pkg_dev_I__Payment__c','cv_pkg_dev_I__Recurring_Payments__r');
            if(str == 'cv_pkg_dev_I__Receipt__c')createQueryStr('child','cv_pkg_dev_I__Receipt__c','cv_pkg_dev_I__Receipts__r');
            if(str == 'cv_pkg_dev_I__Gift_Detail__c')createQueryStr('child','cv_pkg_dev_I__Gift_Detail__c','cv_pkg_dev_I__Gift_Allocations__r');
            if(str == 'cv_pkg_dev_I__Event_Registration__c')createQueryStr('child','cv_pkg_dev_I__Event_Registration__c','cv_pkg_dev_I__Event_Registrations__r');
        }
        mainQry = mainQry.removeEnd(',');
        mainQry = mainQry + ' from cv_pkg_dev_I__Gift__c where cv_pkg_dev_I__GiftBatch__c = '+'\''+causeViewGiftBatch.id+'\'';
        //mainQry = mainQry + ' AND id = \'a0Mi0000000v8ogEAA\'';
        selOptionList = new List<Selectoption>{new Selectoption('All','All Gifts'),new Selectoption('Pending','Pending'),new Selectoption('Failed','Failed')};
        if(selOptionValue != 'All'){
            mainQry = mainQry + ' AND cv_pkg_dev_I__Batch_Status__c = '+'\''+selOptionValue+'\'';
        }
        System.debug('mainQry--------- '+mainQry);
        System.debug('columnList--------- '+columnList);
        System.debug('limit----getFieldSetsDescribes--stmts---- '+Limits.getFieldsDescribes());
        return mainQry;
    }
    void createObjRecordList(string objType, string objName, string objFieldName, cv_pkg_dev_I__Gift__c gift){
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        List<sobject> paymentList;
        if(objType == 'child'){
            paymentList = gift.getSObjects(objFieldName);
        }   
            if(BatchPresetTemplateMap.get(objName) != null){
            for(string str2 : BatchPresetTemplateMap.get(objName).keySet()){
                string fieldName = BatchPresetTemplateMap.get(objName).get(str2).removeEnd('-REF');
                if(fieldName == null || checkObjectFieldTypeMap.get(objName+'-'+fieldName) == null )continue;
                string fieldType = checkObjectFieldTypeMap.get(objName+'-'+fieldName);
                
                System.debug('fieldType-----------'+fieldType);
                string stv;
                if(BatchPresetTemplateMap.get(objName).get(str2) != null) {
                    if(fieldType == 'Date' || fieldType == 'DateTime'){
                        Date stvDateValue;
                        if(objType == 'self'){
                            stvDateValue = (Date)gift.get(BatchPresetTemplateMap.get(objName).get(str2));
                        }else if(objType == 'child' && paymentList !=null && !paymentList.isEmpty()){
                            stvDateValue = (Date)((SObject)paymentList[0]).get(BatchPresetTemplateMap.get(objName).get(str2));
                        }else if(objType == 'parent'){
                            if(gift.getSObject(objFieldName) != null) stvDateValue = (Date)gift.getSObject(objFieldName).get(BatchPresetTemplateMap.get(objName).get(str2));
                        }
                        System.debug('stvDateValue-------'+stvDateValue);
                        if(stvDateValue != null) stv = (String.valueOf(stvDateValue.day()).length() == 2 ? String.valueOf(stvDateValue.day()) : '0'+stvDateValue.day()) + '/'+(String.valueOf(stvDateValue.month()).length() == 2 ? String.valueOf(stvDateValue.month()) : '0'+stvDateValue.month())+'/'+stvDateValue.year();
                    }else if(fieldType == 'REFERENCE'){
                        string strQry = checkFieldTypeAndReturnRelationshipMap.get(objName+'-'+fieldName);
                        System.debug('strQry----------------'+strQry);
                        if(objType == 'self'){
                            if(gift.getSobject(strQry.removeEnd('.name')) != null){
                                stv = string.valueOf(gift.getSobject(strQry.removeEnd('.name')).get('name'));
                            }
                        }else if(objType == 'child' && paymentList !=null && !paymentList.isEmpty()){
                            if(gift.getSObjects(objFieldName)[0].get(fieldName) != null){
                                stv = string.valueOf((gift.getSObjects(objFieldName)[0]).getSobject(strQry.removeEnd('.name')).get('name'));    
                            }
                        }else if(objType == 'parent'){
                            if(gift.getSObject(objFieldName)!= null && gift.getSobject(objFieldName).get(fieldName) != null){
                                stv = string.valueOf((gift.getSobject(objFieldName)).getSobject(strQry.removeEnd('.name')).get('name'));
                            }
                        }
                    }else{
                        if(objType == 'self'){
                            stv = String.valueOf(gift.get(BatchPresetTemplateMap.get(objName).get(str2)));
                        }else if(objType == 'child' && paymentList !=null && !paymentList.isEmpty()){
                            stv = String.valueOf(((SObject)paymentList[0]).get(BatchPresetTemplateMap.get(objName).get(str2)));
                        }else if(objType == 'parent'){
                            System.debug('objRec-------'+gift.getSObject(objFieldName));
                            if(gift.getSObject(objFieldName)!= null) stv = String.valueOf(gift.getSObject(objFieldName).get(BatchPresetTemplateMap.get(objName).get(str2)));
                        }
                    }
                }
                System.debug('stv--------'+stv);
                transactionColumnList.add(str2);
                if(stv != null && stv != ''){strList.add(stv);}
                else{strList.add('&nbsp;');}
            }
        }
    }
    public void createTransactionList(List<cv_pkg_dev_I__Gift__c> giftList){
        transactionFieldmap = new Map<id,List<string>>();
        System.debug('kkk--BatchPresetTemplateMap--'+BatchPresetTemplateMap);
        System.debug('limit----getFieldSetsDescribes--stmts---- '+Limits.getFieldsDescribes());
        for(cv_pkg_dev_I__Gift__c gift : giftList){
            System.debug('gift---id------'+gift.id);
            strList = new List<string>();
            transactionColumnList = new List<string>();
            if(BatchPresetTemplateMap.get('Contact') != null){
                createObjRecordList('parent','Contact', 'cv_pkg_dev_I__Constituent__r',gift);
            }
            if(BatchPresetTemplateMap.get('Account') != null){
                createObjRecordList('parent','Account', 'cv_pkg_dev_I__Organization__r',gift);
            }
            if(BatchPresetTemplateMap.get('cv_pkg_dev_I__Gift__c') != null){
                createObjRecordList('self','cv_pkg_dev_I__Gift__c', '',gift);
            }
            if(BatchPresetTemplateMap.get('cv_pkg_dev_I__Payment__c') != null){
                createObjRecordList('child','cv_pkg_dev_I__Payment__c', 'cv_pkg_dev_I__Recurring_Payments__r',gift);
            }
            if(BatchPresetTemplateMap.get('cv_pkg_dev_I__Recurring_Donation__c') != null){
                createObjRecordList('parent','cv_pkg_dev_I__Recurring_Donation__c', 'cv_pkg_dev_I__Recurring_Donation__r',gift);
            }
            if(BatchPresetTemplateMap.get('cv_pkg_dev_I__Receipt__c') != null){
                createObjRecordList('child','cv_pkg_dev_I__Receipt__c', 'cv_pkg_dev_I__Receipts__r',gift);
            }
            if(BatchPresetTemplateMap.get('cv_pkg_dev_I__Gift_Detail__c') != null){
                createObjRecordList('child','cv_pkg_dev_I__Gift_Detail__c', 'cv_pkg_dev_I__Gift_Allocations__r',gift);
            }
            if(BatchPresetTemplateMap.get('cv_pkg_dev_I__Event_Registration__c') != null){
                createObjRecordList('child','cv_pkg_dev_I__Event_Registration__c', 'cv_pkg_dev_I__Event_Registrations__r',gift);
            }
            transactionFieldmap.put(gift.id,strList);
        }
        System.debug('limit----getFieldSetsDescribes--stmts------ '+Limits.getFieldsDescribes());
    }
    
    public Pagereference editRec(){
        string transactionRecordId = Apexpages.currentPage().getParameters().get('transctionRecId');
        if(transactionRecordId != null) {
            Pagereference pg = new Pagereference('/apex/causeViewGiftBatchEdit_moc?id='+transactionRecordId);
            pg.setRedirect(false);
            return pg;
        }
        return null;    
    }
    
    public pageReference commitBatch() {
        List<cv_pkg_dev_I__Gift__c> gifts = [Select Id, Name, cv_pkg_dev_I__Batch_Status__c, cv_pkg_dev_I__Gift_Type__c From cv_pkg_dev_I__Gift__c Where cv_pkg_dev_I__GiftBatch__c =: recordId];
        for(cv_pkg_dev_I__Gift__c gift : gifts) {
            if(gift.cv_pkg_dev_I__Gift_Type__c == 'Recurring')
                gift.cv_pkg_dev_I__Batch_Status__c = 'Receipted';
            else
                gift.cv_pkg_dev_I__Batch_Status__c = 'Committed';
        }
        update gifts;
        updateReconciliation();
        
        return null;
    }
    
    public void updateReconciliation() {
       if (giftList == null || giftList.size() <= 0)
         return;
       
       Recon = new BatchReconciliation(); 
       for(cv_pkg_dev_I__Gift__c gift : [Select Id, Name, cv_pkg_dev_I__Batch_Status__c, cv_pkg_dev_I__Expected_Amount__c, cv_pkg_dev_I__Gift_Type__c, (Select Id, cv_pkg_dev_I__Payment_Type__c From cv_pkg_dev_I__Recurring_Payments__r) From cv_pkg_dev_I__Gift__c Where cv_pkg_dev_I__GiftBatch__c =: recordId]) {
          
          if (gift.cv_pkg_dev_I__Recurring_Payments__r.size() == 0)
            continue;
           
           if(gift.cv_pkg_dev_I__Batch_Status__c == 'Committed' || gift.cv_pkg_dev_I__Batch_Status__c == 'Receipted')
               isCommitedBatch = true;
               
           Recon.totalCount++;
           string paymentType = gift.cv_pkg_dev_I__Recurring_Payments__r[0].cv_pkg_dev_I__Payment_Type__c;
           Decimal paymentAmount = (gift.cv_pkg_dev_I__Expected_Amount__c==null)? 0 : gift.cv_pkg_dev_I__Expected_Amount__c;
           
           if (gift.cv_pkg_dev_I__Gift_Type__c == 'Recurring') {
              Recon.sharePlanCount += 1;
              Recon.ShareplanTotal += paymentAmount;
           }
           else
           {
           
               if (paymentType == 'Cash')
                    Recon.cashTotal += paymentAmount;
               else 
               if (paymentType == 'Credit Card') {
                   Recon.creditCardTotal += paymentAmount;
                   if (gift.cv_pkg_dev_I__Batch_Status__c == 'Committed' || gift.cv_pkg_dev_I__Batch_Status__c == 'Receipted')
                        Recon.ccApprovedCount += 1;
                   else if (gift.cv_pkg_dev_I__Batch_Status__c == 'Failed')
                        Recon.ccDeclinedCount += 1;
                }
                else if (paymentType == 'Check')
                   Recon.chequeTotal += paymentAmount;
                else
                   Recon.OtherTotal += paymentAmount;
                     
                 if (paymentType != 'PAD')       
                     Recon.grandTotal += paymentAmount;
           }
           
           if (paymentType == 'Credit Card' 
             && gift.cv_pkg_dev_I__Batch_Status__c == 'Pending' && (gift.cv_pkg_dev_I__Gift_Type__c != 'Recurring') ) {
                 Recon.ccPendingCount += 1;
                 Recon.creditCardTotalPending += paymentAmount;
              
           }   
       }
    }

    public pageReference createNewBatch() {
        PageReference pageRef = new PageReference('/apex/BatchProcessingInterface?batchId='+causeViewGiftBatch.Id);
        pageRef.setRedirect(true);
        return pageRef;    
    }

    public class BatchReconciliation {
        public Decimal cashTotal { get; set; }
        public Decimal chequeTotal { get; set; }
        public Decimal creditCardTotal { get; set; }
        public Decimal creditCardTotalPending { get; set; }
        public Decimal ShareplanTotal { get; set; }
        public Decimal DirectDipositTotal { get; set; }
        public Decimal OtherTotal { get; set; }
        public Decimal grandTotal { get; set; }
        
        public Integer sharePlanCount { get; set; }
        public Integer ccApprovedCount { get; set; }
        public Integer ccDeclinedCount { get; set; }
        public Integer ccPendingCount { get; set; }
        public integer totalCount { get; set; }
        
        public BatchReconciliation() {
            cashTotal = 0.00;
            chequeTotal = 0.00;
            creditCardTotal = 0.00;
            creditCardTotalPending = 0.00;
            grandTotal = 0.00;
            sharePlanCount = 0;
            ccApprovedCount = 0;
            ccDeclinedCount = 0;
            ccPendingCount = 0;
            ShareplanTotal =0.00;
            DirectDipositTotal = 0.00;
            OtherTotal = 0.00;
            totalCount = 0;
        }
    }
}