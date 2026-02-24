public class FileBackupToAzure {

  /*  // Step 1: Backup files from Contract, Invoice, and Credit Note objects
    public static void backupFilesToAzure() {
        // Query files related to Contract Object
        List<ContentDocumentLink> contractFiles = [ SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileType 
                                                  FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Contract)];
        
        // Query files related to Invoice Object
        List<ContentDocumentLink> invoiceFiles = [ SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileType 
                                                  FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM blng__Invoice__c)];
        
        // Query files related to Credit Note Object
        List<ContentDocumentLink> creditNoteFiles = [ SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.FileType 
                                                  FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM blng__CreditNote__c)];
        
        // Process and upload files for Contract, Invoice, and Credit Note objects
        processFiles(contractFiles, 'Contract');
        processFiles(invoiceFiles, 'Invoice');
        processFiles(creditNoteFiles, 'CreditNote');
    }

    // Helper method to process files and upload them to Azure
    public static void processFiles(List<ContentDocumentLink> fileLinks, String objectType) {
        for (ContentDocumentLink fileLink : fileLinks) {
            // Retrieve the file content from ContentVersion
            List<ContentVersion> fileVersions = [
                SELECT Id, VersionData, Title FROM ContentVersion
                WHERE ContentDocumentId = :fileLink.ContentDocumentId LIMIT 1
            ];

            for (ContentVersion version : fileVersions) {
                // Upload the file to Azure Blob Storage
               uploadFileToAzure(version.VersionData, version.Title, fileLink.LinkedEntityId, objectType);
            }
        }
    }

    // Step 2: Upload the file to Azure Blob Storage
    public static void uploadFileToAzure(Blob fileContent, String fileName, String recordId, String objectType) {
        try {
            // Generate the Azure Blob Storage URL
            String blobEndpoint = 'https://' + 'bvcstorageos' + '.blob.core.windows.net/salesforcefiles/' + objectType + '/' + recordId + '/' + fileName;

            // Create the Authorization header for Azure Blob Storage (HMAC-based)
           // String date = AzureUtils.getCurrentAzureDate();  // NEED DATE
            String dateToCreated =String.valueOf(System.Today());
            String stringToSign = 'PUT\n\n' + fileContent.size() + '\n\n' + 'application/octet-stream\n\n\n\n\n\n\n\nx-ms-blob-type:BlockBlob\nx-ms-date:' + dateToCreated + '\nx-ms-version:2019-02-02\n/' + 'your-storage-account-name' + '/' + objectType + '/' + recordId + '/' + fileName;

            fileName = fileName.replace(' ', '_');
            System.debug('fileName :'+fileName);
            String endPoint ='https://bvcstorageos.blob.core.windows.net/salesforcefiles/'+fileName;
            endPoint = endPoint +'?sv=2023-01-03&spr=https%2Chttp&st=2024-10-10T12%3A42%3A27Z&se=2028-05-10T12%3A42%3A00Z&sr=c&sp=racwltf&sig=poyeaQEsl8E8nEZvIA%2F4%2FrAV3Gl97wQRrzaeHy7qLkw%3D';
            
            // String data ='@RZltuZFS1/'+fileName+'.pdf'; 
            String endPointtest='https://bvcstorageos.blob.core.windows.net';           
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            
            req.setMethod('PUT');   
            req.setHeader('Content-Length','0');
            req.setHeader('x-ms-blob-type', 'BlockBlob');
            req.setHeader('Content-Type', 'application/pdf');
            req.setBodyAsBlob(fileContent);
            /*         
            req.setHeader('x-ms-blob-type', 'BlockBlob');
            req.setBodyAsBlob(fileContent);  // setting Binary Body
            req.setHeader('Content-Type', 'application/pdf');
            
            // req.setBody(data);

            // Send the HTTP request
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('74  req: ' + req);
			System.debug('71 res.getStatusCode():'+res.getStatusCode());
            if (res.getStatusCode() == 201) {
                System.debug('File uploaded successfully to fileName: ' + fileName);
				System.debug('File uploaded successfully to recordId: ' + recordId);
                System.debug('File uploaded successfully to objectType: ' + objectType);
                System.debug('File uploaded successfully to blobEndpoint: ' + blobEndpoint);
                System.debug('File uploaded successfully to res: ' + res);
                System.debug('File uploaded successfully to res Body: ' + res.getBody());
                // Step 3: Store the Azure Blob Storage URL in Salesforce
                storeFileUrlInSalesforce(recordId, objectType, endPoint);
            } else {
                System.debug('Error uploading file to Azure: ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Error during file upload: ' + e.getMessage());
        }
    }

    // Step 3: Store the Azure Blob Storage URL in Salesforce
    public static void storeFileUrlInSalesforce(String recordId, String objectType, String fileUrl) {
        if (objectType == 'Contract') {
            Contract contractRecord = [SELECT Id FROM Contract WHERE Id = :recordId LIMIT 1];
            contractRecord.ContractSignedDocumentUrl__c = fileUrl;
            update contractRecord;
        } else if (objectType == 'Invoice') {
            blng__Invoice__c invoiceRecord = [SELECT Id FROM blng__Invoice__c WHERE Id = :recordId LIMIT 1];
            invoiceRecord.InvoiceFileUrl__c = fileUrl;
            update invoiceRecord;
        } else if (objectType == 'CreditNote') {
            blng__CreditNote__c creditNoteRecord = [SELECT Id FROM blng__CreditNote__c WHERE Id = :recordId LIMIT 1];
            creditNoteRecord.CreditNoteFileUrl__c = fileUrl;
            update creditNoteRecord;
        }
    }*/
}