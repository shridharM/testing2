/*
Fund Accounting: Prevent Delete of Allocation
If the following conditions are TRUE, then the system will not allow the user to delete the Allocation record:

CustomSettings.CauseviewAppSettings.EnableEnhancedFundAccounting = TRUE
Allocation.PostedToFinance <> BLANK
*/
trigger PreventDeleteOfAllocationTrigger on Gift_Detail__c (before delete) {
    
    causeview__App_Settings__c appSettings = causeview__App_Settings__c.getInstance();
    system.debug('Nitin Setting=='+appSettings);
    for(Gift_Detail__c g : Trigger.old){
        if(g.causeview__Posted_to_Finance__c <> null && appSettings.causeview__Enable_Enhanced_Fund_Accounting__c == True){
            g.addError('You can not delete this record because \'Enable Enhanced Fund Accounting\' is enabled in custom setting and \'Posted to Finance\' field is not blank!');
        }
    }
}