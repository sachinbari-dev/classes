global class DeleteIntegrationLogsSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        DeleteIntegrationLogsBatch batchClass = new DeleteIntegrationLogsBatch();
        Database.executeBatch(batchClass,2000);
        
    }
    
}