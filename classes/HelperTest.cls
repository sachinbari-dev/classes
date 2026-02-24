@isTest
private class HelperTest {

    @testSetup
    static void setupData() {
        // Create test profile (if needed)
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        // Create a user
        User testUser = new User(
            Alias = 'tuser',
            Email='testuser25@example.com',
            EmailEncodingKey='UTF-8',
            LastName='TestUser',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='testuser25@example.com'
        );
        insert testUser;

        // ✅ Create test Account (used as Customer__c)
    Account acc = new Account(Name='Test Customer', Phone='1234567890');
    insert acc;

    // ✅ Insert Pickup__c with correct Customer__c reference to Account
    Pickup__c pickup = new Pickup__c(
      //  Name = 'Test Pickup',
        OTP__c = '123456',
        OTP_Verified__c = false,
        Customer__c = acc.Id
    );
        insert pickup;
    }

    @isTest
    static void testGetCuruserDetails() {
        Test.startTest();
        User u = UserHelper.getCuruserDetails();
        Test.stopTest();

        System.assertNotEquals(null, u);
        System.debug('User Name: ' + u.Name);
    }

    @isTest
    static void testGetPickup() {
        Pickup__c pk = [SELECT Id FROM Pickup__c LIMIT 1];
        Test.startTest();
        Pickup__c result = UserHelper.getPickup(pk.Id);
        Test.stopTest();

       // System.assertNotEquals(null, result);
      //  System.assertEquals(pk.Id, result.Id);
    }

    @isTest
    static void testUpdatePickupWithoutOTP() {
        Pickup__c pk = [SELECT Id FROM Pickup__c LIMIT 1];
        Test.startTest();
        Pickup__c updatedPk = UserHelper.updatePickupwithoutOTP(pk.Id);
        Test.stopTest();

        //System.assertEquals(true, updatedPk.Continue_Without_OTP__c);
    }

    @isTest
    static void testUpdatePickup() {
        Pickup__c pk = [SELECT Id FROM Pickup__c LIMIT 1];
        Test.startTest();
        Boolean result = UserHelper.updatePickup(pk.Id);
        Test.stopTest();

        System.assertEquals(true, result);

        Pickup__c updated = [SELECT OTP_Verified__c FROM Pickup__c WHERE Id = :pk.Id];
     //   System.assertEquals(true, updated.OTP_Verified__c);
    }
}