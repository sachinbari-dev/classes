global class ShipmentPhyTimeBatchSchedular implements Schedulable {
    global void execute(SchedulableContext SC) {
        ShipmentPhyTimeBatch b = new ShipmentPhyTimeBatch();
        Database.executeBatch(b,200); 
    }
}