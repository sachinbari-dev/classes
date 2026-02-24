global class DeleteCustomerDocumentsBatch implements Database.Batchable <sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select Id From Customer_Documents__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List <Customer_Documents__c> shipList) {
        if(shipList.size() > 0) {
            delete shipList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}