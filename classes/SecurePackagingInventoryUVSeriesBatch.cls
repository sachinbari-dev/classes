global class SecurePackagingInventoryUVSeriesBatch  implements Database.Batchable<sObject>,Database.Stateful{
    
    private Integer availableCountThreshold = 10000;
    private String lastRecordName;    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Name FROM Secure_Packaging__c WHERE Name LIKE \'UV%\' AND status__c =\'consumed\' AND shipment__c = Null AND Consumed_in_Universe__c = false AND RecordTypeID=\'0125g0000003dGBAAY\' ORDER BY Name DESC LIMIT 1 ';
     
        system.debug('query@@@'+ query);
        Secure_Packaging__c lastRecord = (Secure_Packaging__c)Database.query(query);
        
        if (lastRecord != null) {
            lastRecordName = lastRecord.Name;
        } 
        
        return Database.getQueryLocator(query);

    }
    
    global void execute(Database.BatchableContext bc, List<Secure_Packaging__c> scope){
       SecurePackagingHandlerUVSeries.createUvShippingLabel(availableCountThreshold, lastRecordName);
          
    }
     global void finish(Database.BatchableContext bc){
            SecurePackagingInventoryUVSeriesBatch2 bt = new SecurePackagingInventoryUVSeriesBatch2();
            id jobId = Database.executeBatch(bt,200);
    }
}