public class STInvoiceSeriesComparator implements Comparator<BVCInvoice__c> {
        
    public Integer compare(BVCInvoice__c a, BVCInvoice__c b) {
        Integer numA = extractInvoiceNumber(a.ST_Invoice_Series__c);
        Integer numB = extractInvoiceNumber(b.ST_Invoice_Series__c);
        
        if (numA > numB) {
                return -1; // Descending order
            } else if (numA < numB) {
                return 1;
            } else {
                return 0;
            }
        
    }
    
    private Integer extractInvoiceNumber(String series) {
        if (String.isEmpty(series)) {
            return 0; 
        }
        
        Matcher match = Pattern.compile('\\d+').matcher(series);
        if (match.find()) {
            return Integer.valueOf(match.group());
        }
        return 0;
    }
}