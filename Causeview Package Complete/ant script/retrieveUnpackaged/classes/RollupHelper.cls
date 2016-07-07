public without sharing class RollupHelper {
 

 
public static void GuestRegistrations(Set<Gift__c> giftIds) {
    System.debug('<==Inside GuestRegistrations==>');
    Set<Event_Registration__c> eventRegs = new Set<Event_Registration__c>();
    BatchSettings__c settings = BatchSettings__c.getInstance();
    List<Gift__c> gifts = [SELECT Id, Attendee_Names_Pending__c, Constituent__c, (SELECT Id, Registration_Date__c, Event__c, Transaction__c FROM Event_Registrations__r WHERE Individual__c != :settings.Unknown_Guest_Id__c) FROM Gift__c WHERE Id IN :giftIds];
    for (Gift__c g : gifts) {
        system.debug('<==g==>'+g);
        if (g.Event_Registrations__r.size() > 0) {           
            for (Integer i = 0; i < g.Attendee_Names_Pending__c; i++) {
                system.debug('<==g1==>'+g);
                Event_Registration__c e = new Event_Registration__c();
                e.Transaction__c = g.Id;
                e.Event__c = g.Event_Registrations__r[0].Event__c;
                e.Registration_Date__c = g.Event_Registrations__r[0].Registration_Date__c;
                e.Individual__c = settings.Unknown_Guest_Id__c;
                e.Guest_Of__c = g.Constituent__c;
                if (e.Registration_Date__c != null && e.Event__c != null && e.Transaction__c != null && e.Individual__c != null) { eventRegs.add(e); }
            }
        }
    }
    insert new List<Event_Registration__c>(eventRegs);
}
 
public static void RecalculateTotalHouseholdGiving(Set<Id> hhIds)
{
    System.debug('<==Inside RecalculateTotalHouseholdGiving==>');
    system.debug(hhIds);
    if (hhIds == null || hhIds.size()<=0) return;
    
    List<Account> households = [SELECT Id, cv_pkg_dev_I__Total_Fiscal_Household_Transactions__c , cv_pkg_dev_I__Total_Household_Transactions__c , cv_pkg_dev_I__Total_Household_Giving__c , cv_pkg_dev_I__Total_Fiscal_Household_Giving__c ,  (SELECT Id, cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c, cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c, cv_pkg_dev_I__Total_Fiscal_Year_Giving__c, cv_pkg_dev_I__Total_Lifetime_Fundraising__c, cv_pkg_dev_I__Total_Lifetime_Giving__c , cv_pkg_dev_I__Total_Fiscal_Fundraising__c FROM cv_pkg_dev_I__HouseholdContacts__r) FROM Account WHERE Id IN :hhIds FOR UPDATE];
    
    integer org = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
    
    List<Date> gDates = new List<Date>();
    List<Date> tDates = new List<Date>();
    Set<String> cIds = new Set<String>();
    
    for(Account a : households)
    {
        Decimal totalAmount = 0;        
        Decimal totalFiscalAmount = 0;
        
        Decimal totalGivingAmount = 0;
        Decimal totalFiscalGivingAmount = 0;
        
        Decimal totalFundraisingAmount = 0;
        Decimal totalFiscalFundraisingAmount = 0;          
        for(Contact c : a.cv_pkg_dev_I__HouseholdContacts__r)
        {
            if (c.cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c != 0 && c.cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c != null)
            { totalFiscalAmount += c.cv_pkg_dev_I__Total_Fiscal_Transaction_Amount__c; }
            if (c.cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c!= 0 && c.cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c!= null)
            { totalAmount += c.cv_pkg_dev_I__Total_Lifetime_Transaction_Amount__c; }
            
            if (c.cv_pkg_dev_I__Total_Fiscal_Year_Giving__c!= 0 && c.cv_pkg_dev_I__Total_Fiscal_Year_Giving__c!= null)
            { totalFiscalGivingAmount += c.cv_pkg_dev_I__Total_Fiscal_Year_Giving__c; }
            if (c.cv_pkg_dev_I__Total_Lifetime_Giving__c!= 0 && c.cv_pkg_dev_I__Total_Lifetime_Giving__c!= null)
            { totalGivingAmount += c.cv_pkg_dev_I__Total_Lifetime_Giving__c; }   
            
            if (c.cv_pkg_dev_I__Total_Lifetime_Fundraising__c != 0 && c.cv_pkg_dev_I__Total_Lifetime_Fundraising__c != null)
            { totalFundraisingAmount += c.cv_pkg_dev_I__Total_Lifetime_Fundraising__c; }  
            
            //newly added code 
            if(c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c != 0 && c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c != null)
            {totalFiscalFundraisingAmount += c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c; }
            
            
             
            
        }    
        
        a.cv_pkg_dev_I__Total_Household_Giving__c = totalGivingAmount;
        a.cv_pkg_dev_I__Total_Fiscal_Household_Giving__c = totalFiscalGivingAmount;
        
        a.cv_pkg_dev_I__Total_Household_Transactions__c = totalAmount;
        a.cv_pkg_dev_I__Total_Fiscal_Household_Transactions__c = totalFiscalAmount;
        
        a.cv_pkg_dev_I__Total_Household_Fundraising__c = totalFundraisingAmount;
        a.cv_pkg_dev_I__Total_Fiscal_Household_Fundraising__c  = totalFiscalFundraisingAmount ;        
    }
    
    update households;
} 

public static void RecalculateTotalGivingForOrg(Set<Id> orgIds)
{
    System.debug('<==Inside RecalculateTotalGivingForOrg==>');
    if (orgIds == null || orgIds.size()<=0) return;
    BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
    String RecordTypeIdforRollup1;
        List<String> RecordTypeIdsforRollup1;
        Set<String> recordIds = new Set<String>();
        RecordTypeIdforRollup1 = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
        system.debug('dbglg '+RecordTypeIdforRollup1);
        
         if(RecordTypeIdforRollup1 != null)
            RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');
         else
            RecordTypeIdforRollup1 = settings.Record_Type_Id_for_Rollups__c;
            
   
            
        if(RecordTypeIdsforRollup1!= null && RecordTypeIdsforRollup1.size()>0)
        {
            for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++)
            {
                    system.debug('dbglog '+RecordTypeIdsforRollup1.size());

                recordIds.add(RecordTypeIdsforRollup1[i]);
            }
        }
    List<Account> accounts = [Select Id,Consecutive_Years_of_Giving__c, Consecutive_Years_of_Transactions__c, 
        Total_Lifetime_Gifts__c, Total_Lifetime_Giving__c, Total_Fiscal_Gifts__c,
        Total_Fiscal_Year_Giving__c, Total_Lifetime_Transactions__c, Total_Lifetime_Transaction_Amount__c,
        Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c, 
        (Select Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId From cv_pkg_dev_I__Orders__r ORDER BY CreatedDate DESC,Gift_Date__c DESC)
        From Account WHERE id IN :orgIds FOR UPDATE]; 
    
    integer org = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
    
    List<Date> gDates = new List<Date>();
    List<Date> tDates = new List<Date>();
    
    for(Account c : accounts)
    {
        Decimal lastGiftAmount = 0;
        Decimal totalAmount = 0;        
        Decimal totalFiscalAmount = 0;
        Decimal totalCount = 0;
        Decimal totalFiscalCount = 0;
        
        Decimal totalGivingAmount = 0;
        Decimal totalFiscalGivingAmount = 0;
        Decimal totalGivingCount = 0;
        Decimal totalFiscalGivingCount = 0;
        
        Decimal total_additional_solicitations = 0;
        Decimal total_solicitations = 0;
        
        if (c.cv_pkg_dev_I__Orders__r!= null)
        {
            if(c.cv_pkg_dev_I__Orders__r.size() > 0) { lastGiftAmount = c.cv_pkg_dev_I__Orders__r[0].Amount__c; }            
        }
                
        for(Gift__c g : c.cv_pkg_dev_I__Orders__r)
        {                     
            if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
            { totalGivingAmount += g.Amount__c; totalAmount += g.Amount__c; gDates.add(g.Gift_Date__c); tDates.add(g.Gift_Date__c); totalGivingCount++; totalCount++;}
            else
            { totalAmount += g.Amount__c; tDates.add(g.Gift_Date__c); totalCount++; }        
                        
            if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
            { 
                 if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                { totalFiscalGivingAmount += g.Amount__c; totalFiscalAmount += g.Amount__c; totalFiscalGivingCount++; totalFiscalCount++; }
                else
                { totalFiscalAmount += g.Amount__c; totalFiscalCount++; }
            }
        }
        
        for(Solicitor__c s : c.Soft_Credits__r)
            total_additional_solicitations += s.Amount__c;
        for(Gift__c g2 : c.Orders1__r)
            total_solicitations += g2.Amount__c;
                    
        if (gDates.size() != 0)
        {
            if (org == null)
            { c.Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, 1); }
            else
            { c.Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, org); }
        }
        
        if (tDates.size() != 0)
        {
            if (org == null)
            { c.Consecutive_Years_of_Transactions__c = GivingpowerUtility.ConseqFiscalYears(tDates, 1); }
            else
            { c.Consecutive_Years_of_Transactions__c = GivingpowerUtility.ConseqFiscalYears(tDates, org); }
        }
        
        c.Total_Lifetime_Gifts__c = totalGivingCount;
        c.Total_Lifetime_Giving__c = totalGivingAmount;
        
        c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
        c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;
        
        c.Total_Lifetime_Transactions__c = totalCount;       
        c.Total_Lifetime_Transaction_Amount__c = totalAmount;

        c.Last_Gift_Amount__c = lastGiftAmount;        
        
        c.Total_Fiscal_Transactions__c = totalFiscalCount;
        c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;
        
        c.Total_Lifetime_Fundraising__c = totalAmount + total_additional_solicitations + total_solicitations;   
        c.Last_Gift_Amount__c = lastGiftAmount;        
    }
    
    update accounts;
}

 //----------------------------------------------------------------------------------------------------
