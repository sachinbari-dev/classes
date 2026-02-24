@isTest
public class FixedBillingInvoiceBatchTest {
    
    @testSetup
    static void setupData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account',last_name__c='Test');
        insert acc;
        
        // Create Legal Entity
        BVC_LegalEntity__c le = new BVC_LegalEntity__c(Name = 'Test Legal Entity');
        insert le;
        
        // Create Invoice Run with date range
        BVC_Invoice_Run__c run = new BVC_Invoice_Run__c(
            Name = 'Test Run',
            Lock_this_Invoice_Run__c = false,
            Customer__c = acc.Id,
            From__c = Date.today().addDays(-30),
            To__c   = Date.today()
        );
        insert run;
        
        // Create Shipment
        Shipment__c shipment = new Shipment__c(
            product_code__c = 'VAL-WC-1',
            customer__c = acc.Id
        );
        insert shipment;
        
        //  Order inside date range (should be picked up)
        BVCOrder__c orderInRange = new BVCOrder__c(
            Account__c = acc.Id,
            Billing_status__c = 'Pending',
            fixed_billing_order__c = true,
            billing_account__c = acc.Id,
            BVC_LegalEntity__c = le.Id,
            Shipment_Date__c = Date.today().addDays(-10), // inside From-To
            BVC_Invoice_Run__c = run.Id,
            Shipment__c = shipment.Id,
            Status__c = 'Draft'
        );
        insert orderInRange;
        
        //  Order outside date range (should NOT be picked up)
        BVCOrder__c orderOutOfRange = new BVCOrder__c(
            Account__c = acc.Id,
            Billing_status__c = 'Pending',
            fixed_billing_order__c = true,
            billing_account__c = acc.Id,
            BVC_LegalEntity__c = le.Id,
            Shipment_Date__c = Date.today().addDays(-40), // outside From-To
            BVC_Invoice_Run__c = run.Id,
            Shipment__c = shipment.Id,
            Status__c = 'Draft'
        );
        insert orderOutOfRange;
        
        // Create Order Product linked to in-range order
        BVC_Order_Product__c op = new BVC_Order_Product__c(
            BVCOrder__c = orderInRange.Id,
            Billing_status__c = 'Pending',
            Quantity__c = 1,
            Freight_Charges__c = 500,
            Total_Charges__c = 500,
            Shipment__c = shipment.Id
        );
        insert op;
    }
    
    @isTest
    static void testBatchInvoiceCreation() {
        // Query setup data
        BVC_Invoice_Run__c run = [SELECT Id FROM BVC_Invoice_Run__c LIMIT 1];
        
        Test.startTest();
        //  Call Helper instead of direct batch instantiation
        FixedBillingHelper.getOrderids(new List<String>{ run.Id });
        Test.stopTest();
        
        // Assertions
        List<BVCInvoice__c> invoices = [SELECT Id, Status__c, Product_Code__c FROM BVCInvoice__c];
        System.assert(!invoices.isEmpty(), 'Invoice should be created for in-range order');
        System.assertEquals('Draft', invoices[0].Status__c, 'Invoice should be Draft');
        
        List<BVCInvoiceLineItem__c> lines = [SELECT Id, BVC_Order_Product__c FROM BVCInvoiceLineItem__c];
        System.assertEquals(1, lines.size(), 'Only one invoice line should be created (for in-range order)');
        
        BVC_Order_Product__c op = [SELECT Id, Billing_status__c FROM BVC_Order_Product__c LIMIT 1];
        System.assertEquals('Completed', op.Billing_status__c, 'Order Product should be marked completed');
        
        BVCOrder__c ord = [SELECT Id, Billing_status__c FROM BVCOrder__c WHERE Shipment_Date__c = :Date.today().addDays(-10) LIMIT 1];
        System.assertEquals('Completed', ord.Billing_status__c, 'In-range order should be marked completed');
        
        Shipment__c s = [SELECT Id, Status__c FROM Shipment__c LIMIT 1];
        System.assertEquals('Billed', s.Status__c, 'Shipment should be updated to Billed');
        
        BVC_Invoice_Run__c runAfter = [SELECT Id, Total_Invoice_Lines__c FROM BVC_Invoice_Run__c LIMIT 1];
        System.assertEquals(1, runAfter.Total_Invoice_Lines__c, 'Invoice run should count only in-range order line');
        
        // Extra check: Out-of-range order should stay pending
        BVCOrder__c ordOut = [SELECT Id, Billing_status__c FROM BVCOrder__c WHERE Shipment_Date__c = :Date.today().addDays(-40) LIMIT 1];
        System.assertEquals('Pending', ordOut.Billing_status__c, 'Out-of-range order should not be billed');
    }
}