// This is a one time activity to update the shipment field values which are newly created
// The values are updated from the recent related ACR consumption records as suggested from Bussiness


public class UpdateShipmentFieldsBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext context) {
			return Database.getQueryLocator('SELECT Id, (SELECT Id, Freight_Charges__c, Holiday_Charges__c, Liability_Charges__c, Offline_Charges__c, BVC_Valuation_Charges__c, Weight_Charges__c, Total_Charge__c FROM ACR_Consumption__r WHERE Shipment__c != null AND IsContract_Active_on_Account__c = true) FROM Shipment__c WHERE LastModifiedBy.name != \'Dinesh Gantla\' Limit 100000');

    }

    public void execute(Database.BatchableContext context, List<Shipment__c> shipments) {
        List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();

        for (Shipment__c shipment : shipments) {
            if (shipment.ACR_Consumption__r.size() > 0) {
                ST_ACR_Consumption__c mostRecentConsumption = getMostRecentConsumption(shipment.ACR_Consumption__r);

                // Update Shipment__c fields with values from the most recent ST_ACR_Consumption__c
                shipment.Freight_Charges__c = mostRecentConsumption.Freight_Charges__c;
                shipment.Holiday_Charges__c = mostRecentConsumption.Holiday_Charges__c;
                shipment.Liability_Charges__c = mostRecentConsumption.Liability_Charges__c;
                shipment.Offline_Charges__c = mostRecentConsumption.Offline_Charges__c;
                shipment.Valuation_Charges__c = mostRecentConsumption.BVC_Valuation_Charges__c;
                shipment.Weight_Charges__c = mostRecentConsumption.Weight_Charges__c;
                shipment.Total_Charge__c = mostRecentConsumption.Total_Charge__c;

                shipmentsToUpdate.add(shipment);
            }
        }

        // Update the Shipment__c records
        update shipmentsToUpdate;
    }

    private ST_ACR_Consumption__c getMostRecentConsumption(List<ST_ACR_Consumption__c> consumptions) {
        consumptions.sort(); // Assuming ST_ACR_Consumption__c has a Date field indicating when it was created
        return consumptions[0];
    }

    public void finish(Database.BatchableContext context) {
        // Send email notification that the batch has completed
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'dgantla@cloudely.com'});
        email.setSubject('Batch Process Completed');
        email.setPlainTextBody('The batch process to update Shipment fields has completed successfully.');
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }
}