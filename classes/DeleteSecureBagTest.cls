@isTest
private class DeleteSecureBagTest {
    
    @testSetup
    static void setupTestData() {
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship.Destination_Address_Name__c = ShipperAddress.Id;
        insert Ship;

        Test.setMock(HttpCalloutMock.class, new TSM_SignatureHelper_Mock());
        
        List<Secure_Bag__c> testRecords = new List<Secure_Bag__c>();
        for (Integer i = 0; i < 10; i++) {
            Secure_Bag__c sbObj = new Secure_Bag__c();
            sbObj.Shipment__c = Ship.Id;
            sbObj.createdDate = Date.newInstance(2022, 11, 01).addDays(-i);
            testRecords.add(sbObj);
        }
        insert testRecords;
    }

    @isTest
    static void testSecureBagBatch() {
        Test.startTest();
        DeleteSecureBagBatch batchClass = new DeleteSecureBagBatch();
        Database.executeBatch(batchClass);
        
        DeleteSecureBagScheduler schedulerClass = new DeleteSecureBagScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}