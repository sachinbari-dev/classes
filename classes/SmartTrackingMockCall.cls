@isTest
global class SmartTrackingMockCall implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest request) {
       HttpResponse response = new HttpResponse();
      
        response.setHeader('Content-Type', 'application/json; charset=utf-8'); 
     String body = '';        
      String body1 = '';
     response.setBody(body);
      //    response.setBody('{"key": "value"}');
      response.setStatusCode(200);
      String bod ='{"uuid":"1234567"}';
      response.setBody(bod);
      return response;
 }    

}