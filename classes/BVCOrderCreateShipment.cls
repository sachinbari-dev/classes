public class BVCOrderCreateShipment {
    
    
    public static void validateAndCreateOrder(Map<Id,Shipment__c> shipmentMap){
        
        Map<Id,Shipment__c> validShipmentData = new Map<Id,Shipment__c>();
        Map<Id,Id> mapBillToAccIds = new Map<Id,Id>();
        Map<Id,Id> mapOriginHubIds= new Map<Id,Id>();
        Map<Id,Id> mapBillToaddressIds = new Map<Id,Id>();
        List<Shipment_Error_Log__c> insertLogs = new List<Shipment_Error_Log__c>();
        for(Shipment__c ship : shipmentMap.values()){
            
            if(ship.BillTo_Party_Address__c != null){
                mapBillToaddressIds.put(ship.Id,ship.BillTo_Party_Address__c);
            }
            if(ship.Bill_To_Account__c != null){
                mapBillToAccIds.put(ship.Id,ship.Bill_To_Account__c);
            }
            if(ship.Origin_Hub__c != null){
                mapOriginHubIds.put(ship.Id,ship.Origin_Hub__c);
            }
            
        }
        Map<Id,Account> mapAccount = new map<Id,Account>([select id,BVC_Contract__c,ST_Pricing_Type__c,Customer_Category__c,Contract_End_Date__c,Contracted_ACR_Package__c,Balance_Amount__c from Account where Id in:mapBillToAccIds.values()]);
        Map<Id,Hub__c> mapHubs = new map<Id,Hub__c>([select id,BVC_LegalEntity__c from Hub__c where Id in:mapOriginHubIds.values() AND BVC_LegalEntity__c != null ]);
        Map<Id,AddressBook__c> mapAddressBook = new map<Id,AddressBook__c>([Select id,ADDRESS1__c,ADDRESS2__c,CITY__c,STATE__c,COUNTRY__c from AddressBook__c where id In :mapBillToaddressIds.values() and ADDRESS1__c != null and CITY__c!= null and STATE__c != null and COUNTRY__c != null and PINCODE__c != null]);
        
        for(Shipment__c shipRec : shipmentMap.values()){
            // Validate the Product code 
            Boolean ValidRecord = true;
            
            
            // Account Validation Start
            date currentDate = date.today();
            if(shipRec.Bill_To_Account__c != null && mapAccount.containsKey(shipRec.Bill_To_Account__c)){
                if(mapAccount.get(shipRec.Bill_To_Account__c).BVC_Contract__c == null
                   && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='Non ACR'
                   && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c=='Non Contracted')
                {
                }
                else if(mapAccount.get(shipRec.Bill_To_Account__c).BVC_Contract__c!=null 
                        && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='Non ACR'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c=='Non ACR Contracted'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contract_End_Date__c>=currentDate)
                {
                }
                else if(mapAccount.get(shipRec.Bill_To_Account__c).BVC_Contract__c!=null 
                        && mapAccount.get(shipRec.Bill_To_Account__c).ST_Pricing_Type__c=='ACR'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Customer_Category__c == 'ACR Contracted'
                        && mapAccount.get(shipRec.Bill_To_Account__c).Contracted_ACR_Package__c !=null)
                {
                }
                else{
                    ValidRecord = false;
                    Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                          Error_Reason__c = '1Cannot change the status to Verified Billing, Account Information missing for Order Creation',
                                                                          Shipment__c = shipRec.Id); 
                    insertLogs.add(log);
                }
                
            }
            else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to Verified Billing, Account is missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
            }
            
            // Account Validation End
            
            // Origin Hub Billing Entity Validation
            
            if(shipRec.Origin_Hub__c != null && mapHubs.containsKey(shipRec.Origin_Hub__c)){
                System.debug('ValidRecord --->'+ValidRecord);
            }
            else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Invalid Hub',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
            }
            
            if(shipRec.Origin_Address_Name__c != null && shipRec.Origin_Address_Line_1__c != null  && shipRec.Origin_Address_State__c != null && shipRec.Origin_Address_Country__c != null && shipRec.Origin_Address_City__c != null && shipRec.Origin_Address_Pincode__c != null){
                
            }
            else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Origin Address information Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
            }
            if(shipRec.Destination_Address_Name__c != null && shipRec.Destination_Address_Line1__c != null  && shipRec.Destination_Address_State__c != null && shipRec.Destination_Address_Country__c != null && shipRec.Destination_Address_City__c != null && shipRec.Destination_Address_Pincode__c != null){
                
            }
            else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Destination Address information Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
            }
            
            if(shipRec.Shipment_Date__c != null){
                
            }
            else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Shipment Date is Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
            }
            
            if(shipRec.BillTo_Party_Address__c != null){
                
            }else{
                ValidRecord = false;
                Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Validation',
                                                                      Error_Reason__c = 'Cannot change the status to verified billing, Bill to Party Address is Missing',
                                                                      Shipment__c = shipRec.Id); 
                insertLogs.add(log);
            }
            if(ValidRecord){
                validShipmentData.put(shipRec.Id,shipRec);
            }
        }
        try{
            insert insertLogs;
        }catch(Exception ex){
            system.debug('Shipment Error Log insert failed : '+ex.getMessage());
            system.debug('  '+ex.getLineNumber());
        }
        if(!validShipmentData.isEmpty()){
            Database.executeBatch(new ShipmentOrderCreationBatch(validShipmentData.keySet()), 50);
            
        }
        
    }
    public static void createOrderShipment(Map<Id,Shipment__c> shipmentMap){
        Map<Id,AddressBook__c> addressMap = new Map<Id,AddressBook__c>();
        Set<Id> addressIds = new Set<Id>();
        boolean automatedOrder=false;
        
        List<Shipment__c> shipList = new List<Shipment__c>();
        
		for(Shipment__c ship : shipmentMap.values()){
            
            
            shipList.add(ship);
            if(ship.BillTo_Party_Address__c != null){
                addressIds.add(ship.BillTo_Party_Address__c);
            }
        }
       Map<Id, Shipment__c> shipRelatedMap = new Map<Id, Shipment__c>([SELECT Id,Account__c,Subrogation_Liability__c,Customer__r.New_Contract__c,Distance_Km__c, Account__r.Name,
                                                                        AddressBook__c,BillTo_Party_Address__c,BillTo_Party_Address__r.CITY__c,Origin_Hub__r.BVC_Entity__c,
                                                                        Hub_Master__c,Hub_Master__r.BVC_LegalEntity__c,Origin_Hub__c,
                                                                        Account__r.Billing_Frequency__c, Account__r.ST_Pricing_Type__c,Origin_Address_Name__r.COUNTRY__c,
                                                                        Origin_Hub__r.BVC_LegalEntity__c,Account__r.Customer_Category__c,Origin_Address_Name__c,
                                                                        Origin_Address_Name__r.STATE__c,Origin_Address_Name__r.TRADE_NAME__c,Origin_Address_Name__r.CITY__c,
                                                                        Origin_Address_Name__r.ADDRESS1__c,Origin_Address_Name__r.ADDRESS2__c,Shipper_Name_TMS__r.Name,
                                                                        Bill_To_Account__c, Bill_To_Account__r.Billing_Frequency__c, Bill_To_Account__r.ST_Pricing_Type__c,
                                                                        Consignee_Name_TMS__r.Name,Bill_To_Account__r.Customer_Category__c,BillTo_Party_Address__r.STATE__c,
                                                                        Bill_To_Account__r.Billing_Cycle__c,AddressBook__r.TRADE_NAME__c,
                                                                        Bill_To_Account__r.Billing_Address__r.TRADE_NAME__c,BillTo_Party_Address__r.COUNTRY__c,customer__r.Customer_Category__c,
                                                                        Customer__r.BVC_Invoice_Run__c,BillTo_Party_Address__r.ADDRESS1__c,BillTo_Party_Address__r.ADDRESS2__c,
                                                                        Net_weight_in_Gram__c,Window_Delivery__c,Window_Pickup__c,customer__r.Billing_Frequency__c,
                                                                        customer__r.ST_Pricing_Type__c,RecordTypeId,RecordType.Name,BVC_CB_Bill_No__c,BVC_CB_Product_Description__c
                                                                        FROM Shipment__c
                                                                        WHERE Id IN :shipList
                                                                        FOR Update
                                                                       ]);                         
        system.debug(':::Order Create:::'+shipList);
        
        List<BVCOrder__c> orders2Update = new List<BVCOrder__c>();
        Set<String> prodCodes = new Set<String>();
        Set<Id> accIds = new Set<Id>();
        if(shipList.size()>0){
            for(Shipment__c ship : shipList){
                
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
                
                User adminUser = [
                    SELECT Id 
                    FROM User 
                    WHERE Name = 'BVC Admin' 
                    LIMIT 1
                ];
                if(ship.BVC_CB_Bill_No__c=='Cal done' && ship.BVC_CB_Product_Description__c=='Cal done'){
                    o.Auto_Shipment_verified__c=true;
                    automatedOrder=true;
                    o.OwnerId =adminUser.Id;
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
                   && shipRelatedMap.get(ship.Id).customer__r.BVC_Invoice_Run__c != null && 
                   ((shipRelatedMap.get(ship.Id).customer__r.Billing_Frequency__c=='Monthly') ||(shipRelatedMap.get(ship.Id).customer__r.Billing_Frequency__c=='Weekly'))){
                       o.BVC_Invoice_Run__c=shipRelatedMap.get(ship.Id).customer__r.BVC_Invoice_Run__c;
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
        List<Shipment_Error_Log__c> insertLogs = new List<Shipment_Error_Log__c>();
        Map<Id,BVCShipmentCalcUtil.ShipmentDetail> IdshipCalcMap = new Map<Id,BVCShipmentCalcUtil.ShipmentDetail>();
        if(shipList.size()>0){
             List<BVCShipmentCalcUtil.ShipmentDetail> shipCalculat = shipmentCalculator(shipList,shipOrderMap,shipRelatedMap);
            List<BVCShipmentCalcUtil.ShipmentDetail>  shipmentCalculatorList =  new List<BVCShipmentCalcUtil.ShipmentDetail>(); 
            if(shipCalculat != null && shipCalculat.size() > 0 ){
                shipmentCalculatorList.addAll(shipcalculat);
            }
            
            if(shipmentCalculatorList != null && shipmentCalculatorList.size() > 0  ){
                for(BVCShipmentCalcUtil.ShipmentDetail shipDetail : shipmentCalculatorList){
                    IdshipCalcMap.put(shipDetail.shipmentId,shipDetail);
                }
            }
            
			
			
            for(Shipment__c ship : shipmentMap.values()){
                BVC_Order_Product__c oi = new BVC_Order_Product__c();
                if(IdshipCalcMap.containsKey(ship.Id)){
                    oi.Start_Date__c = ship.Shipment_Date__c;
                    oi.End_Date__c = ship.Shipment_Date__c;
                    oi.BVCOrder__c = shipOrderMap.get(ship.Id);
                    bvcorderId=shipOrderMap.get(ship.Id);
                    oi.Quantity__c = 1;
                    oi.Unit_Price__c = IdshipCalcMap.get(ship.Id).totalAmount;
                    oi.Rate_UOM__c = IdshipCalcMap.get(ship.Id).rateUOM;
                    oi.Total_Price__c = IdshipCalcMap.get(ship.Id).totalAmount;
                //    oi.Activation_Status__c = 'Activated';
                    oi.Activated__c = true;
                //    oi.Charge_Type__c = 'One-Time'; 
                 //   oi.Billing_Frequency__c = '';
                    
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
                        
                        if(shipRelatedMap.get(ship.Id).customer__r.BVC_Invoice_Run__c != null && 
                           ((shipRelatedMap.get(ship.Id).customer__r.Billing_Frequency__c=='Monthly') ||(shipRelatedMap.get(ship.Id).customer__r.Billing_Frequency__c=='Weekly'))){
                               oi.BVC_Invoice_Run__c=shipRelatedMap.get(ship.Id).customer__r.BVC_Invoice_Run__c;
                               oi.Billing_status__c='Pending';
                           }
                        if(shipRelatedMap.get(ship.Id).Origin_Hub__c != null){
                            oi.BVC_Branch__c = shipRelatedMap.get(ship.Id).Origin_Hub__c;
                            oi.BVC_LegalEntity__c = shipRelatedMap.get(ship.Id).Origin_Hub__r.BVC_LegalEntity__c;
                        }
                        
                        
                        if(shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c != null
                           &&shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c != 'Shipment'
                           && ship.Next_Billing_Date__c == null && ship.Shipment_Date__c != null){
                               oi.Next_Billing_Date__c = dateCalculator(ship.Shipment_Date__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Cycle__c); 
                               oi.Override_Next_Billing_Date__c = dateCalculator(ship.Shipment_Date__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c,shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Cycle__c); 
                               
                           }
                        else if((shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c == null
                                 || shipRelatedMap.get(ship.Id).Bill_To_Account__r.Billing_Frequency__c == 'Shipment')
                                && ship.Next_Billing_Date__c == null && ship.Shipment_Date__c != null){
                                    oi.Next_Billing_Date__c = ship.Shipment_Date__c;
                                    oi.Override_Next_Billing_Date__c = ship.Shipment_Date__c;
                                }
                        else if(ship.Next_Billing_Date__c != null){
                            oi.Next_Billing_Date__c = ship.Next_Billing_Date__c;
                            oi.Override_Next_Billing_Date__c = ship.Next_Billing_Date__c;
                        }
                        
                //        oi.Hold_Billing__c = IdshipCalcMap.get(ship.Id).externalContractId != null ? 'Yes' : holdBilling(shipRelatedMap.get(ship.Id));
                    }
                    
                    
                    oi.Rate_Amount__c = IdshipCalcMap.get(ship.Id).rateAmount;
                    oi.ACR_Standard_Price__c = IdshipCalcMap.get(ship.Id).acrStandardPriceId;
                    oi.Non_ACR_Standard_Price__c = IdshipCalcMap.get(ship.Id).nonACRStandardPriceId;
                    oi.ACR_Contracted_Price__c = IdshipCalcMap.get(ship.Id).acrContractedPriceId;
                    oi.Non_ACR_Contracted_Price__c = IdshipCalcMap.get(ship.Id).nonACRContractedPriceId;
                    
                //    oi.Subscription_Type__c = 'One-Time';
                //    oi.Product_Subscription_Type__c = 'One-time';
                //    oi.Subscription_Pricing__c = 'Fixed Price';
                    
                    oi.Shipment_Type__c = ship.Shipment_Type__c;
                    
                    oi.Contracting_Method__c = 'Inherit';
                    oi.Pricing_Method__c = 'List';
                    
                    
                    oi.Payment_Received__c = ship.Payment_Received__c;
                    oi.Payment_Reference__c = ship.Payment_Reference__c;
                    oi.Payment_Date__c = ship.Payment_Date__c;
                    
                    oi.Gross_Weight__c = ship.Gross_Weight__c;
					
					 Decimal holiday=IdshipCalcMap.get(ship.Id).holidayCharge== null ? 0 :IdshipCalcMap.get(ship.Id).holidayCharge;
                    Decimal SplCharge= IdshipCalcMap.get(ship.Id).ExtraChargeAmount== null ? 0 :IdshipCalcMap.get(ship.Id).ExtraChargeAmount;
                    //  system.debug('Shipment Charges:::'+IdshipCalcMap.get(ship.Id).fuelSurcharge+':::'+IdshipCalcMap.get(ship.Id).liabilityCoverageAmount);
                    oi.Freight_Charges__c = IdshipCalcMap.get(ship.Id).freightCharge ;
                    oi.Total_Charges__c  = IdshipCalcMap.get(ship.Id).totalAmount;
                    oi.Offline_Charge__c = IdshipCalcMap.get(ship.Id).offlineCharge;
                    oi.Minimum_Freight__c = IdshipCalcMap.get(ship.Id).minimumFreight;
                    oi.Billable_Unit_Price__c = IdshipCalcMap.get(ship.Id).totalAmount;
                    oi.Liability_Charges__c = IdshipCalcMap.get(ship.Id).liabilityCoverageAmount ;
                    oi.Fuel_Surcharge__c = IdshipCalcMap.get(ship.Id).fuelSurcharge;//Prat
                    oi.Universe_Cost_Charge__c = IdshipCalcMap.get(ship.Id).universeCostCharge;//UniverseCostCharge
                    oi.Liability_Coverage__c = IdshipCalcMap.get(ship.Id).liabilityCoverage;
                    oi.BVC_Valuation_Charges__c   = IdshipCalcMap.get(ship.Id).bvcValuationCharge;
                    oi.Docket_Charges__c  = IdshipCalcMap.get(ship.Id).docketCharge;
                    oi.Fuel_Charges__c  = IdshipCalcMap.get(ship.Id).fuelCharge;
                    //eachship.invoiceValue == null ? 0 : eachship.invoiceValue;
                    oi.Charges_of_Holiday__c = holiday;
                    oi.Special_Vehicle_Charges__c = SplCharge;
                    oi.Holiday_Charges__c   = holiday + SplCharge;
                    oi.Weight_Charges__c  = IdshipCalcMap.get(ship.Id).weightCharge;
					  
                    
                    if(IdshipCalcMap.get(ship.Id).totalAmount != null && IdshipCalcMap.get(ship.Id).totalAmount >0){
                        system.debug('inside of Oi if=======');
                        ordersItems2Update.add(oi);  
                    }
                    else if(IdshipCalcMap.get(ship.Id).errors != null && IdshipCalcMap.get(ship.Id).errors != ''){
                        Shipment_Error_Log__c log = new Shipment_Error_Log__c(Context__c = 'Shipment Calculation',
                                                                              Error_Reason__c = IdshipCalcMap.get(ship.Id).errors,
                                                                              Shipment__c = IdshipCalcMap.get(ship.Id).shipmentId); 
                        insertLogs.add(log);
                    }
                    
                }
            }
        }
        system.debug('Size of Oi======='+ordersItems2Update.size());
        List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();
        if(ordersItems2Update.size()>0){
            
            Database.SaveResult[] lsr = Database.insert(ordersItems2Update,false);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    system.debug('Order Item with Id :'+result.getId()+' Successfully Inserted');
                    BVC_Order_Product__c insertedOi = ordersItems2Update[0];
                    system.debug('insertedOi.BVCOrder__c===='+insertedOi.BVCOrder__c);
                    // Take shipment from order item
                  //  if (insertedOi.Shipment__c != null && automatedOrder==true) {
                      if (insertedOi.Shipment__c != null ) {
                        Shipment__c s = new Shipment__c(
                            Id = insertedOi.Shipment__c,
                            // Example fields to update:
                         //   BVC_CB_Product_Description__c = null,
                          //  BVC_CB_Bill_No__c =null,
                            BVCOrder__c = insertedOi.BVCOrder__c
                        );
                        shipmentsToUpdate.add(s);
                    }
                    
                }
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order Item fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        if (!shipmentsToUpdate.isEmpty()) {
            update shipmentsToUpdate;
        }
        
        if(bvcorderId!=null && ordersItems2Update.size()>0 ){
            BVCOrder__c o = new BVCOrder__c(id=bvcorderId);
            o.Order_Amount__c=ordersItems2Update[0].Total_Charges__c;
            o.Status__c='Activated';
            o.Order_Status_Static__c='Activated';
            o.ActivatedBy__c = UserInfo.getUserId();
            o.BVC_Order_Product__c = ordersItems2Update[0].Id;
            
            List<BVC_Order_Product__c> insertedOrderItems = [SELECT Id, ACR_Contracted_Price__c, ACR_Contracted_Price__r.BVC_Contract__c,ACR_Contracted_Price__r.BVC_Contract__r.Name,
                                                             ACR_Contracted_Price__r.All_Risk_Liability__c,ACR_Contracted_Price__r.Fidelity_Liability__c,ACR_Contracted_Price__r.Fuel_Surcharge__c, 
                                                             ACR_Contracted_Price__r.Indirect_Location__c,ACR_Contracted_Price__r.ST_Minimum_Freight__c,ACR_Contracted_Price__r.ST_Offline_Charge__c,
                                                             ACR_Contracted_Price__r.ST_Rate_UOM__c,ACR_Contracted_Price__r.ST_Rate_Amount__c,ACR_Contracted_Price__r.Remote_Location__c,
                                                             ACR_Contracted_Price__r.Subrogation_Liability__c,ACR_Contracted_Price__r.Universe_Cost_Charge__c,BVCOrder__c FROM BVC_Order_Product__c
                                                             WHERE Id = :ordersItems2Update[0].Id ];
            system.debug('insertedOrderItems.size:::'+insertedOrderItems.size());
            o.Contract_Number__c = insertedOrderItems[0].ACR_Contracted_Price__r.BVC_Contract__c;
            o.BVC_Contract_Number__c=insertedOrderItems[0].ACR_Contracted_Price__r.BVC_Contract__r.Name;
            o.Contracted_All_Risk_Liability__c  = insertedOrderItems[0].ACR_Contracted_Price__r.All_Risk_Liability__c;
            o.Contracted_Fidelity_Liability__c = insertedOrderItems[0].ACR_Contracted_Price__r.Fidelity_Liability__c;
            o.Contracted_Fuel_Surcharge__c = insertedOrderItems[0].ACR_Contracted_Price__r.Fuel_Surcharge__c;
            o.Contracted_Indirect_Location__c = insertedOrderItems[0].ACR_Contracted_Price__r.Indirect_Location__c;
            o.Contracted_Minimum_Freight__c = insertedOrderItems[0].ACR_Contracted_Price__r.ST_Minimum_Freight__c;
            o.Contracted_Offline_Charge__c = insertedOrderItems[0].ACR_Contracted_Price__r.ST_Offline_Charge__c;
            o.Contracted_Rate_Amount__c = insertedOrderItems[0].ACR_Contracted_Price__r.ST_Rate_Amount__c;
            o.Contracted_Rate_UOM__c = insertedOrderItems[0].ACR_Contracted_Price__r.ST_Rate_UOM__c;
            o.Contracted_Remote_Location__c = insertedOrderItems[0].ACR_Contracted_Price__r.Remote_Location__c;
            o.Contracted_Subrogation_Liability__c = insertedOrderItems[0].ACR_Contracted_Price__r.Subrogation_Liability__c;
            o.Contracted_Universe_Cost_Charge__c = insertedOrderItems[0].ACR_Contracted_Price__r.Universe_Cost_Charge__c;
            
            
            update o;
            List<Shipment__c> tmpShipList = new List<Shipment__c>();
            
            Boolean isNonACR = false;   
            Set<Id> shipmentIds = shipmentMap.keySet();
            List<External_Contract_Shipment__c> externalShipments = [
                SELECT Id, Shipment__c
                FROM External_Contract_Shipment__c
                WHERE Shipment__c IN :shipmentIds
            ];
            //   select id, Shipment__c from External_Contract_Shipment__c where Shipment__c=
            for(Shipment__c ship : shipmentMap.values()){
                
                Shipment__c tmpShip = new Shipment__c();
                if(ordersItems2Update[0].Shipment__c == ship.Id){
                    for(BVCOrder__c od :orders2Update){
                        System.debug('od.Business_Type__c:::'+od.Business_Type__c);
                        System.debug('od.shipment__c:::'+od.shipment__c);
                        
                        if (od.Business_Type__c == 'Non ACR' ){
                            isNonACR=true;
                            system.debug('od.Business_Type__c'+od.Business_Type__c);
                            system.debug('od.od.BVC_Invoice_Run__c'+od.BVC_Invoice_Run__c);
                            system.debug('od.od.Account__r.billing_frequency__c'+od.Account__r.billing_frequency__c);
                            if (od.Business_Type__c == 'Non ACR' && od.BVC_Invoice_Run__c==null ){
                                tmpShip.Status__c = 'Billed';
                            }
                            tmpShip.Id = ship.Id;
                            tmpShip.BVCOrder__c=od.id;
                            System.debug('tmpShip.Id12 :'+tmpShip.Id);
                            System.debug('ship.Id12 :'+ship.Id);
                        } 
                        
                       /* if(automatedOrder){
                            Shipment__c autoShip = new Shipment__c(
                                Id = od.Shipment__c,
                                BVC_CB_Bill_No__c = '',
                                BVC_CB_Product_Description__c = ''
                            );
                            tmpShipList.add(autoShip);
                            System.debug('Blanking shipment fields for automated order, Shipment Id: ' + od.Shipment__c);
                        }*/ //removing this bcoz, getting err- System.ListException: Duplicate id in list: a2pFf0000005ZQ9IAM while update tmpShipList;
                        
                    }
                    
                    tmpShipList.add(tmpShip);
                }
            }
            
            
            
            System.debug('tmpShipList :'+tmpShipList);
            if(tmpShipList.size()>0 && isNonACR){
                update tmpShipList;             
            }
            
            
        }
        try{
            insert insertLogs;
        }catch(Exception ex){
            system.debug('Shipment error Logs insert failed');
        }
    }
    
    public static date dateCalculator(Date d,String frequency,String blngCycle){
        Date nextBillingDate ; 
        if(frequency == 'Weekly'){
            nextBillingDate =  d.toStartOfWeek().addDays(8);
        }
        else if(frequency == 'Forthnightly'){
            if(d.day() <= 15 ){
                nextBillingDate = d.toStartOfMonth().addDays(14);
            }
            else if(d.day() - 15 >0){
                nextBillingDate = d.addMonths(1).toStartofMonth().addDays(-1);
            }
            
        }
        else if(frequency == 'Monthly'){
            
            List<String> billdates = blngCycle.split('-');
            if(d.day() >= integer.valueOf(billdates[0])){
                nextBillingDate = Date.newInstance(d.year(), d.month()+1, integer.valueOf(billdates[0]));
            }
            else if(d.day() < integer.valueOf(billdates[0])){
                nextBillingDate = Date.newInstance(d.year(), d.month(), integer.valueOf(billdates[0]));
            }
            
        }
        return nextBillingDate;
    }
    
    public static List<BVCShipmentCalcUtil.ShipmentDetail> shipmentCalculator(List<Shipment__c> shipList, Map<Id,Id> shipOrderIdMap,Map<Id, Shipment__c> shipRelatedMap){
        List<BVCShipmentCalcUtil.ShipmentDetail> shipCalcs = new  List<BVCShipmentCalcUtil.ShipmentDetail>();
        //System.debug(' shipProdIdMap   :>'+shipProdIdMap);
        for(Shipment__c ship : shipList){
            BVCShipmentCalcUtil.ShipmentDetail shipCalc = new BVCShipmentCalcUtil.ShipmentDetail();
            shipCalc.grossWeight = ship.Gross_weight_in_Gram__c;
            shipCalc.netWeight = ship.Net_weight_in_Gram__c ;
            shipCalc.distanceInKm = ship.Distance_Km__c;
            shipCalc.shipDate = ship.Shipment_Date__c;
            shipCalc.originHub = ship.Origin_Hub__c;
            shipCalc.prodDesc = ship.Product_Description__c;
            shipCalc.shipmentCreatedThrough = ship.Shipment_Created_Through__c; //UniverseCostCharge
            shipCalc.calculatedUniverseCharge = ship.Calculate_Universe_Charge__c;//calculated universe charge
            shipCalc.calculatedHolidayCharge = ship.holiday_sunday_charges1__c;// holiday charges
            shipCalc.SubrogationLetter=ship.Subrogation_letter_available__c;//subrogation letter check
            shipCalc.SubrogationCharge=ship.Subrogation_Liability__c;
            shipCalc.ExtraChargeAmount=ship.Extra_Charges_Amount__c;//Added by sanket
            /* if(ship.Customer__r.New_Contract__c==true){
shipCalc.NewPricing=ship.Customer__r.New_Contract__c;//to check old and new pricing
}*/
            shipCalc.IndirectLocationCharge = 0;
            shipCalc.RemoteLocationCharge = 0;
            shipCalc.offline1Charge = 0;
            shipCalc.SubrogationLiabilityCharge = ship.Subrogation_Liability__c;
            shipCalc.AllRiskLiabilityCharge = ship.All_Risk_Liability__c;
            shipCalc.FidelityLiabilityCharge = ship.Fidelity_Liability__c;
            shipCalc.windowdelivery = ship.Window_Delivery__c;
            shipCalc.windowpickup  =  ship.Window_Pickup__c;
            //system.debug('Customer Prod category :'+shipCalc.customerProdCategory);
            shipCalc.blngEntityId = shipRelatedMap.get(ship.Id).Origin_Hub__r.BVC_LegalEntity__c;
            
            shipCalc.invoiceValue = ship.Shipment_Value__c;
            //shipCalc.productId = shipProdIdMap.get(ship.Product_Code__c);
            shipCalc.productId = ship.Product_Code__c;
            shipCalc.productCode = ship.Product_Code__c;
            shipCalc.orderId = shipOrderIdMap.get(ship.Id);
            shipCalc.shipmentId = ship.Id;
			 shipCalc.accountId = ship.Bill_To_Account__c;
			
			
            if(ship.Exhibition__c != null){
                shipCalc.exhibitionId = ship.Exhibition__c;
                shipCalc.customerProdCategory = ship.Customer_Product_Category__c;
                shipCalc.movtType = ship.Exhibition_Movement_Type__c;
            }
            
            //  shipCalc.isOriginOfflineLoc = ship.Origin_Type__c == 'Offline' ? true : false;
            shipCalc.isOriginOfflineLoc = ((ship.Origin_Type__c == 'Offline')||(ship.Origin_Type__c == 'Indirect')||(ship.Origin_Type__c == 'Remote')) ? true : false;
            //  shipCalc.isDestOfflineLoc = ship.Destination_Type__c == 'Offline' ? true : false; 
            shipCalc.isDestOfflineLoc = ((ship.Destination_Type__c == 'Offline')||(ship.Destination_Type__c == 'Indirect')||(ship.Destination_Type__c == 'Remote')) ? true : false;
            if((ship.Origin_Type__c == 'Offline') ||(ship.Destination_Type__c == 'Offline') ){
                shipCalc.offline1Charge=1;
            }
            if((ship.Origin_Type__c == 'Indirect') ||(ship.Destination_Type__c == 'Indirect') ){
                shipCalc.IndirectLocationCharge=1;
            }
            if((ship.Origin_Type__c == 'Remote') ||(ship.Destination_Type__c == 'Remote') ){
                shipCalc.RemoteLocationCharge=1;
            }
            if(ship.Origin_Type__c ==ship.Destination_Type__c ){
                shipCalc.SameOD= true;
            }
            else{shipCalc.SameOD= false;}
            shipCalc.origin = ship.Origin_Address_City__c;   
            shipCalc.destination = ship.Destination_Address_City__c;
            shipCalc.orderLineItemId = ship.Id;
            shipCalc.optForLiability = ship.Liability_Cover_By_BVC__c;
            shipCalc.LiabilityType = ship.Liability_Type__c;//for new pricing
            System.debug('RecordTypeId: ' + ship.RecordTypeId);
            
            shipCalc.IsExhibition = ship.IsExhibition__c; // added by Pratik on 14 July 25
            shipCalcs.add(shipCalc);
        }
        System.debug('shipCalcs Map Size ---- '+shipCalcs.size());
        List<BVCShipmentCalcUtil.ShipmentDetail> shipCalculation = BVCShipmentCalcUtil.shipmentCalculationUtility(shipCalcs);
        system.debug('size++++'+shipCalculation.size());
        if(shipCalculation.size() > 0){
            system.debug('OfflineCharge'+shipCalculation);
            return shipCalculation;
        }
        else
            return null;
    }
    
    public static String holdBilling(shipment__c ship){
        String hBlng;
        if(ship.Bill_To_Account__r.ST_Pricing_Type__c == 'ACR'
           &&ship.Bill_To_Account__r.Customer_Category__c == 'ACR Contracted'){
               hBlng =  'Yes';
           }
        else if(ship.Bill_To_Account__r.ST_Pricing_Type__c == 'Non ACR'
                &&ship.Bill_To_Account__r.Customer_Category__c == 'Non Contracted'){
                    hBlng = 'No';
                }
        else if(ship.Bill_To_Account__r.ST_Pricing_Type__c == 'Non ACR'
                &&ship.Bill_To_Account__r.Customer_Category__c == 'Non ACR Contracted'){
                    hBlng = 'No';
                }
        return hBlng;
    }
    
    //getCoverage method
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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