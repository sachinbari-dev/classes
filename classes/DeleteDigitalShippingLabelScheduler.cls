global class DeleteDigitalShippingLabelScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
        DeleteDigitalShippingLabelBatch batchClass = new DeleteDigitalShippingLabelBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}