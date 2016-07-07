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
        

        if(!scheduleJobNamesMap.containskey(contactJobName)){
            RollupBatchScheduler batch = new RollupBatchScheduler();
            //If there is a default value for batch size defined in the Custom setting use that, otherwise use 60 as default.
            String sch = '0 0 0,11 ? * *';
            //string cronId = System.scheduleBatch(batch, contactJobName, 30, 100);
           System.schedule('Contact Rollup',sch,batch);
        }
        if(!scheduleJobNamesMap.containskey(accountJobName)){
            RollupBatchForOrganizationScheduler batch1 = new RollupBatchForOrganizationScheduler();
            //string cronId = System.scheduleBatch(batch, accountJobName, 30, 100);
            String sch = '0 0 3,13 ? * *';
            System.schedule('Account Rollup',sch,batch1);
        }
        
        //as limit pbm max is 5
        /* if(!scheduleJobNamesMap.containskey(AppealRollUpJobName)){
            AppealRollupBatch2 batch = new AppealRollupBatch2();
            string cronId = System.scheduleBatch(batch, AppealRollUpJobName, 2, 1);
        } 
        */
        //test
        if(!scheduleJobNamesMap.containskey(PackageRollUpJobName)){
         String sh1='0 0 20 * * ?';
         PackageRollupScheduler packagerollup = new PackageRollupScheduler (); 
         system.schedule('Package Rollup', sh1,packagerollup);
         }
         
         if(!scheduleJobNamesMap.containskey(AppealRollUpJobName)){
          String sh2='0 0 22 * * ?';
          AppealUtilRollupScheduler appealutilrollup= new AppealUtilRollupScheduler(); 
          system.schedule('Appeal Rollup', sh2,appealutilrollup);
        }
        
        if(!scheduleJobNamesMap.containskey(CampaignRollUpJobName)){
          String sh3='0 0 0 * * ?';
          CampaignRollupScheduler campaignrollup= new CampaignRollupScheduler(); 
          system.schedule('Campaign Rollup', sh3,campaignrollup);
          }
          
          
         if(!scheduleJobNamesMap.containskey(PaymentRollUpJobName)){ 
          String sh4='0 0 1 * * ?';
          RDPaymentCountBatchScheduler paymentRollup= new RDPaymentCountBatchScheduler(); 
          system.schedule('Payment Rollup', sh4,paymentRollup);
          }
        
       /* if(!scheduleJobNamesMap.containskey(CmapignRollUpJobName)){
            AppealRollupBatch3 batch = new AppealRollupBatch3();
            string cronId = System.scheduleBatch(batch, CmapignRollUpJobName, 5, 1);
        } */

        
        //Assign the permission set in the new package to those users

        
        List<User> UserList  = [SELECT id FROM User where isActive = true ];                

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
        
         insert psList;
        
        //Link all historical payment records to existing receipts.
        Database.executeBatch(new linkPaymentsToReceiptsBatch(), 50);
        
        
        //insert CVAdmin record
        cv_pkg_dev_I__CVAdmin__c CVAdmin = new cv_pkg_dev_I__CVAdmin__c(Name='Waive Settings');
        insert CVAdmin;
        
      }
     catch(Exception ex) {
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
