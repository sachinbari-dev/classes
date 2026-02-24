@isTest
public class CreditNoteSeriesComparatorTest {
    @isTest
    public static void testCreditNoteSeriesComparison() {
        BVCCreditNote__c cn1 = new BVCCreditNote__c();
        cn1.CreditNote_Serial_No__c = 'CN-000001';
        
        BVCCreditNote__c cn2 = new BVCCreditNote__c();
        cn2.CreditNote_Serial_No__c = 'CN-000002';

        CreditNoteSeriesComparator comparator = new CreditNoteSeriesComparator();

        Integer result = comparator.compare(cn1, cn2);

        
        result = comparator.compare(cn1, cn2);

        
        BVCCreditNote__c cn3 = new BVCCreditNote__c();
        cn3.CreditNote_Serial_No__c = 'CN-000002';
                
        result = comparator.compare(cn2, cn3);

        
    }
}