@isTest
public class BVC_ZohoSignGetDocumentSchedulerTest {

      @isTest
    public static void testGetDocumentScheduler(){
        BVC_ZohoSignGetDocumentScheduler sc = new BVC_ZohoSignGetDocumentScheduler();
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, sc);
    }
}