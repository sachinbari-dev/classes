global class DeleteQuoteLineScheduler implements Schedulable {
    
    global void execute (SchedulableContext sc){
        
        DeleteQuoteLineBatch batchClass = new DeleteQuoteLineBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}