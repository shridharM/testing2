public class CampaignStructureUpdateBatchSchedule implements schedulable {
    
    public void execute(schedulableContext SC){
        Database.executeBatch(new CampaignStructureUpdateBatch());
    }
}