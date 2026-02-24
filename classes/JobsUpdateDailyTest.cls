@isTest
public class JobsUpdateDailyTest 
{
    @isTest
    static void JobsUpdateDailyTest()
    {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new FleetXjobMockCallout());
        String CRON_EXP = '0 0 0 15 10 ? 2025';        
        // Schedule the job
        String jobId = System.schedule('Test Scheduled Batch Job', CRON_EXP, new JobsUpdateDailySchedular());              
        // JobsUpdateDaily.jobUpdateCallout();
        test.stopTest();
    }
}