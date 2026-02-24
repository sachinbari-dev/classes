global class DeleteSecurePackagingBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From Secure_Packaging__c WHERE CreatedDate < 2022-11-01T00:00:00Z And Status__c = \'Consumed\' And LastModifiedDate < 2023-10-21T00:00:00Z';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Secure_Packaging__c> securePackagingList) {
        if(securePackagingList.size()>0){
           delete securePackagingList; 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}