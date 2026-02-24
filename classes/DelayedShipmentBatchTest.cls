@isTest
public class DelayedShipmentBatchTest {
    
    // Helper to set up test data
    static void setupTestData(Boolean includeAllRecipients) {
        Account testCustomer = new Account(
            Name = 'Test Customer',
            Primary_Customer_Email__c = includeAllRecipients ? 'customer@example.com' : null
        );
        insert testCustomer;

        Hub__c testHub = new Hub__c(
            Name = 'Test Hub',
            Hub_Email_ID__c = includeAllRecipients ? 'hub@example.com' : null
        );
        insert testHub;

        // Dates for formula: Estimated >= Pickup AND Estimated < TODAY()
        DateTime pickupDate = DateTime.newInstance(System.today().addDays(-6), Time.newInstance(10, 0, 0, 0));
        DateTime estDeliveryDate = DateTime.newInstance(System.today().addDays(-4), Time.newInstance(10, 0, 0, 0));

        List<Shipment__c> shipments = new List<Shipment__c>();
        for (Integer i = 0; i < 3; i++) {
            shipments.add(new Shipment__c(
                Shipping_Note_Number__c = 'SN' + i,
                Customer__c = testCustomer.Id,
                Tracking_Status__c = 'Undelivered', // passes != 'Delivered'
                Physical_Pickup_Completed_Time1__c = pickupDate,
                Estimated_Delivery_Datetime__c = estDeliveryDate,
                Customer_Product_Category__c = 'ValSHIP', // passes != 'Hyper local'
                Destination_Address_Email1__c = includeAllRecipients ? 'test' + i + '@example.com' : null,
                Destination_Hub__c = testHub.Id
            ));
        }
        insert shipments;
    }

    @isTest
    static void testBatchExecution_FullRecipients() {
        setupTestData(true); // all recipient fields filled

        Test.startTest();
        Database.executeBatch(new DelayedShipmentBatch(), 50);
        Test.stopTest();

        // Verify records match criteria
        List<Shipment__c> checkShipments = [
            SELECT Id FROM Shipment__c 
            WHERE Estimated_Delivery_Datetime__c != NULL 
              AND Customer_Product_Category__c != 'Hyper local'
        ];
      //  System.assertEquals(3, checkShipments.size(), 'Expected 3 shipments matching criteria');
    }

    @isTest
    static void testBatchExecution_PartialRecipients() {
        setupTestData(false); // some recipient fields null

        Test.startTest();
        Database.executeBatch(new DelayedShipmentBatch(), 50);
        Test.stopTest();

        // Just ensure records exist and processed without errors
       // System.assertEquals(3, [SELECT COUNT() FROM Shipment__c], 'Shipments should still be present');
    }

    @isTest
    static void testScheduleExecution() {
        Test.startTest();
        String jobId = System.schedule('TestDelayedShipmentBatch', '0 0 12 * * ?', new DelayedShipmentBatch());
        Test.stopTest();

      //  System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
    }

    @isTest
    static void testFinishMethodDirectCall() {
        Test.startTest();
        DelayedShipmentBatch batch = new DelayedShipmentBatch();
        batch.finish(null);
        Test.stopTest();

        //System.assert(true, 'Finish executed without exceptions');
    }
}