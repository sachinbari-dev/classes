public class autoEY_TaxIntegrationQueueable implements Queueable, Database.AllowsCallouts {
    List<BVCInvoice__c> invoices2Tax = new List<BVCInvoice__c>();

    public autoEY_TaxIntegrationQueueable(List<BVCInvoice__c> invList) {
        System.debug('for checking Inside autoEY_TaxIntegrationQueueable invList'+invList);
        invoices2Tax = invList;
    }

    public void execute(QueueableContext qc) {
        System.debug('for checking Inside execute method invoices2Tax:'+invoices2Tax.size());
        List<Id> invIds = new List<Id>();
        List<Id> razorpayInvoiceIds = new List<Id>();

        for (BVCInvoice__c inv : invoices2Tax) {
            invIds.add(inv.Id);
        }

        if (invIds.size() > 0) {
            razorpayInvoiceIds.addAll(BVC_QueryUtilityManual.invoiceQuery(invIds));
        }

        System.debug('for checking Invoice List for Razorpay >>>' + razorpayInvoiceIds);

        if (razorpayInvoiceIds.size() > 0 && !Test.isRunningTest()) {
            System.enqueueJob(new BVC_RazorpayQueueable(razorpayInvoiceIds));
        }

    }
}