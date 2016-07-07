global class DeleteThisClass implements Database.Batchable<sObject>, Database.stateful {
    
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query = GetQuery();
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    public static string GetQuery()
    {   
        string query = 'Select Id, Name from Account';
        
        return query;       
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }

}