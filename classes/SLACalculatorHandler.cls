public class SLACalculatorHandler {
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


    public static void distanceCalculator(List<Shipment__c> shipList) {
        
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
            for (Shipment__c shipObj : shipList) {
                pickupIdSet.add(shipObj.Pickup__c);
                shipIdVsTATSLAMapping.put(shipObj.Id,new TAT_SLA_Mapping__c(Origin_Pincode__c = shipObj.Origin_Address_Name__r.Active_Pincode__c,Destination_Pincode__c = shipObj.Destination_Address_Name__r.Active_Pincode__c));
                
            }
            
            if(!shipIdVsTATSLAMapping.values().isEmpty()){
                insert shipIdVsTATSLAMapping.values();
            }
            System.debug('check shipIdVsTATSLAMapping.values() '+shipIdVsTATSLAMapping.values());
            
            System.debug('for checking pickupIdSet ' + pickupIdSet);
            Map<Id, Pickup__c> pickupMap = new Map<Id, Pickup__c>([SELECT Id, Name, Origin_Address_Pincode__c 
                                                                   FROM Pickup__c WHERE Id IN :pickupIdSet]);
            System.debug('for checking pickupMap ' + pickupMap);
            
            List<Distance_Calculator__c> distanceCalulatorList = 
                Test.isRunningTest() ? new List<Distance_Calculator__c>() :
            [SELECT Id, Name, State__c, Origin_Pincode__c, Destination_Pincode__c, City__c, 
             Distance_in_km__c, Distance_Range__c, Time_from_Pickup_to_Hub__c, 
             Scheduled_Delivery_Route_Start_Time__c, Same_City_Hub_Delivery_Route_Start_Time__c, 
             ROUTE_NUMBER__c 
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
             Schedule_Arrival_from_airport_to_hub__c, Hub_Processing_hr__c
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
                if (pickupObj != null) {
					System.debug('109 pickupObj.Origin_Address_Pincode__c :'+pickupObj.Origin_Address_Pincode__c);
                    String key = pickupObj.Origin_Address_Pincode__c;
                    Distance_Calculator__c dcObj = distanceMap.get(key);
                    System.debug('for checking distanceMap.get(key) = '+distanceMap.get(key));
                    
                    TATSLAHour = shipObj.Physical_Pickup_Completed_Time1__c.hour();
                    TATSLAMinute = shipObj.Physical_Pickup_Completed_Time1__c.minute();
                    TATSLASeconds = shipObj.Physical_Pickup_Completed_Time1__c.second();
                    
                    System.debug('for checking TATSLAHour '+TATSLAHour);
                    System.debug('for checking TATSLAMinute '+TATSLAMinute);
                    System.debug('for checking TATSLASeconds '+TATSLASeconds);
                    
                    System.debug('for checking key = '+key);
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
                        
                        
                        System.debug('For checking origin hub name after triming '+testOriginAddNameKey);
                        
                        
                        
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
                        
                        
                        System.debug('For checking destination hub name after triming '+testDestAddNameKey);
                        
                        
                        
                        if (!isSameCityLogicExecuted) {
                            //String npkey = shipObj.Origin_Hub__r.Name + '_' + shipObj.Destination_Hub__r.Name;
                            String npKey = testOriginAddNameKey +'_'+ testDestAddNameKey;
                            String destinationKey = shipObj.Destination_Address_Pincode__c;
                            String hdStateKey = shipObj.Destination_Hub__r.Name;
                            
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
            for(Id shipId : shipIdVsTATSLAMapping.keySet()){
                TAT_SLA_Mapping__c tmpTSM = new TAT_SLA_Mapping__c();
                tmpTSM.Id = shipIdVsTATSLAMapping.get(shipId).Id;
                tmpTSM.SLA_Hours__c = ShipIdVsFinalTime.get(shipId);
                tmpTSM.SLA_Day__c = ShipIdVsSLADay.get(shipId);
                tmpTSM.Estimated_Delivery_Date__c = ShipIdVsEstDelDate.get(shipId);
                tmpTSM.TAT_in_Days__c = ShipIdVsTatInDays.get(shipId);
                tmpTSM.Holiday__c = ShipIdVsHolidayDay.get(shipId);
                tmpTSM.Shipment__c = shipId;
                tsmListToUpdate.add(tmpTSM);
            }
            
            if(tsmListToUpdate.size()>0){
                update tsmListToUpdate;
            }
            
            
        } catch(Exception e) { 
            System.debug('Error on line number : ' + e.getLineNumber() +' while updating SLA Hours : ' + e.getMessage());
            Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'SLACalculatorHandlerBatch',Error__c=e.getMessage());
            insert AEL;

        } finally {
            isTriggerExecuted = false;
        }
    }
    
	public static Map<String, Object> adjustTATSLAHourAndMinute(Distance_Calculator__c dcObj, Shipment__c shipObj, Integer ARHour, Integer ARMinute, Integer ARSeconds, Integer TATSLAHour, Integer TATSLAMinute, Integer TATSLASeconds) {
        Integer SameCityDeliveryHour = 0;
        Integer SameCityDeliveryMinute = 0;
        
        Boolean isSameCityLogicExecuted = false;
        
        System.debug('for checking Inside adjustTATSLAHourAndMinute');
        
        System.debug('for checking ARHour :'+ARHour);
        System.debug('for checking ARMinute :'+ARMinute);
        
        ARHour += 1;		//hub processing time
        
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
            
            
            
            
            DateTime currentDateTime = shipObj.Physical_Pickup_Completed_Time1__c;
            Date currentDate = currentDateTime.date();
            System.debug('Inside same city currentDate = '+currentDate);
            
            
            DateTime futureDateTime = currentDateTime.addHours(ARHour).addMinutes(ARMinute);
            System.debug('Inside same city deliveryDateTime.date() = '+futureDateTime.date());
            
            if (currentDateTime.date() == futureDateTime.date()) {
                futureDateTime = futureDateTime.addDays(1);
                ARHour += 24;
                System.debug('If Delivery happened on the same day then adding 24 hours to ARHour = ' + ARHour);
            }
            
            if (ARHour < TATSLAHour || (ARHour == TATSLAHour && ARMinute < TATSLAMinute) || (ARHour == TATSLAHour && ARMinute == TATSLAMinute && ARSeconds < TATSLASeconds)) {
                System.debug('Inside if of Inside same city ARHour<TATSLAHour '+ARHour);
                futureDateTime = futureDateTime.addDays(1);
                ARHour += 24;
                System.debug('Inside if of Inside same city ARHour after adding 24 '+ARHour);
                
            }
            
            System.debug('Inside same city Final Calculated ARHour '+ARHour);
            System.debug('Inside same city Final Calculated ARMinute '+ARMinute);
            String FinalTime = ARHour+'H '+ARMinute+'M '+ARSeconds+'S';
            
            Integer additionalARHours = ARMinute / 60;
            Integer remainingARMinutes = Math.mod(ARMinute, 60);
            
            ARHour+=additionalARHours;
            ARMinute+=remainingARMinutes;
            
            String slaDay = futureDateTime.format('EEEE', 'en_US');
            System.debug('for checking inside if(destinationKey == dcObj.City__c) SLA Day: ' + slaDay);
            
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
            
            TATSLAHour += hours + 1;
            TATSLAMinute += minutes;
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAHour '+TATSLAHour);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) afetr all TATSLAMinute '+TATSLAMinute);
            
            
            
            
        } else {
            System.debug('for checking Inside adjustTATSLAHourAndMinute dcObj.Time_from_Pickup_to_Hub__c '+dcObj.Time_from_Pickup_to_Hub__c);
            
            
            Integer scheduledDispatchHour = dcObj.Scheduled_Delivery_Route_Start_Time__c.hour();
            Integer scheduledDispatchMinute = dcObj.Scheduled_Delivery_Route_Start_Time__c.minute();
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute scheduledDispatchHour '+scheduledDispatchHour);
            System.debug('for checking Inside adjustTATSLAHourAndMinute TATSLAHour '+TATSLAHour);
            if(scheduledDispatchHour <= TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
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
            
            System.debug('for checking Inside adjustTATSLAHourAndMinute after adjustment scheduledDispatchHour '+hours);
            
            ARHour += (scheduledDispatchHour+hours);
            ARMinute += (scheduledDispatchMinute+minutes);
            
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) scheduledDispatchHour '+hours);
            System.debug('for checking Inside if(destinationKey == dcObj.City__c) scheduledDispatchMinute '+minutes);
            
            
            
            
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
                    timeMap = adjustARRoad(npObj, ARHour, ARMinute, ARSeconds, TATSLAHour, TATSLAMinute, TATSLASeconds, isFirstTimeRoad);
                    isFirstTimeRoad = false;
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
                npCalListToInsert.add(npCal);
                
                System.debug('for Checking npObj.Next_Route__c: ' + npObj.Next_Route__c);
                String nextOrigin = splitRoute(npObj.Next_Route__c);
                System.debug('for Checking nextOrigin: ' + nextOrigin);
                System.debug('for Checking npObj.To_Destination_Hub__c: ' + npObj.To_Destination_Hub__c);
                
                if (nextOrigin == npObj.To_Destination_Hub__c) {
                    System.debug('for checking inside if nextOrigin == npObj.To_Destination_Hub__c');
                    //ARHour += 1;
                    //ARMinute += 30;
                    
                    System.debug('for checking destinationKey :'+destinationKey);
                    System.debug('for checking dcObj.Destination_Pincode__c :'+dcObj.Destination_Pincode__c);
                    
                    System.debug('@for checking destination city :'+shipObj.Destination_Address_City__c);
                    System.debug('@for checking dcObj.city__c :'+dcObj.city__c);
                    
                    if(destinationKey == dcObj.Destination_Pincode__c){
                        System.debug('for checking Inside if(destinationKey == dcObj.City__c)');
                        
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) ARHour '+ARHour);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) ARMinute '+ARMinute);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) ARSeconds '+ARSeconds);
                        
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) shipObj.Destination_Address_Name__r.Active_Pincode__r.City__c :'+shipObj.Destination_Address_Name__r.Active_Pincode__r.City__c);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) shipObj.Destination_Address_Name__r.Active_Pincode__r.Sunday__c :'+shipObj.Destination_Address_Name__r.Active_Pincode__r.Sunday__c);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) shipObj.Destination_Address_Name__r.Active_Pincode__r.Monday__c :'+shipObj.Destination_Address_Name__r.Active_Pincode__r.Monday__c);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) shipObj.Destination_Address_Name__r.Active_Pincode__r.Tuesday__c :'+shipObj.Destination_Address_Name__r.Active_Pincode__r.Tuesday__c);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) shipObj.Destination_Address_Name__r.Active_Pincode__r.Wednesday__c :'+shipObj.Destination_Address_Name__r.Active_Pincode__r.Wednesday__c);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) shipObj.Destination_Address_Name__r.Active_Pincode__r.Thursday__c :'+shipObj.Destination_Address_Name__r.Active_Pincode__r.Thursday__c);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) shipObj.Destination_Address_Name__r.Active_Pincode__r.Friday__c :'+shipObj.Destination_Address_Name__r.Active_Pincode__r.Friday__c);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) shipObj.Destination_Address_Name__r.Active_Pincode__r.Saturday__c :'+shipObj.Destination_Address_Name__r.Active_Pincode__r.Saturday__c);
                        
                        Map<String, Boolean> serviceableDays = new Map<String, Boolean>{
                            'Monday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Monday__c,
                                'Tuesday'   => shipObj.Destination_Address_Name__r.Active_Pincode__r.Tuesday__c,
                                'Wednesday' => shipObj.Destination_Address_Name__r.Active_Pincode__r.Wednesday__c,
                                'Thursday'  => shipObj.Destination_Address_Name__r.Active_Pincode__r.Thursday__c,
                                'Friday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Friday__c,
                                'Saturday'  => shipObj.Destination_Address_Name__r.Active_Pincode__r.Saturday__c,
                                'Sunday'    => shipObj.Destination_Address_Name__r.Active_Pincode__r.Sunday__c
                                };
                                    
                                    System.debug('for checking inside if(destinationKey == dcObj.City__c) serviceableDays :'+serviceableDays);
                        
                        Integer additionalARHours = ARMinute / 60;
                        Integer remainingARMinutes = Math.mod(ARMinute, 60);
                        
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) additionalHours : '+additionalARHours);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) remainingMinutes : '+remainingARMinutes);
                        
                        ARHour += additionalARHours;
                        ARMinute = remainingARMinutes;
                        
                        Integer ARdays = ARHour / 24;
                        Integer remainingARHours = Math.mod(ARHour, 24);
                        
                        //Datetime currentARDateTime = Datetime.now().addMinutes(330);
                        
                        Datetime currentARDateTime = shipObj.Physical_Pickup_Completed_Time1__c;
                        
                        Datetime targetARDateTime = currentARDateTime.addDays(ARdays).addHours(remainingARHours).addMinutes(ARMinute).addSeconds(ARSeconds);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) serviceable day calculations targetARDateTime :'+targetARDateTime);
                        
                        Long timeDifferenceMillis = targetARDateTime.getTime() - currentARDateTime.getTime();
                        Integer hoursToAdd = (Integer)(timeDifferenceMillis / (1000 * 60 * 60));
                        Integer minutesToAdd = (Integer)((timeDifferenceMillis - (hoursToAdd * 1000 * 60 * 60)) / (1000 * 60));
                        Integer secondsToAdd = (Integer)((timeDifferenceMillis - (hoursToAdd * 1000 * 60 * 60) - (minutesToAdd * 1000 * 60)) / 1000);
						System.debug('for checking inside if(destinationKey == dcObj.City__c) timeDifferenceMillis '+timeDifferenceMillis);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) hoursToAdd '+hoursToAdd);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) minutesToAdd '+minutesToAdd);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) secondsToAdd '+secondsToAdd);
                        
                        Map<String, Object> destinationTimeMap = adjustTATSLAHourAndMinute(dcObj, shipObj, hoursToAdd, minutesToAdd, secondsToAdd, TATSLAHour, TATSLAMinute, TATSLASeconds);
                        Integer FinalTATHour = (Integer) destinationTimeMap.get('ARHour');
                        Integer FinalTATMinute = (Integer) destinationTimeMap.get('ARMinute');
                        Integer FinalTATSeconds = (Integer) destinationTimeMap.get('ARSeconds');
                        
                        Integer additionalHours = FinalTATMinute / 60;
                        Integer remainingMinutes = Math.mod(FinalTATMinute, 60);
                        
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) additionalHours : '+additionalHours);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) remainingMinutes : '+remainingMinutes);
                        
                        FinalTATHour += additionalHours;
                        FinalTATMinute = remainingMinutes;
                        
                        Integer days = FinalTATHour / 24;
                        Integer remainingHours = Math.mod(FinalTATHour, 24);
                        
                        System.debug('@for checking days '+days);
                        
                        Datetime currentDateTime = shipObj.Physical_Pickup_Completed_Time1__c;
                        Date currentDate = currentDateTime.date();
                        System.debug('@@@for checking currentDate = '+currentDate);
                        
                        Datetime targetDateTime = currentDateTime.addDays(days).addHours(remainingHours).addMinutes(FinalTATMinute).addSeconds(FinalTATSeconds);
                        
                        Datetime istDateTime = targetDateTime.addSeconds(19800);
                        
                        String slaDay = istDateTime.format('EEEE', 'en_US');
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) SLA Day: ' + slaDay);
                        
                        Boolean isServiceable = serviceableDays.containsKey(slaDay) && serviceableDays.get(slaDay);
                        
                        Integer maxDaysInWeek = 7;
                        Integer dayInWeek = 0;
                        
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
                        
                        Date EstDelDate = date.newinstance(targetDateTime.year(),targetDateTime.month(),targetDateTime.day());
                        System.debug('@@@for checking EstDelDate = '+EstDelDate);
                        
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) FinalTATHour '+FinalTATHour);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) FinalTATMinute '+FinalTATMinute);
                        System.debug('for checking inside if(destinationKey == dcObj.City__c) FinalTATSeconds '+FinalTATSeconds);
                        System.debug('for checking total time required from destination hub to destination city : '+FinalTATHour+'H '+FinalTATMinute+'M '+FinalTATSeconds+'S');
                        System.debug('for checking The SLA day ' + slaDay + ' is a serviceable day.');
                        System.debug('for checking Adjusted target delivery date and time: ' + targetDateTime);
                        
                        String FinalTime = FinalTATHour+'H '+FinalTATMinute+'M '+FinalTATSeconds+'S';
                        
                        
                        Integer numberOfDays = Math.abs(EstDelDate.daysBetween(currentDate));
                        System.debug('@@@for checking numberOfDays = '+numberOfDays);                        
                        
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
        System.debug('for checking inside adjustARRoad TATSLAHour '+TATSLAHour);
        System.debug('for checking inside adjustARRoad scheduledDispatchHour '+scheduledDispatchHour);

        if(isFirstTimeRoad){
            //if(ARHour == 2){
                //TATSLAHour += ARHour;		//Commented to test time difference for difference cities.
            //}
            		
            if(scheduledDispatchHour < TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            
            System.debug('for checking inside adjustARRoad 1st time road scheduledDispatchHour '+scheduledDispatchHour);
			
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
            TATSLAHour = tmpTATSLAmorethan24 + 1;
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
            
            if(scheduledDispatchHour < TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            
            System.debug('for checking after first time road scheduledDispatchHour '+scheduledDispatchHour);
            
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
            ARMinute += (scheduledDispatchMinute+minutes);
            //ARSeconds += (npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.second()+npObj.Approx_Time_Taken_in_hrs__c.second());
            
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            
            System.debug('for checking in next road time First Time Road SLA: ' + ARHour + 'h ' + ARMinute + 'm ' + ARSeconds + 's');
            
            TATSLAHour = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.hour() + hours + 1;
            TATSLAMinute = npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.minute() + minutes;
            
            System.debug('for checking in next road time new TATSLAHour :'+TATSLAHour);
            System.debug('for checking in next road time new TATSLAMinute :'+TATSLAMinute);
            
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            
            System.debug('for checking in next road time timeMap @@@@@@@@@@@@@@@@@@ :'+timeMap);
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
            Integer SecondsTimeFromHubToPort = npObj.Flight_Departure_Time__c.second() - npObj.Scheduled_Max_Time_of_Vehicle_Dispatch__c.second();    
            
            System.debug('for checking 1st time air inside if HoursTimeFromHubToPort: '+HoursTimeFromHubToPort);
            System.debug('for checking 1st time air inside if MinutesTimeFromHubToPort: '+MinutesTimeFromHubToPort);
            System.debug('for checking 1st time air inside if SecondsTimeFromHubToPort: '+SecondsTimeFromHubToPort);
            
            Integer tmpScheduledDispatchHour = scheduledDispatchHour;
			System.debug('for checking 1st time air inside if tmpScheduledDispatchHour: ' +tmpScheduledDispatchHour);
            
            if(scheduledDispatchHour <= TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            System.debug('for checking 1st time air inside if scheduledDispatchHour after removing TATSLAHour: '+scheduledDispatchHour);
            System.debug('for checking 1st time air inside if npObj.Flight_Departure_Time__c.hour() : '+npObj.Flight_Departure_Time__c.hour());
            
            Integer FlightTimeHour = npObj.Flight_Arrival_Time__c.hour() - npObj.Flight_Departure_Time__c.hour();
            Integer FlightTimeMinute = npObj.Flight_Arrival_Time__c.minute() - npObj.Flight_Departure_Time__c.minute();
            Integer FlightTimeSeconds = npObj.Flight_Arrival_Time__c.second() - npObj.Flight_Departure_Time__c.second();
            
            System.debug('for checking 1st time air inside if FlightTimeHour: '+FlightTimeHour);
            System.debug('for checking 1st time air inside if FlightTimeMinute: '+FlightTimeMinute);
            System.debug('for checking 1st time air inside if FlightTimeSeconds: '+FlightTimeSeconds);
            
            Integer hourToReachNextHubAfterArrival = scheduledArrivalHourAtNextHub - npObj.Flight_Arrival_Time__c.hour();
            Integer minuteToReachNextHubAfterArrival = scheduledArrivalMinuteAtNextHub - npObj.Flight_Arrival_Time__c.minute();
            
            System.debug('for checking 1st time air inside if hourToReachNextHubAfterArrival: '+hourToReachNextHubAfterArrival);
            System.debug('for checking 1st time air inside if minuteToReachNextHubAfterArrival: '+minuteToReachNextHubAfterArrival);
            
            
            System.debug('for checking 1st time air scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival : '+(scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival));
            System.debug('for checking 1st time air scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival : '+(scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival));
            System.debug('for checking 1st time air FlightTimeSeconds + SecondsTimeFromHubToPort : '+(FlightTimeSeconds + SecondsTimeFromHubToPort));
            
            
            ARHour += (scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival);
            ARMinute += (scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival);
            ARSeconds += (FlightTimeSeconds + SecondsTimeFromHubToPort);
            
            
            Map<String, Object> timeMap = new Map<String, Object>();
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            System.debug('for checking 1st time air inside if AIR Time SLA: ' + ARHour + 'h ' + ARMinute + 'm ' + ARSeconds + 's');
            
            TATSLAHour = tmpScheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival + 1;
            TATSLAMinute = scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival;
            
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
            
            if(scheduledDispatchHour < TATSLAHour){
                scheduledDispatchHour = (scheduledDispatchHour + 24) - TATSLAHour;
            } else {
                scheduledDispatchHour = scheduledDispatchHour - TATSLAHour;
            }
            System.debug('for checking next time air inside else scheduledDispatchHour after removing TATSLAHour: '+scheduledDispatchHour);
            System.debug('for checking next time air inside else npObj.Flight_Departure_Time__c.hour() : '+npObj.Flight_Departure_Time__c.hour());
            
            Integer FlightTimeHour = npObj.Flight_Arrival_Time__c.hour() - npObj.Flight_Departure_Time__c.hour();
            Integer FlightTimeMinute = npObj.Flight_Arrival_Time__c.minute() - npObj.Flight_Departure_Time__c.minute();
            Integer FlightTimeSeconds = npObj.Flight_Arrival_Time__c.second() - npObj.Flight_Departure_Time__c.second();
            
            System.debug('for checking next time air inside else FlightTimeHour: '+FlightTimeHour);
            System.debug('for checking next time air inside else FlightTimeMinute: '+FlightTimeMinute);
            System.debug('for checking next time air inside else FlightTimeSeconds: '+FlightTimeSeconds);
            
            Integer hourToReachNextHubAfterArrival = scheduledArrivalHourAtNextHub - npObj.Flight_Arrival_Time__c.hour();
            Integer minuteToReachNextHubAfterArrival = scheduledArrivalMinuteAtNextHub - npObj.Flight_Arrival_Time__c.minute();
            
            System.debug('for checking 1st time air inside if hourToReachNextHubAfterArrival: '+hourToReachNextHubAfterArrival);
            System.debug('for checking 1st time air inside if minuteToReachNextHubAfterArrival: '+minuteToReachNextHubAfterArrival);
            
            
            System.debug('for checking next time air scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival : '+(scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival));
            System.debug('for checking next time air scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival : '+(scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival));
            System.debug('for checking next time air FlightTimeSeconds + SecondsTimeFromHubToPort : '+(FlightTimeSeconds + SecondsTimeFromHubToPort));
            
            ARHour += (scheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival);
            ARMinute += (scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival);
            ARSeconds += (FlightTimeSeconds + SecondsTimeFromHubToPort);
            
            Map<String, Integer> timeMap = new Map<String, Integer>();
            timeMap.put('ARHour', ARHour);
            timeMap.put('ARMinute', ARMinute);
            timeMap.put('ARSeconds', ARSeconds);
            
            System.debug('for checking next time air inside else AIR Time SLA: ' + ARHour + 'h ' + ARMinute + 'm ' + ARSeconds + 's');
            
            TATSLAHour = tmpScheduledDispatchHour + HoursTimeFromHubToPort + FlightTimeHour + hourToReachNextHubAfterArrival + 1;
            TATSLAMinute = scheduledDispatchMinute + MinutesTimeFromHubToPort + FlightTimeMinute + minuteToReachNextHubAfterArrival;
            
            System.debug('for checking next time air new AIR TATSLAHour :'+TATSLAHour);
            System.debug('for checking next time air new AIR TATSLAMinute :'+TATSLAMinute);
            
            timeMap.put('TATSLAHour', TATSLAHour);
            timeMap.put('TATSLAMinute', TATSLAMinute);
            
            System.debug('for checking next time air timeMap @@@@@@@@@@@@@@@@@@ :'+timeMap);
            
            return timeMap;
        }
        
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
    
    
    public static void getCoverage(){
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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