@isTest
public with sharing class TestRDAllocationsTrigger {

	public testMethod static void test(){
		
		Contact c = new Contact();
		c.FirstName = 'Juan';
		c.LastName = 'Sanchez';
		insert c;
		c = [SELECT Id FROM Contact LIMIT 1];
		
		Date startDate = Date.today();
		
		cv_pkg_dev_I__Recurring_Donation__c rd = new cv_pkg_dev_I__Recurring_Donation__c();
		rd.cv_pkg_dev_I__Constituent__c = c.Id;
		rd.cv_pkg_dev_I__Start_Date__c = startDate;
		rd.cv_pkg_dev_I__Amount__c = 3000;
		insert rd;
		rd = [SELECT Id FROM cv_pkg_dev_I__Recurring_Donation__c WHERE cv_pkg_dev_I__Amount__c = 3000];
		cv_pkg_dev_I__RD_Allocation__c alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 1000;
		insert alloc;
		
		alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 1500;
		insert alloc;
		
		alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 500;
		insert alloc;
		
		// Test second recurring donation and allocations
		
		rd = new cv_pkg_dev_I__Recurring_Donation__c();
		rd.cv_pkg_dev_I__Constituent__c = c.Id;
		rd.cv_pkg_dev_I__Start_Date__c = startDate;
		rd.cv_pkg_dev_I__Amount__c = 1500;
		insert rd;
		rd = [SELECT Id FROM cv_pkg_dev_I__Recurring_Donation__c WHERE cv_pkg_dev_I__Amount__c = 1500];
		alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 750;
		insert alloc;
		
		alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 250;
		insert alloc;
		
		alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 500;
		insert alloc;
		
		// test third
		
		rd = new cv_pkg_dev_I__Recurring_Donation__c();
		rd.cv_pkg_dev_I__Constituent__c = c.Id;
		rd.cv_pkg_dev_I__Start_Date__c = startDate;
		rd.cv_pkg_dev_I__Amount__c = 20;
		insert rd;
		rd = [SELECT Id FROM cv_pkg_dev_I__Recurring_Donation__c WHERE cv_pkg_dev_I__Amount__c = 20];
		alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 10;
		insert alloc;
		
		alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 5;
		insert alloc;
		
		alloc = new cv_pkg_dev_I__RD_Allocation__c();
		alloc.cv_pkg_dev_I__Recurring_Gift__c = rd.Id;
		alloc.cv_pkg_dev_I__Amount__c = 5;
		insert alloc;
		
		system.debug('-----INSERTING RD-----');
		
		List<cv_pkg_dev_I__Recurring_Donation__c> donations = [SELECT Id, cv_pkg_dev_I__Amount__c FROM cv_pkg_dev_I__Recurring_Donation__c WHERE cv_pkg_dev_I__Amount__c != null LIMIT 1];
		
		for(cv_pkg_dev_I__Recurring_Donation__c donation : donations){
		
			if(donation.cv_pkg_dev_I__Amount__c != null)
				donation.cv_pkg_dev_I__Amount__c = 50;
		}
		
		system.debug('-----INSERTING UPDATED DONATIONS-----');
		
		update donations;
		
		system.debug('-----SELECT UPDATED DONATIONS-----');
		
		donations = [SELECT Id, cv_pkg_dev_I__Amount__c FROM cv_pkg_dev_I__Recurring_Donation__c WHERE cv_pkg_dev_I__Amount__c != null LIMIT 1];
		
		for(cv_pkg_dev_I__Recurring_Donation__c donation : donations){
		
			if(donation.cv_pkg_dev_I__Amount__c != null)
				donation.cv_pkg_dev_I__Amount__c = 1250;
		}
		
		system.debug('-----RE-INSERTING UPDATED DONATIONS-----');
		
		update donations;
	}
}