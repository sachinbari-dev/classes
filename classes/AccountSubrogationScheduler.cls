public class AccountSubrogationScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new AccountSubrogationBatch(), 100);
    }
}