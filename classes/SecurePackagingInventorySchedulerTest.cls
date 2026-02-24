@isTest
public class SecurePackagingInventorySchedulerTest {

    @isTest
    public static void securePackagingInventoryScheTest(){
         
        SecurePackagingInventoryScheduler sc = new SecurePackagingInventoryScheduler();
        String sch = '0 0 12 * * ?';
        System.schedule('Test status Check', sch, sc);
    }
}