global class DeleteTrackingScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        DeleteTrackingBatch batchClass = new DeleteTrackingBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}