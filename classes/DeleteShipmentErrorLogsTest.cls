@isTest
private class DeleteShipmentErrorLogsTest {
    
    @testSetup
    static void setupTestData() {
        List<Shipment_Error_Log__c> testRecords = new List<Shipment_Error_Log__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new Shipment_Error_Log__c());
        }
        insert testRecords;
    }

    @isTest
    static void testDeleteOSProductBatch() {
        Test.startTest();
        DeleteShipmentErrorLogsBatch batchClass = new DeleteShipmentErrorLogsBatch();
        Database.executeBatch(batchClass);
        
        DeleteShipmentErrorLogsScheduler schedulerClass = new DeleteShipmentErrorLogsScheduler();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}