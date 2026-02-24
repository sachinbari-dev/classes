// OPTIMIZED: New Queueable class to replace scheduler + batch pattern
// Consolidates async execution for multiple shipments in a single job
// Replaces: SLACalculatorHandlerBatchSchedular.cls (no longer needed)
public class SLACalculatorQueueable implements Queueable {
    private List<String> shipmentIds;

    public SLACalculatorQueueable(List<String> shipmentIds) {
        this.shipmentIds = shipmentIds;
    }

    public void execute(QueueableContext context) {
        try {
            // OPTIMIZED: Query all shipments with required fields once
            // Reduces multiple queries that would happen if each pickup had its own scheduler
            List<Shipment__c> shipmentsToProcess = [
                SELECT Id, Name, Origin_Hub__r.Name, Destination_Hub__r.Name, Shipping_Note_Number__c,
                    Origin_Address_City__c, Pickup__r.Physical_Pickup_Completed_Time__c,
                    Pickup__r.Pickup_Status__c, Estimated_Delivery_Date__c, SLA_Days_and_Hours__c,
                    Physical_Pickup_Completed_Time1__c, Pickup__c,
                    Origin_Address_Name__r.Active_Pincode__c, Origin_Address_Name__r.Active_Pincode__r.Name,
                    Destination_Address_City__c,
                    Destination_Address_Name__r.Active_Pincode__c, Destination_Address_Name__r.Active_Pincode__r.Name,
                    Destination_Address_Pincode__c, Origin_Address_Pincode__c,
                    Destination_Address_Name__r.Active_Pincode__r.City__c, Tracking_Status__c,
                    Destination_Address_Name__r.Active_Pincode__r.Sunday__c,
                    Destination_Address_Name__r.Active_Pincode__r.Monday__c,
                    Destination_Address_Name__r.Active_Pincode__r.Tuesday__c,
                    Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                    Origin_Address_Name__r.STATE__c, Destination_Address_Name__r.STATE__c,
                    holiday_sunday_charges1__c, Origin_Address_State__c,
                    Destination_Address_Name__r.Active_Pincode__r.Thursday__c,
                    Destination_Address_Name__r.Active_Pincode__r.Friday__c,
                    Destination_Address_Name__r.Active_Pincode__r.Saturday__c,
                    Destination_Hub__r.Branch__c, Origin_Hub__r.Branch__c, Destination_Address_State__c
                FROM Shipment__c
                WHERE Id IN :shipmentIds
                

            ];
            
/*for(Shipment__c s : shipmentsToProcess){
    s.Physical_Pickup_Completed_Time1__c =
        s.Pickup__r.Physical_Pickup_Completed_Time__c;
}
update shipmentsToProcess;*/
        



            if(shipmentsToProcess.size() > 0) {
                // OPTIMIZED: Execute batch with optimal batch size (50)
                // Batch will load reference data once in start() method
                SLACalculatorHandlerBatch batch = new SLACalculatorHandlerBatch(shipmentsToProcess);
                Database.executeBatch(batch, 50);
            }
        } catch(Exception e) {
            Apex_Error_Log__c AEL = new Apex_Error_Log__c(
                Class_Name__c = 'SLACalculatorQueueable',
                Error__c = e.getMessage()
            );
            insert AEL;
        }
    }
}