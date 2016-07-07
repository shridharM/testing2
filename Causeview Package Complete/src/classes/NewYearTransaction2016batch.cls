global class NewYearTransaction2016batch implements Database.Batchable<sObject>, Database.stateful{
    String logFileData = '';
  
  global Database.QueryLocator start(Database.BatchableContext BC){
  
    //String query = 'select Id, name,causeview__Status__c ,(select id,name, causeview__Gift_Date__c, causeview__Gift_Type__c, causeview__Status__c, causeview__Constituent__c, causeview__Organization__c from causeview__Orders__r) from causeview__Recurring_Donation__c';
      
    String query = 'select Id, name,causeview__Status__c  from causeview__Recurring_Donation__c';
  
      
      System.debug('query ---'+query);
      return Database.getQueryLocator(query);
   }
  
  
  global void execute(Database.BatchableContext BC, List<causeview__Recurring_Donation__c> scope){
     
        System.debug('Scope ---'+scope.size());
        
        set<Id> RdIds = new Set<Id>();
        
        for(causeview__Recurring_Donation__c rd:scope)
        {
         RdIds.add(rd.id);
        
        }
        //Added missing field
        List<causeview__Recurring_Donation__c> RdlistNew =[select Id, name,causeview__Status__c ,(select causeview__Acknowledgement_Recipient_Email__c,causeview__Affiliated_Contact__c,causeview__Allocation_Count__c,causeview__Amount__c,causeview__Anonymous__c,causeview__Attendee_Names_Pending__c,causeview__Attendee_Names_Received__c,causeview__Authorization__c,causeview__Batch_Status__c,causeview__Channel__c,causeview__Consolidated_Rcpt__c,causeview__ConstituentType__c,causeview__Constituent_Address__c,causeview__Constituent_FirstName__c,causeview__Constituent_Name__c,causeview__Constituent__c,causeview__Credit_Card_Number__c,causeview__Credit_Card_Type__c,causeview__Description__c,causeview__Discounted_Price__c,causeview__Event_Id__c,causeview__Event_Name__c,causeview__Event__c,causeview__Expected_Amount__c,causeview__Exported__c,causeview__External_Trans_ID__c,causeview__Foundation_Credit__c,causeview__Gateway__c,causeview__GiftBatch__c,causeview__Gift_Batch_ID__c,causeview__Gift_Count__c,causeview__Gift_Date__c,causeview__Gift_Type__c,causeview__HouseholdId__c,causeview__Household__c,causeview__Internal_Solicitor__c,causeview__Key_Contact__c,causeview__Last_Payment_Date__c,causeview__Last_Pledge_Payment__c,causeview__Letter__c,causeview__Matched_Gift__c,causeview__Next_Payment_Date__c,causeview__Next_Payment_Due__c,causeview__No_of_Expected_Payments__c,causeview__No_of_Outstanding_Payments__c,causeview__No_of_Written_Off_Payments__c,causeview__Number_of_Payments__c,causeview__Organization__c,causeview__Outstanding_Amount__c,causeview__Package_Name__c,causeview__Package__c,causeview__Payment_Count__c,causeview__Payment_Withdrawal_Day__c,causeview__Per_Payment_Amount__c,causeview__Pledge_Payment_Frequency__c,causeview__Pledge_Start_Date__c,causeview__Primary_Solicitor__c,causeview__Promotion_Code__c,causeview__Proposal__c,causeview__Receipt_Later__c,causeview__Receipt_Type__c,causeview__Recurring_Donation__c,causeview__Recurring_Frequency__c,causeview__Recurring_Start_Date__c,causeview__Reference__c,causeview__Remaining_Payments__c,causeview__Search_Key__c,causeview__Source__c,causeview__Sponsorship_Amount__c,causeview__Status__c,causeview__Stock_Sale_Date__c,causeview__Stock_Value__c,causeview__sysLastAllocationUpdate__c,causeview__sysLastPaymentUpdate__c,causeview__Sys_Clone_Transaction__c,causeview__Total_Attendees_Purchased__c,causeview__Total_Gift_Amount__c,causeview__Total_Payment_Amount__c,causeview__Tribute_Honoree_Name__c,causeview__Tribute_Message__c,causeview__Tribute_Notification_Address__c,causeview__Tribute_Notification_City__c,causeview__Tribute_Notification_Country__c,causeview__Tribute_Notification_Date__c,causeview__Tribute_Notification_Email__c,causeview__Tribute_Notification_Method__c,causeview__Tribute_Notification_State_Province__c,causeview__Tribute_Notification_Zip_Postal_Code__c,causeview__Tribute_Person_To_Notify__c,causeview__Tribute_Type__c,causeview__Withdrawl_Day__c,causeview__Write_Off_Amount__c,IsDeleted,Name,OwnerId,RecordTypeId from causeview__Orders__r where causeview__Gift_Date__c != null ) from causeview__Recurring_Donation__c where Id IN :RdIds];
        
       
        Map<Id,causeview__Recurring_Donation__c> RDmap = new Map<Id,causeview__Recurring_Donation__c>([SELECT id,name ,causeview__Status__c, (select id, name,  causeview__Status__c, causeview__Gift_Date__c from causeview__Orders__r where causeview__Status__c='active' and causeview__Gift_Date__c = THIS_YEAR)  FROM causeview__Recurring_Donation__c where Id IN :RdIds]);
          
        List<Gift__c> modifiedgift= new List<Gift__c>();
        
        List<Gift__c> insertgift = new List<Gift__c> ();
        
        
        for(causeview__Recurring_Donation__c RDlist : RdlistNew) {
        
           if(RDmap.get(RDlist.Id).orders__r.size()  == 0 ) {
           
                for(Gift__c mygift:RDlist.orders__r)
                {
                 if(mygift.Status__c =='Active'  && mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='Active') {
                 
                    mygift.status__c = 'Completed';
                    
                    Gift__c newg= mygift.clone(false,false,false,false);
                    
                    newg.Gift_Date__c = date.valueof(system.today().Year()+'-01-01');
                    
                    newg.Status__c='Active';
                    
                    modifiedgift.add(mygift);
                    
                    insertgift.add(newg);
                 
                  system.debug('test');
                 
                 }
                 
                 else if(mygift.Status__c =='Acknowledged'  && mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='Active') {
                  
                   logFileData += RDlist.causeview__Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.causeview__Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Acknowledged : unchanged '+ '\n' ;
                     
                     Gift__c newg= mygift.clone(false,false,false,false);
                    
                     newg.Gift_Date__c= date.valueof(system.today().Year()+'-01-01');
                    
                     newg.Status__c='Active';
                   
                     insertgift.add(newg);
                 
                 
                  }
                  
                  else if(mygift.status__c == 'Payment Received'  &&  mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='Active') {
                    
                    logFileData += RDlist.causeview__Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.causeview__Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Payment Received : unchanged '+ '\n' ;
                     
                     Gift__c newg= mygift.clone(false,false,false,false);
                    
                     newg.Gift_Date__c=date.valueof(system.today().Year()+'-01-01');
                    
                     newg.Status__c='Active';
                  
                     insertgift.add(newg);
                     
             
                     }
                     
                    else if((mygift.status__c == 'Entered'|| mygift.status__c == 'Payment Pending'|| mygift.status__c == 'Completed'|| mygift.status__c == 'Cancelled')  &&  mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='Active') {
                       
                    logFileData += RDlist.causeview__Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.causeview__Gift_Date__c) + ' Transaction ' + mygift.Name  + ' with Status ' + mygift.Status__c  + ' : unchanged '+ '\n' ;
                       
                    } 
                       
                       
                   else if(mygift.Status__c =='Active'  && mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='On Hold')  {
                 

                    mygift.status__c = 'Completed';
                    
                    Gift__c newg= mygift.clone(false,false,false,false);
                    
                    newg.Gift_Date__c = date.valueof(system.today().Year()+'-01-01');
                    
                    newg.Status__c='Active';
                   
                     modifiedgift.add(mygift);
                    
                    insertgift.add(newg);
                    
                    }      
                   
                   else if(mygift.Status__c =='Acknowledged'  && mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='On Hold')  {
                 
                  
                
                   logFileData += RDlist.causeview__Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.causeview__Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Acknowledged : unchanged '+ '\n' ;

                    Gift__c newg= mygift.clone(false,false,false,false);
                    
                     newg.Gift_Date__c= date.valueof(system.today().Year()+'-01-01');
                    
                     newg.Status__c='Active';
                                        
                     insertgift.add(newg);
                     
                    
                    }      
                    
                    
                    else if(mygift.Status__c =='Payment Received'  && mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='On Hold')  {
                 
                      logFileData += RDlist.causeview__Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.causeview__Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Payment Received : unchanged '+ '\n' ;
                    

                     Gift__c newg= mygift.clone(false,false,false,false);
                    
                     newg.Gift_Date__c= date.valueof(system.today().Year()+'-01-01');
                    
                     newg.Status__c='Active';
                                        
                     insertgift.add(newg);
                     
                    
                    } 
                    
                    else if((mygift.status__c == 'Entered'|| mygift.status__c == 'Payment Pending'|| mygift.status__c == 'Completed'|| mygift.status__c == 'Cancelled')  &&  mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='On Hold') {
                       
                      logFileData += RDlist.causeview__Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.causeview__Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status ' + mygift.status__c + ' : unchanged '+ '\n' ;
                       
                       }
                   
               
                      else if(mygift.Status__c =='Active'  && mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='Cancelled')  {

                     
                       mygift.status__c = 'Completed';
                      
                       modifiedgift.add(mygift);
                       
                  
                    }    
                    
                    
                    else if((mygift.Status__c =='Acknowledged'  ||mygift.Status__c =='Payment Received'  || mygift.status__c == 'Entered'|| mygift.status__c == 'Payment Pending'|| mygift.status__c == 'Completed'|| mygift.status__c == 'Cancelled')  && mygift.causeview__Gift_Date__c.year() == Date.today().addYears(-1).year()  && RDlist.Status__c =='Cancelled')  {
                 
                      logFileData += RDlist.causeview__Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.causeview__Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status ' + mygift.status__c  +' : unchanged '+ '\n' ;
                    
                    }    
                
               }
           }
           
           
           else
           {
           
           logFileData += RDlist.causeview__Status__c  + ' Recurring Gift  '  +  RDlist.Name  +' No 2016 Transaction Added '+ '\n' ;
           
           }
        }
        
        
        
           
            Database.SaveResult[] insertResults = Database.insert(insertgift,false);
            
            List<Id> listOfIds = new List<Id>();
           
            for (Database.SaveResult sr : insertResults) {
                
                if (sr.isSuccess()) {
                   
                    listOfIds.add(sr.getId());
                    }
                    else
                    {
                    for(Database.Error err : sr.getErrors()) {
                    
                     System.debug('The following error has occurred.');   
                                      
                     System.debug(err.getStatusCode() + ': ' + err.getMessage());
                     
                     System.debug('Account fields that affected this error: ' + err.getFields());
                     
                    logFileData += 'error Occured while inserting the Transaction' + 'ERROR MESSAGE '+ err.getMessage() +'ERROR FIELD' + err.getFields() +'\n';

                    
                    }
                    
                    }
                 }
            
            List<gift__c> insertedgiftlist =[select id, name , causeview__Gift_Type__c, causeview__Status__c, causeview__Gift_Date__c,causeview__Constituent__c , causeview__Organization__c ,causeview__Recurring_Donation__r.Name, causeview__Recurring_Donation__c, causeview__Recurring_Donation__r.causeview__Status__c  from causeview__Gift__c where id=:listOfIds ];
            
            for(gift__c m:insertedgiftlist) {
            
                  logFileData += m.causeview__Recurring_Donation__r.causeview__Status__c  + ' Recurring Gift  '  +  m.causeview__Recurring_Donation__r.Name  + '  -  ' + String.valueOf (m.causeview__Gift_Date__c) + ' Transaction ' + m.Name  +' Added with status Active '+ '\n' ;
            
            }
            
            Database.SaveResult[] updatesResults = Database.update(modifiedgift,false);
            
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
                     
                    logFileData += 'error Occured while updating the Transaction' + 'ERROR MESSAGE '+ err.getMessage() +'ERROR FIELD' + err.getFields() +'\n';

                  }
                 } 
            
            List<gift__c> updategiftlist =[select id, name , causeview__Gift_Type__c, causeview__Status__c, causeview__Gift_Date__c,causeview__Constituent__c , causeview__Organization__c ,causeview__Recurring_Donation__r.Name, causeview__Recurring_Donation__c, causeview__Recurring_Donation__r.causeview__Status__c  from causeview__Gift__c where id=:listOfIds1 ];
            
            for(gift__c m:updategiftlist) {
            
                  logFileData += m.causeview__Recurring_Donation__r.causeview__Status__c  + ' Recurring Gift  '  +  m.causeview__Recurring_Donation__r.Name  + '  -  ' +  String.valueOf(m.causeview__Gift_Date__c) + ' Transaction ' + m.Name  +' Status modified from Active to Completed '+ '\n' ;
            
            }
           
        
    }
    
  }
   global void finish(Database.BatchableContext BC){
         
         if (String.isNotBlank(logFileData) == true){
            //Folder folder = [select id from Folder where name='Updated Account/Contact Record Log' LIMIT 1];
            
            DateTime d = Date.Today() ;
            
            String dateStr =  d.format('mmddyy') ;
            
            system.debug(dateStr);
            
            Document doc = new Document (Name = '2015YearEndRecurringTransactionJobReport–'+ dateStr );
            
            doc.Description = ''; // Insert description
            //doc.FolderId = folder.Id;
            
            doc.FolderId = UserInfo.getUserId();
            
            doc.Body = Blob.valueOf(logFileData);
            
            insert doc;
        }
   }
  
  
  

}