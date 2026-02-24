public class CreditNoteSeriesComparator implements Comparator<BVCCreditNote__c> {

    public Integer compare(BVCCreditNote__c a, BVCCreditNote__c b) {

        Long numA = extractNumericPart(a.CreditNote_Serial_No__c);
        Long numB = extractNumericPart(b.CreditNote_Serial_No__c);

        System.debug('Extracted Numeric A: ' + numA + ' from ' + a.CreditNote_Serial_No__c);
        System.debug('Extracted Numeric B: ' + numB + ' from ' + b.CreditNote_Serial_No__c);

        return numB > numA ? 1 : (numB < numA ? -1 : 0);
    }

    private Long extractNumericPart(String creditSeries) {
        if (String.isBlank(creditSeries)) {
            return 0;
        }

        // Extract only digits from the series
        String numericPart = creditSeries.replaceAll('\\D+', '');

        return String.isBlank(numericPart) ? 0 : Long.valueOf(numericPart);
    }
}