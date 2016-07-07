/*
trigger to auto assign the correct GL Debit and GL Credit values on the Allocation records.
The trigger fires on Allocation create or update
The trigger only fires if Custom Settings value: cv_pkg_dev_I__BatchSettings__c.cv_pkg_dev_I__Data_Migration_Mode__c = FALSE
Based on the Gift Recordtype, Gift Type and Payment Type values, the trigger takes the correct GL Debit 
and GL Credit values from the Fund record (cv_pkg_dev_I__Gift_Detail__c.cv_pkg_dev_I__Fund__c) 
and populate them into cv_pkg_dev_I__GL_Auto_Credit_Account__c and cv_pkg_dev_I__GL_Auto_Debit_Account__c fields.
*/
trigger GLfieldUpdateOnAllocationTrigger on Gift_Detail__c (before insert, before update) {
    
    if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c){
        set<id> giftIds = new set<id>();
        set<id> paymentIds = new set<id>();
        set<id> fundIds = new set<id>();
        set<Id> installment_Ids = new set<Id>();
        set<id> refundPaymentIds = new set<id>();
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR  Name = 'Matching Gift' OR Name = 'Refund') AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.name, r.id);
        }
        system.debug('Nitin==>'+rtypes_Map);
        for(Gift_Detail__c g : trigger.new){
            if(Trigger.isInsert){
                giftIds.add(g.Gift__c); 
                paymentIds.add(g.Payment__c);   
                fundIds.add(g.Fund__c);
                installment_Ids.add(g.Installment__c);
            }
            if(Trigger.isUpdate && (g.Gift__c <> Trigger.oldMap.get(g.id).Gift__c || g.Payment__c <> Trigger.oldMap.get(g.id).Payment__c || g.Fund__c <> Trigger.oldMap.get(g.id).Fund__c)){
                giftIds.add(g.Gift__c); 
                paymentIds.add(g.Payment__c);   
                fundIds.add(g.Fund__c);
            }
        }
        system.debug('fundIds==>'+fundIds);
        if(giftIds.size() > 0 && paymentIds.size() > 0 && fundIds.size() > 0){
            Map<Id, Gift__c> giftRecordMap = new Map<Id, Gift__c>([select Id, Gift_Type__c, RecordTypeId, cv_pkg_dev_I__Gift_Date__c from Gift__c where Id IN: giftIds]);
            Map<Id, Payment__c> paymentRecordMap = new Map<Id, Payment__c>([select Id, Payment_Type__c, Payment_Refunded__c, Status__c, Date__c, RecordTypeId, (select Id from Installment_Fulfillments__r) from Payment__c where Id IN: paymentIds]);
            for(Payment__c p : paymentRecordMap.values()){
                if(p.Status__c == 'Refunded' && p.Payment_Refunded__c != null){
                    refundPaymentIds.add(p.Payment_Refunded__c);
                }
            }
            Map<Id, Installment__c> installment_Record_Map = new Map<Id, Installment__c>([select Id from Installment__c where Id IN: installment_Ids]);
            Map<Id, Payment__c> refundedPaymentRecordMap = new Map<Id, Payment__c>([select Id, Payment_Type__c, Payment_Refunded__c, Status__c, Date__c, RecordTypeId, (select cv_pkg_dev_I__Fund__c, GL_Auto_Credit_Account__c, GL_Auto_Debit_Account__c from Allocations__r) from Payment__c where Id IN: refundPaymentIds]);
            Map<Id, Fund__c> fundRecordMap = new Map<Id, Fund__c>([select GL_Credit__c, GL_Debit__c, GL_In_Kind_Credit__c, GL_In_Kind_Debit__c, GL_Matching_Pledge_Cash_Credit__c, GL_Matching_Pledge_Cash_Debit__c,
                                            GL_Matching_Pledge_In_Kind_Credit__c, GL_Matching_Pledge_In_Kind_Debit__c, GL_Matching_Pledge_Property_Credit__c, GL_Matching_Pledge_Property_Debit__c,
                                            GL_Matching_Pledge_Stock_Credit__c, GL_Matching_Pledge_Stock_Debit__c, GL_Matching_Pledge_Write_off_Credit__c, GL_Matching_Pledge_Write_off_Debit__c,
                                            GL_Other_Credit__c, GL_Other_Debit__c, GL_Pledge_Credit__c, GL_Pledge_Debit__c, GL_Pledge_In_Kind_Credit__c, GL_Pledge_In_Kind_Debit__c, GL_Pledge_Property_Credit__c,
                                            GL_Pledge_Property_Debit__c, GL_Pledge_Stock_Credit__c, GL_Pledge_Stock_Debit__c, GL_Pledge_Write_off_Credit__c, GL_Pledge_Write_off_Debit__c, GL_Recurring_Credit__c, GL_Stock_Credit__c, GL_Stock_Debit__c,
                                            GL_Recurring_Debit__c, GL_Matching_Pledge_Current_Fiscal__c, GL_Matching_Pledge_Current_Fiscal_Debit__c, GL_Pledge_Current_Fiscal_Credit__c, GL_Property_Credit__c, GL_Property_Debit__c,
                                            GL_Pledge_Current_Fiscal_Debit__c from Fund__c where Id IN: fundIds]);
                                  
            for(Gift_Detail__c g : trigger.new){
                if(giftRecordMap.get(g.Gift__c) != null && fundRecordMap.get(g.Fund__c) != null && (paymentRecordMap.get(g.Payment__c) != null || installment_Record_Map.get(g.Installment__c) != null)){
                    Gift__c giftRecord = giftRecordMap.get(g.Gift__c);
                    Fund__c fundRecord = fundRecordMap.get(g.Fund__c);
                    if(paymentRecordMap.get(g.Payment__c) != null){
                        Payment__c paymentRecord = paymentRecordMap.get(g.Payment__c);
                        if(!(paymentRecord.Installment_Fulfillments__r.size() > 0)){
                            if(paymentRecord.RecordTypeId != rtypes_Map.get('Refund')){
                                system.debug('Inside Tirgger');
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_In_Kind_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_In_Kind_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Other' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Other_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Other_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Stock_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Stock_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Property_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Property_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Cash_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Cash_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_In_Kind_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_In_Kind_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Stock_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Stock_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Property_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Property_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Write_off_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Write_off_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Write_off_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Write_off_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_In_Kind_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_In_Kind_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Stock_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Stock_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Property_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Property_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Recurring' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Recurring_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Recurring_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Committed'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal_Debit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Committed'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Debit__c;
                                }
                            }
                           /* else{
                                system.debug('<=Inside else=>');
                                if(Trigger.isInsert){
                                    if(refundedPaymentRecordMap.get(paymentRecord.Payment_Refunded__c) != null){
                                        Payment__c refundedPaymentRecord = refundedPaymentRecordMap.get(paymentRecord.Payment_Refunded__c);
                                        if(refundedPaymentRecord.Allocations__r.size() > 0){
                                            Gift_Detail__c refundedPaymentGiftDetailRecord = refundedPaymentRecord.Allocations__r[0];
                                                g.GL_Auto_Credit_Account__c = refundedPaymentGiftDetailRecord.GL_Auto_Debit_Account__c;  
                                                g.GL_Auto_Debit_Account__c = refundedPaymentGiftDetailRecord.GL_Auto_Credit_Account__c;
                                        }
                                    }
                                }
                            }*/
                            //Enhanced Fund Accounting: Refunds with multiple allocations not correctly reversing the GL codes
                            else{
                                system.debug('<=Inside else edit=>');
                                if(Trigger.isInsert){
                                    if(refundedPaymentRecordMap.get(paymentRecord.Payment_Refunded__c) != null){
                                        Payment__c refundedPaymentRecord = refundedPaymentRecordMap.get(paymentRecord.Payment_Refunded__c);
                                        if(refundedPaymentRecord.Allocations__r.size() > 0){
                                        	for(Gift_Detail__c gg:refundedPaymentRecord.Allocations__r) {
                                        		if(gg.Fund__c != null && gg.Fund__c == g.Fund__c)
                                        		{
	                                                g.GL_Auto_Credit_Account__c = gg.GL_Auto_Debit_Account__c;  
	                                                g.GL_Auto_Debit_Account__c = gg.GL_Auto_Credit_Account__c;
                                        		}
                                        	}
                                        }
                                    }
                                }
                            }
                            
                            
                            
                        }else
                        {
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_In_Kind_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Other' && paymentRecord.Status__c == 'Approved'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Other_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Stock_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Property_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_In_Kind_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Stock_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Property_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Write_off_Credit__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            }
                        }
                    }else
                    if(installment_Record_Map.get(g.Installment__c) != null){
                        //Installment__c installment_Record = installment_Record_Map.get(g.Installment__c);
                        if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Pledge'){
                            g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                            g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Debit__c;
                        }else
                        if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge'){
                            g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal__c;
                            g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal_Debit__c;
                        }
                    }
                }
            }
        }
    }
}
