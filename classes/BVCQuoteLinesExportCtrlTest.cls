@isTest
public class BVCQuoteLinesExportCtrlTest {

    @isTest
    static void testExportWithData() {
        // Create Product (Lookup target)
        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        insert prod;

        // Create test BVC Quote
        BVCQuote__c quote = new BVCQuote__c(
           
        );
        insert quote;

        // Create test Quote Line
        BVCQuoteLineItem__c qli = new BVCQuoteLineItem__c(
            BVCQuote__c = quote.Id,
            Product__c = prod.Id, // lookup reference
            Quantity__c = 5,
           
            All_Risk_Liability__c = 10,
            Fidelity_Liability__c = 20,
            Max_Discount__c = 5
        );
        insert qli;

        // Simulate VF Page Request
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', quote.Id);

        BVCQuoteLinesExportCtrl ctrl = new BVCQuoteLinesExportCtrl();
        String csvData = ctrl.getCsvData();
        Test.stopTest();


       

    }

    @isTest
    static void testExportWithNoData() {
        // Create quote without line items
        BVCQuote__c quote = new BVCQuote__c(
        );
        insert quote;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', quote.Id);

        BVCQuoteLinesExportCtrl ctrl = new BVCQuoteLinesExportCtrl();
        String csvData = ctrl.getCsvData();
        Test.stopTest();

    }
}