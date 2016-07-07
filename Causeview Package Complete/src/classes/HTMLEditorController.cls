public class HTMLEditorController{
    
    Public Map<String, Schema.SObjectType> AllObjmap;
    Public HTML_Editor__c htmlEditor;
    Public string relatedTo;
    Public string recepient;
    
    public HTMLEditorController(){
        AllObjmap = New Map<String, Schema.SObjectType>();
        htmlEditor = new HTML_Editor__c();
    }
    /* Wrapper class to contain the nodes and their children */
    public class cNodes
    {
        public string objectName {get; set;}
        Public List<String> fieldName {get;set;}
        public cNodes(string oName, List<String> fName)
        {       
            objectName = oName;       
            fieldName = fName;   
        }  
    }
    /* end of Wrapper class */
    Public List<cNodes> hierarchy;
    Public List<cNodes> getmainnodes()
    {
        hierarchy = new List<cNodes>();
        AllObjmap = Schema.getGlobalDescribe(); 
        System.debug('******All object Names :'+ AllObjmap.keyset()); 
        String[] objectName = new String[]{'Contact', 'Receipt__c'};
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(objectName);
        system.debug('results==>'+results);
        for(Schema.DescribeSobjectResult res : results){
            string objName = res.getName();
            system.debug('objName==>'+objName);
            Map <String, Schema.SObjectField> fieldMap = AllObjmap.get(objName).getDescribe().fields.getMap();
            List<String> fieldname = new List<String>();
            for(string sfieldname : fieldMap.keySet())
            {
                fieldname.add(sfieldname);
                system.debug('fieldMap==>'+fieldMap.get(sfieldname).getDescribe());
                if(fieldMap.get(sfieldname).getDescribe().getType() == Schema.DisplayType.REFERENCE){
                    //system.debug('Name==>'+fieldMap.get(sfieldname).getDescribe().getName());
                    fieldname.add(fieldMap.get(sfieldname).getDescribe().getRelationshipName());
                }
            }
            hierarchy.add(new cNodes(objName, fieldname));
        }
        system.debug('hierarchy==>'+hierarchy);
        return hierarchy;
    }
}