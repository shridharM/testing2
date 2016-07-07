Public Class GiftBatch_Controller_moc {

    private string giftId{get;set;}
    public cv_pkg_dev_I__Gift_Batch__c gb{get;set;}
    public cv_pkg_dev_I__Gift_Batch__c giftbatch;
    public Integer num{get;set;}
    public Map<String,Map<String,String>>AccountshowMap;
    public Map<String,Map<String,String>>ContactshowMap{get;set;}
    public Map<String,Map<String,String>>EventRegistrationshowMap{get;set;}
    public Map<String,Map<String,String>>GiftDetailshowMap{get;set;}
    public Map<String,Map<String,String>>PaymentshowMap{get;set;}
    public Map<String,Map<String,String>>ReceiptshowMap{get;set;}
    public Map<String,Map<String,String>>RecurringGiftshowMap{get;set;}
    public Map<String,Map<String,String>>TransactionshowMap{get;set;}
    public List<string>objList;
    public List<string>fieldnamelist;
    public List<string>fieldlabellist;
   
    public list<Map<string,string>>flfn = new list<map<string,string>>();
    
    Date Open_Date;
    String Name;
    Date Close_Date;
    String Description;
    Integer Cash_Gifts;
    Integer Cash;
    Integer Cheque_Gifts;
    Integer Cheque;
    Integer Credit_Card_Gifts;
    Integer Credit_Card;
    Integer Direct_Deposit_Gifts;
    Integer Direct_Deposit;
    Integer Other_Gifts;
    Integer Other;
    Integer Total_Gift;
    Integer Total_Gift_Amount;
    
    
    
    public GiftBatch_Controller_moc(ApexPages.StandardController stdController){
    giftId =  ApexPages.currentPage().getParameters().get('Id');
        
        gb = new cv_pkg_dev_I__Gift_Batch__c(); 
        gb = [select cv_pkg_dev_I__Open_Date__c,Name,cv_pkg_dev_I__Name__c,cv_pkg_dev_I__Close_Date__c,cv_pkg_dev_I__Description__c,cv_pkg_dev_I__Cash_Gifts__c,
                cv_pkg_dev_I__Cash__c,cv_pkg_dev_I__Cheque_Gifts__c,cv_pkg_dev_I__Cheque__c,cv_pkg_dev_I__Credit_Card_Gifts__c,cv_pkg_dev_I__Credit_Card__c,
                cv_pkg_dev_I__Direct_Deposit_Gifts__c,cv_pkg_dev_I__Direct_Deposit__c,cv_pkg_dev_I__Other_Gifts__c,cv_pkg_dev_I__Other__c,cv_pkg_dev_I__Total_Gift__c,cv_pkg_dev_I__Total_Gift_Amount__c,cv_pkg_dev_I__Shareplan_Gifts__c, cv_pkg_dev_I__Shareplan__c
                from cv_pkg_dev_I__Gift_Batch__c where Id=:giftId];
      // this.giftbatch = (cv_pkg_dev_I__Gift_Batch__c)stdController.getRecord();
         
        
    }
   
    
   public Date getOpen_Date(){
        return gb.cv_pkg_dev_I__Open_Date__c;
    }
    
    
   
    public String getName(){
        return gb.cv_pkg_dev_I__Name__c;
    }
    public Date Close_Date(){
        return gb.cv_pkg_dev_I__Close_Date__c;
    }
    public String Description(){
        return gb.cv_pkg_dev_I__Description__c;
    }
    public Integer Cash_Gifts(){
        return (Integer)gb.cv_pkg_dev_I__Cash_Gifts__c;
    }
    public  Integer Cash(){
        return (Integer)gb.cv_pkg_dev_I__Cash__c;
    }
    public  Integer Cheque_Gifts(){
        return (Integer)gb.cv_pkg_dev_I__Cheque_Gifts__c;
    }
    
     public  Integer Credit_Card(){
        return (Integer)gb.cv_pkg_dev_I__Credit_Card__c;
    }
     public  Integer  Cheque(){
        return (Integer)gb.cv_pkg_dev_I__Cheque__c;
    }
     public  Integer Credit_Card_Gifts(){
        return (Integer)gb.cv_pkg_dev_I__Credit_Card_Gifts__c;
    }
    
    public  Integer Direct_Deposit(){
        return (Integer)gb.cv_pkg_dev_I__Direct_Deposit__c;
    }
    public  Integer Direct_Deposit_Gifts(){
        return (Integer)gb.cv_pkg_dev_I__Direct_Deposit_Gifts__c;
    }
    public  Integer Other_Gifts(){
        return (Integer)gb.cv_pkg_dev_I__Other_Gifts__c;
    }
   
    public String[] getobjlist() {
        return objlist;
    }
    
     public String[] getfieldlabellist() {
        return fieldlabellist;
    }
     public String[] getfieldnamelist() {
        return fieldnamelist;
    }
   
    
  

   
    
   
   
    public PageReference save() {
     gb.cv_pkg_dev_I__Open_Date__c=Open_Date;
     gb.cv_pkg_dev_I__Name__c = Name;
     gb.cv_pkg_dev_I__Close_Date__c=Close_Date;
     gb.cv_pkg_dev_I__Description__c=Description;
     gb.cv_pkg_dev_I__Cash_Gifts__c=Cash_Gifts;
     gb.cv_pkg_dev_I__Cash__c=Cash;
     gb.cv_pkg_dev_I__Cheque_Gifts__c=Cheque_Gifts;
     gb.cv_pkg_dev_I__Cheque__c=Cheque;
     gb.cv_pkg_dev_I__Credit_Card_Gifts__c=Credit_Card_Gifts;
     gb.cv_pkg_dev_I__Credit_Card__c=Credit_Card;
     gb.cv_pkg_dev_I__Direct_Deposit_Gifts__c=Direct_Deposit_Gifts;
     gb.cv_pkg_dev_I__Direct_Deposit__c=Direct_Deposit;
     gb.cv_pkg_dev_I__Other_Gifts__c=Other_Gifts;
     gb.cv_pkg_dev_I__Other__c=Other;


        
        
       
     insert gb;
     XmlSumParserClass_moc parser = new XmlSumParserClass_moc();
       
       
        Batch_Template__c temp = new Batch_Template__c();
        string AccountXml;
        string ContactXml;
        string EventRegistrationsXml;
        string GiftDetailXml;
        string PaymentXml;
        string RecurringGiftXml;
        string TransactionXml;
        string ReceiptXml;
       
        temp = [select id,AccountFieldsXml__c,ContactFieldXml__c  ,EventRegistrationsFieldsXml__c,
                          GiftDetailFieldsXml__c,PaymentFieldsXml__c,ReceiptFieldsXml__c,RecurringGiftFieldsXml__c,
                          TransactionFieldsXml__c from Batch_Template__c where id='a0gi0000000ynzM'];
        AccountXml= temp.AccountFieldsXml__c;
        AccountshowMap=parser.sumParser(AccountXml);
        
        For(String outerKey : AccountshowMap.keySet()) {
            
           System.debug('Print Object Name====> '+ outerKey);
           objList.add(outerkey);
           Map<String,String> innerMap = AccountshowMap.get(outerKey);

           for(String innerKey : innerMap.keySet()) {
               System.debug('Print Key====> '+ innerKey);
               System.debug('Print value====> '+ innerMap.get(innerKey));
               fieldlabellist.add(innerKey);
               fieldnamelist.add( innerMap.get(innerKey));
           }
        }
            
        
       
     return null;
        
   }
    
  /* public Map<string,Map<string,string>>ShowSummary() {
       XmlSumParserClass_moc parser = new XmlSumParserClass_moc();
       
       
        Batch_Template__c temp = new Batch_Template__c();
        string str;
        temp = [select id,AccountFieldsXml__c,ContactFieldXml__c from Batch_Template__c  where id='a0gi0000000ynzM'];
        str = temp.AccountFieldsXml__c;
        showMap=parser.sumParser(str);
        
        return showMap;
   }*/
   
}