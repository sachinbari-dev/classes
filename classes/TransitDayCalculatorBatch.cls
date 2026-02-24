global class TransitDayCalculatorBatch implements Database.Batchable<SObject>, Database.Stateful {

     global Integer batchSize;
    global TransitDayCalculatorBatch(Integer batchSize) {
        this.batchSize = batchSize != null ? batchSize : 200; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [SELECT Id, Pickup__c,Pickup__r.pickup_Date__c,Pickup__r.Physical_Pickup_Completed_Time__c, Origin_Hub__c, Destination_Hub__c,
                    Actual_Delivery_Date_and_Time__c,Tracking_Status__c,CreatedDate, 
                    Transit_Day_Bucket__c
             FROM Shipment__c
             WHERE Actual_Delivery_Date_and_Time__c != null
                   AND Tracking_Status__c = 'Delivered'
                   AND Pickup__r.Physical_Pickup_Completed_Time__c != null
                   AND Transit_Day_Bucket__c = null
                  AND CreatedDate = LAST_N_DAYS:13]);
    }
    global void execute(Database.BatchableContext BC, List<Shipment__c> scope) {
        TransitDayCalculator.calculateAndUpdateBuckets(scope);
        
    }

    global void finish(Database.BatchableContext BC) {
 
    }
}