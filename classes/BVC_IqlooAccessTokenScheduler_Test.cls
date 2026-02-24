@isTest
public class BVC_IqlooAccessTokenScheduler_Test {

     @isTest
    public static void testGetDocumentScheduler(){
        BVC_IqlooAccessTokenScheduler sc = new BVC_IqlooAccessTokenScheduler();
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, sc);
    }
}