/*This trigger is to update credit card number and credit card type on 
Credit Card Number, credit card type field on Gift record. 
*/
trigger creditDetailUpdationOnGift on Payment__c (after Insert,before insert,after update) {
    
    set<Id> giftIds = new set<Id>();
    Set<Gift__c> giftSet = new Set<Gift__c>();
    
    set<ID> giftRecordsIds= new set<Id>();
    
    Set<Id> RdIds = new set<Id>();
    Set<Id> PaymentIds = new Set<Id>();
   
    
    //adding gift id to giftIds if the causeview__Payment_Type__c == 'Credit Card' and causeview__Credit_Card_Number__c != null 
    //on insertion or updation of record
    
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Schema.SObjectType mcEnabled = gd.get('CurrencyType');
    Boolean MultiCurrencyEn = (mcEnabled !=  null)? true : false ;
    
    if(Trigger.isInsert){
         
         if(Trigger.isBefore && MultiCurrencyEn) 
         {
           Map<String,String> CurrencyConversionRate = new Map<String,String>();
           for(Sobject c : Database.query('SELECT IsoCode,ConversionRate,Id FROM CurrencyType'))
             {
               CurrencyConversionRate.put(String.ValueOf(c.get('IsoCode')), String.ValueOf(c.get('ConversionRate')));
             }
           
            for(Sobject payment : Trigger.new){
           
            //Payment.put('PaymentConversionRate__c',CurrencyConversionRate.get(String.valueOf(payment.get('CurrencyIsoCode'))));
            
            Payment.put('PaymentConversionRate__c',Decimal.valueof(CurrencyConversionRate.get(String.valueOf(payment.get('CurrencyIsoCode')))));

           }
         }
         
      }
         if(Trigger.isAfter && Trigger.isInsert){
          for(Payment__c payment : Trigger.new){
          
           giftRecordsIds.add(payment.causeview__Donation__c);
           PaymentIds.add(payment.Id);
             
            if(payment.causeview__Payment_Type__c == 'Credit Card' && payment.causeview__Credit_Card_Number__c != null){
                giftIds.add(payment.causeview__Donation__c);
            }
        }
       } 
    
     if(Trigger.isAfter && Trigger.IsUpdate){
        for(Payment__c payment : Trigger.new){
          
           giftRecordsIds.add(payment.causeview__Donation__c);
           PaymentIds.add(payment.Id);
        }
    }
    //getting gift record into Map
    if(giftIds.size() > 0){
        RollupHelper.creditDetailUpdationOnGiftMethod(giftIds);
        //commented by nitin
        //List<Gift__c> giftRecords = new List<Gift__c>([SELECT  Id, causeview__Credit_Card_Number__c, causeview__Credit_Card_Type__c, (SELECT Credit_Card_Number__c, Credit_Card_Type__c, causeview__Donation__c  FROM Recurring_Payments__r  WHERE Payment_Type__c = :'Credit Card' ORDER BY CreatedDate DESC NULLS Last Limit 1) FROM Gift__c WHERE ID IN :giftIds]);
    }
    
    //Rd next payment date update Code
    
    if(giftRecordsIds.size() > 0 ) {
 
    system.debug('gift Ids-------'+giftRecordsIds);
 
    List<causeview__Recurring_Donation__c> RdupdateList = new List<causeview__Recurring_Donation__c>();
   
    List<Gift__c>  GiftList = [select id, name , Recurring_Donation__c,(select Id,Name, causeview__Date__c FROM Recurring_Payments__r Order By causeview__Date__c DESC NULLS Last  limit 1 ) From Gift__c where Id IN :giftRecordsIds AND causeview__Status__c='Active' AND causeview__Gift_Date__c = THIS_YEAR];
    
    for(Gift__c c: GiftList) 
    {
        RdIds.add(c.Recurring_Donation__c);
    }
    Map<Id,causeview__Recurring_Donation__c> RDmap = new Map<Id,causeview__Recurring_Donation__c>([SELECT id,name ,causeview__Status__c, causeview__Frequency__c, causeview__New_Payment_Start_Date__c, causeview__Next_Payment_Date__c , causeview__Schedule_Date__c, causeview__Start_Date__c FROM causeview__Recurring_Donation__c where Id IN :RdIds and Status__c ='Active']);
    
    if(GiftList.size() > 0) {
    
    for(Gift__c g: GiftList ) {
        if(RDmap.containsKey(g.Recurring_Donation__c)) {
    
           Recurring_Donation__c r = RDmap.get(g.Recurring_Donation__c);
           
           //Date NewDate = g.Recurring_Payments__r.causeview__Date__c ;
           
           Integer addmm = 0; 
           
           if(r.causeview__Frequency__c == 'Monthly') {
           
             addmm = 01; }
             
           else if (r.causeview__Frequency__c == 'Quarterly') {  
           
              addmm = 03;
           }
           
           else { addmm = 12; }
           
           
           if(r.causeview__New_Payment_Start_Date__c != null) 
           {
             payment__c p=g.causeview__Recurring_Payments__r;

             r.causeview__Next_Payment_Date__c = Date.newinstance((p.causeview__Date__c).Year() , (p.causeview__Date__c).month()+addmm, (r.causeview__New_Payment_Start_Date__c).day());
             r.causeview__Schedule_Date__c=(r.causeview__Next_Payment_Date__c).day();          
             RdupdateList.add(r);
          
          
           }
           
           else {
                   if(r.causeview__Start_Date__c > system.Today() ) {
                    r.causeview__Next_Payment_Date__c = r.causeview__Start_Date__c;
                    r.causeview__Schedule_Date__c=(r.causeview__Next_Payment_Date__c).day();
                   }
                  
                  else {
                  
                    payment__c p=g.causeview__Recurring_Payments__r;
                    r.causeview__Next_Payment_Date__c = Date.newinstance((p.causeview__Date__c).Year() , (p.causeview__Date__c).month()+addmm, (r.causeview__Start_Date__c).day());
                    r.causeview__Schedule_Date__c=(r.causeview__Next_Payment_Date__c).day();                     
                    } 
                    RdupdateList.add(r);
           
           }
       }
    }
   
   }
    system.debug('*******RD UPDATES*********');
    update RdupdateList;
    
    }
    
    
    
    //Assigning credit card number and credit card type to gift
    /*if(giftRecords.size() >0)
    {   
        for(Gift__c gift : giftRecords)
        { 
            Payment__c paymentRecord = gift.Recurring_Payments__r;
            gift.causeview__Credit_Card_Number__c = paymentRecord.Credit_Card_Number__c;
            gift.causeview__Credit_Card_Type__c = paymentRecord.Credit_Card_Type__c;
            giftRecordsToUpdate.add(gift);
        }
    } 
    if(giftRecordsToUpdate.size() > 0){
        update giftRecordsToUpdate; 
    }*/
}
