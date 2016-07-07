global with sharing class CallBatchByButtonOnERPage {
   
   webservice static String callBatchContact() {
		BatchContactUpdateOnEventRegistration obj = new BatchContactUpdateOnEventRegistration();
        database.executeBatch(obj,200);
      return null;
   }
}