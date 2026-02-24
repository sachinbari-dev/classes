global class vistaraFlightScheduleBatchScheduler implements schedulable{

    global void execute(SchedulableContext sc){
        
        vistaraFlightScheduleBatch bc = new vistaraFlightScheduleBatch();
            database.executeBatch(bc,10);
        
    }
}