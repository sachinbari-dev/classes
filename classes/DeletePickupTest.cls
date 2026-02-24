@isTest
private class DeletePickupTest {
    
    @testSetup
    static void setupTestData() {
        List<Pickup__c> testRecords = new List<Pickup__c>();
        for (Integer i = 0; i < 10; i++) {
            Pickup__c pickUp = new Pickup__c(
                CreatedDate = Date.newInstance(2022, 11, 01).addDays(-i)
                );
            testRecords.add(pickUp);
        }
        insert testRecords;
    }

    @isTest
    static void testPickupBatch() {
        Test.startTest();
        DeletePickupBatch batchClass = new DeletePickupBatch();
        Database.executeBatch(batchClass);
        
        DeletePickupScheduler schedulerClass = new DeletePickupScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}