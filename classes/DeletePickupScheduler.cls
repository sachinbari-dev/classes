global class DeletePickupScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        DeletePickupBatch batchClass = new DeletePickupBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}