trigger ShipmentSummaryTrigger on External_Contract_Shipment_Summary__c (after update) {
    
    if(trigger.isUpdate && trigger.isAfter){
        
        Set<Id> shipSummaryIds = new Set<Id>();
        External_Contract_Shipment_Summary__c oldSS;
        for(External_Contract_Shipment_Summary__c ss : trigger.new){
            oldSS = trigger.oldMap.get(ss.Id);
            if(/*(ss.Invoice__c <> NULL && ss.Invoice__c <> oldSS.Invoice__c) ||*/ (ss.BVCInvoice__c <> NULL && ss.BVCInvoice__c <> oldSS.BVCInvoice__c)){ //removed for uninstallation of CPQ
                shipSummaryIds.add(ss.Id);
            }
        }        
		system.debug('shipSummaryIds++++'+shipSummaryIds);
        ShipmentSummaryTriggerHandler.updateShipmentStatus(shipSummaryIds);

    }

}