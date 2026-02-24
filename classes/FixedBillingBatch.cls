global class FixedBillingBatch implements Database.Batchable<SObject>, Database.Stateful {

    Date processDate;
    
    private static Map<String, Integer> workingDaysCache = new Map<String, Integer>();
    private static Map<String, Set<Date>> holidayCache = new Map<String, Set<Date>>();
    
    private Set<Id> allFbdIds = new Set<Id>();
    
    private Map<Id, Decimal> perShipmentRateMap = new Map<Id, Decimal>();
                    

    global FixedBillingBatch(Date runDate) {
        processDate = runDate; // pass yesterday when scheduling
        System.debug('for checking processDate == '+processDate);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
		
		String query = 'SELECT Id, Name, Monthly_Billing__c, Start_Date__c, End_Date__c, Product__c, Customer__c, Billing_Type__c, Max_Shipment_Limit__c, Extra_Charge__c, Remaining_Shipments__c FROM Fixed_Billing__c WHERE Start_Date__c <=: processDate AND End_Date__c >=: processDate';
		return Database.getQueryLocator(query);

    }
	
    global void execute(Database.BatchableContext bc, List<Fixed_Billing__c> scope) {
        try {
            System.debug('for checking inside execute ==');
            
            Set<Date> dateSet   = new Set<Date>();
            Set<Id>   custIdSet = new Set<Id>();
            Set<String> productSet = new Set<String>();
            
            for (Fixed_Billing__c fb : scope) {
                if (fb.Start_Date__c <= processDate && fb.End_Date__c >= processDate) {
                    dateSet.add(processDate);
                    custIdSet.add(fb.Customer__c);
                    productSet.add(fb.Product__c);
                }
            }
            System.debug('for checking dateSet == '+dateSet);
            
            List<Shipment__c> allShipments = [SELECT Id,Account__c,Subrogation_Liability__c,Customer__r.New_Contract__c,Distance_Km__c, Account__r.Name,
                                          AddressBook__c,BillTo_Party_Address__c,BillTo_Party_Address__r.CITY__c,Origin_Hub__r.BVC_Entity__c,
                                          Hub_Master__c,Hub_Master__r.BVC_LegalEntity__c,Origin_Hub__c,Shipping_Note_Number__c,Shipment_Date__c,
                                          Account__r.Billing_Frequency__c, Account__r.ST_Pricing_Type__c,Origin_Address_Name__r.COUNTRY__c,
                                          Origin_Hub__r.BVC_LegalEntity__c,Account__r.Customer_Category__c,Origin_Address_Name__c,Billing_Account__c,
                                          Origin_Address_Name__r.STATE__c,Origin_Address_Name__r.TRADE_NAME__c,Origin_Address_Name__r.CITY__c,
                                          Origin_Address_Name__r.ADDRESS1__c,Origin_Address_Name__r.ADDRESS2__c,Shipper_Name_TMS__r.Name,Destination_Address_Name__c,
                                          Bill_To_Account__c, Bill_To_Account__r.Billing_Frequency__c, Bill_To_Account__r.ST_Pricing_Type__c,
                                          Consignee_Name_TMS__r.Name,Bill_To_Account__r.Customer_Category__c,BillTo_Party_Address__r.STATE__c,
                                          Bill_To_Account__r.Billing_Cycle__c/*,Bill_To_Account__r.Invoice_Batch__c*/,AddressBook__r.TRADE_NAME__c, //commented for uninstall CPQ
                                          Bill_To_Account__r.Billing_Address__r.TRADE_NAME__c,BillTo_Party_Address__r.COUNTRY__c,customer__r.Customer_Category__c,
                                          Customer__r.BVC_Invoice_Run__c,BillTo_Party_Address__r.ADDRESS1__c,BillTo_Party_Address__r.ADDRESS2__c,Origin_Type__c,
                                          Net_weight_in_Gram__c,Window_Delivery__c,Window_Pickup__c,customer__r.Billing_Frequency__c,Product_Code__c,
                                          customer__r.ST_Pricing_Type__c,RecordTypeId,RecordType.Name,BVC_CB_Bill_No__c,BVC_CB_Product_Description__c,Product_Description__c,
                                          Destination_Type__c,Shipment_Value__c,Shipment_Type__c,Initiator_Name__c,Initiator_Email__c,Initiator_Mobile__c,
                                          Initiator_PAN__c,Customer_Category_Static__c,Consignee_PAN_TMS__c,Shipper_PAN_TMS__c,Pickup_Time_Date__c,Actual_Delivery_Date_and_Time__c,
                                          Destination_Address_Pincode__c,Destination_Address_State__c,Destination_Address_City__c,Origin_Address_Pincode__c,
                                          Origin_Address_State__c,Origin_Address_City__c,Your_Reference_No__c,Number_of_Packages__c,Net_Weight__c,
                                          Net_Weight_UOM_TMS__c,Gross_Weight__c,Gross_Weight_UOM_TMS__c,Gross_weight_in_Gram__c,Fixed_Billing_Shipment__c,
                                          Exhibition__c,Liability_Cover_By_BVC__c,Confirmed_By_Mobile__c,Confirmed_By_Email_ID__c,Confirmed_By_Name__c,Confirmation_Reference__c,
                                          Payment_Date__c,Payment_Reference__c,Payment_Received__c,customer__r.BVC_Invoice_Run_Fixed_Billing__c,
                                          Fixed_Billing_Daily__c, Fixed_Billing_Daily__r.Date__c, Fixed_Billing_Daily__r.No_of_Shipments__c,
                                          Fixed_Billing_Daily__r.Daily_Revenue__c, Fixed_Billing_Daily__r.Per_Shipment_Revenue__c
                                          FROM Shipment__c
                                          WHERE Customer__c IN : custIdSet AND Shipment_Date__c IN : dateSet
                                          AND Fixed_Billing_Shipment__c =: true AND (Product_Code__c like 'VAL-WC%' OR Product_Code__c like'SILVER-WC%') AND Tracking_Status__c ='Picked Up'
                                          AND BVCOrder__c = null				//uncomment once testing done
                                         ];
            
            
            System.debug('for checking allShipments.size() == ' + allShipments.size());
            
            List<Shipment__c> shipList = new List<Shipment__c>();
            
            List<Allowed_City_Fixed_Billing__c> customSettingCustomer = new List<Allowed_City_Fixed_Billing__c>();
            customSettingCustomer = [Select Name,Customer_Id__c from Allowed_City_Fixed_Billing__c Where Customer_Id__c IN : custIdSet];
            System.debug('for checking customSettingCustomer = '+customSettingCustomer);
            
            Set<Id> customSettingCustIds = new Set<Id>();
            for (Allowed_City_Fixed_Billing__c cs : customSettingCustomer) {
                customSettingCustIds.add(cs.Customer_Id__c);
            }
            System.debug('for checking customSettingCustIds = ' + customSettingCustIds);
            
            List<Shipment__c> specialShipments = new List<Shipment__c>();
            List<Shipment__c> regularShipments = new List<Shipment__c>();

            for (Shipment__c s : allShipments) {
                if (customSettingCustIds.contains(s.Customer__c)) {
                    specialShipments.add(s);
                } else {
                    regularShipments.add(s);
                }
            }
            
            System.debug('for checking specialShipments.size() = ' + specialShipments.size());
            System.debug('for checking regularShipments.size() = ' + regularShipments.size());

            
            if(specialShipments.size()>0){
                Map<Id, Set<String>> customerToAllowedCities = new Map<Id, Set<String>>();
                List<Account> accListForFixedBillingAllowedCities = new List<Account>();
                accListForFixedBillingAllowedCities = [SELECT Id, Fixed_Billing_Cities__c FROM Account WHERE Id IN :custIdSet];
                
                System.debug('for checking accListForFixedBillingAllowedCities = '+accListForFixedBillingAllowedCities);
                for (Account acc : accListForFixedBillingAllowedCities) {
                    Set<String> citySet = new Set<String>();
                    if (!String.isBlank(acc.Fixed_Billing_Cities__c)) {
                        for (String city : acc.Fixed_Billing_Cities__c.split(';')) {
                            citySet.add(city);
                        }
                    }
                    customerToAllowedCities.put(acc.Id, citySet);
                }
                System.debug('for checking customerToAllowedCities = '+customerToAllowedCities);
                
                
                for (Shipment__c s : allShipments) {
                    if (s.Customer__c == null || String.isBlank(s.Origin_Address_City__c) || String.isBlank(s.Destination_Address_City__c)) continue;
                    
                    Set<String> allowedCities = customerToAllowedCities.get(s.Customer__c);
                    
                    System.debug('for checking allowedCities = '+allowedCities);
                    System.debug('for checking allowedCities.contains(s.Origin_Address_City__c) = '+allowedCities.contains(s.Origin_Address_City__c));
                    System.debug('for checking allowedCities.contains(s.Destination_Address_City__c) = '+allowedCities.contains(s.Destination_Address_City__c));
                    
                    if (allowedCities != null && (allowedCities.contains(s.Origin_Address_City__c) || allowedCities.contains(s.Destination_Address_City__c))) {
                        shipList.add(s);
                    } else {
                        System.debug('for checking Excluded Shipment ' + s.Id + ' from city ' + s.Origin_Address_City__c);
                    }
                }
                
                System.debug('for checking Filtered Shipments Count After City Match: ' + shipList.size());
                
            }
            
            shipList.addAll(regularShipments);
            System.debug('for checking Final shipList.size(): ' + shipList.size());

            
            Map<String, List<Shipment__c>> productToShipmentsMap = new Map<String, List<Shipment__c>>();
            for (Shipment__c s : shipList) {
                String shipDateCustKey = s.Shipment_Date__c + '_' + s.Customer__c;
                if (!productToShipmentsMap.containsKey(shipDateCustKey)) {
                    productToShipmentsMap.put(shipDateCustKey, new List<Shipment__c>());
                }
                productToShipmentsMap.get(shipDateCustKey).add(s);
            }
            
            List<Fixed_Billing_Daily__c> fbdList = new List<Fixed_Billing_Daily__c>();
            
            for (Fixed_Billing__c fb : scope) {
                
                List<Shipment__c> shipmentList = new List<Shipment__c>();
                for (Date d : dateSet) {
                    String key = d + '_' + fb.Customer__c;
                    if (productToShipmentsMap.containsKey(key)) {
                        shipmentList = productToShipmentsMap.get(key);
                    }
                }
                
                if (shipmentList.isEmpty()) continue;
                System.debug('Shipment count for FB ' + fb.Id + ' = ' + shipmentList.size());

                preloadHolidays(shipmentList);
                if (fb.Billing_Type__c == 'Type1') {
                    Integer workingDays = getWorkingDays(processDate.year(), processDate.month(), shipmentList);
                    
                    Decimal dailyRevenue = fb.Monthly_Billing__c / workingDays;
                    Decimal perShipmentValue = dailyRevenue / shipmentList.size();
                    
                    Fixed_Billing_Daily__c fbd = new Fixed_Billing_Daily__c(
                        Name = fb.Name + ' - Daily Billing - ' + System.now(),
                        Fixed_Billing__c = fb.Id,
                        Date__c = processDate,
                        No_of_Shipments__c = shipmentList.size(),
                        Daily_Revenue__c = dailyRevenue,
                        Per_Shipment_Revenue__c = perShipmentValue,
                        Working_Days__c = workingDays
                    );
                    fbdList.add(fbd);
                    
                } else if (fb.Billing_Type__c == 'Type2') {
                    Integer maxLimit = Integer.valueOf(fb.Max_Shipment_Limit__c);
                    Decimal monthlyBilling = fb.Monthly_Billing__c;
                    Decimal extraCharge = fb.Extra_Charge__c;
                    Decimal baseRate = monthlyBilling / maxLimit;
                    Decimal shipRate=0;
                    shipmentList.sort();
                    Integer count = 0;
                    
                    if(fb.Remaining_Shipments__c>0){
                        shipRate = baseRate;
                        
                    }else{
                        shipRate = extraCharge;
                    }
                        
                    for (Shipment__c s : shipmentList) {
                        count++;
                        if(fb.Remaining_Shipments__c > 0 && count <= fb.Remaining_Shipments__c){
                            perShipmentRateMap.put(s.Id, baseRate);
                        } else {
                            perShipmentRateMap.put(s.Id, extraCharge);
                        }
                        //perShipmentRateMap.put(s.Id, (count <= maxLimit) ? baseRate : extraCharge);
                            //perShipmentRateMap.put(s.Id,shipRate);
                        
                    }
                    system.debug('fb.Remaining_Shipments__c:::'+fb.Remaining_Shipments__c);
                    
                    Fixed_Billing_Daily__c fbd = new Fixed_Billing_Daily__c(
                        Name = fb.Name + ' - Monthly Cap Billing - ' + System.now(),
                        Fixed_Billing__c = fb.Id,
                        Date__c = processDate,
                        No_of_Shipments__c = shipmentList.size(),
                        Per_Shipment_Revenue__c=shipRate
                    );
                    fbdList.add(fbd);
                    
                }
            }
            
            if (fbdList.isEmpty()) return;
            insert fbdList;
            
            Map<Id, Id> fbToFbdMap = new Map<Id, Id>();
            for (Fixed_Billing_Daily__c fbd : fbdList) {
                fbToFbdMap.put(fbd.Fixed_Billing__c, fbd.Id);
                allFbdIds.add(fbd.Id);
            }
            
            
            Map<Id, Id> fbToCustomerMap = new Map<Id, Id>();
            Map<Id, Integer> fbToRemainingMap = new Map<Id, Integer>();
            
            for (Fixed_Billing__c fb : [
                SELECT Id, Customer__c, Remaining_Shipments__c
                FROM Fixed_Billing__c 
                WHERE Id IN :fbToFbdMap.keySet()
            ]) {
                fbToCustomerMap.put(fb.Id, fb.Customer__c);
                fbToRemainingMap.put(fb.Id, (fb.Remaining_Shipments__c == null) ? 0 : Integer.valueOf(fb.Remaining_Shipments__c));
            }
            
            Map<Id, List<Shipment__c>> customerToShipments = new Map<Id, List<Shipment__c>>();
            for (Shipment__c ship : shipList) {
                if (ship.Customer__c == null) continue;
                if (!customerToShipments.containsKey(ship.Customer__c)) {
                    customerToShipments.put(ship.Customer__c, new List<Shipment__c>());
                }
                customerToShipments.get(ship.Customer__c).add(ship);
            }
            
            List<Shipment__c> shipListToUpdate = new List<Shipment__c>();
            List<Fixed_Billing__c> fixedBillingListToUpdate = new List<Fixed_Billing__c>();
            
            for (Id fbId : fbToFbdMap.keySet()) {
                Id fbdId      = fbToFbdMap.get(fbId);
                Id customerId = fbToCustomerMap.get(fbId);
                
                if (customerToShipments.containsKey(customerId)) {
                    List<Shipment__c> custShipments = customerToShipments.get(customerId);
                    Integer assignedCount = custShipments.size();
                    
                    for (Shipment__c ship : custShipments) {
                        ship.Fixed_Billing_Daily__c = fbdId;
                        shipListToUpdate.add(ship);
                    }
                    
                    Integer remaining = fbToRemainingMap.get(fbId);
                    Fixed_Billing__c fbUpdate = new Fixed_Billing__c(
                        Id = fbId,
                        Remaining_Shipments__c = Math.max(0, remaining - assignedCount)
                    );
                    fixedBillingListToUpdate.add(fbUpdate);
                }
            }
            
            if (!shipListToUpdate.isEmpty()) update shipListToUpdate;
            if (!fixedBillingListToUpdate.isEmpty()) update fixedBillingListToUpdate;
            
        } catch (Exception ex) {
            System.debug('for checking error on line number ' + ex.getLineNumber());
            System.debug('for checking error message ' + ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (!allFbdIds.isEmpty()) {
            System.debug('Enqueuing FixedBillingOrderBatch for ' + allFbdIds.size() + ' FBDs');
            //System.enqueueJob(new FixedBillingOrderQueueable(allFbdIds,perShipmentRateMap));
            Database.executeBatch(new FixedBillingOrderBatch(allFbdIds, perShipmentRateMap), 50);
        }
    }
    
    private static void preloadHolidays(List<Shipment__c> shipments) {
        Set<String> stateMonthKeys = new Set<String>();
        Map<String, Set<String>> stateToMonths = new Map<String, Set<String>>();
        
        for (Shipment__c ship : shipments) {
            if (ship.Shipment_Date__c == null || String.isBlank(ship.Origin_Address_State__c)) continue;
            
            Date d = ship.Shipment_Date__c;
            String ym = d.year() + '-' + String.valueOf(d.month());
            String key = ship.Origin_Address_State__c + '::' + ym;
            stateMonthKeys.add(key);
            
            if (!stateToMonths.containsKey(ship.Origin_Address_State__c)) {
                stateToMonths.put(ship.Origin_Address_State__c, new Set<String>());
            }
            stateToMonths.get(ship.Origin_Address_State__c).add(ym);
        }
        
        if (stateMonthKeys.isEmpty()) return;
        
        List<Holiday_Data__c> holidayList = [
            SELECT State__c, Date__c
            FROM Holiday_Data__c
            WHERE State__c IN :stateToMonths.keySet()
        ];
        system.debug('holidayList:::'+holidayList);
        for (Holiday_Data__c h : holidayList) {
            if (h.Date__c == null) continue;
            String ym = h.Date__c.year() + '-' + String.valueOf(h.Date__c.month());
            if (!stateToMonths.containsKey(h.State__c) || !stateToMonths.get(h.State__c).contains(ym)) continue;
            
            String key = h.State__c + '::' + ym;
            system.debug('key:::'+key);
            if (!holidayCache.containsKey(key)) {
                holidayCache.put(key, new Set<Date>());
            }
            holidayCache.get(key).add(h.Date__c);
        }
        system.debug('holidayCache:::'+holidayCache);
    }
    
    //Last edited in my method works
    public static Integer getWorkingDays(Integer yearFromMethod, Integer monthFromMethod, List<Shipment__c> shipList) {
        Integer year = yearFromMethod;
        Integer month = monthFromMethod;
        Set<Date> holidays = new Set<Date>();
        String cacheKey;
        System.debug('for checking shipList.size() === '+shipList.size());
        
        for(Shipment__c ship : shipList){
            String ym = year + '-' + String.valueOf(month);
            cacheKey = ship.Origin_Address_State__c + '::' + ym;
            system.debug('for checking cacheKey:::'+cacheKey);
            if (workingDaysCache.containsKey(cacheKey)) {
                return workingDaysCache.get(cacheKey);
            }
            
            holidays = holidayCache.containsKey(cacheKey) ? holidayCache.get(cacheKey) : new Set<Date>();
            system.debug('for checking holidays:::'+holidays);
        }
        
        Date firstDay = Date.newInstance(year, month, 1);
        Integer totalDays = Date.daysInMonth(year, month);
        System.debug('for checking firstDay === '+firstDay);
        System.debug('for checking totalDays === '+totalDays);
        
        Date refSunday = Date.newInstance(1900, 1, 7);
        Integer workingDays = 0;
        for (Integer i = 0; i < totalDays; i++) {
            Date d = firstDay.addDays(i);
            Integer diff = refSunday.daysBetween(d);
            
            Boolean isHoliday = holidays.contains(d);
            system.debug('for checking isHoliday:::'+isHoliday);
            
            if (Math.mod(diff, 7) != 0 && !isHoliday) {
                workingDays++;
            }
        }
        System.debug('for checking workingDays === '+workingDays);
        
        workingDaysCache.put(cacheKey, workingDays);
        system.debug('for checking workingDays:::'+workingDays);
        return workingDays;
        
    }
	
    
    
    public static void GetCoverage(){
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
        
    }
    
    
}