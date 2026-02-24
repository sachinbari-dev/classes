@isTest
private class DeleteOSProductTest {
    
    @testSetup
    static void setupTestData() {
        List<BVC_CB_OS_Product__c> testRecords = new List<BVC_CB_OS_Product__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new BVC_CB_OS_Product__c());
        }
        insert testRecords;
    }

    @isTest
    static void testDeleteOSProductBatch() {
        Test.startTest();
        DeleteOSProductBatch batchClass = new DeleteOSProductBatch();
        Database.executeBatch(batchClass);
        
        DeleteOSProductScheduler schedulerClass = new DeleteOSProductScheduler();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}