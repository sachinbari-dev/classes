public class ShipmentUpdateToLinehaulFinalize {

     public static void updateShipments(List<Id> linehaulIds) {
        // Collect shipment IDs and organize bags by shipment
        Set<Id> shipmentIDs = new Set<Id>();       
        Map<Id, List<secure_bag__c>> shipmentBagMap = new Map<Id, List<secure_bag__c>>();

        // Query Linehaul Tracking and related secure bags in one go
        List<Linehaul_Tracking__c> linehaulTrackings = [SELECT Id, Name, AWB_Number__c, Linehaul_Type__c,
                                                               (SELECT Id, Name, Shipment__c FROM Secure_Bags__r)
                                                        FROM Linehaul_Tracking__c 
                                                        WHERE ID IN :linehaulIds];

        for (Linehaul_Tracking__c line : linehaulTrackings) {
            for (secure_bag__c bg : line.Secure_Bags__r) {
                if (bg.Shipment__c != null) {
                    shipmentIDs.add(bg.Shipment__c);
                    
                    if (!shipmentBagMap.containsKey(bg.Shipment__c)) {
                        shipmentBagMap.put(bg.Shipment__c, new List<secure_bag__c>());
                    }
                    shipmentBagMap.get(bg.Shipment__c).add(bg);
                }
            }
        }

        // If no shipments were found, exit the method
        if (shipmentIDs.isEmpty()) {
            return;
        }

        // Maps to hold bag counts
        Map<Id, Integer> shipmentTotalBagCountMap = new Map<Id, Integer>();
        Map<Id, Integer> shipmentBagsWithLTCountMap = new Map<Id, Integer>();
        Map<Id, Integer> shipmentBagsWithoutLTCountMap = new Map<Id, Integer>();

        // Query all secure bags for the shipments in one go
        List<secure_bag__c> allBagsList = [SELECT Id, Name, Shipment__c, Linehaul_Tracking__c 
                                           FROM secure_bag__c 
                                           WHERE Shipment__c IN :shipmentIDs];

        // Process each secure bag
        for (secure_bag__c sbg : allBagsList) {
            Id shipmentId = sbg.Shipment__c;

            if (!shipmentTotalBagCountMap.containsKey(shipmentId)) {
                shipmentTotalBagCountMap.put(shipmentId, 0);
                shipmentBagsWithLTCountMap.put(shipmentId, 0);
                shipmentBagsWithoutLTCountMap.put(shipmentId, 0);
            }
            shipmentTotalBagCountMap.put(shipmentId, shipmentTotalBagCountMap.get(shipmentId) + 1);

            if (sbg.Linehaul_Tracking__c == null) {
                shipmentBagsWithoutLTCountMap.put(shipmentId, shipmentBagsWithoutLTCountMap.get(shipmentId) + 1);
            } else {
                shipmentBagsWithLTCountMap.put(shipmentId, shipmentBagsWithLTCountMap.get(shipmentId) + 1);
            }
        }

        // Prepare and update shipment records
        List<shipment__c> shipList = new List<shipment__c>();

        for (Id shipmentId : shipmentTotalBagCountMap.keySet()) {
            Integer totalBagsCountForShipment = shipmentTotalBagCountMap.get(shipmentId);
            Integer bagsWithLTCount = shipmentBagsWithLTCountMap.get(shipmentId);
            Integer bagsWithoutLTCount = shipmentBagsWithoutLTCountMap.get(shipmentId);

            if (totalBagsCountForShipment == bagsWithLTCount && bagsWithoutLTCount == 0) {
                shipment__c sh = new shipment__c();
                sh.Id = shipmentId;
                sh.Linehaul_Completed__c = true;
                sh.Tracking_Status__c = 'Linehaul Finalised';
                shipList.add(sh);
            }
        }

        if (!shipList.isEmpty()) {
            update shipList;
        }
    }
}