/*
 * Class      : SecureBagListOnShipment
 * Author     : Sanket.pisal@bvclogistics.com
 * Date       : Sep 2023
 */

public class SecureBagListOnShipment {

    @InvocableMethod(label='Update Shipment Record')
    public static void updateShipmentRecord(List<ShipmentIdWrapper> shipmentIdList) {
        List<Shipment__c> shipList = new List<Shipment__c>();

        Map<Id, List<String>> shipmentIdToFormulaValues = new Map<Id, List<String>>();
        Set<Id> shipmentIds = new Set<Id>();

      
        for (ShipmentIdWrapper shipmentIdWrapper : shipmentIdList) {
            shipmentIds.add(shipmentIdWrapper.shipmentId);
        }

        for (secure_bag__c sb : [
            SELECT Shipment__c, Secure_Packaging_Identifier__c 
            FROM secure_bag__c 
            WHERE Shipment__c IN :shipmentIds
            //WHERE Shipment__c IN :shipmentIds and (Shipment__r.Tracking_Status__c != 'Out for Delivery' OR Shipment__r.Tracking_Status__c != 'Delivered' OR Shipment__r.Tracking_Status__c != 'Destination Hub')
        ]) {
            if (!shipmentIdToFormulaValues.containsKey(sb.Shipment__c)) {
                shipmentIdToFormulaValues.put(sb.Shipment__c, new List<String>());
            }
            shipmentIdToFormulaValues.get(sb.Shipment__c).add(sb.Secure_Packaging_Identifier__c);
        }

        for (Id shipID : shipmentIds) {
            Shipment__c ship = new Shipment__c(Id = shipID);

            if (shipmentIdToFormulaValues.containsKey(shipID)) {
                ship.Secure_Bags__c = String.join(shipmentIdToFormulaValues.get(shipID), ', ');
                shipList.add(ship);
            }
        }

        update shipList;
    }

    
    public class ShipmentIdWrapper {
        @InvocableVariable
        public Id shipmentId;
    }
}