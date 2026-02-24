public with sharing class RouteService {

    private Map<String, Network_Plan__c> networkPlanMap;
    private Map<String, Distance_Calculator__c> distanceMap;
    private Integer maxDepth;

    public class RouteResult {
        public Integer ARHour;
        public Integer ARMinute;
        public Integer ARSeconds;
        public String finalTime;
        public String slaDay;
        public Datetime estimatedDeliveryDateTime;
        public Integer tatInDays;
        public String holidayText;
        public List<Network_Plan_For_Calculation__c> npCalRecords = new List<Network_Plan_For_Calculation__c>();
        public List<Distance_Calculator_For_Calculation__c> dcCalRecords = new List<Distance_Calculator_For_Calculation__c>();
    }

    public RouteService(Map<String, Network_Plan__c> networkPlanMap, Map<String, Distance_Calculator__c> distanceMap, Integer maxDepth) {
        this.networkPlanMap = networkPlanMap != null ? networkPlanMap : new Map<String, Network_Plan__c>();
        this.distanceMap = distanceMap != null ? distanceMap : new Map<String, Distance_Calculator__c>();
        this.maxDepth = maxDepth != null ? maxDepth : 20;
    }

    // Main orchestrator for a shipment — returns RouteResult with final values
    public RouteResult calculateForShipment(Shipment__c ship, TAT_SLA_Mapping__c tsm, Datetime pickupDateTime,
                                           Integer baseTATHour, Integer baseTATMinute, Integer baseTATSecond,
                                           HolidayService holidayService) {
        RouteResult res = new RouteResult();
        // Simple guard
        if (ship == null || tsm == null) return null;

        // Determine starting route key — use Origin_Hub__r and Destination_Hub__r names (safe trim/split)
        String originKey = normalizeHubName(ship.Origin_Hub__r != null ? ship.Origin_Hub__r.Name : null);
        String destKey = normalizeHubName(ship.Destination_Hub__r != null ? ship.Destination_Hub__r.Name : null);
        String routeKey = originKey + '_' + destKey;

        // destination pincode key for distanceMap lookup
        String destinationPincode = ship.Destination_Address_Pincode__c;

        // initial AR/ TAT values
        Integer ARHour = 0, ARMinute = 0, ARSeconds = 0;
        Integer TATSLAHour = baseTATHour, TATSLAMinute = baseTATMinute, TATSLASeconds = baseTATSecond;

        // visited routes for recursion guard
        Set<String> visited = new Set<String>();
        // call recursive traversal (breadth-limited)
        traverseRoutes(routeKey, ship, tsm, destinationPincode, visited, 0, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, res, holidayService);

        return res;
    }

    // Recursive route traversal with depth guard; populates RouteResult
    private void traverseRoutes(String key, Shipment__c ship, TAT_SLA_Mapping__c tsm, String destinationPincode,
                                Set<String> visited, Integer depth, Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds,
                                RouteResult res, HolidayService holidayService) {
        if (key == null || visited.contains(key) || depth > maxDepth) return;
        visited.add(key);

        Network_Plan__c np = networkPlanMap.get(key);
        Distance_Calculator__c dcForDest = destinationPincode != null ? distanceMap.get(destinationPincode) : null;

        if (np == null) {
            return;
        }

        // convert times and choose correct adjust function based on transport type
        Map<String, Integer> timeMap;
        if (np.Transport_Type__c == 'Road') {
            // choose single or multiple dispatch adjust
            if (np.OD_Concat__c != null && np.OD_Concat__c.contains('BENGALURU_HOSUR')) {
                timeMap = adjustMultipleARRoad(np, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, depth == 0);
            } else {
                timeMap = adjustARRoad(np, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, depth == 0);
            }
        } else if (np.Transport_Type__c == 'Air') {
            timeMap = adjustARAir(np, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, depth == 0);
        } else {
            // default treat like road
            timeMap = adjustARRoad(np, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, depth == 0);
        }

        // update AR/TAT with returned values (safe cast)
        ARHour = timeMap.get('ARHour'); ARMinute = timeMap.get('ARMinute'); ARSeconds = timeMap.get('ARSeconds');
        TATSLAHour = timeMap.get('TATSLAHour'); TATSLAMinute = timeMap.get('TATSLAMinute');

        // add a Network_Plan_For_Calculation__c record for audit
        Network_Plan_For_Calculation__c npc = new Network_Plan_For_Calculation__c();
        npc.Approx_Time_Taken_in_hrs__c = np.Approx_Time_Taken_in_hrs__c;
        npc.OD_Concat__c = np.OD_Concat__c;
        npc.Transport_Type__c = np.Transport_Type__c;
        npc.TAT_SLA_Mapping__c = tsm.Id;
        res.npCalRecords.add(npc);

        // If this route leads to final destination hub, compute final destination timing
        // Here I use distanceMap destination pincode entry to decide final leg
        Distance_Calculator__c dcDest = dcForDest;
        if (dcDest != null) {
            // Compute target date/time for delivery from pickup baseline
            Datetime pickDT = ship.Pickup__r != null ? ship.Pickup__r.Physical_Pickup_Completed_Time__c : null;
            if (pickDT == null) return;

            // Normalize ARMinute overflow into ARHour
            SLAService.TimeParts normalized = SLAService.normalize(ARHour, ARMinute, ARSeconds);
            ARHour = normalized.hours; ARMinute = normalized.minutes; ARSeconds = normalized.seconds;

            Integer ARdays = ARHour / 24;
            Integer remainingARHours = Math.mod(ARHour, 24);

            Datetime targetDateTime = pickDT.addDays(ARdays).addHours(remainingARHours).addMinutes(ARMinute).addSeconds(ARSeconds);

            // adjust for serviceable days & holidays
            String slaDay = targetDateTime.addSeconds(19800).format('EEEE', 'en_US'); // IST day
            Map<String, Boolean> serviceableDays = buildServiceableDaysMap(ship);

            Integer weeksLookAhead = 7;
            Integer tries = 0;
            String holidayText = '';
            while (tries < weeksLookAhead) {
                Date estDate = Date.newInstance(targetDateTime.year(), targetDateTime.month(), targetDateTime.day());
                Holiday_Data__c hd = holidayService.getHoliday(estDate, ship.Destination_Address_State__c);
                slaDay = targetDateTime.addSeconds(19800).format('EEEE', 'en_US');
                Boolean isServiceable = serviceableDays.containsKey(slaDay) && serviceableDays.get(slaDay);
                if (!isServiceable || hd != null) {
                    if (hd != null) {
                        holidayText += (holidayText == '' ? '' : ', ') + hd.Name + ' on ' + hd.Date__c.format() + ' in ' + hd.State__c;
                    }
                    targetDateTime = targetDateTime.addDays(1);
                    ARHour += 24;
                    tries++;
                    continue;
                }
                break;
            }

            Integer finalHours = ARHour;
            Integer finalMinutes = ARMinute;
            Integer finalSeconds = ARSeconds;
            String finalTimeFormatted = SLAService.formatFinalTime(finalHours, finalMinutes, finalSeconds);

            res.finalTime = finalTimeFormatted;
            res.slaDay = slaDay;
            res.estimatedDeliveryDateTime = targetDateTime;
            res.tatInDays = SLAService.calculateTatInDays(pickDT.date(), targetDateTime.date());
            res.holidayText = holidayText;

            // add DC record for audit
            Distance_Calculator_For_Calculation__c dcc = new Distance_Calculator_For_Calculation__c();
            dcc.Destination_Pincode__c = dcDest.Destination_Pincode__c;
            dcc.City__c = dcDest.City__c;
            dcc.Time_from_Pickup_to_Hub__c = dcDest.Time_from_Pickup_to_Hub__c;
            dcc.TAT_SLA_Mapping__c = tsm.Id;
            res.dcCalRecords.add(dcc);

            return;
        }

        // If not final, step to next route if available
        String nextOrigin = splitRoute(np.Next_Route__c);
        String toDestinationHub = np.To_Destination_Hub__c;
        String nextKey = nextOrigin + '_' + normalizeHubName(toDestinationHub);
        traverseRoutes(nextKey, ship, tsm, destinationPincode, visited, depth + 1, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, res, holidayService);
    }

    // Build serviceableDays map from shipment destination pincode flags (safe guard)
    private Map<String, Boolean> buildServiceableDaysMap(Shipment__c ship) {
        Map<String, Boolean> serviceableDays = new Map<String, Boolean>{
            'Monday' => false, 'Tuesday' => false, 'Wednesday' => false, 'Thursday' => false,
            'Friday' => false, 'Saturday' => false, 'Sunday' => false
        };
        if (ship.Destination_Address_Name__r != null) {
            Active_Pincode__c pc = ship.Destination_Address_Name__r.Active_Pincode__r;
            if (pc != null) {
                serviceableDays.put('Monday', pc.Monday__c);
                serviceableDays.put('Tuesday', pc.Tuesday__c);
                serviceableDays.put('Wednesday', pc.Wednesday__c);
                serviceableDays.put('Thursday', pc.Thursday__c);
                serviceableDays.put('Friday', pc.Friday__c);
                serviceableDays.put('Saturday', pc.Saturday__c);
                serviceableDays.put('Sunday', pc.Sunday__c);
            }
        }
        return serviceableDays;
    }

    // Helpers for normalizing hub names (trim/split/HYD->HYDERABAD)
    private String normalizeHubName(String raw) {
        if (raw == null) return '';
        String s = raw.trim();
        if (s.contains('-')) {
            List<String> parts = s.split('\\s*-\\s*');
            if (!parts.isEmpty()) s = parts[0];
        } else {
            List<String> parts = s.split('\\s+');
            if (!parts.isEmpty()) s = parts[0];
        }
        if (s.equalsIgnoreCase('HYD')) s = 'HYDERABAD';
        return s;
    }

    private String splitRoute(String originalNextRoute) {
        if (originalNextRoute == null) return '';
        List<String> parts = originalNextRoute.split('_');
        if (parts.size() > 1) return parts[1];
        return '';
    }

    // ---------- Simplified adjust methods (kept logic similar to original; must be adapted per real data) ----------
    private Map<String, Integer> adjustARRoad(Network_Plan__c np, Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                              Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTime) {
        Map<String, Integer> timeMap = new Map<String, Integer>{
            'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
            'TATSLAHour' => TATSLAHour, 'TATSLAMinute' => TATSLAMinute
        };

        Time sched = np.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
        Integer schedHour = sched != null ? sched.hour() : 0;
        Integer schedMinute = sched != null ? sched.minute() : 0;

        Integer approxHours = 0;
        Integer approxMinutes = 0;
        if (np.Approx_Time_Taken_in_hrs1__c != null) {
            Decimal d = np.Approx_Time_Taken_in_hrs1__c;
            approxHours = d.intValue();
            Decimal frac = d - approxHours;
            approxMinutes = (frac * 60).intValue();
        }

        if (isFirstTime) {
            Integer adjusted = schedHour < TATSLAHour ? (schedHour + 24) - TATSLAHour : schedHour - TATSLAHour;
            ARHour += adjusted + approxHours;
            ARMinute += schedMinute + approxMinutes;
            SLAService.TimeParts n = SLAService.normalize(ARHour, ARMinute, ARSeconds);
            ARHour = n.hours; ARMinute = n.minutes; ARSeconds = n.seconds;

            Integer tmpTAT = schedHour + approxHours;
            if (tmpTAT > 24) tmpTAT = tmpTAT - 24;
            Integer newTATHour = tmpTAT + 1;
            Integer newTATMinute = schedMinute + approxMinutes;
            SLAService.TimeParts tnorm = SLAService.normalize(newTATHour, newTATMinute, 0);
            timeMap.put('ARHour', ARHour); timeMap.put('ARMinute', ARMinute); timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', tnorm.hours); timeMap.put('TATSLAMinute', tnorm.minutes);
            return timeMap;
        } else {
            Integer adjusted = schedHour < TATSLAHour ? (schedHour + 24) - TATSLAHour : schedHour - TATSLAHour;
            ARHour += adjusted + approxHours;
            ARMinute += schedMinute + approxMinutes;
            SLAService.TimeParts n = SLAService.normalize(ARHour, ARMinute, ARSeconds);
            ARHour = n.hours; ARMinute = n.minutes; ARSeconds = n.seconds;

            Integer newTATHour = schedHour + approxHours;
            Integer newTATMinute = schedMinute + approxMinutes;
            SLAService.TimeParts tnorm = SLAService.normalize(newTATHour, newTATMinute, 0);
            timeMap.put('ARHour', ARHour); timeMap.put('ARMinute', ARMinute); timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', tnorm.hours); timeMap.put('TATSLAMinute', tnorm.minutes);
            return timeMap;
        }
    }

    private Map<String, Integer> adjustMultipleARRoad(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                                      Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeRoad) {
        // Choose best dispatch among multiple dispatch times (simplified)
        Time d1 = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
        Time d2 = npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c;
        Time d3 = npObj.Scheduled_max_time_of_vehicle_dispatch_3__c;

        List<Time> dispatches = new List<Time>();
        if (d1 != null) dispatches.add(d1);
        if (d2 != null) dispatches.add(d2);
        if (d3 != null) dispatches.add(d3);
        // find dispatch >= TATSLAHour:TATSLAMinute or pick earliest next day
        Integer tatTotalMin = (TATSLAHour != null ? TATSLAHour : 0) * 60 + (TATSLAMinute != null ? TATSLAMinute : 0);
        Time chosen = null;
        Integer chosenTotalMin = null;
        for (Time t : dispatches) {
            Integer tm = t.hour() * 60 + t.minute();
            if (tm >= tatTotalMin) {
                if (chosen == null || tm < chosenTotalMin) {
                    chosen = t; chosenTotalMin = tm;
                }
            }
        }
        if (chosen == null && !dispatches.isEmpty()) {
            chosen = dispatches[0];
            chosenTotalMin = chosen.hour() * 60 + chosen.minute();
            // next day add 24 hours later in logic
        }

        Integer chosenHour = chosen != null ? chosen.hour() : 0;
        Integer chosenMinute = chosen != null ? chosen.minute() : 0;

        Integer approxHours = 0; Integer approxMinutes = 0;
        if (npObj.Approx_Time_Taken_in_hrs1__c != null) {
            Decimal d = npObj.Approx_Time_Taken_in_hrs1__c;
            approxHours = d.intValue();
            approxMinutes = (Integer)((d - approxHours) * 60);
        }

        // similar logic to adjustARRoad but using chosen
        if (isFirstTimeRoad) {
            Integer adjusted = chosenHour < TATSLAHour ? (chosenHour + 24) - TATSLAHour : chosenHour - TATSLAHour;
            ARHour += adjusted + approxHours;
            ARMinute += chosenMinute + approxMinutes;
            SLAService.TimeParts n = SLAService.normalize(ARHour, ARMinute, ARSeconds);
            ARHour = n.hours; ARMinute = n.minutes; ARSeconds = n.seconds;

            Integer tmpTAT = chosenHour + approxHours;
            if (tmpTAT > 24) tmpTAT -= 24;
            Integer newTATHour = tmpTAT + 1;
            Integer newTATMinute = chosenMinute + approxMinutes;
            SLAService.TimeParts tnorm = SLAService.normalize(newTATHour, newTATMinute, 0);

            return new Map<String,Integer>{ 'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
                                           'TATSLAHour' => tnorm.hours, 'TATSLAMinute' => tnorm.minutes };
        } else {
            Integer adjusted = chosenHour < TATSLAHour ? (chosenHour + 24) - TATSLAHour : chosenHour - TATSLAHour;
            ARHour += adjusted + approxHours;
            ARMinute += chosenMinute + approxMinutes;
            SLAService.TimeParts n = SLAService.normalize(ARHour, ARMinute, ARSeconds);
            ARHour = n.hours; ARMinute = n.minutes; ARSeconds = n.seconds;

            Integer newTATHour = chosenHour + approxHours;
            Integer newTATMinute = chosenMinute + approxMinutes;
            SLAService.TimeParts tnorm = SLAService.normalize(newTATHour, newTATMinute, 0);

            return new Map<String,Integer>{ 'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
                                           'TATSLAHour' => tnorm.hours, 'TATSLAMinute' => tnorm.minutes };
        }
    }

    private Map<String, Integer> adjustARAir(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                             Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeFlight) {
        // Simplified but robust air handling: compute flight duration carefully, account for next-day arrivals
        Time schedDispatch = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
        Integer schedHour = schedDispatch != null ? schedDispatch.hour() : 0;
        Integer schedMin = schedDispatch != null ? schedDispatch.minute() : 0;

        Integer tmpScheduledDispatchHour = schedHour;

        // Flight times
        Time dep = npObj.Flight_Departure_Time__c;
        Time arr = npObj.Flight_Arrival_Time__c;
        if (dep == null || arr == null) {
            // fallback to treat as road approx
            return adjustARRoad(npObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, isFirstTimeFlight);
        }

        Integer depSec = dep.hour() * 3600 + dep.minute() * 60 + dep.second();
        Integer arrSec = arr.hour() * 3600 + arr.minute() * 60 + arr.second();
        if (arrSec < depSec) arrSec += 24 * 3600;
        Integer diffSec = arrSec - depSec;
        Integer flightH = diffSec / 3600;
        Integer rem = diffSec - flightH * 3600;
        Integer flightM = rem / 60;
        Integer flightS = rem - flightM * 60;

        // time from dispatch to departure (hub->airport)
        Integer hubToPortHours = 0;
        if (dep.hour() < schedHour) hubToPortHours = (24 + dep.hour()) - schedHour;
        else hubToPortHours = dep.hour() - schedHour;
        Integer minutesTimeFromHubToPort = dep.minute() - schedMin;
        if (minutesTimeFromHubToPort < 0) {
            minutesTimeFromHubToPort += 60;
            hubToPortHours -= 1;
        }

        if (isFirstTimeFlight) {
            // remove TATSLA offset logic (similar to original)
            if (schedHour < TATSLAHour || (schedHour == TATSLAHour && schedMin < TATSLAMinute)) {
                schedHour = (schedHour + 24) - TATSLAHour;
            } else {
                schedHour = schedHour - TATSLAHour;
            }
        } else {
            if (schedHour < TATSLAHour || (schedHour == TATSLAHour && schedMin < TATSLAMinute)) {
                schedHour = (schedHour + 24) - TATSLAHour;
            } else {
                schedHour = schedHour - TATSLAHour;
            }
        }

        ARHour += (schedHour + hubToPortHours + flightH);
        ARMinute += (schedMin + minutesTimeFromHubToPort + flightM);
        ARSeconds += (flightS + 0);

        SLAService.TimeParts n = SLAService.normalize(ARHour, ARMinute, ARSeconds);
        ARHour = n.hours; ARMinute = n.minutes; ARSeconds = n.seconds;

        Integer newTATHour = tmpScheduledDispatchHour + hubToPortHours + flightH;
        Integer newTATMinute = schedMin + minutesTimeFromHubToPort + flightM;
        SLAService.TimeParts tnorm = SLAService.normalize(newTATHour, newTATMinute, 0);

        return new Map<String, Integer>{ 'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
                                        'TATSLAHour' => tnorm.hours, 'TATSLAMinute' => tnorm.minutes };
    }
}