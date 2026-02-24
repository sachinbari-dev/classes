@isTest
private class DeleteTaskTest {
    
    @testSetup
    static void setupTestData() {
        List<Task> testRecords = new List<Task>();
        for (Integer i = 0; i < 5; i++) {
            Task taskObj = new Task(
                Subject = 'Test Task ' + i,
                CreatedDate = Date.newInstance(2023, 5, 30).addDays(-i)
            );
            testRecords.add(taskObj);
        }
        insert testRecords;
    }

    @isTest
    static void testTaskBatch() {
        Test.startTest();
        DeleteTaskBatch batchClass = new DeleteTaskBatch();
        Database.executeBatch(batchClass);
        
        DeleteTaskScheduler schedulerClass = new DeleteTaskScheduler();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}