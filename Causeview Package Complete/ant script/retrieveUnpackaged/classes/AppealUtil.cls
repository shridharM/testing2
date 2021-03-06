public without sharing class AppealUtil {
     
      public static void RollupCampaigns(Set<Id> AppealIDs)
    {
        Set<String> AppealIDsH = new Set<String>();
        Map<String, List<Campaign>> Appeals_to_Children = new Map<String, List<Campaign>>();        
        Integer fysm = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
        List<Date> FiscalQuarterArray = getFQArray(fysm);
        Date FiscalYearStartDate = Date.Today();
       
         //Set<Id> parentappeal=new Set<Id>();

        if (Date.Today().Month() >= fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year(), fysm, 1); }
        if (Date.Today().Month() < fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year() - 1, fysm, 1); }

        if (AppealIDs == null || AppealIDs.size()<=0)
        return;

        List<Campaign> Appeals = [SELECT c.Name, c.ParentId, c.ActualCost, c.Gift_Amount__c, c.Gift_Count__c, c.Gifts_for_Current_Fiscal__c, c.Gifts_for_Current_Quarter__c, 
                                  c.One_Time_Gift_Count__c, c.Overall_Gift_Amount__c, c.Overall_Gift_Count__c, c.Overall_Gifts_for_Current_Fiscal__c, 
                                  c.Overall_Gifts_for_Current_Quarter__c, c.Overall_One_Time_Gift_Count__c, c.Overall_Recurring_Gift_Count__c, c.Recurring_Gift_Count__c , 
                                  (SELECT Gift__r.Recurring_Donation__c, Gift__r.Gift_Type__c, Gift__c, Allocation_Date__c, Approved_Amount__c FROM Allocations__r 
                                  WHERE Approved_Amount__c > 0) FROM Campaign c WHERE  Id IN :AppealIDs  FOR UPDATE ];
        system.debug('am here ' + Appeals);
        for(Campaign c : Appeals)
        {
            AppealIDsH.add(c.Id);
        }
        
        List<Campaign> AppealsH = [SELECT  c.Parent.ParentId,c.ParentId, c.ActualCost, c.Gift_Amount__c, c.Gift_Count__c, c.Gifts_for_Current_Fiscal__c, c.Gifts_for_Current_Quarter__c, c.One_Time_Gift_Count__c, c.Overall_Gift_Amount__c, c.Overall_Gift_Count__c, c.Overall_Gifts_for_Current_Fiscal__c, c.Overall_Gifts_for_Current_Quarter__c, c.Overall_One_Time_Gift_Count__c, c.Overall_Recurring_Gift_Count__c, c.Recurring_Gift_Count__c FROM Campaign c WHERE c.ParentId IN :AppealIDsH OR c.Parent.ParentId IN :AppealIDsH ]; 
        system.debug('am here ' + AppealsH);
        for(Campaign c : Appeals)
        {
            List<Campaign> cs = new List<Campaign>();
            for(Campaign cH : AppealsH)
            {
                if(c.Id == cH.ParentId )// || c.Id == cH.Parent.ParentId)
                { cs.add(cH); }
            }
            Appeals_to_Children.put(c.Id, cs);
        }       
        
  
        
        for(Campaign c : Appeals)
        {
            Integer countGiftsFY = 0;
            Integer countGiftsFQ = 0;            
            Decimal Amount = 0;
            Decimal AmountRD = 0;            
            Decimal AmountH = 0;
            Decimal AmountRDH = 0;            
            Decimal AmountFY = 0;
            Decimal AmountFQ = 0;
            Decimal AmountFYH = 0;
            Decimal AmountFQH = 0;    
            Decimal AmountRDFY = 0;
            Decimal AmountRDFQ = 0;
            Decimal AmountRDFYH = 0;
            Decimal AmountRDFQH = 0;   
            c.Gift_Amount__c = 0; 
            c.Overall_Gift_Amount__c = 0;
            c.One_Time_Gift_Count__c = 0;           
            c.Overall_One_Time_Gift_Count__c = 0;
            c.Overall_Recurring_Gift_Count__c = 0;
            c.Recurring_Gift_Count__c = 0;
            c.Gifts_for_Current_Fiscal__c = 0;
            c.Overall_Gifts_for_Current_Fiscal__c = 0;
            c.Overall_Gifts_for_Current_Quarter__c = 0; 
            c.Gifts_for_Current_Quarter__c = 0;                              
            Set<String> Count = new Set<String>();
            Set<String> CountRD = new Set<String>();            
            Set<String> CountH = new Set<String>();
            Set<String> CountRDH = new Set<String>();            
            Campaign ParentRec =new Campaign();
            //system.debug('DETAILSARE' + c.Name + c.Gift_Details__r.size());
            
            if (c.Allocations__r != null)           
            {
                for(Gift_Detail__c gd : c.Allocations__r)
                {                   
                    if (gd.Gift__r.Gift_Type__c == 'Recurring')
                    { 
                        AmountRD += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
                        { AmountRDFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
                        { AmountRDFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        CountRD.add(gd.Gift__r.Recurring_Donation__c);
                    }
                    else
                    {
                        Amount += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
                        { AmountFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
                        { AmountFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        Count.add(gd.Gift__c);                    
                    }
                }
            }                                          
            
            if (Appeals_to_Children.containsKey(c.Id))
            {
                for (Campaign cH : Appeals_to_Children.get(c.Id))
                {  
                    if (cH!=null){   
                    //system.debug('am inside null');
                    
                    cH.Overall_Gift_Amount__c = cH.Overall_Gift_Amount__c == null? 0.00 : cH.Overall_Gift_Amount__c;           
                    c.Overall_Gift_Amount__c += cH.Overall_Gift_Amount__c;                   
                                 
                    cH.Overall_One_Time_Gift_Count__c = cH.Overall_One_Time_Gift_Count__c == null? 0 : cH.Overall_One_Time_Gift_Count__c;
                    c.Overall_One_Time_Gift_Count__c += cH.Overall_One_Time_Gift_Count__c;
                    
                     
                    cH.Overall_Recurring_Gift_Count__c = cH.Overall_Recurring_Gift_Count__c == null? 0 : cH.Overall_Recurring_Gift_Count__c;                                     
                    c.Overall_Recurring_Gift_Count__c += cH.Overall_Recurring_Gift_Count__c; 
                    
                    cH.Overall_Gifts_for_Current_Fiscal__c = cH.Overall_Gifts_for_Current_Fiscal__c == null? 0.00 : cH.Overall_Gifts_for_Current_Fiscal__c;
                    c.Overall_Gifts_for_Current_Fiscal__c += cH.Overall_Gifts_for_Current_Fiscal__c;
                     
                    cH.Overall_Gifts_for_Current_Quarter__c = cH.Overall_Gifts_for_Current_Quarter__c == null? 0.00 : cH.Overall_Gifts_for_Current_Quarter__c;
                    c.Overall_Gifts_for_Current_Quarter__c += cH.Overall_Gifts_for_Current_Quarter__c; 
                    
                    cH.Gifts_for_Current_Quarter__c = cH.Gifts_for_Current_Quarter__c == null? 0.00 : cH.Gifts_for_Current_Quarter__c; 
                    c.Gifts_for_Current_Quarter__c += cH.Gifts_for_Current_Quarter__c;
                    }
                    
                   }
 
                
            }            
                
            c.Overall_Gift_Amount__c += Amount + AmountH + AmountRD + AmountRDH;
            c.Gifts_for_Current_Quarter__c += AmountFQ + AmountRDFQ;
            c.Overall_Gifts_for_Current_Quarter__c += AmountFQ + AmountFQH + AmountRDFQ + AmountRDFQH;
            c.Overall_Gifts_for_Current_Fiscal__c += AmountFY + AmountFYH + AmountRDFY + AmountRDFYH;
            c.Gifts_for_Current_Fiscal__c += AmountFY + AmountRDFY;
            c.Recurring_Gift_Count__c += CountRD.size();
            c.Overall_One_Time_Gift_Count__c += (Count.size() + CountH.size());
            c.Overall_Recurring_Gift_Count__c += (CountRD.size() + CountRDH.size());
            c.Gift_Amount__c += Amount + AmountRD;
            c.One_Time_Gift_Count__c += Count.size();   
                        
            }
            
            update Appeals;

        }
    
    
    public static void RollupPackages(Set<Id> AppealIDs)
    {     
        Integer fysm = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
        List<Date> FiscalQuarterArray = getFQArray(fysm);
        Date FiscalYearStartDate = Date.Today();

        if (Date.Today().Month() >= fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year(), fysm, 1); }
        if (Date.Today().Month() < fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year() - 1, fysm, 1); }

        if (AppealIDs == null || AppealIDs.size()<=0)
        return;

        List<Campaign> Appeals = [SELECT c.ParentId, c.Gift_Amount__c, c.Gift_Count__c, c.Gifts_for_Current_Fiscal__c, c.Gifts_for_Current_Quarter__c, 
                                  c.One_Time_Gift_Count__c, c.Overall_Gift_Amount__c, c.Overall_Gift_Count__c, c.Overall_Gifts_for_Current_Fiscal__c, 
                                  c.Overall_Gifts_for_Current_Quarter__c, c.Overall_One_Time_Gift_Count__c, c.Overall_Recurring_Gift_Count__c, c.Recurring_Gift_Count__c , 
                                  (SELECT Gift__r.Recurring_Donation__c, Gift__c, Allocation_Date__c, Approved_Amount__c FROM Allocations__r) FROM Campaign c WHERE Id IN :AppealIDs  FOR UPDATE];
                                          
        for(Campaign c : Appeals)
        {
            Integer countGiftsFY = 0;
            Integer countGiftsFQ = 0;            
            Decimal Amount = 0;
            Decimal AmountRD = 0;            
            Decimal AmountH = 0;
            Decimal AmountRDH = 0;            
            Decimal AmountFY = 0;
            Decimal AmountFQ = 0;
            Decimal AmountFYH = 0;
            Decimal AmountFQH = 0;    
            Decimal AmountRDFY = 0;
            Decimal AmountRDFQ = 0;
            Decimal AmountRDFYH = 0;
            Decimal AmountRDFQH = 0;                     
            Set<String> Count = new Set<String>();
            Set<String> CountRD = new Set<String>();            
            Set<String> CountH = new Set<String>();
            Set<String> CountRDH = new Set<String>();            
            
            //system.debug(c.Gift_Details__r.size());
            
            if (c.Allocations__r != null)           
            {
                for(Gift_Detail__c gd : c.Allocations__r)
                {                   
                    if (gd.Gift__r.Recurring_Donation__c != null)
                    { 
                        AmountRD += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
                        { AmountRDFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
                        { AmountRDFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        CountRD.add(gd.Gift__r.Recurring_Donation__c);
                    }
                    else
                    {
                        Amount += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
                        { AmountFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
                        { AmountFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        Count.add(gd.Gift__c);                    
                    }
                }
            }                                          
                      
            c.Gift_Amount__c = Amount + AmountRD; 
            c.Overall_Gift_Amount__c = Amount + AmountH + AmountRD + AmountRDH;
            c.One_Time_Gift_Count__c = Count.size();           
            c.Overall_One_Time_Gift_Count__c = (Count.size() + CountH.size());
            c.Overall_Recurring_Gift_Count__c = (CountRD.size() + CountRDH.size());
            c.Recurring_Gift_Count__c = CountRD.size();
            c.Gifts_for_Current_Fiscal__c = AmountFY + AmountRDFY;
            c.Overall_Gifts_for_Current_Fiscal__c = AmountFY + AmountFYH + AmountRDFY + AmountRDFYH;
            c.Overall_Gifts_for_Current_Quarter__c = AmountFQ + AmountFQH + AmountRDFQ + AmountRDFQH; 
            c.Gifts_for_Current_Quarter__c = AmountFQ + AmountRDFQ;
        }         
        update Appeals;
    }
    
    public static void RollupAppeals(Set<Id> AppealIDs)
    {
        Set<String> AppealIDsH = new Set<String>();
        Map<String, List<Campaign>> Appeals_to_Children = new Map<String, List<Campaign>>();        
        Integer fysm = [Select o.FiscalYearStartMonth from Organization o where o.id=:Userinfo.getOrganizationId() LIMIT 1].FiscalYearStartMonth;
        List<Date> FiscalQuarterArray = getFQArray(fysm);
        Date FiscalYearStartDate = Date.Today();

        if (Date.Today().Month() >= fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year(), fysm, 1); }
        if (Date.Today().Month() < fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year() - 1, fysm, 1); }

        if (AppealIDs == null || AppealIDs.size()<=0)
        return;

        List<Campaign> Appeals = [SELECT c.ParentId, c.ActualCost, c.Gift_Amount__c, c.Gift_Count__c, c.Gifts_for_Current_Fiscal__c, c.Gifts_for_Current_Quarter__c, 
                                  c.One_Time_Gift_Count__c, c.Overall_Gift_Amount__c, c.Overall_Gift_Count__c, c.Overall_Gifts_for_Current_Fiscal__c, 
                                  c.Overall_Gifts_for_Current_Quarter__c, c.Overall_One_Time_Gift_Count__c, c.Overall_Recurring_Gift_Count__c, c.Recurring_Gift_Count__c , 
                                  (SELECT Gift__r.Recurring_Donation__c, Gift__r.Gift_Type__c, Gift__c, Allocation_Date__c, Approved_Amount__c FROM Allocations__r 
                                  WHERE Approved_Amount__c > 0) FROM Campaign c WHERE Id IN :AppealIDs   FOR UPDATE ];
        
        
        for(Campaign c : Appeals)
        {
            AppealIDsH.add(c.Id);
        }
        system.debug('Appeals==>'+Appeals.size());
        List<Campaign> AppealsH = [SELECT c.Parent.ParentId, c.ParentId, c.ActualCost, c.Gift_Amount__c, c.Gift_Count__c, c.Gifts_for_Current_Fiscal__c, c.Gifts_for_Current_Quarter__c, c.One_Time_Gift_Count__c, c.Overall_Gift_Amount__c, c.Overall_Gift_Count__c, c.Overall_Gifts_for_Current_Fiscal__c, c.Overall_Gifts_for_Current_Quarter__c, c.Overall_One_Time_Gift_Count__c, c.Overall_Recurring_Gift_Count__c, c.Recurring_Gift_Count__c FROM Campaign c WHERE c.ParentId IN :AppealIDsH];
        for(Campaign c : Appeals)
        {
            List<Campaign> cs = new List<Campaign>();
            for(Campaign cH : AppealsH)
            {
                if(c.Id == cH.ParentId)
                { cs.add(cH); }
            }
            Appeals_to_Children.put(c.Id, cs);
        }       
        
        for(Campaign c : Appeals)
        {
            Integer countGiftsFY = 0;
            Integer countGiftsFQ = 0;            
            Decimal Amount = 0;
            Decimal AmountRD = 0;            
            Decimal AmountH = 0;
            Decimal AmountRDH = 0;            
            Decimal AmountFY = 0;
            Decimal AmountFQ = 0;
            Decimal AmountFYH = 0;
            Decimal AmountFQH = 0;    
            Decimal AmountRDFY = 0;
            Decimal AmountRDFQ = 0;
            Decimal AmountRDFYH = 0;
            Decimal AmountRDFQH = 0;                     
            c.Gift_Amount__c = 0; 
            c.Overall_Gift_Amount__c = 0;
            c.One_Time_Gift_Count__c = 0;           
            c.Overall_One_Time_Gift_Count__c = 0;
            c.Overall_Recurring_Gift_Count__c = 0;
            c.Recurring_Gift_Count__c = 0;
            c.Gifts_for_Current_Fiscal__c = 0;
            c.Overall_Gifts_for_Current_Fiscal__c = 0;
            c.Overall_Gifts_for_Current_Quarter__c = 0; 
            c.Gifts_for_Current_Quarter__c = 0;
            Set<String> Count = new Set<String>();
            Set<String> CountRD = new Set<String>();            
            Set<String> CountH = new Set<String>();
            Set<String> CountRDH = new Set<String>();            
            
            //system.debug(c.Gift_Details__r.size());
            
            if (c.Allocations__r != null)           
            {
                for(Gift_Detail__c gd : c.Allocations__r)
                {                   
                    if (gd.Gift__r.Gift_Type__c == 'Recurring')
                    { 
                        AmountRD += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
                        { AmountRDFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
                        { AmountRDFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        CountRD.add(gd.Gift__r.Recurring_Donation__c);
                    }
                    else
                    {
                        Amount += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
                        { AmountFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
                        { AmountFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
                        Count.add(gd.Gift__c);                    
                    }
                }
            }                                          
            
            if (Appeals_to_Children.containsKey(c.Id))
            {
                for (Campaign cH : Appeals_to_Children.get(c.Id))
                {  
                  if (cH!=null){ //added by Sam  
                    cH.Overall_Gift_Amount__c = cH.Overall_Gift_Amount__c == null? 0.00 : cH.Overall_Gift_Amount__c;    
                    c.Overall_Gift_Amount__c += cH.Overall_Gift_Amount__c;  
                       
                    cH.Overall_One_Time_Gift_Count__c = cH.Overall_One_Time_Gift_Count__c == null? 0 : cH.Overall_One_Time_Gift_Count__c;                  
                    c.Overall_One_Time_Gift_Count__c += cH.Overall_One_Time_Gift_Count__c;
                    
                    cH.Overall_Recurring_Gift_Count__c = cH.Overall_Recurring_Gift_Count__c == null? 0 : cH.Overall_Recurring_Gift_Count__c;
                    c.Overall_Recurring_Gift_Count__c += cH.Overall_Recurring_Gift_Count__c;
                    
                    cH.Overall_Gifts_for_Current_Fiscal__c= cH.Overall_Gifts_for_Current_Fiscal__c == null? 0.00 :cH.Overall_Gifts_for_Current_Fiscal__c;                                        
                    c.Overall_Gifts_for_Current_Fiscal__c += cH.Overall_Gifts_for_Current_Fiscal__c;
                    
                    cH.Overall_Gifts_for_Current_Quarter__c = cH.Overall_Gifts_for_Current_Quarter__c == null? 0.00 : cH.Overall_Gifts_for_Current_Quarter__c;
                    c.Overall_Gifts_for_Current_Quarter__c += cH.Overall_Gifts_for_Current_Quarter__c;
                    
                    cH.Gifts_for_Current_Quarter__c = cH.Gifts_for_Current_Quarter__c == null? 0.00 : cH.Gifts_for_Current_Quarter__c;
                    c.Gifts_for_Current_Quarter__c += cH.Gifts_for_Current_Quarter__c;
                   }
                }
            }            
                 
            c.Overall_Gift_Amount__c += Amount + AmountH + AmountRD + AmountRDH;
            c.Gifts_for_Current_Quarter__c += AmountFQ + AmountRDFQ;
            c.Overall_Gifts_for_Current_Quarter__c += AmountFQ + AmountFQH + AmountRDFQ + AmountRDFQH;
            c.Overall_Gifts_for_Current_Fiscal__c += AmountFY + AmountFYH + AmountRDFY + AmountRDFYH;
            c.Gifts_for_Current_Fiscal__c += AmountFY + AmountRDFY;
            c.Recurring_Gift_Count__c += CountRD.size();
            c.Overall_One_Time_Gift_Count__c += (Count.size() + CountH.size());
            c.Overall_Recurring_Gift_Count__c += (CountRD.size() + CountRDH.size());
            c.Gift_Amount__c += Amount + AmountRD;
            c.One_Time_Gift_Count__c += Count.size();           
            
          
        }
          update Appeals;
    }
    
    public static void RollupExpenses(Set<String> AppealIDs)
    {
        if (AppealIDs == null || AppealIDs.size()<=0)
        return;

        List<Campaign> Appeals = [SELECT c.ActualCost , (SELECT Amount__c FROM Expenses__r) FROM Campaign c WHERE Id IN :AppealIDs FOR UPDATE];        
        
        for(Campaign c : Appeals)
        {
            Decimal Amount = 0;

            if (c.Expenses__r != null)           
            {
                for(Expense__c ex : c.Expenses__r)
                { Amount += (ex.Amount__c != null) ? ex.Amount__c : 0; }
            }                               
            
            c.ActualCost = Amount;  
        }         
        update Appeals;
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
       if (Date.Today().Month() >= FYrStrtMonth && aDate >= Date.newInstance(Date.Today().Year(), FYrStrtMonth, 1) && aDate < Date.newInstance(Date.Today().Year() + 1, FYrStrtMonth, 1))
       { return true; }
       //if the current month has not reached the starting fiscal month, the fiscal year began in the previous calendar year       
       else if (Date.Today().Month() < FYrStrtMonth && aDate >= Date.newInstance(Date.Today().Year() - 1, FYrStrtMonth, 1) && aDate < Date.newInstance(Date.Today().Year(), FYrStrtMonth, 1))
       { return true; }
              
       return false;
   }
   
    public static List<Date> getFQArray(Integer fysm)
   {
        //Integer FYrStrtMonth = fysm;      
        Date FiscalYearStartDate;
        Integer currentQuarter = -1;    
        
        if (fysm == 0 || fysm == null)
            return null;
        
        if (Date.Today().Month() >= fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year(), fysm, 1); }
        if (Date.Today().Month() < fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year() - 1, fysm, 1); }

        // Jan/Feb/March, April/May/June, July/Aug/Sept, Oct/Nov/Dec { [Jan 1 2011, March 31 2011], [April 1 2011, June 30 2011], [July 1 2011, Sept 31 2011], [Oct 1 2011, Dec 31 2011] }
        List<List<Date>> FiscalQuarterArray = new List<List<Date>>();      

        Integer fy = FiscalYearStartDate.Year();
        for (Integer i = 0; i < 4; i++)
        {
            List<Date> aQuarter = new List<Date>();
            aQuarter.add(Date.newInstance(fy, fysm, 1));
            fysm += 2;
            if (fysm > 12)
            { fysm = Math.mod(fysm, 12); fy++; }
            
            /*for (Integer c = 0; c < 2; c++)
            {
                fysm++;
                if (fysm > 12)
                { fysm = 1; fy++;}                              
            }*/
            
            aQuarter.add(Date.newInstance(fy, fysm, Date.daysInMonth(fy, fysm)));
            fysm++;
            FiscalQuarterArray.add(aQuarter);
        }       
        
        for (Integer i = 0; i < 4; i++)     
        {           
            Date FQstart = FiscalQuarterArray[i].get(0);
            Date FQend = FiscalQuarterArray[i].get(1);
            
            System.debug('FQStart: ' + FQstart);
            System.debug('FQEnd: ' + FQend);
            
            if (Date.Today() >= FQstart && Date.Today() <= FQend)
            { currentQuarter = i; break; }
        }
        
        return FiscalQuarterArray[currentQuarter];
    }
    
   public static Boolean isCurrentFiscalQuarter(Date aDate, List<Date> FiscalQuarterArray)
   {      
                
        if (aDate >= FiscalQuarterArray.get(0) && aDate <= FiscalQuarterArray.get(1))
        {
            System.debug('aDate: ' + aDate);
            System.debug('0: ' + FiscalQuarterArray[0]);
            System.debug('1: ' + FiscalQuarterArray[1]);

            return true;
        }
        
        return false;
   }
}