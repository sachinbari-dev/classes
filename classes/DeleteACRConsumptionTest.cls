@isTest
private class DeleteACRConsumptionTest {
    
    @testSetup
    static void setupTestData() {
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        
        Contract contractObj = new Contract();
        contractObj.AccountId = BillingAcc.Id;
        contractObj.Status = 'Draft';
		Insert contractObj;
        
        List<ST_ACR_Consumption__c> testRecords = new List<ST_ACR_Consumption__c>();
        for (Integer i = 0; i < 10; i++) {
            ST_ACR_Consumption__c acrConsumptionObj = new ST_ACR_Consumption__c();
            acrConsumptionObj.Customer_Account__c = BillingAcc.Id;
            acrConsumptionObj.Contract__c = contractObj.Id;
            testRecords.add(acrConsumptionObj);
        }
        insert testRecords;
    }

    @isTest
    static void testACRConsumptionBatch() {
        Test.startTest();
        DeleteACRConsumptionBatch batchClass = new DeleteACRConsumptionBatch();
        Database.executeBatch(batchClass);
        
        DeleteACRConsumptionScheduler schedulerClass = new DeleteACRConsumptionScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}