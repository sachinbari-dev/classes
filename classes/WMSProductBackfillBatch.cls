global class WMSProductBackfillBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Start method: query all necessary fields
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Serial_Number__c, Serial_Number_Search__c,
                   Batch_Number__c, Batch_Number_Search__c
            FROM WMS_Products__c
        ]);
    }

    // Execute method: update searchable fields safely
    global void execute(Database.BatchableContext BC, List<WMS_Products__c> scope) {
        // Skip trigger helpers
        WMSProductTriggerHandler1.isBackfill = true;

        List<WMS_Products__c> updateList = new List<WMS_Products__c>();

        for (WMS_Products__c wp : scope) {
            Boolean needUpdate = false;

            if (wp.Serial_Number__c != null) {
                String serialSearch = wp.Serial_Number__c.substring(0, Math.min(255, wp.Serial_Number__c.length()));
                if (wp.Serial_Number_Search__c != serialSearch) {
                    wp.Serial_Number_Search__c = serialSearch;
                    needUpdate = true;
                }
            }

            if (wp.Batch_Number__c != null) {
                String batchSearch = wp.Batch_Number__c.substring(0, Math.min(255, wp.Batch_Number__c.length()));
                if (wp.Batch_Number_Search__c != batchSearch) {
                    wp.Batch_Number_Search__c = batchSearch;
                    needUpdate = true;
                }
            }

            if (needUpdate) {
                updateList.add(wp);
            }
        }

        if (!updateList.isEmpty()) {
            update updateList;
        }

        WMSProductTriggerHandler1.isBackfill = false;
    }

    // Finish method: optional logging
    global void finish(Database.BatchableContext BC) {
        System.debug('🎯 WMS Product backfill batch complete.');
    }
}