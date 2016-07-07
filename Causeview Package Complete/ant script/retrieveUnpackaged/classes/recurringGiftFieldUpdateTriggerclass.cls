public class recurringGiftFieldUpdateTriggerclass{
    @future
    public static void recurringGiftFieldUpdateForFuture(Set<Id> transactionIds){
        Set<Id> recurringGiftIds = new Set<Id>();
        Set<Id> transctionsIds = new Set<Id>();
        Map<Id, Map<Id, List<cv_pkg_dev_I__Payment__c>>> recurringGiftMap = new Map<Id, Map<Id, List<cv_pkg_dev_I__Payment__c>>>();
        if(transactionIds.size() > 0){
            //List of Transaction records and adding Recurring Gift Id into set of Id type
            //List<cv_pkg_dev_I__Gift__c> gifts = [select cv_pkg_dev_I__Recurring_Donation__c from cv_pkg_dev_I__Gift__c where Id IN: transactionIds];
            //system.debug('gifts==>'+gifts);
            for(cv_pkg_dev_I__Gift__c gift : [select cv_pkg_dev_I__Recurring_Donation__c, cv_pkg_dev_I__Status__c from cv_pkg_dev_I__Gift__c where Id IN: transactionIds AND cv_pkg_dev_I__Recurring_Donation__c != null AND cv_pkg_dev_I__Status__c = 'Active']){
                recurringGiftIds.add(gift.cv_pkg_dev_I__Recurring_Donation__c);
            }
            //List of Recurring Gift records and child Transaction records whose status is Active
            List<cv_pkg_dev_I__Recurring_Donation__c> recurringGifts = [select Id, cv_pkg_dev_I__Approved_Payments__c, cv_pkg_dev_I__Consecutive_Declined_Payments__c, cv_pkg_dev_I__Declined_Payments__c, (select cv_pkg_dev_I__Status__c from Orders__r where cv_pkg_dev_I__Status__c = 'Active') from cv_pkg_dev_I__Recurring_Donation__c where Id IN: recurringGiftIds FOR UPDATE];
            for(cv_pkg_dev_I__Recurring_Donation__c rg : recurringGifts){
                for(cv_pkg_dev_I__Gift__c gift : rg.Orders__r){
                    transctionsIds.add(gift.Id);    //adding gift Id into set of Id type
                }
            }
            //List of all payment records whose cv_pkg_dev_I__Donation__c Id in transctionsIds set
            //List<cv_pkg_dev_I__Payment__c> paymentRecord = [select cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Donation__c, CreatedDate, cv_pkg_dev_I__Date__c from cv_pkg_dev_I__Payment__c where cv_pkg_dev_I__Donation__c IN: transctionsIds order by cv_pkg_dev_I__Date__c DESC, CreatedDate DESC]; 
            Map<Id, List<cv_pkg_dev_I__Payment__c>> paymentRecordMap = new Map<Id, List<cv_pkg_dev_I__Payment__c>>();
            for(cv_pkg_dev_I__Payment__c paymentRecord : [select cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Donation__c, CreatedDate, cv_pkg_dev_I__Date__c from cv_pkg_dev_I__Payment__c where cv_pkg_dev_I__Donation__c IN: transctionsIds order by cv_pkg_dev_I__Date__c DESC, CreatedDate DESC]){
                if(!paymentRecordMap.containsKey(paymentRecord.cv_pkg_dev_I__Donation__c)){
                    paymentRecordMap.put(paymentRecord.cv_pkg_dev_I__Donation__c, new List<cv_pkg_dev_I__Payment__c>());
                }
                paymentRecordMap.get(paymentRecord.cv_pkg_dev_I__Donation__c).add(paymentRecord);
            }
            
            //Putting values into recurringGiftMap Map
            for(cv_pkg_dev_I__Recurring_Donation__c rg : recurringGifts){    //for loop for list of Recurring Gift Records
                if(!recurringGiftMap.containsKey(rg.id)){    //check recurringGiftMap Map contains Recurring Gift Record Id
                    recurringGiftMap.put(rg.id, new Map<Id, List<cv_pkg_dev_I__Payment__c>>());    //If don't contains than put Recurring Gift Record Id into recurringGiftMap
                }
                for(cv_pkg_dev_I__Gift__c gift : rg.Orders__r){    //for loop for list of Gift Records
                    if(!recurringGiftMap.get(rg.id).containsKey(gift.id)){    //check recurringGiftMap Map contains Gift Record Id
                        recurringGiftMap.get(rg.id).put(gift.id, new List<cv_pkg_dev_I__Payment__c>());    //If don't contains than put Gift Record Id into recurringGiftMap
                        
                    }  
                    if(paymentRecordMap.get(gift.Id) != null){
                        for(cv_pkg_dev_I__Payment__c payment : paymentRecordMap.get(gift.Id)){
                            recurringGiftMap.get(rg.id).get(gift.id).add(payment);
                        }
                    }
                }
            } 
            /* First for loop for Recurring Gift records and after that initially making value of cv_pkg_dev_I__Approved_Payments__c,cv_pkg_dev_I__Declined_Payments__c,cv_pkg_dev_I__Consecutive_Declined_Payments__c fields of Recurring Gift to zero,
               than next for loop for child Transactions of that Recurring Gift record. Than checking recurringGiftMap Map containing Recurring Gift Id and Gift Id. Than next for loop for child payments of a transaction.
               After all for loops, Checking the condition for approved, declined and consecutive declined payments. 
               */    
            if(recurringGifts.size() > 0){
                for(cv_pkg_dev_I__Recurring_Donation__c rgift : recurringGifts){
                    rgift.cv_pkg_dev_I__Approved_Payments__c = 0;
                    rgift.cv_pkg_dev_I__Declined_Payments__c = 0;
                    rgift.cv_pkg_dev_I__Consecutive_Declined_Payments__c = 0;
                    if(rgift.Orders__r.size() > 0){
                        for(cv_pkg_dev_I__Gift__c gift : rgift.Orders__r){
                            if(recurringGiftMap.get(rgift.id) != null && recurringGiftMap.get(rgift.id).get(gift.id) != null){
                                boolean isConsecutive = true;
                                for(cv_pkg_dev_I__Payment__c payment : recurringGiftMap.get(rgift.id).get(gift.Id)){
                                    if(payment.cv_pkg_dev_I__Status__c == 'Approved'){
                                        rgift.cv_pkg_dev_I__Approved_Payments__c += 1;
                                    }else
                                    if(payment.cv_pkg_dev_I__Status__c == 'Declined'){
                                        rgift.cv_pkg_dev_I__Declined_Payments__c += 1;
                                    }
                                    if(payment.cv_pkg_dev_I__Status__c == 'Declined' && isConsecutive){
                                        rgift.cv_pkg_dev_I__Consecutive_Declined_Payments__c += 1;
                                    }
                                    else{
                                        isConsecutive = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            try{
                update recurringGifts;    //updating the values in cv_pkg_dev_I__Approved_Payments__c,cv_pkg_dev_I__Declined_Payments__c,cv_pkg_dev_I__Consecutive_Declined_Payments__c fields in Recurring Gift Record
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
    }
    
    public static void recurringGiftFieldUpdate(Set<Id> transactionIds){
        Set<Id> recurringGiftIds = new Set<Id>();
        Set<Id> transctionsIds = new Set<Id>();
        Map<Id, Map<Id, List<cv_pkg_dev_I__Payment__c>>> recurringGiftMap = new Map<Id, Map<Id, List<cv_pkg_dev_I__Payment__c>>>();
        if(transactionIds.size() > 0){
            //List of Transaction records and adding Recurring Gift Id into set of Id type
            //List<cv_pkg_dev_I__Gift__c> gifts = [select cv_pkg_dev_I__Recurring_Donation__c from cv_pkg_dev_I__Gift__c where Id IN: transactionIds];
            //system.debug('gifts==>'+gifts);
            for(cv_pkg_dev_I__Gift__c gift : [select cv_pkg_dev_I__Recurring_Donation__c, cv_pkg_dev_I__Status__c from cv_pkg_dev_I__Gift__c where Id IN: transactionIds AND cv_pkg_dev_I__Recurring_Donation__c != null AND cv_pkg_dev_I__Status__c = 'Active']){
                recurringGiftIds.add(gift.cv_pkg_dev_I__Recurring_Donation__c);
            }
            //List of Recurring Gift records and child Transaction records whose status is Active
            List<cv_pkg_dev_I__Recurring_Donation__c> recurringGifts = [select Id, cv_pkg_dev_I__Approved_Payments__c, cv_pkg_dev_I__Consecutive_Declined_Payments__c, cv_pkg_dev_I__Declined_Payments__c, (select cv_pkg_dev_I__Status__c from Orders__r where cv_pkg_dev_I__Status__c = 'Active') from cv_pkg_dev_I__Recurring_Donation__c where Id IN: recurringGiftIds FOR UPDATE];
            for(cv_pkg_dev_I__Recurring_Donation__c rg : recurringGifts){
                for(cv_pkg_dev_I__Gift__c gift : rg.Orders__r){
                    transctionsIds.add(gift.Id);    //adding gift Id into set of Id type
                }
            }
            //List of all payment records whose cv_pkg_dev_I__Donation__c Id in transctionsIds set
            //List<cv_pkg_dev_I__Payment__c> paymentRecord = [select cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Donation__c, CreatedDate, cv_pkg_dev_I__Date__c from cv_pkg_dev_I__Payment__c where cv_pkg_dev_I__Donation__c IN: transctionsIds order by cv_pkg_dev_I__Date__c DESC, CreatedDate DESC]; 
            Map<Id, List<cv_pkg_dev_I__Payment__c>> paymentRecordMap = new Map<Id, List<cv_pkg_dev_I__Payment__c>>();
            for(cv_pkg_dev_I__Payment__c paymentRecord : [select cv_pkg_dev_I__Status__c, cv_pkg_dev_I__Donation__c, CreatedDate, cv_pkg_dev_I__Date__c from cv_pkg_dev_I__Payment__c where cv_pkg_dev_I__Donation__c IN: transctionsIds order by cv_pkg_dev_I__Date__c DESC, CreatedDate DESC]){
                if(!paymentRecordMap.containsKey(paymentRecord.cv_pkg_dev_I__Donation__c)){
                    paymentRecordMap.put(paymentRecord.cv_pkg_dev_I__Donation__c, new List<cv_pkg_dev_I__Payment__c>());
                }
                paymentRecordMap.get(paymentRecord.cv_pkg_dev_I__Donation__c).add(paymentRecord);
            }
            
            //Putting values into recurringGiftMap Map
            for(cv_pkg_dev_I__Recurring_Donation__c rg : recurringGifts){    //for loop for list of Recurring Gift Records
                if(!recurringGiftMap.containsKey(rg.id)){    //check recurringGiftMap Map contains Recurring Gift Record Id
                    recurringGiftMap.put(rg.id, new Map<Id, List<cv_pkg_dev_I__Payment__c>>());    //If don't contains than put Recurring Gift Record Id into recurringGiftMap
                }
                for(cv_pkg_dev_I__Gift__c gift : rg.Orders__r){    //for loop for list of Gift Records
                    if(!recurringGiftMap.get(rg.id).containsKey(gift.id)){    //check recurringGiftMap Map contains Gift Record Id
                        recurringGiftMap.get(rg.id).put(gift.id, new List<cv_pkg_dev_I__Payment__c>());    //If don't contains than put Gift Record Id into recurringGiftMap
                        
                    }  
                    if(paymentRecordMap.get(gift.Id) != null){
                        for(cv_pkg_dev_I__Payment__c payment : paymentRecordMap.get(gift.Id)){
                            recurringGiftMap.get(rg.id).get(gift.id).add(payment);
                        }
                    }
                }
            } 
            /* First for loop for Recurring Gift records and after that initially making value of cv_pkg_dev_I__Approved_Payments__c,cv_pkg_dev_I__Declined_Payments__c,cv_pkg_dev_I__Consecutive_Declined_Payments__c fields of Recurring Gift to zero,
               than next for loop for child Transactions of that Recurring Gift record. Than checking recurringGiftMap Map containing Recurring Gift Id and Gift Id. Than next for loop for child payments of a transaction.
               After all for loops, Checking the condition for approved, declined and consecutive declined payments. 
               */    
            if(recurringGifts.size() > 0){
                for(cv_pkg_dev_I__Recurring_Donation__c rgift : recurringGifts){
                    rgift.cv_pkg_dev_I__Approved_Payments__c = 0;
                    rgift.cv_pkg_dev_I__Declined_Payments__c = 0;
                    rgift.cv_pkg_dev_I__Consecutive_Declined_Payments__c = 0;
                    if(rgift.Orders__r.size() > 0){
                        for(cv_pkg_dev_I__Gift__c gift : rgift.Orders__r){
                            if(recurringGiftMap.get(rgift.id) != null && recurringGiftMap.get(rgift.id).get(gift.id) != null){
                                boolean isConsecutive = true;
                                for(cv_pkg_dev_I__Payment__c payment : recurringGiftMap.get(rgift.id).get(gift.Id)){
                                    if(payment.cv_pkg_dev_I__Status__c == 'Approved'){
                                        rgift.cv_pkg_dev_I__Approved_Payments__c += 1;
                                    }else
                                    if(payment.cv_pkg_dev_I__Status__c == 'Declined'){
                                        rgift.cv_pkg_dev_I__Declined_Payments__c += 1;
                                    }
                                    if(payment.cv_pkg_dev_I__Status__c == 'Declined' && isConsecutive){
                                        rgift.cv_pkg_dev_I__Consecutive_Declined_Payments__c += 1;
                                    }
                                    else{
                                        isConsecutive = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            try{
                update recurringGifts;    //updating the values in cv_pkg_dev_I__Approved_Payments__c,cv_pkg_dev_I__Declined_Payments__c,cv_pkg_dev_I__Consecutive_Declined_Payments__c fields in Recurring Gift Record
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
    }
    
    // Can we run future calls right now?
    public static boolean CanUseFutureContext() {
        boolean callStackLimitExceeded = Limits.getFutureCalls() >= Limits.getLimitFutureCalls();
    
        if (!callStackLimitExceeded) {
            // Check 24-hour rolling window limit of 200 * # of Salesforce, Salesforce Platform, or Force.com One App Licenses
            // *NOTE 1*: These queries may be cacheable depending on your situation
            // *NOTE 2*: If you have not used up all of your allocated licenses,
            // you will have more available licenses than this, so you may need to adjust.
            // However, you can't use SOQL to determine 
            //how many AVAILABLE licenses you have, 
            // only how many have actually been assigned to users
            return GetNumFutureCallsInLast24Hours() < getMaxFutureCallsAllowed();
        } else return false;
    }
    //Getting number of asynchronous jobs executed in last 24 hours
    public static Integer GetNumFutureCallsInLast24Hours() {
        return [select count() from AsyncApexJob where CreatedDate >= :Datetime.now().addHours(-24)];
    }
    //The limit of future calls in a 24 hour period, which is 250,000 or the number of user licenses in your organization multiplied by 200, whichever is greater.
    //So this method returning which ever in greater value in a org, 250k or the number of user licenses in organization multiplied by 200
    public static Integer getMaxFutureCallsAllowed() {
        Integer usersCount = [SELECT COUNT() FROM User WHERE Profile.UserLicense.LicenseDefinitionKey IN ('SFDC','AUL','PID_FDC_FREE')];
        return Math.max(250000, usersCount*200);
    }
}
