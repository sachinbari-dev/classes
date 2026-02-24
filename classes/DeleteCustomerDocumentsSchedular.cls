global class DeleteCustomerDocumentsSchedular implements Schedulable {
    
    global void execute (SchedulableContext sc) {
        
        DeleteCustomerDocumentsBatch batchClass = new DeleteCustomerDocumentsBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}