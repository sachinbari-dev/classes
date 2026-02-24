@isTest
public class vistaraFlightScheduleBatchSchedulerTest {

    @isTest
    public static void testVistaraFlightScheduleBatchScheduler(){
        
            vistaraFlightScheduleBatchScheduler ts = new  vistaraFlightScheduleBatchScheduler();
         
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, ts );
    }

}