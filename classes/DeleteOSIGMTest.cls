@isTest
private class DeleteOSIGMTest {
    
    @testSetup
    static void setupTestData() {
        List<BVC_CB_OS_IGM__c> testRecords = new List<BVC_CB_OS_IGM__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new BVC_CB_OS_IGM__c());
        }
        insert testRecords;
    }

    @isTest
    static void testDeleteOSIGMBatch() {
        Test.startTest();
        DeleteOSIGMBatch batchClass = new DeleteOSIGMBatch();
        Database.executeBatch(batchClass);
        
        DeleteOSIGMScheduler schedulerClass = new DeleteOSIGMScheduler();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}