@isTest
 Private class BVC_EshipShipmentOrderHelperSch_Test {

     @isTest
     public static void testMethod1(){
         
          BVC_EshipShipmentOrderHelperScheduler sc = new BVC_EshipShipmentOrderHelperScheduler();
            String sch = '0 0 12 * * ?';
            System.schedule('Test status Check', sch, sc);
     }
}