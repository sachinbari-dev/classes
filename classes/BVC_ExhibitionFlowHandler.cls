public class BVC_ExhibitionFlowHandler {

     @InvocableMethod(
        label='Update Secure Bags IsExhibition False'
        description='Used by Flow when Exhibition is removed from Shipment'
    )
    public static void handleFromFlow(List<Id> shipmentIds) {

        if (shipmentIds == null || shipmentIds.isEmpty()) {
            return;
        }

        // Fetch current shipments
        List<Shipment__c> newList = [
            SELECT Id, Exhibition__c, Tracking_Status__c, RecordTypeId
            FROM Shipment__c
            WHERE Id IN :shipmentIds
        ];

        // Simulate oldMap (Flow has no Trigger.oldMap)
        Map<Id, Shipment__c> oldMap = new Map<Id, Shipment__c>();

        for (Shipment__c s : newList) {
            Shipment__c oldRec = s.clone(false, true, false, false);
            oldRec.Exhibition__c = 'DUMMY'; // mark as previously present
            oldMap.put(s.Id, oldRec);
        }

        // Call existing trigger logic
        BVC_exhibitionHelper.updateSecureBagIsExhibitionToFalse(newList, oldMap);
    }
}