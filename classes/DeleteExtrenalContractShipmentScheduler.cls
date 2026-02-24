global class DeleteExtrenalContractShipmentScheduler implements Schedulable {
    
    global void execute (SchedulableContext sc){
        
        DeleteExternalContractShipmentBatch batchClass = new DeleteExternalContractShipmentBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}