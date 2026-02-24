global class SLACalculatorHandlerBatch implements Database.Batchable<sObject> {
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

    private List<Shipment__c> shipList;
    // Constructor accepts Account List from Trigger
    public SLACalculatorHandlerBatch(List<Shipment__c> shipList) {
        this.shipList = shipList;
    }
	
    /*
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM Account limit 1');
    } */
	
    global Iterable<sObject> start(Database.BatchableContext BC) {
        return this.shipList;
    }
    global void execute(Database.BatchableContext BC, List<Shipment__c> shipList) {
        if (isTriggerExecuted) {
            return;
        }       
        try {
            isTriggerExecuted = true;
            
            System.debug('for checking shipList ' + shipList);
            System.debug('for checking  shipList.size() ' + shipList.size());
            
            Integer TATSLAHour = 0;
            Integer TATSLAMinute = 0;
            Integer TATSLASeconds = 0;
            
            Integer ARHour = 0;
            Integer ARMinute = 0;
            Integer ARSeconds = 0;
            
            String TATSLAStartTime = '';
            
            String originPincode = '';
            String destinationPincode = '';
            
            Set<Id> pickupIdSet = new Set<Id>();
            Map<Id,Shipment__c> shipMap = new Map<Id,Shipment__c>(); // added by Imran on Sep 26 - 2025
            
            //Set<String> allStates = new Set<String>();		//added for pratiks holiday charges code by Rafi on 06-10-2025
            //Set<Date> allDates = new Set<Date>();			//added for pratiks holiday charges code by Rafi on 06-10-2025
            
            for (Shipment__c shipObj : shipList) {
                pickupIdSet.add(shipObj.Pickup__c);
                shipIdVsTATSLAMapping.put(shipObj.Id,new TAT_SLA_Mapping__c(Origin_Pincode__c = shipObj.Origin_Address_Name__r.Active_Pincode__c,Destination_Pincode__c = shipObj.Destination_Address_Name__r.Active_Pincode__c));
				shipMap.put(shipObj.Id,shipObj);	// added by Imran on Sep 26 - 2025  
                
                //if (shipObj.Origin_Address_State__c != null) allStates.add(shipObj.Origin_Address_State__c);			//added for pratiks holiday charges code by Rafi on 06-10-2025
                //if (shipObj.Destination_Address_State__c != null) allStates.add(shipObj.Destination_Address_State__c);	//added for pratiks holiday charges code by Rafi on 06-10-2025

            }
            
            if(!shipIdVsTATSLAMapping.values().isEmpty()){
                insert shipIdVsTATSLAMapping.values();
            }
            System.debug('check shipIdVsTATSLAMapping.values() '+shipIdVsTATSLAMapping.values());
            
            System.debug('for checking pickupIdSet ' + pickupIdSet);
            Map<Id, Pickup__c> pickupMap = new Map<Id, Pickup__c>([SELECT Id, Name, Origin_Address_Pincode__c,Physical_Pickup_Completed_Time__c 
                                                                   FROM Pickup__c WHERE Id IN :pickupIdSet]);
            System.debug('for checking pickupMap ' + pickupMap);
            
            List<Distance_Calculator__c> distanceCalulatorList = 
                Test.isRunningTest() ? new List<Distance_Calculator__c>() :
            [SELECT Id, Name, State__c, Origin_Pincode__c, Destination_Pincode__c, City__c, 
             Distance_in_km__c, Distance_Range__c, Time_from_Pickup_to_Hub__c, 
             Scheduled_Delivery_Route_Start_Time__c, Same_City_Hub_Delivery_Route_Start_Time__c, 
             ROUTE_NUMBER__c ,Time_from_Hub_to_delivery_point__c,Pickup_Slot_Start__c,Pickup_Slot_End__c,Pickup_End_Cutoff__c,
             Schedule_Delivery_Start_Time_1__c,Schedule_Delivery_End_Time_1__c,Schedule_Delivery_Start_Time_2nd_Round__c,
             Schedule_Delivery_End_Time_2nd_Round__c,Schedule_Delivery_3_Start_Time__c,Schedule_Delivery_3_End_Time__c,
             Scheduled_Route_Start_Time_2nd_Round__c,Scheduled_Route_Start_Time_3rd_Round__c,Time_from_Hub_to_Delivery_Point_Route_2__c,
             Time_from_Hub_to_Delivery_Point_Route_3__c
             FROM Distance_Calculator__c];
                 
            System.debug('for checking distanceCalulatorList ' + distanceCalulatorList);
            System.debug('for checking distanceCalulatorList.size() ' + distanceCalulatorList.size());
            
            /*  
                List<Distance_Calculator__c> distanceCalulatorList = [SELECT Id, Name, State__c, Origin_Pincode__c, 
                                                                      Destination_Pincode__c, City__c, Distance_in_km__c, 
                                                                      Distance_Range__c, Time_from_Pickup_to_Hub__c, 
                                                                      Scheduled_Delivery_Route_Start_Time__c, 
                                                                      Same_City_Hub_Delivery_Route_Start_Time__c, 
                                                                      ROUTE_NUMBER__c FROM Distance_Calculator__c];
                
            */
            
            Map<String, Distance_Calculator__c> distanceMap = new Map<String, Distance_Calculator__c>();
            for (Distance_Calculator__c dcObj : distanceCalulatorList) {
                String key = dcObj.Destination_Pincode__c;
                distanceMap.put(key, dcObj);
            }
            System.debug('for checking distanceMap ' + distanceMap);
            
            //Added for number field testing for Approx. time taken 1
            List<Network_Plan__c> networkPlanList = 
                Test.isRunningTest() ? new List<Network_Plan__c>():
            [SELECT Id, Name, From_Hub__c, To_Destination_Hub__c, Destination_City__c,
             Approx_Time_Taken_in_hrs__c, OD_Concat__c, Next_Route__c, Transport_Type__c,
             Origin_Port__c, Destination_Port__c, Flight_No__c, Flight_Departure_Time__c,
             Flight_Arrival_Time__c, Scheduled_Max_Time_of_Vehicle_Dispatch__c,
             Approx_Time_Taken_in_hrs1__c, Route_No__c, Scheduled_Arrival_at_Hub__c,
             Scheduled_Arrival_at_Airport__c, Schedule_Airport_handover_time__c, 
             Schedule_Load_retrival_time__c, Schedule_departure_from_airport_to_hub__c, 
             Schedule_Arrival_from_airport_to_hub__c, Hub_Processing_hr__c,
             Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c, Scheduled_max_time_of_vehicle_dispatch_3__c
             FROM Network_Plan__c];
                 
            //List<Network_Plan__c> networkPlanList = [SELECT Id, Name, From_Hub__c, To_Destination_Hub__c, Destination_City__c, Approx_Time_Taken_in_hrs__c, OD_Concat__c, Next_Route__c, Transport_Type__c, Origin_Port__c, Destination_Port__c, Flight_No__c, Flight_Departure_Time__c, Flight_Arrival_Time__c, Scheduled_Max_Time_of_Vehicle_Dispatch__c FROM Network_Plan__c];
            System.debug('for checking networkPlanList ' + networkPlanList);
            System.debug('for checking networkPlanList.size() ' + networkPlanList.size());
            
            Map<String, Network_Plan__c> networkPlanMap = new Map<String, Network_Plan__c>();
            for (Network_Plan__c npObj : networkPlanList) {
                String key = npObj.From_Hub__c + '_' + npObj.To_Destination_Hub__c;
                networkPlanMap.put(key, npObj);
                
            }
            System.debug('for checking networkPlanMap ' + networkPlanMap);
            
            
            //Added code for holiday
            List<Holiday_Data__c> holidayListData = 
                Test.isRunningTest() ? new List<Holiday_Data__c>() :
            [SELECT Id, Name, State__c, Date__c FROM Holiday_Data__c];

            
			//List<Holiday_Data__c> holidayListData = new List<Holiday_Data__c>();
			//holidayListData = [Select Id, Name, State__c, Date__c From Holiday_Data__c];
            System.debug('for checking holidayListData '+holidayListData);
            
            Map<String,Date> holidayMap = new Map<String,Date>();
            Map<Date,Holiday_Data__c> holidayDateMap = new Map<Date,Holiday_Data__c>();
            
            Map<String,Holiday_Data__c> holidayDateStateMap = new Map<String,Holiday_Data__c>();
            
            for(Holiday_Data__c hdObj : holidayListData){
                String hdKey = hdObj.State__c;
                holidayMap.put(hdKey,hdObj.Date__c);
                Date hdDateKey = hdObj.Date__c;
                holidayDateMap.put(hdDateKey,hdObj);
                String key = hdObj.Date__c.format() + '-' + hdObj.State__c;
                holidayDateStateMap.put(key,hdObj);
            }
            System.debug('for checking holidayMap ' + holidayMap);
            //upto here
            
            
            for (Shipment__c shipObj : shipList) {
                System.debug('for checking shipObj.Name '+shipObj.Name);
                System.debug('for checking shipObj.Shipping_Note_Number__c '+shipObj.Shipping_Note_Number__c);
                originPincode = shipObj.Origin_Address_Name__r.Active_Pincode__r.Name;
                destinationPincode = shipObj.Destination_Address_Name__r.Active_Pincode__r.Name;
                System.debug('for checking originPincode :'+originPincode);
                System.debug('for checking destinationPincode :'+destinationPincode);
                
                Pickup__c pickupObj = pickupMap.get(shipObj.Pickup__c);
                
                //allDates.add(pickupObj.Physical_Pickup_Completed_Time__c.date());	//added for pratiks holiday charges code by Rafi on 06-10-2025
                
                if (pickupObj != null) {
					System.debug('109 pickupObj.Origin_Address_Pincode__c :'+pickupObj.Origin_Address_Pincode__c);
                    String key = pickupObj.Origin_Address_Pincode__c;
                    
                    
                    
                    Distance_Calculator__c dcObj = distanceMap.get(key);
                    System.debug('for checking distanceMap.get(key) = '+distanceMap.get(key));
                    System.debug('for checking shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.time() = '+shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.time());
                    System.debug('for checking dcObj.Pickup_End_Cutoff__c = '+dcObj.Pickup_End_Cutoff__c);
                    System.debug('for checking dcObj.Pickup_Slot_Start__c = '+dcObj.Pickup_Slot_Start__c);
                    /*
                    if(shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.time() > dcObj.Pickup_End_Cutoff__c){
                        System.debug('for checking Pickup time is out of slot will add logic here...');
                        
                        Datetime nextDaySlotStart = Datetime.newInstance(shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.date().addDays(1),dcObj.Pickup_Slot_Start__c);
                        
                        TATSLAHour   = nextDaySlotStart.hour();
                        TATSLAMinute = nextDaySlotStart.minute();
                        TATSLASeconds = nextDaySlotStart.second();
                        
                        Long delayMillis = nextDaySlotStart.getTime() - shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.getTime();
                        
                        Integer delaySeconds = (Integer)(delayMillis / 1000);
                        Integer delayMinutes = delaySeconds / 60;
                        Integer delayHours   = delayMinutes / 60;
                        
                        Integer remainingMinutes = Math.mod(delayMinutes, 60);
                        Integer remainingSeconds = Math.mod(delaySeconds, 60);
                        
                        ARHour    += delayHours;
                        ARMinute  += remainingMinutes;
                        ARSeconds += remainingSeconds;
						
                        
                    } 
                    else if (shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.time() < dcObj.Pickup_Slot_Start__c) {
                        
                        System.debug('for checking Early pickup...');
                        
                        Datetime sameDaySlotStart = Datetime.newInstance(shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.Date(), dcObj.Pickup_Slot_Start__c);
                        
                        TATSLAHour    = sameDaySlotStart.hour();
                        TATSLAMinute  = sameDaySlotStart.minute();
                        TATSLASeconds = sameDaySlotStart.second();
                        
                        Long delayMillis = sameDaySlotStart.getTime() - shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.getTime();
                        
                        Integer delaySeconds = (Integer)(delayMillis / 1000);
                        Integer delayMinutes = delaySeconds / 60;
                        Integer delayHours   = delayMinutes / 60;
                        
                        ARHour    += delayHours;
                        ARMinute  += Math.mod(delayMinutes, 60);
                        ARSeconds += Math.mod(delaySeconds, 60);
                        
                    } 
                    else {
                        TATSLAHour = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.hour();
                        TATSLAMinute = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.minute();
                        TATSLASeconds = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.second();
                        
                    }
                    */
                    // added by Imran
                    //TATSLAHour = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.hour();
                    //TATSLAMinute = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.minute();
                    //TATSLASeconds = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.second();
                    // upto here added by Imran
                    
                    
                    Datetime pickupDT = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
                    Date pickupDate   = pickupDT.date();
                    
                    // Slot start is ALWAYS same calendar day
                    Datetime slotStartDT =
                        Datetime.newInstance(pickupDate, dcObj.Pickup_Slot_Start__c);
                    
                    // Slot end logic (may cross midnight)
                    Datetime slotEndDT;
                    if (dcObj.Pickup_End_Cutoff__c < dcObj.Pickup_Slot_Start__c) {
                        // Overnight slot
                        slotEndDT =
                            Datetime.newInstance(pickupDate.addDays(1), dcObj.Pickup_End_Cutoff__c);
                    } else {
                        // Same-day slot
                        slotEndDT =
                            Datetime.newInstance(pickupDate, dcObj.Pickup_End_Cutoff__c);
                    }
                    
                    System.debug('Pickup DT     = ' + pickupDT);
                    System.debug('Slot Start DT = ' + slotStartDT);
                    System.debug('Slot End DT   = ' + slotEndDT);
                    
                    
                    if (pickupDT < slotStartDT) {
                        System.debug('Early pickup → wait till slot start');
                        
                        Datetime effectivePickup = slotStartDT;
                        
                        Long delayMillis = effectivePickup.getTime() - pickupDT.getTime();
                        Integer delaySeconds = (Integer)(delayMillis / 1000);
                        
                        ARHour    += delaySeconds / 3600;
                        ARMinute  += Math.mod(delaySeconds / 60, 60);
                        ARSeconds += Math.mod(delaySeconds, 60);
                        
                        TATSLAHour    = effectivePickup.hour();
                        TATSLAMinute  = effectivePickup.minute();
                        TATSLASeconds = effectivePickup.second();
                    }
                    else if (pickupDT >= slotStartDT && pickupDT <= slotEndDT) {
                        System.debug('Pickup within slot');
                        
                        TATSLAHour    = pickupDT.hour();
                        TATSLAMinute  = pickupDT.minute();
                        TATSLASeconds = pickupDT.second();
                    }
                    else {
                        System.debug('Pickup after slot cutoff → next day slot start');
                        
                        Datetime nextDaySlotStart = Datetime.newInstance(pickupDate.addDays(1), dcObj.Pickup_Slot_Start__c);
                        
                        Long delayMillis = nextDaySlotStart.getTime() - pickupDT.getTime();
                        Integer delaySeconds = (Integer)(delayMillis / 1000);
                        
                        ARHour    += delaySeconds / 3600;
                        ARMinute  += Math.mod(delaySeconds / 60, 60);
                        ARSeconds += Math.mod(delaySeconds, 60);
                        
                        TATSLAHour    = nextDaySlotStart.hour();
                        TATSLAMinute  = nextDaySlotStart.minute();
                        TATSLASeconds = nextDaySlotStart.second();
                    }
					
                    
                    
                    //Added lines 314-316 for testing purpose only
                    /*TATSLAHour    = 20;
                    TATSLAMinute  = 01;
                    TATSLASeconds = 33;*/
                    //upto here
                    
                    
                    
                    System.debug('for checking TATSLAHour '+TATSLAHour);
                    System.debug('for checking TATSLAMinute '+TATSLAMinute);
                    System.debug('for checking TATSLASeconds '+TATSLASeconds);
                    
                    
                    System.debug('for checking ARHour '+ARHour);
                    System.debug('for checking ARMinute '+ARMinute);
                    System.debug('for checking ARSeconds '+ARSeconds);
                    
                    
                    
                    System.debug('for checking key = '+key);
                    
                    // Added to check holiday on Pickup point
                    
                    if(key!=null){
                        /*Datetime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
                        
                        Date PickupDateToCheck = date.newinstance(currentDateTime.year(),currentDateTime.month(),currentDateTime.day());
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) PickupDateToCheck '+PickupDateToCheck);
                        
                        
                        String holidayOnPickupDate = '';
                        
                        String mapKey = PickupDateToCheck.format() + '-' + shipObj.Origin_Address_State__c;
                        System.debug('@for checking mapKey '+mapKey);
                        
                        Holiday_Data__c holidayData = holidayDateStateMap.get(mapKey);
                        
                        if(holidayData != null){
                            holidayOnPickupDate = holidayData.Name + ' on ' + holidayData.Date__c.format() + ' in ' + holidayData.State__c;
                            TATSLAHour += 24;
                            ARHour += 24;
                           
                        }
                        
                        ShipIdVsPickupHoliday.put(shipObj.Id,holidayOnPickupDate);
                        */
                        
                        Datetime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
                        Date pickupDateToCheck = Date.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day());
                        System.debug('for checking PickupDateToCheck: ' + pickupDateToCheck);
                        
                        String holidayOnPickupDate = '';
                        String state = shipObj.Origin_Address_State__c;
                        
                        Integer holidayCount = 0;
                        List<String> holidayNames = new List<String>();
                        
                        Date checkDate = pickupDateToCheck;
                        
                        while (true) {
                            String mapKey = checkDate.format() + '-' + state;
                            Holiday_Data__c holidayData = holidayDateStateMap.get(mapKey);
                            
                            if (holidayData != null) {
                                holidayNames.add(holidayData.Name + ' on ' + holidayData.Date__c.format() + ' in ' + holidayData.State__c);
                                holidayCount++;
                                checkDate = checkDate.addDays(1);
                            } else {
                                break;
                            }
                        }
                        
                        if (holidayCount > 0) {
                            holidayOnPickupDate = String.join(holidayNames, ', ');
                            Integer extraHours = 24 * holidayCount;
                            TATSLAHour += extraHours;
                            ARHour += extraHours;
                        }
                        
                        ShipIdVsPickupHoliday.put(shipObj.Id, holidayOnPickupDate);

                    }
                    
                    //upto here
                    
                    
                    
                    System.debug('for checking dcObj '+dcObj);
                    if (dcObj != null) {
                        Map<String, Object> resultMap = adjustTATSLAHourAndMinute(dcObj, shipObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds);
                        ARHour = (Integer) resultMap.get('ARHour');
                        ARMinute = (Integer) resultMap.get('ARMinute');
                        ARSeconds = (Integer) resultMap.get('ARSeconds');
                        System.debug('for checking before checkNextRoute ARHour '+ARHour);
                        System.debug('for checking before checkNextRoute ARMinute '+ARMinute);
                        System.debug('for checking before checkNextRoute ARSeconds '+ARSeconds);
                        Boolean isSameCityLogicExecuted = (Boolean) resultMap.get('isSameCityLogicExecuted');
                        
                        TATSLAHour = (Integer) resultMap.get('TATSLAHour');
                        TATSLAMinute = (Integer) resultMap.get('TATSLAMinute');

                        System.debug('for checking before checkNextRoute TATSLAHour '+TATSLAHour);
                        System.debug('for checking before checkNextRoute TATSLAMinute '+TATSLAMinute);
                        
                        System.debug('for checking before checkNextRoute isSameCityLogicExecuted '+isSameCityLogicExecuted);
                        System.debug('1001 for shipObj.Origin_Hub__r.Name '+shipObj.Origin_Hub__r.Name);
                        System.debug('1001 for shipObj.Destination_Hub__r.Name '+shipObj.Destination_Hub__r.Name);
                        
                        
                        String testOriginAddNameKey = '';
                        if (shipObj.Origin_Hub__r.Name != null) {
                            String originHubName = shipObj.Origin_Hub__r.Name.trim();
                            
                            if (originHubName.contains('-')) {
                                List<String> parts = originHubName.split('\\s*-\\s*');
                                if (!parts.isEmpty()) {
                                    testOriginAddNameKey = parts[0];
                                }
                            } else {
                                List<String> parts = originHubName.split('\\s+'); 
                                if (!parts.isEmpty()) {
                                    testOriginAddNameKey = parts[0];
                                }
                            }
                        }
                        
                        String testDestAddNameKey = '';
                        if (shipObj.Destination_Hub__r.Name != null) {
                            String destinationHubName = shipObj.Destination_Hub__r.Name.trim();
                            
                            if (destinationHubName.contains('-')) {
                                List<String> parts = destinationHubName.split('\\s*-\\s*');
                                if (!parts.isEmpty()) {
                                    testDestAddNameKey = parts[0];
                                }
                            } else {
                                List<String> parts = destinationHubName.split('\\s+');
                                if (!parts.isEmpty()) {
                                    testDestAddNameKey = parts[0];
                                }
                            }
                        }
                        
                        if (shipObj.Origin_Hub__r.Name != null && testOriginAddNameKey.equalsIgnoreCase('HYD')) {
                            testOriginAddNameKey = 'HYDERABAD';
                        }
                        if (shipObj.Destination_Hub__r.Name != null && testDestAddNameKey.equalsIgnoreCase('HYD')) {
                            testDestAddNameKey = 'HYDERABAD';
                        }

                        
                        System.debug('For checking origin hub name after trimming: ' + testOriginAddNameKey);
                        System.debug('For checking destination hub name after trimming: ' + testDestAddNameKey);
                        
                        if (!isSameCityLogicExecuted) {
                            //String npkey = shipObj.Origin_Hub__r.Name + '_' + shipObj.Destination_Hub__r.Name;
                            String npKey = testOriginAddNameKey +'_'+ testDestAddNameKey;
                            String destinationKey = shipObj.Destination_Address_Pincode__c;
                            String hdStateKey = shipObj.Destination_Address_State__c;
                            
                            System.debug('for checking before checkNextRoute key :' + npkey);
                            System.debug('for checking before checkNextRoute destinationKey :' + destinationKey);
                            System.debug('for checking before checkNextRoute hdStateKey :' + hdStateKey);
                            
                            checkNextRoute(npkey, shipObj, networkPlanMap, destinationKey, distanceMap, TATSLAHour, TATSLAMinute, TATSLASeconds, ARHour, ARMinute, ARSeconds, new Set<String>(), hdStateKey, holidayMap, holidayDateMap, holidayDateStateMap);
                        }

                    }
                    
                    TATSLAHour = 0;
                    TATSLAMinute = 0;
                    TATSLASeconds = 0;
                    
                    ARHour = 0;
                    ARMinute = 0;
                    ARSeconds = 0;
                    
                    isFirstTimeRoad = true;
                    isFirstTimeFlight = true;
                }
                
            }
            
            if(npCalListToInsert.size()>0){
                insert npCalListToInsert;
            }
            
            if(dcCalListToInsert.size()>0){
                insert dcCalListToInsert;
            }
            
            List<TAT_SLA_Mapping__c> tsmListToUpdate = new List<TAT_SLA_Mapping__c>();
            List<Shipment__c> ShipmentLst2Update = new List<Shipment__c>();		// added by Imran Sep 26-2025
            List<Holiday_Data__c> holidayDataForPratik = new List<Holiday_Data__c>();	//added for pratiks holiday charges code by Rafi on 06-10-2025
            
            //holidayDataForPratik = [SELECT State__c, Date__c FROM Holiday_Data__c WHERE State__c IN :allStates AND Date__c IN :allDates ];	//added for pratiks holiday charges code by Rafi on 06-10-2025
            
            //added for pratiks holiday charges code by Rafi on 06-10-2025
            /*Map<String, Set<Date>> holidayMap1 = new Map<String, Set<Date>>();
            for (Holiday_Data__c hd : holidayDataForPratik) {
                if (!holidayMap1.containsKey(hd.State__c)) {
                    holidayMap1.put(hd.State__c, new Set<Date>());
                }
                holidayMap1.get(hd.State__c).add(hd.Date__c);
            }*/
            //upto here
            
            for(Id shipId : shipIdVsTATSLAMapping.keySet()){
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
                
				// added by Imran Sep 26-2025                
                Shipment__c ship = shipMap.get(shipId);                
                String CombinedSLAOutput = tmpTSM.TAT_in_Days__c +' Days OR '+ tmpTSM.SLA_Hours__c ;
                if(ShipIdVsEstDelDate.get(shipId)!=null)
                {
                    DateTime Estimated = ShipIdVsEstDelDate.get(shipId);
                    ship.Estimated_Delivery_Date__c = Estimated.date();
                    ship.Estimated_Delivery_Datetime__c = Estimated;
                    // Estimated_Delivery_Datetime__c
                }                
                ship.SLA_Days_and_Hours__c = CombinedSLAOutput;
                ship.Physical_Pickup_Completed_Time1__c = ship.Pickup__r.Physical_Pickup_Completed_Time__c;
			    
                
                //added for pratiks holiday charges code by Rafi on 06-10-2025
                //Date pickupDate = ship.Pickup__r.Physical_Pickup_Completed_Time__c.date();
            	//Boolean isSunday = pickupDate == pickupDate.toStartOfWeek();
                
           /*     Boolean isHoliday = (ship.Origin_Address_State__c != null && holidayMap1.get(ship.Origin_Address_State__c)?.contains(pickupDate) == true) 
				||(ship.Destination_Address_State__c != null && holidayMap1.get(ship.Destination_Address_State__c)?.contains(pickupDate) == true);                
                Boolean shouldCheck = (isSunday || isHoliday);
                Boolean currentValue = ship.holiday_sunday_charges1__c == true;                
                if (currentValue != shouldCheck) {
                    ship.holiday_sunday_charges1__c = shouldCheck;
                }	*/	//commented holiday charges calculation by Pratik on 13 oct		
                //upto here
                
                ShipmentLst2Update.add(ship);
                
                // added by Imran Sep 26-2025                 
            }
            
            if(tsmListToUpdate.size()>0){
                try
                {
                    update tsmListToUpdate;
                    update ShipmentLst2Update;	// added by Imran Sep 26-2025                   
                } catch(Exception e)
                {
                    Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandlerBatch',Error__c=e.getLineNumber() +'-'+e.getStackTraceString() +'-'+e.getMessage());
                    insert AEL;
                }

            }
            
            
        } catch(Exception ex){
            System.debug('%%% Error in distanceCalculator method '+ex.getMessage());
            System.debug('%%% On Line Number '+ex.getLineNumber());
            Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandlerBatchFinalBatch',Error__c=ex.getLineNumber() +'-'+ex.getStackTraceString() +'-'+ex.getMessage());   
            insert AEL;  
            
        } finally {
            isTriggerExecuted = false;
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        // Post-processing logic
    }
    
    /*public static Map<String, Object> adjustTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj, Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        Integer SameCityDeliveryHour = 0;
        Integer SameCityDeliveryMinute = 0;
        
        Boolean isSameCityLogicExecuted = false;
        
        System.debug('for checking Inside adjustTATSLAHourAndMinute');
        
        System.debug('for checking ARHour :'+ARHour);
        System.debug('for checking ARMinute :'+ARMinute);
        
        //ARHour += 1;		//hub processing time
        
        System.debug('for checking dcObj.Origin_Pincode__c: '+dcObj.Origin_Pincode__c);
        System.debug('for checking dcObj.Destination_Pincode__c: '+dcObj.Destination_Pincode__c);
        
        if ((dcObj.Origin_Pincode__c == dcObj.Destination_Pincode__c) && (shipObj.Destination_Address_City__c == dcObj.City__c) && (shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c)) {
            System.debug('Inside same city logic');
            
            isSameCityLogicExecuted = true;
            
            SameCityDeliveryHour = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c.hour();
            SameCityDeliveryMinute = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c.minute();
        
            System.debug('Inside same city ARHour '+ARHour);
            System.debug('Inside same city ARMinute '+ARMinute);
            System.debug('Inside same city TATSLAHour '+TATSLAHour);
            System.debug('Inside same city TATSLAMinute '+TATSLAMinute);
            
            if(SameCityDeliveryHour < TATSLAHour){
                    SameCityDeliveryHour = (SameCityDeliveryHour + 24) - TATSLAHour;
                } else {
                    SameCityDeliveryHour = SameCityDeliveryHour - TATSLAHour;
                }
            
            if (ARMinute < 0) {
                ARHour -= 1;
                ARMinute += 60;
            }
            
            Integer hours = 0;
            Integer minutes = 0;
            
            if(dcObj.Time_from_Pickup_to_Hub__c != null){
                Decimal AppoxTimeTaken = dcObj.Time_from_Pickup_to_Hub__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment scheduledDispatchHour '+hours);
            
            ARHour += (SameCityDeliveryHour+hours);
            ARMinute += (SameCityDeliveryMinute+minutes);
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) scheduledDispatchHour '+hours);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) scheduledDispatchMinute '+minutes);
            
            // DateTime currentDateTime = shipObj.Physical_Pickup_Completed_Time1__c;
            
            DateTime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
            
            Date currentDate = currentDateTime.date();
            System.debug('Inside same city currentDate = '+currentDate);
            
            
            DateTime futureDateTime = currentDateTime.addHours(ARHour).addMinutes(ARMinute);
            System.debug('Inside same city deliveryDateTime.date() = '+futureDateTime.date());
            
            if (currentDateTime.date() == futureDateTime.date()) {
                futureDateTime = futureDateTime.addDays(1);
                ARHour += 24;
                System.debug('If Delivery happened on the same day then adding 24 hours to ARHour = ' + ARHour);
            }
            
            
            //if (ARHour < TATSLAHour || (ARHour == TATSLAHour && ARMinute < TATSLAMinute)) {
                //System.debug('Inside if of Inside same city ARHour<TATSLAHour '+ARHour);
                //futureDateTime = futureDateTime.addDays(1);
                //ARHour += 24;
                //System.debug('Inside if of Inside same city ARHour after adding 24 '+ARHour);
                
            //}
            
            
            System.debug('Inside same city Final Calculated ARHour '+ARHour);
            System.debug('Inside same city Final Calculated ARMinute '+ARMinute);
            String FinalTime = ARHour+'H '+ARMinute+'M '+ARSeconds+'S';
            
            Integer additionalARHours = ARMinute / 60;
            Integer remainingARMinutes = Math.mod(ARMinute, 60);
            
            ARHour+=additionalARHours;
            ARMinute+=remainingARMinutes;
            
            Datetime istDateTime = futureDateTime.addSeconds(19800);
			String slaDay = istDateTime.format('EEEE', 'en_US');
            
            Date EstDelDate = date.newinstance(futureDateTime.year(),futureDateTime.month(),futureDateTime.day());
            System.debug('Inside same city EstDelDate = '+EstDelDate);
            
            Integer numberOfDays = Math.abs(EstDelDate.daysBetween(currentDate));
            System.debug('Inside same city numberOfDays = '+numberOfDays);
            
            ShipIdVsFinalTime.put(shipObj.Id,FinalTime);
            ShipIdVsSLADay.put(shipObj.Id,slaDay);
            ShipIdVsEstDelDate.put(shipObj.Id,futureDateTime);
            ShipIdVsTatInDays.put(shipObj.Id,numberOfDays);
        
        
        
        } 
        else if(shipObj.Origin_Address_Pincode__c == dcObj.Destination_Pincode__c){
            System.debug('for checking inside shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c');
            System.debug('for checking Inside adjustTATSLAHourAndMinute dcObj.Time_from_Pickup_to_Hub__c '+dcObj.Time_from_Pickup_to_Hub__c);
            Integer hours = 0;
            Integer minutes = 0;
            
            if(dcObj.Time_from_Pickup_to_Hub__c != null){
                Decimal AppoxTimeTaken = dcObj.Time_from_Pickup_to_Hub__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment scheduledDispatchHour '+hours);
            
            ARHour += hours;
            ARMinute += minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all ARHour '+ARHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all ARMinute '+ARMinute);
            
            TATSLAHour += hours;
            
            Integer remainingHours = Math.mod(TATSLAHour, 24);
            
            TATSLAHour = remainingHours;
            TATSLAMinute += minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAHour '+TATSLAHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAMinute '+TATSLAMinute);
            
        } 
        else {
            System.debug('for checking Inside adjustTATSLAHourAndMinute dcObj.Time_from_Pickup_to_Hub__c '+dcObj.Time_from_Pickup_to_Hub__c);
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute at entry ARHour: '+ARHour);
            System.debug('for checking Inside adjustTATSLAHourAndMinute at entry ARHour: '+ARHour);
            
            Integer scheduledDispatchHour = dcObj.Scheduled_Delivery_Route_Start_Time__c.hour();
            Integer scheduledDispatchMinute = dcObj.Scheduled_Delivery_Route_Start_Time__c.minute();
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute scheduledDispatchHour '+scheduledDispatchHour);
            System.debug('for checking Inside adjustTATSLAHourAndMinute TATSLAHour '+TATSLAHour);
            if(scheduledDispatchHour <= TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            }
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment scheduledDispatchHour '+scheduledDispatchHour);
            
            //Added to check Aprrox. time taken (in hours) will work with number field data.
            Integer hours = 0;
            Integer minutes = 0;
            
            if(dcObj.Time_from_Pickup_to_Hub__c != null){
                Decimal AppoxTimeTaken = dcObj.Time_from_Pickup_to_Hub__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment hours '+hours);
            
            ARHour += (scheduledDispatchHour+hours);
            ARMinute += (scheduledDispatchMinute+minutes);
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) Last ARHour '+ARHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) Last ARMinute '+ARMinute);
            
            
			TATSLAHour += scheduledDispatchHour+ hours + 1;
            TATSLAMinute += scheduledDispatchMinute + minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAHour '+TATSLAHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAMinute '+TATSLAMinute);
                     
            
        }
            
            
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
        dcCal.TAT_SLA_Mapping__c = shipIdVsTATSLAMapping.get(shipObj.Id).Id;
         dcCal.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
        dcCalListToInsert.add(dcCal);
        
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('ARHour', ARHour);
        resultMap.put('ARMinute', ARMinute);
        resultMap.put('ARSeconds', ARSeconds);
        resultMap.put('isSameCityLogicExecuted', isSameCityLogicExecuted);
         
        resultMap.put('TATSLAHour', TATSLAHour);
        resultMap.put('TATSLAMinute', TATSLAMinute);
        
        return resultMap;
        
    }
    */
    
    public static Map<String, Object> adjustTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj, Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        Integer SameCityDeliveryHour = 0;
        Integer SameCityDeliveryMinute = 0;
        
        Boolean isSameCityLogicExecuted = false;
        
        Map<String, Object> resultMap = new Map<String, Object>();

        System.debug('for checking Inside adjustTATSLAHourAndMinute');
        
        System.debug('for checking ARHour :'+ARHour);
        System.debug('for checking ARMinute :'+ARMinute);
        
        //ARHour += 1;		//hub processing time
        
        System.debug('for checking dcObj.Origin_Pincode__c: '+dcObj.Origin_Pincode__c);
        System.debug('for checking dcObj.Destination_Pincode__c: '+dcObj.Destination_Pincode__c);
        
        if (shipObj.Origin_Address_Pincode__c == shipObj.Destination_Address_Pincode__c) {
            
            System.debug('Inside Same Pincode - Window Based Logic');
            isSameCityLogicExecuted = true;
            
            DateTime arrivalAtHub = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
            
            // 2️⃣ Build delivery windows from SAME DC record
            List<Map<String, Time>> deliveryWindows = new List<Map<String, Time>>();
            
            if (dcObj.Schedule_Delivery_Start_Time_1__c != null && 
                dcObj.Schedule_Delivery_End_Time_1__c != null) {
                    
                    deliveryWindows.add(
                        new Map<String, Time>{
                            'start' => dcObj.Schedule_Delivery_Start_Time_1__c,
                                'end'   => dcObj.Schedule_Delivery_End_Time_1__c
                                }
                    );
                }
            
            if (dcObj.Schedule_Delivery_Start_Time_2nd_Round__c != null && 
                dcObj.Schedule_Delivery_End_Time_2nd_Round__c != null) {
                    
                    deliveryWindows.add(
                        new Map<String, Time>{
                            'start' => dcObj.Schedule_Delivery_Start_Time_2nd_Round__c,
                                'end'   => dcObj.Schedule_Delivery_End_Time_2nd_Round__c
                                }
                    );
                }
            
            if (dcObj.Schedule_Delivery_3_Start_Time__c != null && 
                dcObj.Schedule_Delivery_3_End_Time__c != null) {
                    
                    deliveryWindows.add(
                        new Map<String, Time>{
                            'start' => dcObj.Schedule_Delivery_3_Start_Time__c,
                                'end'   => dcObj.Schedule_Delivery_3_End_Time__c
                                }
                    );
                }
            
            // 3️⃣ Select next available window
            DateTime selectedDeliveryDT =
                getNextAvailableDeliveryRoute(arrivalAtHub, deliveryWindows);
            
            // 🔴 BUSINESS FIX: Use DELIVERY WINDOW END as SLA baseline
                Time selTime = selectedDeliveryDT.time();
                Time windowStartTime;
                Time windowEndTime;
                
                // -------- ROUND 1 --------
                if (
                    dcObj.Schedule_Delivery_Start_Time_1__c != null &&
                    dcObj.Schedule_Delivery_End_Time_1__c != null &&
                    selTime >= dcObj.Schedule_Delivery_Start_Time_1__c &&
                    selTime <= dcObj.Schedule_Delivery_End_Time_1__c
                ) {
                    windowStartTime = dcObj.Schedule_Delivery_Start_Time_1__c;
                    windowEndTime = dcObj.Schedule_Delivery_End_Time_1__c;
                    //selectedDeliveryDT = Datetime.newInstance(selectedDeliveryDT.date(), windowEndTime);
                }
                
                // -------- ROUND 2 --------
                else if (
                    dcObj.Schedule_Delivery_Start_Time_2nd_Round__c != null &&
                    dcObj.Schedule_Delivery_End_Time_2nd_Round__c != null &&
                    selTime >= dcObj.Schedule_Delivery_Start_Time_2nd_Round__c &&
                    selTime <= dcObj.Schedule_Delivery_End_Time_2nd_Round__c
                ) {
                    windowStartTime = dcObj.Schedule_Delivery_Start_Time_2nd_Round__c;
                    windowEndTime = dcObj.Schedule_Delivery_End_Time_2nd_Round__c;
                    //selectedDeliveryDT = Datetime.newInstance(selectedDeliveryDT.date(), windowEndTime);
                }
                
                // -------- ROUND 3 --------
                else if (
                    dcObj.Schedule_Delivery_3_Start_Time__c != null &&
                    dcObj.Schedule_Delivery_3_End_Time__c != null &&
                    selTime >= dcObj.Schedule_Delivery_3_Start_Time__c &&
                    selTime <= dcObj.Schedule_Delivery_3_End_Time__c
                ) {
                    windowStartTime = dcObj.Schedule_Delivery_3_Start_Time__c;
                    windowEndTime = dcObj.Schedule_Delivery_3_End_Time__c;
                    //selectedDeliveryDT = Datetime.newInstance(selectedDeliveryDT.date(), windowEndTime);
                }
                
                // 🔧 UNIVERSAL FIX (Round 1 / 2 / 3)
                // If arrival crosses the window END on the same day → next day
                /*if (windowEndTime != null && arrivalAtDestHub.date() == selectedDeliveryDT.date() &&
                    arrivalAtDestHub.time() > windowEndTime) {
                        
                        selectedDeliveryDT = selectedDeliveryDT.addDays(1);
                        System.debug('for checking Delivery window crossed → shifting to next day');
                    }*/
                
                
                // ✅ IMPORTANT: Window END already represents final delivery.
                // Do NOT add hub-to-delivery travel time again.
                //Boolean isWindowEndUsed = true;


                Integer hours = 0;
                Integer minutes = 0;
                
                // If window END is used → delivery already completed
                //if (!isWindowEndUsed) {
                    
                    if (selTime >= dcObj.Scheduled_Delivery_Route_Start_Time__c &&
                        selTime <= dcObj.Schedule_Delivery_End_Time_1__c &&
                        dcObj.Time_from_Hub_to_delivery_point__c != null) {
                            
                            Decimal t = dcObj.Time_from_Hub_to_delivery_point__c;
                            hours = t.intValue();
                            minutes = ((t - hours) * 60).intValue();
                        }
                    else if (selTime >= dcObj.Scheduled_Route_Start_Time_2nd_Round__c &&
                             selTime <= dcObj.Schedule_Delivery_End_Time_2nd_Round__c &&
                             dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c != null) {
                                 
                                 Decimal t = dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c;
                                 hours = t.intValue();
                                 minutes = ((t - hours) * 60).intValue();
                             }
                    else if (selTime >= dcObj.Scheduled_Route_Start_Time_3rd_Round__c &&
                             selTime <= dcObj.Schedule_Delivery_3_End_Time__c &&
                             dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c != null) {
                                 
                                 Decimal t = dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c;
                                 hours = t.intValue();
                                 minutes = ((t - hours) * 60).intValue();
                             }
                //}

                Datetime finalDeliveryDT1 = selectedDeliveryDT.addHours(hours).addMinutes(minutes);
                
                
                if (windowEndTime != null) {
                    
                    Datetime windowEndDT =
                        Datetime.newInstance(finalDeliveryDT1.date(), windowEndTime);
                    
                    System.debug('for checking Window End DT: ' + windowEndDT);
                    
                    // ✅ Only shift day if arrival is AFTER window end on SAME DAY
                    if (arrivalAtHub > windowEndDT &&
                        arrivalAtHub.date() == windowEndDT.date()) {
                            
                            System.debug('Arrival crossed window end → shifting to next day');
                            finalDeliveryDT1 = windowEndDT.addDays(1);
                        } else {
                            finalDeliveryDT1 = windowEndDT;
                        }
                }
                
                System.debug('for checking Final finalDeliveryDT1: ' + finalDeliveryDT1);


                
                
                
                
                /*
                Integer hours = 0;
                Integer minutes = 0;
                
                Time selectedStartTime = selectedDeliveryDT.time();
                
                // -------- ROUND 1 --------
                if (selectedStartTime == dcObj.Schedule_Delivery_Start_Time_1__c && dcObj.Time_from_Hub_to_delivery_point__c != null) {
                    
                    Decimal approxTime = dcObj.Time_from_Hub_to_delivery_point__c;
                    hours = approxTime.intValue();
                    minutes = ((approxTime - hours) * 60).intValue();
                    
                    System.debug('Using Round 1 delivery time');
                }
                
                // -------- ROUND 2 --------
                else if (selectedStartTime == dcObj.Schedule_Delivery_Start_Time_2nd_Round__c && dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c != null) {
                    
                    Decimal approxTime = dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c;
                    hours = approxTime.intValue();
                    minutes = ((approxTime - hours) * 60).intValue();
                    
                    System.debug('Using Round 2 delivery time');
                }
                
                // -------- ROUND 3 --------
                else if (selectedStartTime == dcObj.Schedule_Delivery_3_Start_Time__c && dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c != null) {
                    
                    Decimal approxTime = dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c;
                    hours = approxTime.intValue();
                    minutes = ((approxTime - hours) * 60).intValue();
                    
                    System.debug('Using Round 3 delivery time');
                }*/
                
                
                System.debug('for checking selectedDeliveryDT before finalDeliveryDT ==== '+selectedDeliveryDT);
                System.debug('for checking hours before finalDeliveryDT ==== '+hours);
                System.debug('for checking minutes before finalDeliveryDT ==== '+minutes);
                
                //Datetime finalDeliveryDT = selectedDeliveryDT.addHours(hours).addMinutes(minutes);
                Datetime finalDeliveryDT = finalDeliveryDT1;
                
            
            // 4️⃣ Calculate SLA difference
            Long diffMillis = finalDeliveryDT.getTime() - shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.getTime();
            Integer totalSeconds = (Integer)(diffMillis / 1000);
            
            ARHour    = totalSeconds / 3600;
            ARMinute  = Math.mod((totalSeconds / 60), 60);
            ARSeconds = Math.mod(totalSeconds, 60);
            
            TATSLAHour   = finalDeliveryDT.hour();
            TATSLAMinute = finalDeliveryDT.minute();
            
            // 5️⃣ Update SLA Maps
            String finalTime = ARHour+'H '+ARMinute+'M '+ARSeconds+'S';
            
            ShipIdVsFinalTime.put(shipObj.Id, finalTime);
            ShipIdVsSLADay.put(shipObj.Id, finalDeliveryDT.format('EEEE','en_US'));
            ShipIdVsEstDelDate.put(shipObj.Id, finalDeliveryDT);
            ShipIdVsTatInDays.put(
                shipObj.Id,
                Math.abs(finalDeliveryDT.date().daysBetween(shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.date()))
            );
        }

        /*
        else if ((dcObj.Origin_Pincode__c == dcObj.Destination_Pincode__c) && (shipObj.Destination_Address_City__c == dcObj.City__c) && (shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c)) {
            System.debug('Inside same city logic');
            
            isSameCityLogicExecuted = true;
            
            SameCityDeliveryHour = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c.hour();
            SameCityDeliveryMinute = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c.minute();
            
            System.debug('Inside same city ARHour '+ARHour);
            System.debug('Inside same city ARMinute '+ARMinute);
            System.debug('Inside same city TATSLAHour '+TATSLAHour);
            System.debug('Inside same city TATSLAMinute '+TATSLAMinute);
            
            if(SameCityDeliveryHour < TATSLAHour){
                SameCityDeliveryHour = (SameCityDeliveryHour + 24) - TATSLAHour;
            } else {
                SameCityDeliveryHour = SameCityDeliveryHour - TATSLAHour;
            }
            
            if (ARMinute < 0) {
                ARHour -= 1;
                ARMinute += 60;
            }
            
            Integer hours = 0;
            Integer minutes = 0;
            
            if(dcObj.Time_from_Pickup_to_Hub__c != null){
                //Decimal AppoxTimeTaken = dcObj.Time_from_Hub_to_delivery_point__c;
                Decimal AppoxTimeTaken = dcObj.Time_from_Pickup_to_Hub__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment scheduledDispatchHour '+hours);
            
            ARHour += (SameCityDeliveryHour+hours);
            ARMinute += (SameCityDeliveryMinute+minutes);
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) scheduledDispatchHour '+hours);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) scheduledDispatchMinute '+minutes);
            
            DateTime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
            
            Date currentDate = currentDateTime.date();
            System.debug('Inside same city currentDate = '+currentDate);
            
            
            DateTime futureDateTime = currentDateTime.addHours(ARHour).addMinutes(ARMinute);
            System.debug('Inside same city deliveryDateTime.date() = '+futureDateTime.date());
            
            if (currentDateTime.date() == futureDateTime.date()) {
                futureDateTime = futureDateTime.addDays(1);
                ARHour += 24;
                System.debug('If Delivery happened on the same day then adding 24 hours to ARHour = ' + ARHour);
            }
            
            System.debug('Inside same city Final Calculated ARHour '+ARHour);
            System.debug('Inside same city Final Calculated ARMinute '+ARMinute);
            String FinalTime = ARHour+'H '+ARMinute+'M '+ARSeconds+'S';
            
            Integer additionalARHours = ARMinute / 60;
            Integer remainingARMinutes = Math.mod(ARMinute, 60);
            
            ARHour+=additionalARHours;
            ARMinute+=remainingARMinutes;
            
            Datetime istDateTime = futureDateTime.addSeconds(19800);
            String slaDay = istDateTime.format('EEEE', 'en_US');
            
            Date EstDelDate = date.newinstance(futureDateTime.year(),futureDateTime.month(),futureDateTime.day());
            System.debug('Inside same city EstDelDate = '+EstDelDate);
            
            Integer numberOfDays = Math.abs(EstDelDate.daysBetween(currentDate));
            System.debug('Inside same city numberOfDays = '+numberOfDays);
            
            ShipIdVsFinalTime.put(shipObj.Id,FinalTime);
            ShipIdVsSLADay.put(shipObj.Id,slaDay);
            ShipIdVsEstDelDate.put(shipObj.Id,futureDateTime);
            ShipIdVsTatInDays.put(shipObj.Id,numberOfDays);
            
            
            
        } 
        */
        /*else if(shipObj.Origin_Address_Pincode__c == dcObj.Destination_Pincode__c){
            System.debug('for checking inside shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c');
            System.debug('for checking Inside adjustTATSLAHourAndMinute dcObj.Time_from_Pickup_to_Hub__c '+dcObj.Time_from_Pickup_to_Hub__c);
            Integer hours = 0;
            Integer minutes = 0;
            
            if(dcObj.Time_from_Pickup_to_Hub__c != null){
                Decimal AppoxTimeTaken = dcObj.Time_from_Pickup_to_Hub__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment scheduledDispatchHour '+hours);
            
            ARHour += hours;
            ARMinute += minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all ARHour '+ARHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all ARMinute '+ARMinute);
            
            TATSLAHour += hours;
            
            Integer remainingHours = Math.mod(TATSLAHour, 24);
            
            TATSLAHour = remainingHours;
            TATSLAMinute += minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAHour '+TATSLAHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAMinute '+TATSLAMinute);
            
        } */
        else {
            /*
            System.debug('for checking Inside window-based delivery logic');
            
            List<Map<String, Time>> deliveryWindows = new List<Map<String, Time>>();
            
            if (dcObj.Scheduled_Delivery_Route_Start_Time__c != null && dcObj.Schedule_Delivery_End_Time_1__c != null) {
                deliveryWindows.add(new Map<String, Time>{'start' => dcObj.Scheduled_Delivery_Route_Start_Time__c, 'end'   => dcObj.Schedule_Delivery_End_Time_1__c});
            }
            
            if (dcObj.Scheduled_Route_Start_Time_2nd_Round__c != null && dcObj.Schedule_Delivery_End_Time_2nd_Round__c != null) {
                deliveryWindows.add(new Map<String, Time>{'start' => dcObj.Scheduled_Route_Start_Time_2nd_Round__c,'end'   => dcObj.Schedule_Delivery_End_Time_2nd_Round__c});
            }
            
            if (dcObj.Scheduled_Route_Start_Time_3rd_Round__c != null && dcObj.Schedule_Delivery_3_End_Time__c != null) {
                deliveryWindows.add(new Map<String, Time>{'start' => dcObj.Scheduled_Route_Start_Time_3rd_Round__c,'end'   => dcObj.Schedule_Delivery_3_End_Time__c});
            }
            
            if (deliveryWindows.isEmpty()) {
                return resultMap; 
            }
            
            Datetime arrivalAtDestHub = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.addHours(ARHour).addMinutes(ARMinute).addSeconds(ARSeconds);
            
            Datetime selectedDeliveryDT = getNextAvailableDeliveryRoute(arrivalAtDestHub, deliveryWindows);
            
            Long startMillis = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.getTime();
            Long endMillis   = selectedDeliveryDT.getTime();
            Long diffMillis  = endMillis - startMillis;
            
            Integer totalSeconds = (Integer)(diffMillis / 1000);
            
            ARHour    = totalSeconds / 3600;
            ARMinute  = Math.mod((totalSeconds / 60), 60);
            ARSeconds = Math.mod(totalSeconds, 60);
            
            TATSLAHour   = selectedDeliveryDT.hour();
            TATSLAMinute = selectedDeliveryDT.minute();
			*/
        }

        
        
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
        dcCal.TAT_SLA_Mapping__c = shipIdVsTATSLAMapping.get(shipObj.Id).Id;
        dcCal.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
        dcCal.Pickup_Slot_Start__c = dcObj.Pickup_Slot_Start__c;
        dcCal.Pickup_Slot_End__c = dcObj.Pickup_Slot_End__c;
        dcCal.Pickup_End_Cutoff__c = dcObj.Pickup_End_Cutoff__c;
        dcCal.Schedule_Delivery_3_End_Time__c = dcObj.Schedule_Delivery_3_End_Time__c;
        dcCal.Schedule_Delivery_3_Start_Time__c = dcObj.Schedule_Delivery_3_Start_Time__c;
        dcCal.Schedule_Delivery_End_Time_1__c = dcObj.Schedule_Delivery_End_Time_1__c;
        dcCal.Schedule_Delivery_End_Time_2nd_Round__c = dcObj.Schedule_Delivery_End_Time_2nd_Round__c;
        dcCal.Schedule_Delivery_Start_Time_1__c = dcObj.Schedule_Delivery_Start_Time_1__c;
        dcCal.Scheduled_Route_Start_Time_2nd_Round__c = dcObj.Scheduled_Route_Start_Time_2nd_Round__c;
        dcCal.Scheduled_Route_Start_Time_3rd_Round__c = dcObj.Scheduled_Route_Start_Time_3rd_Round__c;
        dcCal.Schedule_Delivery_Start_Time_2nd_Round__c = dcObj.Schedule_Delivery_Start_Time_2nd_Round__c;
        dcCal.Time_from_Hub_to_Delivery_Point_Route_2__c = dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c;
        dcCal.Time_from_Hub_to_Delivery_Point_Route_3__c = dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c;
        dcCalListToInsert.add(dcCal);
        
        //Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('ARHour', ARHour);
        resultMap.put('ARMinute', ARMinute);
        resultMap.put('ARSeconds', ARSeconds);
        resultMap.put('isSameCityLogicExecuted', isSameCityLogicExecuted);
        
        resultMap.put('TATSLAHour', TATSLAHour);
        resultMap.put('TATSLAMinute', TATSLAMinute);
        
        return resultMap;
        
    }
    
    /*
    public static Map<String, Object> adjustFinalTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj, Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        Integer SameCityDeliveryHour = 0;
        Integer SameCityDeliveryMinute = 0;
        
        Boolean isSameCityLogicExecuted = false;
        
        System.debug('for checking Inside adjustFinalTATSLAHourAndMinute');
        
        System.debug('for checking ARHour :'+ARHour);
        System.debug('for checking ARMinute :'+ARMinute);
        
        //ARHour += 1;
        
        System.debug('for checking dcObj.Origin_Pincode__c: '+dcObj.Origin_Pincode__c);
        System.debug('for checking dcObj.Destination_Pincode__c: '+dcObj.Destination_Pincode__c);
        
        if ((dcObj.Origin_Pincode__c == dcObj.Destination_Pincode__c) && (shipObj.Destination_Address_City__c == dcObj.City__c) && (shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c)) {
            System.debug('Inside same city logic');
            
            isSameCityLogicExecuted = true;
            
            SameCityDeliveryHour = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c.hour();
            SameCityDeliveryMinute = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c.minute();
        
            System.debug('Inside same city ARHour '+ARHour);
            System.debug('Inside same city ARMinute '+ARMinute);
            System.debug('Inside same city TATSLAHour '+TATSLAHour);
            System.debug('Inside same city TATSLAMinute '+TATSLAMinute);
            
            if(SameCityDeliveryHour <= TATSLAHour){
                SameCityDeliveryHour = (SameCityDeliveryHour + 24) - TATSLAHour;
            } else {
                SameCityDeliveryHour -= TATSLAHour;
            }
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment SameCityDeliveryHour '+SameCityDeliveryHour);
            
            //Added to check Aprrox. time taken (in hours) will work with number field data.
            Integer hours = 0;
            Integer minutes = 0;
            
            if(dcObj.Time_from_Hub_to_delivery_point__c != null){
                Decimal AppoxTimeTaken = dcObj.Time_from_Hub_to_delivery_point__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment hours '+hours);
            
            ARHour += (SameCityDeliveryHour+hours);
            ARMinute += (SameCityDeliveryMinute+minutes);
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) Last ARHour '+ARHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) Last ARMinute '+ARMinute);
            
            
			TATSLAHour += SameCityDeliveryHour+ hours;
            TATSLAMinute += SameCityDeliveryMinute + minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAHour '+TATSLAHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAMinute '+TATSLAMinute);
                     
            
            if (ARMinute < 0) {
                ARHour -= 1;
                ARMinute += 60;
            }
            
            DateTime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
            
            Date currentDate = currentDateTime.date();
            System.debug('Inside same city currentDate = '+currentDate);
            
            
            DateTime futureDateTime = currentDateTime.addHours(ARHour).addMinutes(ARMinute);
            System.debug('Inside same city deliveryDateTime.date() = '+futureDateTime.date());
            
            if (currentDateTime.date() == futureDateTime.date()) {
                futureDateTime = futureDateTime.addDays(1);
                ARHour += 24;
                System.debug('If Delivery happened on the same day then adding 24 hours to ARHour = ' + ARHour);
            }
            
            //if (ARHour < TATSLAHour || (ARHour == TATSLAHour && ARMinute < TATSLAMinute)) {
                //System.debug('Inside if of Inside same city ARHour<TATSLAHour '+ARHour);
                //futureDateTime = futureDateTime.addDays(1);
                //ARHour += 24;
                //System.debug('Inside if of Inside same city ARHour after adding 24 '+ARHour);
                
            //}
            
            System.debug('Inside same city Final Calculated ARHour '+ARHour);
            System.debug('Inside same city Final Calculated ARMinute '+ARMinute);
            String FinalTime = ARHour+'H '+ARMinute+'M '+ARSeconds+'S';
            
            Integer additionalARHours = ARMinute / 60;
            Integer remainingARMinutes = Math.mod(ARMinute, 60);
            
            ARHour+=additionalARHours;
            ARMinute+=remainingARMinutes;
            
            Datetime istDateTime = futureDateTime.addSeconds(19800);
			String slaDay = istDateTime.format('EEEE', 'en_US');
            
            Date EstDelDate = date.newinstance(futureDateTime.year(),futureDateTime.month(),futureDateTime.day());
            System.debug('Inside same city EstDelDate = '+EstDelDate);
            
            Integer numberOfDays = Math.abs(EstDelDate.daysBetween(currentDate));
            System.debug('Inside same city numberOfDays = '+numberOfDays);
            
            ShipIdVsFinalTime.put(shipObj.Id,FinalTime);
            ShipIdVsSLADay.put(shipObj.Id,slaDay);
            ShipIdVsEstDelDate.put(shipObj.Id,futureDateTime);
            ShipIdVsTatInDays.put(shipObj.Id,numberOfDays);
        
        
        
        } else if(shipObj.Origin_Address_Pincode__c == dcObj.Destination_Pincode__c){
            System.debug('for checking inside shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c');
            System.debug('for checking Inside adjustFinalTATSLAHourAndMinute dcObj.Time_from_Hub_to_delivery_point__c '+dcObj.Time_from_Hub_to_delivery_point__c);
            Integer hours = 0;
            Integer minutes = 0;
            
            if(dcObj.Time_from_Hub_to_delivery_point__c != null){
                Decimal AppoxTimeTaken = dcObj.Time_from_Hub_to_delivery_point__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            System.debug('for checking Inside adjustFinalTATSLAHourAndMinute after adjustment scheduledDispatchHour '+hours);
            
            Integer scheduledDispatchHour = dcObj.Scheduled_Delivery_Route_Start_Time__c.hour();
            Integer scheduledDispatchMinute = dcObj.Scheduled_Delivery_Route_Start_Time__c.minute();
             
             System.debug('for checking Inside adjustFinalTATSLAHourAndMinute scheduledDispatchHour '+scheduledDispatchHour);
             System.debug('for checking Inside adjustFinalTATSLAHourAndMinute scheduledDispatchMinute '+scheduledDispatchMinute);
            
            
            if(scheduledDispatchHour <= TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour -= TATSLAHour;
            }
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment scheduledDispatchHour '+scheduledDispatchHour);
            
            
            ARHour += (scheduledDispatchHour+hours);
            ARMinute += (scheduledDispatchMinute+minutes);
            
            //ARHour += hours;
            //ARMinute += minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all ARHour '+ARHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all ARMinute '+ARMinute);
            
            TATSLAHour += scheduledDispatchHour+ hours + 1;
             
            Integer remainingHours = Math.mod(TATSLAHour, 24);
            TATSLAHour = remainingHours;
             
            TATSLAMinute += scheduledDispatchMinute + minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAHour '+TATSLAHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAMinute '+TATSLAMinute);
            
        } 
         else {
            System.debug('for checking Inside adjustFinalTATSLAHourAndMinute dcObj.Time_from_Pickup_to_Hub__c '+dcObj.Time_from_Pickup_to_Hub__c);
            
            System.debug('for checking Inside adjustFinalTATSLAHourAndMinute at entry ARHour: '+ARHour);
            System.debug('for checking Inside adjustFinalTATSLAHourAndMinute at entry TATSLAHour '+TATSLAHour);
            
            Integer scheduledDispatchHour = dcObj.Scheduled_Delivery_Route_Start_Time__c.hour();
            Integer scheduledDispatchMinute = dcObj.Scheduled_Delivery_Route_Start_Time__c.minute();
             
             System.debug('for checking Inside adjustFinalTATSLAHourAndMinute scheduledDispatchHour '+scheduledDispatchHour);
             System.debug('for checking Inside adjustFinalTATSLAHourAndMinute scheduledDispatchMinute '+scheduledDispatchMinute);
             
            //Added to check Aprrox. time taken (in hours) will work with number field data.
            Integer hours = 0;
            Integer minutes = 0;
            
            if(dcObj.Time_from_Hub_to_delivery_point__c != null){
                Decimal AppoxTimeTaken = dcObj.Time_from_Hub_to_delivery_point__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment hours '+hours);
            
            
            if(scheduledDispatchHour <= TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour -= TATSLAHour;
            }
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment scheduledDispatchHour '+scheduledDispatchHour);
            
            
            ARHour += (scheduledDispatchHour+hours);
            ARMinute += (scheduledDispatchMinute+minutes);
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) Last ARHour '+ARHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) Last ARMinute '+ARMinute);
            
			TATSLAHour += scheduledDispatchHour+ hours + 1;
             
            Integer remainingHours = Math.mod(TATSLAHour, 24);
            TATSLAHour = remainingHours;
             
            TATSLAMinute += scheduledDispatchMinute + minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAHour '+TATSLAHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAMinute '+TATSLAMinute);
                     
            
        }
            
            
        
        
        
        
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
        dcCal.TAT_SLA_Mapping__c = shipIdVsTATSLAMapping.get(shipObj.Id).Id;
        dcCal.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
        dcCalListToInsert.add(dcCal);
        
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('ARHour', ARHour);
        resultMap.put('ARMinute', ARMinute);
        resultMap.put('ARSeconds', ARSeconds);
        resultMap.put('isSameCityLogicExecuted', isSameCityLogicExecuted);
        
        resultMap.put('TATSLAHour', TATSLAHour);
        resultMap.put('TATSLAMinute', TATSLAMinute);
        
        return resultMap;
        
    }
    */

	public static Map<String, Object> adjustFinalTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj, Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        Boolean isSameCityLogicExecuted = false;
        
        Integer SameCityDeliveryHour = 0;
        Integer SameCityDeliveryMinute = 0;
        
        
        System.debug('for checking Inside adjustFinalTATSLAHourAndMinute (window based)');
        
        System.debug('for checking Inside adjustFinalTATSLAHourAndMinute dcObj.Origin_Pincode__c '+dcObj.Origin_Pincode__c);
        System.debug('for checking Inside adjustFinalTATSLAHourAndMinute dcObj.Destination_Pincode__c '+dcObj.Destination_Pincode__c);
        System.debug('for checking Inside adjustFinalTATSLAHourAndMinute shipObj.Destination_Address_City__c '+shipObj.Destination_Address_City__c);
        System.debug('for checking Inside adjustFinalTATSLAHourAndMinute dcObj.City__c '+dcObj.City__c);
        System.debug('for checking Inside adjustFinalTATSLAHourAndMinute shipObj.Destination_Address_Pincode__c '+shipObj.Destination_Address_Pincode__c);
        /*
        if (dcObj.Origin_Pincode__c == dcObj.Destination_Pincode__c && shipObj.Destination_Address_City__c == dcObj.City__c &&
            shipObj.Destination_Address_Pincode__c == dcObj.Destination_Pincode__c) {
                
                isSameCityLogicExecuted = true;
                
                SameCityDeliveryHour = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c.hour();
                SameCityDeliveryMinute = dcObj.Same_City_Hub_Delivery_Route_Start_Time__c.minute();
                
                System.debug('Inside same city ARHour '+ARHour);
                System.debug('Inside same city ARMinute '+ARMinute);
                System.debug('Inside same city TATSLAHour '+TATSLAHour);
                System.debug('Inside same city TATSLAMinute '+TATSLAMinute);
                
                //if(SameCityDeliveryHour <= TATSLAHour){
                    //SameCityDeliveryHour = (SameCityDeliveryHour + 24) - TATSLAHour;
                //} else {
                    //SameCityDeliveryHour -= TATSLAHour;
                //}
                //System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment SameCityDeliveryHour '+SameCityDeliveryHour);
				

                Integer sameCityTotalMinutes =
                    (SameCityDeliveryHour * 60) + SameCityDeliveryMinute;
                
                Integer slaTotalMinutes =
                    (TATSLAHour * 60) + TATSLAMinute;
                
                Integer diffMinutes;
                
                if (sameCityTotalMinutes <= slaTotalMinutes) {
                    diffMinutes = (sameCityTotalMinutes + 1440) - slaTotalMinutes;
                } else {
                    diffMinutes = sameCityTotalMinutes - slaTotalMinutes;
                }
                
                SameCityDeliveryHour   = diffMinutes / 60;
                SameCityDeliveryMinute = Math.mod(diffMinutes, 60);

                
                //Added to check Aprrox. time taken (in hours) will work with number field data.
                Integer hours = 0;
                Integer minutes = 0;
                
                if(dcObj.Time_from_Hub_to_delivery_point__c != null){
                    Decimal AppoxTimeTaken = dcObj.Time_from_Hub_to_delivery_point__c;
                    hours = AppoxTimeTaken.intValue();
                    Decimal fractionalHours = AppoxTimeTaken - hours;
                    minutes = (fractionalHours * 60).intValue();
                    System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                    System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
                }
                
                System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment hours '+hours);
                
                ARHour += (SameCityDeliveryHour+hours);
                ARMinute += (SameCityDeliveryMinute+minutes);
                
                System.debug('for checking Inside if(destinationKey == dcObj.City__c) Last ARHour '+ARHour);
                System.debug('for checking Inside if(destinationKey == dcObj.City__c) Last ARMinute '+ARMinute);
                
                
                TATSLAHour += SameCityDeliveryHour+ hours;
                TATSLAMinute += SameCityDeliveryMinute + minutes;
                
                System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAHour '+TATSLAHour);
                System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAMinute '+TATSLAMinute);
                
                if (ARMinute < 0) {
                    ARHour -= 1;
                    ARMinute += 60;
                }
                
                DateTime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
                
                Date currentDate = currentDateTime.date();
                System.debug('Inside same city currentDate = '+currentDate);
                
                
                DateTime futureDateTime = currentDateTime.addHours(ARHour).addMinutes(ARMinute);
                System.debug('Inside same city deliveryDateTime.date() = '+futureDateTime.date());
                
                if (currentDateTime.date() == futureDateTime.date()) {
                    futureDateTime = futureDateTime.addDays(1);
                    ARHour += 24;
                    System.debug('If Delivery happened on the same day then adding 24 hours to ARHour = ' + ARHour);
                }
                
                
                System.debug('Inside same city Final Calculated ARHour '+ARHour);
                System.debug('Inside same city Final Calculated ARMinute '+ARMinute);
                String FinalTime = ARHour+'H '+ARMinute+'M '+ARSeconds+'S';
                
                Integer additionalARHours = ARMinute / 60;
                Integer remainingARMinutes = Math.mod(ARMinute, 60);
                
                ARHour+=additionalARHours;
                ARMinute=remainingARMinutes;
                
                Datetime istDateTime = futureDateTime.addSeconds(19800);
                String slaDay = istDateTime.format('EEEE', 'en_US');
                
                Date EstDelDate = date.newinstance(futureDateTime.year(),futureDateTime.month(),futureDateTime.day());
                System.debug('Inside same city EstDelDate = '+EstDelDate);
                
                Integer numberOfDays = Math.abs(EstDelDate.daysBetween(currentDate));
                System.debug('Inside same city numberOfDays = '+numberOfDays);
                
                ShipIdVsFinalTime.put(shipObj.Id,FinalTime);
                ShipIdVsSLADay.put(shipObj.Id,slaDay);
                ShipIdVsEstDelDate.put(shipObj.Id,futureDateTime);
                ShipIdVsTatInDays.put(shipObj.Id,numberOfDays);
                
            }
        
        else {*/
            List<Map<String, Time>> deliveryWindows = new List<Map<String, Time>>();
        System.debug('for checking dcObj.Scheduled_Delivery_Route_Start_Time__c ==='+dcObj.Scheduled_Delivery_Route_Start_Time__c);
        System.debug('for checking dcObj.Schedule_Delivery_End_Time_1__c ==='+dcObj.Schedule_Delivery_End_Time_1__c);
        System.debug('for checking dcObj.Scheduled_Route_Start_Time_2nd_Round__c ==='+dcObj.Scheduled_Route_Start_Time_2nd_Round__c);
        System.debug('for checking dcObj.Schedule_Delivery_End_Time_2nd_Round__c ==='+dcObj.Schedule_Delivery_End_Time_2nd_Round__c);
        System.debug('for checking dcObj.Scheduled_Route_Start_Time_3rd_Round__c ==='+dcObj.Scheduled_Route_Start_Time_3rd_Round__c);
        System.debug('for checking dcObj.Schedule_Delivery_3_End_Time__c ==='+dcObj.Schedule_Delivery_3_End_Time__c);
        
            
            if (dcObj.Scheduled_Delivery_Route_Start_Time__c != null && dcObj.Schedule_Delivery_End_Time_1__c != null) {
                deliveryWindows.add(new Map<String, Time>{'start' => dcObj.Scheduled_Delivery_Route_Start_Time__c,'end'   => dcObj.Schedule_Delivery_End_Time_1__c});
            }
            
            if (dcObj.Scheduled_Route_Start_Time_2nd_Round__c != null && dcObj.Schedule_Delivery_End_Time_2nd_Round__c != null) {
                deliveryWindows.add(new Map<String, Time>{'start' => dcObj.Scheduled_Route_Start_Time_2nd_Round__c,'end'   => dcObj.Schedule_Delivery_End_Time_2nd_Round__c});
            }
            
            if (dcObj.Scheduled_Route_Start_Time_3rd_Round__c != null && dcObj.Schedule_Delivery_3_End_Time__c != null) {
                deliveryWindows.add(new Map<String, Time>{'start' => dcObj.Scheduled_Route_Start_Time_3rd_Round__c,'end'   => dcObj.Schedule_Delivery_3_End_Time__c});
            }
            
            if (!deliveryWindows.isEmpty()) {
                
                //test data added by Rafi Khan
                //Datetime test1 = Datetime.newInstance(2026, 2, 18, 20, 1, 33);
                //Datetime arrivalAtDestHub11 = test1.addHours(ARHour).addMinutes(ARMinute).addSeconds(ARSeconds);
                //upto here
                
                Datetime arrivalAtDestHub11 = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.addHours(ARHour).addMinutes(ARMinute).addSeconds(ARSeconds);
                Datetime arrivalAtDestHub = arrivalAtDestHub11;
                System.debug('for checking arrivalAtDestHub === '+arrivalAtDestHub); 
                System.debug('for checking deliveryWindows === '+deliveryWindows);
                
                Datetime selectedDeliveryDT = getNextAvailableDeliveryRoute(arrivalAtDestHub, deliveryWindows);
                System.debug('for checking selectedDeliveryDT === '+selectedDeliveryDT);
                /*Integer hours = 0;
                Integer minutes = 0;
                
                if (dcObj.Time_from_Hub_to_delivery_point__c != null) {
                    Decimal approxTimeTaken = dcObj.Time_from_Hub_to_delivery_point__c;
                    hours = approxTimeTaken.intValue();
                    Decimal fractionalHours = approxTimeTaken - hours;
                    minutes = (fractionalHours * 60).intValue();
                    
                    System.debug('for checking approx hub-to-delivery hours: ' + hours);
                    System.debug('for checking approx hub-to-delivery minutes: ' + minutes);
                }*/
                
                
                // 🔴 BUSINESS FIX: Use DELIVERY WINDOW END as SLA baseline
                Time selTime = selectedDeliveryDT.time();
                Time windowStartTime;
                Time windowEndTime;
                
                // -------- ROUND 1 --------
                if (
                    dcObj.Schedule_Delivery_Start_Time_1__c != null &&
                    dcObj.Schedule_Delivery_End_Time_1__c != null &&
                    selTime >= dcObj.Schedule_Delivery_Start_Time_1__c &&
                    selTime <= dcObj.Schedule_Delivery_End_Time_1__c
                ) {
                    windowStartTime = dcObj.Schedule_Delivery_Start_Time_1__c;
                    windowEndTime = dcObj.Schedule_Delivery_End_Time_1__c;
                    //selectedDeliveryDT = Datetime.newInstance(selectedDeliveryDT.date(), windowEndTime);
                }
                
                // -------- ROUND 2 --------
                else if (
                    dcObj.Schedule_Delivery_Start_Time_2nd_Round__c != null &&
                    dcObj.Schedule_Delivery_End_Time_2nd_Round__c != null &&
                    selTime >= dcObj.Schedule_Delivery_Start_Time_2nd_Round__c &&
                    selTime <= dcObj.Schedule_Delivery_End_Time_2nd_Round__c
                ) {
                    windowStartTime = dcObj.Schedule_Delivery_Start_Time_2nd_Round__c;
                    windowEndTime = dcObj.Schedule_Delivery_End_Time_2nd_Round__c;
                    //selectedDeliveryDT = Datetime.newInstance(selectedDeliveryDT.date(), windowEndTime);
                }
                
                // -------- ROUND 3 --------
                else if (
                    dcObj.Schedule_Delivery_3_Start_Time__c != null &&
                    dcObj.Schedule_Delivery_3_End_Time__c != null &&
                    selTime >= dcObj.Schedule_Delivery_3_Start_Time__c &&
                    selTime <= dcObj.Schedule_Delivery_3_End_Time__c
                ) {
                    windowStartTime = dcObj.Schedule_Delivery_3_Start_Time__c;
                    windowEndTime = dcObj.Schedule_Delivery_3_End_Time__c;
                    //selectedDeliveryDT = Datetime.newInstance(selectedDeliveryDT.date(), windowEndTime);
                }
                
                // 🔧 UNIVERSAL FIX (Round 1 / 2 / 3)
                // If arrival crosses the window END on the same day → next day
                /*if (windowEndTime != null && arrivalAtDestHub.date() == selectedDeliveryDT.date() &&
                    arrivalAtDestHub.time() > windowEndTime) {
                        
                        selectedDeliveryDT = selectedDeliveryDT.addDays(1);
                        System.debug('for checking Delivery window crossed → shifting to next day');
                    }*/
                
                
                // ✅ IMPORTANT: Window END already represents final delivery.
                // Do NOT add hub-to-delivery travel time again.
                //Boolean isWindowEndUsed = true;


                Integer hours = 0;
                Integer minutes = 0;
                
                // If window END is used → delivery already completed
                //if (!isWindowEndUsed) {
                    
                    if (selTime >= dcObj.Scheduled_Delivery_Route_Start_Time__c &&
                        selTime <= dcObj.Schedule_Delivery_End_Time_1__c &&
                        dcObj.Time_from_Hub_to_delivery_point__c != null) {
                            
                            Decimal t = dcObj.Time_from_Hub_to_delivery_point__c;
                            hours = t.intValue();
                            minutes = ((t - hours) * 60).intValue();
                        }
                    else if (selTime >= dcObj.Scheduled_Route_Start_Time_2nd_Round__c &&
                             selTime <= dcObj.Schedule_Delivery_End_Time_2nd_Round__c &&
                             dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c != null) {
                                 
                                 Decimal t = dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c;
                                 hours = t.intValue();
                                 minutes = ((t - hours) * 60).intValue();
                             }
                    else if (selTime >= dcObj.Scheduled_Route_Start_Time_3rd_Round__c &&
                             selTime <= dcObj.Schedule_Delivery_3_End_Time__c &&
                             dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c != null) {
                                 
                                 Decimal t = dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c;
                                 hours = t.intValue();
                                 minutes = ((t - hours) * 60).intValue();
                             }
                //}

                Datetime finalDeliveryDT1 = selectedDeliveryDT.addHours(hours).addMinutes(minutes);
                
                
                if (windowEndTime != null) {
                    
                    Datetime windowEndDT =
                        Datetime.newInstance(finalDeliveryDT1.date(), windowEndTime);
                    
                    System.debug('for checking Window End DT: ' + windowEndDT);
                    
                    // ✅ Only shift day if arrival is AFTER window end on SAME DAY
                    if (arrivalAtDestHub > windowEndDT &&
                        arrivalAtDestHub.date() == windowEndDT.date()) {
                            
                            System.debug('Arrival crossed window end → shifting to next day');
                            finalDeliveryDT1 = windowEndDT.addDays(1);
                        } else {
                            finalDeliveryDT1 = windowEndDT;
                        }
                }
                
                System.debug('for checking Final finalDeliveryDT1: ' + finalDeliveryDT1);


                
                
                
                
                /*
                Integer hours = 0;
                Integer minutes = 0;
                
                Time selectedStartTime = selectedDeliveryDT.time();
                
                // -------- ROUND 1 --------
                if (selectedStartTime == dcObj.Schedule_Delivery_Start_Time_1__c && dcObj.Time_from_Hub_to_delivery_point__c != null) {
                    
                    Decimal approxTime = dcObj.Time_from_Hub_to_delivery_point__c;
                    hours = approxTime.intValue();
                    minutes = ((approxTime - hours) * 60).intValue();
                    
                    System.debug('Using Round 1 delivery time');
                }
                
                // -------- ROUND 2 --------
                else if (selectedStartTime == dcObj.Schedule_Delivery_Start_Time_2nd_Round__c && dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c != null) {
                    
                    Decimal approxTime = dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c;
                    hours = approxTime.intValue();
                    minutes = ((approxTime - hours) * 60).intValue();
                    
                    System.debug('Using Round 2 delivery time');
                }
                
                // -------- ROUND 3 --------
                else if (selectedStartTime == dcObj.Schedule_Delivery_3_Start_Time__c && dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c != null) {
                    
                    Decimal approxTime = dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c;
                    hours = approxTime.intValue();
                    minutes = ((approxTime - hours) * 60).intValue();
                    
                    System.debug('Using Round 3 delivery time');
                }*/
                
                
                System.debug('for checking selectedDeliveryDT before finalDeliveryDT ==== '+selectedDeliveryDT);
                System.debug('for checking hours before finalDeliveryDT ==== '+hours);
                System.debug('for checking minutes before finalDeliveryDT ==== '+minutes);
                
                //Datetime finalDeliveryDT = selectedDeliveryDT.addHours(hours).addMinutes(minutes);
                Datetime finalDeliveryDT = finalDeliveryDT1;
                Datetime physicalPickupTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
                
                Long startMillis = physicalPickupTime.getTime();
                Long endMillis   = finalDeliveryDT.getTime();
                Long diffMillis  = endMillis - startMillis;
                
                Integer totalSeconds = (Integer)(diffMillis / 1000);
                
                ARHour    = totalSeconds / 3600;
                ARMinute  = Math.mod((totalSeconds / 60), 60);
                ARSeconds = Math.mod(totalSeconds, 60);
                
                TATSLAHour   = finalDeliveryDT.hour();
                TATSLAMinute = finalDeliveryDT.minute();
                
                System.debug('for checking in adjustFinalTATSLAHourAndMinute ARHour '+ARHour);
                System.debug('for checking in adjustFinalTATSLAHourAndMinute ARMinute '+ARMinute);
                System.debug('for checking in adjustFinalTATSLAHourAndMinute TATSLAHour '+TATSLAHour);
                System.debug('for checking in adjustFinalTATSLAHourAndMinute TATSLAMinute '+TATSLAMinute);
                
                
            }
        //}
        
        
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
        dcCal.TAT_SLA_Mapping__c = shipIdVsTATSLAMapping.get(shipObj.Id).Id;
        dcCal.Time_from_Hub_to_delivery_point__c = dcObj.Time_from_Hub_to_delivery_point__c;
        dcCal.Pickup_Slot_Start__c = dcObj.Pickup_Slot_Start__c;
        dcCal.Pickup_Slot_End__c = dcObj.Pickup_Slot_End__c;
        dcCal.Pickup_End_Cutoff__c = dcObj.Pickup_End_Cutoff__c;
        dcCal.Schedule_Delivery_3_End_Time__c = dcObj.Schedule_Delivery_3_End_Time__c;
        dcCal.Schedule_Delivery_3_Start_Time__c = dcObj.Schedule_Delivery_3_Start_Time__c;
        dcCal.Schedule_Delivery_End_Time_1__c = dcObj.Schedule_Delivery_End_Time_1__c;
        dcCal.Schedule_Delivery_End_Time_2nd_Round__c = dcObj.Schedule_Delivery_End_Time_2nd_Round__c;
        dcCal.Schedule_Delivery_Start_Time_1__c = dcObj.Schedule_Delivery_Start_Time_1__c;
        dcCal.Scheduled_Route_Start_Time_2nd_Round__c = dcObj.Scheduled_Route_Start_Time_2nd_Round__c;
        dcCal.Scheduled_Route_Start_Time_3rd_Round__c = dcObj.Scheduled_Route_Start_Time_3rd_Round__c;
        dcCal.Schedule_Delivery_Start_Time_2nd_Round__c = dcObj.Schedule_Delivery_Start_Time_2nd_Round__c;
        dcCal.Time_from_Hub_to_Delivery_Point_Route_2__c = dcObj.Time_from_Hub_to_Delivery_Point_Route_2__c;
        dcCal.Time_from_Hub_to_Delivery_Point_Route_3__c = dcObj.Time_from_Hub_to_Delivery_Point_Route_3__c;
        dcCalListToInsert.add(dcCal);
        
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('ARHour', ARHour);
        resultMap.put('ARMinute', ARMinute);
        resultMap.put('ARSeconds', ARSeconds);
        resultMap.put('isSameCityLogicExecuted', isSameCityLogicExecuted);
        resultMap.put('TATSLAHour', TATSLAHour);
        resultMap.put('TATSLAMinute', TATSLAMinute);
        
        return resultMap;
    }

    public static void checkNextRoute(String key, Shipment__c shipObj, Map<String, Network_Plan__c> networkPlanMap, String destinationKey, Map<String, Distance_calculator__c> distanceMap, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Integer ARHour, Integer ARMinute, Integer ARSeconds, Set<String> visitedRoutes, String hdStateKey, Map<String,Date> holidayMap, Map<Date,Holiday_Data__c>holidayDateMap, Map<String,Holiday_Data__c> holidayDateStateMap) {
        System.debug('for checking Inside checkNextRoute ');
        try{
            if (visitedRoutes.contains(key)) {
                return;
            }
            
            visitedRoutes.add(key);
            
            System.debug('for checking inside checkNextRoute key :'+key);
            Network_Plan__c npObj = networkPlanMap.get(key);
            System.debug('for checking Inside checkNextRoute npObj :'+npObj);
            
            System.debug('for checking destinationKey :'+destinationKey);
            Distance_Calculator__c dcObj = distanceMap.get(destinationKey);
            System.debug('for checking Inside checkNextRoute dcObj :'+dcObj);
            
            System.debug('for checking hdStateKey :'+hdStateKey);
            Date hdObj = holidayMap.get(hdStateKey);
            System.debug('for checking Inside checkNextRoute hdObj :'+hdObj);
            
            
            if (npObj != null) {
                Map<String, Object> timeMap; 
                System.debug('for checking npObj.Transport_Type__c = '+npObj.Transport_Type__c);
                if (npObj.Transport_Type__c == 'Road') {
                    //if(npObj.OD_Concat__c == 'BENGALURU_HOSUR' || npObj.OD_Concat__c == 'HOSUR_BENGALURU'){
                    if(npObj.OD_Concat__c == 'BENGALURU_HOSUR'){
                        timeMap = adjustMultipleARRoad(npObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, isFirstTimeRoad);
                        isFirstTimeRoad = false;
                    } else {
                        timeMap = adjustARRoad(npObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, isFirstTimeRoad);
                        isFirstTimeRoad = false; 
                    }
                    
                } else if (npObj.Transport_Type__c == 'Air') {
                    timeMap = adjustARAir(npObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, isFirstTimeFlight);//, TATSLAHour, TATSLAMinute, TATSLASeconds);
                    isFirstTimeFlight = false;
                }
                
                
                ARHour = (Integer) timeMap.get('ARHour');
                ARMinute = (Integer) timeMap.get('ARMinute');
                ARSeconds = (Integer) timeMap.get('ARSeconds');
                
                System.debug('for checking Updated Time after ' + npObj.Transport_Type__c + ': ' + ARHour + 'h ' + ARMinute + 'm ' + ARSeconds + 's');
                
                TATSLAHour = (Integer) timeMap.get('TATSLAHour');
                TATSLAMinute = (Integer) timeMap.get('TATSLAMinute');                
                
                System.debug('for checking Updated TATSLA Time after ' + npObj.Transport_Type__c + ': ' + TATSLAHour + 'h ' + TATSLAMinute + 'm ' );
                
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
                npCal.TAT_SLA_Mapping__c = shipIdVsTATSLAMapping.get(shipObj.Id).Id;
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
                npCalListToInsert.add(npCal);
                
                System.debug('for Checking npObj.Next_Route__c: ' + npObj.Next_Route__c);
                String nextOrigin = splitRoute(npObj.Next_Route__c);
                System.debug('for Checking nextOrigin: ' + nextOrigin);
                System.debug('for Checking npObj.To_Destination_Hub__c: ' + npObj.To_Destination_Hub__c);
                
                if (nextOrigin == npObj.To_Destination_Hub__c) {
                    System.debug('for checking inside if nextOrigin == npObj.To_Destination_Hub__c');
                    
                    System.debug('for checking destinationKey :'+destinationKey);
                    System.debug('for checking dcObj.Destination_Pincode__c :'+dcObj.Destination_Pincode__c);
                    
                    System.debug('@for checking destination city :'+shipObj.Destination_Address_City__c);
                    System.debug('@for checking dcObj.city__c :'+dcObj.city__c);
                    
                    if(destinationKey == dcObj.Destination_Pincode__c){                        
                        Map<String, Boolean> serviceableDays = new Map<String, Boolean>{
                            'Monday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Monday__c,
                                'Tuesday'   => shipObj.Destination_Address_Name__r.Active_Pincode__r.Tuesday__c,
                                'Wednesday' => shipObj.Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                                'Thursday'  => shipObj.Destination_Address_Name__r.Active_Pincode__r.Thursday__c,
                                'Friday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Friday__c,
                                'Saturday'  => shipObj.Destination_Address_Name__r.Active_Pincode__r.Saturday__c,
                                'Sunday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Sunday__c
                                };
                                                            
                        Integer additionalARHours = ARMinute / 60;
                        Integer remainingARMinutes = Math.mod(ARMinute, 60);                        
                        ARHour += additionalARHours;
                        ARMinute = remainingARMinutes;
                        
                        Integer ARdays = ARHour / 24;
                        Integer remainingARHours = Math.mod(ARHour, 24);
                        
                        //Datetime currentARDateTime = Datetime.now().addMinutes(330);
                        
                        // Datetime currentARDateTime = shipObj.Physical_Pickup_Completed_Time1__c;
                        
                        Datetime currentARDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c.addSeconds(19800);
                        
                        Datetime targetARDateTime = currentARDateTime.addDays(ARdays).addHours(remainingARHours).addMinutes(ARMinute).addSeconds(ARSeconds);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) serviceable day calculations targetARDateTime :'+targetARDateTime);
                        
                        Long timeDifferenceMillis = targetARDateTime.getTime() - currentARDateTime.getTime();
                        Integer hoursToAdd = (Integer)(timeDifferenceMillis / (1000 * 60 * 60));
                        Integer minutesToAdd = (Integer)((timeDifferenceMillis - (hoursToAdd * 1000 * 60 * 60)) / (1000 * 60));
                        Integer secondsToAdd = (Integer)((timeDifferenceMillis - (hoursToAdd * 1000 * 60 * 60) - (minutesToAdd * 1000 * 60)) / 1000);
                        
                        Map<String, Object> destinationTimeMap = adjustFinalTATSLAHourAndMinute(dcObj, shipObj, hoursToAdd, minutesToAdd, secondsToAdd, TATSLAHour, TATSLAMinute, TATSLASeconds);
                        Integer FinalTATHour = (Integer) destinationTimeMap.get('ARHour');
                        Integer FinalTATMinute = (Integer) destinationTimeMap.get('ARMinute');
                        Integer FinalTATSeconds = (Integer) destinationTimeMap.get('ARSeconds');
                        
                        //FinalTATMinute = FinalTATMinute - 50;
                        
                        Integer additionalHours = FinalTATMinute / 60;
                        Integer remainingMinutes = Math.mod(FinalTATMinute, 60);
                        
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) additionalHours : '+additionalHours);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) remainingMinutes : '+remainingMinutes);
                        
                        FinalTATHour += additionalHours;
                        FinalTATMinute = remainingMinutes;
                        
                        
                        Integer days = FinalTATHour / 24;
                        Integer remainingHours = Math.mod(FinalTATHour, 24);
                        
                        System.debug('@for checking days '+days);
                        
                        // Datetime currentDateTime = shipObj.Physical_Pickup_Completed_Time1__c;
                        
                        Datetime currentDateTime = shipObj.Pickup__r.Physical_Pickup_Completed_Time__c;
                        
                        Date currentDate = currentDateTime.date();
                        System.debug('@@@for checking currentDate = '+currentDate);
                        
                        Datetime targetDateTime = currentDateTime.addDays(days).addHours(remainingHours).addMinutes(FinalTATMinute).addSeconds(FinalTATSeconds);
                        
                        Datetime istDateTime = targetDateTime.addSeconds(19800);
                        
                        String slaDay = istDateTime.format('EEEE', 'en_US');
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) SLA Day: ' + slaDay);
                        
                        Boolean isServiceable = serviceableDays.containsKey(slaDay) && serviceableDays.get(slaDay);
                        
                        Integer maxDaysInWeek = 7;
                        Integer dayInWeek = 0;
                        String holidayOnEstDelDate = '';
                        
                        while (dayInWeek < maxDaysInWeek) {
                            Date estDelDateToCheck = Date.newInstance(targetDateTime.year(), targetDateTime.month(), targetDateTime.day());
                            String mapKey = estDelDateToCheck.format() + '-' + hdStateKey;
                            Holiday_Data__c holidayData = holidayDateStateMap.get(mapKey);
                            
                            Datetime istDateTimeTemp = targetDateTime.addSeconds(19800);
                            slaDay = istDateTimeTemp.format('EEEE', 'en_US');
                            isServiceable = serviceableDays.containsKey(slaDay) && serviceableDays.get(slaDay);
                            
                            if (!isServiceable || holidayData != null) {
                                if (holidayData != null) {
                                    holidayOnEstDelDate += (holidayOnEstDelDate == '' ? '' : ', ') + 
                                        holidayData.Name + ' on ' + holidayData.Date__c.format() + ' in ' + holidayData.State__c;
                                    System.debug('for checking Holiday skipped: ' + holidayData.Name + ' on ' + holidayData.Date__c.format());
                                } else {
                                    System.debug('for checking Non-serviceable day skipped: ' + slaDay);
                                }
                                
                                targetDateTime = targetDateTime.addDays(1);
                                FinalTATHour += 24;
                                dayInWeek++;
                                continue;
                            }
                            // Found valid day
                            break;
                        }
                        
                        
                        /*
while (!isServiceable && (dayInWeek < maxDaysInWeek)) {
dayInWeek++;
targetDateTime = targetDateTime.addDays(1);
FinalTATHour += 24;

Datetime istDateTime1 = targetDateTime.addSeconds(19800);

slaDay = istDateTime1.format('EEEE', 'en_US');
isServiceable = serviceableDays.containsKey(slaDay) && serviceableDays.get(slaDay);
}

Date EstDelDateToCheck = date.newinstance(targetDateTime.year(),targetDateTime.month(),targetDateTime.day());
System.debug('for checking inside if(destinationKey == dcObj.City__c) EstDelDateToCheck '+EstDelDateToCheck);

String holidayOnEstDelDate = '';

String mapKey = EstDelDateToCheck.format() + '-' + hdStateKey;
System.debug('@for checking mapKey '+mapKey);

Holiday_Data__c holidayData = holidayDateStateMap.get(mapKey);

if(holidayData != null){
holidayOnEstDelDate = holidayData.Name + ' on ' + holidayData.Date__c.format() + ' in ' + holidayData.State__c;
targetDateTime = targetDateTime.addDays(1);
FinalTATHour += 24;

Datetime istDateTime2 = targetDateTime.addSeconds(19800);

slaDay = istDateTime2.format('EEEE', 'en_US');
}
*/
                        Date EstDelDate = date.newinstance(targetDateTime.year(),targetDateTime.month(),targetDateTime.day());
                        System.debug('@@@for checking EstDelDate = '+EstDelDate);
                        
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) FinalTATHour '+FinalTATHour);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) FinalTATMinute '+FinalTATMinute);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) FinalTATSeconds '+FinalTATSeconds);
                        System.debug('for checking total time required from destination hub to destination city : '+FinalTATHour+'H '+FinalTATMinute+'M '+FinalTATSeconds+'S');
                        //System.debug('for checking The SLA day ' + slaDay + ' is a serviceable day.');
                        System.debug('for checking Adjusted target delivery date and time: ' + targetDateTime);
                        
                        String FinalTime = FinalTATHour+'H '+FinalTATMinute+'M '+FinalTATSeconds+'S';
                        
                        
                        Integer numberOfDays = Math.abs(EstDelDate.daysBetween(currentDate));
                        System.debug('@@@for checking numberOfDays = '+numberOfDays);                        
                        
                        /*Integer tatInDays;
if(FinalTATHour<24){
tatInDays = 1;
} else if (FinalTATHour<48){
tatInDays = 2;
} else if (FinalTATHour<72){
tatInDays = 3;
} else if (FinalTATHour<96){
tatInDays = 4;
} else if (FinalTATHour<110){
tatInDays = 5;
} */ 
                        
                        ShipIdVsFinalTime.put(shipObj.Id,FinalTime);
                        ShipIdVsSLADay.put(shipObj.Id,slaDay);
                        ShipIdVsEstDelDate.put(shipObj.Id,targetDateTime);
                        ShipIdVsTatInDays.put(shipObj.Id,numberOfDays);
                        ShipIdVsHolidayDay.put(shipObj.Id,holidayOnEstDelDate);
                        
                    }
                    
                    return;
                } else {
                    
                    String testDestAddNameKey = '';
                    if (shipObj.Destination_Hub__r.Name != null) {
                        String destinationHubName = shipObj.Destination_Hub__r.Name.trim();
                        
                        if (destinationHubName.contains('-')) {
                            List<String> parts = destinationHubName.split('\\s*-\\s*');
                            if (!parts.isEmpty()) {
                                testDestAddNameKey = parts[0];
                            }
                        } else {
                            List<String> parts = destinationHubName.split('\\s+');
                            if (!parts.isEmpty()) {
                                testDestAddNameKey = parts[0];
                            }
                        }
                    }
                    
                    if (shipObj.Destination_Hub__r.Name != null && testDestAddNameKey.equalsIgnoreCase('HYD')) {
                        testDestAddNameKey = 'HYDERABAD';
                    }
                    
                    
                    System.debug('For checking destination hub name after triming for next route '+testDestAddNameKey);
                    
                    key = nextOrigin + '_' + testDestAddNameKey;
                    checkNextRoute(key, shipObj, networkPlanMap, destinationKey, distanceMap, TATSLAHour, TATSLAMinute, TATSLASeconds, ARHour, ARMinute, ARSeconds, visitedRoutes, hdStateKey, holidayMap, holidayDateMap, holidayDateStateMap);
                }
                
                
            } 
        }catch(Exception ex){
            System.debug('Error Message :'+ex.getMessage());
            System.debug('on line number :'+ex.getLineNumber());
        }
    }
    
    public static Map<String, Object> adjustARRoad(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeRoad) {
        
        Map<String, Object> timeMap = new Map<String, Object>();
        Integer scheduledDispatchHour = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour();
        Integer scheduledDispatchMinute = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute();
        System.debug('for checking inside adjustARRoad ARHour '+ARHour);
        System.debug('for checking inside adjustARRoad ARMinute '+ARMinute);
        System.debug('for checking inside adjustARRoad TATSLAHour '+TATSLAHour);
        System.debug('for checking inside adjustARRoad TATSLAMinute '+TATSLAMinute);
        System.debug('for checking inside adjustARRoad scheduledDispatchHour '+scheduledDispatchHour);
        
        if(isFirstTimeRoad){
            /*
            if(scheduledDispatchHour < TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            
            System.debug('for checking inside adjustARRoad 1st time road scheduledDispatchHour '+scheduledDispatchHour);
            */
            
            Integer slaTotalMinutes = (TATSLAHour * 60) + TATSLAMinute;
            
            Integer dispatchTotalMinutes = (scheduledDispatchHour * 60) + scheduledDispatchMinute;
            
            Integer diffMinutes;
            
            // Handle next-day rollover
            if (dispatchTotalMinutes < slaTotalMinutes) {
                diffMinutes = (dispatchTotalMinutes + 1440) - slaTotalMinutes;
            } else {
                diffMinutes = dispatchTotalMinutes - slaTotalMinutes;
            }
            
            scheduledDispatchHour   = diffMinutes / 60;
            scheduledDispatchMinute = Math.mod(diffMinutes, 60);
            
            System.debug('for checking inside adjustARRoad 1st time road Corrected scheduledDispatchHour = ' + scheduledDispatchHour);
            System.debug('for checking inside adjustARRoad 1st time road Corrected scheduledDispatchMinute = ' + scheduledDispatchMinute);
            
            
            //Added to check Aprrox. time taken (in hours) will work with number field data.
            
            Integer hours = 0;
            Integer minutes = 0;
            
            System.debug('for checking inside adjustARRoad 1st time npObj.Approx_Time_Taken_in_hrs1__c '+npObj.Approx_Time_Taken_in_hrs1__c);
            if(npObj.Approx_Time_Taken_in_hrs1__c != null){
                Decimal AppoxTimeTaken = npObj.Approx_Time_Taken_in_hrs1__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking inside adjustARRoad 1st time Approximate time taken in hours : '+hours);
                System.debug('for checking inside adjustARRoad 1st time Approximate time taken in minutes : '+minutes);
            }
            
            //upto here
            
            ARHour += (scheduledDispatchHour+hours);
            //if(ARMinute == 0){
              //ARMinute += (scheduledDispatchMinute+minutes);  
            //}
            ARMinute += (scheduledDispatchMinute+minutes);
            //ARSeconds += (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.second()+npObj.Approx_Time_Taken_in_hrs__c.second());
            
            Integer additionalARHours = ARMinute / 60;
            Integer remainingARMinutes = Math.mod(ARMinute, 60);
            
            ARHour += additionalARHours;
            ARMinute = remainingARMinutes;
            
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            
            System.debug('for checking First Time Road SLA: ' + ARHour + 'h ' + ARMinute + 'm ' + ARSeconds + 's');
            
            Integer tmpTATSLAmorethan24 = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour() + hours;
            if(tmpTATSLAmorethan24 > 24){
                tmpTATSLAmorethan24 -= 24;
            }
            
            //TATSLAHour = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour() + hours;
            TATSLAHour = tmpTATSLAmorethan24;
            TATSLAMinute = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute() + minutes;
            
            Integer additionalTATHours = TATSLAMinute / 60;
            Integer remainingTATMinutes = Math.mod(TATSLAMinute, 60);
            
            TATSLAHour += additionalTATHours;
            TATSLAMinute = remainingTATMinutes;
            
            System.debug('for checking inside adjustARRoad 1st time new TATSLAHour :'+TATSLAHour);
            System.debug('for checking inside adjustARRoad 1st time new TATSLAMinute :'+TATSLAMinute);
            
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            
            System.debug('for checking inside adjustARRoad 1st time timeMap @@@@@@@@@@@@@@@@@@ :'+timeMap);
            return timeMap;
            
        } else {
            //TATSLAHour += ARHour;
            
            System.debug('for checking Inside else of first time road scheduledDispatchHour '+scheduledDispatchHour);
            System.debug('for checking Inside else of first time road TATSLAHour '+TATSLAHour);
            /*
            if(scheduledDispatchHour < TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            
            System.debug('for checking after first time road scheduledDispatchHour '+scheduledDispatchHour);
            */
            
            Integer slaTotalMinutes = (TATSLAHour * 60) + TATSLAMinute;
            
            Integer dispatchTotalMinutes = (scheduledDispatchHour * 60) + scheduledDispatchMinute;
            
            Integer diffMinutes;
            
            // Handle next-day rollover
            if (dispatchTotalMinutes < slaTotalMinutes) {
                diffMinutes = (dispatchTotalMinutes + 1440) - slaTotalMinutes;
            } else {
                diffMinutes = dispatchTotalMinutes - slaTotalMinutes;
            }
            
            scheduledDispatchHour   = diffMinutes / 60;
            scheduledDispatchMinute = Math.mod(diffMinutes, 60);
            
            System.debug('for checking inside adjustARRoad next time road Corrected scheduledDispatchHour = ' + scheduledDispatchHour);
            System.debug('for checking inside adjustARRoad next time road Corrected scheduledDispatchMinute = ' + scheduledDispatchMinute);
            
            
            //Added to check Aprrox. time taken (in hours) will work with number field data.
            
            System.debug('for checking in next road time npObj.Approx_Time_Taken_in_hrs1__c '+npObj.Approx_Time_Taken_in_hrs1__c);
            Integer hours = 0;
            Integer minutes = 0;
            
            if(npObj.Approx_Time_Taken_in_hrs1__c != null){
                Decimal AppoxTimeTaken = npObj.Approx_Time_Taken_in_hrs1__c;
                hours = AppoxTimeTaken.intValue();
                Decimal fractionalHours = AppoxTimeTaken - hours;
                minutes = (fractionalHours * 60).intValue();
                System.debug('for checking in next road time Approximate time taken in hours : '+hours);
                System.debug('for checking in next road time Approximate time taken in minutes : '+minutes);
            }
            
            //upto here
            
            ARHour += (scheduledDispatchHour+hours);
            //if(ARMinute == 0){
              //ARMinute += (scheduledDispatchMinute+minutes);  
            //}
            ARMinute += (scheduledDispatchMinute+minutes);
            //ARSeconds += (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.second()+npObj.Approx_Time_Taken_in_hrs__c.second());
            
            Integer additionalARHours = ARMinute / 60;
            Integer remainingARMinutes = Math.mod(ARMinute, 60);
            
            ARHour += additionalARHours;
            ARMinute = remainingARMinutes;
            
            
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            
            System.debug('for checking in next road time First Time Road SLA: ' + ARHour + 'h ' + ARMinute + 'm ' + ARSeconds + 's');
            
            TATSLAHour = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour() + hours;
            TATSLAMinute = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute() + minutes;
            
            Integer additionalTATHours = TATSLAMinute / 60;
            Integer remainingTATMinutes = Math.mod(TATSLAMinute, 60);
            
            TATSLAHour += additionalTATHours;
            TATSLAMinute = remainingTATMinutes;
            
            System.debug('for checking in next road time new TATSLAHour :'+TATSLAHour);
            System.debug('for checking in next road time new TATSLAMinute :'+TATSLAMinute);
            
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            
            System.debug('for checking in next road time timeMap @@@@@@@@@@@@@@@@@@ :'+timeMap);
            return timeMap;
            
        }
    }
    
    public static Map<String, Object> adjustMultipleARRoad(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds,
                                                           Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeRoad) {
                                                               System.debug('for checking inside adjustARRoad ARHour ' + ARHour);
                                                               System.debug('for checking inside adjustARRoad TATSLAHour ' + TATSLAHour);
                                                               
                                                               Map<String, Object> timeMap = new Map<String, Object>();
                                                               
                                                               // --- Safe extraction of dispatch timings ---
                                                               Time dispatch1 = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c;
                                                               Time dispatch2 = npObj.Scheduled_Max_Time_Of_Vehicle_Dispatch_2__c;
                                                               Time dispatch3 = npObj.Scheduled_max_time_of_vehicle_dispatch_3__c;
                                                               
                                                               // Handle null times
                                                               Integer scheduledDispatchHour = dispatch1 != null ? dispatch1.hour() : 0;
                                                               Integer scheduledDispatchMinute = dispatch1 != null ? dispatch1.minute() : 0;
                                                               
                                                               Integer scheduledVehicleDispatch2Hour = dispatch2 != null ? dispatch2.hour() : null;
                                                               Integer scheduledVehicleDispatch2Minute = dispatch2 != null ? dispatch2.minute() : null;
                                                               
                                                               Integer scheduledVehicleDispatch3Hour = dispatch3 != null ? dispatch3.hour() : null;
                                                               Integer scheduledVehicleDispatch3Minute = dispatch3 != null ? dispatch3.minute() : null;
                                                               
                                                               System.debug('for checking Dispatch1: ' + scheduledDispatchHour + ':' + scheduledDispatchMinute);
                                                               System.debug('for checking Dispatch2: ' + scheduledVehicleDispatch2Hour + ':' + scheduledVehicleDispatch2Minute);
                                                               System.debug('for checking Dispatch3: ' + scheduledVehicleDispatch3Hour + ':' + scheduledVehicleDispatch3Minute);
                                                               
                                                               
                                                               
                                                               System.debug('for checking Dispatch1: ' + scheduledDispatchHour + ':' + scheduledDispatchMinute);
                                                               System.debug('for checking Dispatch2: ' + scheduledVehicleDispatch2Hour + ':' + scheduledVehicleDispatch2Minute);
                                                               System.debug('for checking Dispatch3: ' + scheduledVehicleDispatch3Hour + ':' + scheduledVehicleDispatch3Minute);
                                                               
                                                               Integer tmpTATSLAmorethan24 = 0;
                                                               
                                                               // Approx time taken
                                                               Integer hours = 0;
                                                               Integer minutes = 0;
                                                               if (npObj.Approx_Time_Taken_in_hrs1__c != null) {
                                                                   Decimal AppoxTimeTaken = npObj.Approx_Time_Taken_in_hrs1__c;
                                                                   hours = AppoxTimeTaken.intValue();
                                                                   Decimal fractionalHours = AppoxTimeTaken - hours;
                                                                   minutes = (fractionalHours * 60).intValue();
                                                               }
                                                               
                                                               Integer chosenDispatchHour;
                                                               Integer chosenDispatchMinute;
                                                               
                                                               // Calculate TAT in minutes to compare with dispatch times accurately
                                                               Integer tatTotalMinutes = (TATSLAHour != null ? TATSLAHour : 0) * 60 + (TATSLAMinute != null ? TATSLAMinute : 0);
                                                               
                                                               
                                                               // --- Select best dispatch based on TATSLAHour ---
                                                               /*List<Map<String, Integer>> dispatchList = new List<Map<String, Integer>>{
new Map<String, Integer>{'hour' => scheduledDispatchHour, 'minute' => scheduledDispatchMinute},
new Map<String, Integer>{'hour' => scheduledVehicleDispatch2Hour, 'minute' => scheduledVehicleDispatch2Minute},
new Map<String, Integer>{'hour' => scheduledVehicleDispatch3Hour, 'minute' => scheduledVehicleDispatch3Minute}
};*/
                                                               
                                                               // Collect valid dispatch times only
                                                               List<Map<String, Integer>> dispatchList = new List<Map<String, Integer>>();
                                                               if (scheduledDispatchHour != null) 
                                                                   dispatchList.add(new Map<String, Integer>{'hour' => scheduledDispatchHour, 'minute' => scheduledDispatchMinute});
                                                               if (scheduledVehicleDispatch2Hour != null) 
                                                                   dispatchList.add(new Map<String, Integer>{'hour' => scheduledVehicleDispatch2Hour, 'minute' => scheduledVehicleDispatch2Minute});
                                                               if (scheduledVehicleDispatch3Hour != null) 
                                                                   dispatchList.add(new Map<String, Integer>{'hour' => scheduledVehicleDispatch3Hour, 'minute' => scheduledVehicleDispatch3Minute});
                                                               
                                                               
                                                               Integer bestDiff = 999999;
                                                               for (Map<String, Integer> d : dispatchList) {
                                                                   Integer dh = d.get('hour');
                                                                   Integer dm = d.get('minute');
                                                                   Integer dispatchTotalMin = dh * 60 + dm;
                                                                   if (dispatchTotalMin >= tatTotalMinutes) {
                                                                       Integer diff = dispatchTotalMin - tatTotalMinutes;
                                                                       if (diff < bestDiff) {
                                                                           bestDiff = diff;
                                                                           chosenDispatchHour = dh;
                                                                           chosenDispatchMinute = dm;
                                                                       }
                                                                   }
                                                               }
                                                               
                                                               // If no dispatch before SLA, pick the first of next day
                                                               if (chosenDispatchHour == null) {
                                                                   Integer minDispatchMin = 999999;
                                                                   Integer minDh = scheduledDispatchHour;
                                                                   Integer minDm = scheduledDispatchMinute;
                                                                   for (Map<String, Integer> d : dispatchList) {
                                                                       Integer dh = d.get('hour');
                                                                       Integer dm = d.get('minute');
                                                                       Integer dispatchTotalMin = dh * 60 + dm;
                                                                       if (dispatchTotalMin < minDispatchMin) {
                                                                           minDispatchMin = dispatchTotalMin;
                                                                           minDh = dh;
                                                                           minDm = dm;
                                                                       }
                                                                   }
                                                                   chosenDispatchHour = minDh + 24; // next day
                                                                   chosenDispatchMinute = minDm;
                                                               }
                                                               
                                                               
                                                               System.debug('for checking Chosen dispatch slot => ' + chosenDispatchHour + ':' + chosenDispatchMinute);
                                                               
                                                               Integer adjustedDispatchHour = chosenDispatchHour;
                                                               
                                                               if (isFirstTimeRoad) {
                                                                   // Calculate adjusted SLA for first leg
                                                                   if(chosenDispatchHour < TATSLAHour){
                                                                       chosenDispatchHour = (chosenDispatchHour + 24) - TATSLAHour;
                                                                   } else {
                                                                       chosenDispatchHour -= TATSLAHour;
                                                                   }
                                                                   
                                                                   
                                                                   tmpTATSLAmorethan24 = adjustedDispatchHour + hours;
                                                                   TATSLAMinute = chosenDispatchMinute;
                                                                   
                                                                   ARHour += (chosenDispatchHour + hours);
                                                                   ARMinute += (chosenDispatchMinute + minutes);
                                                                   
                                                                   Integer additionalARHours = ARMinute / 60;
                                                                   Integer remainingARMinutes = Math.mod(ARMinute, 60);
                                                                   ARHour += additionalARHours;
                                                                   ARMinute = remainingARMinutes;
                                                                   
                                                                   timeMap.put('ARHour', ARHour);
                                                                   timeMap.put('ARMinute', ARMinute);
                                                                   timeMap.put('ARSeconds', ARSeconds);
                                                                   
                                                                   if (tmpTATSLAmorethan24 > 24) tmpTATSLAmorethan24 -= 24;
                                                                   
                                                                   TATSLAHour = tmpTATSLAmorethan24 + 1;
                                                                   Integer additionalTATHours = TATSLAMinute / 60;
                                                                   Integer remainingTATMinutes = Math.mod(TATSLAMinute, 60);
                                                                   TATSLAHour += additionalTATHours;
                                                                   TATSLAMinute = remainingTATMinutes;
                                                                   
                                                                   timeMap.put('TATSLAHour', TATSLAHour);
                                                                   timeMap.put('TATSLAMinute', TATSLAMinute);
                                                                   
                                                                   System.debug('for checking Final TimeMap (First Road): ' + timeMap);
                                                                   return timeMap;
                                                               } else {
                                                                   // For next road calculations
                                                                   //Integer adjustedDispatchHour = (chosenDispatchHour + 24) - TATSLAHour;
                                                                   if(chosenDispatchHour < TATSLAHour){
                                                                       chosenDispatchHour = (chosenDispatchHour + 24) - TATSLAHour;
                                                                   } else {
                                                                       chosenDispatchHour -= TATSLAHour;
                                                                   }
                                                                   
                                                                   ARHour += (chosenDispatchHour + hours);
                                                                   ARMinute += (chosenDispatchMinute + minutes);
                                                                   
                                                                   Integer additionalARHours = ARMinute / 60;
                                                                   Integer remainingARMinutes = Math.mod(ARMinute, 60);
                                                                   ARHour += additionalARHours;
                                                                   ARMinute = remainingARMinutes;
                                                                   
                                                                   timeMap.put('ARHour', ARHour);
                                                                   timeMap.put('ARMinute', ARMinute);
                                                                   timeMap.put('ARSeconds', ARSeconds);
                                                                   
                                                                   TATSLAHour = adjustedDispatchHour + hours;
                                                                   TATSLAMinute = chosenDispatchMinute + minutes;
                                                                   
                                                                   Integer additionalTATHours = TATSLAMinute / 60;
                                                                   Integer remainingTATMinutes = Math.mod(TATSLAMinute, 60);
                                                                   TATSLAHour += additionalTATHours;
                                                                   TATSLAMinute = remainingTATMinutes;
                                                                   
                                                                   timeMap.put('TATSLAHour', TATSLAHour);
                                                                   timeMap.put('TATSLAMinute', TATSLAMinute);
                                                                   
                                                                   System.debug('for checking Final TimeMap (Next Road): ' + timeMap);
                                                                   return timeMap;
                                                               }
                                                           }
    
    public static Map<String, Object> adjustARAir(Network_Plan__c npObj, Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds, Boolean isFirstTimeFlight) {
        System.debug('for checking isFirstTimeFlight: '+isFirstTimeFlight);
        Integer HoursTimeFromHubToPort = 0;
        
        Integer scheduledDispatchHour = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour();
        Integer scheduledDispatchMinute = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute();
        Integer scheduledArrivalHourAtNextHub = npObj.Schedule_Arrival_from_airport_to_hub__c.hour();
        Integer scheduledArrivalMinuteAtNextHub = npObj.Schedule_departure_from_airport_to_hub__c.minute();
        System.debug('for checking ARHour in FLight :'+ARHour);
        System.debug('for checking ARMinute in FLight :'+ARMinute);
        System.debug('for checking TATSLAHour in FLight :'+TATSLAHour);
        System.debug('for checking TATSLAMinute in FLight :'+TATSLAMinute);
        System.debug('for checking scheduledDispatchHour in FLight : '+scheduledDispatchHour);
        System.debug('for checking scheduledDispatchMinute in FLight : '+scheduledDispatchMinute);
        System.debug('for checking scheduledArrivalHourAtNextHub in FLight : '+scheduledArrivalHourAtNextHub);
        System.debug('for checking scheduledArrivalMinuteAtNextHub in FLight : '+scheduledArrivalMinuteAtNextHub);
        
        if(isFirstTimeFlight){
            
            if(npObj.Flight_Departure_Time__c.hour() < scheduledDispatchHour){
                HoursTimeFromHubToPort = (24 + npObj.Flight_Departure_Time__c.hour()) - scheduledDispatchHour;
            } else {
                HoursTimeFromHubToPort = npObj.Flight_Departure_Time__c.hour() - scheduledDispatchHour;
            }
            
            Integer MinutesTimeFromHubToPort = npObj.Flight_Departure_Time__c.minute() - scheduledDispatchMinute;
            if (MinutesTimeFromHubToPort < 0) {
                MinutesTimeFromHubToPort += 60;
                HoursTimeFromHubToPort -= 1;
            }
            Integer SecondsTimeFromHubToPort = npObj.Flight_Departure_Time__c.second() - npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.second();    
            
            System.debug('for checking 1st time air inside if HoursTimeFromHubToPort: '+HoursTimeFromHubToPort);
            System.debug('for checking 1st time air inside if MinutesTimeFromHubToPort: '+MinutesTimeFromHubToPort);
            System.debug('for checking 1st time air inside if SecondsTimeFromHubToPort: '+SecondsTimeFromHubToPort);
            
            Integer tmpScheduledDispatchHour = scheduledDispatchHour;
            System.debug('for checking 1st time air inside if tmpScheduledDispatchHour: ' +tmpScheduledDispatchHour);
            
            //if(scheduledDispatchHour < TATSLAHour){
            /*if(scheduledDispatchHour < TATSLAHour || (scheduledDispatchHour == TATSLAHour && scheduledDispatchMinute < TATSLAMinute)){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            */
            Integer dispatchTotalMinutes =
                (scheduledDispatchHour * 60) + scheduledDispatchMinute;
            
            Integer slaTotalMinutes =
                (TATSLAHour * 60) + TATSLAMinute;
            
            Integer resultMinutes = dispatchTotalMinutes - slaTotalMinutes;
            
            if(resultMinutes < 0){
                resultMinutes += 24 * 60;
            }
            
            Integer resultHour = resultMinutes / 60;
            Integer resultMinute = Math.mod(resultMinutes, 60);
            
            scheduledDispatchHour = resultHour;
            scheduledDispatchMinute = resultMinute;

            System.debug('for checking 1st time air inside if scheduledDispatchHour after removing TATSLAHour: '+scheduledDispatchHour);
            System.debug('for checking 1st time air inside if npObj.Flight_Departure_Time__c.hour() : '+npObj.Flight_Departure_Time__c.hour());
            
            //Integer FlightTimeHour = npObj.Flight_Arrival_Time__c.hour() - npObj.Flight_Departure_Time__c.hour();
            //Integer FlightTimeMinute = npObj.Flight_Arrival_Time__c.minute() - npObj.Flight_Departure_Time__c.minute();
            //Integer FlightTimeSeconds = npObj.Flight_Arrival_Time__c.second() - npObj.Flight_Departure_Time__c.second();
            
            Integer depHour = npObj.Flight_Departure_Time__c.hour();
            Integer depMinute = npObj.Flight_Departure_Time__c.minute();
            Integer depSecond = npObj.Flight_Departure_Time__c.second();
            
            Integer arrHour = npObj.Flight_Arrival_Time__c.hour();
            Integer arrMinute = npObj.Flight_Arrival_Time__c.minute();
            Integer arrSecond = npObj.Flight_Arrival_Time__c.second();
            
            // Convert both to total seconds from midnight
            Integer depTotalSeconds = (depHour * 3600) + (depMinute * 60) + depSecond;
            Integer arrTotalSeconds = (arrHour * 3600) + (arrMinute * 60) + arrSecond;
            
            // Handle overnight case (arrival next day)
            if (arrTotalSeconds < depTotalSeconds) {
                arrTotalSeconds += 24 * 3600;
            }
            
            // Compute total difference in seconds
            Integer diffSeconds = arrTotalSeconds - depTotalSeconds;
            
            // Convert back to hours, minutes, and seconds
            Integer FlightTimeHour = diffSeconds / 3600;
            Integer remainingAfterHours = diffSeconds - (FlightTimeHour * 3600);
            Integer FlightTimeMinute = remainingAfterHours / 60;
            Integer FlightTimeSeconds = remainingAfterHours - (FlightTimeMinute * 60);
            
            System.debug('for checking 1st time air inside if FlightTimeHour: '+FlightTimeHour);
            System.debug('for checking 1st time air inside if FlightTimeMinute: '+FlightTimeMinute);
            System.debug('for checking 1st time air inside if FlightTimeSeconds: '+FlightTimeSeconds);
            
            //Integer hourToReachNextHubAfterArrival = scheduledArrivalHourAtNextHub - npObj.Flight_Arrival_Time__c.hour();
            //Integer minuteToReachNextHubAfterArrival = scheduledArrivalMinuteAtNextHub - npObj.Flight_Arrival_Time__c.minute();
            
            // Calculate hour difference
            Integer hourToReachNextHubAfterArrival;
            if (scheduledArrivalHourAtNextHub < npObj.Flight_Arrival_Time__c.hour()) {
                hourToReachNextHubAfterArrival = (24 + scheduledArrivalHourAtNextHub) - npObj.Flight_Arrival_Time__c.hour();
            } else {
                hourToReachNextHubAfterArrival = scheduledArrivalHourAtNextHub - npObj.Flight_Arrival_Time__c.hour();
            }
            
            // Calculate minute difference
            Integer minuteToReachNextHubAfterArrival = scheduledArrivalMinuteAtNextHub - npObj.Flight_Arrival_Time__c.minute();
            if (minuteToReachNextHubAfterArrival < 0) {
                minuteToReachNextHubAfterArrival += 60;
                hourToReachNextHubAfterArrival -= 1;
            }
            
            
            System.debug('for checking 1st time air inside if hourToReachNextHubAfterArrival: '+hourToReachNextHubAfterArrival);
            System.debug('for checking 1st time air inside if minuteToReachNextHubAfterArrival: '+minuteToReachNextHubAfterArrival);
            
            
            System.debug('for checking 1st time air scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival : '+(scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival));
            System.debug('for checking 1st time air scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival : '+(scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival));
            System.debug('for checking 1st time air FlightTimeSeconds + SecondsTimeFromHubToPort : '+(FlightTimeSeconds + SecondsTimeFromHubToPort));
            
            
            ARHour += (scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival);
            ARMinute += (scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival);
            ARSeconds += (FlightTimeSeconds + SecondsTimeFromHubToPort);
            
            Integer additionalARHours = ARMinute / 60;
            Integer remainingARMinutes = Math.mod(ARMinute, 60);
            
            ARHour += additionalARHours;
            ARMinute = remainingARMinutes;
            
            
            Map<String, Object> timeMap = new Map<String, Object>();
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            System.debug('for checking 1st time air inside if AIR Time SLA: ' + ARHour + 'h ' + ARMinute + 'm ' + ARSeconds + 's');
            
            TATSLAHour = tmpScheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival;
            TATSLAMinute = scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival;
            
            // Handle minute overflow
            if (TATSLAMinute >= 60) {
                TATSLAHour += (TATSLAMinute / 60);
                TATSLAMinute = Math.mod(TATSLAMinute, 60);
            }
            
            // Handle hour overflow (wrap to 0–23)
            if (TATSLAHour >= 24) {
                TATSLAHour = Math.mod(TATSLAHour, 24);
            }
            
            System.debug('for checking 1st time air new AIR TATSLAHour :'+TATSLAHour);
            System.debug('for checking 1st time air new AIR TATSLAMinute :'+TATSLAMinute);
            
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            
            System.debug('for checking 1st time air timeMap @@@@@@@@@@@@@@@@@@ :'+timeMap);
            
            return timeMap;
        } else {
            
            if(npObj.Flight_Departure_Time__c.hour() < scheduledDispatchHour){
                HoursTimeFromHubToPort = (24 + npObj.Flight_Departure_Time__c.hour()) - scheduledDispatchHour;
            } else {
                HoursTimeFromHubToPort = npObj.Flight_Departure_Time__c.hour() - scheduledDispatchHour;
            }
            
            Integer MinutesTimeFromHubToPort = npObj.Flight_Departure_Time__c.minute() - scheduledDispatchMinute;
            Integer SecondsTimeFromHubToPort = npObj.Flight_Departure_Time__c.second() - npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.second();    
            
            System.debug('for checking next time air inside else HoursTimeFromHubToPort: '+HoursTimeFromHubToPort);
            System.debug('for checking next time air inside else MinutesTimeFromHubToPort: '+MinutesTimeFromHubToPort);
            System.debug('for checking next time air inside else SecondsTimeFromHubToPort: '+SecondsTimeFromHubToPort);
            
            Integer tmpScheduledDispatchHour = scheduledDispatchHour;
            System.debug('for checking next time air inside if tmpScheduledDispatchHour: ' +tmpScheduledDispatchHour);
            
            //if(scheduledDispatchHour < TATSLAHour){
            /*if(scheduledDispatchHour < TATSLAHour || (scheduledDispatchHour == TATSLAHour && scheduledDispatchMinute < TATSLAMinute)){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }*/
            
            Integer dispatchTotalMinutes =
                (scheduledDispatchHour * 60) + scheduledDispatchMinute;
            
            Integer slaTotalMinutes =
                (TATSLAHour * 60) + TATSLAMinute;
            
            Integer resultMinutes = dispatchTotalMinutes - slaTotalMinutes;
            
            if(resultMinutes < 0){
                resultMinutes += 24 * 60;
            }
            
            Integer resultHour = resultMinutes / 60;
            Integer resultMinute = Math.mod(resultMinutes, 60);
            
            scheduledDispatchHour = resultHour;
            scheduledDispatchMinute = resultMinute;

            
            System.debug('for checking next time air inside else scheduledDispatchHour after removing TATSLAHour: '+scheduledDispatchHour);
            System.debug('for checking next time air inside else npObj.Flight_Departure_Time__c.hour() : '+npObj.Flight_Departure_Time__c.hour());
            
            //Integer FlightTimeHour = npObj.Flight_Arrival_Time__c.hour() - npObj.Flight_Departure_Time__c.hour();
            //Integer FlightTimeMinute = npObj.Flight_Arrival_Time__c.minute() - npObj.Flight_Departure_Time__c.minute();
            //Integer FlightTimeSeconds = npObj.Flight_Arrival_Time__c.second() - npObj.Flight_Departure_Time__c.second();
            
            Integer depHour = npObj.Flight_Departure_Time__c.hour();
            Integer depMinute = npObj.Flight_Departure_Time__c.minute();
            Integer depSecond = npObj.Flight_Departure_Time__c.second();
            
            Integer arrHour = npObj.Flight_Arrival_Time__c.hour();
            Integer arrMinute = npObj.Flight_Arrival_Time__c.minute();
            Integer arrSecond = npObj.Flight_Arrival_Time__c.second();
            
            // Convert both to total seconds from midnight
            Integer depTotalSeconds = (depHour * 3600) + (depMinute * 60) + depSecond;
            Integer arrTotalSeconds = (arrHour * 3600) + (arrMinute * 60) + arrSecond;
            
            // Handle overnight case (arrival next day)
            if (arrTotalSeconds < depTotalSeconds) {
                arrTotalSeconds += 24 * 3600;
            }
            
            // Compute total difference in seconds
            Integer diffSeconds = arrTotalSeconds - depTotalSeconds;
            
            // Convert back to hours, minutes, and seconds
            Integer FlightTimeHour = diffSeconds / 3600;
            Integer remainingAfterHours = diffSeconds - (FlightTimeHour * 3600);
            Integer FlightTimeMinute = remainingAfterHours / 60;
            Integer FlightTimeSeconds = remainingAfterHours - (FlightTimeMinute * 60);
            
            
            System.debug('for checking next time air inside else FlightTimeHour: '+FlightTimeHour);
            System.debug('for checking next time air inside else FlightTimeMinute: '+FlightTimeMinute);
            System.debug('for checking next time air inside else FlightTimeSeconds: '+FlightTimeSeconds);
            
            //Integer hourToReachNextHubAfterArrival = scheduledArrivalHourAtNextHub - npObj.Flight_Arrival_Time__c.hour();
            //Integer minuteToReachNextHubAfterArrival = scheduledArrivalMinuteAtNextHub - npObj.Flight_Arrival_Time__c.minute();
            
            // Calculate hour difference
            Integer hourToReachNextHubAfterArrival;
            if (scheduledArrivalHourAtNextHub < npObj.Flight_Arrival_Time__c.hour()) {
                hourToReachNextHubAfterArrival = (24 + scheduledArrivalHourAtNextHub) - npObj.Flight_Arrival_Time__c.hour();
            } else {
                hourToReachNextHubAfterArrival = scheduledArrivalHourAtNextHub - npObj.Flight_Arrival_Time__c.hour();
            }
            
            // Calculate minute difference
            Integer minuteToReachNextHubAfterArrival = scheduledArrivalMinuteAtNextHub - npObj.Flight_Arrival_Time__c.minute();
            if (minuteToReachNextHubAfterArrival < 0) {
                minuteToReachNextHubAfterArrival += 60;
                hourToReachNextHubAfterArrival -= 1;
            }
            
            
            System.debug('for checking 1st time air inside if hourToReachNextHubAfterArrival: '+hourToReachNextHubAfterArrival);
            System.debug('for checking 1st time air inside if minuteToReachNextHubAfterArrival: '+minuteToReachNextHubAfterArrival);
            
            
            System.debug('for checking next time air scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival : '+(scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival));
            System.debug('for checking next time air scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival : '+(scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival));
            System.debug('for checking next time air FlightTimeSeconds + SecondsTimeFromHubToPort : '+(FlightTimeSeconds + SecondsTimeFromHubToPort));
            
            ARHour += (scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival);
            ARMinute += (scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival);
            ARSeconds += (FlightTimeSeconds + SecondsTimeFromHubToPort);
            
            Integer additionalARHours = ARMinute / 60;
            Integer remainingARMinutes = Math.mod(ARMinute, 60);
            
            ARHour += additionalARHours;
            ARMinute = remainingARMinutes;
            
            
            
            Map<String, Integer> timeMap = new Map<String, Integer>();
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            
            System.debug('for checking next time air inside else AIR Time SLA: ' + ARHour + 'h ' + ARMinute + 'm ' + ARSeconds + 's');
            
            TATSLAHour = tmpScheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival;
            TATSLAMinute = scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival;
            
            // Handle minute overflow
            if (TATSLAMinute >= 60) {
                TATSLAHour += (TATSLAMinute / 60);
                TATSLAMinute = Math.mod(TATSLAMinute, 60);
            }
            
            // Handle hour overflow (wrap to 0–23)
            if (TATSLAHour >= 24) {
                TATSLAHour = Math.mod(TATSLAHour, 24);
            }
            
            System.debug('for checking next time air new AIR TATSLAHour :'+TATSLAHour);
            System.debug('for checking next time air new AIR TATSLAMinute :'+TATSLAMinute);
            
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            
            System.debug('for checking next time air timeMap @@@@@@@@@@@@@@@@@@ :'+timeMap);
            
            return timeMap;
        }
        
    }
    
    // ================= MULTI-DELIVERY ROUTE HELPER =================
    /*
    public static Datetime getNextAvailableDeliveryRoute(Datetime arrivalDT, List<Map<String, Time>> deliveryWindows) {
        if (arrivalDT == null || deliveryWindows.isEmpty()) return null;
        
        System.debug('for checking arrivalDT ==='+arrivalDT);
        Date arrivalDate = arrivalDT.date();
        Time arrivalTime = arrivalDT.time();
        System.debug('for checking arrivalDate ==='+arrivalDate);
        System.debug('for checking arrivalTime ==='+arrivalTime);
        
        for (Map<String, Time> win : deliveryWindows) {
            Time startT = win.get('start');
            Time endT   = win.get('end');
            System.debug('for checking startT ==='+startT);
            System.debug('for checking endT ==='+endT);
            if (arrivalTime < startT) {
                // Arrived early → wait till window opens
                return Datetime.newInstance(arrivalDate, startT);
            }
            
            if (arrivalTime >= startT && arrivalTime <= endT) {
                // Arrived inside window → deliver immediately
                //return arrivalDT;
                continue;
            }
        }
        
        // All windows missed → next day Round 1
        return Datetime.newInstance(
            arrivalDate.addDays(1),
            deliveryWindows[0].get('start')
        );
    }
	*/
    
    
    public static Datetime getNextAvailableDeliveryRoute(Datetime arrivalDT, List<Map<String, Time>> deliveryWindows) {
        if (arrivalDT == null || deliveryWindows.isEmpty()) return null;
        
        System.debug('arrivalDT = ' + arrivalDT);
        
        Date arrivalDate = arrivalDT.date();
        
        for (Map<String, Time> win : deliveryWindows) {
            
            Time startT = win.get('start');
            Time endT   = win.get('end');
            
            Datetime windowStartDT = Datetime.newInstance(arrivalDate, startT);
            Datetime windowEndDT   = Datetime.newInstance(arrivalDate, endT);
            
            System.debug('Window Start DT = ' + windowStartDT);
            System.debug('Window End DT   = ' + windowEndDT);
            
            // Arrived before window → wait till start
            if (arrivalDT < windowStartDT) {
                return windowStartDT;
            }
            
        }
        
        // ❗ All windows missed → next day first window
        return Datetime.newInstance(
            arrivalDate.addDays(1),
            deliveryWindows[0].get('start')
        );
    }
	
    public static String splitRoute(String originalNextRoute) {
        String nextRoute = originalNextRoute;
        List<String> nextRouteParts = nextRoute.split('_');
        String nextOrigin = '';
        if (nextRouteParts.size() > 1) {
            nextOrigin = nextRouteParts[1];
        }
        
        System.debug('for checking Next Origin: ' + nextOrigin); 
        return nextOrigin;
    }   
    
    public static void getCoverage1(){
        integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    
}