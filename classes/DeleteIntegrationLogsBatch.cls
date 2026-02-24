global class DeleteIntegrationLogsBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From Integration_Log__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Integration_Log__c> intLogList) {
        if(intLogList.size()>0){
           delete intLogList; 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}