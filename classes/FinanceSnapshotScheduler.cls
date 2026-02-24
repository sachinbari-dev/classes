global class FinanceSnapshotScheduler implements Schedulable {
    
    // Runs at 12:00 AM on the 5th of every month

    global void execute(SchedulableContext sc) {
        FinanceSnapshotBatch batch = new FinanceSnapshotBatch();
        Database.executeBatch(batch, 200); 
    }

    
    public static void scheduleMonthlyJob() {
        String cronExp = '0 0 0 5 * ? *';
        System.schedule('Monthly Finance Snapshot Scheduler', cronExp, new FinanceSnapshotScheduler());
    }
}