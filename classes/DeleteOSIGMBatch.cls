global class DeleteOSIGMBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From BVC_CB_OS_IGM__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<BVC_CB_OS_IGM__c> osIGMList) {
        if(osIGMList.size()>0){
           delete osIGMList; 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}