@isTest
public class BVCMonthlyReportEshipHelperTest {
    
    @isTest
    static void testAcrschedulerByUser() {
        Test.startTest();
        BVCacrMonthlyReportScheduleEshipHelper.acrschedulerByUser();
        Test.stopTest();
        
        // Verify scheduled jobs exist
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name IN ('BVCacrMonthlyReportScheduleEship', 'BVCacrMontlyEmailsScheduleEship')
        ];
        System.assertEquals(2, jobs.size(), 'Two scheduled jobs should be created.');
    }
    
    @isTest
    static void testAcrmonthlyhealper_NoAbort() {
        // Schedule dummy jobs
        String sch = '0 0 9 9 * ? *';
        System.schedule('BVCacrMonthlyReportScheduleEship', sch, new BVCacrMonthlyReportScheduleEship());
        System.schedule('BVCacrMontlyEmailsScheduleEship', sch, new BVCacrMontlyEmailsScheduleEship());
        
        Test.startTest();
        // This will run, but likely won't abort since time != 23:30
        BVCacrMonthlyReportScheduleEshipHelper.acrmonthlyhealper();
        Test.stopTest();
        
        // At least verifies method executes without error
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name LIKE 'BVCacr%'
        ];
        System.assert(!jobs.isEmpty(), 'Jobs should still exist since condition not met.');
    }
}