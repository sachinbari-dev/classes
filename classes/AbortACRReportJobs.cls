public class AbortACRReportJobs {
    public static void abortBVCJobs() {
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE State = 'WAITING'
        ];
        
        for (CronTrigger job : jobs) {
            if (job.CronJobDetail.Name.startsWith('BVCacrMonthlyReportSchedule') ||
                job.CronJobDetail.Name.startsWith('BVCacrMontlyEmailsSchedule')) {
                    try {
                        System.abortJob(job.Id);
                        System.debug('Aborted BVC job: ' + job.CronJobDetail.Name);
                    } catch (Exception e) {
                        System.debug('Error aborting BVC job ' + job.CronJobDetail.Name + ': ' + e.getMessage());
                    }
                }
        }
    }
}