global class FixedBillingScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Date runDate = System.today().addDays(-1);
        FixedBillingBatch batch = new FixedBillingBatch(runDate);
        Database.executeBatch(batch, 20);
    }
}