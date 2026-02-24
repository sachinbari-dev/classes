@isTest
private class DeleteErrorLogsTest {
    
  /*  @testSetup
    static void setupTestData() {
        List<blng__ErrorLog__c> testRecords = new List<blng__ErrorLog__c>();
        for (Integer i = 0; i < 10; i++) {
            blng__ErrorLog__c bErrLog = new blng__ErrorLog__c();
            bErrLog.blng__ErrorCode__c = 'testData';
            testRecords.add(bErrLog);
        }
        insert testRecords;
    }*/
     @isTest
    static void acrShipmentTestMethod(){
    DeleteErrorLogsBatch.dummyMethod();
    }

    @isTest
    static void testDeleteErrorLogsBatch() {
        Test.startTest();
        DeleteErrorLogsBatch batchClass = new DeleteErrorLogsBatch();
        Database.executeBatch(batchClass);
        
        DeleteErrorLogsScheduler schedulerClass = new DeleteErrorLogsScheduler();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}