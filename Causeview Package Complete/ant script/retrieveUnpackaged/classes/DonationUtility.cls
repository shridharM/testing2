public class DonationUtility
{ 
   public static Boolean fieldTypeBoolean;
   public static  Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
   public static string MergeDocument(string documentId, 
     string relatedToType, 
     string relatedToId,
     string recipientType,
     string recipientId)
   {
      string retVal = '';

      // load document
      string docId = '';
      docId = documentId;
      system.debug('Nitin docId====='+documentId);
      Document doc = null;
      if (docId != null && docId != '')
      {
          List<Document> docs = [Select d.Type, d.ContentType, d.BodyLength, d.Body From Document d WHERE Id = :docId];
          if (docs != null && docs.size()>0)
           {
              doc = docs[0];
           }
      }

      if (doc != null) {
       retVal = doc.Body.toString();
       system.debug('Nitin retVal===='+retVal);
       retVal = removeScriptBlocks(retVal);
      }
      
      // merge fields
      retVal = mergeFields(retVal,relatedToType,relatedToId,recipientType,recipientId);
        system.debug('Nitin relatedToId==='+relatedToId);
        system.debug('Nitin retVal==='+retVal);
        //Populate Payment Date.
      if(relatedToType == 'Receipt__c')
          retVal = addPaymentsTableView(retVal,relatedToId);  

      //return
      return retVal;
    }

    //Retrieve Receipt related Payment data and add to the Document.
    Private static String addPaymentsTableView(String retVal, String relatedToId)
    {
        //If the document contains string '{!receiptPayments}', it is replaced with the payement(s) related to the Receipt.
        String pattern = '{!receiptPayments';
        Integer start = retVal.indexOf(pattern);
        system.debug('Nitin start==='+start);
        if(start > -1) {
            Integer end1 = retVal.indexOf('}', start);
            if(end1 > -1) {

                List<List<String>> headerTypeFieldList = new List<List<String>>();
                List<String> allocationFields = new List<String>();
                List<String> paymentFields = new List<String>();
    
                String toReplace = pattern + retVal.substringBetween(pattern, '}');
                String[] fields = toReplace.substringAfter(pattern).split(',', 0);
                system.debug('Nitin fields==='+fields);
                //Extract Header Values, Object Types and Fields from the document    
                for(Integer i = 0; i < fields.size(); i++) {
                    String[] headerType = fields[i].split(':', 0);
                    system.debug('nitin headerType==='+headerType);
                    if(headerType.size() > 1) {
                        String[] typeField = headerType[1].split('\\.', 2);    
                        system.debug('nitin typeField==='+typeField);
                        system.debug('nitin typeField[0].trim()==='+typeField[0].trim());
                        if(typeField.size() > 1) {
                            if(typeField[0].trim() == 'allocation') {
                                allocationFields.add(typeField[1].trim());
                            } else if(typeField[0].trim() == 'payment') {
                                paymentFields.add(typeField[1].trim());
                            } else {
                                continue;
                            }
                            List<String> headerTypeField = new String[3];   
                            headerTypeField.add(0, headerType[0].trim());
                            headerTypeField.add(1, typeField[0].trim());
                            headerTypeField.add(2, typeField[1].trim());
    
                            headerTypeFieldList.add(headerTypeField);
                        }
                    }
                    
                }

                //Build Query to retrieve values of given fields.
                List<Payment__c> resultObjects = null;
                if(paymentFields.size() > 0 || allocationFields.size() > 0) {  
                    String mainQuery = 'Select Id';
                    system.debug('Nitin paymentFields==='+paymentFields);
                    If(paymentFields.size() > 0) {
                        //Add fields belonging to the Payment__c object to the main query.
                        mainQuery = mainQuery + ', ' + String.join(paymentFields, ', ');
                    }    
                    If(allocationFields.size() > 0) {
                        //Add fields belonging to the Gift_Detail__c(Allocation) object to the sub query.
                        mainQuery = mainQuery + ', (' + buildQuery('Allocations__r', allocationFields) + ') ';
                    }
                    mainQuery = mainQuery + ', cv_pkg_dev_I__Date__c From Payment__c Where Receipt__c = :relatedToId Order By cv_pkg_dev_I__Date__c';
                    system.debug('Nitin mainQuery====='+mainQuery);
                    resultObjects = Database.query(mainQuery);
                }
    
                String receiptPayments = '';
    
                if (resultObjects != null && resultObjects.size() >0) {
                    //Represent Payment(s) data in a Table structure.
                    receiptPayments = receiptPayments + '<table class="receiptPayments"><thead><tr>';
    
                    for(List<String> headerTypeField : headerTypeFieldList) {
                        receiptPayments = receiptPayments + '<th>' + headerTypeField[0] + '</th>';
                    }
    
                    receiptPayments = receiptPayments + '</tr></thead><tbody>';
                    system.debug('Nitin headerTypeFieldList===='+headerTypeFieldList);
                    for(Payment__c resultObject : resultObjects) {
                        /*Integer numberofAllocation = resultObject.Allocations__r.size();
                        if(resultObject.Allocations__r.size() == 0){
                            numberofAllocation = 1;
                        }
                        resultObject.cv_pkg_dev_I__Amount__c = resultObject.cv_pkg_dev_I__Amount__c/numberofAllocation;*/
                        for(Gift_Detail__c allocation : resultObject.Allocations__r) {
                            receiptPayments = receiptPayments + '<tr>';
                            for(List<String> headerTypeField : headerTypeFieldList) {
                                system.debug('Nitin headerTypeField===='+headerTypeField);
                                if(headerTypeField[1] == 'payment') {
                                    receiptPayments = receiptPayments + '<td>' + ReadFieldValue(resultObject, headerTypeField[2]) + '</td>';
                                }
                                if(headerTypeField[1] == 'allocation') {
                                    //receiptPayments = receiptPayments + '<td><table><tbody>';
                                    receiptPayments = receiptPayments + '<td>' + ReadFieldValue(allocation, headerTypeField[2]) + '</td>';
                                    //receiptPayments = receiptPayments + '</tbody></table></td>';
                                }
                            }
                            receiptPayments = receiptPayments + '</tr>';
                        }
                    }
                    receiptPayments = receiptPayments + '</tbody></table>';
                    system.debug('Nitin receiptPayments==='+receiptPayments);
                    //Generate table view for Receipt Funds.
                    retVal = addReceiptFundsSummary(retVal, resultObjects);
                }

                //Replace the Template string with the table generated.
                retVal = retVal.replace(toReplace + '}', receiptPayments);
            }
        }
     
      return retVal;
   }

   Private static String addReceiptFundsSummary(String retVal, List<Payment__c> payments)
   {
       String pattern = '{!receiptFunds}';
       String receiptFunds = '';
       SFDCEncoder htmlEncoder = new SFDCEncoder();
       if(retVal.contains(pattern)) {
           AggregateResult[] allocationsAR = [SELECT max(cv_pkg_dev_I__Fund__r.Fund_Name__c) fundName, sum(cv_pkg_dev_I__Amount__c) totalFundAmount FROM cv_pkg_dev_I__Gift_Detail__c Where Payment__c IN :payments group by cv_pkg_dev_I__Fund__c LIMIT 100];
           //Create Table View.
           if(allocationsAR != null && allocationsAR.size() > 0) {
               receiptFunds += '<table class="receiptFunds"><thead>' +
                                   '<tr><th>Fund</th><th>Total Amount</th></tr>' +
                               '</thead><tbody>';
               for(AggregateResult allocationAR : allocationsAR) {
                    receiptFunds += '<tr><td>' + htmlEncoder.SFDC_HTMLENCODE((String)allocationAR.get('fundName')) + '</td><td>' + htmlEncoder.SFDC_HTMLENCODE('$'+currencyFormat(String.valueOf(allocationAR.get('totalFundAmount')))) + '</td></tr>';
               }
               receiptFunds += '</tbody></table>';               
           }
           //Replace Template string with the Table View Generated
           retVal = retVal.replace(pattern, receiptFunds);
       }
       return retVal;
   }
   
   private static string mergeFields(string text,
     string relatedToType, 
     string relatedToId,
     string recipientType,
     string recipientId)
  {
 
      //validation
      if (text == null || text == '')
        return text;
        
      if ((relatedToType == null || relatedToType == '') || (relatedToId == null || relatedToId == '') || (recipientType == null || recipientType == ''))
        return text;
       
      SFDCEncoder htmlEncoder = new SFDCEncoder();  
      string relatedToKeyBegining = '{!relatedTo.';
      string recipientKeyBegining = '{!recipient.';
      string keyEnd = '}';
      
      //find fields
      List<String> relatedToFields = fetchFields(text, relatedToKeyBegining, keyEnd);
      List<String> recipientFields = fetchFields(text, recipientKeyBegining, keyEnd);
      //query objects
      SObject relatedTo = querySObject(relatedToType, relatedToFields, relatedToId);
      SObject recipient =  querySObject(recipientType, recipientFields,recipientId);
      //merge
      if (relatedTo != null)
        {
            
          for(string relatedToField : relatedToFields)
          {
          
             string fieldValue = ReadFieldValue(relatedTo,relatedToField);
             System.debug('Merging relatedTo field: ' + relatedToField + ' Value:' + fieldValue);
             
              fieldTypeBoolean = schemaMap.get(''+relatedTo.getsObjectType()).getDescribe().fields.getMap().get(relatedToField).getDescribe().isHtmlFormatted();
               
            
            
            
             if (fieldValue != null) {
                    if(!fieldTypeBoolean)
                      fieldValue = htmlEncoder.SFDC_HTMLENCODE(fieldValue);
               
               text = text.replace(relatedToKeyBegining + relatedToField + keyEnd, fieldValue);
             }
          }
        }
      if (recipient != null)
         for(string field : recipientFields)
          {
            fieldTypeBoolean = schemaMap.get(''+recipient.getsObjectType()).getDescribe().fields.getMap().get(field).getDescribe().isHtmlFormatted();
            
              string fieldValue = ReadFieldValue(recipient,field);
             if(!fieldTypeBoolean)
              fieldValue = htmlEncoder.SFDC_HTMLENCODE(fieldValue);
              System.debug('Merging recipient field: ' + field + ' Value:' + fieldValue);
              text = text.replace(recipientKeyBegining + field + keyEnd, fieldValue);
          }
      
      return text;
  } 
  
  private static string ReadFieldValue(SObject obj, string fieldName)
  {
  
     system.debug('Nitin obj===='+obj);
     system.debug('Nitin fieldName===='+fieldName);
  
    
     fieldTypeBoolean  = false;
      if (fieldName.indexOf('.')>0)
      {
         
         System.Debug(fieldName);
         //relationship field
         string[] names = fieldName.split('\\.',0);
         System.Debug(names.size());
         if ((names.size() > 2) || (names.size() <= 0))
             return '';
         else
         {
            SObject obj2 =  obj.getSObject(names[0]);
            Object fValue = obj2.get(names[1]);
            
            //fieldTypeBoolean = obj2.fieldName.getDescribe().isHtmlFormatted();
            
            //checkHtmlFormatted(names[0], names[1]);
            
            system.debug('Nitin fValue==='+fValue);
            system.debug('Nitin fValue==='+string.valueOf(fValue));
            
            if (fValue != null)
              return string.valueOf(fValue);
            else
              return '';
         }
         
         
      }
      else
      {
        //checkHtmlFormatted(''+obj.getsObjectType(), fieldName);

         Object fieldValue = obj.get(fieldName);
         system.debug('Nitin fieldValue==='+fieldValue);
         system.debug('Nitin fieldValue==='+string.valueOf(fieldValue));
         
        Schema.DescribeSObjectResult r = obj.getsObjectType().getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
         system.debug('Nitin getsObjectType==='+f.getType());
         system.debug('Nitin r==='+r);
         if(string.valueOf(f.getType()) == 'CURRENCY' && fieldName == 'Amount__c'){    //r.getName() == 'cv_pkg_dev_I__Gift_Detail__c'
             string currencyVAlue = currencyFormat(string.valueOf(fieldValue));
             return '$'+currencyVAlue;
         }else
         if(string.valueOf(f.getType()) == 'CURRENCY'){
             string currencyVAlue = currencyFormat(string.valueOf(fieldValue));
             return currencyVAlue;
         }else
         if(fieldValue != null && string.valueOf(fieldValue).StartsWith('<a href=')){
             string hrefvalue = parseReference(string.valueOf(fieldValue));
             return hrefvalue;
         }   
         if (fieldValue != null) 
           return string.valueOf(fieldValue);
         else
           return '';
      }
  }
  
  private static SObject querySObject(string sobjectType, List<String> fields, string sobjectId)
  {
     string query = buildQuery(sobjectType, fields);
     if (query != null && query != '')
     {
         query += ' WHERE Id = :sobjectId ';
         SObject[] resultObjects = Database.query(query);
         if (resultObjects != null && resultObjects.size() >0)
          return resultObjects[0]; 
     }
     
     return null;
  }
  
  private static string buildQuery(string sobjectType, List<String> fields)
  {
     if (fields== null || fields.size() <= 0) 
         return '';
     
     integer total = fields.size();
     integer count = 0;
     string query = 'SELECT id,';
     for(string qfield : fields) {
      
        query += qfield;
        if (count != total-1)
          query += ', ';
          
        count++; 
    }//end for
    
    query += ' FROM ' + sobjectType;
    
    return query;
  }
  
  private static integer[] findKeyPositions(string original, string pattern)
  {
    string replacement = '';
    List<integer> positions = new List<integer>();
    integer count, position0, position1;
    count = position0 = position1 = 0;
    string upperString = original;
    string upperPattern = pattern;
    
    while ((position1 = upperString.indexOf(upperPattern, position0)) != -1)
    {
         position0 = position1 + pattern.length();
         positions.Add(position0 - pattern.length());
    }
            
    return positions;
  }
  
  private static string[] fetchFields(string content, string startKey, string endKey)
  {
     List<string> items = new List<string>();
     
     //validation
     if (IsEmptyOrNull(content)) 
      return items;
     
     if (IsEmptyOrNull(startKey)) 
      return items;
     
     if (IsEmptyOrNull(endKey)) 
      return items;
     
      
     integer[] pos0 = findKeyPositions(content, startKey);
     integer[] pos1 = new List<integer>();
     
     for(integer start : pos0)
     {
        integer end2 = content.indexOf(endKey, start);
        boolean endFound = (end2 != -1);

        if (endFound)
        {
           System.Debug(start);
           System.Debug(end2);
           string item = content.substring(start + startKey.length(), end2);
           
           //ensure uniqueness
           boolean itemFound = false;
           for(string str : items)
           {
               if (str.equalsIgnoreCase(item))
               {
                   itemFound = true;
               }
           }
           
           if (!itemFound)
           {
               items.add(item);
           }
        }
     }//main for loop
     return items;
  }
  
  private static string removeScriptBlocks(string htmlText)
  {
    String patternStr = '<script.*?</script>';
    Pattern MyPattern = Pattern.compile(patternStr);
    Matcher MyMatcher = MyPattern.matcher(htmlText);

    return MyMatcher.replaceAll('');
  }
  
  public static Boolean IsEmptyOrNull(string value) {
    return (value==null || value=='');
  }
   
   public static Boolean checkHtmlFormatted(String objectName, String FieldName)
   { 
    fieldTypeBoolean = false;
    if(objectName != null && FieldName != null)
     {
      try{
       fieldTypeBoolean  = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(FieldName).getDescribe().isHtmlFormatted();
      
       system.debug('fieldTypeBoolean  '+fieldTypeBoolean  );
       }
       catch(Exception e)
       {
           fieldTypeBoolean = false;
       }
      }
    return fieldTypeBoolean;
   } 
   //added by nitin to format currency
   public static string currencyFormat(string i){
       String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
        return s.substring(0,s.length()-1);
   }
   //added by nitin to remove hyperlink from values
   public static String parseReference(string i){
        Pattern myPattern = Pattern.compile('>(.*?)</a>');
        Matcher MyMatcher = MyPattern.matcher(i);
        MyMatcher.find();
        string constituent = MyMatcher.group(1);
        return constituent;
    }
}