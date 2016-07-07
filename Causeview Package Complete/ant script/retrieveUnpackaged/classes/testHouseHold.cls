@isTest
private with sharing class testHouseHold {

    static testMethod void testHouseHold () 
    {
        Test.startTest();           
        Contact c = new Contact();
        c.LastName = 'Test'; 
        upsert c;
        HouseHold.MyMember hhmm= new HouseHold.MyMember(0, false, new Contact());
        HouseHold hh = new HouseHold();
        hh.HouseHold.Name = 'Test';
        hh.newMember();
        hh.Member.LastName = 'Test';
        hh.save();
        //hh.saveAll();
        hh.newMember();
        hh.Member.LastName = 'Test';
        hh.saveAndNewMember();
        hh.newMember();
        hh.Keywords = 'Test';
        hh.showSuggestedMember();
        for(HouseHold.MyMember mm: hh.ExistingMemberList){
            mm.Checked=true;
        }    
        hh.addSelectedMember();
        hh.addExistingMember();
        hh.Keywords = 'kunlun';
        hh.selectExistingMember();
        hh.searchExistingMember();
        hh.cancel();
        hh.TestActionMemberId = '0';
        hh.editMember();
        hh.cloneMember();
        hh.delMember();
        hh.Url = '/001?fcf=00Bi0000000TiEI';
        hh.cancelAll();
        Set<Id> ids = new Set<Id>();
        ids.add(c.AccountId);
        RollupBatch.RecalculateTotalHouseholdGiving(ids);
        //hh.saveAll();
        Test.stopTest();
    }

        static testMethod void testHouseHold1 () 
    {
        Test.startTest();           
        Contact c = new Contact();
        c.LastName = 'Test'; 
        upsert c;
        HouseHold.MyMember hhmm= new HouseHold.MyMember(0, false, new Contact());
        HouseHold hh = new HouseHold();
        hh.HouseHold.Name = 'Test';
        hh.newMember();
        hh.Member.LastName = 'Test';
        hh.save();
        //hh.saveAll();
        hh.newMember();
        hh.Member.LastName = 'Test';
        hh.saveAndNewMember();
        hh.newMember();
        hh.Keywords = 'Test';
        hh.showSuggestedMember();
        for(HouseHold.MyMember mm: hh.ExistingMemberList){
            mm.Checked=true;
        }    
        hh.addSelectedMember();
        hh.addExistingMember();
        hh.Keywords = 'kunlun';
        hh.selectExistingMember();
        hh.searchExistingMember();
        hh.cancel();
        hh.TestActionMemberId = '0';
        hh.editMember();
        hh.cloneMember();
        hh.delMember();
        hh.Url = '/001?fcf=00Bi0000000TiEI';
        hh.saveAll();
        Set<Id> ids = new Set<Id>();
        ids.add(c.AccountId);
        RollupBatch.RecalculateTotalHouseholdGiving(ids);
        //hh.saveAll();
        Test.stopTest();
    }
}