@isTest
global class MockHttpResponseGeneratorForPANVerif implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://testapi.karza.in/v2/pan', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"result":{"name":"TITAN COMPANY LIMITED"},"request_id":"e11160f6-02a8-40a6-9ccf-040cbee70c29","status-code":"101"}');
        res.setStatusCode(200);
        return res;
    }
     global HTTPResponse respond1(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://testapi.karza.in/v2/pan', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"result":{"name":"TITAN COMPANY LIMITED"},"request_id":"e11160f6-02a8-40a6-9ccf-040cbee70c29","status-code":"102"}');
        res.setStatusCode(200);
        return res;
    }
     global HTTPResponse respond2(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://testapi.karza.in/v2/pan', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"result":{"name":"TITAN COMPANY LIMITED"},"request_id":"e11160f6-02a8-40a6-9ccf-040cbee70c29","status-code":"103"}');
        res.setStatusCode(200);
        return res;
    }
     global HTTPResponse respond3(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://testapi.karza.in/v2/pan', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"result":{"name":"TITAN COMPANY LIMITED"},"request_id":"e11160f6-02a8-40a6-9ccf-040cbee70c29","status-code":"105"}');
        res.setStatusCode(200);
        return res;
    }
}