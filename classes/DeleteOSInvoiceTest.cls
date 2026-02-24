@isTest
private class DeleteOSInvoiceTest {
    
    @testSetup
    static void setupTestData() {
        List<BVC_CB_OS_Invoice__c> testRecords = new List<BVC_CB_OS_Invoice__c>();
        for (Integer i = 0; i < 10; i++) {
            testRecords.add(new BVC_CB_OS_Invoice__c());
        }
        insert testRecords;
    }

    @isTest
    static void testDeleteOSInvoiceBatch() {
        Test.startTest();
        DeleteOSInvoiceBatch batchClass = new DeleteOSInvoiceBatch();
        Database.executeBatch(batchClass);
        
        DeleteOSInvoiceScheduler schedulerClass = new DeleteOSInvoiceScheduler();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}