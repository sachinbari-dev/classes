public class SubrogationShipmentBatch implements Database.Batchable<SObject> {
    public Set<Id> customerIds;
    public Integer totalUpdatedCount = 0;

    public SubrogationShipmentBatch(Set<Id> customerIds) {
     //   this.customerIds = customerIds;--- Commented becuse of thiserror===	First error: Update failed. First exception on row 0 with id a2p0T0000002Gl5QAE; 
     //                                                                         first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Billing verification failed. Either the Shipper or
     //                                                                          Consignee must be associated with the Billing Customer:
     // Sanket suggested to stop because some records are failing and this batch is running in the loop
     // solutution-- make stop this batch running in loop if records fail
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (customerIds == null || customerIds.isEmpty()) {
            return Database.getQueryLocator([SELECT Id FROM Shipment__c WHERE Id = null]);
        }

        return Database.getQueryLocator([
            SELECT Id, Subrogation_letter_available__c 
            FROM Shipment__c 
            WHERE Customer__c IN :customerIds
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        updateShipments(scope);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Total Shipments Updated: ' + totalUpdatedCount);
    }

    
    public void updateShipments(List<SObject> scope) {
        List<Shipment__c> toUpdate = new List<Shipment__c>();
        Integer updatedCount = 0;

        for (SObject obj : scope) {
            Shipment__c shipment = (Shipment__c) obj;
            shipment.Subrogation_letter_available__c = true;
            toUpdate.add(shipment);
            updatedCount++;
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }

        totalUpdatedCount += updatedCount;
        
        
        
    }
}