@isTest
public class IndigoAWBTrackingControllerBatchScheTest {

     @isTest
     public static void testMethod1(){
         
          IndigoAWBTrackingControllerBatchSche sc = new IndigoAWBTrackingControllerBatchSche();
            String sch = '0 0 12 * * ?';
            System.schedule('Test status Check', sch, sc);
     }
}