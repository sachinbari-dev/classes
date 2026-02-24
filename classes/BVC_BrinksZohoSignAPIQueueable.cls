public class BVC_BrinksZohoSignAPIQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> recordIdList;

    public BVC_BrinksZohoSignAPIQueueable(List<Id> recIds) {
        this.recordIdList = recIds;
    }

    public void execute(QueueableContext context) {
        if(!Test.isRunningTest()){
            BVC_BrinksZohoSignHelper.CreateDocument(recordIdList);
        }
         
    }
}