global class DeleteSecureBagBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From Secure_Bag__c WHERE CreatedDate < 2022-11-01T00:00:00Z';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Secure_Bag__c> secureBagList) {
        if(secureBagList.size()>0){
           Database.delete(secureBagList,false); 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}