@isTest
public class TestPostInstallScript
{
  @isTest static void test() 
  {
      PostInstall postinstall = new PostInstall();
    Test.testInstall(postinstall, new Version(99,0));
    //system.assert(aNums__c.getInstance('Default') != null);
    //system.assert(BatchSettings__c.getInstance('Default') != null);
    system.assert(App_Settings__c.getInstance(UserInfo.getOrganizationId()).Name != null);
    //system.assert(givingpowerSettings__c.getInstance('Settings') != null);

  }
}