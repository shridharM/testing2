@isTest
private class CVHealthCheckControllerTest{
    @istest static void CVHealthCheckControllerTest(){
        CVAdmin__c cvAdmin = new CVAdmin__c(name = 'Waive Settings', Disable_Workflows_for_Sending_Receipts__c = true, Enable_Enhanced_Batch_Interface_Waive__c = true,
                                            Enable_Enhanced_Fund_Accounting_Waive__c = true, Enable_Pledge_Installment_Model_Waive__c = true, Send_Event_Registration_Receipt__c = true,
                                            Send_Gift_Receipt__c = true);
        insert cvAdmin;
        causeview__App_Settings__c app_setting = GLAllocationfieldUpdateTriggerTest.appSettings();
        app_setting.causeview__Enable_Enhanced_Batch_Interface__c = true;
        app_setting.causeview__Enable_Enhanced_Fund_Accounting__c = true;
        app_setting.causeview__Enable_Pledge_Installment_Model__c = true;
        app_setting.causeview__Use_Workflows_for_Sending_Receipts__c = true;
        update app_setting;
        CVHealthCheckController cvhealth = new CVHealthCheckController();
        cvhealth.send_Gift_Receipt_status = true;
        cvhealth.SendEventRegistrationReceipt_status = true;
        cvhealth.updateWaiveSetting();
        //Test.startTest();
        //Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
       cvhealth.updateWorkflowWaiveSetting();
        //cvhealth.workflowStatus();
       // Test.stopTest();
    }
}