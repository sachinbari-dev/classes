@isTest
public class DeleteTrackingTest {
    
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
        
        List<Shipment_Tracking__c> testRecords = new List<Shipment_Tracking__c>();
        for (Integer i = 0; i < 10; i++) {
            Shipment_Tracking__c shipmentTracking = new Shipment_Tracking__c();
            shipmentTracking.Shipment__c = Ship.Id;
            shipmentTracking.createdDate = Date.newInstance(2022, 11, 01).addDays(-i);
            testRecords.add(shipmentTracking);
        }
        insert testRecords;
    }

    @isTest
    static void testDeleteTrackingBatch() {
        
        Test.startTest();
        DeleteTrackingBatch batchClass = new DeleteTrackingBatch();
        Database.executeBatch(batchClass);
        
        DeleteTrackingScheduler schedulerClass = new DeleteTrackingScheduler();
        String jobId = System.schedule('DeleteIntegrationLogsTestJob', '0 0 1 * * ?', schedulerClass);
        Test.stopTest();

    }
    
}