public class testController {

  public string DocumentId {
     get
     {
        givingpowerSettings__c settings = [SELECT ReceiptPDFDocId__c FROM givingpowerSettings__c WHERE name = 'settings'];
        return settings.ReceiptPDFDocId__c;
     }
  }
 
  static testMethod void testMe()
  {
  		testController test = new testController();
  		string val = test.DocumentId;
  		
  }
}