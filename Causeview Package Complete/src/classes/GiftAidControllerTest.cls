@isTest
public class GiftAidControllerTest {
    public static testMethod void testGiftAidController() {
        GiftAidController ga = new GiftAidController();
        //test pagination for to be claimed------------------------------------------
        causeview__Payment__c[] getToBeList = ga.getToBeList;
        causeview__Payment__c[] getToBeListCon = ga.getToBeList();
        ga.FirstPage();
        ga.previous();
        ga.next();
        ga.LastPage();
        boolean getprev = ga.getprev();
        boolean getnxt = ga.getnxt();
        causeview__Payment__c[] listOfToBeClaimed = ga.listOfToBeClaimed;
        decimal sumToBeClaimed = ga.sumToBeClaimed;
        selectoption[] perPageNumbers = ga.perPageNumbers;        
        integer perPageSelection = ga.perPageSelection;
        PageReference pageRef = ga.assignPerPage();
        
        ga.toBeTotalRecs = [SELECT count() FROM causeview__Payment__c WHERE Gift_Aid_Claim_Status__c = 'Not claimed' AND causeview__Gift_Aid_Eligible__c = true ];

        //cnr list--------------------------------------------------------------------
        causeview__Payment__c[] getcnrList = ga.getcnrList;
        causeview__Payment__c[] getcnrListCon = ga.getcnrList();
        ga.cnrFirstPage();
        ga.cnrprevious();
        ga.cnrnext();
        ga.cnrLastPage();        
        boolean getcnrprev = ga.getprev();
        boolean getcnrnxt = ga.getcnrnxt();                
        causeview__Payment__c[] listOfcnr = ga.listOfcnr;
        decimal sumNotReceived = ga.sumNotReceived;
        selectoption[] cnrperPageNumbers = ga.cnrperPageNumbers;
        integer cnrperPageSelection = ga.cnrperPageSelection;        
        PageReference cnrpageRef = ga.cnrassignPerPage();
          
        //received list---------------------------------------------------------------
        causeview__Payment__c[] getreceivedList = ga.getreceivedList;
        causeview__Payment__c[] getreceivedListCon = ga.getreceivedList();        
        ga.receivedFirstPage();
        ga.receivedprevious();
        ga.receivednext();
        ga.receivedLastPage();        
        boolean getreceivedprev = ga.getreceivedprev();
        boolean getreceivednxt = ga.getreceivednxt();                
        causeview__Payment__c[] listOfreceived = ga.listOfreceived;
        decimal sumReceived = ga.sumReceived;
        selectoption[] receivedperPageNumbers = ga.receivedperPageNumbers;
        integer receivedperPageSelection = ga.receivedperPageSelection;        
        PageReference receivedpageRef = ga.receivedassignPerPage();
                
        //rejected list----------------------------------------------------------------
        causeview__Payment__c[] getrejectedList = ga.getrejectedList;
        causeview__Payment__c[] getrejectedListCon = ga.getrejectedList();                
        ga.rejectedFirstPage();
        ga.rejectedprevious();
        ga.rejectednext();
        ga.rejectedLastPage();        
        boolean getrejectedprev = ga.getrejectedprev();
        boolean getrejectednxt = ga.getrejectednxt();                               
        causeview__Payment__c[] listOfrejected = ga.listOfrejected;
        decimal sumRejected = ga.sumRejected;
        selectoption[] rejectedperPageNumbers = ga.rejectedperPageNumbers;          
        integer rejectedperPageSelection = ga.rejectedperPageSelection;         
        PageReference rejectedpageRef = ga.rejectedassignPerPage();
        
        PageReference exportpageRef = ga.exportToCSV();  
        System.assertNotEquals(null, ga);
    }
}