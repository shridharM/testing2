/*
Added by Nitin
To run "ContactTrigger" trigger only once. Because in few cases after trigger update
fields on contact record and workflow runs after that and it updates contact record again.
So it will run the trigger again and creates the "Other Address" two records in those cases.
I'm using this class on "LegacyAddress" method on "OrgContactHandler" apex class for contact type records.  
*/
global class Validator_cls{
    private static set<Id> ids;
    private static boolean blnAlreadyDone = false;
    private static boolean blnAlreadyDone1 = false;
    private static boolean alreadyModified = false;
    private static boolean alreadyModifiedforPayment = false;
    private static boolean alreadyModifiedforTriggerRecurringPayment = false;
    private static boolean alreadyModifiedforReceiptUpdateOnTransaction = false;
    private static boolean alreadyFiredRollupTotalGiving = false;
    Private Static Boolean alreadyModifiedTotalGiftAidpayment = false;
    
    Private static boolean fromaccounttrigger = false;
    
    public static boolean alreadyModifiedforTriggerRecurringPayment1 = false;
    
    public static set<Id> paymentidsset = new set<id> ();
    
    public static boolean hasAlreadyDone(){ 
        return blnAlreadyDone;
    }
    
    public static boolean hasAlreadyDone1(){ 
        return blnAlreadyDone1;
    }
    public static void setAlreadyDone() {  
        blnAlreadyDone = true;
    }
    public static void setAlreadyDone1() {  
        blnAlreadyDone1 = true;
    }
    
    public static boolean isAlreadyModified() {
        return alreadyModified;
    }
 
    // set this to true to keep track of and avoid recursive updates.  Generally set after first time through
    // a trigger.  We can access this in the trigger and avoid recursive updates...
   
    public static void setAlreadyModified() {
        alreadyModified = true;
    }
    
    public static boolean isAlreadyModifiedforPayment() {
        return alreadyModifiedforPayment;
    }
 
   
    public static void setAlreadyModifiedforPayment() {
        alreadyModifiedforPayment = true;
    }
    
    public static boolean isAlreadyModifiedforTriggerRecurringPayment() {
        return alreadyModifiedforTriggerRecurringPayment;
    }
 
    public static void setAlreadyModifiedforTriggerRecurringPayment() {
        alreadyModifiedforTriggerRecurringPayment = true;
    }
    
    public static boolean isAlreadyModifiedforReceiptUpdateOnTransaction() {
        return alreadyModifiedforReceiptUpdateOnTransaction;
    }
 
    public static void setAlreadyModifiedforReceiptUpdateOnTransaction() {
        alreadyModifiedforReceiptUpdateOnTransaction = true;
    }
    
    public static boolean isalreadyFiredRollupTotalGiving() {
        return alreadyFiredRollupTotalGiving;
    }
 
    public static void setalreadyFiredRollupTotalGiving() {
        alreadyFiredRollupTotalGiving = true;
    }
    
    public static boolean isalreadyModifiedTotalGiftAidpayment() {
        return alreadyModifiedTotalGiftAidpayment;
    }
 
    public static void setalreadyModifiedTotalGiftAidpayment() {
        alreadyModifiedTotalGiftAidpayment = true;
    }
}