global class DeleteSecurePackagingScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        DeleteSecurePackagingBatch batchClass = new DeleteSecurePackagingBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}