global class DeleteOSProductScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        DeleteOSProductBatch batchClass = new DeleteOSProductBatch();
        Database.executeBatch(batchClass,2000);
        
    }
    
}