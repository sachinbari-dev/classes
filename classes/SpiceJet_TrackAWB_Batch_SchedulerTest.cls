@isTest(SeeAllData=false)
public class SpiceJet_TrackAWB_Batch_SchedulerTest {
 @isTest
    public static void testschedule() {
		
		SpiceJet_TrackAWB_Batch_Scheduler testsched = new SpiceJet_TrackAWB_Batch_Scheduler();
		String sch = '0 0 12 * * ?';
		System.schedule('Test status Check', sch, testsched );
		
	}
}