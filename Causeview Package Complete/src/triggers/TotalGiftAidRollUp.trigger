trigger TotalGiftAidRollUp on causeview__Payment__c (after insert, after update, after delete, before insert, before update) {

     causeview__App_Settings__c appSetting = causeview__App_Settings__c.getInstance();
     if(appSetting.causeview__Gift_Aid_Enable__c) 
    {
    list<causeview__Gift__c  > giftsToBeUpdated = new list<causeview__Gift__c >();
    list<string> paymentsIdsToUpdateAllocation = new list<string>();
    decimal totalAmountClaimed=0;
    decimal totalAmountForEligibleAmount=0;
    list<string> giftIds = new list<string>();
    
    set<string> contactSet1= new set<string>();
    set<string> TransactionSet= new set<string>();
    set<id> paymentSet= new set<Id>();
    
    
    
    
    map<string ,causeview__Payment__c> paymnetcontactmap= new map<string ,causeview__Payment__c> ();
    // map<Id , causeview__Payment__c> transactionpaymentmap= new map<Id ,causeview__Payment__c> ();
    map<id,List<causeview__Payment__c>> paymentconatctlistmap=new map<id,List<causeview__Payment__c>>();
    
    
    
    
    // this part of code will update Gift-Aid Information of payment record with values from respective individual values. 
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) ){
        for(causeview__Payment__c payment : Trigger.new) 
        {
            Transactionset.add(payment.causeview__Donation__c); 
           
        }
        
        List<causeview__Payment__c> paymentlist=new List<causeview__Payment__c> ();
        //List<causeview__Gift__c> transactionlist =[select id, name , causeview__Constituent__c,(select id,name from causeview__Recurring_Payments__r) from causeview__Gift__c where Id In :Transactionset];
        Map<Id,causeview__Gift__c> map_Id_Transaction = new Map<Id,causeview__Gift__c> ([select id, name , causeview__Constituent__c,(select id,name from causeview__Recurring_Payments__r) from causeview__Gift__c where Id In :Transactionset]); 
        for(causeview__Gift__c trans : map_Id_Transaction.values())
        {
            contactset1.add(trans.causeview__Constituent__c);
        }
        Map<Id,contact> contactslist= new Map<Id,Contact>([select FirstName,LastName,MailingPostalCode, MailingCountry, MailingCity, MailingState,MailingStreet,(select id,name ,Active__c,Type__c,Effective_Date__c from Gift_Aid_Declarations__r where Active__c = true) FROM Contact where id In :contactset1]);
        system.debug('conatct list---->'+contactslist);
        
        Map<Id,List<Gift_Aid_Declaration__c>> Map_ConId_ListGiftAid = new Map<Id,List<Gift_Aid_Declaration__c>>(); 
        for(contact c: contactslist.values())
        {
            Map_ConId_ListGiftAid.put(c.Id, c.Gift_Aid_Declarations__r);
        }
        
        Map<Id,Gift_Aid_Declaration__c> GiftAIdmap = new Map<Id,Gift_Aid_Declaration__c>([SELECT Id,Name,causeview__Donor__c,(select id,name, causeview__Date__c from causeview__Payments__r ) FROM causeview__Gift_Aid_Declaration__c where causeview__Donor__c In :Map_ConId_ListGiftAid.keyset()]);
        
        
        
        List<Gift_Aid_Declaration__c> giftAidDeclerations;
        for(causeview__Payment__c pay : Trigger.new) 
        {
            causeview__Gift__c trans;
            if(map_Id_Transaction.containsKey(pay.causeview__Donation__c))
                trans = map_Id_Transaction.get(pay.causeview__Donation__c);
            system.debug('transaction-----.'+ trans);
            //List<Gift_Aid_Declaration__c> giftAidDeclerations;
            
            if(trans!= null && Map_ConId_ListGiftAid.containsKey(trans.causeview__Constituent__c)){
                giftAidDeclerations = Map_ConId_ListGiftAid.get(trans.causeview__Constituent__c);
                system.debug('giftAidDeclerations -----' +giftAidDeclerations  );
                
                Contact c = contactslist.get(trans.causeview__Constituent__c);
                system.debug('conatct------>' + c );
                if(giftAidDeclerations.size() >0)
                {
                    //for(Gift_Aid_Declaration__c giftAid : giftAidDeclerations)
                    //{
                    //if(giftAid.Effective_Date__c >= pay.causeview__Date__c)
                    //{
                    if(c.MailingCountry==null) {c.MailingCountry='';}
                    if(c.MailingPostalCode==null){c.MailingPostalCode='';}
                    if(c.MailingState==null){c.MailingState='';}
                    if(c.MailingCity==null){c.MailingCity='';}
                    if(c.MailingStreet==null){c.MailingStreet='';}
                    
                    
                    pay.causeview__Gift_Aid_Eligible__c = true;
                    /*if(giftAidDeclerations[0].Type__c != 'This donation, and all future')
                    {
                    pay.Gift_Aid_Declaration__c =  giftAidDeclerations[0].Id;
                    }*/
                    Boolean paymentExist = false;
                  
                       if(giftAidDeclerations[0].Type__c == 'This Donation Only') 
                       {
                           if(GiftAIdmap.get(giftAidDeclerations[0].id).causeview__Payments__r.size() > 0 && GiftAIdmap.get(giftAidDeclerations[0].id).causeview__Payments__r != null)
                           {
                               for(payment__c p:GiftAIdmap.get(giftAidDeclerations[0].id).causeview__Payments__r)
                               {
                                    if(p.causeview__Date__c == pay.causeview__Date__c)
                                    {
                                        paymentExist = true;
                                        break;
                                    }
                                }
                           }
                           if(!paymentExist)
                               pay.Gift_Aid_Declaration__c =  giftAidDeclerations[0].Id;
                       }
                    
                      else if(giftAidDeclerations[0].Type__c == 'This donation, and all future' && (pay.causeview__Date__c  >=  giftAidDeclerations[0].Effective_Date__c) )
                      {
                          pay.Gift_Aid_Declaration__c =  giftAidDeclerations[0].Id;
                      }  
                    
                      else 
                      {
                          pay.Gift_Aid_Declaration__c =  giftAidDeclerations[0].Id;
                      } 
                  
 
                    pay.First_Name__c= c.FirstName;
                    pay.Last_Name__c=c.LastName;
                    pay.House_Number__c=c.MailingStreet;
                    pay.Postal_Code__c=c.MailingPostalCode;
                    //break;
                    /* if(giftAidDeclerations[0].Type__c =='This donation, and all future & historic') 
{
pay.causeview__Date__c = giftAidDeclerations[0].Effective_Date__c;
} */
                    //}
                    //}
                }
            }
        }
        
        
    }
    
    // this part of code will roll up the Total_GA_Claimed__c, Total_Gift-Aid_Eligible_Amount__c of respective traction based on condition.
    if(Trigger.isAfter ){
       if(!Validator_cls.isalreadyModifiedTotalGiftAidpayment()||Trigger.isdelete)
       {
        
        system.debug('101-----error');
        if(Trigger.isInsert ){       
            for(causeview__Payment__c tempPayment : trigger.new){
                giftIds.add(tempPayment.causeview__Donation__c );
            }            
        }
        
        if(Trigger.isUpdate){
            Validator_cls.SetalreadyModifiedTotalGiftAidpayment();
            for(causeview__Payment__c tempPayment : trigger.new){
                giftIds.add(tempPayment.causeview__Donation__c );
                    if(((Trigger.oldMap.get(tempPayment.id).causeview__Gift_Aid_Eligible__c  )!=(Trigger.newMap.get(tempPayment.id). causeview__Gift_Aid_Eligible__c  )) || ((Trigger.oldMap.get(tempPayment.id).causeview__Status__c )!=(Trigger.newMap.get(tempPayment.id).causeview__Status__c ))){
                        paymentsIdsToUpdateAllocation.add(tempPayment.id);
                    }
            }
            list<causeview__Gift_Detail__c > allocationsToBeUpdated = [select id from causeview__Gift_Detail__c where causeview__Payment__c in :paymentsIdsToUpdateAllocation ];
            if(allocationsToBeUpdated.size()>0){
                update allocationsToBeUpdated;
                system.debug('executed--');
            }
            
        }
        giftsToBeUpdated = [select Total_GA_Claimed__c, Total_Gift_Aid_Eligible_Amount__c, name, (select name, Gift_Aid_Amount__c, Total_Gift_Aid_Eligible_Amount__c, Gift_Aid_Claim_Status__c from causeview__Recurring_Payments__r)  from causeview__Gift__c where id in :giftIds ];
        
         if(Trigger.isdelete ){
            for(causeview__Payment__c tempPayment : trigger.old){
                giftIds.add(tempPayment.causeview__Donation__c );
            }
            giftsToBeUpdated = [select Total_GA_Claimed__c, Total_Gift_Aid_Eligible_Amount__c, name, (select name, Gift_Aid_Amount__c, Total_Gift_Aid_Eligible_Amount__c, Gift_Aid_Claim_Status__c from causeview__Recurring_Payments__r)  from causeview__Gift__c where id in :giftIds ];
        }
        
        
        if(giftsToBeUpdated.size()>0){
            for(causeview__Gift__c tempGift : giftsToBeUpdated){
                totalAmountClaimed=0;
                totalAmountForEligibleAmount=0;
                for(causeview__Payment__c tempPayment :  tempGift.causeview__Recurring_Payments__r){
                    if(tempPayment.Gift_Aid_Claim_Status__c !='Not claimed' && tempPayment.Gift_Aid_Claim_Status__c !=null){
                        totalAmountClaimed+=tempPayment.Gift_Aid_Amount__c;
                        if(tempPayment.Total_Gift_Aid_Eligible_Amount__c==null){
                            totalAmountForEligibleAmount+=0;
                        }else{
                            totalAmountForEligibleAmount+=tempPayment.Total_Gift_Aid_Eligible_Amount__c;
                        }    
                    }else{
                        if(tempPayment.Total_Gift_Aid_Eligible_Amount__c==null){
                            totalAmountForEligibleAmount+=0;
                        }else{
                            totalAmountForEligibleAmount+=tempPayment.Total_Gift_Aid_Eligible_Amount__c;
                        }    
                    }
                }
                tempGift.Total_GA_Claimed__c=totalAmountClaimed;
                tempGift.Total_Gift_Aid_Eligible_Amount__c=totalAmountForEligibleAmount;                
            }      
        }    
        
        
        if(giftsToBeUpdated.size()>0){            
            update giftsToBeUpdated;
        }
        //this code is to update Allocation records to make trigger on Allocation 'TotalGAEligibleAllocationsRollUp' to fire. And it wont modify the records(blank update).
      /*  if(Trigger.isupdate){
            for(causeview__Payment__c paymentTempNew:Trigger.new){
                if(((Trigger.oldMap.get(paymentTempNew.id).causeview__Gift_Aid_Eligible__c  )!=(Trigger.newMap.get(paymentTempNew.id). causeview__Gift_Aid_Eligible__c  )) || ((Trigger.oldMap.get(paymentTempNew.id).causeview__Status__c )!=(Trigger.newMap.get(paymentTempNew.id).causeview__Status__c ))){
                    paymentsIdsToUpdateAllocation.add(paymentTempNew.id);
                }
            }
            list<causeview__Gift_Detail__c > allocationsToBeUpdated = [select id from causeview__Gift_Detail__c where causeview__Payment__c in :paymentsIdsToUpdateAllocation ];
            if(allocationsToBeUpdated.size()>0){
                update allocationsToBeUpdated;
                system.debug('executed--');
            }
        } */
    }
    
   } 
  }  
}
