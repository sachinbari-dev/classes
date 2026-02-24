@IsTest
public class BVCCreditNoteTriggerTest {

    @TestSetup
    static void setupData() {
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        
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
        invLineItem.Subtotal__c = 30;  
        
        Insert invLineItem;
        
        BVCCreditNote__c creditNote = new BVCCreditNote__c();
        creditNote.Account__c = BillingAcc.Id;
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        creditNote.BVC_LegalEntity__c = billingEntity.Id;
        
        insert creditNote;
    }

    @IsTest
    static void testBeforeInsertScenario() {
        Account TestBilling = BVCL_TestDataFactory.createCustomer('BVCLBilling Customer','Billing',true);
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test1';
        
        insert billingEntity;

        BVCInvoice__c bvcInvoice = new BVCInvoice__c();
        bvcInvoice.BVC_LegalEntity__c = billingEntity.Id;
        bvcInvoice.Account__c = TestBilling.Id;
        bvcInvoice.Total_Credit_Notes__c = 3;
        
        insert bvcInvoice;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = bvcInvoice.Id;
        invLineItem.Subtotal__c = 25;  
        
        Insert invLineItem;
        
        BVCCreditNote__c creditNote = new BVCCreditNote__c();
        creditNote.Account__c = TestBilling.Id;
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        creditNote.BVC_LegalEntity__c = billingEntity.Id;
        
        insert creditNote;
    }

    @IsTest
    static void testBeforeUpdateScenario() {
        Account TestBillAcc = BVCL_TestDataFactory.createCustomer('TestBillAcc Customer','Billing',true);
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test11';
        
        insert billingEntity;

        BVCInvoice__c bvcInvoice = new BVCInvoice__c();
        bvcInvoice.BVC_LegalEntity__c = billingEntity.Id;
        bvcInvoice.Account__c = TestBillAcc.Id;
        bvcInvoice.Total_Credit_Notes__c = 2;
        
        insert bvcInvoice;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = bvcInvoice.Id;
        invLineItem.Subtotal__c = 15;  
        
        Insert invLineItem;
        
        BVCCreditNote__c creditNote = [SELECT Id, Account__c, BVCInvoice__c, Credit_Note_Type__c FROM BVCCreditNote__c LIMIT 1];
        
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        creditNote.BVC_LegalEntity__c = billingEntity.Id;
        
        update creditNote;
        
    }

    @IsTest
    static void testAfterUpdateScenario() {
        Account TestBillAccc = BVCL_TestDataFactory.createCustomer('TestBillAccc Customer','Billing',true);
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test111';
        
        insert billingEntity;

        BVCInvoice__c bvcInvoice = new BVCInvoice__c();
        bvcInvoice.BVC_LegalEntity__c = billingEntity.Id;
        bvcInvoice.Account__c = TestBillAccc.Id;
        bvcInvoice.Total_Credit_Notes__c = 3;
        
        insert bvcInvoice;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = bvcInvoice.Id;
        invLineItem.Subtotal__c = 20;  
        
        Insert invLineItem;
        
        BVCCreditNote__c creditNote = [SELECT Id, Account__c, BVCInvoice__c, Credit_Note_Type__c FROM BVCCreditNote__c LIMIT 1];
        
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        creditNote.BVC_LegalEntity__c = billingEntity.Id;
        
        update creditNote;
    }

    @IsTest
    static void testNoProcessingWhenNoChange() {
        Account TestBillAcc = BVCL_TestDataFactory.createCustomer('TestBillAcc Customer','Billing',true);
        
        BVC_LegalEntity__c billingEntity = new BVC_LegalEntity__c();
        billingEntity.Name = 'test11';
        
        insert billingEntity;

        BVCInvoice__c bvcInvoice = new BVCInvoice__c();
        bvcInvoice.BVC_LegalEntity__c = billingEntity.Id;
        bvcInvoice.Account__c = TestBillAcc.Id;
        bvcInvoice.Total_Credit_Notes__c = 2;
        
        insert bvcInvoice;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = bvcInvoice.Id;
        invLineItem.Subtotal__c = 10;  
        
        Insert invLineItem;
        
        BVCCreditNote__c creditNote = [SELECT Id, Account__c, BVCInvoice__c, Credit_Note_Type__c FROM BVCCreditNote__c LIMIT 1];
        
        creditNote.BVCInvoice__c = bvcInvoice.Id;
        creditNote.Credit_Note_Type__c = 'Tax Credit Note';
        creditNote.BVC_LegalEntity__c = billingEntity.Id;
        
        update creditNote;
    }
    
    @IsTest
    static void testCBSeriesGenerationOnUpdate() {
        
        UtilClass.recursionCheck = false; // important
        
        Account acc = BVCL_TestDataFactory.createCustomer('CBTestCustomer','Billing',true);
        
        BVC_LegalEntity__c le = new BVC_LegalEntity__c(Name='LE CB');
        insert le;
        
        BVCInvoice__c inv = new BVCInvoice__c(
            BVC_LegalEntity__c = le.Id,
            Account__c = acc.Id,
            Total_Credit_Notes__c = 1,
            BVC_CB_Is_CB_Invoice__c = true            
        );
        insert inv;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = inv.Id;
        invLineItem.Subtotal__c = 15;  
        
        Insert invLineItem;
        
        BVCCreditNote__c cn = new BVCCreditNote__c(
            Account__c = acc.Id,
            BVCInvoice__c = inv.Id,
            Credit_Note_Type__c = 'Tax Credit Note',
            BVC_LegalEntity__c = le.Id,
            Approval_Status__c = 'Pending'
        );
        insert cn;
        
        // Update to APPROVED → should generate CB serial number
        cn.Approval_Status__c = 'Approved';
        update cn;
    }
    
    @IsTest
    static void testNonCBSerialAfterInsert() {
        
        UtilClass.recursionCheck = false; // required
        
        Account acc = BVCL_TestDataFactory.createCustomer('NonCBAcc','Billing',true);
        
        BVC_LegalEntity__c le = new BVC_LegalEntity__c(Name='LE NON CB');
        insert le;
        
        BVCInvoice__c inv = new BVCInvoice__c(
            BVC_LegalEntity__c = le.Id,
            Account__c = acc.Id,
            Total_Credit_Notes__c = 1,
            BVC_CB_Is_CB_Invoice__c = false            
        );
        insert inv;
        
        BVCInvoiceLineitem__c invLineItem = new BVCInvoiceLineitem__c();
        invLineItem.BVCInvoice__c = inv.Id;
        invLineItem.Subtotal__c = 15;  
        
        Insert invLineItem;
        
        BVCCreditNote__c cn = new BVCCreditNote__c(
            Account__c = acc.Id,
            BVCInvoice__c = inv.Id,
            Credit_Note_Type__c = 'Tax Credit Note',
            BVC_LegalEntity__c = le.Id
        );
        
        insert cn; // triggers AFTER INSERT flow
    }

}