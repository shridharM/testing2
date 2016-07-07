public with sharing class MultichannelCampaignController {
    public boolean isTesting { get; set; }
    public string campaignId { get; set; }
    public Campaign selectedRecord { get; set; }
    public cv_pkg_dev_I__Goal__c campaignGoal { get; set; }
    
    public string appealRecordTypeId { get; set; }
    public integer wizardStep { get; set; }
    public string selectedAppealId { get; set; }
    
    public Campaign newAppeal { get; set; }
    public cv_pkg_dev_I__Goal__c newGoal { get; set; }
    
    public List<CampaignWrapper> existingAppeals { get; set; }
    public List<String> appealFields { get; set; }
    public List<String> goalFields { get; set; }
    
    public class CampaignWrapper {
       public Campaign Appeal { get; set; }
       public List<cv_pkg_dev_I__Goal__c> Goals { get; set; }
       public CampaignWrapper(Campaign a,List<cv_pkg_dev_I__Goal__c> b) {
          Appeal =a; Goals =b;
       }
    }
    
    public MultichannelCampaignController(ApexPages.StandardSetController controller) {
       isTesting = true;
       selectedRecord = (Campaign)controller.getRecord();
       campaignId = ApexPages.currentPage().getParameters().get('id');
       
       appealFields = new String[] { 'cv_pkg_dev_I__ParentAppeal__c:ro', 'type', 'Description', 'IsActive', 'BudgetedCost', 'startdate', 'NumberSent',
          'enddate','ExpectedResponse'};
       
       goalFields = new string[] { 'Name','cv_pkg_dev_I__overall_Goal__c','cv_pkg_dev_I__Fiscal_Year__c','cv_pkg_dev_I__Q1_Goal__c',
        'cv_pkg_dev_I__Active__c', 'cv_pkg_dev_I__Q2_Goal__c', 'cv_pkg_dev_I__Notes__c', 'cv_pkg_dev_I__Q3_Goal__c:insBlnk',
        'cv_pkg_dev_I__Q4_Goal__c' };
       
       init();
    }
    
    public void init() {
       wizardStep = 1;
       if (campaignId ==null || campaignId =='')
       {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Cannot locate the Campaign record.'));
          wizardStep = 10;
          return;
       }
       
       selectedRecord = [SELECT Id, name, isactive, startdate, enddate, description,
        (Select cv_pkg_dev_I__RSVP__c, cv_pkg_dev_I__Form_URL__c, Status, LeadId, LastModifiedDate, LastModifiedById, HasResponded, 
          FirstRespondedDate, CreatedDate, CreatedById, ContactId, CampaignId FROM CampaignMembers)
        FROM Campaign WHERE Id = :campaignId  limit 1];
       
       string gfieldsStr = getsObjectFields(goalFields);
       List<cv_pkg_dev_I__Goal__c> gs = Database.Query('SELECT Id, '+gfieldsStr+' FROM cv_pkg_dev_I__Goal__c WHERE cv_pkg_dev_I__Campaign_Appeal__c = :campaignId limit 1');
       if (gs!=null && gs.size()>0)
           campaignGoal = gs[0];
       else 
       {
           campaignGoal = new cv_pkg_dev_I__Goal__c();
           campaignGoal.cv_pkg_dev_I__Campaign_Appeal__c = selectedRecord.Id;
       }
        
       appealRecordTypeId = getAppealRecordTypeId();
       prepareNewAppeal();
       loadExistingAppeals();
    }
    
    private string getsObjectFields(List<string> fields)
    {
       string output = '';
       for(string f : fields) {
         output += f.replace(':ro','').replace(':insBlnk','') + ',';
       }
       if(output.endsWith(','))
         output = output.substring(0,output.length()-1);
       return output;
    }
    
    public void prepareNewAppeal(){
       //wizardStep = 2;
       newAppeal = new Campaign();
       newAppeal.ParentId = selectedRecord.Id;
       newAppeal.RecordTypeId = appealRecordTypeId;
       newGoal = new cv_pkg_dev_I__Goal__c();
    }
    public void cancelLastAction(){
      wizardStep = 1;
    }
    public void newGoal() {
      wizardStep = 2;
      
      if (existingAppeals!=null)
          for(CampaignWrapper c : existingAppeals)
               if (c.appeal.Id == selectedAppealId)
                  newAppeal = c.appeal;
       newGoal = new cv_pkg_dev_I__Goal__c();
    }
    public void AddGoal() {
     try
     {
       newGoal.cv_pkg_dev_I__Campaign_Appeal__c = selectedAppealId;
       insert newGoal;
       init();
      }
      catch(Exception ex)
       {
          ApexPages.addMessages(ex);
       }
    }
    
    private string getAppealRecordTypeId() {
       List<RecordType> recTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name='Appeal' AND NamespacePrefix = 'causeview'];
       if (recTypes!=null && recTypes.size()>0)
         return recTypes[0].Id;
       else
         return null;
    }
    private void loadExistingAppeals() {
       string aFields = getsObjectFields(appealFields);
       string gFields = getsObjectFields(goalFields);
       string query = 'SELECT id, Name, ' + aFields + ', (Select Id, '+gFields+ 
        ' FROM cv_pkg_dev_I__Goals__r) FROM Campaign WHERE ParentId = :campaignId  ORDER BY CreatedDate DESC';
       List<Campaign> existingOnes = Database.Query(query);

      if (existingOnes != null && existingOnes.size()>0) {
         existingAppeals = new List<CampaignWrapper>();
         for(Campaign c : existingOnes)
           existingAppeals.add(new CampaignWrapper(c, c.cv_pkg_dev_I__Goals__r));
      }
    }
    
    /*private void importCampaignMembers() {
      
      List<CampaignMember> members = selectedRecord.CampaignMembers;
      List<CampaignMember> newMembers = new list<CampaignMember>();
      if (members!=null)
          for(CampaignMember member : members){
            CampaignMember newItem = member.clone(false,false,true,true);
            newItem.CampaignId = newAppeal.Id;
            newMembers.add(newItem);
          }
      if (newMembers.size()>0)
          insert newMembers;
    }*/

    public void addAppeal() {
       insert newAppeal;
       newGoal.cv_pkg_dev_I__Campaign_Appeal__c = newAppeal.Id;
       insert newGoal;
       
       /*if (importParentMemberlist) {
          importCampaignMembers();
       }*/
    }
    
    public void saveAll() {
       
       Savepoint sp = Database.setSavepoint();
       try
       {
          update selectedRecord;
          if (campaignGoal !=null) { upsert campaignGoal; }
          addAppeal();
          List<Campaign> appeals = new List<Campaign>();
          List<cv_pkg_dev_I__Goal__c> goals = new List<cv_pkg_dev_I__Goal__c>();
          
          if (existingAppeals!=null) {
              for(CampaignWrapper c : existingAppeals) {
                 appeals.add(c.Appeal);
                 if (c.Goals!=null && c.Goals.size()>0)
                     goals.addAll(c.Goals);
              }
          }
          
          update appeals;
          update goals;
          init();
       }
       catch(Exception ex)
       {
          Database.rollback(sp);
          newAppeal = newAppeal.clone(false);
          newGoal = newGoal.clone(false);
          ApexPages.addMessages(ex);
          if (isTesting) throw ex;
       }
       
    }
}