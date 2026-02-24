@isTest
private class FileUploadControllerTest {
    @isTest
    static void testUpdateFileLink() {
        // Step 1: Create test Vault_Shipmet__c record without setting Name
        Vault_Shipmet__c vShip = new Vault_Shipmet__c();
        insert vShip;

        // Step 2: Create ContentVersion (creates ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'Test POD',
            PathOnClient = 'TestPOD.pdf',
            VersionData = Blob.valueOf('Sample File')
        );
        insert cv;

        // Fetch ContentDocumentId via ContentVersion
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        String contentDocumentId = cv.ContentDocumentId;

        // Step 3: Link file to shipment record (simulate attachment)
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = vShip.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Step 4: Call method under test
        Test.startTest();
        FileUploadController.updateFileLink(vShip.Id, contentDocumentId);
        Test.stopTest();

        // Step 5: Assertions
        Vault_Shipmet__c updatedShip = [
            SELECT POD_Link_URL__c, Vault_Tracking_status__c 
            FROM Vault_Shipmet__c 
            WHERE Id = :vShip.Id
        ];
        System.assertNotEquals(null, updatedShip.POD_Link_URL__c, 'POD link URL should be populated');
        System.assertEquals('Delivered', updatedShip.Vault_Tracking_status__c, 'Status should be updated');

        ContentDocument updatedDoc = [
            SELECT Title FROM ContentDocument WHERE Id = :contentDocumentId
        ];
        System.assert(updatedDoc.Title.contains('POD File'), 'Title should contain "POD File"');
    }
}