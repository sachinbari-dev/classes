global class DeleteOSIGMScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        DeleteOSIGMBatch batchClass = new DeleteOSIGMBatch();
        Database.executeBatch(batchClass,2000);
        
    }
    
}