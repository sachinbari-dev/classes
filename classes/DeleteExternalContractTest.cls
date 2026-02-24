@isTest
private class DeleteExternalContractTest {
    
    @testSetup
    static void setupTestData() {
        
        /*Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship.Destination_Address_Name__c = ShipperAddress.Id;
        insert Ship;*/
        
        External_Contract__c exContract = new External_Contract__c();
        Insert exContract;
        
        External_Contract_Shipment_Summary__c exConShipObj = new External_Contract_Shipment_Summary__c();
        exConShipObj.External_Contract__c = exContract.Id;
        Insert exConShipObj;
        
        List<External_Contract_Shipment__c> testRecords = new List<External_Contract_Shipment__c>();
        for (Integer i = 0; i < 10; i++) {
            External_Contract_Shipment__c exContractShipmentObj = new External_Contract_Shipment__c();
            exContractShipmentObj.Shipment_Summary__c = exConShipObj.Id;
            testRecords.add(exContractShipmentObj);
        }
        insert testRecords;
    }

    @isTest
    static void testExtrenalContractShipmentBatch() {
        Test.startTest();
        DeleteExternalContractShipmentBatch batchClass = new DeleteExternalContractShipmentBatch();
        Database.executeBatch(batchClass);
        
        DeleteExtrenalContractShipmentScheduler schedulerClass = new DeleteExtrenalContractShipmentScheduler();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}