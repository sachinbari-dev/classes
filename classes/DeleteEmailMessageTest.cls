@isTest
public class DeleteEmailMessageTest {
    
    @testSetup
    static void setupTestData() {
        
        List<EmailMessage> testRecords = new List<EmailMessage>();
        for (Integer i = 0; i < 10; i++) {
            EmailMessage emailMessageObj = new EmailMessage (
                Subject = 'Test email ' + i,
                CreatedDate = Date.newInstance(2023, 5, 30).addDays(-i)
            );
            testRecords.add(emailMessageObj);
        }
        insert testRecords;
    }

    @isTest
    static void testDeleteEmailMessageBatch() {
        
        Test.startTest();
        DeleteEmailMessageBatch batchClass = new DeleteEmailMessageBatch();
        Database.executeBatch(batchClass);
        
        DeleteEmailMessageScheduler schedulerClass = new DeleteEmailMessageScheduler();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}