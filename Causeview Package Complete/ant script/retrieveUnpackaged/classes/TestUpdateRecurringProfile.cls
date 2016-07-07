@isTest(seeAllData=true)
public with sharing class TestUpdateRecurringProfile {

	public static testMethod void testUpdateRecurringProfileTrigger(){
		
		Contact con = new Contact();
		con.LastName = 'Testerson';
		insert con;
		
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;
		
		cv_pkg_dev_I__Recurring_Donation__c rd = new cv_pkg_dev_I__Recurring_Donation__c();
		rd.cv_pkg_dev_I__Constituent__c = con.Id;	
		rd.cv_pkg_dev_I__Organization__c = account.Id;
		rd.cv_pkg_dev_I__Start_Date__c = Date.today();
		rd.cv_pkg_dev_I__Status__c = 'Active';
		insert rd;
		
		rd.cv_pkg_dev_I__Status__c = 'On Hold';
		update rd;
		
		rd.cv_pkg_dev_I__Status__c = 'Active';
		update rd; 
	}	
}