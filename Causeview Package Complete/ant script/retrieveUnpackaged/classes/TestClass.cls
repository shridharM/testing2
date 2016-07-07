@isTest
public with sharing class TestClass {

    public static testMethod void testGivingPowerUtility(){
        
        GivingPowerUtility gpu = new GivingPowerUtility();
        GivingPowerUtility.ConseqFiscalYears(new List<Date>(), 1);
        
        List<Date> dates = new List<Date>();
        dates.add(Date.today());
        dates.add(Date.today().addDays(1));
        GivingPowerUtility.ConseqFiscalYears(dates, 1);
            
        dates = new List<Date>();
        dates.add(Date.today().addDays(-365));
        dates.add(Date.today().addDays(-395));
        dates.add(Date.today().addDays(-465));
        GivingPowerUtility.ConseqFiscalYears(dates, 1);
        
        dates = new List<Date>();
        dates.add(Date.today().addDays(-366));
        dates.add(Date.today().addDays(-732));
        dates.add(Date.today().addDays(-1098));
        GivingPowerUtility.ConseqFiscalYears(dates, 1);
        
        GivingPowerUtility.findSobjectType('Temp');
        GivingPowerUtility.setFieldValue(new cv_pkg_dev_I__Gift__c(), 'cv_pkg_dev_I__Anonymous__c', 'Boolean', 'true');
        GivingPowerUtility.setFieldValue(new Contact(), 'Birthdate', 'Date', '10/10/1988');
        //GivingPowerUtility.setFieldValue(new Contact(), 'Name', 'DateTime', '10/10/1988');
        //GivingPowerUtility.setFieldValue(new cv_pkg_dev_I__Gift__c(), 'cv_pkg_dev_I__No_of_Expected_Payments__c', 'Double', '6');
        //GivingPowerUtility.setFieldValue(new cv_pkg_dev_I__Gift__c(), 'cv_pkg_dev_I__No_of_Expected_Payments__c', 'Int', '3');
        //GivingPowerUtility.setFieldValue(new Contact(), 'Name', 'String', 'Juan');
        
        GivingPowerUtility.IsEmptyOrNull('');
        
        Date currentDate = Date.today();
        DateTime currentDateTime = DateTime.now();
        
        GivingPowerUtility.formatDateForQuery(currentDate);
        GivingPowerUtility.formatDateTimeForQuery(currentDateTime);
        cv_pkg_dev_I__BatchSettings__c bs = new cv_pkg_dev_I__BatchSettings__c ();
        bs.Name = 'Default';
        bs.cv_pkg_dev_I__GatewayUrl__c = '';
        bs.cv_pkg_dev_I__BatchFormID__c = 'a';
        bs.cv_pkg_dev_I__BatchReportId__c = 'a';
        bs.cv_pkg_dev_I__BucketAccountId__c = 'a';
        bs.cv_pkg_dev_I__CurrencyCode__c = 'USD';
        bs.cv_pkg_dev_I__Data_Migration_Mode__c = false;
        bs.cv_pkg_dev_I__GatewayUrl__c = 'http://localhost/';
        bs.cv_pkg_dev_I__RegularGiftRecordTypeId__c = 'a';
        bs.cv_pkg_dev_I__Unknown_Guest_Id__c = 'a';
        insert bs;
        //Util.SubmitRecurringChanges('bcg', 'dfszf');
    }
    
    public static testMethod void testGiftBatchController(){
        
        //GiftBatchController cbg = new GiftBatchController();
        
    }

}
