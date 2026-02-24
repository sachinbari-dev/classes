global class FixedBillingChildBatch implements Database.Batchable<SObject>, Database.Stateful {

    private List<Id> fbIds;
    private Integer index;
    private Date processDate;

    private Map<Id, List<Shipment__c>> fbToShipments = new Map<Id, List<Shipment__c>>();
    private Map<Id, Fixed_Billing__c> fbMap = new Map<Id, Fixed_Billing__c>();

    global FixedBillingChildBatch(List<Id> fbIds, Integer index, Date processDate) {
        this.fbIds = fbIds;
        this.index = index;
        this.processDate = processDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id currentFbId = fbIds[index];
        return Database.getQueryLocator([
            SELECT Id, Account__c, Subrogation_Liability__c, Customer__r.New_Contract__c, Distance_Km__c, Account__r.Name,
                   AddressBook__c, BillTo_Party_Address__c, BillTo_Party_Address__r.CITY__c, Origin_Hub__r.BVC_Entity__c,
                   Hub_Master__c, Hub_Master__r.BVC_LegalEntity__c, Origin_Hub__c, Shipping_Note_Number__c, Shipment_Date__c,
                   Account__r.Billing_Frequency__c, Account__r.ST_Pricing_Type__c, Origin_Address_Name__r.COUNTRY__c,
                   Origin_Hub__r.BVC_LegalEntity__c, Account__r.Customer_Category__c, Origin_Address_Name__c, Billing_Account__c,
                   Origin_Address_Name__r.STATE__c, Origin_Address_Name__r.TRADE_NAME__c, Origin_Address_Name__r.CITY__c,
                   Origin_Address_Name__r.ADDRESS1__c, Origin_Address_Name__r.ADDRESS2__c, Shipper_Name_TMS__r.Name, Destination_Address_Name__c,
                   Bill_To_Account__c, Bill_To_Account__r.Billing_Frequency__c, Bill_To_Account__r.ST_Pricing_Type__c,
                   Consignee_Name_TMS__r.Name, Bill_To_Account__r.Customer_Category__c, BillTo_Party_Address__r.STATE__c,
                   Bill_To_Account__r.Billing_Cycle__c, /*Bill_To_Account__r.Invoice_Batch__c,*/ AddressBook__r.TRADE_NAME__c,//commented for uninstall CPQ
                   Bill_To_Account__r.Billing_Address__r.TRADE_NAME__c, BillTo_Party_Address__r.COUNTRY__c, Customer__r.Customer_Category__c,
                   Customer__r.BVC_Invoice_Run__c, BillTo_Party_Address__r.ADDRESS1__c, BillTo_Party_Address__r.ADDRESS2__c, Origin_Type__c,
                   Net_weight_in_Gram__c, Window_Delivery__c, Window_Pickup__c, Customer__r.Billing_Frequency__c, Product_Code__c,
                   Customer__r.ST_Pricing_Type__c, RecordTypeId, RecordType.Name, BVC_CB_Bill_No__c, BVC_CB_Product_Description__c, Product_Description__c,
                   Destination_Type__c, Shipment_Value__c, Shipment_Type__c, Initiator_Name__c, Initiator_Email__c, Initiator_Mobile__c,
                   Initiator_PAN__c, Customer_Category_Static__c, Consignee_PAN_TMS__c, Shipper_PAN_TMS__c, Pickup_Time_Date__c, Actual_Delivery_Date_and_Time__c,
                   Destination_Address_Pincode__c, Destination_Address_State__c, Destination_Address_City__c, Origin_Address_Pincode__c,
                   Origin_Address_State__c, Origin_Address_City__c, Your_Reference_No__c, Number_of_Packages__c, Net_Weight__c,
                   Net_Weight_UOM_TMS__c, Gross_Weight__c, Gross_Weight_UOM_TMS__c, Gross_weight_in_Gram__c,
                   Exhibition__c, Liability_Cover_By_BVC__c, Confirmed_By_Mobile__c, Confirmed_By_Email_ID__c, Confirmed_By_Name__c, Confirmation_Reference__c,
                   Payment_Date__c, Payment_Reference__c, Payment_Received__c, Fixed_Billing_Shipment__c, Status__c, Customer__r.BVC_Invoice_Run_Fixed_Billing__c
            FROM Shipment__c
            WHERE Shipment_Date__c = :processDate
              AND Fixed_Billing_Shipment__c = true
              AND Product_Code__c LIKE '%VAL-WC%'
              AND Customer__c = :[SELECT Customer__c FROM Fixed_Billing__c WHERE Id = :currentFbId].Customer__c
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Shipment__c> scope) {
        if (scope.isEmpty()) return;

        /*Id currentFbId = fbIds[index];

        Fixed_Billing__c fb = [
            SELECT Id, Name, Billing_Type__c, Monthly_Billing__c, Max_Shipment_Limit__c, Extra_Charge__c, Customer__c
            FROM Fixed_Billing__c
            WHERE Id = :currentFbId
            LIMIT 1
        ];

        fbMap.put(fb.Id, fb);
        if (!fbToShipments.containsKey(fb.Id)) {
            fbToShipments.put(fb.Id, new List<Shipment__c>());
        }
        fbToShipments.get(fb.Id).addAll(scope);*/
        
        // Group shipments by Customer Id
        for (Shipment__c s : scope) {
            Id custId = s.Customer__c;
            if (!fbToShipments.containsKey(custId)) {
                fbToShipments.put(custId, new List<Shipment__c>());
            }
            fbToShipments.get(custId).add(s);
        }
    }

    /*
    global void finish(Database.BatchableContext bc) {
        Id currentFbId = fbIds[index];
        List<Shipment__c> shipments = fbToShipments.get(currentFbId);

        if (shipments != null && !shipments.isEmpty()) {
            Fixed_Billing__c fb = fbMap.get(currentFbId);
            Decimal dailyRevenue = 0;
            Decimal perShipmentValue = 0;

            if (fb.Billing_Type__c == 'Type1') {
                Integer workingDays = FixedBillingBatch.getWorkingDays(processDate.year(), processDate.month(), shipments);
                dailyRevenue = fb.Monthly_Billing__c / workingDays;
                perShipmentValue = dailyRevenue / shipments.size();

                FixedBillingBatch.createOrderShipment(
                    shipments, perShipmentValue, null, null, new Map<Id, Shipment__c>(shipments)
                );
            } else if (fb.Billing_Type__c == 'Type2') {
                Integer maxLimit = (fb.Max_Shipment_Limit__c != null) ? Integer.valueOf(fb.Max_Shipment_Limit__c) : 0;
                Decimal monthlyBilling = fb.Monthly_Billing__c;
                Decimal extraCharge = fb.Extra_Charge__c;
                Decimal baseRate = (maxLimit > 0) ? (monthlyBilling / maxLimit) : 0;

                shipments.sort();
                Integer count = 0;
                Map<Id, Decimal> perShipmentRateMap = new Map<Id, Decimal>();

                for (Shipment__c s : shipments) {
                    count++;
                    perShipmentRateMap.put(s.Id, (count <= maxLimit) ? baseRate : extraCharge);
                }

                FixedBillingBatch.createOrderShipment(
                    shipments, null, perShipmentRateMap, fb.Id, new Map<Id, Shipment__c>(shipments)
                );
            }

            insert new Fixed_Billing_Daily__c(
                Name = fb.Name + ' - Daily Billing - ' + processDate.format(),
                Fixed_Billing__c = fb.Id,
                Date__c = processDate,
                No_of_Shipments__c = shipments.size(),
                Daily_Revenue__c = dailyRevenue,
                Per_Shipment_Revenue__c = perShipmentValue
            );
        }

        // 🚀 Schedule next FB’s child batch
        if (index + 1 < fbIds.size()) {
            Database.executeBatch(new FixedBillingChildBatch(fbIds, index + 1, processDate), 100);
        }

        System.debug('✅ Finished child batch for FB: ' + currentFbId);
    }
    */
    
    global void finish(Database.BatchableContext bc) {
        // Current FB
        Id currentFbId = fbIds[index];
        
        // Get the FB record
        Fixed_Billing__c fb = [
            SELECT Id, Name, Customer__c, Billing_Type__c, Monthly_Billing__c, Max_Shipment_Limit__c, Extra_Charge__c
            FROM Fixed_Billing__c
            WHERE Id = :currentFbId
            LIMIT 1
        ];
        
        // Get shipments for this FB via its Customer
        List<Shipment__c> shipments = fbToShipments.get(fb.Customer__c);
        
        if (shipments != null && !shipments.isEmpty()) {
            Decimal dailyRevenue = 0;
            Decimal perShipmentValue = 0;
            
            if (fb.Billing_Type__c == 'Type1') {
                Shipment__c sampleShip = shipments[0];
              //  Integer workingDays = FixedBillingBatch.getWorkingDays(sampleShip.Shipment_Date__c, sampleShip.Origin_Address_State__c);
              //  dailyRevenue = fb.Monthly_Billing__c / workingDays;
                perShipmentValue = dailyRevenue / shipments.size();
                
           //     FixedBillingBatch.createOrderShipment(shipments, perShipmentValue, null, null, new Map<Id, Shipment__c>(shipments));
            } else if (fb.Billing_Type__c == 'Type2') {
                Integer maxLimit = (fb.Max_Shipment_Limit__c != null) ? Integer.valueOf(fb.Max_Shipment_Limit__c) : 0;
                Decimal monthlyBilling = fb.Monthly_Billing__c;
                Decimal extraCharge = fb.Extra_Charge__c;
                Decimal baseRate = (maxLimit > 0) ? (monthlyBilling / maxLimit) : 0;
                
                shipments.sort();
                Integer count = 0;
                Map<Id, Decimal> perShipmentRateMap = new Map<Id, Decimal>();
                
                for (Shipment__c s : shipments) {
                    count++;
                    perShipmentRateMap.put(s.Id, (count <= maxLimit) ? baseRate : extraCharge);
                }
                
             //   FixedBillingBatch.createOrderShipment(shipments, null, perShipmentRateMap, fb.Id, new Map<Id, Shipment__c>(shipments));
            }
            
            insert new Fixed_Billing_Daily__c(
                Name = fb.Name + ' - Daily Billing - ' + processDate.format(),
                Fixed_Billing__c = fb.Id,
                Date__c = processDate,
                No_of_Shipments__c = shipments.size(),
                Daily_Revenue__c = dailyRevenue,
                Per_Shipment_Revenue__c = perShipmentValue
            );
        }
        
        if (index + 1 < fbIds.size()) {
            Database.executeBatch(new FixedBillingChildBatch(fbIds, index + 1, processDate), 100);
        }
        
        System.debug('✅ Finished child batch for FB: ' + currentFbId);
    }

}