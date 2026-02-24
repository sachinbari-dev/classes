@IsTest
public class getContentVersionRecordByIdTest {
    @IsTest
    static void testGetInvoiceDataWithValidData() {
        
        BVCQuote__c testAccount = new BVCQuote__c(Business_Type__c = 'ACR', BVC_Service__c = 'ValSHIP');
        insert testAccount;

        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Version',
            PathOnClient = 'Test.pdf',
            FirstPublishLocationId = testAccount.Id, 
            VersionData = Blob.valueOf('Test data')
        );
        insert testContentVersion;

       
        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id LIMIT 1];
        System.debug('ContentDocumentId: ' + testContentVersion.ContentDocumentId);

     
        List<ContentDocumentLink> existingLinks = [
            SELECT Id FROM ContentDocumentLink
            WHERE LinkedEntityId = :testAccount.Id
            AND ContentDocumentId = :testContentVersion.ContentDocumentId
        ];

        if (existingLinks.isEmpty()) {
            ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
                LinkedEntityId = testAccount.Id,
                ContentDocumentId = testContentVersion.ContentDocumentId,
                ShareType = 'V'
            );
            insert testContentDocumentLink;
        } else {
            System.debug('ContentDocumentLink already exists.');
        }

        
        String requestBody = JSON.serialize(new Map<String, Object>{
            'linkedEntityIds' => new List<String>{testAccount.Id}
        });

      
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ContentRecordAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

       
        getContentVersionRecordById.getInvoiceData();

        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains(testAccount.Id));
        System.assert(responseBody.contains(testContentVersion.Id));
    }
}