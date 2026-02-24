global class DeleteACRConsumptionScheduler implements Schedulable {
    
    global void execute (SchedulableContext sc){
        
        DeleteACRConsumptionBatch batchClass = new DeleteACRConsumptionBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}