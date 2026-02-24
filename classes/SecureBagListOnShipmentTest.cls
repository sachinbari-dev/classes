@isTest
public class SecureBagListOnShipmentTest {

    @isTest
    static void testUpdateShipmentRecord() {
       
        Shipment__c shipment = new Shipment__c();
       
        insert shipment;

        secure_bag__c secureBag = new secure_bag__c();
        secureBag.Shipment__c = shipment.Id;
      
        insert secureBag;

        
        List<SecureBagListOnShipment.ShipmentIdWrapper> shipmentIds = new List<SecureBagListOnShipment.ShipmentIdWrapper>();
        SecureBagListOnShipment.ShipmentIdWrapper shipmentIdWrapper = new SecureBagListOnShipment.ShipmentIdWrapper();
        shipmentIdWrapper.shipmentId = shipment.Id;
        shipmentIds.add(shipmentIdWrapper);

       
        Test.startTest();
        SecureBagListOnShipment.updateShipmentRecord(shipmentIds);
        Test.stopTest();

       
        shipment = [SELECT Secure_Bags__c FROM Shipment__c WHERE Id = :shipment.Id LIMIT 1];
        
    }
}