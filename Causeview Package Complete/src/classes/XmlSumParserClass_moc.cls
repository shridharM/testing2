Public Class XmlSumParserClass_moc{
    public List<String>objectname = new List<string>();
    public List<String>fieldlabel = new List<String>();       
    public List<String>fieldvalue = new List<String>();
    public string str;   
    
    Map<String,Map<String,String>>showInSumMap = new Map<String,Map<String,String>>();
    
    public Map<String,Map<string,string>> sumParser(string xmlString) {
        //List<PresetWrapper> presetDataList = new List<PresetWrapper>();
         
        XmlStreamReader reader = new XmlStreamReader(xmlString);
        while(reader.hasNext() ) {
//            PresetWrapper pw = new PresetWrapper();
            PresetWrapper pw = new PresetWrapper(Batch_Template__c.SObjectType);
            DOM.Document doc = new DOM.Document();
            doc.load(xmlString);   

            DOM.XMLNode root = doc.getRootElement();
            str = root.getName();
            system.debug('*****' + str);

            if(reader.getEventType()== XmlTag.START_ELEMENT) {
               
             // str= xmlString.getRootElement();
               // str = reader.getAttributePrefix(1);
               //str = getParent(Dom.element);
             //   system.debug('*********' + root);
                
                if(reader.getLocalName() == 'fields') {
                     
                     pw.fieldLable = reader.getAttributeValue(null, 'Lable');
                     pw.fieldName = reader.getAttributeValue(null, 'Name');
                     pw.isForSummary = Boolean.valueOf(reader.getAttributeValue(null, 'Summ'));
                }
                if (pw.isForSummary == TRUE) {
                    objectname.add(str);
                    fieldlabel.add(pw.fieldLable);
                    fieldvalue.add(pw.fieldName);
                }
            }
            reader.next();
       }
       system.debug(objectname);
       system.debug(fieldlabel);
       system.debug(fieldvalue);
       system.debug(objectname.size());
       for(Integer i = 0; i< objectname.size(); i++){
    
            Map<String,String>labelvalueMap = new Map<String,String>();          
            
            for(Integer j = 0; j<fieldlabel.size(); j++){            
                labelvalueMap.put(fieldlabel[j],fieldvalue[j]);       
            }
    
            showInSumMap.put(objectname[i],labelvalueMap); 
        } 
        
       
        return ( showInSumMap );
    }  
    
}