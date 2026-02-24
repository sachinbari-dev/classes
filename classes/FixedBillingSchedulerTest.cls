@isTest
public class FixedBillingSchedulerTest {

    @isTest
    static void testSchedulerExecutesBatch() {
        Account acc = new Account(Name = 'Test Customer',Last_name__c='xyz');
        insert acc;

        Fixed_Billing__c fb = new Fixed_Billing__c(
            Name = 'Test Fixed Billing',
            Customer__c = acc.Id,
            Billing_Type__c = 'Type1',
            Monthly_Billing__c = 10000,
            Remaining_Shipments__c = 50
        );
        insert fb;

        List<Shipment__c> shipments = new List<Shipment__c>();
        for (Integer i = 0; i < 3; i++) {
            shipments.add(new Shipment__c(
                Customer__c = acc.Id,
                Shipment_Date__c = System.today().addDays(-1)
            ));
        }
        insert shipments;

        Test.startTest();

        FixedBillingScheduler scheduler = new FixedBillingScheduler();
        Datetime dt = System.now();
        String schId = '12345'; // dummy job ID
        scheduler.execute(null); // directly invoke

        Test.stopTest();

    }
}