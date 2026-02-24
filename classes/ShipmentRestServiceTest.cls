@isTest
private class ShipmentRestServiceTest {

    @isTest
    static void testCustomerDocumentAPI_InsertAndUpdate_WithId() {
        // Use provided Shipment Id
        String shipmentId = 'a2p5g000001AtMoAAK';

        // --- Build Insert payload ---
        ShipmentRestService.ShipmentRequest insertReq = new ShipmentRestService.ShipmentRequest();
        insertReq.Shipment = shipmentId;
        insertReq.TotalNetWeight = 200.00;
        insertReq.InvoiceValue = 500.00;
        insertReq.Referencenumber = 'Ref123';
        insertReq.Documenttype = 'Delivery challan';
        insertReq.CustomerDocumentsURL = 'https://example.com/documents';
        insertReq.UnitWeight = 'Gram';
        insertReq.CustomerProductCategory = 'ValSHIP';
        insertReq.ProductDescription = 'Gold Coin';
        insertReq.AdharUrl = 'https://example.com/aadhar';
        insertReq.PANUrl = 'https://example.com/pan';

        List<ShipmentRestService.ShipmentRequest> insertList = new List<ShipmentRestService.ShipmentRequest>{insertReq};

        // --- Build Update payload (CustomerDocumentId will be filled later) ---
        ShipmentRestService.ShipmentRequest updateReq = new ShipmentRestService.ShipmentRequest();
        updateReq.Shipment = shipmentId;
        updateReq.TotalNetWeight = 300.00;
        updateReq.InvoiceValue = 700.00;
        updateReq.Referencenumber = 'Ref456';
        updateReq.Documenttype = 'Invoice';
        updateReq.CustomerDocumentsURL = 'https://example.com/documents2';
        updateReq.UnitWeight = 'Gram';
        updateReq.CustomerProductCategory = 'ValSHIP';
        updateReq.ProductDescription = 'Gold Coin';
        updateReq.AdharUrl = 'https://example.com/aadhar2';
        updateReq.PANUrl = 'https://example.com/pan2';

        Test.startTest();

        // Perform Insert call
        RestRequest reqInsert = new RestRequest();
        RestResponse resInsert = new RestResponse();
        reqInsert.requestURI = '/services/apexrest/CustomerDocuments';
        reqInsert.httpMethod = 'POST';
        reqInsert.requestBody = Blob.valueOf(JSON.serialize(insertList));
        RestContext.request = reqInsert;
        RestContext.response = resInsert;
        String insertResponse = ShipmentRestService.CustomerDocumentAPI();
        System.assert(insertResponse.contains('successfully'), 'Insert failed. Response: ' + insertResponse);

        // Get inserted record Id
        Customer_Documents__c insertedDoc = [
            SELECT Id, Shipment__c, Reference_number__c
            FROM Customer_Documents__c
            WHERE Shipment__c = :shipmentId
            LIMIT 1
        ];
        System.assertEquals('Ref123', insertedDoc.Reference_number__c, 'Insert did not persist data');

        // Update payload with existing record Id
        updateReq.CustomerDocumentId = insertedDoc.Id;
        List<ShipmentRestService.ShipmentRequest> updateList = new List<ShipmentRestService.ShipmentRequest>{updateReq};

        // Perform Update call
        RestRequest reqUpdate = new RestRequest();
        RestResponse resUpdate = new RestResponse();
        reqUpdate.requestURI = '/services/apexrest/CustomerDocuments';
        reqUpdate.httpMethod = 'POST';
        reqUpdate.requestBody = Blob.valueOf(JSON.serialize(updateList));
        RestContext.request = reqUpdate;
        RestContext.response = resUpdate;
        String updateResponse = ShipmentRestService.CustomerDocumentAPI();
        System.assert(updateResponse.contains('successfully'), 'Update failed. Response: ' + updateResponse);

        Test.stopTest();

        // Validate update applied
        Customer_Documents__c updatedDoc = [
            SELECT Id, Total_Net_Weight__c, Invoice_Value__c, Reference_number__c, Document_type__c,
                   Unit_Weight__c, Customer_Product_Category__c, Product_Description__c, Aadhar_Url__c, PAN_Url__c
            FROM Customer_Documents__c
            WHERE Id = :insertedDoc.Id
        ];
        System.assertEquals(300.00, updatedDoc.Total_Net_Weight__c, 'Weight not updated');
        System.assertEquals('Ref456', updatedDoc.Reference_number__c, 'Reference not updated');
    //    System.assertEquals('PackingList', updatedDoc.Document_type__c, 'Document type not updated');
     //   System.assertEquals('Silver Coin', updatedDoc.Product_Description__c, 'Description not updated');
    }

    @isTest
    static void testCustomerDocumentAPI_WithEmptyList() {
        List<ShipmentRestService.ShipmentRequest> emptyList = new List<ShipmentRestService.ShipmentRequest>();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerDocuments';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(emptyList));
        RestContext.request = req;
        RestContext.response = res;

        String response = ShipmentRestService.CustomerDocumentAPI();
        System.assert(response.contains('successfully'), 'Empty list should not error');
    }

    @isTest
    static void testCustomerDocumentAPI_WithInvalidJSON() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CustomerDocuments';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"invalidJson":}');
        RestContext.request = req;
        RestContext.response = res;

        String response = ShipmentRestService.CustomerDocumentAPI();
        System.assert(response.startsWith('Error creating/updating'), 'Invalid JSON should throw error');
    }
}