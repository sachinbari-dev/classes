global with sharing class SLACalculatorBatch1 implements Database.Batchable<SObject>, Database.Stateful {

    // Instance state (per batch job)
    private List<Shipment__c> shipments;
    private Map<String, Distance_Calculator__c> distanceMap;
    private Map<String, Network_Plan__c> networkPlanMap;
    private Map<String, Holiday_Data__c> holidayDateStateMap;
    private Map<Id, TAT_SLA_Mapping__c> shipIdToTSM = new Map<Id, TAT_SLA_Mapping__c>();
    private List<Network_Plan_For_Calculation__c> npCalToInsert = new List<Network_Plan_For_Calculation__c>();
    private List<Distance_Calculator_For_Calculation__c> dcCalToInsert = new List<Distance_Calculator_For_Calculation__c>();
    private List<TAT_SLA_Mapping__c> tsmToUpdate = new List<TAT_SLA_Mapping__c>();
    private List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();

    // Results (populated by services)
    private Map<Id, String> shipIdVsFinalTime = new Map<Id, String>();
    private Map<Id, String> shipIdVsSLADay = new Map<Id, String>();
    private Map<Id, Datetime> shipIdVsEstDelDate = new Map<Id, Datetime>();
    private Map<Id, Integer> shipIdVsTatInDays = new Map<Id, Integer>();
    private Map<Id, String> shipIdVsHolidayDay = new Map<Id, String>();
    private Map<Id, String> shipIdVsPickupHoliday = new Map<Id, String>();

    // Config
    private final Integer MAX_ROUTE_DEPTH = 20;

    // Constructor accepts shipments (from trigger or caller)
    public SLACalculatorBatch1(List<Shipment__c> shipList) {
        this.shipments = shipList != null ? shipList : new List<Shipment__c>();
    }

    global Iterable<sObject> start(Database.BatchableContext bc) {
        // Preload reference data (one time)
        distanceMap = loadDistanceMap();
        networkPlanMap = loadNetworkPlanMap();
        holidayDateStateMap = loadHolidayDateStateMap();

        // Pre-create TAT_SLA_Mapping__c records for each shipment (bulk create)
        for (Shipment__c s : shipments) {
            TAT_SLA_Mapping__c tsm = new TAT_SLA_Mapping__c(
                Origin_Pincode__c = s.Origin_Address_Name__r != null ? s.Origin_Address_Name__r.Active_Pincode__c : null,
                Destination_Pincode__c = s.Destination_Address_Name__r != null ? s.Destination_Address_Name__r.Active_Pincode__c : null,
                Shipment__c = s.Id
            );
            shipIdToTSM.put(s.Id, tsm);
        }
        if (!shipIdToTSM.isEmpty()) {
            insert shipIdToTSM.values();
        }

        // Query updated TSM with IDs (they have been inserted)
        for (TAT_SLA_Mapping__c t : [SELECT Id, Shipment__c FROM TAT_SLA_Mapping__c WHERE Shipment__c IN :shipments]) {
            shipIdToTSM.put(t.Shipment__c, t);
        }

        return (Iterable<sObject>) this.shipments;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Shipment__c> localShipments = (List<Shipment__c>) scope;

        // build pickup map in bulk
        Set<Id> pickupIds = new Set<Id>();
        for (Shipment__c s : localShipments) {
            if (s.Pickup__c != null) pickupIds.add(s.Pickup__c);
        }
        Map<Id, Pickup__c> pickupMap = new Map<Id, Pickup__c>();
        if (!pickupIds.isEmpty()) {
            pickupMap = new Map<Id, Pickup__c>(
                [SELECT Id, Origin_Address_Pincode__c, Physical_Pickup_Completed_Time__c
                 FROM Pickup__c WHERE Id IN :pickupIds]);
        }

        // Use services for calculation
        HolidayService holidayService = new HolidayService(holidayDateStateMap);
        SLAService slaService = new SLAService();
        RouteService routeService = new RouteService(networkPlanMap, distanceMap, MAX_ROUTE_DEPTH);

        // Process each shipment
        for (Shipment__c ship : localShipments) {
            try {
                // basic safety checks
                if (ship.Pickup__c == null || pickupMap.get(ship.Pickup__c) == null) continue;
                Pickup__c p = pickupMap.get(ship.Pickup__c);
                if (p.Physical_Pickup_Completed_Time__c == null) continue;

                // Get TSM record id for linking DC/NP cal records later
                TAT_SLA_Mapping__c tsm = shipIdToTSM.get(ship.Id);
                if (tsm == null) continue;

                // Process pickup-holidays (multi-day contiguous holiday handling)
                String pickupHolidayText = holidayService.getPickupHolidayText(p.Physical_Pickup_Completed_Time__c.date(), ship.Origin_Address_State__c);
                shipIdVsPickupHoliday.put(ship.Id, pickupHolidayText);

                // Start TAT baseline from pickup time
                Datetime pickupDateTime = p.Physical_Pickup_Completed_Time__c;
                Integer baseTATHours = pickupDateTime.hour();
                Integer baseTATMinutes = pickupDateTime.minute();
                Integer baseTATSeconds = pickupDateTime.second();

                // call routeService to traverse routes and compute ARHour/Minute etc.
                RouteService.RouteResult rr = routeService.calculateForShipment(
                    ship,
                    tsm,
                    pickupDateTime,
                    baseTATHours,
                    baseTATMinutes,
                    baseTATSeconds,
                    holidayService
                );

                // rr contains final ARHour/Minute/Seconds, FinalTime, EstDelDate etc.
                if (rr != null) {
                    shipIdVsFinalTime.put(ship.Id, rr.finalTime);
                    shipIdVsSLADay.put(ship.Id, rr.slaDay);
                    shipIdVsEstDelDate.put(ship.Id, rr.estimatedDeliveryDateTime);
                    shipIdVsTatInDays.put(ship.Id, rr.tatInDays);
                    shipIdVsHolidayDay.put(ship.Id, rr.holidayText);

                    // create NP and DC cal records from rr (if any)
                    if (!rr.npCalRecords.isEmpty()) npCalToInsert.addAll(rr.npCalRecords);
                    if (!rr.dcCalRecords.isEmpty()) dcCalToInsert.addAll(rr.dcCalRecords);

                    // Prepare TSM update
                    TAT_SLA_Mapping__c tToUpdate = new TAT_SLA_Mapping__c(
                        Id = tsm.Id,
                        SLA_Hours__c = rr.finalTime,
                        SLA_Day__c = rr.slaDay,
                        Estimated_Delivery_Date__c = rr.estimatedDeliveryDateTime,
                        TAT_in_Days__c = rr.tatInDays,
                        Holiday__c = rr.holidayText,
                        Holiday_at_Pickup_Point__c = pickupHolidayText,
                        Shipment__c = ship.Id
                    );
                    tsmToUpdate.add(tToUpdate);

                    // Prepare shipment update
                    ship.SLA_Days_and_Hours__c = String.valueOf(rr.tatInDays) + ' Days OR ' + rr.finalTime;
                    ship.Estimated_Delivery_Datetime__c = rr.estimatedDeliveryDateTime;
                    ship.Estimated_Delivery_Date__c = rr.estimatedDeliveryDateTime != null ? rr.estimatedDeliveryDateTime.date() : null;
                    ship.Physical_Pickup_Completed_Time1__c = pickupDateTime;
                    shipmentsToUpdate.add(ship);
                }

            } catch (Exception e) {
                // Log to custom error object for debugging
                Apex_Error_Log__c log = new Apex_Error_Log__c(
                    Class_Name__c = 'SLACalculatorBatch.execute',
                    Error__c = e.getMessage() + ' --- ' + e.getStackTraceString()
                );
                insert log;
            }
        }

        // Bulk insert cal records (if any)
        if (!npCalToInsert.isEmpty()) insert npCalToInsert;
        if (!dcCalToInsert.isEmpty()) insert dcCalToInsert;

        // Bulk update TSMs and shipments
        if (!tsmToUpdate.isEmpty()) update tsmToUpdate;
        if (!shipmentsToUpdate.isEmpty()) update shipmentsToUpdate;
    }

    global void finish(Database.BatchableContext bc) {
        // optional post-processing: notifications, logs, etc.
    }

    // ---------- Helper methods to load static data ----------
    private Map<String, Distance_Calculator__c> loadDistanceMap() {
        Map<String, Distance_Calculator__c> result = new Map<String, Distance_Calculator__c>();
        for (Distance_Calculator__c dc : [SELECT Id, Destination_Pincode__c, Origin_Pincode__c, City__c, Distance_in_km__c,
                                          Distance_Range__c, Time_from_Pickup_to_Hub__c, Scheduled_Delivery_Route_Start_Time__c,
                                          Same_City_Hub_Delivery_Route_Start_Time__c, ROUTE_NUMBER__c, Time_from_Hub_to_delivery_point__c, State__c
                                          FROM Distance_Calculator__c]) {
            if (dc.Destination_Pincode__c != null) {
                result.put(dc.Destination_Pincode__c, dc);
            }
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
}