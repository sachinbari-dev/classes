@IsTest(seeAllData=true)
public class ShipmentPhyTimeBatchTest {
    @IsTest
    public static void testMeth1()
    {
        test.StartTest();
        
        String jobName = 'ShipmentPhyTimeBatchSchedular';        
        // Minimum 1 minute delay
        Datetime now = System.now().addMinutes(1);
        String cronExp = now.second() + ' ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' ' + now.month() + ' ? ' + now.year();        
        // Schedule the class
        System.schedule(jobName, cronExp, new ShipmentPhyTimeBatchSchedular());        
        /*
        ShipmentPhyTimeBatch b = new ShipmentPhyTimeBatch();
        Database.executeBatch(b,200);
		*/
        test.StopTest();
    }
}