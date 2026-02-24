global class DeleteEmailMessageScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        DeleteEmailMessageBatch batchClass = new DeleteEmailMessageBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}