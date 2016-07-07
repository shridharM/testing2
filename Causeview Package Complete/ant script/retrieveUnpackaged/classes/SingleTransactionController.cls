public with sharing class SingleTransactionController {

   public string formId { get; set; }
   public string serviceUrl { get; set; }
   public string widgetWidth { get; set; }
   public string widgetHeight { get; set; }
   public List<SelectOption> options { get; set; }
   public List<WidgetForms__c> forms { get; set; }
   public string selectedOption { get; set; }
   
   public SingleTransactionController()
   {
       /*
       serviceUrl = 'https://www.opinov.com/breakeven/Gateway.asmx';
       formId = 'a02A0000001lq1d';
       widgetWidth = '100%';
       widgetHeight = '700';*/
       forms = [SELECT Id, Name, FormId__c/*, ServiceUrl__c, WidgetWidth__c, WidgetHeight__c*/ FROM WidgetForms__c LIMIT 200];
       loadFormOptions();
   } 
   
   private void loadFormOptions()
   {
      options = new List<SelectOption>();
      for(WidgetForms__c form : forms)
      {
         SelectOption option = new SelectOption(form.Id,form.Name);
         options.add(option);
      }
      selectedOption = forms[0].Id;
      loadForm();
   }
   
   public void loadForm()
   {
     if (forms != null)
      for(WidgetForms__c form : forms)
       if (form.Id == selectedOption)
       {
           //serviceUrl = form.serviceUrl__c;
           formId = form.FormId__c;
           //widgetWidth = (form.WidgetWidth__c==null)? '100%' : form.WidgetWidth__c;
           //widgetHeight =(form.WidgetHeight__c==null)? '700' : form.WidgetHeight__c;
           break;
       }
   }
   
   static testMethod void testMe()
   {
       cv_pkg_dev_I__WidgetForms__c widgetForm = new cv_pkg_dev_I__WidgetForms__c(name = 'test Widget', cv_pkg_dev_I__Form_Name__c='test widget1', cv_pkg_dev_I__FormId__c = 'gdf123');//, cv_pkg_dev_I__ServiceUrl__c='https://www.opinov.com/breakeven/Gateway.asmx',cv_pkg_dev_I__WidgetWidth__c = '100%', cv_pkg_dev_I__WidgetHeight__c = '700');
        insert widgetForm;
        SingleTransactionController cnt = new SingleTransactionController();
        cnt.loadFormOptions();
        cnt.loadForm();
   }
}