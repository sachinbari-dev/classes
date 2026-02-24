@isTest
private class DeleteQuoteLineTest {
}
    
 /*   @testSetup
    static void setupTestData() {
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        
        List<SBQQ__QuoteLine__c> testRecords = new List<SBQQ__QuoteLine__c>();
        for (Integer i = 0; i < 10; i++) {
            SBQQ__QuoteLine__c quoteLineObj = new SBQQ__QuoteLine__c();
            //quoteLineObj.Max_Discount__c = 70%;
            //orderObj.AccountId = BillingAcc.Id;
            //orderObj.EffectiveDate = System.today();
            //orderObj.Status = 'Draft';

        }
        insert testRecords;
    }

    @isTest
    static void testOrderBatch() {
        Test.startTest();
        DeleteQuoteLineBatch batchClass = new DeleteQuoteLineBatch();
        Database.executeBatch(batchClass);
        
        DeleteQuoteLineScheduler schedulerClass = new DeleteQuoteLineScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}*/