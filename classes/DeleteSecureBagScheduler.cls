global class DeleteSecureBagScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        DeleteSecureBagBatch batchClass = new DeleteSecureBagBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}