@isTest
public class TSM_SignatureHelper_Mock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        
        response.setBody('{"key": "value"}');
        response.setStatusCode(200);
        return response;
    }
}