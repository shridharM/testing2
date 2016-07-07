public class BatchPresetXMLParser {
    
    public String writeXML(String ObjectType, List<PresetWrapper> dataToWrite) {
        
        XmlStreamWriter w = new XmlStreamWriter();
        
        w.writeStartElement(null, ObjectType, null);
        for(PresetWrapper obj_PW : dataToWrite) {
            //if(obj_PW.isHidden == false) {
                w.writeStartElement(null, 'fields', null);
                w.writeAttribute(null, null, 'Lable', obj_PW.fieldLable);
                w.writeAttribute(null, null, 'Name', obj_PW.fieldName);
                w.writeAttribute(null, null, 'Type', obj_PW.fieldType);
                
                if(obj_PW.sObjectType.get(obj_PW.fieldName) != null)
                    w.writeAttribute(null, null, 'Value', String.valueOf(obj_PW.sObjectType.get(obj_PW.fieldName)));
                else
                    w.writeAttribute(null, null, 'Value', 'null');
                    
                w.writeAttribute(null, null, 'ReadOnly', String.valueOf(obj_PW.isReadOnly));
                w.writeAttribute(null, null, 'Hidden', String.valueOf(obj_PW.isHidden));
                w.writeAttribute(null, null, 'Summ', String.valueOf(obj_PW.isForSummary));

                w.writeEndElement(); //end fields
            //}
        }
        w.writeEndElement(); //end objectType
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        
        return xmlOutput;
    }
    
    public List<PresetWrapper> readXML(String xmlString, String sObjectType) {
        
        List<PresetWrapper> presetDataList = new List<PresetWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(sObjectType);
        
        XmlStreamReader reader = new XmlStreamReader(xmlString);
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (reader.getLocalName() == 'fields') {
                    
                    PresetWrapper pw = new PresetWrapper(objSchema);
                    
                    pw.fieldLable = reader.getAttributeValue(null, 'Lable');
                    pw.fieldName = reader.getAttributeValue(null, 'Name');
                    pw.fieldType = reader.getAttributeValue(null, 'Type');
                    if(reader.getAttributeValue(null, 'Value') != 'null')
                        pw.fieldValue = reader.getAttributeValue(null, 'Value');
                    else
                        pw.fieldValue = null;
                    
                    if(pw.fieldValue != null && pw.fieldValue != 'null') {
                        if(pw.fieldType == 'BOOLEAN')
                            pw.sObjectType.put(pw.fieldName, Boolean.valueOf(pw.fieldValue));
                        else if(pw.fieldType == 'DOUBLE' || pw.fieldType == 'CURRENCY' || pw.fieldType == 'PERCENT')
                            pw.sObjectType.put(pw.fieldName, Double.valueOf(pw.fieldValue));
                        else if(pw.fieldType == 'DATE')
                            pw.sObjectType.put(pw.fieldName, convertDate(pw.fieldValue));
                        else if(pw.fieldType == 'DATETIME')
                            pw.sObjectType.put(pw.fieldName, convertDateTime(pw.fieldValue));
                        else
                            pw.sObjectType.put(pw.fieldName, pw.fieldValue);
                    }
                    else
                        pw.sObjectType.put(pw.fieldName, pw.fieldValue);
                        
                    pw.isReadOnly = Boolean.valueOf(reader.getAttributeValue(null, 'ReadOnly'));
                    pw.isHidden = Boolean.valueOf(reader.getAttributeValue(null, 'Hidden'));
                    pw.isForSummary = Boolean.valueOf(reader.getAttributeValue(null, 'Summ'));
                    
                    presetDataList.add(pw);
                } 
            }
            reader.next();
        }
        
        return presetDataList;
    }
    
    public Date convertDate(string stringDate) {
        
        String[] strDateDivided = stringDate.split(' ');
        strDateDivided = strDateDivided[0].split('-');
        
        Integer year = Integer.ValueOf(strDateDivided[0]);
        Integer month = Integer.ValueOf(strDateDivided[1]);
        Integer day = Integer.ValueOf(strDateDivided[2]);
        
        return date.newinstance(year, month, day);
    }
    
    public DateTime convertDateTime(string strDT) {
        /*
        Map<string,integer> MapMonthList = new Map<string,integer>();
        MapMonthList.put('January',1);
        MapMonthList.put('February',2);
        MapMonthList.put('March',3);
        MapMonthList.put('April',4);
        MapMonthList.put('May',5);
        MapMonthList.put('June',6);
        MapMonthList.put('July',7);
        MapMonthList.put('August',8);
        MapMonthList.put('September',9);
        MapMonthList.put('October',10);
        MapMonthList.put('November',11);
        MapMonthList.put('December',12);

        String[] strDTDivided = strDT.split(' ');
        
        string month = String.ValueOf(MapMonthList.get(strDTDivided.get(0)));
        string day = strDTDivided.get(1).replace(',', '');
        string year = strDTDivided.get(2);
        
        string hour = strDTDivided.get(3).split(':').get(0);
        string minute = strDTDivided.get(3).split(':').get(1);
        string second = '00';
        
        if (strDTDivided.get(4) == 'PM')
        {
            hour = String.ValueOf(Integer.ValueOf(hour) + 12);
        }
        string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute +  ':' + second;
        return datetime.valueOf(stringDate);
        */
        
        String[] strDateDivided = strDT.split(' ')[0].split('-');
        String[] strTimeDivided = strDT.split(' ')[1].split(':');
        
        Integer year = Integer.ValueOf(strDateDivided[0]);
        Integer month = Integer.ValueOf(strDateDivided[1]);
        Integer day = Integer.ValueOf(strDateDivided[2]);
        
        Integer hour = Integer.ValueOf(strTimeDivided[0]);
		Integer minute = Integer.ValueOf(strTimeDivided[1]);
		Integer second = Integer.ValueOf(strTimeDivided[2]);
		
        return dateTime.newInstance(year, month, day, hour, minute, second);
    }
}