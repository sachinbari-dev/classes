@isTest
public class TATSLACalculatorAPI_Test {

     @isTest
    static void testNoRequestBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;

        String result = TATSLACalculatorAPI.getTurnAroundTime();
        TATSLACalculatorAPI.Method2();
        
    }

     @isTest
    static void testwithNonServiceableRequest() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"originPincode":"121102","destinationPincode": "121105"}');  
        RestContext.request = req;
        RestContext.response = res;
       
        String result = TATSLACalculatorAPI.getTurnAroundTime();
          TATSLACalculatorAPI.Method2();
    }
     @isTest
    static void testwithRequest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"originPincode":"400004","destinationPincode": "400001"}');  
        RestContext.request = req;
        RestContext.response = res;
              
        String result = TATSLACalculatorAPI.getTurnAroundTime();
        system.debug('result' + result);
        system.debug('response ' + RestContext.response );        
    }
     
     @isTest
    static void testNoOrigin() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"originPincode":" ","destinationPincode": "100003"}');  
        RestContext.request = req;
        RestContext.response = res;

        String result = TATSLACalculatorAPI.getTurnAroundTime();
          TATSLACalculatorAPI.Method2();
    }
    @isTest
    static void testWithException() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{invalidJson}');
        RestContext.request = req;
        RestContext.response = res;

          String result = TATSLACalculatorAPI.getTurnAroundTime();
              TATSLACalculatorAPI.Method2();
    }
     @isTest
     static void testOriginLength() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"originPincode":"1000034","destinationPincode": "100003"}');  
        RestContext.request = req;
        RestContext.response = res;
    
        String result = TATSLACalculatorAPI.getTurnAroundTime();
          TATSLACalculatorAPI.Method2();
    }
     @isTest
     static void testDestinationLength() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"originPincode":"100003","destinationPincode": "1000037"}');  
        RestContext.request = req;
        RestContext.response = res;

        String result = TATSLACalculatorAPI.getTurnAroundTime();
        
    }
    

}