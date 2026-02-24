@isTest
public class PickupDuplicateValidationTest {
    
    @isTest
    static void pickupDuplicateTest() {
        
        // Create Customer Accounts
        Account acc = new Account(
            Name = 'Test Billing Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId(),
            PAN_Number_of_Entity__c  ='1234556778',
            Customer_Status__c ='Active',
            Type_Of_Customer__c='Customer'
        );
        insert acc;

        Account shipAcc = new Account(
            Name = 'Shipping Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId(),
            PAN_Number_of_Entity__c  ='9876543211',
            Customer_Status__c ='Active',
            Type_Of_Customer__c='Customer'
        );
        insert shipAcc;

        
        // Address for shipper
        AddressBook__c shipAdd = new AddressBook__c(
            Name = 'Test Address',
            Customer__c = shipAcc.Id,
            ADDRESS1__c = 'XYZ Road',
            CITY__c = 'City',
            COUNTRY__c = 'India',
            PINCODE__c = '458796',
            District__c = 'District',
            RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId()
        );
        insert shipAdd;

        DateTime nowtime = System.now();

        Test.startTest();

        // Insert valid pickup (should succeed)
        Pickup__c p1 = new Pickup__c(
            Customer__c = acc.Id,
            Shipper_Name__c = shipAcc.Id,
            Shipper_Address__c = shipAdd.Id,
            Pickup_Date_and_Time__c = nowtime,
            Remarks__c = 'Test Pickup',
            RecordTypeId = Schema.SObjectType.Pickup__c.getRecordTypeInfosByName().get('Pickup Form').getRecordTypeId()
        );
        insert p1;

        System.assertNotEquals(null, p1.Id, 'Primary pickup should get inserted successfully');

        // Insert Duplicate Pickup - should throw duplicate error
        Boolean duplicateErrorThrown = false;
        try {
            Pickup__c p2 = new Pickup__c(
                Customer__c = acc.Id,
                Shipper_Name__c = shipAcc.Id,
                Shipper_Address__c = shipAdd.Id,
                Pickup_Date_and_Time__c = nowtime.addSeconds(5), // within ±1 min
                Remarks__c = 'Duplicate Pickup',
                RecordTypeId = Schema.SObjectType.Pickup__c.getRecordTypeInfosByName().get('Pickup Form').getRecordTypeId()
            );
            insert p2;
        } catch (Exception e) {
            duplicateErrorThrown = true;
        }
        System.assertEquals(true, duplicateErrorThrown, 'Duplicate pickup should be restricted');

        // Past date validation check
        Boolean pastDateErrorThrown = false;
        try {
            Pickup__c p3 = new Pickup__c(
                Customer__c = acc.Id,
                Shipper_Name__c = shipAcc.Id,
                Shipper_Address__c = shipAdd.Id,
                Pickup_Date_and_Time__c = nowtime.addHours(-2), // Past time
                Remarks__c = 'Old Pickup',
                RecordTypeId = Schema.SObjectType.Pickup__c.getRecordTypeInfosByName().get('Pickup Form').getRecordTypeId()
            );
            insert p3;
        } catch (Exception e) {
            pastDateErrorThrown = true;
        }
        System.assertEquals(true, pastDateErrorThrown, 'Past datetime should throw validation error');

        Test.stopTest();
    }
}