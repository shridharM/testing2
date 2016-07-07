public class ExportClass{
    public cv_pkg_dev_I__Gift_Detail__c allocation{get;set;}
    public string debit{get;set;}
    public string credit{get;set;}
    Public string allocationDate {get;set;}
    Public string reference{get;set;}
    public ExportClass(cv_pkg_dev_I__Gift_Detail__c a){
        allocation = a;
        allocationDate = string.valueOf(a.Allocation_Date__c);
        reference = parseReference(a);
        debit = 'D';
        Credit = 'C';
    }
    public String parseReference(cv_pkg_dev_I__Gift_Detail__c allocation){
        Pattern myPattern = Pattern.compile('>(.*?)</a>');
        Matcher MyMatcher = MyPattern.matcher(allocation.Constituent__c);
        MyMatcher.find();
        string constituent = MyMatcher.group(1);
        return constituent;
    }
}