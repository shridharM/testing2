public with sharing class TransactionBatchPresetsController {
 
  public GiftBatchWrapper wrapper { get; set; }
  public String TrsactionName { get; set; }
  
  public TransactionBatchPresetsController() {
     TrsactionName = 'Gift';
     initPage();
  }
  
  private void initPage() 
  {
     wrapper = new GiftBatchWrapper();
     wrapper.loadDefaults();
     
     String recordTypeId = '';
     
     List<BatchSettings__c> settingList = [Select b.RegularGiftRecordTypeId__c From BatchSettings__c b WHERE Name = 'Default'];
     if (settingList != null && settingList.size()>0)
          recordTypeId  = settingList[0].RegularGiftRecordTypeId__c;
     if (recordTypeId != null && recordTypeId != '')
     {
        List<RecordType> rts = [Select r.Id, r.Name From RecordType r WHERE Id = :recordTypeId];
        if (rts!=null && rts.size()>0)
          TrsactionName = rts[0].Name;
     }
     
  }

  public void clear() {
     wrapper.clearDefaults();
     wrapper.loadDefaults();
  }
  
  public void save() 
  {
      system.debug('<====>'+wrapper.giftDetail.Package__c);
      system.debug('kkk-- '+wrapper.giftDetail.New_Campaign__c);
      
     if ((wrapper.presets.giftSubject.isHidden || wrapper.presets.giftSubject.readOnly) && (wrapper.noteSubject==null || wrapper.noteSubject==''))
     {
        if ( !wrapper.presets.giftNotes.isHidden || (wrapper.noteSubject!=null && wrapper.noteSubject!=''))
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid state: Note subject default value is required if you are not hidding Note Content or setting a default value for it.'));
             return;
        }
     }
  
     
     if ( wrapper.presets.giftSubject.readOnly && !wrapper.presets.giftNotes.readOnly && !wrapper.presets.giftNotes.isHidden && (wrapper.noteSubject==null || wrapper.noteSubject==''))
     {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid state: Note subject default value is required if you are not hidding Note Content.'));
        return;
     }
  
     if ( (wrapper.presets.receiptType.readOnly || wrapper.presets.receiptType.isHidden) && (wrapper.gift.Receipt_Type__c==null || wrapper.gift.Receipt_Type__c==''))
     {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid state: Receipt Type requires a default value.'));
        return;
     }
     
     if ( (wrapper.presets.paymentType.readOnly || wrapper.presets.paymentType.isHidden) &&  (wrapper.payment.Payment_Type__c==null||wrapper.payment.Payment_Type__c==''))
     {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid state: payment Type requires a default value.'));
        return;
     }
  
     wrapper.saveDefaults();
     
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your presets are saved.'));
  }
  
  
  static testMethod void testMe() {
        
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        
                TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
                
                cnt.wrapper.presets.giftSubject.readOnly = true;
                cnt.wrapper.noteSubject = '';
                cnt.save();
                
                cnt.wrapper.noteSubject = 'jkjkjl';
         
        cnt.wrapper.presets.receiptType.readOnly = true;
        cnt.wrapper.gift.Receipt_Type__c = '';
        cnt.save();
        
        cnt.wrapper.gift.Receipt_Type__c = 'xvxczvz';
        
        cnt.wrapper.presets.paymentType.readOnly = true;
        cnt.wrapper.payment.Payment_Type__c = '';
        cnt.save();
         
        cnt.wrapper.gift.Receipt_Type__c = 'On time only';
        cnt.wrapper.payment.Payment_Type__c = 'Credit Card';
        cnt.save();
        
        cnt.clear();
    }

}