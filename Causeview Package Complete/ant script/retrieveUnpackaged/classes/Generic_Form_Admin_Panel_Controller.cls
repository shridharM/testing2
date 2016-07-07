public with sharing class Generic_Form_Admin_Panel_Controller {

    public String accountId { get; set; }
    public String sessionId{ get; set; }
    public String pageUrl { get; set; }

    public Generic_Form_Admin_Panel_Controller(){
            
        cv_pkg_dev_I__App_Settings__c settings = cv_pkg_dev_I__App_Settings__c.getInstance();
        accountId = settings.cv_pkg_dev_I__CV_Account_Id__c;
        
        
    }

}