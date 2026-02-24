global class IndigoAWBTrackingControllerBatchSche implements schedulable {

  global void execute(SchedulableContext sc){
        
       IndigoAWBTrackingControllerBatch bc = new IndigoAWBTrackingControllerBatch();
        id JobId =  Database.executeBatch(bc,5);
        
    }  
}