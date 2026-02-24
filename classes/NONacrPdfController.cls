public class NONacrPdfController {
 @AuraEnabled
    public static void attachPdfToQuote(Id quoteId) {
        BVCnonAcrQuotePdfController.attachPdfToQuote(quoteId);
    }
}