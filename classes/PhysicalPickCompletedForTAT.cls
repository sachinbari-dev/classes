// Created by Rafi Khan for TAT.
public class PhysicalPickCompletedForTAT {
    public static void updateShipmentPhysicalCompletedTime(List<Pickup__c> pickupList) {
        System.debug('Inside PhysicalPickCompletedForTAT');

        Set<Id> pickupIdsToUpdate = new Set<Id>();
        for (Pickup__c pickup : pickupList) {
            pickupIdsToUpdate.add(pickup.Id);
        }
        
        //UpdateShipmentPhysicalTimeBatch batchJob = new UpdateShipmentPhysicalTimeBatch(pickupIdsToUpdate);
        //Database.executeBatch(batchJob, 20);
        
        System.enqueueJob(new UpdateShipmentPhysicalTimeQueueable(pickupIdsToUpdate));

        /*List<Shipment__c> allShipments = [
            SELECT Id, Physical_Pickup_Completed_Time1__c, Pickup__c
            FROM Shipment__c 
            WHERE Pickup__c IN :pickupIdsToUpdate
        ];

        System.debug('Total shipments found = ' + allShipments.size());

        DateTime now = System.now();
        Integer batchSize = 10;
        List<List<Shipment__c>> shipmentBatches = new List<List<Shipment__c>>();
        List<Shipment__c> currentBatch = new List<Shipment__c>();

        for (Shipment__c ship : allShipments) {
            ship.Physical_Pickup_Completed_Time1__c = now;
            currentBatch.add(ship);

            if (currentBatch.size() == batchSize) {
                shipmentBatches.add(new List<Shipment__c>(currentBatch));
                currentBatch.clear();
            }
        }

        // Add remaining records (if any)
        if (!currentBatch.isEmpty()) {
            shipmentBatches.add(currentBatch);
        }

        // Perform updates outside loop
        for (List<Shipment__c> batch : shipmentBatches) {
            try {
                update batch;
                System.debug('Updated batch of size: ' + batch.size());
            } catch (Exception e) {
                System.debug('Error updating batch: ' + e.getMessage());
            }
        }*/
    }
}