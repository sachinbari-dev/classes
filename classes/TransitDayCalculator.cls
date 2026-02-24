/**
* @description       : This class is calculating actaul days of delivery from pickup date to actual delivery date on shipment.
* @author            : Mr.Govind Sangale
* @group             : 
* created On         : 13-10-2025
* @last modified on  : 14-10-2025           :
* @last modified by  : Mr.Mr.Govind Sangale :
**/

public with sharing class TransitDayCalculator {
    public class Result {
        public Id shipmentId;
        public Integer workingDays;
        public String bucket;
        public Result(Id sid, Integer days, String b) {
            shipmentId = sid; workingDays = days; bucket = b;
        }
    }

    // ---------- Public entrypoints ----------
    @invocableMethod
    public static void callTransitDayBucket(List<Shipment__c> shipments){
        calculateAndUpdateBuckets(shipments);
    }
    public static Map<Id, Result> calculateAndUpdateBuckets(List<Shipment__c> shipments) {
        if (shipments == null || shipments.isEmpty()) return new Map<Id, Result>();
        return processShipmentsInternal(shipments, true);
    }

    public static Map<Id, Result> processByIds(List<Id> shipmentIds, Boolean performUpdate) {
        if (shipmentIds == null || shipmentIds.isEmpty()) return new Map<Id, Result>();
        List<Shipment__c> shipments = [SELECT Id, Pickup__c, Origin_Hub__c, Destination_Hub__c,
                                              Actual_Delivery_Date_and_Time__c, Transit_Day_Bucket__c
                                      FROM Shipment__c WHERE Id IN :shipmentIds];
        return processShipmentsInternal(shipments, performUpdate);
    }

    public static Map<Id, Result> calculateBuckets(List<Shipment__c> shipments) {
        return processShipmentsInternal(shipments, false);
    }

    // ---------- Core implementation ----------
    private static Map<Id, Result> processShipmentsInternal(List<Shipment__c> shipments, Boolean performUpdate) {
        Map<Id, Result> results = new Map<Id, Result>();
        if (shipments == null || shipments.isEmpty()) return results;

        //  Collect pickup & hub ids and compute raw min/max bounds
        Set<Id> pickupIds = new Set<Id>();
        Set<Id> hubIds = new Set<Id>();
        Date minDate = Date.newInstance(9999,12,31);
        Date maxDate = Date.newInstance(1900,1,1);

        for (Shipment__c s : shipments) {
            if (s.Pickup__c != null) pickupIds.add(s.Pickup__c);
            if (s.Origin_Hub__c != null) hubIds.add(s.Origin_Hub__c);
            if (s.Destination_Hub__c != null) hubIds.add(s.Destination_Hub__c);

            if (s.Actual_Delivery_Date_and_Time__c != null) {
                Date del = s.Actual_Delivery_Date_and_Time__c.date();
               
                if (del > maxDate) maxDate = del;
            }
        }

        // Query pickups (Pickup_Date__c)
        Map<Id, Date> pickupDateById = new Map<Id, Date>();
        if (!pickupIds.isEmpty()) {
            for (Pickup__c p : [SELECT Id, Pickup_Date__c,Physical_Pickup_Completed_Time__c FROM Pickup__c WHERE Id IN :pickupIds]) {
                Date pickdate = p.Physical_Pickup_Completed_Time__c.date();
                system.debug(pickdate);
                pickupDateById.put(p.Id, pickdate);
                if (p.Physical_Pickup_Completed_Time__c != null) {
                    if (p.Physical_Pickup_Completed_Time__c.date() < minDate) minDate = p.Physical_Pickup_Completed_Time__c.date();
                    
                }
            }
        }

        // Query hubs for states
        Map<Id, String> hubStateById = new Map<Id, String>();
        if (!hubIds.isEmpty()) {
            for (Hub__c h : [SELECT Id, Hub_State__c FROM Hub__c WHERE Id IN :hubIds]) {
                hubStateById.put(h.Id, h.Hub_State__c);
            }
        }

        // If no valid bounds, nothing to compute
        if (minDate == Date.newInstance(9999,12,31) || maxDate == Date.newInstance(1900,1,1)) {
            return results;
        }

        Set<String> statesToQuery = new Set<String>();
        for (String st : hubStateById.values()) {
            if (st != null) statesToQuery.add(st);
        }

        //  Query holidays once for all relevant states
        Map<String, Set<Date>> holidaysByState = new Map<String, Set<Date>>();
        if (!statesToQuery.isEmpty()) {
            List<Holiday_Data__c> hols = [SELECT Date__c, State__c
                                          FROM Holiday_Data__c
                                          WHERE Date__c >= :minDate AND Date__c <= :maxDate
                                            AND State__c IN :statesToQuery];
            for (Holiday_Data__c h : hols) {
                String st = h.State__c;
                if (st == null) continue; 
                if (!holidaysByState.containsKey(st)) holidaysByState.put(st, new Set<Date>());
                holidaysByState.get(st).add(h.Date__c);
            }
        }

        // For each shipment: compute effective pickup/delivery and working days
        for (Shipment__c s : shipments) {
            Date rawDelivery = (s.Actual_Delivery_Date_and_Time__c != null) ? s.Actual_Delivery_Date_and_Time__c.date() : null;
            if (rawDelivery == null) continue;
            Date rawPickup = (s.Pickup__c != null && pickupDateById.containsKey(s.Pickup__c)) ? pickupDateById.get(s.Pickup__c) : null;
            if (rawPickup == null) continue;

            String originState = (s.Origin_Hub__c != null && hubStateById.containsKey(s.Origin_Hub__c)) ? hubStateById.get(s.Origin_Hub__c) : null;
            String destState   = (s.Destination_Hub__c != null && hubStateById.containsKey(s.Destination_Hub__c)) ? hubStateById.get(s.Destination_Hub__c) : null;

            // holidaySet for counting (union of origin+destination) — duplicates automatically deduped
            Set<Date> holidayUnion = new Set<Date>();
            if (originState != null && holidaysByState.containsKey(originState)) holidayUnion.addAll(holidaysByState.get(originState));
            if (destState   != null && holidaysByState.containsKey(destState))   holidayUnion.addAll(holidaysByState.get(destState));

            // effective pickup: shift forward while it's Sunday OR present in origin holidays (serial holiday+Sunday)
            Date effectivePickup = rawPickup;
            while (effectivePickup != null && (isSunday(effectivePickup) || (originState != null && holidaysByState.containsKey(originState) && holidaysByState.get(originState).contains(effectivePickup)))) {
                effectivePickup = effectivePickup.addDays(1);
            }

            // effective delivery: shift backward while it's Sunday OR present in destination holidays (serial)
            Date effectiveDelivery = rawDelivery;
            while (effectiveDelivery != null && (isSunday(effectiveDelivery) || (destState != null && holidaysByState.containsKey(destState) && holidaysByState.get(destState).contains(effectiveDelivery)))) {
                effectiveDelivery = effectiveDelivery.addDays(-1);
            }

            Integer workingDays = 0;
            if (effectivePickup == null || effectiveDelivery == null) {
                workingDays = 0;
            } else if (effectiveDelivery < effectivePickup) {
                workingDays = 0;
            } else if (effectiveDelivery == effectivePickup) {
                // per spec: same effective working day => 0
                workingDays = 0;
            } else {
                // count working days inclusive, excluding Sundays and any date in holidayUnion
                workingDays = countWorkingDaysInclusive(effectivePickup, effectiveDelivery, holidayUnion);
            }

            String bucket = bucketForWorkingDays(workingDays);
            results.put(s.Id, new Result(s.Id, workingDays, bucket));
        }

       
        if (performUpdate && !results.isEmpty()) {
            List<Shipment__c> updates = new List<Shipment__c>();
            for (Shipment__c s : shipments) {
                if (!results.containsKey(s.Id)) continue;
                String computedBucket = results.get(s.Id).bucket;
                if (s.Transit_Day_Bucket__c != computedBucket) {
                    updates.add(new Shipment__c(Id = s.Id, Transit_Day_Bucket__c = computedBucket));
                }
            }
            if (!updates.isEmpty()) {
                try {
                    update updates;
                } catch (DmlException dex) {
                    System.debug('TransitDayCalculator - update failed: ' + dex.getMessage());
                }
            }
        }

        return results;
    }

    // ---------- Utilities ----------
    private static Boolean isSunday(Date d) {
        if (d == null) return false;
        
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        return dt.format('u') == '7';
    }

    private static Integer countWorkingDaysInclusive(Date startDt, Date endDt, Set<Date> holidaySet) {
        if (startDt == null || endDt == null) return 0;
        Integer cnt = 0;
        Date cur = startDt;
        while (cur <= endDt) {
            if (!isSunday(cur) && (holidaySet == null || !holidaySet.contains(cur))) {
                cnt++;
            }
            cur = cur.addDays(1);
            if (cnt > 100000) break; 
        }
        return cnt;
    }

    private static String bucketForWorkingDays(Integer days) {
        if (days == null) return null;
        if (days <= 0) return '0';
        if (days == 1) return '1';
        if (days == 2) return '2';
        if (days == 3) return '3';
        if (days == 4) return '4';
        if (days == 5) return '5';
        return '>5';
    }
}