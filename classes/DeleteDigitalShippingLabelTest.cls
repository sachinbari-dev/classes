@isTest
private class DeleteDigitalShippingLabelTest {
    
    @testSetup
    static void setupTestData() {
        List<Digital_Shipping_Label__c> testRecords = new List<Digital_Shipping_Label__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new Digital_Shipping_Label__c());
        }
        insert testRecords;
    }

    @isTest
    static void testDigitalShippingLabelBatch() {
        Test.startTest();
        DeleteDigitalShippingLabelBatch batchClass = new DeleteDigitalShippingLabelBatch();
        Database.executeBatch(batchClass);
        
        DeleteDigitalShippingLabelScheduler schedulerClass = new DeleteDigitalShippingLabelScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}