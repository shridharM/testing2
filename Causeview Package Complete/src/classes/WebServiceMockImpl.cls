@isTest
global class WebServiceMockImpl implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       MetadataService.readMetadataResponse_element respElement = 
           new MetadataService.readMetadataResponse_element();
       //respElement.EchoStringResult = 'Mock response';
       response.put('response_x', respElement); 
   }
}