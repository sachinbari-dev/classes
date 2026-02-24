global class SecurePackagingInventoryBatch implements Database.Batchable<sObject>,Database.Stateful {

    private Integer availableCountThreshold = 10000;
    private String lastRecordName;
    
   
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        // Query the last secure packaging record to get the series name
        
       String query = 'SELECT Name,status__c FROM Secure_Packaging__c WHERE Name LIKE \'DS%\' AND status__c=\'Available\' AND RecordTypeID=\'0125g0000003dGBAAY\' ORDER BY Name DESC LIMIT 1 ';
     //  string query1 = 'select id,name,status__c from secure_packaging__c where status__c =\'Available\'';
        system.debug('query@@@'+ query);
        Secure_Packaging__c lastRecord = (Secure_Packaging__c)Database.query(query);
        
        if (lastRecord != null) {
            lastRecordName = lastRecord.Name;
        } 
        
        return Database.getQueryLocator(query);
        
     }
        global void execute(Database.BatchableContext bc, List<Secure_Packaging__c> scope){
        
            SecurePackagingHandler.createShippingLabel( availableCountThreshold, lastRecordName);
        }
    
        global void finish(Database.BatchableContext bc){
            
            SecurePackagingInventoryBatch2 bt = new SecurePackagingInventoryBatch2();
            id jobId = Database.executeBatch(bt,200);
    }
}