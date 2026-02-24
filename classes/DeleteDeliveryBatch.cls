global class DeleteDeliveryBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From Delivery__c WHERE CreatedDate < 2022-11-01T00:00:00Z';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Delivery__c> deliveryList) {
        if(deliveryList.size()>0){
           delete deliveryList; 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}