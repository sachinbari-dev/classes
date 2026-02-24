@isTest
public class ZohoSignGetDocumentSchedulerTest {

    @isTest
    public static void testGetDocumentScheduler(){
        ZohoSignGetDocumentScheduler sc = new ZohoSignGetDocumentScheduler();
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, sc);
    }
}