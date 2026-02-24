@isTest
global class FileBackupToAzureBatchNewMock implements HttpCalloutMock
{
	global HttpResponse respond(HttpRequest req)
    {
        HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type','application/json');
        resp.setBody('');
		resp.setStatusCode(201);
		return resp;        
    }
}