global class PostInstall implements InstallHandler
{
    public void onInstall(InstallContext context)
    {
        Boolean configure = true;
        try 
        {
         /**
        * Creating the records for the custom settings if those record doesnt exists....
        */
        CauseViewCustomSetting.defaultANumSettings();
        CauseViewCustomSetting.defaultBatchSettings();
        CauseViewCustomSetting.defaultAppSettings();
        CauseViewCustomSetting.defaultAppTemplateSettings();
        //CauseViewCustomSetting.updateSeachKey();

        //Updates all the Email Templates in the Org with non erroneous Component code.
        ModifyRecipientTemplates MRT = new ModifyRecipientTemplates();
        MRT.modify();       

        //Limit the Batch size to givingpowerSettings__c.Rollup_Batch_Size__c, to avoid the Exception "Aggregate query has too many rows for direct assignment, use FOR loop".
        //givingpowerSettings__c GPS = [Select Id, Rollup_Batch_Size__c From givingpowerSettings__c Where IsDeleted = false limit 1];
        
        //commented by Nitin
        /*if(context.isUpgrade()) 
        {
            configure = false;
            Version v = context.previousVersion();
            configure = v.compareTo(new Version(1, 936)) < 0;
            
        }
        
        if (configure)
        {
            if(GPS != null && GPS.Rollup_Batch_Size__c != null && GPS.Rollup_Batch_Size__c > 0) 
            {
                System.scheduleBatch(new RollupBatchForOrganization(), 'Account Rollup Batch', 30,  (Integer)GPS.Rollup_Batch_Size__c);
                System.scheduleBatch(new RollupBatch(), 'Contact Rollup Batch', 30,  (Integer)GPS.Rollup_Batch_Size__c);
            }
            else
             {
                System.scheduleBatch(new RollupBatchForOrganization(), 'Account Rollup Batch', 30,100);
                System.scheduleBatch(new RollupBatch(), 'Contact Rollup Batch', 30,100);
            }
        }*/
        
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();
        scheduleJobNamesMap = CauseViewCustomSetting.cronJobMethod();
        String contactJobName = 'Contact Rollup';
        String accountJobName = 'Account Rollup';
        String AppealRollUpJobName = 'Appeal Rollup';
        String CampaignRollUpJobName = 'Campaign Rollup';
        String PackageRollUpJobName = 'Package Rollup';
        String PaymentRollUpJobName= 'Payment Rollup';
        String NewYearTransaction2016batchJobName = 'New Year Transaction 2016';
        String paymentsToTransactionMapping = 'Payment to Transaction Mapping - 2016';
        
        Set<Id> DeleteJobIds = new Set<Id>();
        if(scheduleJobNamesMap.containskey(contactJobName)) 
           {
            DeleteJobIds.add(scheduleJobNamesMap.get(contactJobName));
           }
           
        if(scheduleJobNamesMap.containskey(accountJobName)) 
           {
            DeleteJobIds.add(scheduleJobNamesMap.get(accountJobName));
           }   
           
          
        List<CronTrigger>  CronTriggerList = [SELECT id , CronJobDetailId FROM CronTrigger where CronJobDetailId IN :DeleteJobIds];
        
        for(CronTrigger ct:CronTriggerList)
          {
            System.abortJob(ct.id);
          
          }
           
        Map<String, String> scheduleJobNamesMap1 = new Map<String, String>();
        scheduleJobNamesMap1 = CauseViewCustomSetting.cronJobMethod();   
           
        
        if(!scheduleJobNamesMap1.containskey(contactJobName)){
            RollupBatchScheduler batch = new RollupBatchScheduler();
            //If there is a default value for batch size defined in the Custom setting use that, otherwise use 60 as default.
            String sch = '0 0 0 ? * *';
            //string cronId = System.scheduleBatch(batch, contactJobName, 30, 100);
           System.schedule('Contact Rollup',sch,batch);
        }
        if(!scheduleJobNamesMap1.containskey(accountJobName)){
            RollupBatchForOrganizationScheduler batch1 = new RollupBatchForOrganizationScheduler();
            //string cronId = System.scheduleBatch(batch, accountJobName, 30, 100);
            String sch1 = '0 0 3 ? * *';
            System.schedule('Account Rollup',sch1,batch1);
        }
        
        //as limit pbm max is 5
        /* if(!scheduleJobNamesMap.containskey(AppealRollUpJobName)){
            AppealRollupBatch2 batch = new AppealRollupBatch2();
            string cronId = System.scheduleBatch(batch, AppealRollUpJobName, 2, 1);
        } 
        */
        //test
        if(!scheduleJobNamesMap1.containskey(PackageRollUpJobName)){
         String sh1='0 0 20 * * ?';
         PackageRollupScheduler packagerollup = new PackageRollupScheduler (); 
         system.schedule('Package Rollup', sh1,packagerollup);
         }
         
         if(!scheduleJobNamesMap1.containskey(AppealRollUpJobName)){
          String sh2='0 0 22 * * ?';
          AppealUtilRollupScheduler appealutilrollup= new AppealUtilRollupScheduler(); 
          system.schedule('Appeal Rollup', sh2,appealutilrollup);
        }
        
        if(!scheduleJobNamesMap1.containskey(CampaignRollUpJobName)){
          String sh3='0 0 0 * * ?';
          CampaignRollupScheduler campaignrollup= new CampaignRollupScheduler(); 
          system.schedule('Campaign Rollup', sh3,campaignrollup);
          }
          
          
         if(!scheduleJobNamesMap1.containskey(PaymentRollUpJobName)){ 
          String sh4='0 0 1 * * ?';
          RDPaymentCountBatchScheduler paymentRollup= new RDPaymentCountBatchScheduler(); 
          system.schedule('Payment Rollup', sh4,paymentRollup);
          }
          
         /* if(!scheduleJobNamesMap.containskey(NewYearTransaction2016batchJobName)){ 
          String sh5='0 0 22 6 1 ? 2016';
          NewYearTransaction2016batchScheduler newyear2016job= new NewYearTransaction2016batchScheduler(); 
          system.schedule('New Year Transaction 2016', sh5,newyear2016job);
          }*/
        
        
         /*if(!scheduleJobNamesMap.containskey(paymentsToTransactionMapping)){ 
          String sh6='0 0 22 15 1 ? 2016';
          paymentsToTransactionMapping paymenttransactionmap= new paymentsToTransactionMapping(); 
          system.schedule('Payment to Transaction Mapping - 2016', sh6, paymenttransactionmap);
          }*/
        
        
        
        
       /* if(!scheduleJobNamesMap.containskey(CmapignRollUpJobName)){
            AppealRollupBatch3 batch = new AppealRollupBatch3();
            string cronId = System.scheduleBatch(batch, CmapignRollUpJobName, 5, 1);
        } */

        
        //Assign the permission set in the new package to those users

        
        List<User> UserList  = [SELECT id FROM User WHERE isActive = true LIMIT 8000 ];                

        PermissionSet PermissionSetToAssign = [SELECT id,Name FROM PermissionSet where Name='Newly_Added_Fields_Objects_Permission_Set' AND 
            NamespacePrefix = 'causeview' Limit 1];
            List<PermissionSetAssignment> psList = new List<PermissionSetAssignment>();
        Set<ID> UsersSet = new Set<ID> ();          
        for(User us : UserList){
            PermissionSetAssignment psa= new PermissionSetAssignment();
            psa.PermissionSetId = PermissionSetToAssign.id;
            psa.AssigneeId = us.id;
           psList.add(psa);
        }
        
        Database.SaveResult[] lsr = Database.insert(psList,false);
        
        //Link all historical payment records to existing receipts.
        Database.executeBatch(new linkPaymentsToReceiptsBatch(), 50);
        
        
        //newly inserted code for patch release 
        
          //Database.executeBatch(new NewYearTransaction2016batch(), 200);
        
        
        //insert CVAdmin record
        causeview__CVAdmin__c CVAdmin = new causeview__CVAdmin__c(Name='Waive Settings');
        insert CVAdmin;
        
        //for Gift-Aid Enable customsetting
        
        Organization locale =[SELECT Id,DefaultLocaleSidKey,FiscalYearStartMonth FROM Organization limit 1];
        If(locale.DefaultLocaleSidKey.containsIgnoreCase ('en_GB') || locale.DefaultLocaleSidKey.containsIgnoreCase('cy_GB'))
            {
                 //App_Settings__c s =[select id,name ,Gift_Aid_Enable__c from  App_Settings__c limit 1];
                App_Settings__c s = App_Settings__c.getInstance(UserInfo.getOrganizationId());
                 s.Gift_Aid_Enable__c = true;
                 s.Fiscal_Start_Month__c = Decimal.ValueOf(locale.FiscalYearStartMonth);
                update s;      
             }

        
        //Folder change issue:
        
         /* List<Document> d = [select id, name , FolderId from Document where name  LIKE '2015YearEndRecurringTransactionJobReport%' limit 1];
          if(d!=null && d.size() > 0)
          {        
              Folder f= [select id from Folder where name='causeview' and Type = 'Document'];
    
              d[0].FolderId= f.Id;
          
              Database.SaveResult lsr1 = Database.update(d[0],false);
          } */       //TO UPDATE THE TRANSACTION RECEIPT TYPE
       
       /*
        //Commented out creation of New Year Gifts
        String logFileData1 = '';
        
        String logFiledata2 = '';


        List<causeview__Gift__c>  OldGiftList=[select id,name, causeview__Gift_Date__c, causeview__Reference__c, causeview__Channel__c, causeview__Status__c, causeview__Receipt_Type__c,causeview__Recurring_Donation__c,RecordTypeId, causeview__Expected_Amount__c from causeview__gift__c where causeview__Status__c='active' and causeview__Gift_Date__c = 2016-01-01  AND  Owner.Name =:userinfo.getName() ];
            
           set<Id> RdIds = new Set<Id>();
        
        for(causeview__Gift__c g:oldGiftList)
        {
         RdIds.add(g.causeview__Recurring_Donation__c);
        }
           
         
         Map<Id,causeview__Recurring_Donation__c> RDmap = new Map<Id,causeview__Recurring_Donation__c>([SELECT id,name ,causeview__Status__c, causeview__Amount__c, (select Id,causeview__Gift_Date__c, causeview__Reference__c, causeview__Channel__c, causeview__Status__c, causeview__Receipt_Type__c,RecordTypeId, causeview__Expected_Amount__c,causeview__Recurring_Donation__c,causeview__Recurring_Donation__r.causeview__Amount__c from  causeview__Orders__r where  causeview__Gift_Date__c = LAST_YEAR order by causeview__Gift_Date__c DESC limit 1 )  FROM causeview__Recurring_Donation__c where Id IN :RdIds]);

         
            List<causeview__Gift__c> modifygiftlist= new List<causeview__Gift__c> ();
            
            for(causeview__Gift__c m1: OldGiftList)
            {
             if(RDmap.containsKey(m1.causeview__Recurring_Donation__c)) 
             {
            
            if(RDmap.get(m1.causeview__Recurring_Donation__c).causeview__orders__r.size() != 0 && RDmap.get(m1.causeview__Recurring_Donation__c).causeview__orders__r!= null) 
              {
              Gift__c modgift= RDmap.get(m1.causeview__Recurring_Donation__c).causeview__orders__r;
              
              m1.causeview__Reference__c = modgift.causeview__Reference__c;
              
              m1.causeview__Channel__c = modgift.causeview__Channel__c;
              
              m1.recordTypeId = modgift.recordTypeId;
                        
              m1.causeview__Receipt_Type__c='Consolidated';

              m1.causeview__Expected_Amount__c = modgift.causeview__Recurring_Donation__r.causeview__Amount__c;
               
              modifygiftlist.add(m1);
            
            } 
            
            }
            
            }

           Database.SaveResult[] updatesResults = Database.update(modifygiftlist,false);
            
            List<Id> listOfIds1 = new List<Id>();
            
            for (Database.SaveResult sr : updatesResults) {
                
                if (sr.isSuccess()) {
                    
                    listOfIds1.add(sr.getId());
                    }
                    
                    else {
                    
                   for(Database.Error err : sr.getErrors()) {
                    
                     System.debug('The following error has occurred.');   
                                      
                     System.debug(err.getStatusCode() + ': ' + err.getMessage());
                     
                     System.debug('Account fields that affected this error: ' + err.getFields());
                     
                    logFiledata2 += 'error Occured while updating the Transaction' + 'ERROR MESSAGE '+ err.getMessage() +'ERROR FIELD' + err.getFields() +'\n';
                    
                    
                    }
                 }
                 
                }
            
            List<gift__c> updategiftlist =[select id, name , causeview__Gift_Type__c, causeview__Status__c, causeview__Gift_Date__c,causeview__Constituent__c , causeview__Organization__c ,causeview__Recurring_Donation__r.Name, causeview__Recurring_Donation__c, causeview__Recurring_Donation__r.causeview__Status__c, causeview__Receipt_Type__c from causeview__Gift__c where id=:listOfIds1 ];
            
            for(gift__c m:updategiftlist) {
            
                  logFileData1 += m.causeview__Recurring_Donation__r.causeview__Status__c  + ' Recurring Gift  '  +  m.causeview__Recurring_Donation__r.Name  + '  -  ' +  String.valueOf(m.causeview__Gift_Date__c) + ' Transaction ' + m.Name  +' Receipt Type --- '+ m.causeview__Receipt_Type__c   + 'modified' +'\n' ;
            
            }
           

         if (String.isNotBlank(logFileData1) == true){
            
            Folder folder = [SELECT Id,Name,Type FROM Folder where Name = 'Causeview' AND Type = 'Document' LIMIT 1];
            
            Document doc = new Document (Name = 'Transaction - Receipt Type log'+DateTime.now().format() + '.txt');
            
            doc.Description = ''; // Insert description
            
            doc.FolderId = folder.Id;
            //doc.FolderId = UserInfo.getUserId();
            
            doc.Body = Blob.valueOf(logFileData1);
            
            insert doc;
        }
        
        
        
        
        

        //Folder change issue:
        
          Document d=[select id, name , FolderId from Document where name  LIKE '2015YearEndRecurringTransactionJobReport%' limit 1];
    
          Folder f= [select id from Folder where name='causeview' and Type = 'Document'];
    
          d.FolderId= f.Id;
          
          Database.SaveResult lsr1 = Database.update(d,false);
          
          if(!lsr1.isSuccess()) 
            {
            Database.Error error = lsr1.getErrors().get(0);

            logFileData2 += 'Error message while updating the folder Id' + error.getMessage();
            
            }
            
            
            if (String.isNotBlank(logFileData2) == true){
            
            Folder folder = [SELECT Id,Name,Type FROM Folder where Name = 'Causeview' AND Type = 'Document' LIMIT 1];
            
            Document doc = new Document (Name = 'Transaction - Receipt Type/Foleder Id modification  log'+DateTime.now().format() + '.txt');
            
            doc.Description = ''; // Insert description
            
            doc.FolderId = folder.Id;
            //doc.FolderId = UserInfo.getUserId();
            doc.Body = Blob.valueOf(logFileData2);
            
            insert doc;
        }
          */
   
      }
     catch(Exception ex) {
      system.debug('---------'+ex.getmessage());
/*            Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
            list<String> listEmailMembers = new list<String>();
            listEmailMembers.add('tnguyen@causeview.com');
            emailTobeSent.setToAddresses(listEmailMembers);
            emailTobeSent.setSubject('Post install exception');
            emailTobeSent.setHtmlBody('Message : ' + ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' getStackTraceString ' + ex.getStackTraceString() + '' + ex.getCause());
            Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
*/        }
        
    }
}
