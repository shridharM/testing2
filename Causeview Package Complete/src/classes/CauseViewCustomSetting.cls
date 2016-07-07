/**
 * @Class CauseViewCustomSetting
 * Description : To auto create the record for the custom settings listed below
 *               1.Auto Number Counts 
 2. Batch Settings 3. Causeview App Settings  4. Causeview Templates
 *
 */

global class CauseViewCustomSetting
{

 /**
 * @Method defaultANumSettings
 * Description : To create the default record for Auto Number Counts
 *               name with value default and rest values are fields default value.
 *
 */
  global static void defaultANumSettings()
  {
     if(aNums__c.getInstance('Default') == null)
       {  
        aNums__c  aNum = new aNums__c();
        aNum.Name = 'Default';

            try
            {
                insert aNum;
                system.debug('ANumSettings created successfully');
            }    
            catch(System.DMLException e) 
            {
                emailUserAnError(e.getMessage());
            }  
      }
      causeview__aNums__c s = causeview__aNums__c.getInstance('Default');  
      List<causeview__Application_Setting__c> autonumberRecord = new List<causeview__Application_Setting__c>(); 
      autonumberRecord = [select Name, causeview__Org_Count__c from causeview__Application_Setting__c where Name =: 'Auto Number Setting' Limit 1];    //Auto Number Setting
      if(s != null){
          if(s.causeview__OrgCount__c != 0){
              if(autonumberRecord.size() > 0){
                  for(causeview__Application_Setting__c appSetting : autonumberRecord){
                      if(appSetting.causeview__Org_Count__c == 0){
                          appSetting.causeview__Org_Count__c = s.causeview__OrgCount__c;
                      }
                  }
              }else
              {
                  causeview__Application_Setting__c app = new causeview__Application_Setting__c();
                  app.Name = 'Auto Number Setting';
                  app.causeview__Org_Count__c = s.causeview__OrgCount__c;
                  try
                  {
                      insert app;
                      system.debug('Application setting created successfully');
                  }
                  catch(System.DMLException e) 
                  {
                      emailUserAnError(e.getMessage());
                  }
              }
          }else
          {
              if(!(autonumberRecord.size() > 0)){
                  causeview__Application_Setting__c app = new causeview__Application_Setting__c();
                  app.Name = 'Auto Number Setting';
                  app.causeview__Org_Count__c = s.causeview__OrgCount__c;
                  try
                  {
                      insert app;
                      system.debug('Application setting created successfully');
                  }
                  catch(System.DMLException e) 
                  {
                      emailUserAnError(e.getMessage());
                  }
              }
          }
      }
  }

/**
 * @Method defaultBatchSettings
 * Description : To create the default record for Batch Settings.
 */ 
 global static void defaultBatchSettings()
  {
     if((BatchSettings__c.getInstance('Default') == null))
       {  
        BatchSettings__c batchSettings = new BatchSettings__c ();
        batchSettings.Name = 'Default';
        batchSettings.CurrencyCode__c = UserInfo.getDefaultCurrency();
        batchSettings.BatchFormID__c = 'TBD';
        batchSettings.BatchReportId__c = getObjectId( 'Report' ,  'Gift Batch Summary Report' );
        batchSettings.BucketAccountId__c = createObject('Account', null , 'Individual');
        batchSettings.Unknown_Guest_Id__c = createObject('Contact', null , 'Unknown Guest');
        batchSettings.RegularGiftRecordTypeId__c = getObjectId( 'RecordType' ,  'Gift' );
        batchSettings.Record_Type_Id_for_Rollups__c = getObjectId( 'RecordType' ,  'Matching Gift' );
            try
            {
                insert batchSettings;
                system.debug('batchSettings created successfully');

            } 
            catch(System.DMLException e) 
            {
              emailUserAnError(e.getMessage());
            }  
        }
   }
  
/**
 * @Method defaultAppSettings
 * Description : To create the default record for causeview App Settings.
 */ 
    global static void defaultAppSettings()
     {
      App_Settings__c appSetting  = App_Settings__c.getInstance(UserInfo.getOrganizationId());
        
      if((appSetting.Name == null))
       {  
        appSetting.Public_Free_Event_Registration_Form_Id__c = 'TBD';
        appSetting.Appeal_Donate_Now_Form_Id__c = 'TBD';
        appSetting.Appeal_RecordType_Id__c = getObjectId( 'RecordType' ,  'Appeal' );
        appSetting.Campaign_RecordType_Id__c = getObjectId( 'RecordType' ,  'Campaign' );
        appSetting.CV_Account_Id__c = 'TBD';
        appSetting.Default_Actionpages_Campaign__c = createObject('Campaign','Appeal', 'CV Forms');
        appSetting.Event_RecordType_Id__c =  getObjectId( 'RecordType' ,  'Event' );
        appSetting.Individual_App_RecordtypeId__c = getObjectId( 'RecordType' ,  'Individual Application' );
        appSetting.Event_Registration_Form_Id__c = 'TBD';
        appSetting.Free_Event_Registration_Form_Id__c = 'TBD';
        appSetting.Use_Workflows_for_Sending_Receipts__c = false;
        appSetting.Other_Address_Trigger_Setting__c = true;
            try
            {
                insert appSetting ;
                system.debug('App settings created successfully');
                
            } 
            catch(System.DMLException e) 
            {
              emailUserAnError(e.getMessage()); 
            }  
        }
   }
     
     
    /**
    * @Method defaultAppTemplateSettings
    * Description : To create the default record for causeview App Template Settings which includes document mapping and object
    *               creation, email templates.
    */ 
   global static void defaultAppTemplateSettings()
    {

        if(givingpowerSettings__c.getInstance('Settings') == null)
        {  
            givingpowerSettings__c givingpowerSettings= new givingpowerSettings__c();
            givingpowerSettings.Name = 'Settings';
            givingpowerSettings.DupeEmailTemplateId__c = getObjectId( 'EmailTemplate' ,  'Receipt Template (Dupe)' );
            givingpowerSettings.EmailTemplateId__c = getObjectId( 'EmailTemplate' ,  'Receipt Template');
            givingpowerSettings.X15_DAYS_CC_Expiry_Email_Template__c = getObjectId( 'EmailTemplate' ,  'Credit Card Expiry - 15 DAY Notification');
            givingpowerSettings.X30_DAYS_CC_Expiry_Email_Template__c = getObjectId( 'EmailTemplate' ,  'Credit Card Expiry - 30 DAY Notification');
            givingpowerSettings.consolidatedReceiptEmailTemplateId__c = getObjectId( 'EmailTemplate' ,  'Consolidated Receipt Email Template');
            givingpowerSettings.DupeConsolidatedReceiptEmailTempId__c = getObjectId( 'EmailTemplate' , 'Consolidated Receipt Email Template (Dupe)');
            
            givingpowerSettings.Org_Wide_Email_ID__c = getObjectId( 'OrgWideEmailAddress' ,  'HN Foundation');

            givingpowerSettings.ReceiptEmailDocId__c = getObjectId( 'Document' ,  'en_htm');
            givingpowerSettings.DupeDocumentTemplateId__c = getObjectId( 'Document' ,  'HTML_Template_for_Reciept_Email_Content_Dupe');
            givingpowerSettings.ReceiptPDFDocId__c = getObjectId( 'Document' ,  'HTMLPage2_htm');
            givingpowerSettings.DupeAttachTemplateId__c = getObjectId( 'Document' ,  'HTML_Template_for_Reciept_PDF_Dupe');
            givingpowerSettings.consolidatedReceiptPDFDocId__c = getObjectId( 'Document' ,  'HTML_Template_for_Consolidated_Receipt_PDF_Attachment');
            givingpowerSettings.DupeConsolidatedReceiptPDFDocId__c = getObjectId( 'Document' ,  'HTML_Template_for_Consolidated_Reciept_PDF_Dupe');
           
            
            givingpowerSettings.Event_Registration_Email_Doc_ID__c = getObjectId( 'Document' ,  'HTML_Template_for_Event_Registration_Email_Content');
            givingpowerSettings.Dupe_Event_Registration_Email_Doc_ID__c = getObjectId( 'Document' ,  'HTML_Template_for_Event_Registration_Email_Content_Dupe');
            givingpowerSettings.Event_Registration_Email_Template_ID__c = getObjectId( 'EmailTemplate' ,  'Event Registration Acknowledgement');
            givingpowerSettings.Dupe_Event_Registration_Template_ID__c = getObjectId( 'EmailTemplate' ,  'Event Registration Acknowledgement (Dupe)');
            
            
            givingpowerSettings.Consolidated_Receipt_Email_Document_Id__c= getObjectId( 'Document' ,  'HTML_Template_for_Consolidated_Receipt_Email_Content');
            givingpowerSettings.Consolidated_Duplicate_Receipt_Email_Doc__c= getObjectId( 'Document' ,  'HTML_Template_for_Consolidated_Receipt_Email_Content_Dupe');

                
         try
            {
                insert givingpowerSettings;
                system.debug('App Template Settings created successfully');
            } 
            catch(System.DMLException e) 
            {
                emailUserAnError(e.getMessage()); 
            }  
            system.debug('givingpowerSettings is  :'+givingpowerSettings);
        }
    }

    /*
    *   @method : getObjectId
    *   Description : To get the id of the existing records from the database based on the field name and the object
    *
    */
    global static String getObjectId(String ObjectName, String fieldValue)
    {
        String soql = 'SELECT ID FROM '+ObjectName+' WHERE Name = : fieldValue';
        
        if(ObjectName.equals('OrgWideEmailAddress'))
            soql = 'SELECT ID FROM OrgWideEmailAddress WHERE DisplayName = : fieldValue';  
       
       if(ObjectName.equals('Document'))
            soql = 'SELECT ID FROM Document WHERE DeveloperName = : fieldValue';      
         
        String ret = '';
        
           system.debug(ObjectName+'  :soql for:'+fieldValue);
           if(Database.query(soql).size() == 0)
           {
              emailUserAnError('Missing record =>\n'+fieldValue+' in '+ObjectName+' does not exists. Please ensure this exists and retry');
           }    
           else
            ret = Database.query(soql)[0].Id;
        
        return ret;
    }
    
    /*
    *   @method : createObject
    *   Description : To get the id by creating the record Object name and recordtypeid and record name(value for the field named as name) is passed.
    *
    */
    global static Id createObject(String ObjectName,String recType, String RecordName) 
    {
        sObject sObj ;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectName);
        
        if(targetType!=null)
        {
            sObj = targetType.newSObject();  
                
            if(ObjectName != 'Contact')
                sObj.put('name' , RecordName) ;
            else
                sObj.put('LastName' , RecordName) ;
     
            if(recType!=null)
            {
                Id recordId = getObjectId('RecordType', recType);

                sObj.put('RecordTypeId' , recordId);  
            }
    
            try
            {
                insert sObj ;    
            }
            catch(Exception e)
            {
                emailUserAnError(e.getMessage());
            }        
            
            // Instantiate an sObject with the type passed in as an argument
            //  at run time.
            return sObj.Id; 
        }
        else 
           return null;
    }

 global static void emailUserAnError(String ex)
 {
 
     system.debug('Message : '+ex);
/*   Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
            list<String> listEmailMembers = new list<String>();
            listEmailMembers.add(userInfo.getUserEmail());
            emailTobeSent.setToAddresses(listEmailMembers);
            emailTobeSent.setSubject('Post Install Script failed due unavailabilty of the record');
            emailTobeSent.setHtmlBody('Message : '+ex);
            Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
    system.debug('Error mailed to '+userInfo.getUserEmail());
*/ }
    
    public static Map<String, String> cronJobMethod()
    {
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();
        for(CronJobDetail scheduleJobNames : [SELECT Id, Name FROM CronJobDetail]){
            scheduleJobNamesMap.put(scheduleJobNames.Name, scheduleJobNames.id);
        }
        return scheduleJobNamesMap;
    }
    
    public static void updateSeachKey(){
        List<causeview__Gift__c> newlist =new List<causeview__Gift__c> ();
        List<causeview__Gift__c>  giftlist=[select id , name,causeview__Constituent_Name__c ,causeview__Gift_Type__c,causeview__Amount__c from causeview__Gift__c where CreatedDate != null];
      
            for(causeview__Gift__c gift:giftlist)
             {
              string ss=gift.causeview__Constituent_Name__c + '-' + gift.causeview__Gift_Type__c + '-' + gift.causeview__Amount__c ;
              gift.causeview__Search_Key__c=ss;
              newlist.add(gift);
             }
          update newlist;
    }
}