global class DeleteOrderScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        DeleteOrderBatch batchClass = new DeleteOrderBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}