global class Indigo_TrackAWB_BatchScheduler implements schedulable {

     global void execute(SchedulableContext sc){
        
        Indigo_TrackAWB_Batch bc = new Indigo_TrackAWB_Batch();
         
        database.executeBatch(bc,200);
          
     
    }
}