@isTest
private class DeleteSecurePackagingTest {
    
    @testSetup
    static void setupTestData() {
        List<Secure_Packaging__c> testRecords = new List<Secure_Packaging__c>();
        for (Integer i = 0; i < 10; i++) {
            Secure_Packaging__c securePackaging = new Secure_Packaging__c(
                Name = 'Test Secure Packaging ' + i,
                CreatedDate = Date.newInstance(2022, 11, 01).addDays(-i),
                LastModifiedDate = Date.newInstance(2023, 10, 20).addDays(-i),
                Status__c = 'Consumed'
            );

            testRecords.add(securePackaging);
        }
        insert testRecords;
    }

    @isTest
    static void testSecurePackagingBatch() {
        Test.startTest();
        DeleteSecurePackagingBatch batchClass = new DeleteSecurePackagingBatch();
        Database.executeBatch(batchClass);
        
        DeleteSecurePackagingScheduler schedulerClass = new DeleteSecurePackagingScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}