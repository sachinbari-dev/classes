@IsTest
public class BVCInvoiceTriggerTest {

    @TestSetup
    static void setupData() {
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        BVCInvoice__c invoice = new BVCInvoice__c(
            Account__c = BillingAcc.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Pending',
            Billing_Address__c = regularAddress.Id,
            BVC_CB_IsTaxPosted__c = false
        );
        insert invoice;
    }

    @IsTest
    static void testBeforeUpdateScenario() {
        BVCInvoice__c invoice = [SELECT Id FROM BVCInvoice__c LIMIT 1];
        
        update invoice;
        
    }

    @IsTest
    static void testAfterUpdateScenario() {
        BVCInvoice__c invoice = [SELECT Id,Status__c,BVC_CB_IsTaxPosted__c FROM BVCInvoice__c LIMIT 1];
        invoice.Status__c = 'Posted';
        invoice.BVC_CB_IsTaxPosted__c = true;
        update invoice;
        
    }

    @IsTest
    static void testBeforeInsertScenario() {
        Account testBilling = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account testShipping = BVCL_TestDataFactory.createCustomer('BVCLShip Customer','Shipping',false);
        testShipping.PAN_Number_of_Entity__c = 'ZABCD6398D';
        Insert testShipping;
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('653420', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',testShipping.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        BVCInvoice__c invoice = new BVCInvoice__c(
            Account__c = testBilling.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Pending',
            Billing_Address__c = regularAddress.Id
        );
        insert invoice;
    }

    @IsTest
    static void testAfterInsertScenario() {
        Account billingAccTest = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShippingAccTest = BVCL_TestDataFactory.createCustomer('BVCLShipment Customer','Shipping',false);
        ShippingAccTest.PAN_Number_of_Entity__c = 'ZABCD6777D';
        Insert ShippingAccTest;
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('569832', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShippingAccTest.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        BVCInvoice__c invoice = new BVCInvoice__c(
            Account__c = billingAccTest.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Pending',
            Billing_Address__c = regularAddress.Id
        );
        insert invoice;
    }

    @IsTest
    static void testNoEYTaxIntegrationWhenInvoiceRunNotNull() {
        Account testBillAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account testShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',false);
        testShipperAcc.PAN_Number_of_Entity__c = 'ZAQWD6398D';
        Insert testShipperAcc;
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('MUMBAI', true, 'MUMBAI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('400362', DelhiHub.id, 'MUMBAI', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',testShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        BVCInvoice__c invoice = new BVCInvoice__c(
            Account__c = testBillAcc.Id,
            Billing_Address__c = regularAddress.Id
        );
        insert invoice;
    }
}