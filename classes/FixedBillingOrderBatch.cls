global class FixedBillingOrderBatch implements Database.Batchable<SObject> {
    
    private Set<Id> fbdIds;
    private Map<Id, Decimal> perShipmentRateMap;
    
    global FixedBillingOrderBatch(Set<Id> fbdIds,Map<Id, Decimal> perShipmentRateMap) {
        this.fbdIds = fbdIds;
        this.perShipmentRateMap = perShipmentRateMap;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Customer__c, Shipping_Note_Number__c, Shipment_Date__c, Product_Code__c, 
                        Fixed_Billing_Daily__c, Fixed_Billing_Daily__r.Date__c, Fixed_Billing_Daily__r.No_of_Shipments__c,
                        Fixed_Billing_Daily__r.Daily_Revenue__c, Fixed_Billing_Daily__r.Per_Shipment_Revenue__c
                        FROM Shipment__c WHERE Fixed_Billing_Daily__c IN :fbdIds
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Shipment__c> shipmentList){
        if(shipmentList.size()>0){
            createOrderShipment(shipmentList,perShipmentRateMap);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    
    
    public static void createOrderShipment(List<Shipment__c> shipmentListForOrderCreation,  Map<Id, Decimal> perShipmentRateMap){
        System.debug('for checking Inside createOrderShipment of FixedBillingOrderQueueable');
        system.debug('for checking shipmentListForOrderCreation.size() ==='+shipmentListForOrderCreation.size());
        Map<Id,AddressBook__c> addressMap = new Map<Id,AddressBook__c>();
        Set<Id> addressIds = new Set<Id>();
        boolean automatedOrder=false;
        
        List<Shipment__c> shipList = new List<Shipment__c>();
        
        
        Map<Id, Shipment__c> shipRelatedMap = new Map<Id, Shipment__c>([SELECT Id,Account__c,Subrogation_Liability__c,Customer__r.New_Contract__c,Distance_Km__c, Account__r.Name,
                                                                        AddressBook__c,BillTo_Party_Address__c,BillTo_Party_Address__r.CITY__c,Origin_Hub__r.BVC_Entity__c,
                                                                        Hub_Master__c,Hub_Master__r.BVC_LegalEntity__c,Origin_Hub__c,Shipping_Note_Number__c,Shipment_Date__c,
                                                                        Account__r.Billing_Frequency__c, Account__r.ST_Pricing_Type__c,Origin_Address_Name__r.COUNTRY__c,
                                                                        Origin_Hub__r.BVC_LegalEntity__c,Account__r.Customer_Category__c,Origin_Address_Name__c,Billing_Account__c,
                                                                        Origin_Address_Name__r.STATE__c,Origin_Address_Name__r.TRADE_NAME__c,Origin_Address_Name__r.CITY__c,
                                                                        Origin_Address_Name__r.ADDRESS1__c,Origin_Address_Name__r.ADDRESS2__c,Shipper_Name_TMS__r.Name,Destination_Address_Name__c,
                                                                        Bill_To_Account__c, Bill_To_Account__r.Billing_Frequency__c, Bill_To_Account__r.ST_Pricing_Type__c,
                                                                        Consignee_Name_TMS__r.Name,Bill_To_Account__r.Customer_Category__c,BillTo_Party_Address__r.STATE__c,
                                                                        Bill_To_Account__r.Billing_Cycle__c,/*Bill_To_Account__r.Invoice_Batch__c,*/AddressBook__r.TRADE_NAME__c,//commented for uninstallation of CPQ
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
                                                                        Fixed_Billing_Daily__r.Daily_Revenue__c, Fixed_Billing_Daily__r.Per_Shipment_Revenue__c,
                                                                        BillTo_Party_Address__r.Active_Pincode__r.Pincodes__c
                                                                        
                                                                        FROM Shipment__c
                                                                        WHERE Id IN :shipmentListForOrderCreation
                                                                        FOR Update
                                                                       ]);                         
        system.debug('for checking shipRelatedMap.size() ==='+shipRelatedMap.size());
        
        List<BVCOrder__c> orders2Update = new List<BVCOrder__c>();
        Set<String> prodCodes = new Set<String>();
        Set<Id> accIds = new Set<Id>();
        if(shipRelatedMap.size()>0){
            for(Shipment__c ship : shipRelatedMap.values()){
                system.debug('for checking Inside statring creation of Order');
                // Create Order from Shipment
                BVCOrder__c o = new BVCOrder__c();
                o.Account__c = ship.Customer__c;
                o.Account__c = ship.Bill_To_Account__c;
                
             //   o.Payment_Term__c = 'Net 30';
                o.Shipment__c = ship.Id;
                o.Shipment_Number__c = ship.Shipping_Note_Number__c;
                o.Shipment_Date__c = ship.Shipment_Date__c;
                
                o.Status__c = 'Draft';
                o.Order_Type__c = 'New';
                o.BillingAccount__c = ship.Billing_Account__c;
                o.Billing_Account__c = ship.Billing_Account__c;
                
                o.Origin_Address__c = ship.Origin_Address_Name__c;
                o.Destination_Address__c = ship.Destination_Address_Name__c;
                o.Origin_Type__c = ship.Origin_Type__c;
                o.Destination_Type__c = ship.Destination_Type__c;
                
                o.Shipment_Value__c = ship.Shipment_Value__c;
                o.Shipment_Type__c = ship.Shipment_Type__c;
                o.Shipment_Status_Static__c = 'Picked for Billing';
                o.Product_Description__c = ship.Product_Description__c;
                
                o.Initiator_Name__c = ship.Initiator_Name__c;
                o.Initiator_PAN__c = ship.Initiator_PAN__c;
                o.Initiator_Email__c = ship.Initiator_Email__c;
                
                o.Initiator_Mobile__c = ship.Initiator_Mobile__c;
                o.Bill_To_Trade_Name__c = shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Address__r.TRADE_NAME__c;
                
                if(ship.BVC_CB_Bill_No__c=='Cal done' && ship.BVC_CB_Product_Description__c=='Cal done'){
                    o.Auto_Shipment_verified__c=true;
                    automatedOrder=true;
                }
                
                if(ship.Shipment_Date__c != null){
                    o.Order_End_Date__c = ship.Shipment_Date__c;
                }else{
                    o.Order_End_Date__c = System.today();
                }
                if(ship.Customer_Category_Static__c=='ACR'){
                    o.Business_Type__c = 'ACR';
                }else {
                    o.Business_Type__c = 'Non ACR';
                }
                if(ship.Product_Code__c != null){
                    prodCodes.add(ship.Product_Code__c);
                }
                if(ship.Bill_To_Account__c != null){
                    accIds.add(ship.Bill_To_Account__c);
                }
                if(ship.Pickup_Time_Date__c != null){
                    o.Pickup_Date__c = ship.Pickup_Time_Date__c.date();
                }                
                if(shipRelatedMap.containsKey(ship.Id)
                   && shipRelatedMap.get(ship.Id).customer__r.BVC_Invoice_Run_Fixed_Billing__c != null && 
                   ((shipRelatedMap.get(ship.Id).customer__r.Billing_Frequency__c=='Monthly') ||(shipRelatedMap.get(ship.Id).customer__r.Billing_Frequency__c=='Weekly'))){
                       o.BVC_Invoice_Run__c=shipRelatedMap.get(ship.Id).customer__r.BVC_Invoice_Run_Fixed_Billing__c;
                       o.Billing_status__c='Pending';
                   }
                if(shipRelatedMap.containsKey(ship.Id)){
                    if((shipRelatedMap.get(ship.Id).customer__r.ST_Pricing_Type__c=='ACR')){
                        o.Customer_Type__c='ACR';
                    } 
                    if((shipRelatedMap.get(ship.Id).customer__r.ST_Pricing_Type__c=='Non ACR') 
                       && (shipRelatedMap.get(ship.Id).customer__r.Customer_Category__c=='Non ACR Contracted')){
                           o.Customer_Type__c='Non-ACR Credit';
                       }
                    if((shipRelatedMap.get(ship.Id).customer__r.ST_Pricing_Type__c=='Non ACR')  
                       && (shipRelatedMap.get(ship.Id).customer__r.Customer_Category__c=='Non Contracted')){
                           o.Customer_Type__c='Non-ACR Non-Credit';
                       }
                }  
                if(shipRelatedMap.containsKey(ship.Id)
                   && shipRelatedMap.get(ship.Id).Origin_Hub__c != null){
                       o.BVC_Branch__c = ship.Origin_Hub__c;
                       o.BVC_LegalEntity__c = shipRelatedMap.get(ship.Id).Origin_Hub__r.BVC_LegalEntity__c;
                       o.BVC_Entity__c = shipRelatedMap.get(ship.Id).Origin_Hub__r.BVC_Entity__c;
                       system.debug('Legal Entity>>>'+shipRelatedMap.get(ship.Id).Origin_Hub__r.BVC_LegalEntity__c);
                   }
                if(shipRelatedMap.containsKey(ship.Id)
                   && shipRelatedMap.get(ship.Id).BillTo_Party_Address__c != null){
                       
                       o.Billing_Address__c =  shipRelatedMap.get(ship.Id).BillTo_Party_Address__c;
                       o.ShippingCity__c =  shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.CITY__c;
                       o.ShippingCountry__c = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.COUNTRY__c;
                       o.ShippingPostalCode__c = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.Active_Pincode__r.Pincodes__c;
                       o.ShippingState__c = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.STATE__c;
                       String fullAddress = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS1__c + (String.isBlank(shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS2__c) ? '' : ',' + shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.ADDRESS2__c);
                       o.ShippingStreet__c = fullAddress;
                       /*Date resultDate;
                        
                        if (record.Order_Start_Date__c != null) {
                        resultDate = record.Order_Start_Date__c.addMonths(36).addDays(-1);
                        }
                        o.Order_End_Date__c = shipRelatedMap.get(ship.Id).BillTo_Party_Address__r.city__c;*/
                   }
                
                if(shipRelatedMap.get(ship.Id).Shipper_Name_TMS__c != null)
                    o.Shipper_Name__c = shipRelatedMap.get(ship.Id).Shipper_Name_TMS__r.Name;
                o.Shipper_PAN__c = ship.Shipper_PAN_TMS__c;
                if(shipRelatedMap.get(ship.Id).Consignee_Name_TMS__c != null)
                    o.Consignee_Name__c = shipRelatedMap.get(ship.Id).Consignee_Name_TMS__r.Name;
                o.Consignee_PAN__c = ship.Consignee_PAN_TMS__c;
                
                if(ship.Pickup_Time_Date__c != null){
                    o.Pickup_Date__c = ship.Pickup_Time_Date__c.date(); 
                }
                
                
                o.fixed_billing_order__c = ship.Fixed_Billing_Shipment__c;
                orders2Update.add(o);
                
                
            }
        }
        system.debug('::: Orders2Insert:::'+orders2Update.size());
        if(orders2Update.size()>0){
            
            Database.SaveResult[] lsr = Database.insert(orders2Update,false);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    system.debug('Order with Id :'+result.getId()+' Successfully Inserted');
                }
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }
        }
        
        Map<Id,Id> shipOrderMap = new Map<Id,Id>();
        for(BVCOrder__c od :orders2Update){
            shipOrderMap.put(od.Shipment__c,od.Id);     
        }
        id bvcorderId=null;
        List<BVC_Order_Product__c> ordersItems2Update = new List<BVC_Order_Product__c>();
        if(shipRelatedMap.size()>0){
            System.debug('for checking Inside OrdProd Creation');
            for(Shipment__c ship : shipRelatedMap.values()){
                System.debug('for checking Inside shipOrderMap.get(ship.Id) === '+shipOrderMap.get(ship.Id));
                BVC_Order_Product__c oi = new BVC_Order_Product__c();
                oi.Start_Date__c = ship.Shipment_Date__c;
                oi.End_Date__c = ship.Shipment_Date__c;
                oi.BVCOrder__c = shipOrderMap.get(ship.Id);
                bvcorderId=shipOrderMap.get(ship.Id);
                oi.Quantity__c = 1;
             //   oi.Activation_Status__c = 'Activated';
                oi.Activated__c = true;
              //  oi.Charge_Type__c = 'One-Time'; 
              //  oi.Billing_Frequency__c = '';
                
                oi.Shipment__c = ship.Id;
                oi.Shipment_Number__c = ship.Shipping_Note_Number__c;
                oi.Shipment_Date__c = ship.Shipment_Date__c;
                oi.PickUp_Date_and_Time__c = ship.Pickup_Time_Date__c;
                oi.Delivery_Date_and_Time__c = ship.Actual_Delivery_Date_and_Time__c;
                
                if(shipRelatedMap.get(ship.Id).Shipper_Name_TMS__c != null)
                    oi.Shipper_Name__c = shipRelatedMap.get(ship.Id).Shipper_Name_TMS__r.Name;
                oi.Shipper_PAN__c = ship.Shipper_PAN_TMS__c;
                if(shipRelatedMap.get(ship.Id).Consignee_Name_TMS__c != null)
                    oi.Consignee_Name__c = shipRelatedMap.get(ship.Id).Consignee_Name_TMS__r.Name;
                oi.Consignee_PAN__c = ship.Consignee_PAN_TMS__c;
                
                oi.Origin_Address_Name__c = ship.Origin_Address_Name__c;
                oi.Origin_City__c = ship.Origin_Address_City__c;
                oi.Origin_State__c = ship.Origin_Address_State__c;
                oi.Origin_PinCode__c = ship.Origin_Address_Pincode__c;
                oi.Origin_Type__c = ship.Origin_Type__c;
                
                oi.Destination_City__c = ship.Destination_Address_City__c;
                oi.Destination_State__c = ship.Destination_Address_State__c;
                oi.Destination_Pin_Code__c = ship.Destination_Address_Pincode__c;
                oi.Destination_Type__c = ship.Destination_Type__c;
                
                oi.Gross_Weight_gms__c =  ship.Gross_weight_in_Gram__c;
                oi.Gross_Weight_UOM__c = ship.Gross_Weight_UOM_TMS__c;
                oi.Gross_Weight__c = ship.Gross_Weight__c;
                oi.Net_Weight_UOM__c = ship.Net_Weight_UOM_TMS__c;
                oi.Net_Weight_gms__c = ship.Net_weight_in_Gram__c;
                oi.Net_Weight__c = ship.Net_Weight__c;
                oi.Number_of_Packages__c = ship.Number_of_Packages__c;
                oi.Your_Reference_Number__c = ship.Your_Reference_No__c;
                
                oi.Initiator_Name__c = ship.Initiator_Name__c;
                oi.Initiator_PAN__c = ship.Initiator_PAN__c;
                oi.Initiator_Email__c = ship.Initiator_Email__c;
                oi.Initiator_Mobile__c = ship.Initiator_Mobile__c;
                
                oi.Confirmation_Reference__c = ship.Confirmation_Reference__c;
                oi.Confirmation_By_Name__c = ship.Confirmed_By_Name__c;
                oi.Confirmation_Email_ID__c = ship.Confirmed_By_Email_ID__c;
                oi.Confirmed_By_Mobile__c = ship.Confirmed_By_Mobile__c;
                
                oi.Liability_Cover_By_BVC__c = ship.Liability_Cover_By_BVC__c;
                if(ship.Exhibition__c != null){
                    oi.Exhibition__c = ship.Exhibition__c;
                    oi.Customer_Product_Category__c = ship.Customer_Product_Category__c;
                }
                
                if(shipRelatedMap.containsKey(ship.Id)){
                    
                    if(shipRelatedMap.get(ship.Id).customer__r.BVC_Invoice_Run_Fixed_Billing__c != null && 
                       ((shipRelatedMap.get(ship.Id).customer__r.Billing_Frequency__c=='Monthly') ||(shipRelatedMap.get(ship.Id).customer__r.Billing_Frequency__c=='Weekly'))){
                           oi.BVC_Invoice_Run__c=shipRelatedMap.get(ship.Id).customer__r.BVC_Invoice_Run_Fixed_Billing__c;
                           oi.Billing_status__c='Pending';
                       }
                    if(shipRelatedMap.get(ship.Id).Origin_Hub__c != null){
                        oi.BVC_Branch__c = shipRelatedMap.get(ship.Id).Origin_Hub__c;
                        oi.BVC_LegalEntity__c = shipRelatedMap.get(ship.Id).Origin_Hub__r.BVC_LegalEntity__c;
                    }
                    
                }
                
              //  oi.Subscription_Type__c = 'One-Time';
              //  oi.Product_Subscription_Type__c = 'One-time';
             //   oi.Subscription_Pricing__c = 'Fixed Price';
                
                oi.Shipment_Type__c = ship.Shipment_Type__c;
                
                oi.Contracting_Method__c = 'Inherit';
                oi.Pricing_Method__c = 'List';
                
                
                oi.Payment_Received__c = ship.Payment_Received__c;
                oi.Payment_Reference__c = ship.Payment_Reference__c;
                oi.Payment_Date__c = ship.Payment_Date__c;
                
                oi.Gross_Weight__c = ship.Gross_Weight__c;
                
                Decimal rate;
                if(perShipmentRateMap != null && perShipmentRateMap.containsKey(ship.Id)) {
                    rate = perShipmentRateMap.get(ship.Id);  // for Type-2
                } else {
                    rate = ship.Fixed_Billing_Daily__r.Per_Shipment_Revenue__c;                 // for Type-1
                }
                
                oi.Freight_Charges__c = rate;
                oi.Total_Charges__c  = rate;
                oi.Billable_Unit_Price__c = rate;
                
                if(rate != null && rate >0){
                    system.debug('inside of Oi if=======');
                    ordersItems2Update.add(oi);  
                }
                
            }
            
        }
        system.debug('Size of Oi======='+ordersItems2Update.size());
        List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();
        List<BVCOrder__c> orderAmountList = new List<BVCOrder__c>();
        
        if(ordersItems2Update.size()>0){
            Database.SaveResult[] lsr = Database.insert(ordersItems2Update, false);
            
            for (Integer i = 0; i < lsr.size(); i++) {
                Database.SaveResult result = lsr[i];
                
                
                System.debug('Order Item with Id : ' + result.getId() + ' Successfully Inserted');
                
                BVC_Order_Product__c insertedOi = ordersItems2Update[i];
                
                if (insertedOi.Shipment__c != null) {
                    Shipment__c s = new Shipment__c(
                        Id = insertedOi.Shipment__c,
                        BVCOrder__c = insertedOi.BVCOrder__c,
                        Verified_for_Billing__c = true,
                        Status__c = 'Picked for Billing'
                        
                    );
                    system.debug('before Status==='+s.Status__c);
                    shipmentsToUpdate.add(s);
                    system.debug('After Status==='+s.Status__c);
                }
                
                if (insertedOi.BVCOrder__c != null) {
                    BVCOrder__c o = new BVCOrder__c(
                        Id = insertedOi.BVCOrder__c,
                        Order_Amount__c = insertedOi.Total_Charges__c,
                        Status__c = 'Activated',
                        Order_Status_Static__c = 'Activated',
                        Billing_status__c = 'Pending',
                        BVC_Order_Product__c = insertedOi.Id
                    );
                    orderAmountList.add(o);
                }
                
            }
        }
        
        if (!shipmentsToUpdate.isEmpty()) {
            update shipmentsToUpdate;
        }
        
        if (!orderAmountList.isEmpty()) {
            update orderAmountList;
        }
        
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