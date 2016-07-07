public with sharing class ReceiptAttachExportController {

    public string content { 
        get {
                string retVal = '';
                Id docId = null;
                
                // read custom settings
                List<givingpowerSettings__c> settingsRecords = [SELECT DupeAttachTemplateId__c, ReceiptPDFDocId__c, DupeConsolidatedReceiptPDFDocId__c, ConsolidatedReceiptPDFDocId__c FROM givingpowerSettings__c WHERE name = 'settings'];
                if (settingsRecords != null && settingsRecords.size()>0) {
                givingpowerSettings__c settings = settingsRecords[0];
                //If Receipt is of type "Consolidated" set docId with Consolidated doc Ids.
                if([Select Id, Receipt_Type__c From Receipt__c Where Id = :ApexPages.currentPage().getParameters().get('rid') LIMIT 1].Receipt_Type__c == 'Consolidated') {
                    if (ApexPages.currentPage().getParameters().get('isdupe') == 'True')
                    { docId = (Id)settings.DupeConsolidatedReceiptPDFDocId__c; }
                    else
                    { docId = (Id)settings.ConsolidatedReceiptPDFDocId__c; }
                } else {
                    if (ApexPages.currentPage().getParameters().get('isdupe') == 'True')
                    { docId = (Id)settings.DupeAttachTemplateId__c; }
                    else
                    { docId = (Id)settings.ReceiptPDFDocId__c; }                    
                }
            }
            
            // load document
            
            System.Debug('Nitin docId==='+docId);
            System.Debug('Nitin rid==='+ApexPages.currentPage().getParameters().get('rid'));
            System.Debug('Nitin cid==='+ApexPages.currentPage().getParameters().get('cid'));
            try {
                retVal = DonationUtility.MergeDocument(docId, 'Receipt__c', ApexPages.currentPage().getParameters().get('rid'), 'Contact', ApexPages.currentPage().getParameters().get('cid'));
            }
            catch(Exception ex)
            {
                retVal = ex.getMessage() + ' doc id: ' + docId + ' recipientType=Contact' + ' recipientId=' + ApexPages.currentPage().getParameters().get('cid');
            }
            system.debug('Nitin retVal===='+retVal);
            //return
            return retVal;
        }
    }
    
    /*public Receipt__c recipient { get; set; }    
    public Contact relatedTo { get; set; } 
    */
    
    public ReceiptAttachExportController () {
 
    }
}