@isTest
private class DeleteShipmentTest {
    
    @testSetup
    static void setupTestData() {
        List<Shipment__c> testRecords = new List<Shipment__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new Shipment__c());
        }
        insert testRecords;
    }

    @isTest
    static void testShipmentBatch() {
        Test.startTest();
        DeleteShipmentBatch batchClass = new DeleteShipmentBatch();
        Database.executeBatch(batchClass);
        
        DeleteShipmentScheduler schedulerClass = new DeleteShipmentScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}