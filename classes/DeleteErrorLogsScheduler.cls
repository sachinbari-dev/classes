global class DeleteErrorLogsScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        DeleteErrorLogsBatch batchClass = new DeleteErrorLogsBatch();
        Database.executeBatch(batchClass,2000);
        
    }
    
}