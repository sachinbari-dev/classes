global class SLACalculatorFuture1 {
    private static Boolean isTriggerExecuted = false;
    private static Boolean isFirstTimeRoad  = true;
    private static Boolean isFirstTimeFlight  = true;
    private static Map<Id, TAT_SLA_Mapping__c> shipIdVsTATSLAMapping = new Map<Id, TAT_SLA_Mapping__c>(); 
    private static List<Network_Plan_For_Calculation__c> npCalListToInsert = new List<Network_Plan_For_Calculation__c>();
    private static List<Distance_Calculator_For_Calculation__c> dcCalListToInsert = new List<Distance_Calculator_For_Calculation__c>();
    private static Map<Id, String> ShipIdVsFinalTime = new Map<Id, String>(); 
    private static Map<Id, String> ShipIdVsSLADay = new Map<Id, String>();
    private static Map<Id, Datetime> ShipIdVsEstDelDate = new Map<Id, Datetime>();
    private static Map<Id, Integer> ShipIdVsTatInDays = new Map<Id, Integer>();
    private static Map<Id, String> ShipIdVsHolidayDay = new Map<Id, String>();
    private static Map<Id, String> ShipIdVsPickupHoliday = new Map<Id, String>();
    
    // Entry: instantiate calls future processor
    public SLACalculatorFuture1(List<String> recordIds) {
        calculateSla(recordIds);
    }
    
    @future
    public static void calculateSla(List<String> recordIds) {
        if (recordIds == null || recordIds.isEmpty()) return;
        List<Shipment__c> shipList = [SELECT Id, Name,
                                      Origin_Hub__r.Name, Destination_Hub__r.Name,
                                      Shipping_Note_Number__c, Origin_Address_City__c,
                                      Pickup__r.Physical_Pickup_Completed_Time__c, Pickup__r.Id, Pickup__r.Pickup_Status__c,
                                      Estimated_Delivery_Date__c, SLA_Days_and_Hours__c,
                                      Physical_Pickup_Completed_Time1__c, Pickup__c,
                                      Origin_Address_Name__r.Active_Pincode__c, Origin_Address_Name__r.Active_Pincode__r.Name,
                                      Destination_Address_City__c, Destination_Address_Name__r.Active_Pincode__c, Destination_Address_Name__r.Active_Pincode__r.Name, 
                                      Destination_Address_Pincode__c, Origin_Address_Pincode__c,
                                      Destination_Address_Name__r.Active_Pincode__r.City__c, Tracking_Status__c,
                                      Destination_Address_Name__r.Active_Pincode__r.Sunday__c, Destination_Address_Name__r.Active_Pincode__r.Monday__c, 
                                      Destination_Address_Name__r.Active_Pincode__r.Tuesday__c, Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                                      Origin_Address_Name__r.STATE__c, Destination_Address_Name__r.STATE__c,
                                      holiday_sunday_charges1__c, Origin_Address_State__c,
                                      Destination_Address_Name__r.Active_Pincode__r.Thursday__c, Destination_Address_Name__r.Active_Pincode__r.Friday__c,
                                      Destination_Address_Name__r.Active_Pincode__r.Saturday__c, Destination_Hub__r.Branch__c, Origin_Hub__r.Branch__c, Destination_Address_State__c
                                      FROM Shipment__c WHERE Id IN :recordIds];
        try {
            isTriggerExecuted = true;

            Integer TATSLAHour = 0;
            Integer TATSLAMinute = 0;
            Integer TATSLASeconds = 0;
            Integer ARHour = 0;
            Integer ARMinute = 0;
            Integer ARSeconds = 0;

            Set<Id> pickupIdSet = new Set<Id>();
            Map<Id, Shipment__c> shipMap = new Map<Id, Shipment__c>();
            
            for (Shipment__c shipObj : shipList) {
                pickupIdSet.add(shipObj.Pickup__c);
                // create TAT_SLA_Mapping__c placeholder and keep reference keyed by Shipment Id
                TAT_SLA_Mapping__c tsm = new TAT_SLA_Mapping__c(
                    Origin_Pincode__c = shipObj.Origin_Address_Name__r.Active_Pincode__c,
                    Destination_Pincode__c = shipObj.Destination_Address_Name__r.Active_Pincode__c
                );
                shipIdVsTATSLAMapping.put(shipObj.Id, tsm);
                shipMap.put(shipObj.Id, shipObj);
            }
            
            if (!shipIdVsTATSLAMapping.values().isEmpty()) {
                insert shipIdVsTATSLAMapping.values();
            }
            
            Map<Id, Pickup__c> pickupMap = new Map<Id, Pickup__c>([
                SELECT Id, Name, Origin_Address_Pincode__c, Physical_Pickup_Completed_Time__c
                FROM Pickup__c WHERE Id IN :pickupIdSet
            ]);
            
            List<Distance_Calculator__c> distanceCalulatorList = Test.isRunningTest() ? new List<Distance_Calculator__c>() :
                [SELECT Id, Name, State__c, Origin_Pincode__c, Destination_Pincode__c, City__c, 
                 Distance_in_km__c, Distance_Range__c, Time_from_Pickup_to_Hub__c, 
                 Scheduled_Delivery_Route_Start_Time__c, Same_City_Hub_Delivery_Route_Start_Time__c, 
                 ROUTE_NUMBER__c, Time_from_Hub_to_delivery_point__c
                 FROM Distance_Calculator__c];
            
            Map<String, Distance_Calculator__c> distanceMap = new Map<String, Distance_Calculator__c>();
            for (Distance_Calculator__c dcObj : distanceCalulatorList) {
                if (dcObj.Destination_Pincode__c != null) distanceMap.put(dcObj.Destination_Pincode__c, dcObj);
            }
            
            List<Network_Plan__c> networkPlanList = Test.isRunningTest() ? new List<Network_Plan__c>() : [
                SELECT Id, Name, From_Hub__c, To_Destination_Hub__c, Destination_City__c,
                Approx_Time_Taken_in_hrs__c, OD_Concat__c, Next_Route__c, Transport_Type__c,
                Origin_Port__c, Destination_Port__c, Flight_No__c, Flight_Departure_Time__c,
                Flight_Arrival_Time__c, Scheduled_Max_Time_of_Vehicle_Dispatch__c,
                Approx_Time_Taken_in_hrs1__c, Route_No__c, Scheduled_Arrival_at_Hub__c,
                Scheduled_Arrival_at_Airport__c, Schedule_Airport_handover_time__c, 
                Schedule_Load_retrival_time__c, Schedule_departure_from_airport_to_hub__c, 
                Schedule_Arrival_from_airport_to_hub__c, Hub_Processing_hr__c,
                Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c, Scheduled_max_time_of_vehicle_dispatch_3__c
                FROM Network_Plan__c
            ];
            
            Map<String, Network_Plan__c> networkPlanMap = new Map<String, Network_Plan__c>();
            for (Network_Plan__c npObj : networkPlanList) {
                String key = (npObj.From_Hub__c == null ? '' : npObj.From_Hub__c) + '_' + (npObj.To_Destination_Hub__c == null ? '' : npObj.To_Destination_Hub__c);
                networkPlanMap.put(key, npObj);
            }
            
            List<Holiday_Data__c> holidayListData = Test.isRunningTest() ? new List<Holiday_Data__c>() : [
                SELECT Id, Name, State__c, Date__c FROM Holiday_Data__c
            ];
            
            // Build holiday lookup maps
            Map<String, Date> holidayMap = new Map<String, Date>();
            Map<Date, Holiday_Data__c> holidayDateMap = new Map<Date, Holiday_Data__c>();
            Map<String, Holiday_Data__c> holidayDateStateMap = new Map<String, Holiday_Data__c>();
            
            for (Holiday_Data__c hdObj : holidayListData) {
                if (hdObj.State__c != null) holidayMap.put(hdObj.State__c, hdObj.Date__c);
                if (hdObj.Date__c != null) holidayDateMap.put(hdObj.Date__c, hdObj);
                if (hdObj.State__c != null && hdObj.Date__c != null) {
                    holidayDateStateMap.put(hdObj.Date__c.format() + '-' + hdObj.State__c, hdObj);
                }
            }
            
            // Process each shipment
            for (Shipment__c shipObj : shipList) {
                Pickup__c pickupObj = pickupMap.get(shipObj.Pickup__c);
                if (pickupObj == null || pickupObj.Physical_Pickup_Completed_Time__c == null) {
                    // reset state for next shipment
                    resetTempTimeVars();
                    continue;
                }
                
                // Init times from pickup
                DateTime pickupDT = pickupObj.Physical_Pickup_Completed_Time__c;
                TATSLAHour = pickupDT.hour();
                TATSLAMinute = pickupDT.minute();
                TATSLASeconds = pickupDT.second();
                ARHour = 0; ARMinute = 0; ARSeconds = 0;
                
                // Calculate pickup holiday(s)
                Date pickupDate = Date.newInstance(pickupDT.year(), pickupDT.month(), pickupDT.day());
                String state = shipObj.Origin_Address_State__c;
                String pickupHolidaySummary = '';
                if (state != null) {
                    Date checkDate = pickupDate;
                    Integer holidayCount = 0;
                    List<String> holidayNames = new List<String>();
                    while (true) {
                        String mapKey = checkDate.format() + '-' + state;
                        Holiday_Data__c hd = holidayDateStateMap.get(mapKey);
                        if (hd != null) {
                            holidayNames.add(hd.Name + ' on ' + hd.Date__c.format() + ' in ' + hd.State__c);
                            holidayCount++;
                            checkDate = checkDate.addDays(1);
                        } else {
                            break;
                        }
                    }
                    if (!holidayNames.isEmpty()) {
                        pickupHolidaySummary = String.join(holidayNames, ', ');
                        Integer extraHours = 24 * holidayCount;
                        TATSLAHour += extraHours;
                        ARHour += extraHours;
                    }
                }
                ShipIdVsPickupHoliday.put(shipObj.Id, pickupHolidaySummary);
                
                // distance map lookup by pickup origin pincode
                String pickupOriginPincode = pickupObj.Origin_Address_Pincode__c;
                Distance_Calculator__c dcObj = (pickupOriginPincode != null) ? distanceMap.get(pickupOriginPincode) : null;
                
                if (dcObj != null) {
                    Map<String, Object> resultMap = adjustTATSLAHourAndMinute(dcObj, shipObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds);
                    ARHour = (Integer) resultMap.get('ARHour');
                    ARMinute = (Integer) resultMap.get('ARMinute');
                    ARSeconds = (Integer) resultMap.get('ARSeconds');
                    TATSLAHour = (Integer) resultMap.get('TATSLAHour');
                    TATSLAMinute = (Integer) resultMap.get('TATSLAMinute');
                    Boolean isSameCityLogicExecuted = (Boolean) resultMap.get('isSameCityLogicExecuted');

                    // prepare hub name keys trimmed
                    String testOriginAddNameKey = extractHubKey(shipObj.Origin_Hub__r != null ? shipObj.Origin_Hub__r.Name : null);
                    String testDestAddNameKey = extractHubKey(shipObj.Destination_Hub__r != null ? shipObj.Destination_Hub__r.Name : null);
                    if ('HYD'.equalsIgnoreCase(testOriginAddNameKey)) testOriginAddNameKey = 'HYDERABAD';
                    if ('HYD'.equalsIgnoreCase(testDestAddNameKey)) testDestAddNameKey = 'HYDERABAD';
                    
                    if (!isSameCityLogicExecuted) {
                        String npKey = testOriginAddNameKey + '_' + testDestAddNameKey;
                        String destinationKey = shipObj.Destination_Address_Pincode__c;
                        String hdStateKey = shipObj.Destination_Address_State__c;
                        
                        checkNextRoute(npKey, shipObj, networkPlanMap, destinationKey, distanceMap, TATSLAHour, TATSLAMinute, TATSLASeconds, ARHour, ARMinute, ARSeconds, new Set<String>(), hdStateKey, holidayMap, holidayDateMap, holidayDateStateMap);
                    }
                }
                
                resetTempTimeVars();
            } // end for shipments
            
            // insert collected records
            if (!npCalListToInsert.isEmpty()) insert npCalListToInsert;
            if (!dcCalListToInsert.isEmpty()) insert dcCalListToInsert;
            
            // Prepare updates
            List<TAT_SLA_Mapping__c> tsmListToUpdate = new List<TAT_SLA_Mapping__c>();
            List<Shipment__c> ShipmentLst2Update = new List<Shipment__c>();
            
            for (Id shipId : shipIdVsTATSLAMapping.keySet()) {
                TAT_SLA_Mapping__c tmpTSM = new TAT_SLA_Mapping__c();
                tmpTSM.Id = shipIdVsTATSLAMapping.get(shipId).Id;
                tmpTSM.SLA_Hours__c = ShipIdVsFinalTime.get(shipId);
                tmpTSM.SLA_Day__c = ShipIdVsSLADay.get(shipId);
                tmpTSM.Estimated_Delivery_Date__c = ShipIdVsEstDelDate.get(shipId);
                tmpTSM.TAT_in_Days__c = ShipIdVsTatInDays.get(shipId);
                tmpTSM.Holiday__c = ShipIdVsHolidayDay.get(shipId);
                tmpTSM.Holiday_at_Pickup_Point__c = ShipIdVsPickupHoliday.get(shipId);
                tmpTSM.Shipment__c = shipId;
                tsmListToUpdate.add(tmpTSM);
                
                Shipment__c ship = shipMap.get(shipId);
                if (ship != null) {
                    String combinedSLA = (tmpTSM.TAT_in_Days__c == null ? '' : tmpTSM.TAT_in_Days__c + ' Days OR ') + (tmpTSM.SLA_Hours__c == null ? '' : tmpTSM.SLA_Hours__c);
                    if (ShipIdVsEstDelDate.get(shipId) != null) {
                        DateTime Estimated = ShipIdVsEstDelDate.get(shipId);
                        ship.Estimated_Delivery_Date__c = Estimated.date();
                        ship.Estimated_Delivery_Datetime__c = Estimated;
                    }
                    ship.SLA_Days_and_Hours__c = combinedSLA;
                    ship.Physical_Pickup_Completed_Time1__c = ship.Pickup__r != null ? ship.Pickup__r.Physical_Pickup_Completed_Time__c : null;
                    ShipmentLst2Update.add(ship);
                }
            }
            
            if (!tsmListToUpdate.isEmpty()) {
                try {
                    update tsmListToUpdate;
                    if (!ShipmentLst2Update.isEmpty()) update ShipmentLst2Update;
                } catch (Exception e) {
                    Apex_Error_Log__c AEL = new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorFuture', Error__c = String.valueOf(e.getLineNumber()) + '-' + e.getMessage());
                    insert AEL;
                }
            }
            
        } catch (Exception ex) {
            Apex_Error_Log__c AEL = new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorFuture', Error__c = String.valueOf(ex.getLineNumber()) + '-' + ex.getMessage());
            insert AEL;
        }
    } // end calculateSla
    
    // Helper: normalize/reset temps
    private static void resetTempTimeVars() {
        Integer TATSLAHour = 0; // won't compile as direct reference; kept for conceptual grouping (these are method-local in original). No-op here.
        isFirstTimeRoad = true;
        isFirstTimeFlight = true;
    }
    
    // --- Core helper functions (logic preserved) ---
    public static Map<String, Object> adjustTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj,
        Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        
        Boolean isSameCityLogicExecuted = false;
        Integer SameCityDeliveryHour = 0;
        Integer SameCityDeliveryMinute = 0;
        
        if (dcObj == null || shipObj == null) {
            Map<String, Object> r = new Map<String, Object>{
                'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
                'isSameCityLogicExecuted' => isSameCityLogicExecuted,
                'TATSLAHour' => TATSLAHour, 'TATSLAMinute' => TATSLAMinute
            };
            return r;
        }
        
        // Same city flow
        if (dcObj.Origin_Pincode__c == dcObj.Destination_Pincode__c &&
            shipObj.Destination_Address_City__c == dcObj.City__c &&
            shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c) {
            
            isSameCityLogicExecuted = true;
            Time sameStart = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c;
            if (sameStart != null) {
                SameCityDeliveryHour = sameStart.hour();
                SameCityDeliveryMinute = sameStart.minute();
            }
            
            if (SameCityDeliveryHour < TATSLAHour) {
                SameCityDeliveryHour = (SameCityDeliveryHour + 24) - TATSLAHour;
            } else {
                SameCityDeliveryHour = SameCityDeliveryHour - TATSLAHour;
            }
            
            Integer hours = 0, minutes = 0;
            if (dcObj.Time_from_Pickup_to_Hub__c != null) {
                Decimal approx = dcObj.Time_from_Pickup_to_Hub__c;
                hours = approx.intValue();
                minutes = ((approx - hours) * 60).intValue();
            }
            
            ARHour += (SameCityDeliveryHour + hours);
            ARMinute += (SameCityDeliveryMinute + minutes);
            
            // normalize minutes -> hours
            Integer addHours = ARMinute / 60;
            ARHour += addHours;
            ARMinute = Math.mod(ARMinute, 60);
            
            DateTime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
            DateTime futureDateTime = currentDateTime.addHours(ARHour).addMinutes(ARMinute);
            // if delivery happened same day as pickup, shift to next day (keeps previous behavior)
            if (currentDateTime.date() == futureDateTime.date()) {
                futureDateTime = futureDateTime.addDays(1);
                ARHour += 24;
            }
            
            String finalTime = ARHour + 'H ' + ARMinute + 'M ' + ARSeconds + 'S';
            Datetime istDateTime = futureDateTime.addSeconds(19800);
            String slaDay = istDateTime.format('EEEE', 'en_US');
            Date estDelDate = Date.newInstance(futureDateTime.year(), futureDateTime.month(), futureDateTime.day());
            Integer numberOfDays = Math.abs(estDelDate.daysBetween(currentDateTime.date()));
            
            ShipIdVsFinalTime.put(shipObj.Id, finalTime);
            ShipIdVsSLADay.put(shipObj.Id, slaDay);
            ShipIdVsEstDelDate.put(shipObj.Id, futureDateTime);
            ShipIdVsTatInDays.put(shipObj.Id, numberOfDays);
        }
        // If origin pincode equals destination pincode in DC (intermediate leg)
        else if (shipObj.Origin_Address_Pincode__c == dcObj.Destination_Pincode__c) {
            Integer hours = 0, minutes = 0;
            if (dcObj.Time_from_Pickup_to_Hub__c != null) {
                Decimal approx = dcObj.Time_from_Pickup_to_Hub__c;
                hours = approx.intValue();
                minutes = ((approx - hours) * 60).intValue();
            }
            ARHour += hours;
            ARMinute += minutes;
            TATSLAHour += hours;
            TATSLAHour = Math.mod(TATSLAHour, 24);
            TATSLAMinute += minutes;
        }
        // General case
        else {
            Integer scheduledDispatchHour = dcObj.Scheduled_Delivery_Route_Start_Time__c != null ? dcObj.Scheduled_Delivery_Route_Start_Time__c.hour() : 0;
            Integer scheduledDispatchMinute = dcObj.Scheduled_Delivery_Route_Start_Time__c != null ? dcObj.Scheduled_Delivery_Route_Start_Time__c.minute() : 0;
            
            if (scheduledDispatchHour <= TATSLAHour) {
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            
            Integer hours = 0, minutes = 0;
            if (dcObj.Time_from_Pickup_to_Hub__c != null) {
                Decimal approx = dcObj.Time_from_Pickup_to_Hub__c;
                hours = approx.intValue();
                minutes = ((approx - hours) * 60).intValue();
            }
            
            ARHour += (scheduledDispatchHour + hours);
            ARMinute += (scheduledDispatchMinute + minutes);
            
            TATSLAHour += (scheduledDispatchHour + hours + 1);
            TATSLAMinute += (scheduledDispatchMinute + minutes);
            TATSLAHour = Math.mod(TATSLAHour, 24);
        }
        
        // create DC calculation record
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
        dcCal.TAT_SLA_Mapping__c = shipIdVsTATSLAMapping.get(shipObj.Id) != null ? shipIdVsTATSLAMapping.get(shipObj.Id).Id : null;
        dcCal.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
        dcCalListToInsert.add(dcCal);
        
        Map<String, Object> result = new Map<String, Object>{
            'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
            'isSameCityLogicExecuted' => isSameCityLogicExecuted,
            'TATSLAHour' => TATSLAHour, 'TATSLAMinute' => TATSLAMinute
        };
        return result;
    } // end adjustTATSLAHourAndMinute
    
    public static Map<String, Object> adjustFinalTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj,
        Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        
        // This method mirrors adjustTATSLAHourAndMinute but uses Time_from_Hub_to_delivery_point__c where appropriate
        Boolean isSameCityLogicExecuted = false;
        Integer SameCityDeliveryHour = 0;
        Integer SameCityDeliveryMinute = 0;
        
        if (dcObj == null || shipObj == null) {
            Map<String, Object> r = new Map<String, Object>{
                'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
                'isSameCityLogicExecuted' => isSameCityLogicExecuted,
                'TATSLAHour' => TATSLAHour, 'TATSLAMinute' => TATSLAMinute
            };
            return r;
        }
        
        if (dcObj.Origin_Pincode__c == dcObj.Destination_Pincode__c &&
            shipObj.Destination_Address_City__c == dcObj.City__c &&
            shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c) {
            
            isSameCityLogicExecuted = true;
            Time sameStart = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c;
            if (sameStart != null) {
                SameCityDeliveryHour = sameStart.hour();
                SameCityDeliveryMinute = sameStart.minute();
            }
            
            if (SameCityDeliveryHour <= TATSLAHour) {
                SameCityDeliveryHour = (SameCityDeliveryHour + 24) - TATSLAHour;
            } else {
                SameCityDeliveryHour -= TATSLAHour;
            }
            
            Integer hours = 0, minutes = 0;
            if (dcObj.Time_from_Hub_to_delivery_point__c != null) {
                Decimal approx = dcObj.Time_from_Hub_to_delivery_point__c;
                hours = approx.intValue();
                minutes = ((approx - hours) * 60).intValue();
            }
            
            ARHour += (SameCityDeliveryHour + hours);
            ARMinute += (SameCityDeliveryMinute + minutes);
            
            Integer addHours = ARMinute / 60;
            ARHour += addHours;
            ARMinute = Math.mod(ARMinute, 60);
            
            DateTime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
            DateTime futureDateTime = currentDateTime.addHours(ARHour).addMinutes(ARMinute);
            if (currentDateTime.date() == futureDateTime.date()) {
                futureDateTime = futureDateTime.addDays(1);
                ARHour += 24;
            }
            
            String finalTime = ARHour + 'H ' + ARMinute + 'M ' + ARSeconds + 'S';
            Datetime istDateTime = futureDateTime.addSeconds(19800);
            String slaDay = istDateTime.format('EEEE', 'en_US');
            Date estDelDate = Date.newInstance(futureDateTime.year(), futureDateTime.month(), futureDateTime.day());
            Integer numberOfDays = Math.abs(estDelDate.daysBetween(currentDateTime.date()));
            
            ShipIdVsFinalTime.put(shipObj.Id, finalTime);
            ShipIdVsSLADay.put(shipObj.Id, slaDay);
            ShipIdVsEstDelDate.put(shipObj.Id, futureDateTime);
            ShipIdVsTatInDays.put(shipObj.Id, numberOfDays);
        }
        // other branches: origin pincode equal etc.
        else if (shipObj.Origin_Address_Pincode__c == dcObj.Destination_Pincode__c) {
            Integer hours = 0, minutes = 0;
            if (dcObj.Time_from_Hub_to_delivery_point__c != null) {
                Decimal approx = dcObj.Time_from_Hub_to_delivery_point__c;
                hours = approx.intValue();
                minutes = ((approx - hours) * 60).intValue();
            }
            Integer scheduledDispatchHour = dcObj.Scheduled_Delivery_Route_Start_Time__c != null ? dcObj.Scheduled_Delivery_Route_Start_Time__c.hour() : 0;
            Integer scheduledDispatchMinute = dcObj.Scheduled_Delivery_Route_Start_Time__c != null ? dcObj.Scheduled_Delivery_Route_Start_Time__c.minute() : 0;
            
            if (scheduledDispatchHour <= TATSLAHour) {
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour -= TATSLAHour;
            }
            
            ARHour += (scheduledDispatchHour + hours);
            ARMinute += (scheduledDispatchMinute + minutes);
            TATSLAHour += scheduledDispatchHour + hours + 1;
            TATSLAHour = Math.mod(TATSLAHour, 24);
            TATSLAMinute += (scheduledDispatchMinute + minutes);
            
        } else {
            Integer scheduledDispatchHour = dcObj.Scheduled_Delivery_Route_Start_Time__c != null ? dcObj.Scheduled_Delivery_Route_Start_Time__c.hour() : 0;
            Integer scheduledDispatchMinute = dcObj.Scheduled_Delivery_Route_Start_Time__c != null ? dcObj.Scheduled_Delivery_Route_Start_Time__c.minute() : 0;
            Integer hours = 0, minutes = 0;
            if (dcObj.Time_from_Hub_to_delivery_point__c != null) {
                Decimal approx = dcObj.Time_from_Hub_to_delivery_point__c;
                hours = approx.intValue();
                minutes = ((approx - hours) * 60).intValue();
            }
            
            if (scheduledDispatchHour <= TATSLAHour) {
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour -= TATSLAHour;
            }
            
            ARHour += (scheduledDispatchHour + hours);
            ARMinute += (scheduledDispatchMinute + minutes);
            TATSLAHour += scheduledDispatchHour + hours + 1;
            TATSLAHour = Math.mod(TATSLAHour, 24);
            TATSLAMinute += (scheduledDispatchMinute + minutes);
        }
        
        // add DC calc record
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
        dcCal.TAT_SLA_Mapping__c = shipIdVsTATSLAMapping.get(shipObj.Id) != null ? shipIdVsTATSLAMapping.get(shipObj.Id).Id : null;
        dcCal.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
        dcCalListToInsert.add(dcCal);
        
        Map<String, Object> result = new Map<String, Object>{
            'ARHour' => ARHour, 'ARMinute' => ARMinute, 'ARSeconds' => ARSeconds,
            'isSameCityLogicExecuted' => isSameCityLogicExecuted,
            'TATSLAHour' => TATSLAHour, 'TATSLAMinute' => TATSLAMinute
        };
        return result;
    } // end adjustFinalTATSLAHourAndMinute
    
    
    public static void checkNextRoute(String key, Shipment__c shipObj, Map<String, Network_Plan__c> networkPlanMap,
            String destinationKey, Map<String, Distance_Calculator__c> distanceMap,
            Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds,
            Integer ARHour, Integer ARMinute, Integer ARSeconds,
            Set<String> visitedRoutes, String hdStateKey,
            Map<String, Date> holidayMap, Map<Date, Holiday_Data__c> holidayDateMap, Map<String, Holiday_Data__c> holidayDateStateMap) {
        
        if (key == null || visitedRoutes.contains(key)) return;
        visitedRoutes.add(key);
        
        Network_Plan__c npObj = networkPlanMap.get(key);
        Distance_Calculator__c dcObj = (destinationKey != null) ? distanceMap.get(destinationKey) : null;
        
        if (npObj == null) return;
        
        Map<String, Object> timeMap;
        if ('Road' == npObj.Transport_Type__c) {
            if ('BENGALURU_HOSUR' == npObj.OD_Concat__c) {
                timeMap = adjustMultipleARRoad(npObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, isFirstTimeRoad);
            } else {
                timeMap = adjustARRoad(npObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, isFirstTimeRoad);
            }
            isFirstTimeRoad = false;
        } else if ('Air' == npObj.Transport_Type__c) {
            timeMap = adjustARAir(npObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, isFirstTimeFlight);
            isFirstTimeFlight = false;
        } else {
            // unknown transport type - skip
            return;
        }
        
        ARHour = (Integer) timeMap.get('ARHour');
        ARMinute = (Integer) timeMap.get('ARMinute');
        ARSeconds = (Integer) timeMap.get('ARSeconds');
        TATSLAHour = (Integer) timeMap.get('TATSLAHour');
        TATSLAMinute = (Integer) timeMap.get('TATSLAMinute');
        
        // store network plan calc
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
        npCal.TAT_SLA_Mapping__c = shipIdVsTATSLAMapping.get(shipObj.Id) != null ? shipIdVsTATSLAMapping.get(shipObj.Id).Id : null;
        npCal.Approx_Time_Taken_in_hrs1__c = npObj.Approx_Time_Taken_in_hrs1__c;
        npCal.Route_No__c = npObj.Route_No__c;
        npCal.Hub_Processing_hr__c = npObj.Hub_Processing_hr__c;
        npCal.Scheduled_Arrival_at_Hub__c = npObj.Scheduled_Arrival_at_Hub__c;
        npCal.Schedule_departure_from_airport_to_hub__c = npObj.Schedule_departure_from_airport_to_hub__c;
        npCal.Schedule_Arrival_from_airport_to_hub__c = npObj.Schedule_Arrival_from_airport_to_hub__c;
        npCal.Schedule_Load_retrival_time__c = npObj.Schedule_Load_retrival_time__c;
        npCal.Schedule_Arrival_from_airport_to_hub__c = npObj.Schedule_Arrival_from_airport_to_hub__c;
        npCal.Scheduled_Max_Time_of_Vehicle_Dispatch_2__c = npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c;
        npCal.Scheduled_Max_Time_of_Vehicle_Dispatch_3__c = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch_3__c;
        npCalListToInsert.add(npCal);
        
        // If nextOrigin equals current To_Destination_Hub, compute final delivery for destinationKey
        String nextOrigin = splitRoute(npObj.Next_Route__c);
        if (nextOrigin == npObj.To_Destination_Hub__c) {
            if (destinationKey != null && dcObj != null && destinationKey == dcObj.Destination_Pincode__c) {
                // final destination logic (preserve original flow)
                Integer additionalARHours = ARMinute / 60;
                Integer remainingARMinutes = Math.mod(ARMinute, 60);
                ARHour += additionalARHours;
                ARMinute = remainingARMinutes;
                
                Integer ARdays = ARHour / 24;
                Integer remainingARHours = Math.mod(ARHour, 24);
                
                DateTime currentARDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
                DateTime targetARDateTime = currentARDateTime.addDays(ARdays).addHours(remainingARHours).addMinutes(ARMinute).addSeconds(ARSeconds);
                
                Long timeDifferenceMillis = targetARDateTime.getTime() - currentARDateTime.getTime();
                Integer hoursToAdd = (Integer)(timeDifferenceMillis / (1000 * 60 * 60));
                Integer minutesToAdd = (Integer)((timeDifferenceMillis - (hoursToAdd * 1000 * 60 * 60)) / (1000 * 60));
                Integer secondsToAdd = (Integer)((timeDifferenceMillis - (hoursToAdd * 1000 * 60 * 60) - (minutesToAdd * 1000 * 60)) / 1000);
                
                Map<String, Object> destinationTimeMap = adjustFinalTATSLAHourAndMinute(dcObj, shipObj, hoursToAdd, minutesToAdd, secondsToAdd, TATSLAHour, TATSLAMinute, TATSLASeconds);
                Integer FinalTATHour = (Integer) destinationTimeMap.get('ARHour');
                Integer FinalTATMinute = (Integer) destinationTimeMap.get('ARMinute');
                Integer FinalTATSeconds = (Integer) destinationTimeMap.get('ARSeconds');
                
                Integer additionalHours = FinalTATMinute / 60;
                Integer remainingMinutes = Math.mod(FinalTATMinute, 60);
                FinalTATHour += additionalHours;
                FinalTATMinute = remainingMinutes;
                
                Integer days = FinalTATHour / 24;
                Integer remainingHours = Math.mod(FinalTATHour, 24);
                
                DateTime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
                Date currentDate = currentDateTime.date();
                DateTime targetDateTime = currentDateTime.addDays(days).addHours(remainingHours).addMinutes(FinalTATMinute).addSeconds(FinalTATSeconds);
                
                Datetime istDateTime = targetDateTime.addSeconds(19800);
                String slaDay = istDateTime.format('EEEE', 'en_US');
                
                // serviceable day/holiday loop - skip up to 7 days until serviceable and not holiday
                Map<String, Boolean> serviceableDays = new Map<String, Boolean>{
                    'Monday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Monday__c,
                    'Tuesday'   => shipObj.Destination_Address_Name__r.Active_Pincode__r.Tuesday__c,
                    'Wednesday' => shipObj.Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                    'Thursday'  => shipObj.Destination_Address_Name__r.Active_Pincode__r.Thursday__c,
                    'Friday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Friday__c,
                    'Saturday'  => shipObj.Destination_Address_Name__r.Active_Pincode__r.Saturday__c,
                    'Sunday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Sunday__c
                };
                
                Integer maxDaysInWeek = 7;
                Integer dayInWeek = 0;
                String holidayOnEstDelDate = '';
                
                while (dayInWeek < maxDaysInWeek) {
                    Date estDelDateToCheck = Date.newInstance(targetDateTime.year(), targetDateTime.month(), targetDateTime.day());
                    String mapKey = estDelDateToCheck.format() + '-' + hdStateKey;
                    Holiday_Data__c holidayData = holidayDateStateMap.get(mapKey);
                    
                    Datetime istDateTimeTemp = targetDateTime.addSeconds(19800);
                    slaDay = istDateTimeTemp.format('EEEE', 'en_US');
                    Boolean isServiceable = serviceableDays.containsKey(slaDay) && serviceableDays.get(slaDay);
                    
                    if (!isServiceable || holidayData != null) {
                        if (holidayData != null) {
                            holidayOnEstDelDate += (holidayOnEstDelDate == '' ? '' : ', ') + holidayData.Name + ' on ' + holidayData.Date__c.format() + ' in ' + holidayData.State__c;
                        }
                        targetDateTime = targetDateTime.addDays(1);
                        FinalTATHour += 24;
                        dayInWeek++;
                        continue;
                    }
                    break;
                }
                
                Date EstDelDate = Date.newInstance(targetDateTime.year(), targetDateTime.month(), targetDateTime.day());
                String FinalTime = FinalTATHour + 'H ' + FinalTATMinute + 'M ' + FinalTATSeconds + 'S';
                Integer numberOfDays = Math.abs(EstDelDate.daysBetween(currentDate));
                
                ShipIdVsFinalTime.put(shipObj.Id, FinalTime);
                ShipIdVsSLADay.put(shipObj.Id, slaDay);
                ShipIdVsEstDelDate.put(shipObj.Id, targetDateTime);
                ShipIdVsTatInDays.put(shipObj.Id, numberOfDays);
                ShipIdVsHolidayDay.put(shipObj.Id, holidayOnEstDelDate);
            }
            return;
        } else {
            // build new key and traverse next route
            String testDestAddNameKey = extractHubKey(shipObj.Destination_Hub__r != null ? shipObj.Destination_Hub__r.Name : null);
            if ('HYD'.equalsIgnoreCase(testDestAddNameKey)) testDestAddNameKey = 'HYDERABAD';
            String newKey = nextOrigin + '_' + testDestAddNameKey;
            checkNextRoute(newKey, shipObj, networkPlanMap, destinationKey, distanceMap, TATSLAHour, TATSLAMinute, TATSLASeconds, ARHour, ARMinute, ARSeconds, visitedRoutes, hdStateKey, holidayMap, holidayDateMap, holidayDateStateMap);
        }
    } // end checkNextRoute
    
    // adjust ARRoad for simple single dispatch
    public static Map<String, Object> adjustARRoad(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
        Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeRoad) {
        
        Map<String, Object> timeMap = new Map<String, Object>();
        if (npObj == null) return timeMap;
        Time dispatch = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
        Integer scheduledDispatchHour = dispatch != null ? dispatch.hour() : 0;
        Integer scheduledDispatchMinute = dispatch != null ? dispatch.minute() : 0;
        
        if (isFirstTimeRoad) {
            if (scheduledDispatchHour < TATSLAHour) scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            else scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            
            Integer hours = 0, minutes = 0;
            if (npObj.Approx_Time_Taken_in_hrs1__c != null) {
                Decimal approx = npObj.Approx_Time_Taken_in_hrs1__c;
                hours = approx.intValue();
                minutes = ((approx - hours) * 60).intValue();
            }
            
            ARHour += (scheduledDispatchHour + hours);
            ARMinute += (scheduledDispatchMinute + minutes);
            Integer additionalARHours = ARMinute / 60;
            ARHour += additionalARHours;
            ARMinute = Math.mod(ARMinute, 60);
            
            Integer tmpTATSLAmorethan24 = (dispatch != null ? dispatch.hour() : 0) + hours;
            if (tmpTATSLAmorethan24 > 24) tmpTATSLAmorethan24 -= 24;
            TATSLAHour = tmpTATSLAmorethan24;
            TATSLAMinute = (dispatch != null ? dispatch.minute() : 0) + minutes;
            Integer additionalTATHours = TATSLAMinute / 60;
            TATSLAHour += additionalTATHours;
            TATSLAMinute = Math.mod(TATSLAMinute, 60);
            
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        } else {
            if (scheduledDispatchHour < TATSLAHour) scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            else scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            
            Integer hours = 0, minutes = 0;
            if (npObj.Approx_Time_Taken_in_hrs1__c != null) {
                Decimal approx = npObj.Approx_Time_Taken_in_hrs1__c;
                hours = approx.intValue();
                minutes = ((approx - hours) * 60).intValue();
            }
            
            ARHour += (scheduledDispatchHour + hours);
            ARMinute += (scheduledDispatchMinute + minutes);
            Integer additionalARHours = ARMinute / 60;
            ARHour += additionalARHours;
            ARMinute = Math.mod(ARMinute, 60);
            
            TATSLAHour = (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null ? npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour() : 0) + hours;
            TATSLAMinute = (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null ? npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute() : 0) + minutes;
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        }
    } // end adjustARRoad
    
    
    // adjustMultipleARRoad : picks best dispatch slot among up to 3 dispatch times
    public static Map<String, Object> adjustMultipleARRoad(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
        Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeRoad) {
        
        Map<String, Object> timeMap = new Map<String, Object>();
        if (npObj == null) return timeMap;
        
        Time dispatch1 = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
        Time dispatch2 = npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c;
        Time dispatch3 = npObj.Scheduled_max_time_of_vehicle_dispatch_3__c;
        
        Integer d1h = dispatch1 != null ? dispatch1.hour() : null;
        Integer d1m = dispatch1 != null ? dispatch1.minute() : null;
        Integer d2h = dispatch2 != null ? dispatch2.hour() : null;
        Integer d2m = dispatch2 != null ? dispatch2.minute() : null;
        Integer d3h = dispatch3 != null ? dispatch3.hour() : null;
        Integer d3m = dispatch3 != null ? dispatch3.minute() : null;
        
        // approximate time
        Integer hours = 0, minutes = 0;
        if (npObj.Approx_Time_Taken_in_hrs1__c != null) {
            Decimal approx = npObj.Approx_Time_Taken_in_hrs1__c;
            hours = approx.intValue();
            minutes = ((approx - hours) * 60).intValue();
        }
        
        // prepare candidate dispatch list (only when hour not null)
        List<Map<String, Integer>> dispatchList = new List<Map<String, Integer>>();
        if (d1h != null) dispatchList.add(new Map<String,Integer>{'hour' => d1h, 'minute' => d1m});
        if (d2h != null) dispatchList.add(new Map<String,Integer>{'hour' => d2h, 'minute' => d2m});
        if (d3h != null) dispatchList.add(new Map<String,Integer>{'hour' => d3h, 'minute' => d3m});
        
        Integer chosenDispatchHour = null;
        Integer chosenDispatchMinute = null;
        Integer bestDiff = 999999;
        Integer tatTotalMinutes = (TATSLAHour == null ? 0 : TATSLAHour) * 60 + (TATSLAMinute == null ? 0 : TATSLAMinute);
        
        for (Map<String, Integer> d : dispatchList) {
            Integer dh = d.get('hour');
            Integer dm = d.get('minute');
            Integer dispatchTotalMin = dh * 60 + (dm == null ? 0 : dm);
            if (dispatchTotalMin >= tatTotalMinutes) {
                Integer diff = dispatchTotalMin - tatTotalMinutes;
                if (diff < bestDiff) {
                    bestDiff = diff;
                    chosenDispatchHour = dh;
                    chosenDispatchMinute = dm;
                }
            }
        }
        
        // If no dispatch after SLA same day, pick earliest next day (smallest minutes)
        if (chosenDispatchHour == null && !dispatchList.isEmpty()) {
            Integer minDispatchMin = 999999;
            Integer minDh = dispatchList[0].get('hour');
            Integer minDm = dispatchList[0].get('minute');
            for (Map<String, Integer> d : dispatchList) {
                Integer dh = d.get('hour');
                Integer dm = d.get('minute');
                Integer dispatchTotalMin = dh * 60 + (dm == null ? 0 : dm);
                if (dispatchTotalMin < minDispatchMin) {
                    minDispatchMin = dispatchTotalMin;
                    minDh = dh; minDm = dm;
                }
            }
            chosenDispatchHour = minDh + 24; // next day
            chosenDispatchMinute = minDm;
        }
        
        Integer adjustedDispatchHour = chosenDispatchHour;
        if (chosenDispatchHour == null) chosenDispatchHour = 0;
        if (chosenDispatchMinute == null) chosenDispatchMinute = 0;
        
        if (isFirstTimeRoad) {
            if (chosenDispatchHour < TATSLAHour) chosenDispatchHour = (chosenDispatchHour + 24) - TATSLAHour;
            else chosenDispatchHour -= TATSLAHour;
            
            Integer tmpTATSLAmorethan24 = adjustedDispatchHour + hours;
            ARHour += (chosenDispatchHour + hours);
            ARMinute += (chosenDispatchMinute + minutes);
            Integer additionalARHours = ARMinute / 60;
            ARHour += additionalARHours;
            ARMinute = Math.mod(ARMinute, 60);
            
            if (tmpTATSLAmorethan24 > 24) tmpTATSLAmorethan24 -= 24;
            TATSLAHour = tmpTATSLAmorethan24 + 1;
            TATSLAMinute = chosenDispatchMinute;
            Integer additionalTATHours = TATSLAMinute / 60;
            TATSLAHour += additionalTATHours;
            TATSLAMinute = Math.mod(TATSLAMinute, 60);
            
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        } else {
            if (chosenDispatchHour < TATSLAHour) chosenDispatchHour = (chosenDispatchHour + 24) - TATSLAHour;
            else chosenDispatchHour -= TATSLAHour;
            
            ARHour += (chosenDispatchHour + hours);
            ARMinute += (chosenDispatchMinute + minutes);
            Integer additionalARHours = ARMinute / 60;
            ARHour += additionalARHours;
            ARMinute = Math.mod(ARMinute, 60);
            
            TATSLAHour = adjustedDispatchHour + hours;
            TATSLAMinute = chosenDispatchMinute + minutes;
            Integer additionalTATHours = TATSLAMinute / 60;
            TATSLAHour += additionalTATHours;
            TATSLAMinute = Math.mod(TATSLAMinute, 60);
            
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        }
    } // end adjustMultipleARRoad
    
    
    // adjust AR for air route
    public static Map<String, Object> adjustARAir(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
        Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeFlight) {
        
        Map<String, Object> timeMap = new Map<String, Object>();
        if (npObj == null) return timeMap;
        
        Integer scheduledDispatchHour = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null ? npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour() : 0;
        Integer scheduledDispatchMinute = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null ? npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute() : 0;
        Integer tmpScheduledDispatchHour = scheduledDispatchHour;
        
        if (isFirstTimeFlight) {
            // compute HoursTimeFromHubToPort
            Integer HoursTimeFromHubToPort = 0;
            if (npObj.Flight_Departure_Time__c != null) {
                if (npObj.Flight_Departure_Time__c.hour() < scheduledDispatchHour) HoursTimeFromHubToPort = (24 + npObj.Flight_Departure_Time__c.hour()) - scheduledDispatchHour;
                else HoursTimeFromHubToPort = npObj.Flight_Departure_Time__c.hour() - scheduledDispatchHour;
            }
            Integer MinutesTimeFromHubToPort = npObj.Flight_Departure_Time__c != null ? npObj.Flight_Departure_Time__c.minute() - scheduledDispatchMinute : 0;
            Integer SecondsTimeFromHubToPort = 0;
            if (npObj.Flight_Departure_Time__c != null && npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null) {
                SecondsTimeFromHubToPort = npObj.Flight_Departure_Time__c.second() - npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.second();
            }
            
            if (scheduledDispatchHour < TATSLAHour || (scheduledDispatchHour == TATSLAHour && scheduledDispatchMinute < TATSLAMinute)) {
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            
            // Flight time calculation robust against overnight flights
            Integer depTotalSeconds = (npObj.Flight_Departure_Time__c.hour() * 3600) + (npObj.Flight_Departure_Time__c.minute() * 60) + npObj.Flight_Departure_Time__c.second();
            Integer arrTotalSeconds = (npObj.Flight_Arrival_Time__c.hour() * 3600) + (npObj.Flight_Arrival_Time__c.minute() * 60) + npObj.Flight_Arrival_Time__c.second();
            if (arrTotalSeconds < depTotalSeconds) arrTotalSeconds += 24 * 3600;
            Integer diffSeconds = arrTotalSeconds - depTotalSeconds;
            Integer FlightTimeHour = diffSeconds / 3600;
            Integer remainingAfterHours = diffSeconds - (FlightTimeHour * 3600);
            Integer FlightTimeMinute = remainingAfterHours / 60;
            Integer FlightTimeSeconds = remainingAfterHours - (FlightTimeMinute * 60);
            
            Integer hourToReachNextHubAfterArrival = 0;
            if (npObj.Schedule_Arrival_from_airport_to_hub__c != null && npObj.Flight_Arrival_Time__c != null) {
                if (npObj.Schedule_Arrival_from_airport_to_hub__c.hour() < npObj.Flight_Arrival_Time__c.hour()) {
                    hourToReachNextHubAfterArrival = (24 + npObj.Schedule_Arrival_from_airport_to_hub__c.hour()) - npObj.Flight_Arrival_Time__c.hour();
                } else {
                    hourToReachNextHubAfterArrival = npObj.Schedule_Arrival_from_airport_to_hub__c.hour() - npObj.Flight_Arrival_Time__c.hour();
                }
            }
            Integer minuteToReachNextHubAfterArrival = npObj.Schedule_departure_from_airport_to_hub__c != null && npObj.Flight_Arrival_Time__c != null ? npObj.Schedule_departure_from_airport_to_hub__c.minute() - npObj.Flight_Arrival_Time__c.minute() : 0;
            if (minuteToReachNextHubAfterArrival < 0) {
                minuteToReachNextHubAfterArrival += 60;
                hourToReachNextHubAfterArrival -= 1;
            }
            
            ARHour += (scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival);
            ARMinute += (scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival);
            ARSeconds += (FlightTimeSeconds + SecondsTimeFromHubToPort);
            
            TATSLAHour = tmpScheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival;
            TATSLAMinute = scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival;
            if (TATSLAMinute >= 60) {
                TATSLAHour += (TATSLAMinute / 60);
                TATSLAMinute = Math.mod(TATSLAMinute, 60);
            }
            if (TATSLAHour >= 24) TATSLAHour = Math.mod(TATSLAHour, 24);
            
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        } else {
            // subsequent flight adjustments: same logic, different accumulation
            Integer HoursTimeFromHubToPort = 0;
            if (npObj.Flight_Departure_Time__c != null) {
                if (npObj.Flight_Departure_Time__c.hour() < scheduledDispatchHour) HoursTimeFromHubToPort = (24 + npObj.Flight_Departure_Time__c.hour()) - scheduledDispatchHour;
                else HoursTimeFromHubToPort = npObj.Flight_Departure_Time__c.hour() - scheduledDispatchHour;
            }
            Integer MinutesTimeFromHubToPort = npObj.Flight_Departure_Time__c != null ? npObj.Flight_Departure_Time__c.minute() - scheduledDispatchMinute : 0;
            Integer SecondsTimeFromHubToPort = 0;
            if (npObj.Flight_Departure_Time__c != null && npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c != null) {
                SecondsTimeFromHubToPort = npObj.Flight_Departure_Time__c.second() - npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.second();
            }
            
            if (scheduledDispatchHour < TATSLAHour || (scheduledDispatchHour == TATSLAHour && scheduledDispatchMinute < TATSLAMinute)) {
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            
            Integer depTotalSeconds = (npObj.Flight_Departure_Time__c.hour() * 3600) + (npObj.Flight_Departure_Time__c.minute() * 60) + npObj.Flight_Departure_Time__c.second();
            Integer arrTotalSeconds = (npObj.Flight_Arrival_Time__c.hour() * 3600) + (npObj.Flight_Arrival_Time__c.minute() * 60) + npObj.Flight_Arrival_Time__c.second();
            if (arrTotalSeconds < depTotalSeconds) arrTotalSeconds += 24 * 3600;
            Integer diffSeconds = arrTotalSeconds - depTotalSeconds;
            Integer FlightTimeHour = diffSeconds / 3600;
            Integer remainingAfterHours = diffSeconds - (FlightTimeHour * 3600);
            Integer FlightTimeMinute = remainingAfterHours / 60;
            Integer FlightTimeSeconds = remainingAfterHours - (FlightTimeMinute * 60);
            
            Integer hourToReachNextHubAfterArrival = 0;
            if (npObj.Schedule_Arrival_from_airport_to_hub__c != null && npObj.Flight_Arrival_Time__c != null) {
                if (npObj.Schedule_Arrival_from_airport_to_hub__c.hour() < npObj.Flight_Arrival_Time__c.hour()) {
                    hourToReachNextHubAfterArrival = (24 + npObj.Schedule_Arrival_from_airport_to_hub__c.hour()) - npObj.Flight_Arrival_Time__c.hour();
                } else {
                    hourToReachNextHubAfterArrival = npObj.Schedule_Arrival_from_airport_to_hub__c.hour() - npObj.Flight_Arrival_Time__c.hour();
                }
            }
            Integer minuteToReachNextHubAfterArrival = npObj.Schedule_departure_from_airport_to_hub__c != null && npObj.Flight_Arrival_Time__c != null ? npObj.Schedule_departure_from_airport_to_hub__c.minute() - npObj.Flight_Arrival_Time__c.minute() : 0;
            if (minuteToReachNextHubAfterArrival < 0) {
                minuteToReachNextHubAfterArrival += 60;
                hourToReachNextHubAfterArrival -= 1;
            }
            
            ARHour += (scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival);
            ARMinute += (scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival);
            ARSeconds += (FlightTimeSeconds + SecondsTimeFromHubToPort);
            
            TATSLAHour = tmpScheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival;
            TATSLAMinute = scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival;
            if (TATSLAMinute >= 60) {
                TATSLAHour += (TATSLAMinute / 60);
                TATSLAMinute = Math.mod(TATSLAMinute, 60);
            }
            if (TATSLAHour >= 24) TATSLAHour = Math.mod(TATSLAHour, 24);
            
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            return timeMap;
        }
    } // end adjustARAir
    
    
    // split route like "ABC_DEF" -> returns second piece if available
    public static String splitRoute(String originalNextRoute) {
        if (originalNextRoute == null) return '';
        List<String> parts = originalNextRoute.split('_');
        if (parts.size() > 1) return parts[1];
        return '';
    }
    
    // extract first token of hub name pre dash/space
    public static String extractHubKey(String hubName) {
        if (hubName == null) return '';
        String trimmed = hubName.trim();
        if (trimmed.contains('-')) {
            List<String> parts = trimmed.split('\\s*-\\s*');
            if (!parts.isEmpty()) return parts[0];
        } else {
            List<String> parts = trimmed.split('\\s+');
            if (!parts.isEmpty()) return parts[0];
        }
        return trimmed;
    }
}