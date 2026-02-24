@isTest
private class DeleteDeliveryTest {
    
    @testSetup
    static void setupTestData() {
        List<Delivery__c> testRecords = new List<Delivery__c>();
        for (Integer i = 0; i < 10; i++) {
            Delivery__c deObj = new Delivery__c(
            createdDate = Date.newInstance(2022, 11, 01).addDays(-i)
                );
            testRecords.add(deObj);
        }
        insert testRecords;
    }

    @isTest
    static void testDeliveryBatch() {
        Test.startTest();
        DeleteDeliveryBatch batchClass = new DeleteDeliveryBatch();
        Database.executeBatch(batchClass);
        
        DeleteDeliveryScheduler schedulerClass = new DeleteDeliveryScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}