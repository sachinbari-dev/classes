global class DeleteACRConsumptionBatch implements Database.Batchable <sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id From ST_ACR_Consumption__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<ST_ACR_Consumption__c> acrConsumptionList) {
        if(acrConsumptionList.size() > 0){
            delete acrConsumptionList;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}