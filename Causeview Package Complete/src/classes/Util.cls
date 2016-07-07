public class Util {
    
    @future
   public static void allocationUpdate(Set<id> allocIds) //user story #102396768
   {
    system.debug('*************** *******hi***** ****************');
    List<causeview__Gift_Detail__c> allocs = new List<causeview__Gift_Detail__c>();
    allocs= [select id, causeview__Posted_to_Finance__c from causeview__Gift_Detail__c where id in :allocIds ];
    for(causeview__Gift_Detail__c tempAllo : allocs){
        tempAllo.causeview__Posted_to_Finance__c = system.Today();
    }
    update allocs;
   } 
  
  public class PieWedgeData {

        public String name { get; set; }
        public decimal data { get; set; }

        public PieWedgeData(String name, decimal data) {
            this.name = name;
            this.data = data;
        }
    }
    
    public static AggregateResult FindItem(List<AggregateResult> objects, object value, string property)
    {
         for(AggregateResult obj : objects)
          if (obj.get(property) == value)
           return obj;
           
         return null;
    }
    
    public static Sobject FindObject(List<Sobject> objects, object value, string property)
    {
         for(Sobject obj : objects)
          if (obj.get(property) == value)
           return obj;
           
         return null;
    }
    
    public static string GetRecordTypeId(string sobjecttype, string recordTypeName)
    {
        string SchoolRecType = '';    
        for(RecordType rt: [select id,name from recordtype where sobjecttype=:sobjecttype]) 
          if (rt.name == recordTypeName) {
           SchoolRecType = rt.id;
           break;
          }
          
        return SchoolRecType;
   }
  
  public static double getDifferenceInSeconds(datetime firstDT, datetime secondDT){  
   long dt1 = firstDT.getTime() / 1000;  //getTime gives us milliseconds, so divide by 1000 for seconds  
   long dt2 = secondDT.getTime() / 1000;
   double d = dt1 - dt2;
   return d;
  }
  
  public static string SerializeRecurringItems(List<causeview__Recurring_Donation__c> recurrings)
  {
      List<RecurringWrapper> items = new List<RecurringWrapper>(); 
      for(causeview__Recurring_Donation__c rd : recurrings) {
            RecurringWrapper wrapper = new RecurringWrapper();
            wrapper.Id = rd.Id;
            wrapper.Token = rd.Reference__c;
            wrapper.Frequency = rd.Frequency__c;
            wrapper.Amount = rd.Amount__c;
            wrapper.Status = rd.causeview__Status__c;
            items.add(wrapper);
      }
      return Json.serialize(items);
  }
  
  @future(callout=true)
  public static void SubmitRecurringChanges(string rawData, string purpose)
  {
     causeview__BatchSettings__c settings = causeview__BatchSettings__c.getInstance('Default');
     string url = settings.causeview__GatewayUrl__c.replace('Gateway.asmx', 'RecurringUpdate.aspx');
     
     if(purpose == 'EnableDisableProfile')
        url = settings.causeview__GatewayUrl__c.replace('Gateway.asmx', 'EnableDisableProfile.aspx');
     
     system.debug('-----' + url + '-----');
     
     Blob privateKey = EncodingUtil.base64Decode('KZtOAkl7zb9HghhEtffV0KJlQdYdFrOGThmQBGhR0s4=');
     string iv = '@1B2c3D4e5F6g7H8';
     //Blob msg = EncodingUtil.base64Encode(pBlob) (rawData);
     
     string encrypted = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Crypto.encrypt('AES256', privateKey, Blob.valueOf(iv), Blob.valueOf(rawData))),'UTF-8');
     system.debug(encrypted);
     
     Http h = new Http();
     HttpRequest req = new HttpRequest();
     req.setEndpoint(url);
     req.setMethod('POST');
     req.setTimeout(60000);
     req.setBody('data='+encrypted);    
     HttpResponse res = h.send(req);
     string response = res.getBody();
     system.debug(response);
     //return true;
  }
  
  public class RecurringWrapper
  {
      public string Id { get; set; }
      public string Token { get; set; }
      public string Frequency { get; set; }
      public decimal Amount { get; set; }
      public string Status { get; set; }
  }
  
  @isTest
  static void testMe()
  {
     Util.getDifferenceInSeconds(DateTime.now(), DateTime.now());
     Util.RecurringWrapper wrapper = new Util.RecurringWrapper();
     wrapper.Amount = 44; wrapper.Id = 'ddd'; wrapper.Token = 'ddd'; wrapper.Frequency = 'ssss'; wrapper.Status = 'ddd';
     
     List<causeview__Recurring_Donation__c> recurrings = new  List<causeview__Recurring_Donation__c>();
     recurrings.add(new causeview__Recurring_Donation__c(Reference__c='ddd',Frequency__c='dsdsd', Amount__c=234,Status__c='AAS'));
     string result = Util.SerializeRecurringItems(recurrings);
     
     List<Contact> cons = new List<Contact>();
     Contact c = new Contact();
     c.FirstName = 'Test';
     cons.add(c);
     c = new Contact();
     c.FirstName = 'Sam';
     cons.add(c);
     c = new Contact();
     c.FirstName = 'Vahid';
     cons.add(c);
     c = new Contact();
     c.FirstName = 'Lee';
     cons.add(c);
     
     Contact c2 = (Contact)FindObject(cons, 'Lee', 'FirstName');
     
     GetRecordTypeId('', '');
     
     FindItem(new List<AggregateResult>(), c, 'Name');
     
     PieWedgeData pwd = new PieWedgeData('temp', 500);
     
     causeview__BatchSettings__c settings = new causeview__BatchSettings__c();
     settings.Name = 'Default';
     
     //insert settings;
     
     //SubmitRecurringChanges('OBSDFNO');
     
     
  }

}