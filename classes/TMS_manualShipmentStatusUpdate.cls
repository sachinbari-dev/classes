/**
* @description       : Validation to check current scan location of secure bags and then check tracking status update on shipment.
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc  //govind.sangale@bvclogistics.com
* @group             : 
* @Craeted on        : 08-04-2025             
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc  //govind.sangale@bvclogistics.com
* Modifications Log 
* Ver   Date         Author                               Modification
  1.1  23/04/2025    govind sangale                     added method avoidDeliveryAssign
**/

public class TMS_manualShipmentStatusUpdate {

    public static String validateManualTrackingStatusUpdate(List<Shipment__c> shipmentList) {

        if (shipmentList == null || shipmentList.isEmpty()) {
            return null;
        }

        Set<Id> shipmentIds = new Set<Id>();
        for (Shipment__c s : shipmentList) {
            shipmentIds.add(s.Id);
        }

        Map<Id, List<Secure_Bag__c>> shipmentToBagsMap = new Map<Id, List<Secure_Bag__c>>();
        List<Secure_Bag__c> secureBagList = [SELECT Id, Shipment__c, Current_Scan_Loction__c FROM Secure_Bag__c WHERE Shipment__c IN :shipmentIds];

        for (Secure_Bag__c bag : secureBagList) {
            
            if (!shipmentToBagsMap.containsKey(bag.Shipment__c)) {
                shipmentToBagsMap.put(bag.Shipment__c, new List<Secure_Bag__c>());
            }
                shipmentToBagsMap.get(bag.Shipment__c).add(bag);
        }

        for (Shipment__c shipment : shipmentList) {
            List<Secure_Bag__c> bags = shipmentToBagsMap.get(shipment.Id);

            if (bags != null && !bags.isEmpty()) {
                String baseLocation = bags[0].Current_Scan_Loction__c;
                for (Secure_Bag__c bag : bags) {
                    if (bag.Current_Scan_Loction__c != baseLocation) {
                        return 'You cannot update the status of shipment with Name: ' + shipment.Name +
                               'because one or more bags have mismatching current scan locations.';
                    }
                }
            }
        }

           return null; 
    }
    
    public static string avoidDeliveryAssign(List<Shipment__c> shipmentList){
        
            if (shipmentList == null || shipmentList.isEmpty()) {
            return null;
        }

        Set<Id> shipmentIds = new Set<Id>();
        for (Shipment__c s : shipmentList) {
            shipmentIds.add(s.Id);
        }

        Map<Id, List<Secure_Bag__c>> shipmentToBagsMap = new Map<Id, List<Secure_Bag__c>>();
        List<Secure_Bag__c> secureBagList = [SELECT Id, Shipment__c, Current_Scan_Loction__c FROM Secure_Bag__c WHERE Shipment__c IN :shipmentIds];

        for (Secure_Bag__c bag : secureBagList) {
            
            if (!shipmentToBagsMap.containsKey(bag.Shipment__c)) {
                shipmentToBagsMap.put(bag.Shipment__c, new List<Secure_Bag__c>());
            }
                shipmentToBagsMap.get(bag.Shipment__c).add(bag);
        }

        for (Shipment__c shipment : shipmentList) {
            List<Secure_Bag__c> bags = shipmentToBagsMap.get(shipment.Id);

            if (bags != null && !bags.isEmpty()) {
                String baseLocation = bags[0].Current_Scan_Loction__c;
                for (Secure_Bag__c bag : bags) {
                    if (bag.Current_Scan_Loction__c != baseLocation) {
                        return 'you can not assign delivery of shipment with Name: ' + shipment.Name +
                               ' because one or more bags have mismatching current scan locations.';
                    }
                }
            }
        }
        
         return null;
    }
}