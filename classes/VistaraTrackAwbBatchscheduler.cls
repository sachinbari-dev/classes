global class VistaraTrackAwbBatchscheduler implements schedulable {

      global void execute(SchedulableContext sc){
        
        VistaraTrackAwbBatch bc = new VistaraTrackAwbBatch();
        database.executeBatch(bc,200);
        
    }
}