trigger GLAllocationfieldUpdateTrigger on Payment__c (after update) {
    
    if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c){
        set<id> giftIds = new set<id>();
        set<id> paymentIds = new set<id>();
        set<id> fundIds = new set<id>();
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR  Name = 'Matching Gift' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.name, r.id);
        }
        system.debug('Nitin==>'+rtypes_Map);
        for(Payment__c g : trigger.new){
            if(Trigger.isUpdate && g.cv_pkg_dev_I__Status__c <> Trigger.oldMap.get(g.Id).cv_pkg_dev_I__Status__c){
                paymentIds.add(g.id);
            }
        }
        
        if(paymentIds.size() > 0){
            Map<Id, List<cv_pkg_dev_I__Gift_Detail__c>> giftDetailRecordMap = new Map<Id, List<cv_pkg_dev_I__Gift_Detail__c>>();
            List<cv_pkg_dev_I__Gift_Detail__c> giftDetailRecordListToUpdate = new List<cv_pkg_dev_I__Gift_Detail__c>();
            for(cv_pkg_dev_I__Gift_Detail__c gd : [select cv_pkg_dev_I__Gift__c, cv_pkg_dev_I__Payment__c, cv_pkg_dev_I__Fund__c, cv_pkg_dev_I__GL_Auto_Credit_Account__c, cv_pkg_dev_I__GL_Auto_Debit_Account__c, cv_pkg_dev_I__Posted_to_Finance__c from cv_pkg_dev_I__Gift_Detail__c where cv_pkg_dev_I__Payment__c IN: paymentIds FOR UPDATE]){
                if(!giftDetailRecordMap.containsKey(gd.cv_pkg_dev_I__Payment__c)){
                    giftDetailRecordMap.put(gd.cv_pkg_dev_I__Payment__c, new List<cv_pkg_dev_I__Gift_Detail__c>());
                }
                giftDetailRecordMap.get(gd.cv_pkg_dev_I__Payment__c).add(gd);
                fundIds.add(gd.cv_pkg_dev_I__Fund__c);
                giftIds.add(gd.cv_pkg_dev_I__Gift__c); 
            }
            Map<Id, Gift__c> giftRecordMap = new Map<Id, Gift__c>([select Id, Gift_Type__c, RecordTypeId from Gift__c where Id IN: giftIds]);
            Map<Id, Fund__c> fundRecordMap = new Map<Id, Fund__c>([select GL_Credit__c, GL_Debit__c, GL_In_Kind_Credit__c, GL_In_Kind_Debit__c, GL_Matching_Pledge_Cash_Credit__c, GL_Matching_Pledge_Cash_Debit__c,
                                            GL_Matching_Pledge_In_Kind_Credit__c, GL_Matching_Pledge_In_Kind_Debit__c, GL_Matching_Pledge_Property_Credit__c, GL_Matching_Pledge_Property_Debit__c,
                                            GL_Matching_Pledge_Stock_Credit__c, GL_Matching_Pledge_Stock_Debit__c, GL_Matching_Pledge_Write_off_Credit__c, GL_Matching_Pledge_Write_off_Debit__c, GL_Stock_Credit__c, GL_Stock_Debit__c,
                                            GL_Other_Credit__c, GL_Other_Debit__c, GL_Pledge_Credit__c, GL_Pledge_Debit__c, GL_Pledge_In_Kind_Credit__c, GL_Pledge_In_Kind_Debit__c, GL_Pledge_Property_Credit__c, GL_Property_Credit__c, GL_Property_Debit__c,
                                            GL_Pledge_Property_Debit__c, GL_Pledge_Stock_Credit__c, GL_Pledge_Stock_Debit__c, GL_Pledge_Write_off_Credit__c, GL_Pledge_Write_off_Debit__c, GL_Recurring_Credit__c,
                                            GL_Recurring_Debit__c, GL_Matching_Pledge_Current_Fiscal__c, GL_Matching_Pledge_Current_Fiscal_Debit__c, GL_Pledge_Current_Fiscal_Credit__c, GL_Pledge_Current_Fiscal_Debit__c from Fund__c where Id IN: fundIds]);
                 
                  Map<id, List<cv_pkg_dev_I__Installment_Fulfillment__c>> installmentmap=new map<id, List<cv_pkg_dev_I__Installment_Fulfillment__c>>();
                 for(cv_pkg_dev_I__Installment_Fulfillment__c fulfilment: [select id, cv_pkg_dev_I__Payment__c from cv_pkg_dev_I__Installment_Fulfillment__c where cv_pkg_dev_I__Payment__c In : paymentIds ])
                 {
                    if(!installmentmap.containsKey(fulfilment.cv_pkg_dev_I__Payment__c))
                    {
                    installmentmap.put(fulfilment.cv_pkg_dev_I__Payment__c, new List<cv_pkg_dev_I__Installment_Fulfillment__c>());
                    }
                    installmentmap.get(fulfilment.cv_pkg_dev_I__Payment__c).add(fulfilment);
                 }          
                                  
                                  
            for(Payment__c paymentRecord : trigger.new){
                if( giftDetailRecordMap.get(paymentRecord.Id) != null){
                    List<cv_pkg_dev_I__Gift_Detail__c> giftDetailRecordList = giftDetailRecordMap.get(paymentRecord.Id);
                    for(cv_pkg_dev_I__Gift_Detail__c g : giftDetailRecordList){
                        if(giftRecordMap.get(g.cv_pkg_dev_I__Gift__c) != null && fundRecordMap.get(g.Fund__c) != null){
                        
                            Gift__c giftRecord = giftRecordMap.get(paymentRecord.cv_pkg_dev_I__Donation__c);
                            system.debug('am here in if loop -----' + installmentmap.size() );
                             if(installmentmap.get(paymentRecord.Id) == null ||  !(installmentmap.get(paymentRecord.Id).size() > 0)){
                            
                            Fund__c fundRecord = fundRecordMap.get(g.Fund__c);
                            
                            
                            system.debug('am here inside');
                            if(paymentRecord.RecordTypeId != rtypes_Map.get('Refund')){
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_In_Kind_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_In_Kind_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Other' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Other_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Other_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Stock_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Stock_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Property_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Property_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Cash_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Cash_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_In_Kind_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_In_Kind_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Stock_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Stock_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Property_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Property_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Write_off_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Write_off_Debit__c;
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Write_off_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Write_off_Debit__c;
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_In_Kind_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_In_Kind_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Stock_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Stock_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Property_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Property_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Recurring' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Recurring_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Recurring_Debit__c;
                                    if(Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Committed' || Trigger.oldMap.get(paymentRecord.id).cv_pkg_dev_I__Status__c == 'Pending'){
                                        g.cv_pkg_dev_I__Posted_to_Finance__c = null;
                                    }
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Committed'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal_Debit__c;
                                    giftDetailRecordListToUpdate.add(g);
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Committed'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Debit__c;
                                    giftDetailRecordListToUpdate.add(g);
                                }
                            }
                        }
                        }
                    }
                }
            }
            if(giftDetailRecordListToUpdate.size() > 0){
                update giftDetailRecordListToUpdate;
            }
        }
    }
}