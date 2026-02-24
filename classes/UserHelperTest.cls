@isTest
public class UserHelperTest {

    @isTest
    public static void test1() {
        CreateData();
        Test.startTest();
        User u = UserHelper.getCuruserDetails();
        Test.stopTest();
    }

    @isTest
    public static void test2() {
        CreateData();
        Pickup__c pk = [SELECT Id FROM Pickup__c LIMIT 1];
        Test.startTest();
        Pickup__c result = UserHelper.getPickup(pk.Id);
        Test.stopTest();
    }

    @isTest
    public static void test3() {
        CreateData();
        Pickup__c pk = [SELECT Id FROM Pickup__c LIMIT 1];
        Test.startTest();
        Pickup__c updatedPk = UserHelper.updatePickupwithoutOTP(pk.Id);
        Test.stopTest();

    }

    @isTest
    public static void test4() {
        CreateData();
        Pickup__c pk = [SELECT Id FROM Pickup__c LIMIT 1];
        Test.startTest();
        Boolean result = UserHelper.updatePickup(pk.Id);
        Test.stopTest();
        Pickup__c updated = [SELECT OTP_Verified__c FROM Pickup__c WHERE Id = :pk.Id];
    }
    
    public static void CreateData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User( Alias = 'UserTest', Email='testuserTest123@example.com',
            EmailEncodingKey='UTF-8',LastName='TestLastName', LanguageLocaleKey='en_US',  LocaleSidKey='en_US',
            ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testuserTest123@example.com' );
        insert testUser;

    Account acc = new Account(Name='Customer Account', Phone='1234567890');
    insert acc;
    Pickup__c pickup = new Pickup__c(  OTP__c = '123456', OTP_Verified__c = false, Customer__c = acc.Id );
        insert pickup;
    }    
}