/*
    
    When a recurring donation is updated and the amount is different, update the new amount to each allocation
    
    percentage = allocation.Value / donation.OldAmount;
    
    allocation.Value = donation.NewAmout * percentage;
    
*/

trigger updateRDAllocationsTrigger on causeview__Recurring_Donation__c (after update,before update, before insert) {
/*    
    Set<String> donationIDs = new Set<String>();        
    
    for(causeview__Recurring_Donation__c donation: trigger.new){
        
        causeview__Recurring_Donation__c oldDonation = (causeview__Recurring_Donation__c)Util.FindObject(trigger.old, donation.Id, 'Id');
                
        if(donation.causeview__Amount__c != oldDonation.causeview__Amount__c)
            donationIDs.add(donation.Id);       
    }
    
    List<causeview__RD_Allocation__c> allocations = [SELECT id, causeview__Amount__c, causeview__Recurring_Gift__c FROM causeview__RD_Allocation__c WHERE causeview__Recurring_Gift__c IN :donationIDs];
    
    
    // loop through the donations, and if there's a change in amount, reassign the amount of the allocations to the new percentages
    for(causeview__Recurring_Donation__c donation: trigger.new){
        
        causeview__Recurring_Donation__c oldDonation = (causeview__Recurring_Donation__c)Util.FindObject(trigger.old, donation.Id, 'Id');
        
            for(causeview__RD_Allocation__c allocation : allocations){
                
                // for every allocation related to this donation, assign the new amount 
                if(allocation.causeview__Recurring_Gift__c == donation.Id){
                    
                    if(allocation.causeview__Amount__c != null && oldDonation.causeview__Amount__c != null){
                        Double percentage = allocation.causeview__Amount__c / oldDonation.causeview__Amount__c; 
                        allocation.causeview__Amount__c = donation.causeview__Amount__c * percentage;
                    }
                }
            }       
    }
    
    update allocations; 
    */
    if(Trigger.isBefore && Trigger.isupdate) {
    
    List<Gift__c> GiftIds = new List<Gift__c>();
    
    set<Id> RDIds = new Set<id>();
    
    


    for(Recurring_Donation__c Rd : trigger.New)
    {
        Recurring_Donation__c RDold = Trigger.oldMap.get(Rd.Id);
        
        if((Rd.causeview__Frequency__c != Rdold.causeview__Frequency__c)|| (Rd.causeview__New_Payment_Start_Date__c != Rdold.causeview__New_Payment_Start_Date__c) ||(Rd.causeview__Start_Date__c != Rdold.causeview__Start_Date__c) ) 
        {
            RDIds.add(Rd.Id);
        }
        else if((RD.causeview__Schedule_Date__c != Rdold.causeview__Schedule_Date__c))
           {
             
                 for(Recurring_Donation__c r:Trigger.New)
                   { 
                    if(r.causeview__Next_Payment_Date__c != null){
                        r.causeview__Next_Payment_Date__c = Date.newinstance((r.causeview__Next_Payment_Date__c).Year(),(r.causeview__Next_Payment_Date__c).month(), Integer.Valueof(r.causeview__Schedule_Date__c)); 
                    } 
                   }
           }
    }
       
     if(RDIds.size() > 0 )  
     {
        Map<Id,causeview__Recurring_Donation__c>   RDMap =  new Map<Id,causeview__Recurring_Donation__c>([SELECT id,name ,causeview__Status__c, causeview__Frequency__c, causeview__New_Payment_Start_Date__c, causeview__Next_Payment_Date__c , causeview__Schedule_Date__c, causeview__Start_Date__c, (select Id,Name,causeview__Status__c,causeview__Gift_Date__c from  causeview__Orders__r where causeview__Status__c='active' and causeview__Gift_Date__c = THIS_YEAR ORDER BY causeview__Gift_Date__c DESC limit 1) FROM causeview__Recurring_Donation__c where Id IN :RDIds and Status__c ='Active']);
        
        map<Id,Gift__c>  GiftMap = new map<Id,Gift__c>([select id, name , Recurring_Donation__c,(select Id,Name, causeview__Date__c FROM Recurring_Payments__r  Order By causeview__Date__c DESC  NULLS LAST limit 1) From Gift__c where Recurring_Donation__c IN :RDIds]);    
        for(Recurring_Donation__c Rd : trigger.New)
        {
             
             if(RDmap.containsKey(Rd.Id) && (RDmap.get(Rd.Id).causeview__Orders__r != null && RDmap.get(Rd.Id).causeview__Orders__r.size()>0 ) )
             { 
                Gift__c  gift = RDmap.get(Rd.Id).causeview__Orders__r;
                if(GiftMap.get(gift.Id).Recurring_Payments__r != null && GiftMap.get(gift.Id).Recurring_Payments__r.size() > 0 )
                {
                Payment__c  p= GiftMap.get(gift.Id).Recurring_Payments__r;
                
                Integer addmm = 0; 
                
                if(Rd.causeview__Frequency__c == 'Monthly') {
                     addmm = 01; 
                } 
                else if (Rd.causeview__Frequency__c == 'Quarterly') {  
                      addmm = 03;
                }
                else { 
                      addmm = 12; 
                }
                
                if(Rd.causeview__New_Payment_Start_Date__c != null){            
                    Rd.causeview__Next_Payment_Date__c = Date.newinstance((Rd.causeview__New_Payment_Start_Date__c).Year() , (p.causeview__Date__c).month()+addmm, (Rd.causeview__New_Payment_Start_Date__c).day());                    
                }                
                else if(Rd.causeview__Start_Date__c > system.Today()) {
                    Rd.causeview__Next_Payment_Date__c = Rd.causeview__Start_Date__c;                    
                }
                else{
                    Rd.causeview__Next_Payment_Date__c = Date.newinstance((Rd.causeview__Start_Date__c).Year() , (p.causeview__Date__c).month()+addmm, (Rd.causeview__Start_Date__c).day());                    
                }
            } 
            else {
                   if(Rd.causeview__Start_Date__c != null) 
                   {
                     Rd.causeview__Next_Payment_Date__c = Rd.causeview__Start_Date__c;                     
                   }
                 else
                   {
                    Rd.causeview__Next_Payment_Date__c = Rd.causeview__New_Payment_Start_Date__c;                    
                    }
                  }
            
          }
       } 
    }     
 }
 
 if(Trigger.isBefore && Trigger.isInsert){  
      for(Recurring_Donation__c Rd : trigger.New){
        if(Rd.causeview__Start_Date__c != null){
             Rd.causeview__Next_Payment_Date__c = Rd.causeview__Start_Date__c;             
         }
         else{
             Rd.causeview__Next_Payment_Date__c = Rd.causeview__New_Payment_Start_Date__c;            
         }
              
         if(Rd.causeview__Next_Payment_Date__c !=null){
             Rd.causeview__Schedule_Date__c=(Rd.causeview__Next_Payment_Date__c).day();
         }
       }  
  }
  
  if(Trigger.isBefore && Trigger.isupdate){
      for(Recurring_Donation__c Rd : trigger.New){
          if(Rd.causeview__Next_Payment_Date__c!=trigger.oldMap.get(RD.id).causeview__Next_Payment_Date__c && Rd.causeview__Status__c == 'Active'){              
              if(Rd.causeview__Next_Payment_Date__c != null){ 
                Rd.causeview__Schedule_Date__c=(Rd.causeview__Next_Payment_Date__c).day();             
             }     
          }  
      }
    
  }

}
