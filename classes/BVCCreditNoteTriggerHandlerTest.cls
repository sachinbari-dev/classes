@IsTest
public class BVCCreditNoteTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test';
        
        insert billingEntity;

        BVCInvoice__c bvcInvoice = new BVCInvoice__c();
        bvcInvoice.BVC_LegalEntity__c = billingEntity.Id;
        bvcInvoice.Account__c = BillingAcc.Id;
        bvcInvoice.Total_Credit_Notes__c = 2;
        
        insert bvcInvoice;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = bvcInvoice.Id;
        invLineItem.Subtotal__c = 10000;  
        
        Insert invLineItem;
        
        BVCCreditNote__c creditNote = new BVCCreditNote__c();
        creditNote.Account__c = BillingAcc.Id;
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        creditNote.BVC_LegalEntity__c = bvcInvoice.BVC_LegalEntity__c;
        
        insert creditNote;
        
      
    }

    @IsTest
    static void testAmountsInWordConversion() {
        List<BVCCreditNote__c> creditNotes = [SELECT Id, TotalAmount__c, Total_Amount_In_Words__c, BVC_LegalEntity__c FROM BVCCreditNote__c];
        
        Test.startTest();
        BVCCreditNoteTriggerHandler.amountsInWordConversion(creditNotes, new Map<Id, BVCCreditNote__c>(creditNotes));
        BVCCreditNoteTriggerHandler.getCoverage();
        Test.stopTest();
        
    }
    
    @IsTest
    static void testUpdateEmailRecepients() {
        List<BVCCreditNote__c> creditNotes = [SELECT Id, Account__c, Email_Recepients__c, BVCInvoice__c, BVC_LegalEntity__c FROM BVCCreditNote__c];
        
        Test.startTest();
        BVCCreditNoteTriggerHandler.updateEmailRecepients(creditNotes);
        Test.stopTest();
        
    }

    @IsTest
    static void testGstSerialNumberUpdate() {
        List<BVCCreditNote__c> creditNotes = [SELECT Id, BVC_CB_Is_CB_CreditNote_c__c, Credit_Note_Type__c, CreditNote_Serial_No__c, BVCInvoice__c, RecordTypeId, BVC_LegalEntity__c FROM BVCCreditNote__c];
       
        Test.startTest();
        BVCCreditNoteTriggerHandler.gstSerialNumberUpdate(creditNotes);
        Test.stopTest();
        
    }

    @IsTest
    static void testValidateCreditAmount() {
        List<BVCCreditNote__c> creditNotes = [SELECT Id, Subtotal__c, BVC_LegalEntity__c FROM BVCCreditNote__c];
        
        Test.startTest();
        BVCCreditNoteTriggerHandler.ValidateCreditAmount(creditNotes, new Map<Id, BVCCreditNote__c>(creditNotes));
        Test.stopTest();
        
    }
    
    @IsTest
    static void testCallEYTaxCal() {
        List<BVCCreditNote__c> creditNotes = [SELECT Id, Approval_Status__c, RecordTypeId, BVC_LegalEntity__c FROM BVCCreditNote__c];
        
        Test.startTest();
        BVCCreditNoteTriggerHandler.callEYTaxCal(creditNotes, new Map<Id, BVCCreditNote__c>(creditNotes));
        Test.stopTest();
        
    }
}