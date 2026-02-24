public class AbortCBJobs {
    @InvocableMethod(label='Abort CB Jobs')
    public static void abortallCBJobs() {
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE State = 'WAITING' AND CronJobDetail.Name LIKE 'CB Order Activation Job%'
        ];
        
        if (jobs.isEmpty()) {
            System.debug('No CB jobs found to abort.');
            return; // Exit the method if no CB jobs are found
        }
        
        for (CronTrigger job : jobs) {
            try {
                System.abortJob(job.Id);
                System.debug('Aborted CB job: ' + job.CronJobDetail.Name);
            } catch (Exception e) {
                System.debug('Error aborting CB job ' + job.CronJobDetail.Name + ': ' + e.getMessage());
            }
        }
       
    }
}