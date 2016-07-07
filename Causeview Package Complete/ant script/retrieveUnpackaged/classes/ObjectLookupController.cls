public with sharing class ObjectLookupController {
    public String searchStringLabel{get;set;}
    public String selectedObjectIds{get;set;}
    public Map<String, String> mapApiNameLable{get;set;}
    public List<String> fields{get;set;}
    Integer limitValue;
    Integer countLimit;
    Set<String> setOfFields;
    public String objName{get;set;}
    List<String> externalIdFields;
    public String displayType{get;set;}
    public boolean rendermsg{get;set;}
    //Constructor
    public ObjectLookupController() {
        rendermsg = true;
        fields = new List<String>();
        setOfFields = new Set<String>();
        mapApiNameLable = new Map<String, String>();
        objName = String.escapeSingleQuotes(System.currentPageReference().getParameters().get('oName'));
        
    }
    
}