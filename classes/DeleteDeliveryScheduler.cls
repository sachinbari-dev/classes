global class DeleteDeliveryScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        DeleteDeliveryBatch batchClass = new DeleteDeliveryBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}