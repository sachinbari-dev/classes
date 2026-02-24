@isTest
public class HolidayChargeBatchTest {

 @isTest
    static void testHandleAfterUpdate_HolidayAndSunday() {
        // Step 1: Create test Pickup
        Pickup__c pickup = new Pickup__c(
            Physical_Pickup_Completed_Time__c = DateTime.newInstance(2025, 8, 2, 10, 0, 0) // Not a Sunday initially
        );
        insert pickup;
        
        // Step 2: Create Account and Address Book entries
        Account customer = new Account(Name = 'Test Customer');
        customer.Last_Name__c='test_LastName';
        insert customer;
        
        // Step 2.1: Create consignee and shipper account and their address entries
        Account ShipperConsigneeAccount = new Account(Name = 'Test Shipper Customer');
        ShipperConsigneeAccount.Last_Name__c='test_ShipperConsigneeAccount_LastName';
        insert ShipperConsigneeAccount;
        
        AddressBook__c origin = new AddressBook__c(Customer__c = ShipperConsigneeAccount.Id, STATE__c = 'Maharashtra', RecordTypeId='0125g0000002Xb1AAE');
        AddressBook__c destination = new AddressBook__c(Customer__c = ShipperConsigneeAccount.Id, STATE__c = 'Maharashtra');
        insert new List<AddressBook__c>{origin, destination};
        
        // Step 3: Create Shipment
        Shipment__c shipment = new Shipment__c(
            Pickup__c = pickup.Id,
            Shipper_Name_TMS__c=ShipperConsigneeAccount.id,
            Consignee_Name_TMS__c=ShipperConsigneeAccount.id,
            Origin_Address_Name__c = origin.Id,
            Destination_Address_Name__c = destination.Id,
            holiday_sunday_charges1__c = false,
            Customer__c = customer.Id
        );
        insert shipment;

        // Step 4: Create Holiday on 5th August 2025
        Holiday_Data__c holiday = new Holiday_Data__c(
            State__c = 'Maharashtra',
            Date__c = Date.newInstance(2025, 8, 5)
        );
        insert holiday;

        // Step 5: Update Pickup to that holiday date
        pickup.Physical_Pickup_Completed_Time__c = DateTime.newInstance(2025, 8, 5, 10, 0, 0);
        update pickup;

        // Step 6: Run the Batch with that Pickup Id
        Set<Id> pickupIds = new Set<Id>{pickup.Id};
        Test.startTest();
            HolidayChargeBatch batch = new HolidayChargeBatch(pickupIds);
            Database.executeBatch(batch, 1);
        Test.stopTest();

        // Step 7: Verify Shipment was updated correctly
        Shipment__c updatedShipment = [SELECT Id, holiday_sunday_charges1__c FROM Shipment__c WHERE Id = :shipment.Id];
        System.assertEquals(true, updatedShipment.holiday_sunday_charges1__c, 'Shipment should be marked true due to holiday');
    }
    
    @isTest
    static void testHandleAfterUpdate_SundayOnly() {
        // // Step 1: Create test Pickup
        DateTime sundayDateTime = DateTime.newInstance(2025, 8, 3, 9, 0, 0);

        Pickup__c pickup = new Pickup__c(
          //  Name = 'Sunday Pickup',
            Physical_Pickup_Completed_Time__c = DateTime.newInstance(2025, 8, 2, 10, 0, 0) // Not Sunday yet
        );
        insert pickup;

         // Step 2: Create Account and Address Book entries
        Account customer = new Account(Name = 'Test Customer');
        customer.Last_Name__c='test_LastName';
        insert customer;
        
        // Step 2.1: Create consignee and shipper account and their address entries
        Account ShipperConsigneeAccount = new Account(Name = 'Test Shipper Customer');
        ShipperConsigneeAccount.Last_Name__c='test_ShipperConsigneeAccount_LastName';
        insert ShipperConsigneeAccount;
        
        AddressBook__c origin = new AddressBook__c(Customer__c = ShipperConsigneeAccount.Id, STATE__c = 'Maharashtra', RecordTypeId='0125g0000002Xb1AAE');
        AddressBook__c destination = new AddressBook__c(Customer__c = ShipperConsigneeAccount.Id, STATE__c = 'Maharashtra');
        insert new List<AddressBook__c>{origin, destination};
        
        // Step 3: Create Shipment
        Shipment__c shipment = new Shipment__c(
            Pickup__c = pickup.Id,
            Shipper_Name_TMS__c=ShipperConsigneeAccount.id,
            Consignee_Name_TMS__c=ShipperConsigneeAccount.id,
            Origin_Address_Name__c = origin.Id,
            Destination_Address_Name__c = destination.Id,
            holiday_sunday_charges1__c = false,
            Customer__c = customer.Id
        );
        insert shipment;

        // // Step 5: Update Pickup to Sunday
        pickup.Physical_Pickup_Completed_Time__c = sundayDateTime;
        
            update pickup;
        
        
        // Step 6: Run the Batch with that Pickup Id
        Set<Id> pickupIds = new Set<Id>{pickup.Id};
            Test.startTest();
        HolidayChargeBatch batch = new HolidayChargeBatch(pickupIds);
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        Shipment__c updatedShipment = [SELECT holiday_sunday_charges1__c FROM Shipment__c WHERE Id = :shipment.Id];
        System.assertEquals(true, updatedShipment.holiday_sunday_charges1__c, 'Should be true because it is Sunday');
    }
    @isTest
    static void testBatchWithNullIds() {
        Test.startTest();
        HolidayChargeBatch batch = new HolidayChargeBatch(null); // or new Set<Id>()
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        
    }
    
}