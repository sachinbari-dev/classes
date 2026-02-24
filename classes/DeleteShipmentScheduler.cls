global class DeleteShipmentScheduler implements Schedulable {
    
    global void execute (SchedulableContext sc) {
        
        DeleteShipmentBatch batchClass = new DeleteShipmentBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}