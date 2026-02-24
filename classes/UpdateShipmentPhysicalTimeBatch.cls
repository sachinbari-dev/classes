public class UpdateShipmentPhysicalTimeBatch implements Database.Batchable<SObject> {

    private Set<Id> pickupIds;

    public UpdateShipmentPhysicalTimeBatch(Set<Id> pickupIds) {
        this.pickupIds = pickupIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Pickup__c, Physical_Pickup_Completed_Time1__c
            FROM Shipment__c
            WHERE Pickup__c IN :pickupIds
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Shipment__c> scope) {
        ShipmentTriggerExecutionLogicControl.skipHeavyLogic = true;
        DateTime now = System.now();
        List<Shipment__c> shipments = (List<Shipment__c>)scope;

        for (Shipment__c ship : shipments) {
            ship.Physical_Pickup_Completed_Time1__c = now;
        }

        try {
            update shipments;
        } catch (Exception e) {
            System.debug('Update failed: ' + e.getMessage());
        }
        
        ShipmentTriggerExecutionLogicControl.skipHeavyLogic = false;
    }

    public void finish(Database.BatchableContext bc) {
        // Optional post-processing
    }
}