public with sharing class refundPaymentController {
 
   public string paymentId { get; set; }
   public Payment__c payment { get; set; }
   public boolean isValid { get; set; }
   public boolean showComments { get; set; }
   public Decimal totalRefunded { get; set; }
   public Decimal paymentAmount { get; set; }
   
   public integer wizardStep { get; set; }
   // test edit  commit test
   public refundPaymentController()
   {
      paymentId = ApexPages.currentPage().getParameters().get('id');
      system.debug('<=Inside Controller=>'+paymentId);
      init();
   }
   
   public void init()
   {
       system.debug('<=Inside Init=>');
      //initial values
      isValid = false;
      showComments = false;
      wizardStep = 1;
      paymentAmount = 0;
      totalRefunded = 0;
      
      List<Payment__c> payments = [SELECT Id, Name, Amount__c, Refund_Reason__c, Refund_Comments__c, Payment_Type__c, Status__c, Donation__c FROM Payment__c WHERE Id = :paymentId];
      system.debug('<=payments=>'+payments);
      if (payments!=null && payments.size()>0)
      {
         payment = payments[0];
         isValid = (payment.Status__c == 'Approved');
         paymentAmount = payment.Amount__c;
      }
      system.debug('<=payment=>'+payment);
      system.debug('<=isValid=>'+isValid);
      system.debug('<=paymentAmount=>'+paymentAmount);
      if (!isValid)
      {
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, System.Label.payment_can_not_refunded ));
      }
      
      
      totalRefunded = RefundedAmount(paymentId);
      system.debug('<=totalRefunded=>'+totalRefunded);
      if (payment != null && (payment.Amount__c - totalRefunded) <= 0)
      {
         isValid = false;
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, System.Label.payment_can_not_refunded ));
      }
   }
   
   public void refresh()
   {
      if (payment.Refund_Reason__c == 'Other')
       showComments = true;
      else
       showComments  = false;
   }
   
   public PageReference submit()
   {
       Map<String, String> rtypes_Map = new Map<String, String>();
       for(RecordType r : [Select Name, Id From RecordType where Name = 'Refund' AND NamespacePrefix = 'causeview']){
            rtypes_Map.put(r.name, r.id);
        }
       system.debug('<=Inside submit=>');
      //valiation
      if (payment==null)
        return null;
        
      //get refunded payments
      totalRefunded  = RefundedAmount(paymentId);
      system.debug('<=totalRefunded=>'+totalRefunded);
      Decimal maxRefund = paymentAmount - totalRefunded;
      system.debug('<=maxRefund=>'+maxRefund);
      system.debug('<=payment=>'+payment);
      if (payment.Amount__c > maxRefund)
      {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Invalid amount. Maximum possible refund amount is: ' + maxRefund.format() ));
         return null;
      }
   
        try
        {
            system.debug('<=Inside try=>');
            system.debug('payment type===>' + payment.Payment_Type__c );
          
            if (payment.Payment_Type__c == 'Credit Card' || payment.Payment_Type__c == 'ACH/PAD' || payment.Payment_Type__c == 'ACH/EFT' || payment.Payment_Type__c == 'Direct Debit') {
                /*wizardStep = 2; 
                Payment__c refund = new Payment__c();
                refund.Amount__c = 0 - payment.Amount__c;
                refund.Donation__c = payment.Donation__c;
                refund.Date__c = Date.Today();
                refund.Status__c = 'Refunded';
                refund.Payment_Refunded__c = payment.Id;
                refund.Payment_Type__c = payment.Payment_Type__c;
                refund.RecordTypeId = rtypes_Map.get('Refund');
                insert refund; */

                system.debug('given type------>' +payment.Payment_Type__c );
                BatchGateway3.GatewaySoap gateway = RollupHelper.newGPServiceInstance();
                system.debug('<=gateway=>'+gateway);
                ID pid = paymentId;
                system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'+pid);
                String refundReason = payment.Refund_Reason__c;
                
                if (refundReason!=null && refundReason.toLowerCase() == 'other' && !RollupHelper.IsEmptyOrNull(payment.Refund_Comments__c))
                    refundReason += ':' + payment.Refund_Comments__c;
            
                BatchGateway3.TransactionResult result = gateway.SubmitRefund(pid,payment.Amount__c,refundReason);
                system.debug('<=result=>'+result);
                if (result.Errors != null && result.Errors.ErrorMessages != null && result.Errors.ErrorMessages.size()>0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'The refund request failed, this may be due to the fact that the payment is already refunded. please contact the administrator for more information.'));
                    List<BatchGateway3.ErrorMessages> msgs = result.Errors.ErrorMessages;
                    
                    for (BatchGateway3.ErrorMessages msg : msgs) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg.ErrorCode + ' : '+ msg.Error ));
                    }
                    return null;
                }
                else
                {  
                    system.debug('%%%% Commented out payment creation with credit card - ach/pad: ' + payment);
                    wizardStep = 2; 
                    /*Payment__c refund = new Payment__c();
                    refund.Amount__c = 0 - payment.Amount__c;
                    refund.Donation__c = payment.Donation__c;
                    refund.Date__c = Date.Today();
                    refund.Status__c = 'Refunded';
                    refund.Payment_Refunded__c = payment.Id;
                    insert refund;*/
                } 

            } else {
                system.debug('%%%% payment creation from ach/eft: ' + payment);
                wizardStep = 2; 
                Payment__c refund = new Payment__c();
                refund.Amount__c = 0 - payment.Amount__c;
                refund.Donation__c = payment.Donation__c;
                refund.Date__c = Date.Today();
                refund.Status__c = 'Refunded';
                refund.Payment_Refunded__c = payment.Id;
                refund.Payment_Type__c = payment.Payment_Type__c;
                refund.RecordTypeId = rtypes_Map.get('Refund');
                refund.causeview__Refund_Reason__c=payment.Refund_Reason__c;
                refund.causeview__Refund_Comments__c=payment.causeview__Refund_Comments__c;
                
                system.debug('%%%% Inserting payment...');
                
                insert refund; 
            }
                
                
                /*system.debug('given type------>' +payment.Payment_Type__c );
            BatchGateway3.GatewaySoap gateway = RollupHelper.newGPServiceInstance();
            system.debug('<=gateway=>'+gateway);
            ID pid = paymentId;
            String refundReason = payment.Refund_Reason__c;
            if (refundReason!=null && refundReason.toLowerCase() == 'other' && !RollupHelper.IsEmptyOrNull(payment.Refund_Comments__c))
              refundReason += ':' + payment.Refund_Comments__c;
            
            BatchGateway3.TransactionResult result = gateway.SubmitRefund(pid,payment.Amount__c,refundReason);
            system.debug('<=result=>'+result);
            if (result.Errors != null && result.Errors.ErrorMessages != null && result.Errors.ErrorMessages.size()>0)
            {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'The refund request failed, this may be due to the fact that the payment is already refunded. please contact the administrator for more information.'));
               List<BatchGateway3.ErrorMessages> msgs = result.Errors.ErrorMessages;
               for(BatchGateway3.ErrorMessages msg : msgs)
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg.ErrorCode + ' : '+ msg.Error ));
                 
               return null;
            }
            else
            {
                wizardStep = 2; 
                /*Payment__c refund = new Payment__c();
                refund.Amount__c = 0 - payment.Amount__c;
                refund.Donation__c = payment.Donation__c;
                refund.Date__c = Date.Today();
                refund.Status__c = 'Refunded';
                refund.Payment_Refunded__c = payment.Id;
                insert refund;
            } 
      
          }*/
      }
      catch(Exception ex)
      {
           ApexPages.addMessages(ex);
           return null;
      }
      system.debug('final payment-------->'+ payment);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'The payment is sucessfully refunded.' ));
      return null;
       
   }
   public PageReference cancel()
   {
      string retUrl = ApexPages.currentPage().getParameters().get('returl');
      if (rollupHelper.IsEmptyOrNull(retUrl))
        retUrl = '/'+paymentId;
      PageReference pageRef = new PageReference(retUrl);
      pageRef.setRedirect(true);
      return pageRef;
   }
   
   private decimal RefundedAmount(string paymentId)
   {
       List<Payment__c> payments = [SELECT Id, Amount__c FROM Payment__c WHERE Payment_Refunded__c = :paymentId AND Status__c = 'Refunded'];
       decimal total = 0;
       if (payments!=null && payments.size()>0)
        for(Payment__c p : payments)
            total += p.Amount__c.abs();
        
       return total;
   }
   
}