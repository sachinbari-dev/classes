public class FixedBillingQueueManager {

    // Enqueue a batch for execution
    public static void enqueueBatch(Database.Batchable<SObject> batchInstance, Id invoiceRunId) {

        // Check if any FixedBillingInvoiceBatch is already running or queued
        List<AsyncApexJob> jobs = [
            SELECT Id, Status, JobType 
            FROM AsyncApexJob 
            WHERE JobType = 'BatchApex' 
              AND Status IN ('Processing', 'Queued')
              AND ApexClass.Name = 'FixedBillingInvoiceBatch'
        ];

        if (jobs.isEmpty()) {
            // No batch running → execute immediately
            Database.executeBatch(batchInstance, 200);
            
            // Mark this invoice run as Running
            BVC_Invoice_Run__c run = new BVC_Invoice_Run__c(
                Id = invoiceRunId,
                Processing_Status__c = 'Running'
            );
            update run;

            System.debug('Batch started immediately for invoice run: ' + invoiceRunId);
        } else {
            // Batch already running → leave this invoice run as Pending
            System.debug('Batch already running. Invoice run queued as Pending: ' + invoiceRunId);
        }
    }

    // Start the next pending batch (called from finish() of batch)
    public static void startNextBatch() {

        // Query the oldest pending invoice run
        List<BVC_Invoice_Run__c> pendingRuns = [
            SELECT Id, Customer__c, From__c, To__c
            FROM BVC_Invoice_Run__c
            WHERE Processing_Status__c = 'Pending'
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];

        if (!pendingRuns.isEmpty()) {
            BVC_Invoice_Run__c nextRun = pendingRuns[0];

            // Fetch orders for this run
            List<BVCOrder__c> ordersList = [
                SELECT Id, Product_Code__c, BVC_LegalEntity__c, Billing_Account__c, schedulerKey__c,
                    (SELECT Id FROM BVC_Order_Products__r)
                FROM BVCOrder__c 
                WHERE Account__c = :nextRun.Customer__c
                  AND Shipment_Date__c >= :nextRun.From__c
                  AND Shipment_Date__c <= :nextRun.To__c
                  AND Billing_status__c = 'Pending'
                  AND fixed_billing_order__c = true
                  AND BVC_Invoice_Run__c = :nextRun.Id
            ];

            Map<Id,BVCOrder__c> orderMap = new Map<Id,BVCOrder__c>();
            for (BVCOrder__c o : ordersList) orderMap.put(o.Id, o);

            FixedBillingInvoiceBatch batchInstance = new FixedBillingInvoiceBatch(orderMap, new List<BVC_Invoice_Run__c>{nextRun});
            Database.executeBatch(batchInstance, 200);

            // Mark as Running
            nextRun.Processing_Status__c = 'Running';
            update nextRun;

            System.debug('Started next pending batch: ' + nextRun.Id);
        } else {
            System.debug('No pending invoice runs in queue.');
        }
    }
}