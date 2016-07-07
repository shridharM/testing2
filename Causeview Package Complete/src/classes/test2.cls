public with sharing class test2 {
    public void mymethod()
    {
        system.debug('hiiiii');
        list<Campaign> cc=[select id, name from Campaign where id ='701A0000000mMwi' limit 1];
        
        if(cc.size()>0){
            for(Campaign ccTemp : cc){
                ccTemp.name='FY 2013 Special Events--up';            
            }
            update cc;
        }
    }
}