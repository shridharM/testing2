trigger GiftAidUpdates_new on Gift_Aid_Declaration__c (after insert,after update,before insert,before update) {
      
    causeview__App_Settings__c appSetting = causeview__App_Settings__c.getInstance();
    if(appSetting.causeview__Gift_Aid_Enable__c) 
    {
    
       
        List<Gift_Aid_Declaration__c> giftaidlist= new List<Gift_Aid_Declaration__c> ();  
        set<id> contactset = new set<id> ();
        map<Gift_Aid_Declaration__c,id> contactgiftmap = new map<Gift_Aid_Declaration__c,id> ();
        String customdate;
   
        map<Id, List<causeview__payment__c>> transpaymnetmap = new map<Id, List<causeview__payment__c>>();
        map<id,causeview__Gift__c> transactionind= new map<id,causeview__Gift__c> ();
        list<causeview__Gift__c> transactionlist= new list<causeview__Gift__c>();
        map<id,List<causeview__Gift__c>> contransmap=new map<id,List<causeview__Gift__c>>();
        List<contact> mycon=new List<contact>();
          
       
       if(Trigger.isBefore) 
       {
            if(Trigger.isInsert  || Trigger.isupdate)
            {
                for(Gift_Aid_Declaration__c gift:trigger.new)
                {
                    if(gift.Type__c =='This donation, and all future & historic')
                    {
                        customdate= gift.Next_Fiscal_Date__c.year()-5 +'-'+gift.Next_Fiscal_Date__c.month()+'-01' ;
                        gift.Effective_Date__c = date.valueOf(customdate);
                        system.debug('custom date---' + gift.Effective_Date__c);
                        gift.End_Date__c=null;
                    }
                    else if(gift.Type__c == 'This donation, and all future') 
                    {
                        gift.Effective_Date__c= gift.Start_Date__c;
                        gift.End_Date__c=null;
                    }
                }
            }
       }
          
      if(Trigger.isAfter)
      {
            List<causeview__Gift_Detail__c> AllocationUpdateList =  new List<causeview__Gift_Detail__c>();
            system.debug('am inside after trigger');
            if(Trigger.isInsert)
            {
               for(Gift_Aid_Declaration__c gift:trigger.new)
               {
                 if(gift.Type__c == 'This donation, and all future & historic' )
                 {
                     giftaidlist.add(gift);
                     contactset.add(gift.Donor__c);
                     contactgiftmap.put(gift,gift.Donor__c);
                 }
               }
            }
            else if(Trigger.isUpdate) 
            {
                for(Gift_Aid_Declaration__c gift:trigger.new)
                {
                    system.debug('am inside update1');
                    system.debug('gift date-----'+ gift.Effective_Date__c);
                    string oldvalue = Trigger.oldMap.get(gift.Id).Type__c;
                    system.debug('oldvale------'+oldvalue);
                    system.debug('current value is ---'+gift.Type__c);
                    string newvalue=gift.Type__c;
                    if((gift.Type__c == 'This donation, and all future' &&  Trigger.oldMap.get(gift.Id).Type__c == 'This donation, and all future & historic' )||  gift.Type__c == 'This donation, and all future & historic')
                    {
                        giftaidlist.add(gift);
                        contactset.add(gift.Donor__c);
                        contactgiftmap.put(gift,gift.Donor__c);
                    }
                }
             }
            
            transactionlist=[SELECT id, name , causeview__Constituent__c,(select id,name ,Gift_Aid_Claim_Status__c,Gift_Aid_Declaration__c,causeview__Date__c from causeview__Recurring_Payments__r where Gift_Aid_Claim_Status__c = 'Not claimed') FROM causeview__Gift__c where causeview__Constituent__c In :contactset];
            mycon=[select id, name , (select id, name from  causeview__Gifts__r) from contact where id In :contactset];
            
            for(contact mycon2:mycon)
            {
                contransmap.put(mycon2.id, mycon2.causeview__Gifts__r);
            }
            
            for(causeview__Gift__c t:transactionlist)
            {
                transactionind.put(t.causeview__Constituent__c, t);
                transpaymnetmap.put(t.Id, t.causeview__Recurring_Payments__r);
            }
            
            List<causeview__payment__c> mypay2=new List<causeview__payment__c> ();
            if(trigger.isInsert) 
            {
                for(Gift_Aid_Declaration__c gg:giftaidlist)
                {
                    Id cc=contactgiftmap.get(gg); 
                    List<causeview__Gift__c> mytransaction = contransmap.get(cc);
                    
                    if(mytransaction.size() >0) 
                    {
                        for(causeview__Gift__c trans:mytransaction)
                        {
                            List<causeview__payment__c> mypay= transpaymnetmap.get(trans.Id);
                            if(mypay != null)
                            {
                                if(mypay.size() > 0) 
                                {
                                    for(causeview__payment__c p: mypay)
                                    {
                                        if(p.causeview__Date__c >= gg.Effective_Date__c && p.Gift_Aid_Declaration__c == null)
                                        {
                                             p.Gift_Aid_Declaration__c= gg.Id;
                                             mypay2.add(p);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }//is insert
            
            else if(trigger.isUpdate) 
            {
                system.debug('am inside update2');
                for(Gift_Aid_Declaration__c gg:giftaidlist)
                {
                    system.debug('gg effective date: ---' + gg.Effective_Date__c);
                    Id cc=contactgiftmap.get(gg); 
                    List<causeview__Gift__c> mytransaction = contransmap.get(cc);
                    
                    if(mytransaction.size() >0) 
                    {
                        for(causeview__Gift__c trans:mytransaction)
                        {
                        
                            List<causeview__payment__c> mypay= transpaymnetmap.get(trans.Id);
                            if(mypay != null)
                            {
                                if(mypay.size() > 0) 
                                {
                                    for(causeview__payment__c p: mypay)
                                    { 
                                        system.debug('payment date---'+p.causeview__Date__c);
                                        if( (p.causeview__Date__c <  gg.Effective_Date__c) && gg.Type__c == 'This donation, and all future' && p.Gift_Aid_Declaration__c != NULL)
                                        {
                                             p.Gift_Aid_Declaration__c= null;
                                             mypay2.add(p);
                                        }
                                        else if(p.causeview__Date__c >= gg.Effective_Date__c  && p.Gift_Aid_Declaration__c == NULL)
                                        {
                                            p.Gift_Aid_Declaration__c= gg.Id;
                                            mypay2.add(p);
                                        } 
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(mypay2.size() >0) 
                {
                    AllocationUpdateList = [SELECT id,name,causeview__Payment__c FROM causeview__Gift_Detail__c where causeview__Payment__c In :mypay2]; 
                }
            }//is update
               
            if(mypay2.size() >0) 
            {
               update mypay2;
            }               
            if(AllocationUpdateList.size() > 0 ) 
            {
               update AllocationUpdateList;
            }
        } //is after trigger
    }
}