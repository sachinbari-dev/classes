@isTest
private class MassDeleteTest {

    // Test method to test the MassDelete batch class
    static testMethod void testMassDeleteBatch() {
        // Create test records
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert testAccounts;

        // Start the MassDelete batch job
        MassDelete batch = new MassDelete('Account');
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify that the records have been deleted
        Integer count = [SELECT COUNT() FROM Account];
        System.assertEquals(0, count, 'All test accounts should be deleted');
    }
}