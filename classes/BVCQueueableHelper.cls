public class BVCQueueableHelper {
    
    @future
    public static void enqueueRazorpayQueueable(List<Id> razorpayInvoiceIds) {
        System.debug('Enqueueing BVC_RazorpayQueueable with Invoice IDs: ' + razorpayInvoiceIds);
        System.enqueueJob(new BVC_RazorpayQueueable(razorpayInvoiceIds));
    }
}