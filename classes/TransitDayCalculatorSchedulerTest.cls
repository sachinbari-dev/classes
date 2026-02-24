@isTest
public class TransitDayCalculatorSchedulerTest {

    @isTest
    public static void testMethod1(){
        
          Test.startTest();
            String sch = '0 0 12 * * ?';
            TransitDayCalculatorScheduler schedulerJob = new TransitDayCalculatorScheduler();
            System.schedule('Test_TransitDayCalculator', sch, schedulerJob);
         Test.stopTest();

    }
}