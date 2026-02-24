@IsTest
public class getAttachmentRecordByIdTest {
    
    @IsTest
    static void testGetInvoiceDataWithValidData() {
        
        BVCQuote__c testQuote = new BVCQuote__c(Business_Type__c = 'ACR', BVC_Service__c = 'ValSHIP');
        insert testQuote;

      
        Attachment testAttachment = new Attachment(
            Name = 'TestAttachment.pdf',
            Body = Blob.valueOf('Test attachment data'),
            ParentId = testQuote.Id,
            ContentType = 'application/pdf'
        );
        insert testAttachment;

        
        String requestBody = JSON.serialize(new Map<String, Object>{
            'parentIds' => new List<String>{testQuote.Id}
        });

       
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AttachmentRecordAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        
        getAttachmentRecordById.getInvoiceData();

     
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains(testQuote.Id));
        System.assert(responseBody.contains(testAttachment.Id));
        System.assert(responseBody.contains('TestAttachment.pdf'));
    }

    @IsTest
    static void testGetInvoiceDataWithMissingParentIds() {
        
        String requestBody = JSON.serialize(new Map<String, Object>{
            'parentIds' => new List<String>()
        });

       
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AttachmentRecordAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

       
        getAttachmentRecordById.getInvoiceData();

        
        System.assertEquals(400, res.statusCode);
        System.assert(res.responseBody.toString().contains('No ParentIDs provided'));
    }

    @IsTest
    static void testGetInvoiceDataWithNonexistentParentId() {
     
        String requestBody = JSON.serialize(new Map<String, Object>{
            'parentIds' => new List<String>{'001XXXXXXXXXXXXXXX'}
        });

        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AttachmentRecordAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;


        getAttachmentRecordById.getInvoiceData();

    
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        
    }
}