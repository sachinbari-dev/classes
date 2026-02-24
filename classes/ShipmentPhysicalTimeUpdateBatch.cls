global class ShipmentPhysicalTimeUpdateBatch implements Database.Batchable<sObject>, Database.Stateful
{
    public List<Shipment__c> shipList;    
    public ShipmentPhysicalTimeUpdateBatch(List<Shipment__c> shipList) 
    {
        this.shipList = shipList;
    }
    global Iterable<sObject> start(Database.BatchableContext BC) 
    {
        return this.shipList;
    }
    global void execute(Database.BatchableContext BC, List<Shipment__c> scope) {       
        try {
                DateTime start = System.Now();
                while(System.Now().getTime()< start.getTime()+1000){} //Delay 
                update scope;
        } catch(Exception e) { System.debug('Error updating shipments in batch: ' + e.getMessage());
            Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'ShipmentPhysicalTimeUpdateBatch',Error__c=e.getMessage());
            insert AEL;
        }
    }
    global void finish(Database.BatchableContext BC) {
        if(shipList.size() > 0) {
            //SLACalculatorHandler.distanceCalculator(shipList);
            DateTime start = System.Now();
            while(System.Now().getTime()< start.getTime()+2000){} //Delay 
            SLACalculatorHandlerBatch batch = new SLACalculatorHandlerBatch(shipList);
            Database.executeBatch(batch, 50);
        }
    }
}