public with sharing class testsharing 
{
    public void mymethod()
 {
    system.debug('hiiiii');
    Campaign cc=[select id, name from Campaign where id ='701A0000000mMwi'];
    system.debug('hiiiiiiii'+cc);
  
    cc.name='FY 2013 Special Events--up';
    update cc;
  }
}