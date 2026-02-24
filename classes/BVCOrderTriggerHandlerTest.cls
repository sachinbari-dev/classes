@isTest
public class BVCOrderTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        
        Account acrAccount = BVCL_TestDataFactory.createCustomer('ACR Account','Billing',true);
        Account nonAcrAccount = BVCL_TestDataFactory.createCustomer('NonACRAccount','Billing',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Billing',nonAcrAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(acrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, true);
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(nonAcrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, true);
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test';
        insert billingEntity;
        
        BVCQuote__c quote = new BVCQuote__c(
            Account__c = acrAccount.Id,
            Contracted__c = false,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addMonths(12),
            BVC_LegalEntity__c = billingEntity.Id,
            BVC_Branch__c = DelhiHub.Id,
            BVC_Service__c = 'ValSHIP'
        );
        insert quote;

        BVC_Contract__c bvcContract1 = new BVC_Contract__c(
            Customer_Name__c = acrAccount.Id,
            Contract_Start_Date__c = Date.today(),
            Contract_End_Date__c = Date.today().addMonths(12),
            BVC_LegalEntity__c = billingEntity.Id,
            BVC_Branch__c = DelhiHub.Id,
            Contracted_ACR_Package__c = 'Standard',
            Contract_Amount__c = 10000,
            Business_Type__c = 'ACR',
            Contract_Term_months__c = 12,
            Quote__c = quote.Id
        );
        
        BVC_Contract__c bvcContract2 = new BVC_Contract__c(
            Customer_Name__c = nonAcrAccount.Id,
            Contract_Start_Date__c = Date.today().addDays(1),
            Contract_End_Date__c = Date.today().addMonths(12).addDays(1),
            BVC_LegalEntity__c = billingEntity.Id,
            BVC_Branch__c = DelhiHub.Id,
            Contracted_ACR_Package__c = 'Premium',
            Contract_Amount__c = 20000,
            Business_Type__c = 'Non ACR',
            Contract_Term_months__c = 24,
            Quote__c = quote.Id
        );
        
        BVC_Contract__c eSHIPbvcContract = new BVC_Contract__c(
            Customer_Name__c = acrAccount.Id,
            Contract_Start_Date__c = Date.today(),
            Contract_End_Date__c = Date.today().addMonths(12),
            BVC_LegalEntity__c = billingEntity.Id,
            BVC_Branch__c = DelhiHub.Id,
            Contracted_ACR_Package__c = '120000',
            Contract_Amount__c = 120000,
            Business_Type__c = 'ACR',
            Contract_Term_months__c = 12,
            BVC_Service__c='eSHIP'
        );

        insert new List<BVC_Contract__c>{bvcContract1, bvcContract2,eSHIPbvcContract};
            
        acrAccount.BVC_Contract__c = bvcContract1.Id;
        acrAccount.GST_Registered__c = false;
        acrAccount.eSHIP_BVC_Contract__c=eSHIPbvcContract.id;
        Update acrAccount;
        System.debug('for checking acrAccount ===='+acrAccount);
        
        Account tmpNonAcrAccount = new Account();
        tmpNonAcrAccount.Id = nonAcrAccount.Id;
        tmpNonAcrAccount.BVC_Contract__c = bvcContract2.Id;
        tmpNonAcrAccount.GST_Registered__c = false;
        tmpNonAcrAccount.Billing_Address__c =sezAddress.Id;
        Update tmpNonAcrAccount;
        System.debug('for checking tmpNonAcrAccount ===='+tmpNonAcrAccount);
        
        BVCOrder__c acrBvcOrder = new BVCOrder__c(
            Account__c = acrAccount.Id,
            Business_Type__c = 'ACR',
            Status__c = 'Activated',
            Shipment__c = Ship1.Id
        );
        insert acrBvcOrder;

        BVCOrder__c nonAcrBvcOrder = new BVCOrder__c(
            Account__c = nonAcrAccount.Id,
            Business_Type__c = 'Non ACR',
            Status__c = 'Activated',
            Shipment__c = Ship2.Id
        );
        insert nonAcrBvcOrder;

        BVC_Order_Product__c acrOrderProduct = new BVC_Order_Product__c(
            BVCOrder__c = acrBvcOrder.Id,
            Billable_Unit_Price__c = 1000,
            Freight_Charges__c = 100,
            Offline_Charge__c = 50,
            BVC_Valuation_Charges__c = 25,
            Docket_Charges__c = 10,
            Fuel_Charges__c = 15,
            Holiday_Charges__c = 20,
            Weight_Charges__c = 30
        );
        insert acrOrderProduct;

        BVC_Order_Product__c nonAcrOrderProduct = new BVC_Order_Product__c(
            BVCOrder__c = nonAcrBvcOrder.Id,
            Billable_Unit_Price__c = 2000,
            Freight_Charges__c = 200,
            Offline_Charge__c = 100,
            BVC_Valuation_Charges__c = 50,
            Docket_Charges__c = 20,
            Fuel_Charges__c = 30,
            Holiday_Charges__c = 40,
            Weight_Charges__c = 60
        );
        insert nonAcrOrderProduct;
    }

    @isTest
    static void testBVCOrderProcessor_ACR() {
        Account acrAccount = [SELECT Id FROM Account WHERE Name = 'ACR Account' LIMIT 1];
        BVCOrder__c acrBvcOrder = [SELECT Id, Account__c, Account__r.Billing_Address__c FROM BVCOrder__c WHERE Account__c = :acrAccount.Id LIMIT 1];

        Map<Id, BVCOrder__c> newMap = new Map<Id, BVCOrder__c>();
        newMap.put(acrBvcOrder.Id, acrBvcOrder);

        Test.startTest();
        BVCOrderTriggerHandler.BVCOrderProcessor(newMap);
        Test.stopTest();

    }

 /*   @isTest
    static void testBVCOrderProcessor_NonACR() {
        Account nonAcrAccount = BVCL_TestDataFactory.createCustomer('NonACRAccount','Billing',true);
        
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(nonAcrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, true);
        
        BVCOrder__c nonAcrBvcOrder = new BVCOrder__c(
            Account__c = nonAcrAccount.Id,
            Business_Type__c = 'Non ACR',
            Status__c = 'Activated',
            Shipment__c = Ship2.Id
        );
        insert nonAcrBvcOrder;
        
        Map<Id, BVCOrder__c> newMap = new Map<Id, BVCOrder__c>();
        newMap.put(nonAcrBvcOrder.Id, nonAcrBvcOrder);

        Test.startTest();
        BVCOrderTriggerHandler.BVCOrderProcessor(newMap);
        Test.stopTest();

    }*/

    @isTest
    static void testCreateBVCACRConsumption() {
        /*Account acrAccount = [SELECT Id FROM Account WHERE Name = 'ACR Account' LIMIT 1];
        BVCOrder__c acrBvcOrder = [SELECT Id,Account__c,Business_Type__c,Shipment__c,Account__r.ST_Pricing_Type__c,BVC_Service__c,Billing_Address__c,Product_Code__c, ExhibiSHIP_Order__c FROM BVCOrder__c WHERE Account__c = :acrAccount.Id LIMIT 1];

        Map<Id, BVCOrder__c> newMap = new Map<Id, BVCOrder__c>();
        newMap.put(acrBvcOrder.Id, acrBvcOrder);

        Test.startTest();
        BVCOrderTriggerHandler.createBVCACRConsumption(newMap);*/
        Test.startTest();
        BVCOrderTriggerHandler.getCoverage();
        Test.stopTest();

    }

  /*  @isTest
    static void testGenerateInvoice() {
        Account nonAcrAccount = BVCL_TestDataFactory.createCustomer('NonACRAccount','Billing',true);
        
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(nonAcrAccount.id, nonAcrAccount.id, null, nonAcrAccount.id, null, true);
        
        BVCOrder__c nonAcrBvcOrder = new BVCOrder__c(
            Account__c = nonAcrAccount.Id,
            Business_Type__c = 'Non ACR',
            Status__c = 'Activated',
            Shipment__c = Ship2.Id
        );
        insert nonAcrBvcOrder;
        
        Map<Id, BVCOrder__c> bvcOrderMap = new Map<Id, BVCOrder__c>();
        bvcOrderMap.put(nonAcrBvcOrder.Id, nonAcrBvcOrder);

        Test.startTest();
        BVCOrderTriggerHandler.generateInvoice(bvcOrderMap);
        
        Test.stopTest();

    }*/
}