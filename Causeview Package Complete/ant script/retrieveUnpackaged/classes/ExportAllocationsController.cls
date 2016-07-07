public with sharing class ExportAllocationsController {
   
   public List<cv_pkg_dev_I__Gift_Detail__c> records { get; set; }
   public Set<string> csvFields { get; set; }
   public Set<string> csvGiftFields { get; set; }
   public integer total { get; set; }
   
   public ExportAllocationsController()
   {
      string fields = getObjFields(Schema.SObjectType.cv_pkg_dev_I__Gift_Detail__c.fields.getMap(),'');
      string giftFields = getObjFields(Schema.SObjectType.cv_pkg_dev_I__Gift__c.fields.getMap(),'cv_pkg_dev_I__Gift__r.');
      fields += ','+giftFields;
      string q = 'SELECT '+ fields + ' FROM cv_pkg_dev_I__Gift_Detail__c WHERE cv_pkg_dev_I__Gift__r.Exported__c = false';
      records = Database.query(q);
      csvFields = Schema.SObjectType.cv_pkg_dev_I__Gift_Detail__c.fields.getMap().keySet();
      csvGiftFields = Schema.SObjectType.cv_pkg_dev_I__Gift__c.fields.getMap().keySet();
      total = csvFields.size();
   }
   
   private string getObjFields(Map<String, Schema.SObjectField> M, string prefix)
   {
       Set<string> fieldSet = M.keySet();  
       string fields = '';
       for(string f : fieldSet) fields += prefix + f +',';
       if(fields.endsWith(',')) fields= fields.substring(0,fields.length()-1);
       return fields;
   }
   
    @isTest
    static void testMe()
    {
        ExportAllocationsController controller = new ExportAllocationsController();
        Set<string> dd = controller.csvFields;
        Set<string> dd2 = controller.csvGiftFields;
        integer d = controller.total;
        List<cv_pkg_dev_I__Gift_Detail__c> recs = controller.records;
    }
   
}
