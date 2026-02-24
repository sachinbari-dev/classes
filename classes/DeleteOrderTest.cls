@isTest
private class DeleteOrderTest {
    
    @testSetup
    static void setupTestData() {
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        
        List<Order> testRecords = new List<Order>();
        for (Integer i = 0; i < 10; i++) {
            Order orderObj = new Order();
            orderObj.AccountId = BillingAcc.Id;
            orderObj.EffectiveDate = System.today();
            orderObj.Status = 'Draft';
            testRecords.add(orderObj);
        }
        insert testRecords;
    }

    @isTest
    static void testOrderBatch() {
        Test.startTest();
        DeleteOrderBatch batchClass = new DeleteOrderBatch();
        Database.executeBatch(batchClass);
        
        DeleteOrderScheduler schedulerClass = new DeleteOrderScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}