@IsTest
private class PickupCutoffValidatorTest {

    @IsTest
    static void testPickupBeforeCutoff_Success() {

        /* ---------------- ACCOUNT ---------------- */
        Account Acc = new Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc.Customer_Status__c = 'Active';
        insert Acc;
        
         Account Acc1 = new Account();
        Acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc1.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc1.Customer_Status__c = 'Active';
        insert Acc1;

        /* ---------------- HUB + ZONE ---------------- */
        Hub__c hub1 = new Hub__c(Name='delhi', Branch__c ='delhi');
        insert hub1;

        Zone__c z = new Zone__c(Name= 'North');
        insert z;

        /* ---------------- ACTIVE PINCODE (FUTURE CUTOFF) ---------------- */
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '444601';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'Maha';
        pin.Zone__c = z.Id;

        // Cutoff 2 hours ahead
        pin.Pickup_End_Cutoff_Time__c = Datetime.now().addHours(2).time();
        pin.Creation_Lead_Time__c = 0;

        insert pin;

        /* ---------------- ADDRESS ---------------- */
        AddressBook__c TestAdd = new AddressBook__c();
         TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.Active_Pincode__c = pin.Id;
        TestAdd.Customer__c = Acc.id;
        insert TestAdd;

        /* ---------------- PICKUP ---------------- */
        Pickup__c TestPick = new Pickup__c();
        TestPick.Customer__c = Acc1.Id;
        TestPick.Shipper_Address__c = TestAdd.Id;   // IMPORTANT FIELD
        TestPick.BVC_Origin_Hub__c = hub1.Id;

        Test.startTest();
        insert TestPick;   // Should NOT error
        Test.stopTest();

        System.assertNotEquals(null, TestPick.Id);
    }


    @IsTest
    static void testPickupAfterCutoff_Error() {

        Account Acc = new Account(
            Name = 'Test Billing',
          RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId(),
            Customer_Status__c = 'Active'
        );
        insert Acc;

        Hub__c hub1 = new Hub__c(Name='delhi', Branch__c ='delhi');
        insert hub1;

        Zone__c z = new Zone__c(Name= 'North');
        insert z;

        /* ---------------- ACTIVE PINCODE (PAST CUTOFF) ---------------- */
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '444602';
        pin.Zone__c = z.Id;

        // Cutoff 1 hour before now
        pin.Pickup_End_Cutoff_Time__c = Datetime.now().addHours(-1).time();
        pin.Creation_Lead_Time__c = 0;

        insert pin;

        AddressBook__c TestAdd = new AddressBook__c(
            Name = 'testaddress2',
            RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId(),
            Active_Pincode__c = pin.Id,
            Is_Active__c =True,
            Customer__c = Acc.id
        );
        insert TestAdd;

        Pickup__c TestPick = new Pickup__c(
            Customer__c = Acc.Id,
            Shipper_Address__c = TestAdd.Id,
            BVC_Origin_Hub__c = hub1.Id
        );

        Test.startTest();
        try {
            insert TestPick;
            System.assert(false, 'Expected cutoff error.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Pickup cannot be created after'),
                'Cutoff validation not triggered.'
            );
        }
        Test.stopTest();
    }


    @IsTest
    static void testBulkInsert_MixedRecords() {

        Zone__c z = new Zone__c(Name= 'North');
        insert z;

         Account Acc = new Account(
            Name = 'Billing',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId(),
            Customer_Status__c = 'Active'
        );
        insert Acc;
        
        Active_Pincode__c pin = new Active_Pincode__c(
            Name = '600001',
            Zone__c = z.Id,
            Pickup_End_Cutoff_Time__c = Datetime.now().addHours(2).time(),
            Creation_Lead_Time__c = 0
        );
        insert pin;

        AddressBook__c address = new AddressBook__c(
            Name = 'Bulk Address',
            Active_Pincode__c = pin.Id,
            Is_Active__c =True,
           RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId(),
            Customer__c = Acc.id
        );
        insert address;

        List<Pickup__c> pickups = new List<Pickup__c>();

        for(Integer i = 0; i < 5; i++){
            pickups.add(new Pickup__c(
                Shipper_Address__c = address.Id
            ));
        }

        Test.startTest();
        insert pickups;  
        Test.stopTest();

        System.assertEquals(5, pickups.size());
    }
}