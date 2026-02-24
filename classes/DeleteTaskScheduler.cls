global class DeleteTaskScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        DeleteTaskBatch batchClass = new DeleteTaskBatch();
        Database.executeBatch(batchClass,2000);
        
    }
        
}