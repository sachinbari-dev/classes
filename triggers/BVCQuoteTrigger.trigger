//Updated By Sanket For Multiple Contract Restrict
trigger BVCQuoteTrigger on BVCQuote__c (after update) {
    if (trigger.isUpdate && trigger.isAfter) {
        Map<Id, BVCQuote__c> bvcQuoteMap = new Map<Id, BVCQuote__c>();
        utilClass.flowSequence++;
        System.debug('flowSequence : Order After Update Trigger ' + utilClass.flowSequence);
        // Fetch all existing invoices related to quotes in this trigger execution
        Set<Id> quotedIdsWithInvoices = new Set<Id>();
        for (BVCInvoice__c inv : [SELECT BVCQuote__c FROM BVCInvoice__c WHERE BVCQuote__c IN :Trigger.newMap.keySet()]) {
            quotedIdsWithInvoices.add(inv.BVCQuote__c);
        }
        // Fetch all existing contracts related to quotes in this trigger execution
        Set<Id> quotedIdsWithContracts = new Set<Id>();
        for (BVC_Contract__c contract : [SELECT Quote__c FROM BVC_Contract__c WHERE Quote__c IN :Trigger.newMap.keySet()]) {
            quotedIdsWithContracts.add(contract.Quote__c);
        }
        for (BVCQuote__c bvcQuoteObj : trigger.newMap.values()) {
            BVCQuote__c oldbvcQuoteObj = trigger.oldMap.get(bvcQuoteObj.Id);
            // Check if Status is "Contract Sent" and store the record
            if (UtilClass.triggerLoop == false
                && bvcQuoteObj.Status__c == 'Contract Sent'
                && bvcQuoteObj.Business_Type__c == 'ACR'
                && bvcQuoteObj.Status__c != oldbvcQuoteObj.Status__c
                && !quotedIdsWithInvoices.contains(bvcQuoteObj.Id)) {
                bvcQuoteMap.put(bvcQuoteObj.Id, bvcQuoteObj);
                UtilClass.triggerLoop = true;
            }
        }
        System.debug('Rafi debug bvcQuoteMap.size(): ' + bvcQuoteMap.size());
        System.debug('Rafi debug bvcQuoteMap.values(): ' + bvcQuoteMap.values());
        // Process the BVC Quote records if the map is not empty
        if (bvcQuoteMap.size() > 0) {
            System.debug('Calling BVCQuoteProcessor with bvcQuoteMap: ' + bvcQuoteMap);
            BVCQuoteTriggerHandler.BVCQuoteProcessor(bvcQuoteMap);
        } else {
            System.debug('No records to process in BVCQuoteProcessor');
        }
        // Call contract generation only if there are no existing contracts for the quotes
        Set<Id> quotesWithoutContracts = new Set<Id>();
        for (BVCQuote__c quote : trigger.new) {
            if (!quotedIdsWithContracts.contains(quote.Id)) {
                quotesWithoutContracts.add(quote.Id);
            }
        }
        if (!quotesWithoutContracts.isEmpty()) {
            System.debug('Calling bvcContractGeneration.createContract for quotes: ' + quotesWithoutContracts);
            bvcContractGeneration.createContract(trigger.new, trigger.oldMap);
        } else {
            System.debug('Contracts already exist, skipping bvcContractGeneration.createContract');
        }
    }
}