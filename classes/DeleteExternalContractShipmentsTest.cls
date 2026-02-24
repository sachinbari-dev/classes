@isTest
private class DeleteExternalContractShipmentsTest {
    
    @testSetup
    static void setupTestData() {
        
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
    static void testShipmentBatch() {
        Test.startTest();
        DeleteExternalContractShipmentsBatch batchClass = new DeleteExternalContractShipmentsBatch();
        Database.executeBatch(batchClass);
        
        DeleteExternalContractShipmentsSchedular schedulerClass = new DeleteExternalContractShipmentsSchedular();
        String jobId = System.schedule('DeleteTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}