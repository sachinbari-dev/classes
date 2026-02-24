@isTest
private class DeleteCustomerDocumentsTest {
    
    @testSetup
    static void setupTestData() {
        List<Shipment__c> testShipmentRecords = new List<Shipment__c>();
        for (Integer i = 0; i < 10; i++) {
            testShipmentRecords.add(new Shipment__c());
        }
        insert testShipmentRecords;
        
        List<Customer_Documents__c> testRecords = new List<Customer_Documents__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new Customer_Documents__c(
            Total_Net_Weight__c = 101.50,
            Shipment__c = testShipmentRecords[i].Id
            ));
        }
        insert testRecords;
    }

    @isTest
    static void testShipmentBatch() {
        Test.startTest();
        DeleteCustomerDocumentsBatch batchClass = new DeleteCustomerDocumentsBatch();
        Database.executeBatch(batchClass);
        
        DeleteCustomerDocumentsSchedular schedulerClass = new DeleteCustomerDocumentsSchedular();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}