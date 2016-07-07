global class DonationMapping
{
  global class MappingObject
  {
     WebService string Id { get; set; }
     WebService string Name { get; set; }    
     WebService MappingField[] MappingFields;
     private string yy;
  }
  
  global class MappingField
  {
        //Sales Force Field name
        WebService string ApiName { get; set; }
        //value
        WebService string Value { get; set; }
        
        public MappingField() { }
        public MappingField(string apiName,string Value) {
            this.ApiName = apiName;
            this.Value = Value;
        }
  }
  
  global class MappingSettings
  {
      WebService string bucketAccountId;
      WebService boolean isRecurring;
      WebService boolean isIndividualDonation; 
  }
  
  global class MappingObjectResult
  {
     WebService string Id { get; set; }
     WebService string Name { get; set; }
     WebService string[] Errors;
     public SObject mappingObject;
  }
  
  global enum StatusResult { Success, Failure, NotFound, InvalidInput }
  
  global class MappingResult
  {
     WebService MappingObjectResult[] ObjectResults;
     WebService String ConstituentType;
     WebService StatusResult Status;
     Webservice String StatusComment { get; set; }
  }
  
  global class MappingException extends Exception { }
  
  
  //-------------------------------------------------------------------------------
  WebService static MappingResult PerformMapping(MappingObject[] objects, MappingSettings settings) {
  
    MappingResult retVal = new MappingResult();
    
    List<MappingObjectResult> results = new List<MappingObjectResult>();
    retVal.ObjectResults = results;
    
    
    //validation
    if (objects == null || objects.size()<=0)
     return retVal; 
     
    if (settings == null)
    {
        retVal.Status = StatusResult.InvalidInput;
        retVal.StatusComment = 'Mapping settings are not provided. The object can not be null.';
        System.Debug(retVal.StatusComment);
        return retVal;
    }
  
     //try/catch and handle transaction
     Savepoint sp = Database.setSavepoint();
     
     try
     {
        
     
      for(MappingObject mobj : objects)
      {
         MappingObjectResult result = new MappingObjectResult();
         result.Errors = new List<string>();
         result.Name = mobj.Name;
         results.add(result);
         
         if (mobj.MappingFields == null || mobj.MappingFields.size() <= 0)
             continue;
         
         //find the object type
         Schema.SObjectType objType = findSobjectType(mobj.Name);
         if (objType == null)
         {
            retVal.Status = StatusResult.NotFound;
            retVal.StatusComment = 'object type: ' + mobj.Name + ' was not found in the selected org.';
            System.Debug(retVal.StatusComment);
            return retVal;
         }
         
         
         SObject newObject = objType.newSObject();
         result.mappingObject = newObject;
         Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
         
         //fields
         newObject = populateFields(newObject, sobjectDescribe, mobj.MappingFields, settings, result, retVal.ObjectResults);
         
         
         //upsert if there is no errors
         if (result.Errors.size() <= 0)
            upsertObject(newObject, sobjectDescribe, mobj.MappingFields, settings, result, retVal);
         
      }//end for 
           
     }
     catch (Exception ex)
     {
        Database.rollback(sp);
        retVal.Status = StatusResult.Failure;
        retVal.StatusComment = ex.getMessage();
        System.Debug(retVal.StatusComment);
        return retVal;
     }
     
     try
     {
      
     DonationCustomMapping customMapping = new DonationCustomMapping();
     results = customMapping.execute(results, settings);
     
     }
     catch(Exception ex)
     {
        retVal.Status = StatusResult.Failure;
        retVal.StatusComment = ex.getMessage();
        return retVal;
     }
     
     retVal.Status = StatusResult.Success;
     return retVal;
  }
  
  //-------------------------------------------------------------------------------
  private static void upsertObject(SObject newObject, 
       Schema.DescribeSObjectResult objDescriber,
       List<MappingField> mfields, 
       MappingSettings settings,
       MappingObjectResult result, 
       MappingResult response)
  {
      string objectName = objDescriber.getName();
      string applicationNamespace = 'giving_power__';
       
      if (objectName == 'Account')
      {
        if (!settings.isIndividualDonation) {
          
           // check upsert
           string query = buildQuery(objDescriber, mfields);
           if (query != '')
           {
               string AccountName = (String)newObject.get('Name');
               if (AccountName == null || AccountName == '')
                 throw new MappingException('Account Name field is required. Please include it in the mapping.');
               
               query += ' WHERE Name = \'' + string.escapeSingleQuotes(AccountName) + '\'';
               SObject[] foundObjects = Database.query(query);
               if (foundObjects != null && foundObjects.size()>0)
               {
                   SObject foundAccount = foundObjects[0];
                   newObject = mergeSObject(newObject, foundAccount, objDescriber, mfields, result);
                   update newObject;  
              
                   System.Debug('Updated Account Id:' + newObject.Id); 
               }
               else
               {
                  insert newObject;
                  System.Debug('New Account Id:' + newObject.Id); 
               }
           }//query
          
        }//not individual donation
         
      }
      else
      if (objectName == 'Contact')
      {
         if (settings.isIndividualDonation) 
           newObject.put('AccountId', settings.bucketAccountId);
         
         // check upsert
         string query = buildQuery(objDescriber, mfields);
         if (query != '')
         {
            
            string contactEmail = (String)newObject.get('Email');
            if (contactEmail == null || contactEmail == '')
             throw new MappingException('Contact email is required, please include in the mapping.');
            
            query += ' WHERE Email = \'' + string.escapeSingleQuotes(contactEmail) + '\'';
            SObject[] queryContactObjects = Database.query(query);
            if (queryContactObjects != null && queryContactObjects.size()>0)
            {
              //contact found
              SObject queryContact = queryContactObjects[0];
              
              String accountId = (String)newObject.get('AccountId');
            
              newObject = mergeSObject(newObject, queryContact, objDescriber, mfields, result); 
              newObject.put('AccountId',accountId);
              update newObject;  
              
              System.Debug('Updated Contact Id:' + newObject.Id);
              response.ConstituentType = 'Existing';
            }
            else
            {
               //new contact
               insert newObject;
               response.ConstituentType = 'New';
               System.Debug('New Contact Id:' + newObject.Id);
            }
         }
      }
      else if (objectName ==  applicationNamespace+'Recurring_Donation__c' && settings.isRecurring) {
            insert newObject;
            System.Debug('New Recurring_Donation__c Id:' + newObject.Id);
      }
      else if (objectName == applicationNamespace +'Gift__c') {
         newObject.put('ConstituentType__c',response.ConstituentType);
         insert newObject;
         System.Debug('New gift with Constituent Type:' + response.ConstituentType);
      }
      else if (objectName == applicationNamespace+'Receipt__c' && settings.isRecurring) {
        insert newObject;
        System.Debug('New Receipt__c Id:' + newObject.Id);
      }
      else
      {
         //all other custom objects
         insert newObject;
      }
      
      //gather Id
      result.Id = newObject.Id;
      result.mappingObject = newObject;
  }
    
  
  public static SObject populateFields(SObject obj,
    Schema.DescribeSObjectResult objDescriber,
    List<MappingField> mfields,
    MappingSettings settings,
    MappingObjectResult result,
    List<MappingObjectResult> results)
  {
      string objectName = objDescriber.getLabel();
    
      for(MappingField mfield : mfields)
      {
          Schema.SObjectField field = findSObjectField(mfield.ApiName, objDescriber);
          if (field == null)
           throw new MappingException('field '+ mfield.ApiName + ' does not exists in ' + objectName + ' within the organization schema.');
          
          Object fieldValue = null;
          
          System.Debug('Object:'+ objectName + '- mapping field:' + mfield.ApiName + ' to: '+ mfield.Value);
          
          //find if a relation mapping is required.
          string[] lookupValues = tryLookupField(mfield.Value);
          if (lookupValues != null)
          {
            
             if (lookupValues.size() <= 0) {
               throw new MappingException('input merge field string was not in correct format:' + mfield.Value);
             }
             else
             {
                //lookup
                string lookupObject = lookupValues[0];
                boolean found = false;
                for(MappingObjectResult r : results)
                 if (r.Name == lookupObject) {
                   fieldValue = r.mappingObject.get(lookupValues[1]);
                   found = true;
                   break;
                 }
                 
                if (!found) {
                  throw new MappingException('lookup object was not found in the context:' + lookupValues[0]);
                }//endif
                
                System.Debug('Setting the lookup field: '+ mfield.ApiName +' with value: '+ fieldValue);
                if (fieldValue != null)
                    obj.put(mfield.ApiName,fieldValue);
                
             }//end else
          }
          else
          {
            string Value = mfield.Value;
            if (Value == null || Value == '')
             continue;
            
            //regular mapping
            Schema.DescribeFieldResult descField = field.getDescribe();
            Schema.SOAPType fieldType = descField.getSOAPType();
            
            if (fieldType == Schema.SOAPType.Boolean)
            {   
                Value = Value.toLowerCase();
                obj.put(mfield.ApiName,Value.equals('true'));
            }
            else if (fieldType == Schema.SOAPType.Date)
                obj.put(mfield.ApiName,Date.parse(Value));
            else if (fieldType == Schema.SOAPType.DateTime)
                obj.put(mfield.ApiName,DateTime.parse(Value));
            else if (fieldType == Schema.SOAPType.Double)
                obj.put(mfield.ApiName,Double.valueOf(Value));
            else if (fieldType == Schema.SOAPType.Integer)
                obj.put(mfield.ApiName,Integer.valueOf(Value));
            else
                obj.put(mfield.ApiName,String.valueOf(Value));
            
          }
         
          
      } 
      return obj;
  }
  
  private static SObject putValue(Schema.SObjectField field, object Value, SObject obj)
  {
        Schema.DescribeFieldResult descField = field.getDescribe();
        Schema.SOAPType fieldType = descField.getSOAPType();
        
        string V = String.valueOf(Value);
            
        if (fieldType == Schema.SOAPType.Boolean)
        {   
                V = V.toLowerCase();
                obj.put(descField.getName(),V.equals('true'));
        }
        else if (fieldType == Schema.SOAPType.Date)
                obj.put(descField.getName(),Date.parse(V));
        else if (fieldType == Schema.SOAPType.DateTime)
                obj.put(descField.getName(),DateTime.parse(V));
        else if (fieldType == Schema.SOAPType.Double)
                obj.put(descField.getName(),Double.valueOf(V));
        else if (fieldType == Schema.SOAPType.Integer)
                obj.put(descField.getName(),Integer.valueOf(V));
        else
                obj.put(descField.getName(),String.valueOf(V));
                
        return obj;
  }
  
  public static SObject mergeSObject(SObject newObject, 
       SObject queryObject, 
       Schema.DescribeSObjectResult objDescriber,
       List<MappingField> mfields, 
       MappingObjectResult result )
  {
     string objectName = objDescriber.getLabel();   
     
    //merge the two
    for(MappingField mfield : mfields)
    {
        object v = queryObject.get(mfield.ApiName);
        System.Debug('Merging field: '+ mfield.ApiName);
        if (v == null)
        {
           //convert the value to the proper type and put into the record
           Schema.SObjectField field = findSObjectField(mfield.ApiName, objDescriber);
           if (field == null)
            throw new MappingException('field '+ mfield.ApiName + ' does not exists in ' + objectName + ' within the organization schema.');
           
            queryObject = putValue(field, newObject.get(mfield.ApiName), queryObject);
        }
    }
    return queryObject;
  }
  
  public static string buildQuery(Schema.DescribeSObjectResult describer, List<MappingField> mfields) {
    
    if (mfields == null || mfields.size() <= 0) 
     return '';
    
    integer total = mfields.size();
    integer count = 0;
    string query = 'SELECT id,';
    for(MappingField mfield : mfields) {
      
        query += string.escapeSingleQuotes(mfield.ApiName);
        if (count != total-1)
          query += ', ';
          
        count++; 
    }//end for
    
    query += ' FROM ' + describer.getName();
    
    return query;
  }
  
  public static string[] tryLookupField(string Value)
  {
     if (Value != null && Value.startsWith('{!') && Value.endsWith('}'))
     {
        Value = Value.replace('{!','');
        Value = Value.replace('}','');
        System.Debug('processing the lookup value: ' + Value);
        string[] strs = Value.split('\\.',0);
      
        
        return strs;  
      
     }
     
     return null;
  }
  
   
  public static Schema.SObjectType findSobjectType(string sObjectName) {
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    for(string key : gd.keySet())
     if (key == sObjectName)
       return gd.get(key);
    return null;
  }
  
  public static Schema.SObjectField findSObjectField(string apiName,Schema.DescribeSObjectResult describer) { 
    Schema.DescribeSObjectResult objDesc = describer;
    Map<String, Schema.SObjectField> M = objDesc.fields.getMap();
    for (string key : M.keySet())
     if (key == apiName)
      return M.get(key);
    return null;  
  }
  
  public static testMethod void testMapping()
  {

    List<DonationMapping.MappingObject> objects = new List<DonationMapping.MappingObject>();
    DonationMapping.MappingObject mapAccount = new DonationMapping.MappingObject();
    objects.add(mapAccount);
    mapAccount.Name = 'Account';
    
    List<DonationMapping.MappingField> fields = new List<DonationMapping.MappingField>();
    fields.add(new DonationMapping.MappingField('Name','test account'));
    fields.add(new DonationMapping.MappingField('WebSite','http://www.opinov.com'));
    mapAccount.MappingFields = fields;
    
    //mapping contact
    DonationMapping.MappingObject mapContact = new DonationMapping.MappingObject();
    objects.add(mapContact);
    mapContact.Name = 'Contact';
    
    List<DonationMapping.MappingField> cfields = new List<DonationMapping.MappingField>();
    cfields.add(new DonationMapping.MappingField('FirstName','vahid'));
    cfields.add(new DonationMapping.MappingField('LastName','fotovat'));
    cfields.add(new DonationMapping.MappingField('Email','some@email.com'));
    cfields.add(new DonationMapping.MappingField('AccountId','{!Account.Id}'));
    mapContact.MappingFields = cfields;
    
    
    //mapping Recurring_Donation__c
    DonationMapping.MappingObject mapRecurringDonation = new DonationMapping.MappingObject();
    mapRecurringDonation.Name = 'Recurring_Donation__c';
    objects.add(mapRecurringDonation);
    
    List<DonationMapping.MappingField> mrfields = new List<DonationMapping.MappingField>();
    mrfields.add(new DonationMapping.MappingField('Reference__c','#WERWFSDFSDF'));
    mrfields.add(new DonationMapping.MappingField('Constituent__c','{!Contact.Id}'));
    mrfields.add(new DonationMapping.MappingField('Start_Date__c','2010-05-01'));
    mapRecurringDonation.MappingFields = mrfields;
    
    List<RecordType> rts = [Select r.SobjectType, r.Name, r.Id From RecordType r WHERE SobjectType='givingpower__Gift__c'];
        String recTypeId = '';
        if (rts!=null&&rts.size()>0)
          recTypeId = rts[0].Id;
    
    // mapping Gift
    DonationMapping.MappingObject mapGift = new DonationMapping.MappingObject();
    mapGift.Name = 'Gift__c';
    objects.add(mapGift);
    
    List<DonationMapping.MappingField> gfields = new List<DonationMapping.MappingField>();
    gfields.add(new DonationMapping.MappingField('Organization__c','{!Account.Id}'));
    gfields.add(new DonationMapping.MappingField('Recurring_Donation__c','{!Recurring_Donation__c.Id}'));
    gfields.add(new DonationMapping.MappingField('Amount__c','80'));
    gfields.add(new DonationMapping.MappingField('Constituent__c','{!Contact.Id}'));
    //gfields.add(new DonationMapping.MappingField('RecordTypeId',recTypeId));
    mapGift.MappingFields = gfields;
    
    
    
    //mapping payment 
    DonationMapping.MappingObject mapPayment = new DonationMapping.MappingObject();
    objects.add(mapPayment );
    mapPayment.Name = 'Payment__c';
    
    List<DonationMapping.MappingField> payfields = new List<DonationMapping.MappingField>();
    payfields.add(new DonationMapping.MappingField('Donation__c','{!Gift__c.Id}'));
    payfields.add(new DonationMapping.MappingField('Amount__c','80'));
    payfields.add(new DonationMapping.MappingField('CC_Reference__c','#DSFGDSFDSFS'));
    payfields.add(new DonationMapping.MappingField('Status__c','Pending'));
    mapPayment.MappingFields = payfields;
    
    
    Account acc = new Account(Name='bucket account');
    insert acc;
    
    //scenario 0
    DonationMapping.PerformMapping(objects, null);
    
    DonationMapping.MappingSettings settings = new DonationMapping.MappingSettings();
    settings.bucketAccountId = acc.Id;
    settings.isRecurring = false;
    settings.isIndividualDonation = true;
    
    //scenario 1
    DonationMapping.PerformMapping(objects, settings);
    
    //scenario 2
    settings.isIndividualDonation = false;
    DonationMapping.PerformMapping(objects, settings);
    
    //scenario 3
    settings.isRecurring = true;
    DonationMapping.PerformMapping(objects, settings);
    
    //scenario 4: exception invalid field
    objects[0].MappingFields.add(new DonationMapping.MappingField('Donation__c','{!Gift__c.Id}'));
    DonationMapping.MappingResult result = DonationMapping.PerformMapping(objects, settings);
    System.assertEquals(result.Status, DonationMapping.StatusResult.Failure);
    
    //sceanrio 5: exception invalid object
    objects[0].Name = 'Dude';
    result = DonationMapping.PerformMapping(objects, settings);
    System.assertEquals(result.Status, DonationMapping.StatusResult.NotFound);
    
    
     //mapContact.MappingFields[2].Value = 'some@email.com';
    // DonationMapping.PerformMapping(objects, settings);
    }
  
  @isTest
  static Contact createContact()
  {
    
    integer num = math.random().intValue();
    String email = 'test' + num.format() + '@test.com';
    String lastName = 'test lastname' + num.format();
    
    Contact c = new Contact(LastName=lastName,Email=email);
    insert c;
     
    return c;
  }
  
   static testMethod void testAsyncDonation()
  {
     BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
          
     DonationAsyncTransaction.PaymentTransaction payment = new DonationAsyncTransaction.PaymentTransaction();
     DonationAsyncTransaction.TransactionUpsert(payment);
          
     //test refund
     payment.ParentTransactionId = 'SESESE';
     payment.TransactionId = 'WEWEWE';
     payment.Amount = 65;
     payment.Status = 'Pending';
     DonationAsyncTransaction.DonationAsyncResult result = DonationAsyncTransaction.TransactionUpsert(payment);
     
     System.assertEquals(result.Status,DonationAsyncTransaction.StatusResult.NotFound);
     
     Contact c = createContact();
     Gift__c g = new Gift__c();
     g.Constituent__c = c.Id;
     g.Gift_Date__c = Date.today();
     g.Channel__c = 'Phone 2';
     g.Status__c = 'New';
     //g.RecordTypeId = getGiftRecTypeId();
     insert g;
      
     
     Payment__c p1 = new Payment__c();
     p1.CC_Reference__c = 'SESESE';
     p1.Donation__c = g.Id;
     p1.Amount__c = 65;
     p1.Status__c = 'Approved';
     insert p1;
     
     result = DonationAsyncTransaction.TransactionUpsert(payment);
     
     
     //test existing payment IPN
     payment.ParentTransactionId = '';
     payment.Status = 'Approved';
     result = DonationAsyncTransaction.TransactionUpsert(payment);
     
     System.assertEquals(result.Status,DonationAsyncTransaction.StatusResult.Success);
      
      //test recurring payment
      Gift__c g1 = new Gift__c();
      g1.Constituent__c = c.Id;
      g1.Gift_Date__c = Date.today();
      g1.Channel__c = 'Phone 2';
      g1.Status__c = 'Active Recurring';
      g1.Reference__c = 'RECURRING';
      //g1.RecordTypeId = getGiftRecTypeId();
      insert g1;
      
      
     DonationAsyncTransaction.PaymentTransaction payment2 = new DonationAsyncTransaction.PaymentTransaction();
     payment2.TransactionId = 'NEWTRANS';
     payment2.Amount = 65;
     payment2.Status = 'Approved';
     payment2.TransactionDate = Date.today();
     payment2.RecurringPaymentId = 'RECURRING2';
     
     result = DonationAsyncTransaction.TransactionUpsert(payment2);
     System.assertEquals(result.Status,DonationAsyncTransaction.StatusResult.NotFound);
     
     payment2.RecurringPaymentId = 'RECURRING';
     result = DonationAsyncTransaction.TransactionUpsert(payment2);
     //System.assertEquals(result.Status,DonationAsyncTransaction.StatusResult.Success); 
    
  }
  
}