public with sharing class TatDashboard {

    @AuraEnabled(cacheable=true)
    public static List<TatRow> getTatData() {

        Datetime nowDt = System.now();
        Datetime endDt = nowDt.addHours(5);

        List<Shipment__c> shipments = [
            SELECT Id, Destination_Hub__c, Estimated_Delivery_Datetime__c
            FROM Shipment__c
            WHERE Estimated_Delivery_Datetime__c != null
            AND Estimated_Delivery_Datetime__c >= :nowDt
            AND Estimated_Delivery_Datetime__c <= :endDt
        ];

        Map<String, TatRow> hubMap = new Map<String, TatRow>();

        for (Shipment__c s : shipments) {

            String hub = s.Destination_Hub__c;
            if (hub == null) continue;

            if (!hubMap.containsKey(hub)) {
                hubMap.put(hub, new TatRow(hub));
            }

            TatRow row = hubMap.get(hub);

            Long diffMillis = s.Estimated_Delivery_Datetime__c.getTime() - nowDt.getTime();
            Integer diffHours = (Integer)Math.floor(diffMillis / (1000 * 60 * 60));

            if (diffHours == 0) row.next1++;
            else if (diffHours == 1) row.next2++;
            else if (diffHours == 2) row.next3++;
            else if (diffHours == 3) row.next4++;
            else if (diffHours == 4) row.next5++;
        }

        return hubMap.values();
    }

    // Wrapper
    public class TatRow {
        @AuraEnabled public String hub;
        @AuraEnabled public Integer next1 = 0;
        @AuraEnabled public Integer next2 = 0;
        @AuraEnabled public Integer next3 = 0;
        @AuraEnabled public Integer next4 = 0;
        @AuraEnabled public Integer next5 = 0;

        public TatRow(String hubName) {
            hub = hubName;
        }
    }
}