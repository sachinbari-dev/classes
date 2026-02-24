@IsTest
public class getAttachmentObjectDataTest {
    
    @IsTest
    static void testGetInvoiceDataWithValidData() {
       
        BVCQuote__c testQuote = new BVCQuote__c(Business_Type__c = 'ACR', BVC_Service__c = 'ValSHIP');
        insert testQuote;

        
        Attachment testAttachment = new Attachment(
            Name = 'TestAttachment.pdf',
            ParentId = testQuote.Id,
            Body = Blob.valueOf('Test Attachment Body Data')
        );
        insert testAttachment;

        
        testAttachment = [SELECT Id, CreatedDate, ParentId FROM Attachment WHERE Id = :testAttachment.Id LIMIT 1];

        
        String fromCreationDate = String.valueOf(testAttachment.CreatedDate.addDays(-1).date());
        String toCreationDate = String.valueOf(testAttachment.CreatedDate.addDays(1).date());

       
        String requestBody = JSON.serialize(new Map<String, Object>{
            'from' => fromCreationDate,
            'to' => toCreationDate
        });


        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AttachmentDataAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

      
        getAttachmentObjectData.getInvoiceData();

       
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains(testAttachment.Id));
        System.assert(responseBody.contains(testAttachment.ParentId));
        System.assert(responseBody.contains('TestAttachment.pdf'));
    }

    @IsTest
    static void testGetInvoiceDataWithInvalidDateRange() {
       
        String requestBody = JSON.serialize(new Map<String, Object>{
            'from' => '2024-09-30',
            'to' => '2024-09-01'
        });

        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AttachmentDataAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

       
        getAttachmentObjectData.getInvoiceData();

   
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
        req.requestUri = '/services/apexrest/AttachmentDataAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

   
        getAttachmentObjectData.getInvoiceData();

       
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
        req.requestUri = '/services/apexrest/AttachmentDataAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

      
        getAttachmentObjectData.getInvoiceData();

        
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('Invalid date format'));
    }
}