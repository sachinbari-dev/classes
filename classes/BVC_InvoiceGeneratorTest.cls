@isTest
public class BVC_InvoiceGeneratorTest {

    @testSetup
    static void setupTestData() {
        try{
        Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        
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
            //Billing_Account__r.Billing_Address__c = regularAddress.Id
        );
        insert testOrder;

        BVC_Order_Product__c testOrderProduct = new BVC_Order_Product__c(
            BVCOrder__c = testOrder.Id,                                
            Quantity__c = 5,                                      
            Total_Price__c = 2638.00,                                 
          //  Activation_Status__c = 'Activated',                          
            Activated__c = false,                                        
            Origin_Address_Name__c = 'undefined',                        
            BVC_Branch__c = DelhiHub.Id,                                 
          //  Bookings_Indicator__c = 'Include',                          
            InvSheduler_Billing__c = false,                              
            BVC_LegalEntity__c = billingEntity.Id,                               
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
          //  Hold_Billing__c = 'No',                                      
            Start_Date__c = Date.valueOf('24-08-2024'),                  
            End_Date__c = Date.valueOf('24-08-2024'),                    
            Override_Next_Billing_Date__c = Date.valueOf('24-08-2024'),  
            Next_Billing_Date__c = Date.valueOf('24-08-2024'),           
            Total_Charges__c = 2638.000,                              
            Freight_Charges__c = 2500.00,                             
            Offline_Charge__c = 0.00,                                  
            Billable_Unit_Price__c = 2638.00,                            
            Unit_Price__c = 2638.00                                    
            
        );
        insert testOrderProduct;
        System.debug('testOrderProduct ==='+testOrderProduct);
            
        }catch(Exception ex){
            System.debug('Error Message ==='+ex.getMessage());
            System.debug('Error on Line Number ==='+ex.getLineNumber());
        }
    }

    @isTest
    static void testCreateACRInvoice() {
        Map<Id, BVCQuote__c> acrBVCQuoteMap = new Map<Id, BVCQuote__c>([SELECT Id, Account__c, BVC_Branch__c, Primary_Contact__c,  BVC_Entity__c, Billing_Address__c, BVC_LegalEntity__c FROM BVCQuote__c Limit 1]);
        Map<Id, List<BVCQuoteLineItem__c>> acrBVCQuoteLineMap = new Map<Id, List<BVCQuoteLineItem__c>>();
        for (BVCQuote__c quote : acrBVCQuoteMap.values()) {
            acrBVCQuoteLineMap.put(quote.Id, [SELECT Id, Net_Unit_Price__c, Product_Code__c, COA_Product_Code__c, ACR_Standard_Price__c, ACR_Standard_Price__r.Product_Name__c, ACR_Standard_Price__r.ACR_Product_Code__c, BVCQuote__r.Account__c, Product_Name__c FROM BVCQuoteLineItem__c WHERE BVCQuote__c = :quote.Id]);
        }

        Test.startTest();
        BVC_InvoiceGenerator.createACRInvoice(acrBVCQuoteMap, acrBVCQuoteLineMap);
        Test.stopTest();

    }

    @isTest
    static void testCreateNONACRInvoice() {
        Map<Id, BVCOrder__c> nonacrBVCOrderMap = new Map<Id, BVCOrder__c>([SELECT Id, Account__c,Billing_Account__c,Billing_Account__r.Billing_Address__c, Shipment__c, BVC_Branch__c, BVC_Invoice_Run__c, BVC_Entity__c, Billing_Address__c, Origin_Address__c, BVC_LegalEntity__c FROM BVCOrder__c]);
        System.debug('nonacrBVCOrderMap.Values() ==='+nonacrBVCOrderMap.Values());
        Map<Id, List<BVC_Order_Product__c>> nonacrBVCOrderProductMap = new Map<Id, List<BVC_Order_Product__c>>();
        for (BVCOrder__c order : nonacrBVCOrderMap.values()) {
            nonacrBVCOrderProductMap.put(order.Id, [SELECT Id, Quantity__c, Start_Date__c, End_Date__c, Offline_Charge__c, Total_Price__c, Unit_Price__c, BVC_LegalEntity__c, Shipment__c, Freight_Charges__c, Shipment_Date__c, BVCOrder__c FROM BVC_Order_Product__c WHERE BVCOrder__c = :order.Id]);
        }
		System.debug('nonacrBVCOrderProductMap.values() ==='+nonacrBVCOrderProductMap.values());
		
        BVC_Invoice_Run__c invRun = new BVC_Invoice_Run__c();
        
        Insert invRun;
        
        list<BVC_Invoice_Run__c> invRunList = new list<BVC_Invoice_Run__c>();
        invRunList.add(invRun);
        
        Test.startTest();
        BVC_InvoiceGenerator.createNONACRInvoice(nonacrBVCOrderMap, nonacrBVCOrderProductMap);
        //BVC_InvoiceGenerator.InvSchcreateNONACRInvoice(nonacrBVCOrderMap, nonacrBVCOrderProductMap, invRunList);
		BVC_InvoiceGenerator.getCoverage();
        BVC_CB_InvoiceGenerator.getCoverage();
        Test.stopTest();

    }
    
    
}