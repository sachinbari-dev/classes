@isTest
public class MeetingScheduleBatchTest 
{
    @isTest
    static void testMeetingScheduleBatchScheduler() {
        Account acct = new Account();
        acct.name = 'Shipping Accounts';
        acct.ST_Pricing_Type__c = 'Non ACR';
        acct.Customer_Category__c = 'Non Contracted';
        acct.Billing_Frequency__c = 'Monthly';
        acct.Name_As_Per_PAN_Manual_Input__c = 'Lionesl Messi';
        acct.GST_Registered__c = true;
        acct.Billing_Cycle__c = '26-25';
        acct.KYC_Status__c = 'API Verified';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        acct.KYC_Indicator_for_Domestic_Flag__c = true;
        insert acct; 
        
        String userId = 'User123';
        String notes = 'Test Notes';
        String duration = '1.5';
        Date visitedDate = Date.today();
        String visitedTime = '12:30:00';
        string blobData ='test';
        
        Meeting_Schedule__c ms = new Meeting_Schedule__c();
        if(visitedTime!=null)
        {
            List<String> tm = visitedTime.split(':');
            Time myTime = Time.newInstance(Integer.valueOf(tm[0]), Integer.valueOf(tm[1]),Integer.valueOf(tm[2]), 0); 
            ms.Time__c=myTime;
        }
        
        ms.Customer__c=acct.Id;
        ms.Duration__c=Duration;
        ms.Notes__c=Notes;
        ms.User__c=UserInfo.getUserId();
        ms.Visit_Date__c=visitedDate;
        insert ms;
        // Create an instance of the Schedule class
        MeetingScheduleBatchScheduler sched = new MeetingScheduleBatchScheduler();       
        // Schedule the class to run 1 minute from now
        String sch = '0 0 0 * * ?';       
        // Schedule the job
        String jobId = System.schedule('Test Job', sch, sched);        
        // Verify the job is scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];       
        System.assertEquals('0 0 0 * * ?', ct.CronExpression, 'Cron expression did not match');
        System.assertEquals(0, ct.TimesTriggered, 'Job should not have run yet');
        System.assertNotEquals(null, ct.NextFireTime, 'Next fire time should be set');       
        // Now we need to simulate the execution of the scheduled job
        Test.startTest();       
        // You can't directly call the execute method, so we simulate the schedule job execution
        MeetingScheduleBatchScheduler scheduledJob = new MeetingScheduleBatchScheduler();
        scheduledJob.execute(null);       
        Test.stopTest();
    }
}