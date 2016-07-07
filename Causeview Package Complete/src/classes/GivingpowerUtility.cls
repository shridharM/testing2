public with sharing class GivingpowerUtility {
   
   public static final string FIELD_TYPE_TEXT = 'Text';
   public static final string FIELD_TYPE_INT = 'Integer';
   public static final string FIELD_TYPE_DOUBLE = 'Double';
   public static final string FIELD_TYPE_DATE = 'Date';
   public static final string FIELD_TYPE_DATETIME = 'DateTime';
   public static final string FIELD_TYPE_BOOLEAN = 'Boolean';
   
    /*public static void RecalcAppealTracking(Set<ID> CIDs)
    {                           
        AppealTrackerSettings__c s = [SELECT Appeal_ID__c, Lapse_Period__c, Run_Date__c FROM AppealTrackerSettings__c LIMIT 1];        
        if(s == null)
        { return; }
        
        Appeal__c a = [SELECT Lifetime_Income__c FROM Appeal__c WHERE Id = :s.Appeal_ID__c];
        List<Contact> cs = [SELECT Id FROM Contact WHERE Id IN :CIDs];
        a.Lifetime_Income__c = 0;
        
        for (Contact c : cs)
        {
            List<Gift__c> gs = [SELECT Id, Amount__c, Gift_Date__c, (SELECT Appeal__c FROM Gift_Allocations__r) FROM Gift__c WHERE Constituent__c = :c.Id ORDER BY Gift_Date__c];
            Integer i = 0; 
            Decimal sum = 0;
            Date rDate;
            Boolean notFound = true;

            while (notFound) 
            {
                for (Gift_Detail__c gd : gs[i].Gift_Allocations__r)
                {
                    if (gd.Appeal__c == s.Appeal_ID__c)
                    { rDate = gs[i].Gift_Date__c; notFound = false; }
                }
                i++;
            }


            if (i == 0)
            {
                for (Integer d = i; d < gs.size(); d++)
                { sum += gs[d].Amount__c; }
            }
            else if (gs[i-1].Gift_Date__c.daysBetween(gs[i].Gift_Date__c) >= (s.Lapse_Period__c * 365))
            {
                for (; i < gs.size() - 1; i++)
                { 
                    if (gs[i].Gift_Date__c.daysBetween(gs[i+1].Gift_Date__c) >= (s.Lapse_Period__c * 365))
                    { sum += gs[i].Amount__c; break; }
                    else
                    { sum += gs[i].Amount__c; if (i == gs.size() - 2) { sum += gs[i+1].Amount__c; } }                                   
                }            
            }
            
            c.Lifetime_Appeal_Amount__c = sum;
            a.Lifetime_Income__c += sum;
            c.Appeal_Recovery_Gift_Date__c = rDate;
        }
        
        update cs;
        update a;
    }*/
    
    //array of dates, returns number of conseq years
    public static Integer ConseqFiscalYears(List<Date> dates, Integer fysm)
    {
        system.debug('date size==>'+dates.size());
        system.debug('-------------------------------Dates------------------');
        system.debug(dates);
        system.debug('-------------------------------Dates------------------');
        
        //To return 0 if no transaction exists
        Integer conseq = 0;
        //add nitin
        Set<Integer> dateSet = new Set<Integer>();
        List<Integer> dateList = new List<Integer>();
        if(dates.size() > 0)
        {
          for (Integer i = (dates.size()-1); i >= 0; i--)
          { 
            if(dates[i] > Date.Today()){
                dates.remove(i);                
            }
          }
        }
        
        system.debug('Dates==>'+dates);
        system.debug('Dates==>'+dates.size());
        
        
     //getting distinct set of sorted records removing null values from it
      //change nitin
      set<Date> setDate  = new set<Date>(dates);
      setDate.remove(null);
      dates.clear();
      dates.addAll(setDate);   
      //dates.sort();
      //add nitin
        if(dates.size() > 0)
        {
            system.debug('Dates==>'+dates);
            system.debug('Dates==>'+dates.size());
            for (date d : dates)
            {
                dateSet.add(d.year());
            }
        }
      dateList.addAll(dateSet);
      dateList.sort();
      system.debug(dateList);        
       //change nitin
       //assign the size of date list to variable
      //Integer listSize = dates.size();
      Integer listSize = dateList.size();
      
      //if size is greater then zero then to proceed
        if(listSize > 0)
        { 
            conseq = 0;
            
            system.debug('--------------listSize: '+listSize);
            system.debug('--------------dates: '+dateList);
            
            /*  calculating the conseq for the max date available in date list. atleast one date will be there
            *   Fetching the last date from the list of dates which will be the max year subtracted from previous year
            */
             //conseq = (dates[listSize - 1].year())-(Date.Today().Year()-1);
             conseq = (dateList[listSize - 1])-(Date.Today().Year()-1);
             
             //If year is the previous year it will be 0 then to return -1
             //if(conseq == 0 && (dates[listSize - 1].year()) == (Date.Today().Year()-1)) 
             if(conseq == 0 && (dateList[listSize - 1]) == (Date.Today().Year()-1))
                 conseq = 1;
            
             system.debug('conseq is '+conseq);
               system.debug('listSize==> '+listSize+' conseq==>'+conseq);
           //If the dates size is greater then 1 then for checking the consecutive
           //checking for consecutive years 
           if(listSize > 1 && conseq > 0)
            { 
             
               system.debug('listSize==> '+listSize+' conseq==>'+conseq);
               //calulating the consecutive years
               for (Integer i = (listSize - 2); i >= 0; i--)
                { 
                   system.debug('listSize==> '+listSize);
                   //change Nitin
                 //Difference between the two years is calculated if it is 1 it means its consecutive
                 //Checking the latest consecutive year, if its positive then to add all else to go on subtracting
                  /*if(((dates[i+1].year() - dates[i].year()) == 1)   &&  (conseq > 0))
                   {
                      conseq++;
                      system.debug('in increment :'+conseq);
                    }
                  else if((dates[i+1].year() - dates[i].year()) == 1 &&  (conseq < 0))
                    {
                        conseq--;
                        system.debug('in decrement:'+conseq);
                    } 
                  else
                   break;       */
                    
                      
                if(((dateList[i+1] - dateList[i]) == 1))
                   {
                     
                      conseq++;
                      system.debug('in increment :'+conseq);
                    }
                  else
                   break;        
                }      
             }    
             
        }
        else
          conseq = 0;
          system.debug('conseq is '+conseq);  
          return conseq ;      
    }
   
   public static Boolean isCurrentFiscal(Date aDate, Integer fysm)
   {
       Integer FYrStrtMonth = fysm;
       if (aDate == null)
           return false;
       
       //if the fiscal year starts on Jan 1st, then we only need to check the year
       if (FYrStrtMonth == 1 && aDate.Year() == Date.Today().Year())
       { return true; }       
       //if the current month is beyond the starting fiscal month, the fiscal year ends in the next calendar year
       if (Date.Today().Month() >= FYrStrtMonth && aDate > Date.newInstance(Date.Today().Year(), FYrStrtMonth, 1) && aDate < Date.newInstance(Date.Today().Year() + 1, FYrStrtMonth, 1))
       { return true; }
       //if the current month has not reached the starting fiscal month, the fiscal year began in the previous calendar year       
       else if (Date.Today().Month() < FYrStrtMonth && aDate > Date.newInstance(Date.Today().Year() - 1, FYrStrtMonth, 1) && aDate < Date.newInstance(Date.Today().Year(), FYrStrtMonth, 1))
       { return true; }
              
       return false;
   }
   
   public static Boolean isLastFiscalYear(Date aDate, Integer orgFiscalYearStartMonth)
   {
       if (aDate == null)
           return false;
       
       //if the fiscal year starts on Jan 1st, then we only need to check the year
       if (orgFiscalYearStartMonth == 1 && aDate.Year() == Date.Today().Year() - 1)
       { return true; }       
       //if the current month is beyond the starting fiscal month, the fiscal year ends in the next calendar year
       if (Date.Today().Month() >= orgFiscalYearStartMonth && aDate > Date.newInstance(Date.Today().Year() - 1, orgFiscalYearStartMonth, 1) && aDate < Date.newInstance(Date.Today().Year(), orgFiscalYearStartMonth, 1))
       { return true; }
       //if the current month has not reached the starting fiscal month, the fiscal year began in the previous calendar year       
       else if (Date.Today().Month() < orgFiscalYearStartMonth && aDate > Date.newInstance(Date.Today().Year() - 2, orgFiscalYearStartMonth, 1) && aDate < Date.newInstance(Date.Today().Year() - 1, orgFiscalYearStartMonth, 1))
       { return true; }
              
       return false;
   }

   public static Schema.SObjectType findSobjectType(string sObjectName) {
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    for(string key : gd.keySet())
     if (key == sObjectName)
       return gd.get(key);
    return null;
  }
   
  public static SObject setFieldValue(SObject obj, string fieldName, string fieldType, string Value)
  {
       if (fieldType == GivingpowerUtility.FIELD_TYPE_BOOLEAN) {   
            Value = Value.toLowerCase();
            obj.put(fieldName,Value.equals('true'));
       }
       else if (fieldType == GivingpowerUtility.FIELD_TYPE_DATE)
            obj.put(fieldName,Date.parse(Value));
       else if (fieldType == GivingpowerUtility.FIELD_TYPE_DATETIME)
            obj.put(fieldName,DateTime.parse(Value));
       else if (fieldType == GivingpowerUtility.FIELD_TYPE_DOUBLE)
            obj.put(fieldName,Double.valueOf(Value));
       else if (fieldType == GivingpowerUtility.FIELD_TYPE_INT)
            obj.put(fieldName,Integer.valueOf(Value));
       else
            obj.put(fieldName,String.valueOf(Value));         
       return obj;
  }
  
  public static Boolean IsEmptyOrNull(string value) {
    return (value==null || value=='');
  }
  
  public static string formatDateForQuery(Date d)
  {
    string year = decimal.valueOf(d.year()).toPlainString();
    string month = decimal.valueOf(d.month()).toPlainString();
    string day = decimal.valueOf(d.day()).toPlainString();
    month = addLeadingZero(month);
    day = addLeadingZero(day);
    return year+'-'+month+'-'+day;  
  }
  
  public static string formatDateTimeForQuery(DateTime d)
  {
    string year = decimal.valueOf(d.year()).toPlainString();
    string month = decimal.valueOf(d.month()).toPlainString();
    string day = decimal.valueOf(d.day()).toPlainString();
    month = addLeadingZero(month);
    day = addLeadingZero(day);
    string formattedDate = year+'-'+month+'-'+day;
    string hour = decimal.valueOf(d.hour()).toPlainString();
    string min =  decimal.valueOf(d.minute()).toPlainString();
    string second =  decimal.valueOf(d.second()).toPlainString();
    hour = addLeadingZero(hour);
    min = addLeadingZero(min);
    second = addLeadingZero(second);
    
    return formattedDate+'T'+hour+':'+min+':'+second+'Z';
  }
  
  private static string addLeadingZero(string val)
  {
    if (val.length()==1)
      val = '0'+val;
    return val;
  }
}