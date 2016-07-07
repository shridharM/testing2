@isTest
public with sharing class TestRDAllocationsTrigger {

	public testMethod static void test(){
		
		Contact c = new Contact();
		c.FirstName = 'Juan';
		c.LastName = 'Sanchez';
		insert c;
		c = [SELECT Id FROM Contact LIMIT 1];
		
		Date startDate = Date.today();
		
		causeview__Recurring_Donation__c rd = new causeview__Recurring_Donation__c();
		rd.causeview__Constituent__c = c.Id;
		rd.causeview__Start_Date__c = startDate;
		rd.causeview__Amount__c = 3000;
		insert rd;
		rd = [SELECT Id FROM causeview__Recurring_Donation__c WHERE causeview__Amount__c = 3000];
		causeview__RD_Allocation__c alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 1000;
		insert alloc;
		
		alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 1500;
		insert alloc;
		
		alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 500;
		insert alloc;
		
		// Test second recurring donation and allocations
		
		rd = new causeview__Recurring_Donation__c();
		rd.causeview__Constituent__c = c.Id;
		rd.causeview__Start_Date__c = startDate;
		rd.causeview__Amount__c = 1500;
		insert rd;
		rd = [SELECT Id FROM causeview__Recurring_Donation__c WHERE causeview__Amount__c = 1500];
		alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 750;
		insert alloc;
		
		alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 250;
		insert alloc;
		
		alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 500;
		insert alloc;
		
		// test third
		
		rd = new causeview__Recurring_Donation__c();
		rd.causeview__Constituent__c = c.Id;
		rd.causeview__Start_Date__c = startDate;
		rd.causeview__Amount__c = 20;
		insert rd;
		rd = [SELECT Id FROM causeview__Recurring_Donation__c WHERE causeview__Amount__c = 20];
		alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 10;
		insert alloc;
		
		alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 5;
		insert alloc;
		
		alloc = new causeview__RD_Allocation__c();
		alloc.causeview__Recurring_Gift__c = rd.Id;
		alloc.causeview__Amount__c = 5;
		insert alloc;
		
		system.debug('-----INSERTING RD-----');
		
		List<causeview__Recurring_Donation__c> donations = [SELECT Id, causeview__Amount__c FROM causeview__Recurring_Donation__c WHERE causeview__Amount__c != null LIMIT 1];
		
		for(causeview__Recurring_Donation__c donation : donations){
		
			if(donation.causeview__Amount__c != null)
				donation.causeview__Amount__c = 50;
		}
		
		system.debug('-----INSERTING UPDATED DONATIONS-----');
		
		update donations;
		
		system.debug('-----SELECT UPDATED DONATIONS-----');
		
		donations = [SELECT Id, causeview__Amount__c FROM causeview__Recurring_Donation__c WHERE causeview__Amount__c != null LIMIT 1];
		
		for(causeview__Recurring_Donation__c donation : donations){
		
			if(donation.causeview__Amount__c != null)
				donation.causeview__Amount__c = 1250;
		}
		
		system.debug('-----RE-INSERTING UPDATED DONATIONS-----');
		
		update donations;
	}
}