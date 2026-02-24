global class DeletePickupBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From Pickup__c WHERE CreatedDate < 2022-11-01T00:00:00Z';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Pickup__c> pickupList) {
        if(pickupList.size()>0){
           delete pickupList; 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}