global class SLACalculatorHandlerBatchSchedular implements Schedulable {
    List<Shipment__c> AllShipmentLst = new List<Shipment__c>();
    global SLACalculatorHandlerBatchSchedular(List<Shipment__c> AllShipmentLst) {
        this.AllShipmentLst = AllShipmentLst;
    }
    global void execute(SchedulableContext sc) {
        SLACalculatorHandlerBatch batch = new SLACalculatorHandlerBatch(AllShipmentLst);	// added by Imran on Sep 26 - 2025
        Database.executeBatch(batch);
        //SLACalculator sla = new SLACalculator(AllShipmentLst);
    }
}