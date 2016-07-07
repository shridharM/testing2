public with sharing class CampaignDashboardController {
    public List<Util.PieWedgeData> allocByMonth { get; set; }
    public List<Util.PieWedgeData> allocByDonorLevel { get; set; }
    public Campaign camp { get; set; }
    public boolean hasDonorLevel { get; set; }
    public boolean hasAllocation { get; set; }
   
    public CampaignDashboardController(ApexPages.StandardController controller) {
       string campId = ApexPages.currentPage().getParameters().get('id');
       if (campId==null || campId=='') return;
       camp = [SELECT Id, Name, RecordTypeId FROM Campaign WHERE Id = :campId];
       
       loadAllocByMonth(campId);
       loadAllocByDonorLevel(campId);
    }
    
    public void loadAllocByMonth(string campId)
    {
       allocByMonth = new List<Util.PieWedgeData>();
       AggregateResult[] aggrRecs = null;
       
       if (camp!=null && camp.RecordTypeId == Util.GetRecordTypeId('Campaign','Campaign'))
       {
          aggrRecs = [SELECT SUM(causeview__Amount__c) total, CALENDAR_MONTH(causeview__Allocation_Date__c) month
          FROM causeview__Gift_Detail__c WHERE causeview__Campaign__c = :campId AND (causeview__Allocation_Date__c = THIS_YEAR)
            GROUP BY CALENDAR_MONTH(causeview__Allocation_Date__c) 
            ORDER BY CALENDAR_MONTH(causeview__Allocation_Date__c)];
       }
       else
       {
          aggrRecs = [SELECT SUM(causeview__Amount__c) total, CALENDAR_MONTH(causeview__Allocation_Date__c) month
          FROM causeview__Gift_Detail__c WHERE causeview__New_Campaign__c = :campId AND (causeview__Allocation_Date__c = THIS_YEAR)
            GROUP BY CALENDAR_MONTH(causeview__Allocation_Date__c) 
            ORDER BY CALENDAR_MONTH(causeview__Allocation_Date__c)];
       }
       
       if (aggrRecs!=null && aggrRecs.size()>0)
       {
          integer inx = 1;
          hasAllocation = true;
          for(integer i=inx;i<=12;i++)
          {
              AggregateResult result = Util.findItem(aggrRecs, i, 'month');
              if (result!=null)
                 allocByMonth.add(new Util.PieWedgeData(string.valueOf(result.get('month')),(decimal)result.get('total'))); 
              else
                 allocByMonth.add(new Util.PieWedgeData(string.valueOf(i),0)); 
               inx++;
          }
       } 
    }
    
    
    public void loadAllocByDonorLevel(string campId)
    {
       allocByDonorLevel = new List<Util.PieWedgeData>();
       AggregateResult[] aggrRecs = null;
       
       if (camp!=null && camp.RecordTypeId == Util.GetRecordTypeId('Campaign','Campaign'))
       {
          aggrRecs = [SELECT SUM(causeview__Amount__c) total, causeview__Gift__r.causeview__Constituent__r.causeview__First_Time_Donor__c level
            FROM causeview__Gift_Detail__c WHERE causeview__Campaign__c = :campId 
            GROUP BY causeview__Gift__r.causeview__Constituent__r.causeview__First_Time_Donor__c
            ORDER BY causeview__Gift__r.causeview__Constituent__r.causeview__First_Time_Donor__c];
       }
       else
       {
          aggrRecs = [SELECT SUM(causeview__Amount__c) total, causeview__Gift__r.causeview__Constituent__r.Sys_Donor_Segmentation__c level
            FROM causeview__Gift_Detail__c WHERE causeview__New_Campaign__c = :campId 
            GROUP BY causeview__Gift__r.causeview__Constituent__r.Sys_Donor_Segmentation__c
            ORDER BY causeview__Gift__r.causeview__Constituent__r.Sys_Donor_Segmentation__c];
       }
       
       if (aggrRecs!=null && aggrRecs.size()>0)
       {
          hasDonorLevel = true;
          for(AggregateResult r : aggrRecs)
          {
             string level = (r.get('level')==null)? 'Unknown' : string.valueOf(r.get('level'));
             allocByDonorLevel.add(new Util.PieWedgeData(level,(decimal)r.get('total'))); 
          }
       } 
        
    }
}
