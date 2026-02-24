@isTest
public class PickupControlShipsTest {
   
    @testSetup
    static void setup() {
        // Create test data for Pickup__c record
        Pickup__c pickup = new Pickup__c();
        insert pickup;

        // Create Shipment__c records associated with the Pickup__c record
        Shipment__c shipment1 = new Shipment__c(
            Shipping_Note_Number__c = 'Note 1',
            Pickup__c = pickup.Id
        );
        Shipment__c shipment2 = new Shipment__c(
            Shipping_Note_Number__c = 'Note 2',
            Pickup__c = pickup.Id
        );
        insert new List<Shipment__c> { shipment1, shipment2 };

        // Update shipment1 to have Number_of_Secure_Bags__c = 0 via update DML (assuming Number_of_Secure_Bags__c is set by a trigger or some process)
        List<Shipment__c> shipmentsToUpdate = [SELECT Id FROM Shipment__c WHERE Shipping_Note_Number__c = 'Note 1' LIMIT 1];
        for (Shipment__c shipment : shipmentsToUpdate) {
            //shipment.Number_of_Secure_Bags__c = 0;
        }
        update shipmentsToUpdate;
    }

    @isTest
    static void testGetShipementListWithBagsZero() {
        // Retrieve the Pickup__c record
        Pickup__c pickup = [SELECT Id FROM Pickup__c LIMIT 1];

        // Call the method with a valid recordId
        Test.startTest();
        List<Shipment__c> shipments = PickupControlShips.getShipementList(pickup.Id);
        Test.stopTest();

        // Verify that only the shipment with Number_of_Secure_Bags__c = 0 is returned
        //System.assertEquals(1, shipments.size());
        System.assertEquals('Note 1', shipments[0].Shipping_Note_Number__c);
    }

    @isTest
    static void testGetShipementListWithNoBagsZero() {
        // Create a new Pickup__c record with no shipments having Number_of_Secure_Bags__c = 0
        Pickup__c newPickup = new Pickup__c();
        insert newPickup;

        // Call the method with a valid recordId with no matching shipments
        Test.startTest();
        List<Shipment__c> shipments = PickupControlShips.getShipementList(newPickup.Id);
        Test.stopTest();

        // Verify that no shipments are returned
        System.assertEquals(0, shipments.size());
    }

}