@isTest
  public class RollupBatchPaymentTest{  
   public  static testMethod void testRollupBatchPaymentTest(){
              RollupBatchPayment e = new RollupBatchPayment();
           Database.executeBatch(e, 10); 
           
           //Database.executeBatch(new RollupBatchForConsecutiveYears(), 10); 
           
           BatchPresetController bpc = new BatchPresetController();           
           bpc.newBatchPreset();          
           bpc.getbatchTypeOptions();
           bpc.discribeObjects('account');
           
           
           
  }
  }