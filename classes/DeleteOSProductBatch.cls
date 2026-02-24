global class DeleteOSProductBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From BVC_CB_OS_Product__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<BVC_CB_OS_Product__c> osProductList) {
        if(osProductList.size()>0){
           delete osProductList; 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}