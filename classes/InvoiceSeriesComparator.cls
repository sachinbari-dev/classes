public class InvoiceSeriesComparator implements Comparator<BVCInvoice__c> {
    /*public Integer compare(BVCInvoice__c a, BVCInvoice__c b) {
        System.debug('for checking new a.ST_Invoice_Series__c '+a.ST_Invoice_Series__c);
        System.debug('for checking new b.ST_Invoice_Series__c '+b.ST_Invoice_Series__c);
        return b.ST_Invoice_Series__c.compareTo(a.ST_Invoice_Series__c);
    }*/
    
    public Integer compare(BVCInvoice__c a, BVCInvoice__c b) {
        Long numA = extractNumericPart(a.ST_Invoice_Series__c);
        Long numB = extractNumericPart(b.ST_Invoice_Series__c);

        System.debug('Extracted Numeric A: ' + numA + ' from ' + a.ST_Invoice_Series__c);
        System.debug('Extracted Numeric B: ' + numB + ' from ' + b.ST_Invoice_Series__c);

        return numB > numA ? 1 : (numB < numA ? -1 : 0);
    }

    private Long extractNumericPart(String invoiceSeries) {
        if (String.isBlank(invoiceSeries)) {
            return 0;
        }
        String numericPart = invoiceSeries.replaceAll('\\D+', '');
        
        return String.isBlank(numericPart) ? 0 : Long.valueOf(numericPart);
    }
}