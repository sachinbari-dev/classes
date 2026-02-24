global class DeleteShipmentErrorLogsScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        DeleteShipmentErrorLogsBatch batchClass = new DeleteShipmentErrorLogsBatch();
        Database.executeBatch(batchClass,2000);
        
    }
    
}