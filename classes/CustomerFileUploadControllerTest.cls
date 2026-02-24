@isTest
public class CustomerFileUploadControllerTest {
    @isTest
    static void testUpdateFileLink1() {
        // Step 1: Create a ContentVersion (required to create a ContentDocument)
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Sample content')
        );
        insert contentVersion;

        // Step 2: Query the generated ContentDocumentId
        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id 
            LIMIT 1
        ];

        // Step 3: Call the method
        Test.startTest();
        CustomerFileUploadController.updateFileLink1('001000000000001', insertedVersion.ContentDocumentId);
        Test.stopTest();

        // Step 4: Verify the update
        ContentDocument updatedDoc = [
            SELECT Title 
            FROM ContentDocument 
            WHERE Id = :insertedVersion.ContentDocumentId
        ];

        System.assert(updatedDoc.Title.contains('Customer File'), 'Title should be updated to include "Customer File"');
    }

    @isTest
    static void testUpdateFileLink1_TitleAlreadyUpdated() {
        // Step 1: Create a ContentVersion with title already containing 'Customer File'
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test - Customer File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Sample content')
        );
        insert contentVersion;

        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id 
            LIMIT 1
        ];

        // Step 2: Call the method - It should NOT update the document title
        Test.startTest();
        CustomerFileUploadController.updateFileLink1('001000000000001', insertedVersion.ContentDocumentId);
        Test.stopTest();

        // Step 3: Validate title remains unchanged
        ContentDocument updatedDoc = [
            SELECT Title 
            FROM ContentDocument 
            WHERE Id = :insertedVersion.ContentDocumentId
        ];

        System.assertEquals('Test - Customer File', updatedDoc.Title, 'Title should not change if already contains "Customer File"');
    }
}