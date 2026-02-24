@isTest
private class DeleteIntegrationLogsBatchTest {
    
    @testSetup
    static void setupTestData() {
        List<Integration_Log__c> testRecords = new List<Integration_Log__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new Integration_Log__c());
        }
        insert testRecords;
    }

    @isTest
    static void testDeleteIntegrationLogsBatch() {
        Test.startTest();
        DeleteIntegrationLogsBatch batchClass = new DeleteIntegrationLogsBatch();
        Database.executeBatch(batchClass);
        
        DeleteIntegrationLogsSchedulable schedulerClass = new DeleteIntegrationLogsSchedulable();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}