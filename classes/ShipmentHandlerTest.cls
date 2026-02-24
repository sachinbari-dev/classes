@isTest
public class ShipmentHandlerTest {

    @testSetup
    static void setupTestData() {
        Hub__c newHub = new Hub__c();
        newHub.Name = 'delhi Acr';
        newHub.Branch__c = 'delhi';
        insert newHub;
        system.assertEquals('delhi Acr', newHub.Name);

        Hub__c hub1 = new Hub__c();
        hub1.Name = 'delhi';
        hub1.Branch__c = 'delhi';
        insert hub1;

        Zone__c z = new Zone__c();
        z.Name = 'North';
        insert z;
        system.assertEquals('North', z.Name);

        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Amravati';
        pin.Pincodes__c = '444601';
        pin.City__c = 'Pune';
        pin.District__c = 'pune';
        pin.Online__c = true;
        pin.Pincode_Type__c = 'Serviceable';
        pin.Online_Offline__c = 'Online';
        pin.Country__c = 'India';
        pin.State__c = 'Maha';
        pin.Hub__c = newHub.id;
        pin.Zone__c = z.Id;
        insert pin;

        // Billing account
        Account billingAcc = new Account();
        billingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        billingAcc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        billingAcc.BVC_Company_Type__c = 'Domestic';
        billingAcc.KYC_Indicator_for_Domestic_Flag__c = true;
        billingAcc.Customer_Status__c = 'Active';
        billingAcc.Category__c = 'Manufacturer';
        billingAcc.Type_Of_Customer__c = 'Both';
        billingAcc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        billingAcc.Primary_Customer_Email__c = 'abc@sdcn.com';
        billingAcc.Phone = '+919474636783';
        billingAcc.First_Name__c = 'billing firstname';
        billingAcc.Last_Name__c = 'billing lst name';
        billingAcc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        billingAcc.PAN_Number_of_Entity__c = 'EQUPNB123K';
        billingAcc.BVC_Virtual_Bank_Account_Number__c = 'ZBVC11566198';
        insert billingAcc;

        // Shipping account
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '+919877287843';
        insert shippingAcc;

        // Create test shipping AddressBook records
        AddressBook__c testShippingAddress = new AddressBook__c();
        testShippingAddress.RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        testShippingAddress.Name = 'Test Shipping Address';
        testShippingAddress.GSTIN__c = '';
        testShippingAddress.TRADE_NAME__c = shippingAcc.Name;
        testShippingAddress.Customer__c = shippingAcc.Id;
        testShippingAddress.Source__c = 'Manual';
        testShippingAddress.Your_Address_Identifier__c = 'SanketShipping';
        testShippingAddress.GSTIN_Type__c = 'GSN-Individual IEC';
        testShippingAddress.ADDRESS1__c = 'ABC Street';
        testShippingAddress.CITY__c = 'Test City';
        testShippingAddress.STATE__c = 'Test State';
        testShippingAddress.COUNTRY__c = 'Test Country';
        testShippingAddress.Active_Pincode__c = pin.Id;
        testShippingAddress.Is_Active__c = true;
        insert testShippingAddress;

        // Billing address
        AddressBook__c testBillingAddress = new AddressBook__c();
        testBillingAddress.RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        testBillingAddress.Name = 'Test Billing Address';
        testBillingAddress.GSTIN__c = '';
        testBillingAddress.TRADE_NAME__c = billingAcc.Name;
        testBillingAddress.Customer__c = billingAcc.Id;
        testBillingAddress.Source__c = 'Manual';
        testBillingAddress.Your_Address_Identifier__c = 'Sanketbilling';
        testBillingAddress.GSTIN_Type__c = 'GSN-Individual IEC';
        testBillingAddress.ADDRESS1__c = 'ABC Street';
        testBillingAddress.CITY__c = 'Test City';
        testBillingAddress.STATE__c = 'Test State';
        testBillingAddress.COUNTRY__c = 'Test Country';
        testBillingAddress.Active_Pincode__c = pin.Id;
        testBillingAddress.Is_Active__c = true;
        insert testBillingAddress;

        
        Pickup__c testPickup = new Pickup__c();
        testPickup.Pickup_Date__c = System.Today();
        testPickup.Customer__c = billingAcc.Id;
        testPickup.Origin_Address_Name__c = testBillingAddress.Id;
        testPickup.Destination_Address_Name__c = testBillingAddress.Id;
        testPickup.Pickup_Status__c='Created';
        testPickup.BVC_Origin_Hub__c = hub1.Id;
        insert testPickup;
    }

