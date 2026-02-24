@isTest
global class BVC_IqlooLockAPIHelperMock2 implements HttpCalloutMock {

     global HTTPResponse respond(HTTPRequest request) {
         
          HttpResponse response = new HttpResponse();
           response.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
           String body = '';
         
         if(request.getEndpoint().endswith('https://auth.igloohome.co/oauth2/token')){
              body = '{"error":"invalid_client"}';
              response.setBody(body);
              response.setStatusCode(400);
          }
         if(request.getEndpoint().endswith('https://api.igloodeveloper.co/igloohome/devices/SP2X18720632/algopin/onetime')){
             body = '{"error":"Invalid JSON. The request body must be valid JSON."}';
             response.setBody(body);
             response.setStatusCode(400);
         }
         if(request.getEndpoint().endswith('https://api.igloodeveloper.co/igloohome/devices/SP2X18720632/masterpin')){
             body = '{"code":403,"message":"Invalid Oauth token","status":"failure"}';
             response.setBody(body);
             response.setStatusCode(403);
         }
          
            return response;
         }
}