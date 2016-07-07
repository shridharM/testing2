trigger GiftAidUpdates on Gift_Aid_Declaration__c (after insert,after update) {

   causeview__App_Settings__c appSetting = causeview__App_Settings__c.getInstance();
   if(appSetting.causeview__Gift_Aid_Enable__c) 
    {

   
   List<Gift_Aid_Declaration__c> giftaidlist= new List<Gift_Aid_Declaration__c> ();  
   set<id> contactset = new set<id> ();
   map<Gift_Aid_Declaration__c,id> contactgiftmap = new map<Gift_Aid_Declaration__c,id> ();
   

   for(Gift_Aid_Declaration__c gift:trigger.new)
   {
     if(gift.Type__c == 'This donation, and all future & historic' )
     {
     giftaidlist.add(gift);
     contactset.add(gift.Donor__c);
     contactgiftmap.put(gift,gift.Donor__c);
     }
   }
     
 
  map<Id, List<causeview__payment__c>> transpaymnetmap = new map<Id, List<causeview__payment__c>>();
  map<id,causeview__Gift__c> transactionind= new map<id,causeview__Gift__c> ();
  
  list<causeview__Gift__c> transactionlist=[SELECT id, name , causeview__Constituent__c,(select id,name ,Gift_Aid_Claim_Status__c,Gift_Aid_Declaration__c,causeview__Date__c from causeview__Recurring_Payments__r where Gift_Aid_Claim_Status__c = 'Not claimed' AND Gift_Aid_Declaration__c = null )  FROM causeview__Gift__c where causeview__Constituent__c In :contactset];
 
 
  map<id,List<causeview__Gift__c>> contransmap=new map<id,List<causeview__Gift__c>>();
  List<contact> mycon=[select id, name , (select id, name from  causeview__Gifts__r) from contact where id In :contactset];
  
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
                                          if(p.causeview__Date__c >= gg.Effective_Date__c)
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
  
  
  update mypay2;
  }
}