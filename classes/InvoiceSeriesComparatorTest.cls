@isTest
public class InvoiceSeriesComparatorTest {
    @isTest
    public static void testInvoiceSeriesComparison() {
        BVCInvoice__c invoice1 = new BVCInvoice__c();
        invoice1.ST_Invoice_Series__c = 'BVCINV-000001';
        
        BVCInvoice__c invoice2 = new BVCInvoice__c();
        invoice2.ST_Invoice_Series__c = 'BVCINV-000002';

        InvoiceSeriesComparator comparator = new InvoiceSeriesComparator();

        Integer result = comparator.compare(invoice1, invoice2);

        System.assert(result > 0, 'Expected invoice2 to be greater than invoice1');

        result = comparator.compare(invoice2, invoice1);

        System.assert(result < 0, 'Expected invoice1 to be less than invoice2');

        BVCInvoice__c invoice3 = new BVCInvoice__c();
        invoice3.ST_Invoice_Series__c = 'BVCINV-000002';
        
        result = comparator.compare(invoice2, invoice3);

        System.assertEquals(0, result, 'Expected both invoices to be considered equal');
    }
}