@isTest(seeAllData=true)
public with sharing class TestUpdateRecurringProfile {

	public static testMethod void testUpdateRecurringProfileTrigger(){
		
		Contact con = new Contact();
		con.LastName = 'Testerson';
		insert con;
		
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;
		
		causeview__Recurring_Donation__c rd = new causeview__Recurring_Donation__c();
		rd.causeview__Constituent__c = con.Id;	
		rd.causeview__Organization__c = account.Id;
		rd.causeview__Start_Date__c = Date.today();
		rd.causeview__Status__c = 'Active';
		insert rd;
		
		rd.causeview__Status__c = 'On Hold';
		update rd;
		
		rd.causeview__Status__c = 'Active';
		update rd; 
	}	
}