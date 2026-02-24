@isTest
public class AccountSubrogationBatchTest {

    @testSetup
    static void setupTestData() {
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'testuser@example.com.' + System.currentTimeMillis()
        );
        insert testUser;

        Date today = Date.today();

        List<Account> accList = new List<Account>{
            new Account(Name = 'Acc -6 Days', Subrogation_End_Date__c = today.addDays(6), OwnerId = testUser.Id, Primary_Customer_Email__c = 'customer1@example.com'),
            new Account(Name = 'Acc -3 Days', Subrogation_End_Date__c = today.addDays(3), OwnerId = testUser.Id, Primary_Customer_Email__c = 'customer2@example.com'),
            new Account(Name = 'Acc +1 Day', Subrogation_End_Date__c = today.addDays(-1), OwnerId = testUser.Id, Primary_Customer_Email__c = 'customer3@example.com'),
            new Account(Name = 'Acc No Match', Subrogation_End_Date__c = today.addDays(10), OwnerId = testUser.Id, Primary_Customer_Email__c = 'ignore@example.com')
        };
        insert accList;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        AccountSubrogationBatch batch = new AccountSubrogationBatch();
        Database.executeBatch(batch, 100);
        Test.stopTest();

        System.debug('Test completed. Check email logic with both Owner and Primary_Customer_Email__c.');
    }

    @isTest
    static void testSchedulerExecuteMethod() {
        AccountSubrogationScheduler scheduler = new AccountSubrogationScheduler();

        Test.startTest();
        scheduler.execute(null); // Simulate schedulable context
        Test.stopTest();

        // No asserts required if we only want to ensure it runs without exceptions.
    }

    @isTest
    static void testSchedulerViaSystemSchedule() {
        String cronExp = '0 0 0 1 1 ? 2050'; // arbitrary valid future cron expression

        Test.startTest();
        String jobId = System.schedule('AccountSubrogationSchedulerJob', cronExp, new AccountSubrogationScheduler());
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null.');
    }
}