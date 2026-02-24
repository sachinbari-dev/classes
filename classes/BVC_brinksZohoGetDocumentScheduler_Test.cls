@istest
public class BVC_brinksZohoGetDocumentScheduler_Test {

     @isTest
    public static void testGetDocumentScheduler(){
        BVC_brinksZohoGetDocumentScheduler sc = new BVC_brinksZohoGetDocumentScheduler();
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, sc);
    }
}