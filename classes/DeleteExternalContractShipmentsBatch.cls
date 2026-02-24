global class DeleteExternalContractShipmentsBatch implements Database.Batchable <sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select Id From External_Contract_Shipment__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List <External_Contract_Shipment__c> shipList) {
        if(shipList.size() > 0) {
            delete shipList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}