public static void RecalculateTotalGiving(Set<Id> ContactIds)
{
  system.debug('----------------------------------Inside RollupHelper.RecalculateTotalGiving--------------------------------------------------------');
    if (ContactIds == null || ContactIds.size()<=0)
        return;

    BatchSettings__c settings =  BatchSettings__c.getInstance('Default');   
    
    String RecordTypeIdforRollup1;
        List<String> RecordTypeIdsforRollup1;
        Set<String> recordIds = new Set<String>();
        RecordTypeIdforRollup1 = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
        system.debug('dbglg '+RecordTypeIdforRollup1);
        
        if(RecordTypeIdforRollup1 != null)
            RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');
            
        
        if(RecordTypeIdsforRollup1!=null && RecordTypeIdsforRollup1.size()>0)
        {
        for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++)
        {
                    system.debug('dbglog '+RecordTypeIdsforRollup1.size());

            recordIds.add(RecordTypeIdsforRollup1[i]);
        }
        }
    
    List<Contact> contacts = new List<Contact>();/*[Select Id, Consecutive_Years_of_Giving__c, Consecutive_Years_of_Transactions__c, 
    Total_Lifetime_Gifts__c, Total_Lifetime_Giving__c, Total_Fiscal_Gifts__c,
    Total_Fiscal_Year_Giving__c, Total_Lifetime_Transactions__c, Total_Lifetime_Transaction_Amount__c,cv_pkg_dev_I__Total_Fiscal_Fundraising__c,
    Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c, Total_Lifetime_Fundraising__c,
    (Select Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId From Gifts__r ORDER BY Gift_Date__c DESC , CreatedDate DESC),
    (Select Id, Amount__c, Gift_Status__c From Additional_Solicitations__r), 
    (Select Id, Amount__c, Status__c From Gifts1__r),
    (Select npe4__RelatedContact__c FROM npe4__Relationships1__r where cv_pkg_dev_I__Apply_Soft_Credit__c=true)
    From Contact c WHERE id IN :ContactIds FOR UPDATE];*/       
    integer org;
    
    org = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
    
    List<Date> gDates = new List<Date>();
    List<Date> tDates = new List<Date>();
    
    for(Contact c : contacts)
    {
        Decimal lastGiftAmount = 0;
        Decimal totalAmount = 0;        
        Decimal totalFiscalAmount = 0;
        Decimal totalCount = 0;
        Decimal totalFiscalCount = 0;
        
        Decimal totalGivingAmount = 0;
        Decimal totalFiscalGivingAmount = 0;
        Decimal totalGivingCount = 0;
        Decimal totalFiscalGivingCount = 0;
        
        Decimal total_additional_solicitations = 0;
        Decimal total_solicitations = 0;

        if (c.Gifts__r != null)
        {
            if(c.Gifts__r.size() > 0) 
            { 
                 lastGiftAmount = c.Gifts__r[0].Amount__c; 
            }            
        }

        for(Gift__c g : c.Gifts__r)
        {                     
            if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
            { totalGivingAmount += g.Amount__c; totalAmount += g.Amount__c; gDates.add(g.Gift_Date__c); tDates.add(g.Gift_Date__c); totalGivingCount++; totalCount++;}
            else
            { totalAmount += g.Amount__c; tDates.add(g.Gift_Date__c); totalCount++; }        
                        
            if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
            { 
                if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                { totalFiscalGivingAmount += g.Amount__c; totalFiscalAmount += g.Amount__c; totalFiscalGivingCount++; totalFiscalCount++; }
                else
                { totalFiscalAmount += g.Amount__c; totalFiscalCount++; }
            }
        }
        if (c.Additional_Solicitations__r!=null)
          for(Solicitor__c s : c.Additional_Solicitations__r)
            total_additional_solicitations += (s.Amount__c==null)? 0 : s.Amount__c;
        for(Gift__c g2 : c.Gifts1__r)
            total_solicitations += g2.Amount__c;
        
        if (gDates.size() != 0)
        {
            //c.Longest_Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, org.FiscalYearStartMonth, false);
            if (org == null)
            {
            
            system.debug('-------------------------------------------------------------------');
            system.debug(gDates);
            system.debug('-------------------------------------------------------------------');
            
             c.Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, 1); }
            else
            { c.Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, org); }
        }
        
        if (tDates.size() != 0)
        {
            //c.Longest_Consecutive_Years_of_Transaction__c = GivingpowerUtility.ConseqFiscalYears(tDates, org.FiscalYearStartMonth, false);
            if (org == null)
            { c.Consecutive_Years_of_Transactions__c = GivingpowerUtility.ConseqFiscalYears(tDates, 1); }
            else
            { c.Consecutive_Years_of_Transactions__c = GivingpowerUtility.ConseqFiscalYears(tDates, org); }
        }
        
        c.Total_Lifetime_Gifts__c = totalGivingCount;
        c.Total_Lifetime_Giving__c = totalGivingAmount;
        
        c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
        c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;
        
        c.Total_Lifetime_Transactions__c = totalCount;       
        c.Total_Lifetime_Transaction_Amount__c = totalAmount;
        
        c.Total_Fiscal_Transactions__c = totalFiscalCount;
        c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;
        
        c.Last_Gift_Amount__c = lastGiftAmount;
        
        c.Total_Lifetime_Fundraising__c = totalAmount + total_additional_solicitations + total_solicitations;
        //newly added field ---Total Fiscal Fundraising   
        c.cv_pkg_dev_I__Total_Fiscal_Fundraising__c =  totalFiscalAmount + total_additional_solicitations + total_solicitations;
        
        
         
    }

    update contacts;
     
  }

  //----------------------------------------------------------------------------------------------------
  public static void CreateIndividualSoftCredits(List<Gift__c> gifts) {
     System.debug('<==Inside CreateIndividualSoftCredits==>'+gifts);
     Map<Id, Solicitor__c> solicitorMap = new Map<Id, Solicitor__c>();
     Set<Id> contactIds = new Set<Id>();
     set<Id> giftIds = new Set<Id>();
     for(Gift__c g : gifts) {
        if (!contactIds.contains(g.Constituent__c) && !IsEmptyOrNull(g.Constituent__c))
          contactIds.add(g.Constituent__c);
          giftIds.add(g.id);
          System.debug('<==contactIds==>'+contactIds);
          System.debug('Gift==>'+gifts);
     }
     
    /*List<npe4__Relationship__c> relationships = [SELECT Id, npe4__Contact__c, npe4__RelatedContact__c 
       FROM npe4__Relationship__c WHERE npe4__Contact__c IN :contactIds 
       AND cv_pkg_dev_I__Apply_Soft_Credit__c=true AND npe4__RelatedContact__c !=null];
       System.debug('<==relationships==>'+relationships);
     //if (relationships==null || relationships.size()<=0) return;
     
    /*List<npe5__Affiliation__c> affiliations = [SELECT Id, npe5__Organization__c, npe5__Contact__c, npe5__Role__c 
       FROM npe5__Affiliation__c WHERE npe5__Contact__c IN :contactIds 
       AND cv_pkg_dev_I__Apply_Soft_Credit__c=true];

     //if (affiliations==null || affiliations.size()<=0) return;

     List<Solicitor__c> softCredits = new List<Solicitor__c>();
     for(Gift__c g : gifts) {
         for(npe4__Relationship__c item : relationships){
            if (item.npe4__Contact__c == g.Constituent__c) {
                Solicitor__c s = new Solicitor__c(Gift__c=g.Id,Role__c='General Soft Credit',Solicitor__c=item.npe4__RelatedContact__c);
                System.debug('<==softCredits==>'+s);
                softCredits.add(s);
                System.debug('<==softCredits2==>'+softCredits);
             }
         }
         for(npe5__Affiliation__c item : affiliations){
            if (item.npe5__Contact__c == g.cv_pkg_dev_I__Constituent__c) {
                Solicitor__c s = new Solicitor__c(Gift__c=g.Id,Role__c='General Soft Credit',Organization_Solicitor__c=item.npe5__Organization__c,Relationship__c=item.npe5__Role__c);
                softCredits.add(s);
            }
         }
     }
     if (softCredits.size()>0) {
         System.debug('<==softCredits1==>'+softCredits);
         insert softCredits;
     } 
     
  }
  
  //----------------------------------------------------------------------------------------------------
  public static void CreateOrganizationSoftCredits(List<Gift__c> gifts) {
     System.debug('<==Inside CreateOrganizationSoftCredits==>');
     Set<Id> contactIds = new Set<Id>();
     for(Gift__c g : gifts) {
        if (!contactIds.contains(g.Organization__c) && !IsEmptyOrNull(g.Organization__c))
          contactIds.add(g.Organization__c);
     }
     
    /*List<npe5__Affiliation__c> affiliations = [SELECT Id, npe5__Organization__c, npe5__Contact__c, npe5__Role__c 
       FROM npe5__Affiliation__c WHERE npe5__Organization__c IN :contactIds 
       AND cv_pkg_dev_I__Apply_Soft_Credit__c=true AND npe5__Contact__c !=null];
       
     if (affiliations==null || affiliations.size()<=0) return;
     
     List<Solicitor__c> softCredits = new List<Solicitor__c>();
     for(Gift__c g : gifts) {
         for(npe5__Affiliation__c item : affiliations)
            if (item.npe5__Organization__c == g.Organization__c) {
                Solicitor__c s = new Solicitor__c(Gift__c=g.Id,Role__c='General Soft Credit',Solicitor__c=item.npe5__Contact__c,Relationship__c=item.npe5__Role__c);
                softCredits.add(s);
            }
     }
     
     if (softCredits.size()>0) insert softCredits;*/ 
     
  }
  
   //---------------------------------------------------------------------------------------------------- 
   public static void RecalculateGiftDatesForOrg(Set<Id> orgIds)
   {
       System.debug('<==Inside RecalculateGiftDatesForOrg==>');
      BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
      String RecordTypeIdforRollup;
      List<String> RecordTypeIdsforRollup;
        RecordTypeIdforRollup = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
      if(RecordTypeIdforRollup != null)
            RecordTypeIdsforRollup = RecordTypeIdforRollup.Split(',');
      
      AggregateResult[] results = [SELECT AVG(Amount__c)avgGiftAmt, MAX(Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Organization__c org 
          FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c != null
               AND (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup)
          GROUP BY Organization__c]; 
      AggregateResult[] last_year = [SELECT SUM(Amount__c) total, Organization__c org
                                      FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c = LAST_YEAR
                                           AND   (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup) 
                                        GROUP BY Organization__c]; 
                                   
      Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1);
      Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31);      
                                                  
      AggregateResult[] last2_year = [SELECT SUM(Amount__c) total, Organization__c org
                                      FROM Gift__c WHERE Organization__c IN :orgIds AND Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
                                           AND   (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup) 
                                        GROUP BY Organization__c];           
      System.debug(results);              
  
      List<Account> accounts = [Select c.Id, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c From Account c Where Id IN :orgIds FOR UPDATE];    
      System.debug(accounts);
      for(Account c : accounts)
      {
        c.Total_Giving_Last_Year__c = 0;
        c.Total_Giving_Two_Years_Ago__c = 0;
      }
      
      if (results != null && results.size()>0)
      {
          for(AggregateResult result : results)
          {
              Account c = (Account)findItem('Id',String.valueOf(result.get('org')),accounts);
              if (c != null)
              {
                 c.Date_of_Last_Gift__c = Date.valueOf(result.get('maxGiftDate'));
                 c.Date_of_First_Gift__c = Date.valueOf(result.get('minGiftDate'));
                 c.Largest_Gift__c = (Decimal)result.get('maxGiftAmt');
                 c.Average_Gift__c = (Decimal)result.get('avgGiftAmt');  
                 
                 //https://www.pivotaltracker.com/story/show/105699872
                 c.cv_pkg_dev_I__Date_of_Last_Transaction__c = Date.valueOf(result.get('maxGiftDate'));
                 c.cv_pkg_dev_I__Date_of_First_Transaction__c = Date.valueOf(result.get('minGiftDate'));            
              }              
              
          }
      }      
      
      if (last_year != null && last_year.size()>0)
      {
          for(AggregateResult result : last_year)
          {              
              Account c = (Account)findItem('Id',String.valueOf(result.get('org')),accounts);
              if (c != null)
              {
                  c.Total_Giving_Last_Year__c = (Decimal)result.get('total');         
              }                         
          }
      } 
      
      if (last2_year != null && last2_year.size()>0)
      {
          for(AggregateResult result : last2_year)
          {              
              Account c = (Account)findItem('Id',String.valueOf(result.get('org')),accounts);
              if (c != null)
              {
                  c.Total_Giving_Two_Years_Ago__c = (Decimal)result.get('total');           
              }                         
          }
      }       
                 
      if (accounts != null && accounts.size()>0)
        update accounts;
        
   }
   //----------------------------------------------------------------------------------------------------
   public static void RecalculateGiftDates(Set<Id> contactIds)
   {
        System.debug('<==Inside RecalculateGiftDates==>');
      BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
      
      String RecordTypeIdforRollup;
      List<String> RecordTypeIdsforRollup;
      RecordTypeIdforRollup = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
      
      if(RecordTypeIdforRollup!=null)
        RecordTypeIdsforRollup = RecordTypeIdforRollup.Split(',');
      
      
      AggregateResult[] results = [SELECT AVG(Amount__c)avgGiftAmt, MAX(Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Constituent__c con 
          FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c != null
               AND  (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup)
          GROUP BY Constituent__c];
          
      System.debug(results);    
      
      AggregateResult[] last_year = [SELECT SUM(Amount__c) total, Constituent__c con
                                      FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c = LAST_YEAR
                                           AND  (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup)
                                        GROUP BY Constituent__c]; 
                                   
      Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1);
      Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31);      
                                                  
      AggregateResult[] last2_year = [SELECT SUM(Amount__c) total, Constituent__c con
                                      FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end
                                           AND  (RecordTypeId = :settings.RegularGiftRecordTypeId__c OR RecordTypeId In :RecordTypeIdsforRollup)
                                        GROUP BY Constituent__c];                                                    
      
      List<Contact> contacts = [Select c.Id, c.Date_of_Last_Gift__c, c.Date_of_First_Gift__c, c.Largest_Gift__c, c.Average_Gift__c,cv_pkg_dev_I__Date_of_Last_Transaction__c,cv_pkg_dev_I__Date_of_First_Transaction__c From Contact c Where Id IN :contactIds FOR UPDATE];    
      Set<ID> contactIdsToUpdate = new Set<ID>();
      for(Contact c : contacts)
      {
        c.Total_Giving_Last_Year__c = 0;
        c.Total_Giving_Two_Years_Ago__c = 0;
      }
      System.debug(contacts);
      
      if (last_year != null && last_year.size()>0)
      {
          for(AggregateResult result : last_year)
          {              
              Contact c = (Contact)findItem('Id',String.valueOf(result.get('con')),contacts);
              if (c != null)
              {
                  c.Total_Giving_Last_Year__c = (Decimal)result.get('total');  
                  if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);         
              }                         
          }
      } 
      
      if (last2_year != null && last2_year.size()>0)
      {
          for(AggregateResult result : last2_year)
          {              
              Contact c = (Contact)findItem('Id',String.valueOf(result.get('con')),contacts);
              if (c != null)
              {
                  c.Total_Giving_Two_Years_Ago__c = (Decimal)result.get('total'); 
                  if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);          
              }                         
          }
      }       
      
      if (results != null && results.size()>0)
      {
          for(AggregateResult result : results)
          {
              Contact c = (Contact)findItem('Id',String.valueOf(result.get('con')),contacts);
              if (c != null)
              {
                 c.Date_of_Last_Gift__c = Date.valueOf(result.get('maxGiftDate'));
                 c.Date_of_First_Gift__c = Date.valueOf(result.get('minGiftDate'));
                 c.Largest_Gift__c = (Decimal)result.get('maxGiftAmt');
                 c.Average_Gift__c = (Decimal)result.get('avgGiftAmt'); 
                 
                 
                 // for Date_of_Last_Transaction__c && Date_of_Last_Transaction__c field updates 
                 c.cv_pkg_dev_I__Date_of_Last_Transaction__c = Date.valueOf(result.get('maxGiftDate'));
                 c.cv_pkg_dev_I__Date_of_First_Transaction__c = Date.valueOf(result.get('minGiftDate'));
                 
                 if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);    
                 system.debug('hi---------average gift amount----' +c.Average_Gift__c );                 
              }              
              
          }
      }
      
      /* if (contacts != null && contacts.size()>0)
        update contacts; */
         List<Contact> values = new List<Contact>();
        for (Contact c : contacts)
        {
            if (contactIdsToUpdate.contains(c.Id)) values.add(c);
        }
        if (values.size() > 0) update values;
   }
   
  //----------------------------------------------------------------------------------------------------
  public static sObject findItem(String propertyName, String propertyValue, List<sObject> collection)
  {
      System.debug('<==Inside findItem==>'+propertyName +', '+propertyValue);
     if (isEmptyOrNull(propertyName) || isEmptyOrNull(propertyValue) || collection==null)
       return null;
      
     for(sObject item : collection){
     system.debug('Nitin==='+item.get(propertyName)+'------'+item);
      if (item.get(propertyName)==propertyValue)
        return item;
     }
        
     return null;
  }
  
  //----------------------------------------------------------------------------------------------------
  public static List<sObject> findItems(String propertyName, String propertyValue, List<sObject> collection)
  {
      System.debug('<==Inside findItems==>');
     if (isEmptyOrNull(propertyName) || isEmptyOrNull(propertyValue) || collection==null)
       return null;
       
     List<sObject> results = new List<sObject>();
     
     for(sObject item : collection)
      if (item.get(propertyName)==propertyValue)
        results.add(item);
        
     return results;
  }
  
  
  
  //----------------------------------------------------------------------------------------------------
  public static Boolean IsEmptyOrNull(string value) {
    return (value==null || value=='');
  }
   
   //----------------------------------------------------------------------------------------------------
   //----------------------------------------------------------------------------------------------------
   @future(callout=true)
   public static void issueReceipts(Set<Id> ReceiptIds)
   {
       System.debug('<==Inside issueReceipts==>');
    givingpowerSettings__c settings = null;
    string templateId = '';
    string consoTemplateId = '';
    string orgWideId = '';
    RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'cv_pkg_dev_I__Receipt__c' AND Name = 'Issued' LIMIT 1];
    givingpowerSettings__c settingsRecords = givingpowerSettings__c.getInstance('Settings');
    if (settingsRecords != null) { templateId = settingsRecords.EmailTemplateId__c; orgWideId = settingsRecords.Org_Wide_Email_ID__c; consoTemplateId = settingsRecords.ConsolidatedReceiptEmailTemplateId__c; }
    
    
    List<Receipt__c> rs =[Select Id, g.Status__c, g.Gift__r.Amount__c, 
       g.Gift__r.Recurring_Donation__c, g.Gift__c, g.Constituent__c, g.Auto_Email_Receipt__c, g.Receipt_Type__c 
       From Receipt__c g WHERE Id IN :ReceiptIds FOR UPDATE];
       
    List<Receipt__c> itemsToUpdate = new List<Receipt__c>();
  
    for(receipt__c r : rs)
    {  
       if (r.Auto_Email_Receipt__c == true && r.Gift__r.Amount__c > 0 && r.Status__c != 'Issued' && r.Constituent__c != null)
       {
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setSaveAsActivity(false);
             //Set Consolidated Email Template Id if Receipt is of type Consolidated.
             if(r.Receipt_Type__c == 'Consolidated') {
                 mail.setTemplateId(consoTemplateId);
             } else {
                 mail.setTemplateId(templateId);
             }
             mail.setTargetObjectId(r.Constituent__c);
             mail.setWhatId(r.Id);
             if (orgWideId != null && orgWideId != '')
             { mail.setOrgWideEmailAddressId(orgWideId); }             
             if (templateId != null && templateId != '')
             {
                 Try { 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    insert new Task(Subject = 'Automated Email Receipt Sent', Status = 'Completed', WhatId = r.Id, ActivityDate = Date.Today(), WhoId = r.Constituent__c, Type = 'Automated Email');
                    
                    
                     } catch(Exception ex) { }
             }
             
             r.Status__c = 'Issued';
             r.RecordTypeId = rt.Id;
             itemsToUpdate.add(r);         
       }
    }
    
    if (itemsToUpdate.size()>0)
     update itemsToUpdate;
   }
   
    
   @future
   public static void UpdateGDs(String CampId)
   {
       System.debug('<==Inside UpdateGDs==>');
       List<Gift_Detail__c> gds = [SELECT Id FROM Gift_Detail__c WHERE New_Campaign__c = :CampId FOR UPDATE];
       update gds;
   }
   
   //----------------------------------------------------------------------------------------------------
   public static BatchGateway3.GatewaySoap newGPServiceInstance()
   {
       System.debug('<==Inside newGPServiceInstance==>');
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
        
        //call GP Getway
        BatchGateway3.GatewaySoap gateway = new BatchGateway3.GatewaySoap();
        //gateway.endpoint_x =
        gateway.timeout_x = 120000; 
        gateway.endpoint_x = settings.GatewayUrl__c;
        return gateway;
   } 
   
   //----------------------------------------------------------------------------------------------------
   public static string maskCardNumber(string num)
   {
       System.debug('<==Inside maskCardNumber==>');
      if (IsEmptyOrNull(num))
        return num;
      
      if (num.length()<5)
        return num;  
      
      string last4chars = num.substring(num.length()-4, num.length());
      integer maskLen = num.length()-4;
      string result = '';
      for(integer i=0;i<maskLen;i++)
        result += '*';
      
      return result + last4chars; 
   } 
   
   //----------------------------------------------------------------------------------------------------
   public static Recurring_Payment_Batch__c CreateTodayRecurringBatch()
   {
       System.debug('<==Inside CreateTodayRecurringBatch==>');
      //find or add recurring payment batch
        List<Recurring_Payment_Batch__c> batches = [SELECT Id, Name FROM Recurring_Payment_Batch__c WHERE Process_Date__c = Today AND Payment_Type__c = 'Credit Card'];
        
        Recurring_Payment_Batch__c TodayBatch = null;
        if (batches==null || batches.size()<=0)
        {
            //create a new batch
            TodayBatch = new Recurring_Payment_Batch__c();
            TodayBatch.Process_Date__c = Date.today();
            TodayBatch.Payment_Type__c = 'Credit Card';
            TodayBatch.Comments__c = 'Payments processed by X-Charge on :' + Date.today().format();
            insert TodayBatch;
        }
        else
         TodayBatch = batches[0];
         
     return TodayBatch;
   }
   
  //----------------------------------------------------------------------------------------------------
  @future
  public static void createGiftDetails(Set<Id> paymentIds) {
  try{
   System.debug('<==Inside createGiftDetails==>');
      Set<String> inputs = new Set<String>();
      List<Payment__c> toUpdatePayment = new List<Payment__c>();
      
      Map<String,String> paymentMap = new Map<String, String>();
        List<string> RD_Ids = new List<String>();
        Receipt__c theReceipt = null;
        List<Receipt__c> toInsertReceipt = new List<Receipt__c>();
      Set<String> recurringPIds = new Set<String>();
   
        List<Payment__c> ps1 = [Select p.Id, p.Donation__r.Gift_Type__c, p.Donation__r.RecordTypeId, p.Donation__c, cv_pkg_dev_I__Credit_Card_Number__c, cv_pkg_dev_I__Credit_Card_Type__c, cv_pkg_dev_I__Account_Number__c, cv_pkg_dev_I__Routing_Branch_Number__c, cv_pkg_dev_I__Transit_Number__c, cv_pkg_dev_I__Bank_Name__c, 
            p.Donation__r.Recurring_Donation__c, p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Credit_Card__c, p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Credit_Card_Type__c,
            p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Account__c, p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Branch_Num__c, p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Institution_Num__c,  p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Bank_Name__c
            From Payment__c p WHERE id IN :paymentIds AND Amount__c!=0 FOR UPDATE];
            system.debug('ps==>'+ps1);
        for(Payment__c p : ps1){
        system.debug('Nitin Recurring Donation==='+p.Donation__r.Recurring_Donation__c);
         if (p.Donation__r.Gift_Type__c=='Recurring' || p.Donation__r.Gift_Type__c=='Sponsorship'){ /*|| p.Donation__r.Gift_Type__c == 'Pledge'*/
               p.cv_pkg_dev_I__Credit_Card_Number__c = p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Credit_Card__c;
               p.cv_pkg_dev_I__Credit_Card_Type__c = p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Credit_Card_Type__c;
               p.cv_pkg_dev_I__Account_Number__c = p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Account__c;
               p.cv_pkg_dev_I__Routing_Branch_Number__c = p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Branch_Num__c;
               p.cv_pkg_dev_I__Transit_Number__c = p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Institution_Num__c;
               p.cv_pkg_dev_I__Bank_Name__c = p.Donation__r.Recurring_Donation__r.cv_pkg_dev_I__Bank_Name__c;
               toUpdatePayment.add(p);
              // UpdatesPaymentIds.add(p.id);
               Validator_cls.paymentidsset.add(p.id);
               inputs.add(p.Id+':'+p.Donation__r.Recurring_Donation__c);
           }
        }
        
       
        system.debug('**********'+ Validator_cls.paymentidsset);
        
        if(toUpdatePayment.size() > 0){
        
         update toUpdatePayment;
         toUpdatePayment.clear(); 
        Validator_cls.paymentidsset.clear(); }
         
    for(string input : inputs)
    {
        if (isEmptyOrNull(input) || input == ':')
         continue;
        
        System.debug('---------------------------- item combination:' + input);
        
        string[] parts = input.split(':');
        if (parts.size()>1 && !isEmptyOrNull(parts[0]))
        {
            paymentMap.put(parts[0],parts[1]);
            if (!isEmptyOrNull(parts[1]))
                RD_Ids.add(parts[1]);
        }
    }//for
    
    List<Recurring_Donation__c> RDs = [Select Id, (Select Id, Name, Recurring_Gift__c, Active__c, Appeal__c, 
         Campaign__c, Fund__c, Amount__c, New_Campaign__c, Custom_Allocation_Text__c, Package__c 
         From Recurring_Gift_Allocations__r WHERE Active__c=true) From Recurring_Donation__c r 
         WHERE r.Id IN :RD_Ids];
    
        
    //if (RDs==null || RDs.size()<=0) return;
    
    List<Payment__c> Ps = [SELECT Id, Amount__c, Receipt__c, Donation__c, Date__c, (Select Id From Allocations__r), Donation__R.Gift_Type__c, Donation__R.Organization__c, Donation__R.Constituent__c, Donation__r.Recurring_Donation__c FROM Payment__c WHERE Id IN :paymentMap.keySet()];
    //if (Ps==null || Ps.size()<=0) return;
    
    System.debug('---------------------------- Total payments:'+ Ps.size());
    
    //target list
    List<Gift_Detail__c> itemsToBeInserted = new List<Gift_Detail__c>();
    Map<Id, Receipt__c> giftDetailMap = new Map<Id, Receipt__c>();
    decimal rdAmount = 0;
    integer cnt = 0;
    App_Settings__c appSetting = App_Settings__c.getInstance(UserInfo.getOrganizationId());
      //system.debug('custom app setting==>'+appSetting.Enable_Recurring_Receipts__c);
    for(Payment__c p : Ps)
    {
        system.debug('Donation==>'+p.Donation__r.Recurring_Donation__c);
        system.debug('Recipt==>'+p.Receipt__c);
        //system.debug('Recipt==>'+appSetting.Enable_Recurring_Receipts__c);
        if(appSetting.Enable_Recurring_Receipts__c &&  p.Donation__r.Recurring_Donation__c != NULL && p.Receipt__c == null)
        {
            system.debug('<==Inside==>');
          if (p.Donation__R.Constituent__c != null) {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Constituent__c = p.Donation__R.Constituent__c);
          }
            else {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Organization__c  = p.Donation__R.Organization__c);
            } 
            
            theReceipt.Gift__c =  p.Donation__c;
            theReceipt.Receipt_Type__c = 'Single';
            theReceipt.cv_pkg_dev_I__Amount_Receipted__c = p.cv_pkg_dev_I__Amount__c;
            system.debug('theReceipt==>'+theReceipt);
            //insertion of receipt record was in for loop
            //insert theReceipt;
            giftDetailMap.put(p.id, theReceipt);
            //p.receipt__c = theReceipt.Id;
            //toUpdatePayment.add(p);
        }

    }
    if(giftDetailMap.values().size() > 0){
        insert giftDetailMap.values();
    }
    for(Payment__c p : Ps)
    {
        if(giftDetailMap.get(p.id) != null){
            p.receipt__c = giftDetailMap.get(p.id).id;
            toUpdatePayment.add(p);
           // UpdatesPaymentIds.add(p.id);
          Validator_cls.paymentidsset.add(p.id);
        }    //till here
        //If the Payment record already contains allocation, do not create allocations.
        //Bug Fix : Process Payment - recurring gifts creates 2 allocations.
        if(p.Donation__R.Gift_Type__c == 'Recurring' && p.Allocations__r != null && p.Allocations__r.size() > 0) {
            continue;
        }

        cnt++;
        string RD_Id = paymentMap.get(p.Id);
        
        System.debug('--------------------------- item no: ' + cnt.format());
        System.debug('--------------------------- processing payment: ' + p.Id + ' with RD: ' + RD_ID);
        
        Recurring_Donation__c RD = (Recurring_Donation__c)findItem('Id',RD_Id, RDs);
        if (RD==null || RD.Recurring_Gift_Allocations__r==null || RD.Recurring_Gift_Allocations__r.size()<=0)
            continue;
        for(RD_Allocation__c allocation : RD.Recurring_Gift_Allocations__r)
        {
            Gift_Detail__c gd = new Gift_Detail__c();
            gd.Allocation_Date__c = p.Date__c;            
            if (p.Amount__c < 0)
            { gd.Amount__c = (0 - allocation.Amount__c); }
            else 
            { gd.Amount__c = allocation.Amount__c; }
            rdAmount = allocation.Amount__c;
            gd.New_Campaign__c = allocation.New_Campaign__c;
            gd.Appeal__c = allocation.Appeal__c;
            gd.Campaign__c = allocation.Campaign__c;
            gd.Fund__c = allocation.Fund__c;
            gd.Custom_Allocation_Text__c = allocation.Custom_Allocation_Text__c;            
            gd.Gift__c = p.Donation__c;
            gd.Payment__c = p.Id; 
            gd.Package__c = allocation.Package__c;

            itemsToBeInserted.add(gd);  
        }
        
    }//for
    system.debug('itemsToBeInserted==>'+itemsToBeInserted);
    if (itemsToBeInserted!=null && itemsToBeInserted.size()>0 && rdAmount!=-8967)
      insert itemsToBeInserted;
 
    if (toUpdatePayment!=null && toUpdatePayment.size()>0)     
        update toUpdatePayment;
        
    }catch(Exception e){
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        string emailAddress = userInfo.getUserEmail();
         String[] toAddresses = new String[]{emailAddress};
         mail.setToAddresses(toAddresses);
         mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
         mail.setPlainTextBody(e.getMessage());
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  }
  
  //----------------------------------------------------------------------------------------------------
  public static void executeNewYearTransactionsBatch(List<sObject> scope) {
        System.debug('<==Inside executeNewYearTransactionsBatch==>');
        List<Gift__c> thisYearGifts = new List<Gift__c>();
        
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        Contact c = new contact(LastName = 'ssss');
        insert c;
        
        for(sObject o : scope)
        {
              Gift__c ng = (Gift__c)o;
              Gift__c g = new Gift__c();
              //g.RecordTypeId = settings.RecurringDonationGiftRecordTypeId__c;
              g.Channel__c = ng.Channel__c;
              g.Constituent__c = ng.Recurring_Donation__r.Constituent__c;
              g.Gift_Date__c = Date.Today();
              g.Gift_Type__c = ng.Gift_Type__c;
              g.Last_Payment_Date__c = ng.Last_Payment_Date__c;
              g.Next_Payment_Date__c = ng.Next_Payment_Date__c;
              g.Receipt_Type__c = 'Consolidated';
              g.Recurring_Donation__c = ng.Recurring_Donation__c;
              g.Status__c = 'Active';
              g.Reference__c = ng.Recurring_Donation__r.Reference__c;
              if (g.Constituent__c == null) { g.Constituent__c = c.Id; }
              thisYearGifts.add(g);
        }         
          
        insert thisYearGifts;
  }
  
  //----------------------------------------------------------------------------------------------------
  public static void executeConsolidatedReceiptBatch(List<sObject> scope) {
  System.debug('<==Inside executeConsolidatedReceiptBatch==>');
    List<Gift__c> giftsToUpdate = new List<Gift__c>();
        List<Receipt__c> receiptsToInsert = new List<Receipt__c>();
      
       if (scope== null || scope.size()<=0)
         return;
        
      
      for(sObject o : scope) {
        
        Contact c = (Contact)o;
        if (c.Gifts__r!=null && c.Gifts__r.size()>0)
        {
            //the contact has consolidated gifts
            Decimal total = 0;
            for(Gift__c g : c.Gifts__r)
            {
                g.Status__c = 'Acknowledged'; 
                total += g.Amount__c;
            }
            
            Receipt__c r = new Receipt__c();
            //r.Receipt_Amount__c = total;
            r.Gift__c = c.Gifts__r[0].Id;   
            r.Receipt_Date__c = Date.today();
            r.Status__c = 'To be Printed';
            r.sysConsolidatedJob__c = true;
            receiptsToInsert.add(r);
                
        }
      }//for
        
      if (receiptsToInsert.size()>0)
         insert receiptsToInsert;   
            
      for(sObject o : scope) {
        
          Contact c = (Contact)o;  
          if (c.Gifts__r!=null && c.Gifts__r.size()>0)
          {
            
                Gift__c masterGift = c.Gifts__r[0];
                Receipt__c r = (Receipt__c)RollupHelper.findItem('Gift__c', masterGift.Id, receiptsToInsert);
                if (r != null)
                    for(Gift__c g : c.Gifts__r) 
                    {   
                        g.Consolidated_Rcpt__c = r.Id;
                        giftsToUpdate.add(g);
                    }
          }//end if
      }   
        
     if (giftsToUpdate.size()>0) {
       List<Id> giftIds = new List<Id>();
       for(Gift__c gift : giftsToUpdate) {
           giftIds.add(gift.Id);
       }

       update giftsToUpdate;      

       //Update all the Payment records belonging to the Transcation with the receipt Id of the Transaction record.
       List<Payment__c> payments = [Select Id, Receipt__c, Donation__r.Consolidated_Rcpt__c From Payment__c Where
                                   Status__c = 'Approved' AND Donation__c In :giftIds FOR UPDATE];
       if(payments != null && payments.size() > 0) {
           for(Integer i = 0; i < payments.size(); i++) {
               payments[i].Receipt__c = payments[i].Donation__r.Consolidated_Rcpt__c;
           }

           Update payments;
       }

     }  
  }
    
    @future
    public static void creditDetailUpdationOnGiftMethod(set<Id> giftIds){
        List<Gift__c> giftRecordsToUpdate = new List<Gift__c>();
        List<Gift__c> giftRecords = new List<Gift__c>();
        if(giftIds.size() > 0){
            giftRecords = new List<Gift__c>([SELECT  Id, cv_pkg_dev_I__Credit_Card_Number__c, cv_pkg_dev_I__Credit_Card_Type__c, (SELECT Credit_Card_Number__c, Credit_Card_Type__c, cv_pkg_dev_I__Donation__c  FROM Recurring_Payments__r  WHERE Payment_Type__c = :'Credit Card' ORDER BY CreatedDate DESC NULLS Last Limit 1) FROM Gift__c WHERE ID IN :giftIds FOR UPDATE]);
        }
        //Assigning credit card number and credit card type to gift
        if(giftRecords.size() >0)
        {   
            for(Gift__c gift : giftRecords)
            { 
                Payment__c paymentRecord = gift.Recurring_Payments__r;
                gift.cv_pkg_dev_I__Credit_Card_Number__c = paymentRecord.Credit_Card_Number__c;
                gift.cv_pkg_dev_I__Credit_Card_Type__c = paymentRecord.Credit_Card_Type__c;
                giftRecordsToUpdate.add(gift);
            }
        } 
        if(giftRecordsToUpdate.size() > 0){
            update giftRecordsToUpdate; 
        }
    }
    
    @future
    public static void RefundAllocationsMethod(Set<String> refundedPaymentIds, Set<String> refundPaymentIds){
        Map<String, List<Gift_Detail__c>> payment_to_allocations = new Map<String, List<Gift_Detail__c>>();
        Map<String, Decimal> payment_to_amount = new Map<String, Decimal>();  
        List<Gift_Detail__c> allocationsToInsert = new List<Gift_Detail__c>();
        List<Gift_Detail__c> allocations = [SELECT Allocation_Date__c, Gift__c, Tribute__c, Product__c, New_Campaign__c, Fund__c, Payment__c, Amount__c,Quantity__c,Event_Level__c FROM Gift_Detail__c WHERE Payment__c IN :refundedPaymentIds];
        List<Payment__c> refundedPayments = [SELECT Amount__c, Id, Payment_Refunded__c FROM Payment__c WHERE Id IN :refundedPaymentIds];    
        List<Payment__c> refundPayments = [SELECT Amount__c, Id, Payment_Refunded__c FROM Payment__c WHERE Id IN :refundPaymentIds];       
        List<Gift_Detail__c> bufferAllocations = new List<Gift_Detail__c>();   
        system.debug('Nitin++'+refundedPayments);
        for (Payment__c p : refundedPayments)
        {
            bufferAllocations = new List<Gift_Detail__c>();
            for (Gift_Detail__c gd : allocations)
            {
                if (p.Id == gd.Payment__c)
                bufferAllocations.add(gd);
            }
            payment_to_allocations.put(p.Id, bufferAllocations);
            payment_to_amount.put(p.Id, p.Amount__c);
        }   
        system.debug('Nitin++'+payment_to_amount);
        Gift_Detail__c bufferGiftDetail = new Gift_Detail__c();
        
        for (Payment__c p : refundPayments)
        {        
            for (Gift_Detail__c gd : payment_to_allocations.get(p.Payment_Refunded__c))
            {
                bufferGiftDetail = new Gift_Detail__c();
                bufferGiftDetail.Payment__c = p.Id;
                bufferGiftDetail.Allocation_Date__c = Date.Today();
                bufferGiftDetail.New_Campaign__c = gd.New_Campaign__c;
                bufferGiftDetail.Gift__c = gd.Gift__c;
                bufferGiftDetail.Tribute__c = gd.Tribute__c;
                bufferGiftDetail.Product__c = gd.Product__c;
                bufferGiftDetail.Fund__c = gd.Fund__c;
                bufferGiftDetail.Amount__c = (p.Amount__c * (gd.Amount__c/payment_to_amount.get(p.Payment_Refunded__c)));
                
                if(gd.Quantity__c != null && gd.Event_Level__c != null)
                {
                bufferGiftDetail.Quantity__c = 0 - gd.Quantity__c;
                bufferGiftDetail.Event_Level__c = gd.Event_Level__c;
                }
                
                allocationsToInsert.add(bufferGiftDetail);
            }
        }
        system.debug('allocationsToInsert:=>'+allocationsToInsert);
        if(allocationsToInsert.size() > 0)
        insert allocationsToInsert;
    }
    
    public static void updateCurrency(List<Receipt__c> receiptList){
        Boolean multiCurrenyEnable = checkMCEnabled();
        if(multiCurrenyEnable){
            set<Id> giftIds = new set<Id>();
            for(Receipt__c receipt : receiptList){
                giftIds.add(receipt.cv_pkg_dev_I__Gift__c);
            }
            String query = 'select CurrencyIsoCode from cv_pkg_dev_I__Gift__c where Id IN : giftIds';
            List<cv_pkg_dev_I__Gift__c> giftRecord_List = Database.query(query);
            Map<Id, String> giftRecord_Map = new Map<Id, String>();
            for(cv_pkg_dev_I__Gift__c gift : giftRecord_List){
                giftRecord_Map.put(gift.id, (String)gift.get('CurrencyIsoCode'));
            }
            for(Receipt__c receipt : receiptList){
                receipt.put('CurrencyIsoCode', giftRecord_Map.get(receipt.cv_pkg_dev_I__Gift__c));
            }
        }
    }
    
    public static Boolean checkMCEnabled(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType mcEnabled = gd.get('CurrencyType');
        system.debug('Nitin mcEnabled=='+mcEnabled);
        return (mcEnabled != null) ? true : false;
    }
    
  static testMethod void testMe()
  {
      boolean value = isEmptyOrNull('');
     List<Account> accs = [SELECT Id, Name FROM Account limit 10];
     if (accs!=null && accs.size()>0) {
        Account acc = (Account)findItem('Id', accs[0].Id, accs);
     }
     
     string result = maskCardNumber('2632784632874');
  }
}
