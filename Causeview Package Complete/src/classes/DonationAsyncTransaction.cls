global class DonationAsyncTransaction {
  
   global enum StatusResult { Success, Failure, NotFound, InvalidInput }
   
   global class DonationAsyncResult
   {
       webservice StatusResult Status { get; set; }
       webservice String StatusComment { get; set; }
       webservice String PaymentId { get; set; }
       webservice String GiftId { get; set; }
   }
   
   global class PaymentTransaction 
   { 
       webservice String RecurringPaymentId { get; set; }
       webservice String TransactionId { get; set; } 
       webservice Decimal Amount { get; set; } 
       webservice String Status { get; set; } 
       webservice String StatusComment { get; set; }
       webservice Date TransactionDate { get; set; } 
       webservice String ParentTransactionId {get; set; }
   }
    
   webservice static DonationAsyncResult TransactionUpsert(PaymentTransaction payment)
   {
     string debugStr = ' New transaction call with following info: ';
     debugstr += '\n TransactionId = ' + payment.TransactionId;
     debugstr += '\n RecurringPaymentId = ' + payment.RecurringPaymentId;
     debugstr += '\n Status = ' + payment.Status;
     debugstr += '\n ParentTransactionId = ' + payment.ParentTransactionId;
     debugstr += '\n Amount = ' + payment.Amount;
     System.debug(debugstr);
     
     DonationAsyncResult retVal = new DonationAsyncResult();
     
     try
     {
      
        if (payment.ParentTransactionId != null && payment.ParentTransactionId != '')
        {
          //process refund
          return RefundPayment(payment);
        }
       
        // if the transaction id exists: update the status on the Payment
        if (payment.TransactionId == null || payment.TransactionId == '')
        {
            retVal.Status = StatusResult.InvalidInput;
            retVal.StatusComment = 'Invalid Input: Transaction Id is null.';
            System.debug(retVal.StatusComment);
            return retVal;
        }
     
        List<Payment__c> payments = [Select Id, Status__c, CC_Reference__c, StatusComment__c, Donation__c FROM Payment__c WHERE CC_Reference__c = :payment.TransactionId];
        if (payments != null && payments.size()>0) {
            System.debug('Trans ID:' + payment.TransactionId + ' - Payment found, updating......');
            System.debug('New Status: ' + payment.Status);
            Payment__c p = payments[0];
            p.Status__c = payment.Status;
            p.StatusComment__c = payment.StatusComment;
            update p;
            
            retVal.GiftId = p.Donation__c;
            retVal.StatusComment = 'Payment record: ' + p.Id + ' updated, new status: ' + payment.Status; 
        }
        else {
        
            if (payment.RecurringPaymentId == null || payment.RecurringPaymentId == '') {
                retVal.StatusComment = 'Invalid Input: Recurring payment Id is null.';
                System.debug(retVal.StatusComment);
                retVal.Status = StatusResult.InvalidInput;
                return retVal;
            }
        
            // if the transaction id does not exists: check the recurringPaymentId
            System.debug('Trans ID:' + payment.TransactionId + ' - Inserting new Payment for a recurring donation......');
            List<Gift__c> donations = [SELECT id, Reference__c FROM Gift__c WHERE Status__c = 'Active Recurring' AND Reference__c = :payment.RecurringPaymentId];
            if (donations != null && donations.size()>0) {
                // if found: create a new payment record
                Payment__c p = new Payment__c();
                p.Amount__c = payment.Amount;
                p.CC_Reference__c = payment.TransactionId;
                p.CC_Transaction_Date__c = payment.TransactionDate;
                p.Donation__c = donations[0].Id;
                p.Status__c = payment.Status;
                p.StatusComment__c = payment.StatusComment;
            
                insert p;
                
                retVal.PaymentId = p.Id;
                retVal.GiftId = p.Donation__c;
                retVal.StatusComment = 'New Payment Id: ' + p.Id + ' ---Payment Amount:' + payment.Amount.format()+ '---Status:'+ payment.Status;
                System.debug(retVal.StatusComment);
            }
            else {
                // if not found: return :
                retVal.StatusComment = 'Was not able to locate Donation record based on Recurring payment id.'; 
                System.debug(retVal.StatusComment);
                retVal.Status = StatusResult.NotFound;
                return retVal;
            }//end else
        }
        
     }
     catch(Exception ex)
     {
        retVal.StatusComment = ex.getMessage(); 
        System.debug(retVal.StatusComment);
        retVal.Status = StatusResult.Failure;
        return retVal;
     }
     
     retVal.Status = StatusResult.Success;
     return retVal;
   }
   
   private static DonationAsyncResult RefundPayment(PaymentTransaction payment)
   {
      System.Debug('refuding a payment, Parent Trans ID: '+ payment.ParentTransactionId);
      DonationAsyncResult retVal = new DonationAsyncResult();
      
      
      List<Payment__c> pays = [SELECT Id, Donation__c FROM Payment__c WHERE CC_Reference__c = : payment.ParentTransactionId];
      if (pays == null || pays.size()<=0)
      {
          retVal.Status = StatusResult.NotFound;
          retVal.StatusComment = 'original transaction was not found, Reference=' + payment.ParentTransactionId; 
          System.Debug(retVal.StatusComment);
          return retVal;       
      }
      
      
      Payment__c p = new Payment__c();
      p.Amount__c = payment.Amount;
      p.CC_Reference__c = payment.TransactionId;
      p.CC_Transaction_Date__c = payment.TransactionDate;
      p.Donation__c = pays[0].Donation__c;
      p.Status__c = payment.Status;
      p.StatusComment__c = payment.StatusComment;      
      insert p;
      
      retVal.StatusComment = 'New payment record created (refunded), Id='+ p.Id; 
      System.Debug(retVal.StatusComment);
      retVal.Status = StatusResult.Success;
      retVal.PaymentId = p.Id;
      retVal.GiftId = pays[0].Donation__c;
      return retVal;
   }

}