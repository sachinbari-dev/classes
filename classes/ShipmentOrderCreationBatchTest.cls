@isTest
public class ShipmentOrderCreationBatchTest {
    
    @testSetup
    static void setupTestData() {
        
        Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, false);
        Ship2.Created_Through_BVCContract__c=true;
        Ship2.Status__c = 'Verified For Billing';
        Insert Ship2;
        List<Shipment__c> shipments = new List<Shipment__c>();
        
        shipments.add(Ship1);
        shipments.add(Ship2);
    }

    @isTest
    static void testShipmentOrderCreationBatch() {
       /* Set<Id> shipmentIds = new Set<Id>();
        for (Shipment__c shipment : [SELECT Id FROM Shipment__c WHERE Status__c = 'Verified For Billing']) {
            
            shipmentIds.add(shipment.Id);
        }*/
        
        Shipment__c ship = [SELECT Id, Created_Through_BVCContract__c 
                            FROM Shipment__c 
                            WHERE Status__c = 'Verified For Billing' 
                            LIMIT 1];
        
        ship.Created_Through_BVCContract__c = true;
        update ship;
        
        Set<Id> shipmentIds = new Set<Id>{ ship.Id };
        
        ShipmentOrderCreationBatch batch = new ShipmentOrderCreationBatch(shipmentIds);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ShipmentOrderCreationBatchMock());
        
        Database.executeBatch(batch);
        
        ShipmentOrderCreationBatch.dummyMethod();

        Test.stopTest();

        
    }
    
    private class ShipmentOrderCreationBatchMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true}');
            return res;
        }
    }
}