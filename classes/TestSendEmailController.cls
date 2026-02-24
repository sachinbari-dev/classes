@isTest
private class TestSendEmailController {
    @isTest
    static void testSendShipmentPDFs() {
        List<Pickup__c> pickups = new List<Pickup__c>();
        List<Shipment__c> shipments = new List<Shipment__c>();
        for (Integer i = 0; i < 3; i++) {
            pickups.add(new Pickup__c(Shipper_Email__c = 'test' + i + '@example.com'));
            shipments.add(new Shipment__c());
        }
        insert pickups;
        insert shipments;
        List<Pickup__c> pickupsWithShipments = [SELECT Id FROM Pickup__c WHERE Id IN :pickups];
        List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();
        for (Integer i = 0; i < pickupsWithShipments.size(); i++) {
            shipments[i].Pickup__c = pickupsWithShipments[i].Id;
            shipmentsToUpdate.add(shipments[i]);
        }
        update shipmentsToUpdate;
        
        Shipment__c shipmentWithDSN = new Shipment__c(Pickup__c = pickupsWithShipments[0].Id, DSN__c = true);
        insert shipmentWithDSN;
        List<SendEmailController.EmailInputWrapper> inputList = new List<SendEmailController.EmailInputWrapper>();
        for (Pickup__c pickup : pickups) {
            SendEmailController.EmailInputWrapper input = new SendEmailController.EmailInputWrapper();
            input.pickupId = pickup.Id;
            inputList.add(input);
        }
        Test.startTest();
        SendEmailController.sendShipmentPDFs(inputList);
        Test.stopTest();
    
    }
}