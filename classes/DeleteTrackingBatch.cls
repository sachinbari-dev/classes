global class DeleteTrackingBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id From Shipment_Tracking__c WHERE CreatedDate < 2022-11-01T00:00:00Z';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<Shipment_Tracking__c> shipTrackingList){
        if(shipTrackingList.size() >0){
            delete shipTrackingList;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}