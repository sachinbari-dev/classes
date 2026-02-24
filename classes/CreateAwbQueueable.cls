public class CreateAwbQueueable implements Queueable {

 private List<Id> linehaulIds;
    private Integer retryCount;

    public CreateAwbQueueable(List<Id> linehaulIds) {
        this(linehaulIds, 0);
    }
    public CreateAwbQueueable(List<Id> linehaulIds, Integer retryCount) {
        this.linehaulIds = linehaulIds == null ? new List<Id>() : linehaulIds;
        this.retryCount = retryCount == null ? 0 : retryCount;
    }

    public void execute(QueueableContext ctx) {
           createAwbNumberRecord.createAWBRecords1(linehaulIds, retryCount);
    }
     
}