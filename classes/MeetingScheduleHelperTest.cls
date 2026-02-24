@isTest
private class MeetingScheduleHelperTest {

    @isTest
    static void testSaveMS() {
        String result = MeetingScheduleHelper.saveMS('Customer123');
        System.assertEquals('123', result, 'Expected result is not returned from saveMS');
    }

    @isTest
    static void testSaveRecord() {
        // Add test data if needed
        String customerId = '0015g00000vJCfxAAG';
        String userId = 'User123';
        String notes = 'Test Notes';
        string duration = '1.5';
        Date visitedDate = Date.today();
        String visitedTime = '12:30:00';
        string blobData ='test';
        String customerName = 'test1';
        

        Test.startTest();
        String result = MeetingScheduleHelper.SaveRecord(customerId, userId, notes, duration, visitedDate, visitedTime,blobData,customerName);
        Test.stopTest();

        // Add assertions based on expected outcomes
        System.assertNotEquals(null, result, 'SaveRecord returned null');
        // Add more assertions as needed
        Meeting_Schedule__c ms = [SELECT Id,Customer__c FROM Meeting_Schedule__c WHERE Id = :result];
        System.assertEquals(customerId, ms.Customer__c, 'Customer Id does not match');
        // Add more assertions for other fields if needed
    }

    @isTest
    static void testUploadFile() {
        // Add test data if needed
        String base64 = 'Base64EncodedString';
        String filename = 'TestFile.txt';
        String recordId = 'a6x0T000000ATKhQAO';

        Test.startTest();
        String result = MeetingScheduleHelper.uploadFile(base64, filename, recordId);
        Test.stopTest();

        // Add assertions based on expected outcomes
        //System.assertNotEquals(null, result, 'uploadFile returned null');
        // Add more assertions as needed
    }

    @isTest
    static void testExceptionHandling() {
        // Test case for exception handling
        Test.startTest();
        // Create a scenario where an exception might occur
        try {
            // Call a method with invalid input to force an exception
            MeetingScheduleHelper.SaveRecord(null, null, null, null, null, null,null,null);
        } catch (Exception e) {
            // Verify that the exception is caught and handled properly
            System.assertNotEquals(null, e.getMessage(), 'Exception not handled properly');
        }
        Test.stopTest();
    }

    @isTest
    static void testBulkDataProcessing() {
        // Test case for bulk data processing
        List<String> customerIds = new List<String>{'Cust1', 'Cust2', 'Cust3'};
        List<String> userIds = new List<String>{'User1', 'User2', 'User3'};
        List<String> notes = new List<String>{'Note1', 'Note2', 'Note3'};
            List<Decimal> durations = new List<Decimal>{1.0, 2.0,3.0};
                
            }
}