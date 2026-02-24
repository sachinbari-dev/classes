@isTest
global class FleetXjobMockCallout implements HttpCalloutMock
{
	global HttpResponse respond(HttpRequest req)
    {
        HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type','application/json');
        // resp.setBody('{"Id":"123456","Name":"Name"}');
        resp.setBody('{"content": [{"id": 15625369,"name": "J-0000571","status": "CANCELLED","startDate": "2024-10-12 23:11:57"}]}');
		resp.setStatusCode(200);
		return resp;        
    }
}