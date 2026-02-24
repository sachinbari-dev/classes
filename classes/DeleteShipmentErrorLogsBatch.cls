global class DeleteShipmentErrorLogsBatch implements Database.Batchable <sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select Id From Shipment_Error_Log__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List <Shipment_Error_Log__c> shipErrorLogsList) {
        if(shipErrorLogsList.size() > 0) {
            delete shipErrorLogsList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}