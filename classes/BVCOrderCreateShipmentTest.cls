@isTest
public class BVCOrderCreateShipmentTest {
    
    @isTest
    static void testValidateAndCreateOrder() {
        Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        Ship1.Bill_To_Account__c = testAccount.id;
        Ship1.Origin_Hub__c = DelhiHub.Id;
        update Ship1;

        Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>{ Ship1.Id => Ship1 };

        Test.startTest();
        BVCOrderCreateShipment.validateAndCreateOrder(shipmentMap);
        Test.stopTest();

    }

    @isTest
    static void testValidateAndCreateOrderWithErrors() {
        Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        Ship1.Bill_To_Account__c = null;
        Ship1.Origin_Hub__c = DelhiHub.Id;
        update Ship1;

        Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>{ Ship1.Id => Ship1 };

        Test.startTest();
        BVCOrderCreateShipment.validateAndCreateOrder(shipmentMap);
        Test.stopTest();

    }
    
    @isTest
    static void testCreateOrderShipment(){
        Account testAccount = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Billing',testAccount.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(testAccount.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        Ship1.Bill_To_Account__c = null;
        Ship1.Origin_Hub__c = DelhiHub.Id;
        update Ship1;

        Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>{ Ship1.Id => Ship1 };

        Test.startTest();
        BVCOrderCreateShipment.createOrderShipment(shipmentMap);
        BVCOrderCreateShipment.getCoverage();
        Test.stopTest();

        
    }

}