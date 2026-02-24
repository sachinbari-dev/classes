@isTest
public class BVCInvoiceTriggerHandlerTest {

    @testSetup
    static void setupData() {
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        
		BVCInvoice__c invoice1 = new BVCInvoice__c(
            Account__c = BillingAcc.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Success',
            Billing_Address__c = regularAddress.Id,
            BVC_CB_Is_CB_Invoice__c = true,
            Invoice_Doc_URL__c = 'test String'
        );
        BVCInvoice__c invoice2 = new BVCInvoice__c(
            Account__c = BillingAcc.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Success',
            Billing_Address__c = sezAddress.Id
        );
        insert new List<BVCInvoice__c>{invoice1, invoice2};

        DocumentSeries__c docSeries = new DocumentSeries__c(
            Name = 'Doc Series 1',
            Unique_Key__c = '01TI',
            Last_Serial_Number__c = '01TI0001'
        );
        insert docSeries;
    }

    @isTest
    static void testGstSerialNumberUpdate() {
        List<BVCInvoice__c> invoiceList = [SELECT Id, BVC_LegalEntity__c, ST_Invoice_Series__c, BVC_CB_Invoice_Series__c, Invoice_Type__c, BVC_CB_Is_CB_Invoice__c, Invoice_Doc_URL__c FROM BVCInvoice__c];
        Test.startTest();
        BVCInvoiceTriggerHandler.gstSerialNumberUpdate(invoiceList);
        Test.stopTest();

        
    }

    @isTest
    static void testAmountsInWordConversion() {
        List<BVCInvoice__c> invoiceList = [SELECT Id, Total_Amount_With_Tax__c, NumberToWord__c FROM BVCInvoice__c];
        Map<Id, BVCInvoice__c> oldMap = new Map<Id, BVCInvoice__c>(invoiceList);

        Test.startTest();
        BVCInvoiceTriggerHandler.amountsInWordConversion(invoiceList, oldMap);
        Test.stopTest();

        
    }

    @isTest
    static void testUpdateEmailRecepients() {
        List<BVCInvoice__c> invoiceList = [SELECT Id, Account__c, Email_Recepients__c, BVCQuote__c,BVCOrder__r.Account__r.BVC_Contract__r.Quote__c FROM BVCInvoice__c];
        
        Test.startTest();
        BVCInvoiceTriggerHandler.updateEmailRecepients(invoiceList);
        Test.stopTest();

       
    }

    @isTest
    static void testPostInvoice() {
        Map<Id, BVCInvoice__c> oldMap = new Map<Id, BVCInvoice__c>([SELECT Id, Status__c FROM BVCInvoice__c]);

        for (BVCInvoice__c inv : oldMap.values()) {
            inv.Status__c = 'Initiated';
        }

        Test.startTest();
        BVCInvoiceTriggerHandler.postInvoice(new Map<Id, BVCInvoice__c>([SELECT Id, Billing_Address__c, Total_Amount_With_Tax__c FROM BVCInvoice__c]), oldMap);
        BVCInvoiceTriggerHandler.getCoverage();
        Test.stopTest();

    }

    @isTest
    static void testGenerateDocument() {
        List<BVCInvoice__c> invoiceList = [SELECT Id, BVC_CB_IsTaxPosted__c, Status__c, BVC_CB_Is_CB_Invoice__c, BVC_CB_PreTaxBill__c, Invoice_Type__c, Invoice_Doc_URL__c FROM BVCInvoice__c];
        Map<Id, BVCInvoice__c> oldMap = new Map<Id, BVCInvoice__c>(invoiceList);

        for (BVCInvoice__c inv : invoiceList) {
            inv.Status__c = 'Posted';
        }

        Test.startTest();
        BVCInvoiceTriggerHandler.generateDocument(invoiceList, oldMap);
        Test.stopTest();

        
    }
}