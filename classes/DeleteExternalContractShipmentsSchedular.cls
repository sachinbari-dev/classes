global class DeleteExternalContractShipmentsSchedular implements Schedulable {
    
    global void execute (SchedulableContext sc) {
        
        DeleteExternalContractShipmentsBatch batchClass = new DeleteExternalContractShipmentsBatch();
        Database.executeBatch(batchClass,2000);
        
    }

}