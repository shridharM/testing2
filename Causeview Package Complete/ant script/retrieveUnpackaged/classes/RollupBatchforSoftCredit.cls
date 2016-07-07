global class RollupBatchforSoftCredit implements Database.Batchable<sObject>, Database.Stateful {
    
    global string query;
    global DateTime previousRunTime;
    global set<String> cid = new set<String>();
    Map<Id, List<Solicitor__c>> softCreditMap = new Map<Id, List<Solicitor__c>>();
    global List<Contact> contactRec = new List<Contact>();
    Set<Id> conId = new Set<Id>();
    global Map<Id, List<Gift__c>> giftMap = new Map<Id, List<Gift__c>>();
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        
        for(Solicitor__c g : (List<Solicitor__c>)scope){
            if(!softCreditMap.containsKey(g.Solicitor__c)){
                softCreditMap.put(g.Solicitor__c, new List<Solicitor__c>());
            }
            softCreditMap.get(g.Solicitor__c).add(g);
        }
        
    }
    // Reschedule the job for an hour from now
    global void finish(Database.BatchableContext BC)
    {/*
        List<Contact> contacts = new List<Contact>();
        for(Contact c : contactRec){
            contacts.add(c);
            
            system.debug('Primary==>'+c.Gifts1__r.size());
        }
        if (contacts == null || contacts.size() <= 0) return;
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default'); 

        String RecordTypeIdforRollup1;
        List<String> RecordTypeIdsforRollup1;
        Set<String> recordIds = new Set<String>();
        RecordTypeIdforRollup1 = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
        system.debug('dbglg '+RecordTypeIdforRollup1);
        RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');
        if(RecordTypeIdsforRollup1.size()>0)
        {
        for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++)
        {
                    system.debug('dbglog '+RecordTypeIdsforRollup1.size());

            recordIds.add(RecordTypeIdsforRollup1[i]);
        }
        }  
        List<Contact> contactsToUpdate = new List<Contact>();
        
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
            Decimal consecutive_years_of_giving = 0;
            Decimal consecutive_years_of_transactions = 0;
            if(giftMap.get(c.id) != null)
            {
                lastGiftAmount = giftMap.get(c.id)[0].Amount__c;
            }
            if(giftMap.get(c.id) != null)
            {
                for(Gift__c g : giftMap.get(c.id))
                {
                    system.debug('<=Inside Gift=>');
                    if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                    {
                        totalGivingAmount += g.Amount__c; totalAmount += g.Amount__c; gDates.add(g.Gift_Date__c); tDates.add(g.Gift_Date__c);
                        totalGivingCount++; totalCount++;
                    }
                    else
                    {
                        totalAmount += g.Amount__c; tDates.add(g.Gift_Date__c); totalCount++;
                    }        
                    if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
                    {
                        if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                        {
                            totalFiscalGivingAmount += g.Amount__c; totalFiscalAmount += g.Amount__c; totalFiscalGivingCount++; totalFiscalCount++;
                        }
                        else
                        {
                            totalFiscalAmount += g.Amount__c; totalFiscalCount++;
                        }
                    }
                }
            }
            if (softCreditMap.get(c.id) != null)
            {
                for(Solicitor__c s : softCreditMap.get(c.id))
                {
                    system.debug('<=Inside soft Credit=>');
                    //tDates.add(s.Gift_Date__c); 
                    total_additional_solicitations += (s.Amount__c == null) ? 0 : s.Amount__c;
                }
            }
            if(c.Gifts1__r != null){
                for(Gift__c g2 : c.Gifts1__r)
                {
                    system.debug('<=Inside gift 1=>');
                    total_solicitations += g2.Amount__c;
                }
            }
            system.debug('Contact==>'+c.id);
            if (gDates.size() != 0)
            {
                if (org == null)
                {
                     consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, 1);
                }
                else
                {
                    consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, org);                    
                }
            }
            system.debug('consecutive_years_of_giving=='+consecutive_years_of_giving);
            if (tDates.size() != 0)
            {
                if (org == null)
                {
                    consecutive_years_of_transactions = GivingpowerUtility.ConseqFiscalYears(tDates, 1);
                }
                else
                {
                    consecutive_years_of_transactions = GivingpowerUtility.ConseqFiscalYears(tDates, org);
                }
            }
            gDates.clear();
            tDates.clear();
            system.debug('consecutive_years_of_transactions=='+consecutive_years_of_transactions);
            if (c.Total_Lifetime_Gifts__c <> totalGivingCount || c.Total_Lifetime_Giving__c <> totalGivingAmount ||
                c.Total_Fiscal_Gifts__c <> totalFiscalGivingCount || c.Total_Fiscal_Year_Giving__c <> totalFiscalGivingAmount ||
                c.Total_Lifetime_Transactions__c <> totalCount || c.Total_Lifetime_Transaction_Amount__c <> totalAmount ||
                c.Total_Fiscal_Transactions__c <> totalFiscalCount || c.Total_Fiscal_Transaction_Amount__c <> totalFiscalAmount ||
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Total_Lifetime_Fundraising__c <> totalGivingAmount + total_additional_solicitations + total_solicitations ||
                c.Consecutive_Years_of_Giving__c <> consecutive_years_of_giving || c.Consecutive_Years_of_Transactions__c <> consecutive_years_of_transactions)
            {
                c.Total_Lifetime_Gifts__c = totalGivingCount;
                c.Total_Lifetime_Giving__c = totalGivingAmount;
                c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
                c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;
                c.Total_Lifetime_Transactions__c = totalCount;       
                c.Total_Lifetime_Transaction_Amount__c = totalAmount;
                c.Total_Fiscal_Transactions__c = totalFiscalCount;
                c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;
                c.Last_Gift_Amount__c = lastGiftAmount;
                //c.Total_Lifetime_Fundraising__c = totalAmount + total_additional_solicitations + total_solicitations;
                c.Total_Lifetime_Fundraising__c = totalGivingAmount + total_additional_solicitations + total_solicitations;
                c.Consecutive_Years_of_Giving__c = consecutive_years_of_giving;
                c.Consecutive_Years_of_Transactions__c = consecutive_years_of_transactions;
                system.debug('---Inside RecalculateTotalGiving---');
                system.debug('consecutive_years_of_giving==>'+consecutive_years_of_giving);
                system.debug('consecutive_years_of_transactions==>'+consecutive_years_of_transactions);
                system.debug('c.Consecutive_Years_of_Giving__c==>'+c.Consecutive_Years_of_Giving__c);
                system.debug('c.Consecutive_Years_of_Transactions__c==>'+c.Consecutive_Years_of_Transactions__c);
                contactsToUpdate.add(c);
                
            }
        }
        update contactsToUpdate;*/
    }   
}