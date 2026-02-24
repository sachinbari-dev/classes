@isTest
public class VistaraTrackAwbBatchschedulerTest {

      @isTest
    public static void testVistaraTrackAwbBatchscheduler(){
        
         VistaraTrackAwbBatchscheduler ts = new  VistaraTrackAwbBatchscheduler();
         
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, ts );
    }
}