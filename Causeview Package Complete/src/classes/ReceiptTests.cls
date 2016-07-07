@isTest
class ReceiptTests {

     static testMethod void test1() {
         RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'causeview__Receipt__c' AND Name = 'Pending' LIMIT 1];
         Contact c = new Contact(LastName = 'dsadasd', Email = 'breakeven@breakeveninc.com');
         insert c;
         Gift__c g = new Gift__c(Constituent__c = c.Id);
         insert g;
         Receipt__c r = new Receipt__c(RecordTypeId = rt.Id, Constituent__c = c.Id, Gift__c = g.Id);
         insert r;
         Test.startTest();
        PageReference pageRef = Page.ReceiptPrinter;
        pageRef.getParameters().put('id', r.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController std = new ApexPages.StandardController(r);
        ReceiptPrinter controller = new ReceiptPrinter(std);
        controller.rerender();
        controller.format = True;
        controller.print();
        controller.format = False;
        controller.print();
        controller.getItems();
        PageReference pageRef2 = Page.ReceiptPrinter;
        pageRef2.getParameters().put('id', r.Id);
        Test.setCurrentPage(pageRef2);
        ApexPages.StandardController std2 = new ApexPages.StandardController(r);
        ReceiptPrinter controller2 = new ReceiptPrinter(std2);
        controller2.rerender();
        controller2.format = True;
        controller2.print();
        controller2.format = False;
        controller2.print();
        controller2.getItems();
        Test.stopTest();
     }
    
}