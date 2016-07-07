trigger RollupTotalGiving on Gift__c (after update) {//after delete, after insert, after undelete (Removed for optimization)
    set<ID> ids = new set<ID>();    
    Set<Id> contactIds = new Set<Id>();
    Set<Id> orgIds = new Set<Id>();
    set<Id> hhIds = new Set<Id>();
    set<Id> giftId = new set<Id>();
    Set<String> receiptReadyGifts = new Set<String>();
    List<Gift__c> solicitsGifts = new List<Gift__c>();
    List<Gift__c> solicitsGiftsforOrganisation = new List<Gift__c>();
    List<Gift__c> solicitsGiftsforIndividual = new List<Gift__c>();
    List<Gift__c> updatedGifts = new List<Gift__c>();
    
    BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
    
    
    if (settings != null)
    {
        if (!settings.causeview__Data_Migration_Mode__c)
        {
            
            if (trigger.isUpdate) 
            {    
                    
                    for (Integer i = 0; i < Trigger.new.size(); i++) {
                        if (Trigger.old[i].Gift_Date__c != Trigger.new[i].Gift_Date__c || Trigger.old[i].Amount__c != Trigger.new[i].Amount__c) {
                            updatedGifts.add(Trigger.new[i]);
                            
                        }
                        //Story 110427988 
                         if(Trigger.new[i].Gift_Type__c != 'Recurring') {
                        if (Trigger.new[i].Amount__c > 0 && trigger.old[i].Amount__c == 0) {
                           if (Trigger.new[i].Recurring_Donation__c == null) { 
                               receiptReadyGifts.add(Trigger.new[i].Id); 
                           }
                           
                           if(Trigger.new[i].causeview__Organization__c != null){
                               solicitsGiftsforOrganisation.add(Trigger.new[i]);
                           }
                           else{
                               solicitsGiftsforIndividual.add(Trigger.new[i]);
                           }
                           
                           }
                           
                           }
                           else
                           {
                            if (Trigger.new[i].Amount__c > 0 && trigger.old[i].Amount__c == 0 && Trigger.new[i].Recurring_Donation__c != null && Trigger.new[i].Recurring_Donation__r.causeview__Start_Date__c < system.Today() ) {
                           if (Trigger.new[i].Recurring_Donation__c == null) { 
                               receiptReadyGifts.add(Trigger.new[i].Id); 
                           }
                           
                           if(Trigger.new[i].causeview__Organization__c != null){
                               solicitsGiftsforOrganisation.add(Trigger.new[i]);
                           }
                           else{
                               solicitsGiftsforIndividual.add(Trigger.new[i]);
                           }
                           
                           }
                           }
                        
                        /*if (solicitsGifts.size()>0) {
                            system.debug('<==organisation Id==>'+Trigger.new[i].causeview__Organization__c);
                            //# Check if gift donated by organization or individual
                            if (Trigger.new[i].causeview__Organization__c != null){
                                RollupHelper.CreateOrganizationSoftCredits(solicitsGifts); 
                             }
                            else{
                                RollupHelper.CreateIndividualSoftCredits(solicitsGifts);
                            }
                            solicitsGifts.clear()
                        }*/
                    }              
                
            }
            
            if (solicitsGiftsforOrganisation.size()>0) {
                if(!Validator_cls.isalreadyFiredRollupTotalGiving()){
                    Validator_cls.setalreadyFiredRollupTotalGiving();
                    RollupHelper.CreateOrganizationSoftCredits(solicitsGiftsforOrganisation); 
                }
             }
             if (solicitsGiftsforIndividual.size()>0) {
                 if(!Validator_cls.isalreadyFiredRollupTotalGiving()){
                    Validator_cls.setalreadyFiredRollupTotalGiving();
                    RollupHelper.CreateIndividualSoftCredits(solicitsGiftsforIndividual);
                }
            }

            
            /*
            else if (trigger.isUnDelete || trigger.isInsert)
            {
                for (Gift__c g : trigger.new) {
                    if (g.Amount__c > 0 && g.Gift_Date__c != null) {
                        updatedGifts.add(g);
                    }
                }
            }
            else if (trigger.isDelete) {
                for (Gift__c g : trigger.old) {
                    if (g.Amount__c > 0 && g.Gift_Date__c != null) {
                        receiptReadyGifts.add(g);
                    }
                }
            }
            
           
  
            
            if (hhIds.size()>0){
                RollupHelper.RecalculateTotalHouseholdGiving(hhIds);
            }
            
            
            
             for (Gift__c g : updatedGifts) {
                
                //.add(g.Constituent__c);
                contactIds.add(g.Primary_Solicitor__c);
                orgIds.add(g.Organization__c);
                hhIds.add(g.HouseholdId__c);
                Ids.add(g.Id);
            }            
            
            List<Solicitor__c> softCredits = [SELECT Id, Solicitor__c, Gift__c From Solicitor__c WHERE Gift__c IN :Ids];
            if (softCredits != null) {
                for(Solicitor__c s : softCredits) {
                    if (!contactIds.contains(s.Solicitor__c) && !RollupHelper.IsEmptyOrNull(s.Solicitor__c)) {
                        contactIds.add(s.Solicitor__c);            
                    }
                }
            }
          
            if (contactIds.size()>0) {
                RollupHelper.RecalculateTotalGiving(contactIds);
                   
            }       
        
             if (orgIds.size()>0){
                RollupHelper.RecalculateTotalGivingForOrg(orgIds);
                RollupHelper.RecalculateGiftDatesForOrg(orgIds);
            }
            */
            
            
            
            //new receipts to be issued
            if (receiptReadyGifts.size()>0)
            {
                
                Map<id, Receipt__c> rs =new Map<id, Receipt__c>( [Select Id From Receipt__c WHERE Gift__c IN :receiptReadyGifts FOR UPDATE]);
                
                /*Set<Id> receiptIds = new Set<Id>();
                receiptIds.
                for(receipt__c r : rs)
                receiptIds.add(r.Id);*/
                if (rs.keyset().size()>0)
                RollupHelper.issueReceipts(rs.keyset());
            }
        }
    }
    
}