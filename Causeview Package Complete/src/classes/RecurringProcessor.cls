global class RecurringProcessor implements Database.Batchable<sObject>,Database.AllowsCallouts  {
    
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query = 'SELECT Id, Recurring_Donation__r.causeview__Reference__c, Recurring_Donation__r.causeview__Amount__c' +
        ' FROM Gift__c WHERE Gift_Type__c =\'Recurring\' AND Status__c=\'Active\' '+
        ' AND Recurring_Donation__r.causeview__Type__c = \'Credit Card\' AND Next_Payment_Date__c = TODAY ';
        
        return Database.getQueryLocator(query);
    }
    //uncommented by nitin
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug('scope==>'+scope);
        //create a list of tokens
        BatchGateway3.ArrayOfRecurringTransaction params = new BatchGateway3.ArrayOfRecurringTransaction();
        params.RecurringTransaction = new List<BatchGateway3.RecurringTransaction>();
        
        for(sObject o : scope) {
            Gift__c g = (Gift__c)o;
            if (!RollupHelper.IsEmptyOrNull(g.Recurring_Donation__r.Reference__c))
            {
                BatchGateway3.RecurringTransaction rt = new BatchGateway3.RecurringTransaction();
                rt.Amount = g.Recurring_Donation__r.Amount__c;
                rt.RecurringId = g.Recurring_Donation__r.Reference__c;
                params.RecurringTransaction.add(rt);
            }
        }
        
        //call GP Getway
        BatchGateway3.GatewaySoap gateway = RollupHelper.newGPServiceInstance();
        gateway.SubmitRecurring(params);

    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}