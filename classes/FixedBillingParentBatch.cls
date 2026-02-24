global class FixedBillingParentBatch implements Database.Batchable<SObject>, Database.Stateful {

    Date processDate;
    private Set<Id> fbIds = new Set<Id>();

    global FixedBillingParentBatch(Date runDate) {
        processDate = runDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Monthly_Billing__c, Start_Date__c, End_Date__c, Product__c, Customer__c,
                   Billing_Type__c, Max_Shipment_Limit__c, Extra_Charge__c, Remaining_Shipments__c 
            FROM Fixed_Billing__c
            WHERE Start_Date__c <= :processDate
              AND End_Date__c   >= :processDate
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Fixed_Billing__c> scope) {
        for (Fixed_Billing__c fb : scope) {
            fbIds.add(fb.Id);
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (!fbIds.isEmpty()) {
            List<Id> fbList = new List<Id>(fbIds);
            //Database.executeBatch(new FixedBillingChildBatch(fbList, 0, processDate), 100);
            // 🚀 Call the Queueable for the first FB
            System.enqueueJob(new FixedBillingChildQueueable(fbList, 0, processDate));
        }
    }
}