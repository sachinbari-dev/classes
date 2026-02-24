@isTest
public class BVC_ZohoSignAccessGenScheculerTest {

     @isTest
    public static void testGetDocumentScheduler(){
        BVC_ZohoSignAccessGenScheculer sc = new BVC_ZohoSignAccessGenScheculer();
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, sc);
    }
}