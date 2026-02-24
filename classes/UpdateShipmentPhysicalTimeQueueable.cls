public class UpdateShipmentPhysicalTimeQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> pickupIds;

    public UpdateShipmentPhysicalTimeQueueable(Set<Id> pickupIds) {
        this.pickupIds = pickupIds;
    }

    public void execute(QueueableContext context) {
        /*UpdateShipmentPhysicalTimeBatch batchJob = new UpdateShipmentPhysicalTimeBatch(pickupIds);
        Database.executeBatch(batchJob, 50);*/
        List<Shipment__c> shipmentsToUpdate = [
            SELECT Id, Name, Origin_Hub__r.Name, Destination_Hub__r.Name, Shipping_Note_Number__c, Origin_Address_City__c,Pickup__r.Physical_Pickup_Completed_Time__c,
                                            Physical_Pickup_Completed_Time1__c, Pickup__c, Origin_Address_Name__r.Active_Pincode__c, Origin_Address_Name__r.Active_Pincode__r.Name,
                                            Destination_Address_City__c, Destination_Address_Name__r.Active_Pincode__c,Destination_Address_Name__r.Active_Pincode__r.Name, 
                                            Destination_Address_Pincode__c, Origin_Address_Pincode__c, Destination_Address_Name__r.Active_Pincode__r.City__c,Tracking_Status__c,
                                            Destination_Address_Name__r.Active_Pincode__r.Sunday__c, Destination_Address_Name__r.Active_Pincode__r.Monday__c, 
                                            Destination_Address_Name__r.Active_Pincode__r.Tuesday__c, Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                                            Origin_Address_Name__r.STATE__c,Destination_Address_Name__r.STATE__c,holiday_sunday_charges1__c,
                                            Destination_Address_Name__r.Active_Pincode__r.Thursday__c, Destination_Address_Name__r.Active_Pincode__r.Friday__c, 
                                            Destination_Address_Name__r.Active_Pincode__r.Saturday__c, Destination_Hub__r.Branch__c, Origin_Hub__r.Branch__c,Destination_Address_State__c
                                            FROM Shipment__c WHERE Pickup__c IN :pickupIds];

        DateTime now = System.now();

        for (Shipment__c ship : shipmentsToUpdate) {
            ship.Physical_Pickup_Completed_Time1__c = now;
        }

        Integer batchSize = 20;
        List<Shipment__c> batch = new List<Shipment__c>();

        for (Integer i = 0; i < shipmentsToUpdate.size(); i++) {
            batch.add(shipmentsToUpdate[i]);

            if (batch.size() == batchSize || i == shipmentsToUpdate.size() - 1) {
                try {
                    update batch;
                } catch (Exception e) {
                    System.debug('for checking error message = ' + e.getMessage());
                    System.debug('for checking error on line numer = ' + e.getLineNumber());
                }
                batch.clear();
            }
        }
        
        
         if(shipmentsToUpdate.size()>0){
            SLACalculatorHandlerBatch batch1 = new SLACalculatorHandlerBatch(shipmentsToUpdate);
            Database.executeBatch(batch1, 100); // 10 is the batch size  
        }
        
    }
    
   
}