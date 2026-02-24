public with sharing class SLACalculatorHandler1 {
    // ---------- Config ----------
    public static Integer MAX_ROUTE_DEPTH = 20;

    // ---------- Public entry ----------
    /**
     * Run SLA calculations for the given shipments (bulk-safe).
     * Call from trigger or other apex.
     */
    public static void runSLA(List<Shipment__c> shipments) {
        if (shipments == null || shipments.isEmpty()) return;
        SLACalculatorHandler1 handler = new SLACalculatorHandler1();
        handler.process(shipments);
    }

    // ---------- Instance state for a run ----------
    private Map<String, Distance_Calculator__c> distanceMap;
    private Map<String, Network_Plan__c> networkPlanMap;
    private Map<String, Holiday_Data__c> holidayDateStateMap;

    // Results/buffers (per-run)
    private Map<Id, String> shipIdToFinalTime = new Map<Id, String>();
    private Map<Id, String> shipIdToSLADay = new Map<Id, String>();
    private Map<Id, Datetime> shipIdToEstDel = new Map<Id, Datetime>();
    private Map<Id, Integer> shipIdToTatDays = new Map<Id, Integer>();
    private Map<Id, String> shipIdToHolidayText = new Map<Id, String>();
    private Map<Id, String> shipIdToPickupHoliday = new Map<Id, String>();

    private List<Network_Plan_For_Calculation__c> npToInsert = new List<Network_Plan_For_Calculation__c>();
    private List<Distance_Calculator_For_Calculation__c> dcToInsert = new List<Distance_Calculator_For_Calculation__c>();
    private List<TAT_SLA_Mapping__c> tsmToUpdate = new List<TAT_SLA_Mapping__c>();
    private List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();
    private Map<Id, TAT_SLA_Mapping__c> shipToTsm = new Map<Id, TAT_SLA_Mapping__c>();

    // ---------- Main flow ----------
    private void process(List<Shipment__c> shipments) {
        try {
            // preload reference data
            distanceMap = loadDistanceMap();
            networkPlanMap = loadNetworkPlanMap();
            holidayDateStateMap = loadHolidayDateStateMap();

            // create initial TAT_SLA_Mapping__c records (bulk)
            createInitialTSM(shipments);

            // preload pickups and related fields in bulk
            Set<Id> pickupIds = new Set<Id>();
            for (Shipment__c s : shipments) if (s.Pickup__c != null) pickupIds.add(s.Pickup__c);
            Map<Id, Pickup__c> pickupMap = pickupIds.isEmpty() ? new Map<Id, Pickup__c>() :
                new Map<Id, Pickup__c>([
                    SELECT Id, Origin_Address_Pincode__c, Physical_Pickup_Completed_Time__c
                    FROM Pickup__c WHERE Id IN :pickupIds
                ]);

            // Ensure related lookup fields are available - if the trigger didn't include the related fields,
            // we need to requery shipments to fetch referenced fields used by SLA logic.
            // Build list of shipment ids that are missing required lookups
            List<Id> missingDetailShipIds = new List<Id>();
            for (Shipment__c s : shipments) {
                // required lookups: Pickup__r.Physical_Pickup_Completed_Time__c, Origin_Hub__r.Name, Destination_Hub__r.Name,
                // Origin_Address_Name__r.Active_Pincode__r.Name, Destination_Address_Name__r.Active_Pincode__r.Name,
                // Destination_Address_Name__r.Active_Pincode__r.* (service day booleans), Origin_Address_State__c, Destination_Address_State__c
                Boolean ok = (s.Pickup__r != null && s.Pickup__r.Physical_Pickup_Completed_Time__c != null)
                             && s.Origin_Hub__r != null && s.Destination_Hub__r != null
                             && s.Origin_Address_Name__r != null && s.Destination_Address_Name__r != null
                             && s.Origin_Address_Name__r.Active_Pincode__r != null && s.Destination_Address_Name__r.Active_Pincode__r != null;
                if (!ok) missingDetailShipIds.add(s.Id);
            }

            if (!missingDetailShipIds.isEmpty()) {
                Map<Id, Shipment__c> requery = new Map<Id, Shipment__c>([
                    SELECT Id, Name, Pickup__c, Pickup__r.Physical_Pickup_Completed_Time__c,
                           Origin_Hub__r.Name, Destination_Hub__r.Name,
                           Origin_Address_Name__r.Active_Pincode__c, Origin_Address_Name__r.Active_Pincode__r.Name,
                           Origin_Address_Name__r.Active_Pincode__r.City__c, Origin_Address_Name__r.Active_Pincode__r.Sunday__c,
                           Destination_Address_Name__r.Active_Pincode__c, Destination_Address_Name__r.Active_Pincode__r.Name,
                           Destination_Address_Name__r.Active_Pincode__r.City__c,
                           Destination_Address_Name__r.Active_Pincode__r.Sunday__c, Destination_Address_Name__r.Active_Pincode__r.Monday__c,
                           Destination_Address_Name__r.Active_Pincode__r.Tuesday__c, Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                           Destination_Address_Name__r.Active_Pincode__r.Thursday__c, Destination_Address_Name__r.Active_Pincode__r.Friday__c,
                           Destination_Address_Name__r.Active_Pincode__r.Saturday__c,
                           Origin_Address_Pincode__c, Destination_Address_Pincode__c, Origin_Address_State__c, Destination_Address_State__c,
                           Pickup__r.Origin_Address_Pincode__c
                    FROM Shipment__c WHERE Id IN :missingDetailShipIds
                ]);
                // merge requery fields into original list
                for (Integer i = 0; i < shipments.size(); i++) {
                    Shipment__c s = shipments[i];
                    if (requery.containsKey(s.Id)) {
                        Shipment__c fresh = requery.get(s.Id);
                        shipments[i] = mergeShipmentFields(s, fresh);
                    }
                }
            }

            // build a map for quick access to shipments by id
            Map<Id, Shipment__c> shipMap = new Map<Id, Shipment__c>();
            for (Shipment__c s : shipments) shipMap.put(s.Id, s);

            // Iterate shipments, compute SLA via routing logic
            for (Shipment__c ship : shipments) {
                try {
                    if (ship.Pickup__c == null) continue;
                    Pickup__c p = pickupMap.get(ship.Pickup__c);
                    if (p == null || p.Physical_Pickup_Completed_Time__c == null) continue;

                    TAT_SLA_Mapping__c tsm = shipToTsm.get(ship.Id);
                    if (tsm == null) continue;

                    // pickup holiday handling: contiguous holiday sequence starting pickup date
                    handlePickupHoliday(ship, p);

                    // starting baseline times
                    Integer baseHour = p.Physical_Pickup_Completed_Time__c.hour();
                    Integer baseMinute = p.Physical_Pickup_Completed_Time__c.minute();
                    Integer baseSecond = p.Physical_Pickup_Completed_Time__c.second();

                    // initial AR and TAT (AR = accumulated runtime, TAT = SLA clock)
                    Integer ARHour = 0, ARMinute = 0, ARSeconds = 0;
                    Integer TATSLAHour = baseHour, TATSLAMinute = baseMinute, TATSLASec = baseSecond;

                    // find distance calc for pickup origin p.Origin_Address_Pincode__c
                    String pickupPincode = p.Origin_Address_Pincode__c;
                    if (String.isBlank(pickupPincode)) continue;
                    Distance_Calculator__c dcPickup = distanceMap.get(pickupPincode);

                    // initial adjust from pickup to hub, same city etc.
                    if (dcPickup != null) {
                        Map<String, Object> adj = adjustTATSLAHourAndMinute(dcPickup, ship, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASec);
                        ARHour = (Integer)adj.get('ARHour');
                        ARMinute = (Integer)adj.get('ARMinute');
                        ARSeconds = (Integer)adj.get('ARSeconds');
                        TATSLAHour = (Integer)adj.get('TATSLAHour');
                        TATSLAMinute = (Integer)adj.get('TATSLAMinute');
                        // dc cal record added inside that helper via dcToInsert
                    }

                    // prepare route key: use hub name tokens like original code
                    String originKey = extractHubKey(ship.Origin_Hub__r != null ? ship.Origin_Hub__r.Name : null);
                    String destKey = extractHubKey(ship.Destination_Hub__r != null ? ship.Destination_Hub__r.Name : null);
                    if (String.isBlank(originKey) || String.isBlank(destKey)) {
                        // fallback: if hubs missing, use direct DC finalization if destination matches
                        finalizeIfDirectDestination(ship, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, p);
                        continue;
                    }

                    String npKey = originKey + '_' + destKey;
                    // recursively walk next routes up to limit
                    Set<String> visited = new Set<String>();
                    checkNextRoute(npKey, ship, destinationKeyForShip(ship), new Integer[]{TATSLAHour, TATSLAMinute, TATSLASec}, 
                                   new Integer[]{ARHour, ARMinute, ARSeconds}, visited, 0);

                } catch (Exception eInner) {
                    // log minimal error
                    insert new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandler.process.inner', Error__c = eInner.getMessage());
                }
            }

            // prepare TSM updates and shipment updates from buffers
            prepareAndCommitUpdates(shipMap);

        } catch (Exception e) {
            insert new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandler.process', Error__c = e.getMessage() + ' :: ' + e.getStackTraceString());
        } finally {
            // nothing global to clear
        }
    }

    // ---------- Helpers ----------

    private Shipment__c mergeShipmentFields(Shipment__c original, Shipment__c fresh) {
        // Merge safe fields from fresh into original (so trigger-provided fields remain too)
        // We'll just return fresh for simplicity (we reloaded required fields)
        return fresh;
    }

    private void createInitialTSM(List<Shipment__c> shipments) {
        List<TAT_SLA_Mapping__c> toInsert = new List<TAT_SLA_Mapping__c>();
        for (Shipment__c s : shipments) {
            TAT_SLA_Mapping__c t = new TAT_SLA_Mapping__c();
            // Protect against null lookups
            try {
                t.Origin_Pincode__c = s.Origin_Address_Name__r != null ? s.Origin_Address_Name__r.Active_Pincode__c : null;
            } catch (Exception ex) { t.Origin_Pincode__c = null; }
            try {
                t.Destination_Pincode__c = s.Destination_Address_Name__r != null ? s.Destination_Address_Name__r.Active_Pincode__c : null;
            } catch (Exception ex) { t.Destination_Pincode__c = null; }
            t.Shipment__c = s.Id;
            toInsert.add(t);
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
            // map them for later usage
            for (TAT_SLA_Mapping__c tsm : [SELECT Id, Shipment__c FROM TAT_SLA_Mapping__c WHERE Shipment__c IN :shipments]) {
                if (tsm.Shipment__c != null) shipToTsm.put(tsm.Shipment__c, tsm);
            }
        }
    }

    private Map<String, Distance_Calculator__c> loadDistanceMap() {
        Map<String, Distance_Calculator__c> result = new Map<String, Distance_Calculator__c>();
        for (Distance_Calculator__c dc : [SELECT Id, Destination_Pincode__c, Origin_Pincode__c, City__c, Distance_in_km__c,
                                          Distance_Range__c, Time_from_Pickup_to_Hub__c, Scheduled_Delivery_Route_Start_Time__c,
                                          Same_City_Hub_Delivery_Route_Start_Time__c, ROUTE_NUMBER__c, Time_from_Hub_to_delivery_point__c, State__c
                                          FROM Distance_Calculator__c]) {
            if (!String.isBlank(dc.Destination_Pincode__c)) result.put(dc.Destination_Pincode__c, dc);
        }
        return result;
    }

    private Map<String, Network_Plan__c> loadNetworkPlanMap() {
        Map<String, Network_Plan__c> result = new Map<String, Network_Plan__c>();
        for (Network_Plan__c np : [SELECT Id, From_Hub__c, To_Destination_Hub__c, OD_Concat__c,
                                  Approx_Time_Taken_in_hrs__c, Next_Route__c, Transport_Type__c,
                                  Origin_Port__c, Destination_Port__c, Flight_No__c, Flight_Departure_Time__c,
                                  Flight_Arrival_Time__c, Scheduled_Max_Time_of_Vehicle_Dispatch__c,
                                  Approx_Time_Taken_in_hrs1__c, Route_No__c, Scheduled_Arrival_at_Hub__c,
                                  Schedule_Arrival_from_airport_to_hub__c, Schedule_departure_from_airport_to_hub__c,
                                  Schedule_Airport_handover_time__c, Schedule_Load_retrival_time__c, Hub_Processing_hr__c,
                                  Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c, Scheduled_Max_Time_Of_Vehicle_Dispatch_3__c
                                  FROM Network_Plan__c]) {
            String key = (np.From_Hub__c != null ? np.From_Hub__c : '') + '_' + (np.To_Destination_Hub__c != null ? np.To_Destination_Hub__c : '');
            result.put(key, np);
        }
        return result;
    }

    private Map<String, Holiday_Data__c> loadHolidayDateStateMap() {
        Map<String, Holiday_Data__c> result = new Map<String, Holiday_Data__c>();
        for (Holiday_Data__c hd : [SELECT Id, Date__c, State__c, Name FROM Holiday_Data__c]) {
            if (hd.Date__c != null && hd.State__c != null) {
                String k = hd.Date__c.format() + '-' + hd.State__c;
                result.put(k, hd);
            }
        }
        return result;
    }

    // returns 'OriginHub' token like original trim logic; e.g. "HYDERABAD" for "HYD - XYZ"
    private String extractHubKey(String fullName) {
        if (String.isBlank(fullName)) return null;
        String trimmed = fullName.trim();
        if (trimmed.contains('-')) {
            List<String> parts = trimmed.split('\\s*-\\s*');
            if (!parts.isEmpty()) trimmed = parts[0];
        } else {
            List<String> parts = trimmed.split('\\s+');
            if (!parts.isEmpty()) trimmed = parts[0];
        }
        if (trimmed.equalsIgnoreCase('HYD')) return 'HYDERABAD';
        return trimmed;
    }

    private String destinationKeyForShip(Shipment__c s) {
        // primary: Destination_Address_Pincode__c or Destination_Address_Name__r.Active_Pincode__r.Name
        if (!String.isBlank(s.Destination_Address_Pincode__c)) return s.Destination_Address_Pincode__c;
        try {
            if (s.Destination_Address_Name__r != null && s.Destination_Address_Name__r.Active_Pincode__r != null) {
                return s.Destination_Address_Name__r.Active_Pincode__r.Name;
            }
        } catch (Exception ex) {}
        return null;
    }

    private void handlePickupHoliday(Shipment__c ship, Pickup__c pickup) {
        if (pickup == null || pickup.Physical_Pickup_Completed_Time__c == null) return;
        Date checkDate = pickup.Physical_Pickup_Completed_Time__c.date();
        String state = ship.Origin_Address_State__c;
        if (String.isBlank(state)) {
            shipIdToPickupHoliday.put(ship.Id, null);
            return;
        }
        Integer holidayCount = 0;
        List<String> names = new List<String>();
        while (holidayCount < 14) { // safety cap on contiguous holidays
            String key = checkDate.format() + '-' + state;
            Holiday_Data__c hd = holidayDateStateMap.get(key);
            if (hd != null) {
                names.add(hd.Name + ' on ' + hd.Date__c.format() + ' in ' + hd.State__c);
                holidayCount++;
                checkDate = checkDate.addDays(1);
            } else break;
        }
        if (holidayCount > 0) {
            shipIdToPickupHoliday.put(ship.Id, String.join(names, ', '));
        } else {
            shipIdToPickupHoliday.put(ship.Id, '');
        }
    }

    // If no route data available, try finalizing using direct distance calculator
    private void finalizeIfDirectDestination(Shipment__c ship, Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Pickup__c p) {
        String destinationKey = destinationKeyForShip(ship);
        if (destinationKey == null) return;
        Distance_Calculator__c dc = distanceMap.get(destinationKey);
        if (dc == null) return;

        Map<String, Object> destMap = adjustFinalTATSLAHourAndMinute(dc, ship, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, 0);
        Integer FinalTATHour = (Integer)destMap.get('ARHour');
        Integer FinalTATMinute = (Integer)destMap.get('ARMinute');
        Integer FinalTATSeconds = (Integer)destMap.get('ARSeconds');

        Integer additionalHours = FinalTATMinute / 60;
        FinalTATHour += additionalHours;
        FinalTATMinute = Math.mod(FinalTATMinute, 60);

        Integer days = FinalTATHour / 24;
        Integer remainingHours = Math.mod(FinalTATHour, 24);

        Datetime currentDateTime = p != null ? p.Physical_Pickup_Completed_Time__c : Datetime.now();
        Datetime targetDateTime = currentDateTime.addDays(days).addHours(remainingHours).addMinutes(FinalTATMinute).addSeconds(FinalTATSeconds);

        Datetime istDateTime = targetDateTime.addSeconds(19800);
        String slaDay = istDateTime.format('EEEE', 'en_US');

        Date estDate = Date.newInstance(targetDateTime.year(), targetDateTime.month(), targetDateTime.day());
        Integer numberOfDays = Math.abs(estDate.daysBetween(currentDateTime.date()));

        shipIdToFinalTime.put(ship.Id, FinalTATHour + 'H ' + FinalTATMinute + 'M ' + FinalTATSeconds + 'S');
        shipIdToSLADay.put(ship.Id, slaDay);
        shipIdToEstDel.put(ship.Id, targetDateTime);
        shipIdToTatDays.put(ship.Id, numberOfDays);
    }

    private void prepareAndCommitUpdates(Map<Id, Shipment__c> shipMap) {
        // Build TSM updates and shipment updates from computed maps
        for (Id shipId : shipToTsm.keySet()) {
            TAT_SLA_Mapping__c tToUpdate = new TAT_SLA_Mapping__c();
            tToUpdate.Id = shipToTsm.get(shipId).Id;
            tToUpdate.SLA_Hours__c = shipIdToFinalTime.get(shipId);
            tToUpdate.SLA_Day__c = shipIdToSLADay.get(shipId);
            tToUpdate.Estimated_Delivery_Date__c = shipIdToEstDel.get(shipId);
            tToUpdate.TAT_in_Days__c = shipIdToTatDays.get(shipId);
            tToUpdate.Holiday__c = shipIdToHolidayText.get(shipId);
            tToUpdate.Holiday_at_Pickup_Point__c = shipIdToPickupHoliday.get(shipId);
            tToUpdate.Shipment__c = shipId;
            tsmToUpdate.add(tToUpdate);

            // update shipment
            Shipment__c s = shipMap.get(shipId);
            if (s != null) {
                String combined = (shipIdToTatDays.containsKey(shipId) ? String.valueOf(shipIdToTatDays.get(shipId)) : '') + ' Days OR ' + (shipIdToFinalTime.containsKey(shipId) ? shipIdToFinalTime.get(shipId) : '');
                s.SLA_Days_and_Hours__c = combined;
                Datetime est = shipIdToEstDel.get(shipId);
                if (est != null) {
                    s.Estimated_Delivery_Datetime__c = est;
                    s.Estimated_Delivery_Date__c = est.date();
                }
                // physical pickup time copy
                try {
                    s.Physical_Pickup_Completed_Time1__c = s.Pickup__r != null ? s.Pickup__r.Physical_Pickup_Completed_Time__c : null;
                } catch (Exception ex) {}
                shipmentsToUpdate.add(s);
            }
        }

        // DML in bulk (try/catch to log)
        try {
            if (!npToInsert.isEmpty()) insert npToInsert;
            if (!dcToInsert.isEmpty()) insert dcToInsert;
            if (!tsmToUpdate.isEmpty()) update tsmToUpdate;
            if (!shipmentsToUpdate.isEmpty()) update shipmentsToUpdate;
        } catch (Exception dmx) {
            insert new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandler.commit', Error__c = dmx.getMessage());
        }
    }

    // ---------- Core routing / time adjust logic ----------
    // Public-like signature modified to store dp cal records in dcToInsert/npToInsert as earlier.
    // Returns a map with ARHour/ARMinute/ARSeconds/isSameCityLogicExecuted, TATSLAHour/TATSLAMinute
    public Map<String, Object> adjustTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj,
                                                        Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                                        Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        Map<String, Object> result = new Map<String, Object>{
            'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
            'TATSLAHour' => TATSLAHour, 'TATSLAMinute' => TATSLAMinute, 'isSameCityLogicExecuted' => false
        };
        if (dcObj == null) return result;

        Boolean isSameCity = (dcObj.Origin_Pincode__c == dcObj.Destination_Pincode__c)
                             && (shipObj.Destination_Address_City__c == dcObj.City__c)
                             && (shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c);

        Integer SameCityDeliveryHour = 0;
        Integer SameCityDeliveryMinute = 0;

        if (isSameCity) {
            result.put('isSameCityLogicExecuted', true);
            Time sameStart = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c;
            if (sameStart != null) {
                SameCityDeliveryHour = sameStart.hour();
                SameCityDeliveryMinute = sameStart.minute();
            }
            // approximate time from pickup to hub
            Integer hours = 0;
            Integer minutes = 0;
            if (dcObj.Time_from_Pickup_to_Hub__c != null) {
                Decimal d = dcObj.Time_from_Pickup_to_Hub__c;
                hours = d.intValue();
                minutes = (d - hours) * 60 == null ? 0 : (Integer)((d - hours) * 60);
            }

            // if Scheduled time is earlier than baseline TATSLAHour, assume next day shift
            if (SameCityDeliveryHour < TATSLAHour) SameCityDeliveryHour = (SameCityDeliveryHour + 24) - TATSLAHour;
            else SameCityDeliveryHour = SameCityDeliveryHour - TATSLAHour;

            ARHour += (SameCityDeliveryHour + hours);
            ARMinute += (SameCityDeliveryMinute + minutes);

            // normalise ARMinute
            Integer addH = ARMinute / 60;
            ARHour += addH;
            ARMinute = Math.mod(ARMinute, 60);

            // Build final time representation
            String FinalTime = ARHour + 'H ' + ARMinute + 'M ' + ARSeconds + 'S';

            // future datetime from pickup
            Datetime pickupDT = shipObj.Pickup__r != null ? shipObj.Pickup__r.Physical_Pickup_Completed_Time__c : Datetime.now();
            Datetime future = pickupDT.addHours(ARHour).addMinutes(ARMinute).addSeconds(ARSeconds);
            // if delivery falls on same calendar day as pickup, move to next day (preserve original logic)
            if (pickupDT.date() == future.date()) {
                future = future.addDays(1);
                ARHour += 24;
            }
            Datetime ist = future.addSeconds(19800);
            String slaDay = ist.format('EEEE', 'en_US');
            Date EstDelDate = Date.newInstance(future.year(), future.month(), future.day());
            Integer numberOfDays = Math.abs(EstDelDate.daysBetween(pickupDT.date()));

            shipIdToFinalTime.put(shipObj.Id, FinalTime);
            shipIdToSLADay.put(shipObj.Id, slaDay);
            shipIdToEstDel.put(shipObj.Id, future);
            shipIdToTatDays.put(shipObj.Id, numberOfDays);

            // create DC cal record
            Distance_Calculator_For_Calculation__c dcCal = new Distance_Calculator_For_Calculation__c();
            dcCal.Distance_Range__c = dcObj.Distance_Range__c;
            dcCal.State__c = dcObj.State__c;
            dcCal.Time_from_Pickup_to_Hub__c = dcObj.Time_from_Pickup_to_Hub__c;
            dcCal.City__c = dcObj.City__c;
            dcCal.Destination_Pincode__c = dcObj.Destination_Pincode__c;
            dcCal.Distance_km__c = dcObj.Distance_in_km__c;
            dcCal.Same_City_Hub_Delivery_Route_Start_Time__c = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c;
            dcCal.Scheduled_Delivery_Route_Start_Time__c = dcObj.Scheduled_Delivery_Route_Start_Time__c;
            dcCal.Origin_Pincode__c = dcObj.Origin_Pincode__c;
            dcCal.ROUTE_NUMBER__c = dcObj.ROUTE_NUMBER__c;
            dcCal.TAT_SLA_Mapping__c = shipToTsm.containsKey(shipObj.Id) ? shipToTsm.get(shipObj.Id).Id : null;
            dcCal.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
            dcToInsert.add(dcCal);

            // update return values
            result.put('ARHour', ARHour); result.put('ARMinute', ARMinute); result.put('ARSeconds', ARSeconds);
            result.put('TATSLAHour', TATSLAHour); result.put('TATSLAMinute', TATSLAMinute);
            return result;
        }

        // non same-city / other branches:
        // treat Time_from_Pickup_to_Hub__c as hours decimal
        Integer hours = 0;
        Integer minutes = 0;
        if (dcObj.Time_from_Pickup_to_Hub__c != null) {
            Decimal d = dcObj.Time_from_Pickup_to_Hub__c;
            hours = d.intValue();
            minutes = (Integer)((d - hours) * 60);
        }

        // scheduled start time field
        Time sched = dcObj.Scheduled_Delivery_Route_Start_Time__c;
        Integer scheduledDispatchHour = sched != null ? sched.hour() : 0;
        Integer scheduledDispatchMinute = sched != null ? sched.minute() : 0;

        if (scheduledDispatchHour <= TATSLAHour) scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
        else scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;

        ARHour += (scheduledDispatchHour + hours);
        ARMinute += (scheduledDispatchMinute + minutes);

        // normalise ARMinute
        Integer addH = ARMinute / 60;
        ARHour += addH;
        ARMinute = Math.mod(ARMinute, 60);

        // update TATSLA as well (approximation preserved)
        TATSLAHour += scheduledDispatchHour + hours + 1; // original +1 behaviour
        TATSLAMinute += scheduledDispatchMinute + minutes;
        Integer addT = TATSLAMinute / 60;
        TATSLAHour += addT;
        TATSLAMinute = Math.mod(TATSLAMinute, 60);
        if (TATSLAHour >= 24) TATSLAHour = Math.mod(TATSLAHour, 24);

        // add DC calculation record
        Distance_Calculator_For_Calculation__c dcCal2 = new Distance_Calculator_For_Calculation__c();
        dcCal2.Distance_Range__c = dcObj.Distance_Range__c;
        dcCal2.State__c = dcObj.State__c;
        dcCal2.Time_from_Pickup_to_Hub__c = dcObj.Time_from_Pickup_to_Hub__c;
        dcCal2.City__c = dcObj.City__c;
        dcCal2.Destination_Pincode__c = dcObj.Destination_Pincode__c;
        dcCal2.Distance_km__c = dcObj.Distance_in_km__c;
        dcCal2.Same_City_Hub_Delivery_Route_Start_Time__c = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c;
        dcCal2.Scheduled_Delivery_Route_Start_Time__c = dcObj.Scheduled_Delivery_Route_Start_Time__c;
        dcCal2.Origin_Pincode__c = dcObj.Origin_Pincode__c;
        dcCal2.ROUTE_NUMBER__c = dcObj.ROUTE_NUMBER__c;
        dcCal2.TAT_SLA_Mapping__c = shipToTsm.containsKey(shipObj.Id) ? shipToTsm.get(shipObj.Id).Id : null;
        dcCal2.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
        dcToInsert.add(dcCal2);

        result.put('ARHour', ARHour); result.put('ARMinute', ARMinute); result.put('ARSeconds', ARSeconds);
        result.put('TATSLAHour', TATSLAHour); result.put('TATSLAMinute', TATSLAMinute);
        result.put('isSameCityLogicExecuted', false);
        return result;
    }

    public Map<String, Object> adjustFinalTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj,
                                                              Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                                              Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        // Keep logic similar to adjustTATSLAHourAndMinute but uses Time_from_Hub_to_delivery_point__c for final leg
        Map<String, Object> result = new Map<String, Object>{
            'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
            'TATSLAHour' => TATSLAHour, 'TATSLAMinute' => TATSLAMinute
        };
        if (dcObj == null) return result;

        Boolean isSameCity = (dcObj.Origin_Pincode__c == dcObj.Destination_Pincode__c)
                             && (shipObj.Destination_Address_City__c == dcObj.City__c)
                             && (shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c);

        if (isSameCity) {
            Time sameStart = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c;
            Integer SameCityDeliveryHour = sameStart != null ? sameStart.hour() : 0;
            Integer SameCityDeliveryMinute = sameStart != null ? sameStart.minute() : 0;

            if (SameCityDeliveryHour <= TATSLAHour) SameCityDeliveryHour = (SameCityDeliveryHour + 24) - TATSLAHour;
            else SameCityDeliveryHour -= TATSLAHour;

            Integer hours = 0; Integer minutes = 0;
            if (dcObj.Time_from_Hub_to_delivery_point__c != null) {
                Decimal d = dcObj.Time_from_Hub_to_delivery_point__c;
                hours = d.intValue();
                minutes = (Integer)((d - hours) * 60);
            }

            ARHour += (SameCityDeliveryHour + hours);
            ARMinute += (SameCityDeliveryMinute + minutes);
            Integer additionalARHours = ARMinute / 60;
            ARHour += additionalARHours;
            ARMinute = Math.mod(ARMinute, 60);

            TATSLAHour += SameCityDeliveryHour + hours;
            TATSLAMinute += SameCityDeliveryMinute + minutes;
            Integer additionalTATHours = TATSLAMinute / 60;
            TATSLAHour += additionalTATHours;
            TATSLAMinute = Math.mod(TATSLAMinute, 60);
            if (TATSLAHour >= 24) TATSLAHour = Math.mod(TATSLAHour, 24);

            // create dc cal
            Distance_Calculator_For_Calculation__c dcCal = new Distance_Calculator_For_Calculation__c();
            dcCal.Distance_Range__c = dcObj.Distance_Range__c;
            dcCal.State__c = dcObj.State__c;
            dcCal.Time_from_Pickup_to_Hub__c = dcObj.Time_from_Pickup_to_Hub__c;
            dcCal.City__c = dcObj.City__c;
            dcCal.Destination_Pincode__c = dcObj.Destination_Pincode__c;
            dcCal.Distance_km__c = dcObj.Distance_in_km__c;
            dcCal.Same_City_Hub_Delivery_Route_Start_Time__c = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c;
            dcCal.Scheduled_Delivery_Route_Start_Time__c = dcObj.Scheduled_Delivery_Route_Start_Time__c;
            dcCal.Origin_Pincode__c = dcObj.Origin_Pincode__c;
            dcCal.ROUTE_NUMBER__c = dcObj.ROUTE_NUMBER__c;
            dcCal.TAT_SLA_Mapping__c = shipToTsm.containsKey(shipObj.Id) ? shipToTsm.get(shipObj.Id).Id : null;
            dcCal.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
            dcToInsert.add(dcCal);

            result.put('ARHour', ARHour); result.put('ARMinute', ARMinute); result.put('ARSeconds', ARSeconds);
            result.put('TATSLAHour', TATSLAHour); result.put('TATSLAMinute', TATSLAMinute);
            return result;
        }

        // Non same-city: scheduled route start vs TATSLAHour
        Integer scheduledDispatchHour = dcObj.Scheduled_Delivery_Route_Start_Time__c != null ? dcObj.Scheduled_Delivery_Route_Start_Time__c.hour() : 0;
        Integer scheduledDispatchMinute = dcObj.Scheduled_Delivery_Route_Start_Time__c != null ? dcObj.Scheduled_Delivery_Route_Start_Time__c.minute() : 0;

        Integer hours = 0; Integer minutes = 0;
        if (dcObj.Time_from_Hub_to_delivery_point__c != null) {
            Decimal d = dcObj.Time_from_Hub_to_delivery_point__c;
            hours = d.intValue();
            minutes = (Integer)((d - hours) * 60);
        }

        if (scheduledDispatchHour <= TATSLAHour) scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
        else scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;

        ARHour += (scheduledDispatchHour + hours);
        ARMinute += (scheduledDispatchMinute + minutes);

        Integer add = ARMinute / 60;
        ARHour += add;
        ARMinute = Math.mod(ARMinute, 60);

        TATSLAHour += scheduledDispatchHour + hours + 1;
        TATSLAMinute += scheduledDispatchMinute + minutes;
        Integer addT = TATSLAMinute / 60;
        TATSLAHour += addT;
        TATSLAMinute = Math.mod(TATSLAMinute, 60);
        if (TATSLAHour >= 24) TATSLAHour = Math.mod(TATSLAHour, 24);

        Distance_Calculator_For_Calculation__c dcCal2 = new Distance_Calculator_For_Calculation__c();
        dcCal2.Distance_Range__c = dcObj.Distance_Range__c;
        dcCal2.State__c = dcObj.State__c;
        dcCal2.Time_from_Pickup_to_Hub__c = dcObj.Time_from_Pickup_to_Hub__c;
        dcCal2.City__c = dcObj.City__c;
        dcCal2.Destination_Pincode__c = dcObj.Destination_Pincode__c;
        dcCal2.Distance_km__c = dcObj.Distance_in_km__c;
        dcCal2.Same_City_Hub_Delivery_Route_Start_Time__c = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c;
        dcCal2.Scheduled_Delivery_Route_Start_Time__c = dcObj.Scheduled_Delivery_Route_Start_Time__c;
        dcCal2.Origin_Pincode__c = dcObj.Origin_Pincode__c;
        dcCal2.ROUTE_NUMBER__c = dcObj.ROUTE_NUMBER__c;
        dcCal2.TAT_SLA_Mapping__c = shipToTsm.containsKey(shipObj.Id) ? shipToTsm.get(shipObj.Id).Id : null;
        dcCal2.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
        dcToInsert.add(dcCal2);

        result.put('ARHour', ARHour); result.put('ARMinute', ARMinute); result.put('ARSeconds', ARSeconds);
        result.put('TATSLAHour', TATSLAHour); result.put('TATSLAMinute', TATSLAMinute);
        return result;
    }

    // checkNextRoute: traverses networkPlanMap recursively up to MAX_ROUTE_DEPTH
    private void checkNextRoute(String key, Shipment__c shipObj, String destinationKey,
                                Integer[] tatslaArr /* size 3: hour, minute, sec */,
                                Integer[] arArr /* size 3: hour, minute, sec */,
                                Set<String> visited, Integer depth) {
        if (String.isBlank(key) || depth >= MAX_ROUTE_DEPTH) return;
        if (visited.contains(key)) return;
        visited.add(key);

        Network_Plan__c npObj = networkPlanMap.get(key);
        Distance_Calculator__c dcObj = destinationKey != null ? distanceMap.get(destinationKey) : null;

        if (npObj == null) return;

        Map<String, Object> timeMap;
        Boolean isFirstRoad = (depth == 0);
        Boolean isFirstFlight = (depth == 0);

        if (npObj.Transport_Type__c == 'Road') {
            if (npObj.OD_Concat__c != null && npObj.OD_Concat__c == 'BENGALURU_HOSUR') {
                timeMap = adjustMultipleARRoad(npObj, arArr[0], arArr[1], arArr[2], tatslaArr[0], tatslaArr[1], tatslaArr[2], isFirstRoad);
            } else {
                timeMap = adjustARRoad(npObj, arArr[0], arArr[1], arArr[2], tatslaArr[0], tatslaArr[1], tatslaArr[2], isFirstRoad);
            }
        } else if (npObj.Transport_Type__c == 'Air') {
            timeMap = adjustARAir(npObj, arArr[0], arArr[1], arArr[2], tatslaArr[0], tatslaArr[1], tatslaArr[2], isFirstFlight);
        } else {
            timeMap = new Map<String, Object>{'ARHour'=>arArr[0],'ARMinute'=>arArr[1],'ARSeconds'=>arArr[2],'TATSLAHour'=>tatslaArr[0],'TATSLAMinute'=>tatslaArr[1]};
        }

        // push NP cal record
        Network_Plan_For_Calculation__c npCal = new Network_Plan_For_Calculation__c();
        npCal.Approx_Time_Taken_in_hrs__c = npObj.Approx_Time_Taken_in_hrs__c;
        npCal.Destination_City__c = shipObj.Destination_Address_City__c;
        npCal.Destination_Port__c = npObj.Destination_Port__c;
        npCal.Flight_Arrival_Time__c = npObj.Flight_Arrival_Time__c;
        npCal.Flight_Departure_Time__c = npObj.Flight_Departure_Time__c;
        npCal.Flight_No__c = npObj.Flight_No__c;
        npCal.From_Hub__c = npObj.From_Hub__c;
        npCal.Next_Route__c = npObj.Next_Route__c;
        npCal.OD_Concat__c = npObj.OD_Concat__c;
        npCal.Origin_Port__c = npObj.Origin_Port__c;
        npCal.Scheduled_Max_Time_of_Vehicle_Dispatch__c = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
        npCal.To_Destination_Hub__c = npObj.To_Destination_Hub__c;
        npCal.Transport_Type__c = npObj.Transport_Type__c;
        npCal.TAT_SLA_Mapping__c = shipToTsm.containsKey(shipObj.Id) ? shipToTsm.get(shipObj.Id).Id : null;
        npCal.Approx_Time_Taken_in_hrs1__c = npObj.Approx_Time_Taken_in_hrs1__c;
        npCal.Route_No__c = npObj.Route_No__c;
        npCal.Schedule_Airport_handover_time__c = npObj.Schedule_Airport_handover_time__c;
        npCal.Schedule_Arrival_from_airport_to_hub__c = npObj.Schedule_Arrival_from_airport_to_hub__c;
        npCal.Schedule_departure_from_airport_to_hub__c = npObj.Schedule_departure_from_airport_to_hub__c;
        npCal.Schedule_Load_retrival_time__c = npObj.Schedule_Load_retrival_time__c;
        npCal.Scheduled_Arrival_at_Airport__c = npObj.Scheduled_Arrival_at_Airport__c;
        npCal.Hub_Processing_hr__c = npObj.Hub_Processing_hr__c;
        npCal.Scheduled_Arrival_at_Hub__c = npObj.Scheduled_Arrival_at_Hub__c;
        npCal.Scheduled_Max_Time_of_Vehicle_Dispatch_2__c = npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c;
        npCal.Scheduled_Max_Time_of_Vehicle_Dispatch_3__c = npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_3__c;
        npToInsert.add(npCal);

        // apply returned times
        Integer ARHour = (Integer)timeMap.get('ARHour');
        Integer ARMinute = (Integer)timeMap.get('ARMinute');
        Integer ARSeconds = (Integer)timeMap.get('ARSeconds');
        Integer TATSLAHour = (Integer)timeMap.get('TATSLAHour');
        Integer TATSLAMinute = (Integer)timeMap.get('TATSLAMinute');

        // if next route equals the To_Destination_Hub and destination matches dcObj -> finalize
        String nextOrigin = splitRoute(npObj.Next_Route__c);
        if (nextOrigin == npObj.To_Destination_Hub__c) {
            // final leg calculation if destination key matches
            if (dcObj != null && destinationKeyForShip(shipObj) == dcObj.Destination_Pincode__c) {
                // compute time difference, convert to final
                // Use approach similar to earlier: compute hours/minutes/seconds to add then call adjustFinal
                // Compute time difference based on ar times relative to pickup
                // Simplify: call adjustFinalTATSLAHourAndMinute with ARHour/ARMinute etc
                Map<String, Object> finalMap = adjustFinalTATSLAHourAndMinute(dcObj, shipObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, 0);
                Integer FinalTATHour = (Integer)finalMap.get('ARHour');
                Integer FinalTATMinute = (Integer)finalMap.get('ARMinute');
                Integer FinalTATSeconds = (Integer)finalMap.get('ARSeconds');

                Integer additionalHours = FinalTATMinute / 60;
                FinalTATHour += additionalHours;
                FinalTATMinute = Math.mod(FinalTATMinute, 60);

                Integer days = FinalTATHour / 24;
                Integer remainingHours = Math.mod(FinalTATHour, 24);

                Datetime pickupDT = shipObj.Pickup__r != null ? shipObj.Pickup__r.Physical_Pickup_Completed_Time__c : Datetime.now();
                Datetime targetDT = pickupDT.addDays(days).addHours(remainingHours).addMinutes(FinalTATMinute).addSeconds(FinalTATSeconds);

                Datetime ist = targetDT.addSeconds(19800);
                String slaDay = ist.format('EEEE', 'en_US');

                Date estDate = Date.newInstance(targetDT.year(), targetDT.month(), targetDT.day());
                Integer numberOfDays = Math.abs(estDate.daysBetween(pickupDT.date()));

                shipIdToFinalTime.put(shipObj.Id, FinalTATHour + 'H ' + FinalTATMinute + 'M ' + FinalTATSeconds + 'S');
                shipIdToSLADay.put(shipObj.Id, slaDay);
                shipIdToEstDel.put(shipObj.Id, targetDT);
                shipIdToTatDays.put(shipObj.Id, numberOfDays);

                // holiday checking for estimated date (store name)
                String holidayOnEst = '';
                String hdKey = estDate.format() + '-' + (shipObj.Destination_Address_State__c != null ? shipObj.Destination_Address_State__c : '');
                Holiday_Data__c hd = holidayDateStateMap.get(hdKey);
                if (hd != null) holidayOnEst = hd.Name + ' on ' + hd.Date__c.format() + ' in ' + hd.State__c;
                shipIdToHolidayText.put(shipObj.Id, holidayOnEst);
            }
            return;
        }

        // recursion: continue to next route
        // find next destination hub key for ship
        String testDestAddNameKey = extractHubKey(shipObj.Destination_Hub__r != null ? shipObj.Destination_Hub__r.Name : null);
        String newKey = nextOrigin + '_' + testDestAddNameKey;
        checkNextRoute(newKey, shipObj, destinationKey, new Integer[]{TATSLAHour, TATSLAMinute, 0}, new Integer[]{ARHour, ARMinute, ARSeconds}, visited, depth + 1);
    }

    // splitRoute: returns the 2nd token from originalNextRoute as in original code
    private String splitRoute(String originalNextRoute) {
        if (String.isBlank(originalNextRoute)) return '';
        List<String> parts = originalNextRoute.split('_');
        if (parts.size() > 1) return parts[1];
        return '';
    }

    // ----- Road / MultipleRoad / Air adjusters ported and simplified for safety -----
    public Map<String, Object> adjustARRoad(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                            Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeRoad) {
        Map<String, Object> timeMap = new Map<String, Object>();
        if (npObj == null) {
            timeMap.put('ARHour', ARHour); timeMap.put('ARMinute', ARMinute); timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour); timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        }

        Time scheduled = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
        Integer scheduledDispatchHour = scheduled != null ? scheduled.hour() : 0;
        Integer scheduledDispatchMinute = scheduled != null ? scheduled.minute() : 0;

        Integer hours = 0; Integer minutes = 0;
        if (npObj.Approx_Time_Taken_in_hrs1__c != null) {
            Decimal d = npObj.Approx_Time_Taken_in_hrs1__c;
            hours = d.intValue();
            minutes = (Integer)((d - hours) * 60);
        }

        if (isFirstTimeRoad) {
            if (scheduledDispatchHour < TATSLAHour) scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            else scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;

            ARHour += (scheduledDispatchHour + hours);
            ARMinute += (scheduledDispatchMinute + minutes);
            Integer add = ARMinute / 60; ARHour += add; ARMinute = Math.mod(ARMinute, 60);

            // new TATSLA
            Integer tmp = (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null ? npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour() : 0) + hours;
            if (tmp > 24) tmp -= 24;
            TATSLAHour = tmp + 1;
            TATSLAMinute = (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null ? npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute() : 0) + minutes;
            Integer addT = TATSLAMinute / 60; TATSLAHour += addT; TATSLAMinute = Math.mod(TATSLAMinute, 60);
        } else {
            if (scheduledDispatchHour < TATSLAHour) scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            else scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            ARHour += (scheduledDispatchHour + hours);
            ARMinute += (scheduledDispatchMinute + minutes);
            Integer add = ARMinute / 60; ARHour += add; ARMinute = Math.mod(ARMinute, 60);

            TATSLAHour = (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null ? npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour() : 0) + hours;
            TATSLAMinute = (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null ? npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute() : 0) + minutes;
            Integer addT = TATSLAMinute / 60; TATSLAHour += addT; TATSLAMinute = Math.mod(TATSLAMinute, 60);
        }

        timeMap.put('ARHour', ARHour); timeMap.put('ARMinute', ARMinute); timeMap.put('ARSeconds', ARSeconds);
        timeMap.put('TATSLAHour', TATSLAHour); timeMap.put('TATSLAMinute', TATSLAMinute);
        return timeMap;
    }

    public Map<String, Object> adjustMultipleARRoad(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                                    Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeRoad) {
        // Choose the best dispatch among up to 3 dispatch slots and then apply similar logic as adjustARRoad.
        Map<String, Object> timeMap = new Map<String, Object>();
        if (npObj == null) {
            timeMap.put('ARHour', ARHour); timeMap.put('ARMinute', ARMinute); timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour); timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        }

        List<Time> dispatchTimes = new List<Time>();
        if (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null) dispatchTimes.add(npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c);
        if (npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c != null) dispatchTimes.add(npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c);
        if (npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_3__c != null) dispatchTimes.add(npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_3__c);

        // convert TATSLA to minutes for comparison
        Integer tatMinutes = (TATSLAHour != null ? TATSLAHour : 0) * 60 + (TATSLAMinute != null ? TATSLAMinute : 0);
        Integer bestDiff = 2147483647;
        Time chosen = null;
        for (Time t : dispatchTimes) {
            Integer tm = t.hour() * 60 + t.minute();
            if (tm >= tatMinutes) {
                Integer diff = tm - tatMinutes;
                if (diff < bestDiff) { bestDiff = diff; chosen = t; }
            }
        }
        if (chosen == null && !dispatchTimes.isEmpty()) {
            // pick earliest dispatch but next day
            chosen = dispatchTimes[0];
            for (Time t : dispatchTimes) {
                if (t.hour() * 60 + t.minute() < chosen.hour() * 60 + chosen.minute()) chosen = t;
            }
        }

        Integer chosenHour = chosen != null ? chosen.hour() : 0;
        Integer chosenMinute = chosen != null ? chosen.minute() : 0;

        Integer hours = 0; Integer minutes = 0;
        if (npObj.Approx_Time_Taken_in_hrs1__c != null) {
            Decimal d = npObj.Approx_Time_Taken_in_hrs1__c;
            hours = d.intValue();
            minutes = (Integer)((d - hours) * 60);
        }

        Integer adjustedDispatchHour = chosenHour;
        // if chosen dispatch is earlier than TATSLA, treat as next day
        if (chosenHour < TATSLAHour) chosenHour = (chosenHour + 24) - TATSLAHour;
        else chosenHour = chosenHour - TATSLAHour;

        if (isFirstTimeRoad) {
            ARHour += (chosenHour + hours);
            ARMinute += (chosenMinute + minutes);
            Integer add = ARMinute / 60; ARHour += add; ARMinute = Math.mod(ARMinute, 60);

            Integer tmpTAT = adjustedDispatchHour + hours;
            if (tmpTAT > 24) tmpTAT -= 24;
            TATSLAHour = tmpTAT + 1;
            TATSLAMinute = chosenMinute;
            Integer addT = TATSLAMinute / 60; TATSLAHour += addT; TATSLAMinute = Math.mod(TATSLAMinute, 60);
        } else {
            ARHour += (chosenHour + hours);
            ARMinute += (chosenMinute + minutes);
            Integer add = ARMinute / 60; ARHour += add; ARMinute = Math.mod(ARMinute, 60);

            TATSLAHour = adjustedDispatchHour + hours;
            TATSLAMinute = chosenMinute + minutes;
            Integer addT = TATSLAMinute / 60; TATSLAHour += addT; TATSLAMinute = Math.mod(TATSLAMinute, 60);
        }

        timeMap.put('ARHour', ARHour); timeMap.put('ARMinute', ARMinute); timeMap.put('ARSeconds', ARSeconds);
        timeMap.put('TATSLAHour', TATSLAHour); timeMap.put('TATSLAMinute', TATSLAMinute);
        return timeMap;
    }

    public Map<String, Object> adjustARAir(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                           Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeFlight) {
        Map<String, Object> timeMap = new Map<String, Object>();
        if (npObj == null) {
            timeMap.put('ARHour', ARHour); timeMap.put('ARMinute', ARMinute); timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour); timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        }

        // get scheduled dispatch and flight times
        Time scheduledDispatch = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
        Integer scheduledDispatchHour = scheduledDispatch != null ? scheduledDispatch.hour() : 0;
        Integer scheduledDispatchMinute = scheduledDispatch != null ? scheduledDispatch.minute() : 0;

        Time flightDep = npObj.Flight_Departure_Time__c;
        Time flightArr = npObj.Flight_Arrival_Time__c;

        // hours difference from dispatch to flight departure (hub to port)
        Integer HoursTimeFromHubToPort = 0;
        if (flightDep != null) {
            if (flightDep.hour() < scheduledDispatchHour) HoursTimeFromHubToPort = (24 + flightDep.hour()) - scheduledDispatchHour;
            else HoursTimeFromHubToPort = flightDep.hour() - scheduledDispatchHour;
        }
        Integer MinutesTimeFromHubToPort = flightDep != null ? flightDep.minute() - scheduledDispatchMinute : 0;
        Integer SecondsTimeFromHubToPort = flightDep != null ? flightDep.second() - (scheduledDispatchSecond(scheduledDispatch)) : 0;
        if (MinutesTimeFromHubToPort < 0) { MinutesTimeFromHubToPort += 60; HoursTimeFromHubToPort -= 1; }

        // flight duration in hours/minutes/seconds
        Integer FlightTimeHour = 0; Integer FlightTimeMinute = 0; Integer FlightTimeSeconds = 0;
        if (flightDep != null && flightArr != null) {
            Integer depTotal = flightDep.hour() * 3600 + flightDep.minute() * 60 + flightDep.second();
            Integer arrTotal = flightArr.hour() * 3600 + flightArr.minute() * 60 + flightArr.second();
            if (arrTotal < depTotal) arrTotal += 24 * 3600;
            Integer diff = arrTotal - depTotal;
            FlightTimeHour = diff / 3600;
            Integer rem = diff - FlightTimeHour * 3600;
            FlightTimeMinute = rem / 60;
            FlightTimeSeconds = rem - FlightTimeMinute * 60;
        }

        // time to reach hub after arrival
        Integer scheduledArrivalHourAtNextHub = npObj.Schedule_Arrival_from_airport_to_hub__c != null ? npObj.Schedule_Arrival_from_airport_to_hub__c.hour() : 0;
        Integer scheduledArrivalMinuteAtNextHub = npObj.Schedule_departure_from_airport_to_hub__c != null ? npObj.Schedule_departure_from_airport_to_hub__c.minute() : 0;
        Integer hourToReachNextHubAfterArrival;
        if (scheduledArrivalHourAtNextHub < (flightArr != null ? flightArr.hour() : 0)) {
            hourToReachNextHubAfterArrival = (24 + scheduledArrivalHourAtNextHub) - (flightArr != null ? flightArr.hour() : 0);
        } else {
            hourToReachNextHubAfterArrival = scheduledArrivalHourAtNextHub - (flightArr != null ? flightArr.hour() : 0);
        }
        Integer minuteToReachNextHubAfterArrival = scheduledArrivalMinuteAtNextHub - (flightArr != null ? flightArr.minute() : 0);
        if (minuteToReachNextHubAfterArrival < 0) {
            minuteToReachNextHubAfterArrival += 60;
            hourToReachNextHubAfterArrival -= 1;
        }

        // convert scheduled dispatch relative to TATSLAHour
        Integer tmpScheduled = scheduledDispatchHour;
        if (scheduledDispatchHour < TATSLAHour || (scheduledDispatchHour == TATSLAHour && scheduledDispatchMinute < TATSLAMinute)) {
            scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
        } else scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;

        ARHour += (scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival);
        ARMinute += (scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival);
        ARSeconds += (FlightTimeSeconds + SecondsTimeFromHubToPort);

        // normalize
        Integer addARMin = ARMinute / 60; ARHour += addARMin; ARMinute = Math.mod(ARMinute, 60);
        Integer addARSec = ARSeconds / 60; ARMinute += addARSec; ARSeconds = Math.mod(ARSeconds, 60);
        addARMin = ARMinute / 60; ARHour += addARMin; ARMinute = Math.mod(ARMinute, 60);

        // TATSLA update
        TATSLAHour = tmpScheduled + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival;
        TATSLAMinute = scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival;
        if (TATSLAMinute >= 60) { TATSLAHour += (TATSLAMinute / 60); TATSLAMinute = Math.mod(TATSLAMinute, 60); }
        if (TATSLAHour >= 24) TATSLAHour = Math.mod(TATSLAHour, 24);

        timeMap.put('ARHour', ARHour); timeMap.put('ARMinute', ARMinute); timeMap.put('ARSeconds', ARSeconds);
        timeMap.put('TATSLAHour', TATSLAHour); timeMap.put('TATSLAMinute', TATSLAMinute);
        return timeMap;
    }

    private Integer scheduledDispatchSecond(Time t) {
        return t != null ? t.second() : 0;
    }
}