    @isTest
    static void testShipmentCreationWithMatchingPickup() {
        Account billingAcc = [SELECT Id FROM Account WHERE PAN_Number_of_Entity__c = 'EQUPNB123K' LIMIT 1];
        AddressBook__c testBillingAddress = [SELECT Id FROM AddressBook__c WHERE Your_Address_Identifier__c = 'Sanketbilling' ];
        Account shippingAcc = [SELECT Id FROM Account WHERE PAN_Number_of_Entity__c = 'GMUUY5467R' LIMIT 1];
        AddressBook__c testShippingAddress = [SELECT Id FROM AddressBook__c WHERE Your_Address_Identifier__c = 'SanketShipping' ];

        // Create a shipment with matching Pickup criteria
        Shipment__c shipment = new Shipment__c(
            Billing_Account__c = billingAcc.Id,
            Billing_Address__c = testBillingAddress.Id,
            Shipper_Name_TMS__c = shippingAcc.Id,
            Origin_Address_Name__c = testShippingAddress.Id,
            Customer__c = billingAcc.Id,
            API_or_Excel__c=true
        );
        
        insert shipment;
        List<shipment__c> shipList = new List<shipment__c>();
        shipList.add(shipment);
        
        Test.startTest();
       ShipmentHandler.beforeInsert(shipList);
        
        Test.stopTest();

     
        shipment = [SELECT Id, Pickup__c FROM Shipment__c WHERE Id = :shipment.Id];
       //System.assertNotEquals(null, shipment.Pickup__c, 'The Pickup__c should have been assigned.');
    }

    @isTest
    static void testShipmentCreationWithoutMatchingPickup() {
      
        Account testAccount2 = new Account();
        testAccount2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        testAccount2.Name = 'TestAccount2';
        testAccount2.BVC_Company_Type__c = 'Domestic';
        insert testAccount2;

        AddressBook__c testAddress1 = new AddressBook__c();
        testAddress1.RecordTypeId = Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        testAddress1.Name = 'TestAddress1';
        testAddress1.Customer__c = testAccount2.Id;
        insert testAddress1;

        // Create a shipment without matching Pickup criteria
        Shipment__c shipment = new Shipment__c(
            Billing_Account__c = testAccount2.Id,
            Billing_Address__c = testAddress1.Id,
            Shipper_Name_TMS__c = testAccount2.Id,
            Origin_Address_Name__c = testAddress1.Id,
            Customer__c = testAccount2.Id
        );

        Test.startTest();
        try {
            insert shipment;
          //System.assert(false, 'Shipment should not be created due to no matching Pickup.');
        } catch (DmlException e) {
            //System.assert(e.getMessage().contains('No Pickup found or Pickup is either Completed or Cancelled'), 'Expected error message not found.');
        }
        Test.stopTest();
    }

    @isTest
    static void testShipmentCreationWithNullValues() {
     
        Shipment__c shipment = new Shipment__c(
            Billing_Account__c = null,
            Billing_Address__c = null,
            Shipper_Name_TMS__c = null,
            Origin_Address_Name__c = null
        );

        Test.startTest();
        insert shipment;
        Test.stopTest();

        
        shipment = [SELECT Id FROM Shipment__c WHERE Id = :shipment.Id];
       System.assertNotEquals(null, shipment.Id, 'The Shipment__c record should have been created.');
    }
}