global class CBBVCOrderActivation implements Schedulable{
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new CBBVCOrderActivationBatch(), 50);
        
    }
}