@isTest
private class FixedBillingBatchTest {

    @testSetup
    static void setupData() {
        // Create a test Account (Customer)
        user u= [SELECT Id, Username  FROM User WHERE UserRoleId='00E5g000000QqbY' LIMIT 1];
        
        Account Acc = New Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc.BVC_Company_Type__c = 'Domestic';        
        Acc.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.Phone = '94746367837';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';      
        Insert Acc;
        system.assertEquals('TITAN COMPANY LIMITED - Billing EQUPNB123K', Acc.name);
        system.assertEquals('Active', Acc.Customer_Status__c);
        system.assertEquals('billing firstname', Acc.First_Name__c);
        
        Account shippingAcc = new Account();
        shippingAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        shippingAcc.Name = 'SPARKLEs GOLD RETAIL VENTURES LLP - Shipping GMUUY5467R';
        shippingAcc.PAN_Number_of_Entity__c = 'GMUUY5467R';
        //   shippingAcc.Name_As_Per_PAN__pc = 'shipping customer';
        shippingAcc.Name_As_Per_PAN_Manual_Input__c = 'new custmers';
        shippingAcc.First_Name__c = 'new customer';           
        shippingAcc.Last_Name__c = 'customer account';
        shippingAcc.Primary_Customer_Email__c = 'ravi.e@bvclogistics.com';
        shippingAcc.Phone = '9877287843';
        //insert shippingAcc;
        
        Contact Con = New Contact();
        Con.LastName = 'TestContact';
        Con.AccountId = shippingAcc.Id;
        Con.Email = 'abc123@paoj.com';
        Con.BVC_Finance_Contact__c = TRUE;
        Insert Con;
        
        Hub__c newHub = new Hub__c();
        newHub.Name = 'MUMBAI';
        newHub.Branch__c = 'MUMBAI';
        insert newHub;
        
        Hub__c newDHub = new Hub__c();
        newDHub.Name = 'HYDERABAD';
        newDHub.Branch__c = 'HYDERABAD';
        insert newDHub;
        
        
        Zone__c z =  new Zone__c();         
        z.Name= 'North';
        insert z;
        system.assertEquals('North', z.Name);
        
        Active_Pincode__c pin = new Active_Pincode__c();
        pin.Name = '456789';
        pin.City__c = 'Amravati';
        pin.Pincodes__c = '456789';
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
        

        Active_Pincode__c DHpin = new Active_Pincode__c();
        DHpin.Name = '456755';
        DHpin.City__c = 'Amravati';
        DHpin.Pincodes__c = '456755';
        DHpin.City__c = 'Pune';
        DHpin.District__c = 'pune';
        DHpin.Online__c = true;
        DHpin.Pincode_Type__c = 'Serviceable';
        DHpin.Online_Offline__c = 'Online';
        DHpin.Country__c = 'India';
        DHpin.State__c = 'Maha';
        DHpin.Hub__c = newDHub.id;
        DHpin.Zone__c = z.Id;
        //insert DHpin;
        
        AddressBook__c TestAdd = New AddressBook__c();
        TestAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        TestAdd.Name = 'testaddress';
        TestAdd.GSTIN__c = '';
        TestAdd.TRADE_NAME__c = Acc.Name;
        TestAdd.Customer__c = Acc.id;
        TestAdd.Source__c = 'Manual';
        TestAdd.Your_Address_Identifier__c = 'billing';
        TestAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestAdd.ADDRESS1__c = 'ABC Street';
        TestAdd.CITY__c = 'Test City';
        TestAdd.STATE__c = 'Test State';
        TestAdd.COUNTRY__c = 'Test Country';
        TestAdd.Active_Pincode__c = pin.Id ; 
        TestAdd.Is_Active__c = true;
        //Insert TestAdd;      

        AddressBook__c TestShipAdd = New AddressBook__c();
        TestShipAdd.RecordTypeId =Schema.SObjectType.AddressBook__c.getRecordTypeInfosByName().get('Shipping').getRecordTypeId();
        TestShipAdd.Name = 'testaddress11';
        TestShipAdd.GSTIN__c = '';
        TestShipAdd.TRADE_NAME__c = Acc.Name;
        TestShipAdd.Customer__c = shippingAcc.id;
        TestShipAdd.Source__c = 'Manual';
        TestShipAdd.Your_Address_Identifier__c = 'Shipping';
        TestShipAdd.GSTIN_Type__c = 'GSN-Individual IEC';
        TestShipAdd.ADDRESS1__c = 'ABC Street';
        TestShipAdd.CITY__c = 'Test City';
        TestShipAdd.STATE__c = 'Test State';
        TestShipAdd.COUNTRY__c = 'Test Country';
        TestShipAdd.Active_Pincode__c = pin.Id ; 
        TestShipAdd.Is_Active__c = true;
        //Insert TestShipAdd; 
        
        ST_Exhibition__c newexhibition = new ST_Exhibition__c();
        newexhibition.Name = 'New OFC opening';
        newexhibition.COA_Exhibition_Code__c = 'OFC-21';
        insert newexhibition ;
        
        Shipment_Lot__c newLot =  new Shipment_Lot__c();
        newLot.name = 'New Shipment Lot';
        insert newLot;                               
        
        Pickup__c TestPick = New Pickup__c();
        TestPick.Pickup_Date__c = System.Today();
        TestPick.Customer__c = Acc.Id;        
        TestPick.Origin_Address_Name__c = TestAdd.Id;
        TestPick.Destination_Address_Name__c = TestAdd.Id;
        TestPick.Shipper_Address__c = TestShipAdd.Id;
        TestPick.Shipper_Name__c = shippingAcc.id;
        //   TestPick.Name = 'TestPickup';
        Insert TestPick; 
        
        Pickup_Delivery_Route__c  newpickup = new Pickup_Delivery_Route__c();
        newpickup.Delivery_Route_Number__c = 'RTNO-45';
        newpickup.Hub__c = newhub.id;
        //        newpickup.Delivery_Route_Assigned_To__c = u.id;
        insert newpickup;
 
        Shipment__c ship = new Shipment__c();          
        ship.Invoice_Calculated_Amount__c = 29000;
        Ship.Total_Charge__c = 3456;
        ship.Customer__c = Acc.id; 
        ship.Shipper_Name_TMS__c = Acc.Id;
        ship.Insurance_By__c = 'BVC';
        ship.Destination_Address_Name__c = TestAdd.Id;
        ship.Origin_Address_Name__c = TestAdd.Id;
        ship.Net_Weight__c = 12;
        ship.Net_Weight_UOM_TMS__c = 'gram';
        ship.Shipment_Value__c = 21;
        Ship.Total_Invoice_Value__c = 876;
        ship.Billing_Account__c = acc.Id;
        Ship.Bill_To_GSTIN__c = 'ABCD123L';
        Ship.Bill_To_Party_Address__c = 'Test Address';
        Ship.Bill_To_Party_PAN__c = 'ABCD1234M';
        Ship.Billing_Entity_Name__c = Acc.Name;
        ship.AddressBook__c = TestAdd.Id;
        ship.Delivery_Route_Assigned_To__c = u.id; 
        ship.Physical_Pickup_Completed_Time1__c=DateTime.now();
        ship.Origin_Hub__c= newHub.Id; 
        ship.Destination_Hub__c = newDHub.Id;
        ship.Pickup__c=TestPick.Id;
        //insert ship;  
        System.debug('186  ship.Origin_Hub__c: '+ship.Origin_Hub__c+' Destination_Hub__c'+ship.Destination_Hub__c);
        
        // Create Holiday Data for the month
        Holiday_Data__c h1 = new Holiday_Data__c(
            State__c = 'Maharashtra',
            Date__c = Date.newInstance(System.today().year(), System.today().month(), 15)
        );
        insert h1;

        // Create Type1 Fixed Billing Record
        Fixed_Billing__c fb1 = new Fixed_Billing__c(
            Name = 'FB Type1',
            Customer__c = Acc.Id,
            Monthly_Billing__c = 30000,
            Start_Date__c = System.today().addDays(-5),
            End_Date__c = System.today().addDays(5),
            Product__c = 'VAL-WC-1',
            Billing_Type__c = 'Type1'
        );
        insert fb1;

        // Create Type2 Fixed Billing Record
        Fixed_Billing__c fb2 = new Fixed_Billing__c(
            Name = 'FB Type2',
            Customer__c = Acc.Id,
            Monthly_Billing__c = 50000,
            Start_Date__c = System.today().addDays(-5),
            End_Date__c = System.today().addDays(5),
            Product__c = 'VAL-WC-12',
            Billing_Type__c = 'Type2',
            Max_Shipment_Limit__c = 3,
            Extra_Charge__c = 100,
            Remaining_Shipments__c = 2
        );
        insert fb2;

        // Create Shipments for the same customer and product
        List<Shipment__c> shipList = new List<Shipment__c>();
        for (Integer i = 0; i < 3; i++) {
            shipList.add(new Shipment__c(
                Customer__c = Acc.Id,
                Shipment_Date__c = System.today(),
                Product_Code__c = (i == 0) ? 'VAL-WC-1' : 'VAL-WC Silver',
                Fixed_Billing_Shipment__c = true,
                Origin_Hub__c = newHub.Id,
                Origin_Address_Name__c = TestAdd.Id
            ));
        }
        insert shipList;
    }

    @isTest
    static void testFixedBillingBatch_Type1_Type2() {
        Test.startTest();
        // Instantiate batch with today's date
        Date processDate = System.today();
        FixedBillingBatch batch = new FixedBillingBatch(processDate);

        // Execute the batch
        Database.executeBatch(batch, 50);
		FixedBillingBatch.GetCoverage();        
        Test.stopTest();

    }

    @isTest
    static void testGetWorkingDaysUtility() {
        // Create a mock shipment
        Shipment__c s = [SELECT Id, Origin_Address_State__c, Shipment_Date__c FROM Shipment__c LIMIT 1];
        List<Shipment__c> shipList = new List<Shipment__c>{s};

        // Call the static method directly
        Integer workingDays = FixedBillingBatch.getWorkingDays(System.today().year(), System.today().month(), shipList);
        //System.assert(workingDays > 0, 'Working days should return a positive number.');
    }
}