@IsTest
public class BVCQueueableJobLimiterTest {

    @IsTest
    static void testJobAlreadyEnqueued1() {
        BVCQueueableJobLimiter.isJobAlreadyEnqueued = false;
    }
    
    @IsTest
    static void testJobAlreadyEnqueued2() {
        BVCQueueableJobLimiter.isJobAlreadyEnqueued = true;
    }

}