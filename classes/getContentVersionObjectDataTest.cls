@IsTest
public class getContentVersionObjectDataTest {
    @IsTest
    static void testGetInvoiceDataWithValidData() {

        BVCQuote__c testQuote = new BVCQuote__c(Business_Type__c = 'ACR', BVC_Service__c = 'ValSHIP');
        insert testQuote;

     
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Version',
            PathOnClient = 'Test.pdf',
            FirstPublishLocationId = testQuote.Id,
            VersionData = Blob.valueOf('Test data')
        );
        insert testContentVersion;

     
        testContentVersion = [SELECT Id, CreatedDate, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id LIMIT 1];

       
        String fromCreationDate = String.valueOf(testContentVersion.CreatedDate.addDays(-1).date());
        String toCreationDate = String.valueOf(testContentVersion.CreatedDate.addDays(1).date());

        
        String requestBody = JSON.serialize(new Map<String, Object>{
            'from' => fromCreationDate,
            'to' => toCreationDate
        });

     
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/InvoiceDataAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

    
        getContentVersionObjectData.getInvoiceData();

       
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains(testContentVersion.Id));
        System.assert(responseBody.contains(testContentVersion.ContentDocumentId));
    }

    @IsTest
    static void testGetInvoiceDataWithInvalidDateRange() {
      
        String requestBody = JSON.serialize(new Map<String, Object>{
            'from' => '2024-09-30',
            'to' => '2024-09-01'
        });

       
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/InvoiceDataAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

  
        getContentVersionObjectData.getInvoiceData();

      
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('From date must be before To date'));
    }

    @IsTest
    static void testGetInvoiceDataWithMissingDate() {

        String requestBody = JSON.serialize(new Map<String, Object>{
            'from' => '',
            'to' => ''
        });

      
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/InvoiceDataAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

  
        getContentVersionObjectData.getInvoiceData();

      
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Invalid date range provided'));
    }

    @IsTest
    static void testGetInvoiceDataWithInvalidDateFormat() {
        
        String requestBody = JSON.serialize(new Map<String, Object>{
            'from' => 'invalid-date',
            'to' => 'invalid-date'
        });

     
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/InvoiceDataAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

       
        getContentVersionObjectData.getInvoiceData();

       
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Invalid date format'));
    }
}