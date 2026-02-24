@isTest
public class autoEY_TaxIntegrationQueueableTest {
    
    @testSetup
    static void setup() {
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        BVCInvoice__c invoice1 = new BVCInvoice__c(
            Account__c = BillingAcc.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Success',
            Billing_Address__c = regularAddress.Id
        );
        BVCInvoice__c invoice2 = new BVCInvoice__c(
            Account__c = BillingAcc.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Success',
            Billing_Address__c = sezAddress.Id
        );
        insert new List<BVCInvoice__c>{invoice1, invoice2};

    }

    @isTest
    static void testQueueableExecution() {
        List<BVCInvoice__c> invoices = [SELECT Id FROM BVCInvoice__c LIMIT 2];

        autoEY_TaxIntegrationQueueable queueable = new autoEY_TaxIntegrationQueueable(invoices);

        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

    }

}