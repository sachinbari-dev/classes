public class BVC_ZohoSignTokenQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        BVC_zohoSignHelper.getAccesstoken();
    }
}