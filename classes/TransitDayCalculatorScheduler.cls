public class TransitDayCalculatorScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        
        integer batchsize = 50;
        TransitDayCalculatorBatch batchJob = new TransitDayCalculatorBatch(batchsize);
        Database.executeBatch(batchJob, 200);
    }
}