global class DeleteOSInvoiceScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        DeleteOSInvoiceBatch batchClass = new DeleteOSInvoiceBatch();
        Database.executeBatch(batchClass,2000);
        
    }
    
}