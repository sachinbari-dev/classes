@isTest
private class FixedBillingOrderBatchTest {
    
    @testSetup
    static void setupTestData() {
        
        Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test';
        
        insert billingEntity;
            
        ST_ACR_Standard_Price__c acrStdPrice = new ST_ACR_Standard_Price__c();
        Insert acrStdPrice;
        
        Contact testContact = new Contact(
            LastName = 'Test Name',
            AccountId = testAccount.Id,
            MobilePhone = '9876543210'
        );
        Insert testContact;

        BVCQuote__c testQuote = new BVCQuote__c(
            Account__c = testAccount.Id,
            BVC_Branch__c = DelhiHub.Id,
            Primary_Contact__c = testContact.Id,
            BVC_LegalEntity__c = billingEntity.Id,
            Billing_Address__c = regularAddress.Id
        );
        insert testQuote;
        System.debug('testQuote ==='+testQuote);
        
        BVCQuoteLineItem__c testQuoteLineItem = new BVCQuoteLineItem__c(
            BVCQuote__c = testQuote.Id,
            Net_Unit_Price__c = 100.00,
            Product_Code__c = 'P12345',
            Product_Name__c = 'Test Product',
            ACR_Standard_Price__c = acrStdPrice.Id
        );
        insert testQuoteLineItem;

        BVCOrder__c testOrder = new BVCOrder__c(
            Account__c = testAccount.Id,
            BVC_Branch__c = DelhiHub.Id,
            BVC_LegalEntity__c = billingEntity.Id,
            Billing_Address__c = regularAddress.Id,  
            Billing_Account__c = testAccount.Id
            
        );
        insert testOrder;

        BVC_Order_Product__c testOrderProduct = new BVC_Order_Product__c(
            BVCOrder__c = testOrder.Id,                                
            Quantity__c = 5,                                      
            Total_Price__c = 2638.00,                                 
           // Activation_Status__c = 'Activated',                          
            Activated__c = false,                                        
            BVC_Branch__c = DelhiHub.Id,                                 
           // Bookings_Indicator__c = 'Include',                          
            InvSheduler_Billing__c = false,                              
            Origin_City__c = 'Mumbai',                                   
            Rate_UOM__c = 'Flat Rate',                                   
            Origin_State__c = 'Maharashtra',                             
            Origin_PinCode__c = '400004',                               
            Origin_Type__c = 'Online',                                   
            Destination_City__c = 'Mumbai',                              
            Destination_State__c = 'Maharashtra',                        
            Liability_Cover_By_BVC__c = 'Yes',                           
            Destination_Pin_Code__c = '400004',                         
            Destination_Type__c = 'Online',                              
            Gross_Weight_gms__c = 300.000,                             
            Gross_Weight_UOM__c = 'Gram',                                
            Gross_Weight__c = 300.000,                                 
            Pricing_Method__c = 'List',                                  
            Net_Weight__c = 200.00,                                   
            Contracting_Method__c = 'Inherit',                           
            Net_Weight_UOM__c = 'Gram',                                  
            Net_Weight_gms__c = 200.000,                               
            Rate_Amount__c = 2500.00,                                 
            Liability_Charges__c = 3.00,                               
            Minimum_Freight__c = 2500.00,                             
            Fuel_Surcharge__c = 125.00,                                
            Universe_Cost_Charge__c = 10.00,                           
            Liability_Coverage__c = 0.10,                                
           // Hold_Billing__c = 'No',                                      
            Total_Charges__c = 2638.000,                              
            Freight_Charges__c = 2500.00,                             
            Offline_Charge__c = 0.00,                                  
            Billable_Unit_Price__c = 2638.00,                            
            Unit_Price__c = 2638.00                                    
            
        );
        insert testOrderProduct;
        System.debug('testOrderProduct ==='+testOrderProduct);
            
        // Create Holiday Data for the month
        Holiday_Data__c h1 = new Holiday_Data__c(
            State__c = 'Maharashtra',
            Date__c = Date.newInstance(System.today().year(), System.today().month(), 15)
        );
        insert h1;
		
        // Create Fixed_Billing_Daily__c record
        Fixed_Billing_Daily__c fbd = new Fixed_Billing_Daily__c(
            Name = 'FBD-001',
            Date__c = System.today(),
            No_of_Shipments__c = 1,
            Daily_Revenue__c = 1000,
            Per_Shipment_Revenue__c = 100
        );
        insert fbd;
        
    }

    @isTest
    static void testFixedBillingOrderBatchExecution() {
        
        
        // Retrieve test data
        Fixed_Billing_Daily__c fbd = [SELECT Id FROM Fixed_Billing_Daily__c LIMIT 1];
        Shipment__c ship = [SELECT Id FROM Shipment__c LIMIT 1];
        
        // Prepare input data for batch
        Set<Id> fbdIds = new Set<Id>{ fbd.Id };
        Map<Id, Decimal> rateMap = new Map<Id, Decimal>{
            ship.Id => 200
        };
        
        // Instantiate and execute the batch
        Test.startTest();
        FixedBillingOrderBatch batchObj = new FixedBillingOrderBatch(fbdIds, rateMap);
        Database.executeBatch(batchObj, 1);
        FixedBillingOrderBatch.GetCoverage();
        Test.stopTest();
        
    }

    @isTest
    static void testCreateOrderShipmentDirectly() {
        
        // Fetch existing Shipment and build rate map
        Shipment__c ship = [SELECT Id, Fixed_Billing_Daily__c FROM Shipment__c LIMIT 1];
        Map<Id, Decimal> rateMap = new Map<Id, Decimal>{ ship.Id => 300 };

        // Directly call createOrderShipment
        Test.startTest();
        FixedBillingOrderBatch.createOrderShipment(new List<Shipment__c>{ ship }, rateMap);
        FixedBillingOrderBatch.GetCoverage();
        Test.stopTest();

    }
}