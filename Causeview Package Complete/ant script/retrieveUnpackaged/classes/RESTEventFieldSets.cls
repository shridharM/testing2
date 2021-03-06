@RestResource(urlMapping='/EventsFieldSet')
global with sharing class RESTEventFieldSets {
    @HttpGet   
    global static String createNewCase() {
        List<string> retVal = new List<string>();
        for(Schema.FieldSetMember f : SObjectType.cv_pkg_dev_I__Event_Registration__c.FieldSets.cv_pkg_dev_I__iOSAppFields.getFields()) {
            retVal.add(f.getFieldPath());
        }
        return String.join(retVal, ',');
    }
}