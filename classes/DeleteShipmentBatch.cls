global class DeleteShipmentBatch implements Database.Batchable <sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select Id From Shipment__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List <Shipment__c> shipList) {
        if(shipList.size() > 0) {
            delete shipList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}