@isTest
public class securepackagingupdateBatchSchedulertest {

     @isTest
    public static void securePackagingUpdateBatchScheTest(){
         
        securepackagingupdateBatchScheduler sc = new securepackagingupdateBatchScheduler();
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, sc);
    }
}