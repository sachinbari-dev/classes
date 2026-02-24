@isTest
global class sendGridEmailMessageAttachmentsMock  implements HttpCalloutMock{

       global HTTPResponse respond(HttpRequest req){
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":"success"}');
        res.setStatusCode(202);
        return res;
    }
}