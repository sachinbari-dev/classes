@isTest
public class Indigo_TrackAWB_BatchSchedulerTest {
  @isTest
    public static void testVistaraTrackAwbBatchscheduler(){
        
         VistaraTrackAwbBatchscheduler ts = new  VistaraTrackAwbBatchscheduler();
         
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, ts );
        
       
    }
     @isTest
    public static void testIndigoTrackAwbBatchscheduler(){
        
         Indigo_TrackAWB_BatchScheduler ts = new  Indigo_TrackAWB_BatchScheduler();
         
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, ts );
        
       
    }
}