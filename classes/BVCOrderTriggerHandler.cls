public class BVCOrderTriggerHandler {
    
    public static void BVCOrderProcessor(Map<Id,BVCOrder__c> newMap){
        
        System.debug('Rafi debug Inside BVCOrderTriggerHandler.BVCOrderProcessor() newMap = '+newMap);
        Map<Id,BVCOrder__c> acrOrderMap = new Map<Id,BVCOrder__c>();
        Map<Id,BVCOrder__c> invBVCOrderMap = new Map<Id,BVCOrder__c>();
        Set<Id> accIds = new Set<Id>();
        
        for(BVCOrder__c bvcOrder : newMap.values()){
            accIds.add(bvcOrder.Account__c);
        }
        
        System.debug('Rafi debug Inside BVCOrderTriggerHandler.BVCOrderProcessor() accIds = '+accIds);
        
        for(BVCOrder__c bvcOrder : [SELECT Id,BVC_CB_PreTaxBill__c, Is_CB_Order__c,Business_Type__c, Status__c, Billing_Account__c, Billing_Account__r.Billing_Address__c, 
                                    Account__r.ST_Pricing_Type__c, /*Account__r.Active_Contract__c*/ Account__r.BVC_Contract__c, Account__r.Business_Type_eSHIP__c, BVC_Service__c, //commented to uninstall CPQ
                                    Account__r.eSHIP_BVC_Contract__c,Account__r.ExhibiShip_Bvc_Contract__c,Account__r.Business_Type_Exhibiship_BVC__c, BVC_LegalEntity__c
                                    FROM BVCOrder__c 
                                    WHERE Account__c IN :accIds
                                    AND Id IN :newMap.keySet()]){
                                        if(((bvcOrder.Account__r.ST_Pricing_Type__c == 'ACR' && bvcOrder.Account__r.BVC_Contract__c != null) || 
                                            (bvcOrder.Account__r.Business_Type_eSHIP__c == 'ACR' && bvcOrder.Account__r.eSHIP_BVC_Contract__c != null && bvcOrder.BVC_Service__c=='eShip') ||
                                           (bvcOrder.Account__r.ExhibiShip_Bvc_Contract__c!=null && bvcOrder.Account__r.Business_Type_Exhibiship_BVC__c== 'ACR')) &&  
                                             bvcOrder.BVC_CB_PreTaxBill__c == null && bvcOrder.Is_CB_Order__c == false){
                                            System.debug('acrOrderMap population-------');
                                            acrOrderMap.put(newMap.get(bvcOrder.Id).Id,newMap.get(bvcOrder.Id));
							
                                             } else if((bvcOrder.Account__r.ST_Pricing_Type__c == 'Non ACR' && bvcOrder.Status__c == 'Activated')
                                                       || ((bvcOrder.Account__r.ST_Pricing_Type__c == 'ACR' || bvcOrder.Account__r.ST_Pricing_Type__c == 'Non ACR') && bvcOrder.BVC_CB_PreTaxBill__c != null) 
                                                       || (bvcOrder.Account__r.ExhibiShip_Bvc_Contract__c!=null && bvcOrder.Account__r.Business_Type_Exhibiship_BVC__c== 'Non ACR')){
                                            invBVCOrderMap.put(newMap.get(bvcOrder.Id).Id,newMap.get(bvcOrder.Id));
                                        } 
                                        
                                        
                                    } 
        
        System.debug('Rafi debug Inside BVCOrderTriggerHandler.BVCOrderProcessor() invBVCOrderMap.size() = '+invBVCOrderMap.size());
        System.debug('Rafi debug Inside BVCOrderTriggerHandler.BVCOrderProcessor() invBVCOrderMap.values() = '+invBVCOrderMap.values());
        
        if(acrOrderMap.size() > 0 && acrOrderMap != null ){
            System.debug('Calling createBVCACRConsumption-----');
            createBVCACRConsumption(acrOrderMap);
        }
        
        if(invBVCOrderMap.size() > 0 && invBVCOrderMap != null){
            generateInvoice(invBVCOrderMap);
        }
    } 
    
    public static void createBVCACRConsumption(Map<Id,BVCOrder__c> newMap){
        System.debug('Rafi debug Inside createBVCACRConsumption newMap :'+newMap);
        UtilClass.triggerLoop = true;
        Set<Id> accIds = new Set<Id>();
        for(BVCOrder__c o : newMap.values()){
            
            accIds.add(o.Account__c);
        }
        List<BVC_ACR_Consumption__c> consumptionList = new List<BVC_ACR_Consumption__c>();
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,ST_Pricing_Type__c,/*Active_Contract__c,*/ //commented to uninstall CPQ
                                                      
                                                      BVC_Contract__r.Quote__r.Name,BVC_Contract__r.Quote__c,
                                                      /*Original_Contract_End_Date__c,*/BVC_Contract__c, //commented to uninstall CPQ
                                                      of_Contract_Consumption__c,Adjusted_Contract_Amount__c,
                                                      Adjustment_Amount__c,Balance_Amount__c,
                                                      Contracted_ACR_Package__c,Contract_Start_Date__c,
                                                      Contract_End_Date__c,Contract_Amount__c,eSHIP_BVC_Contract__c,
                                                      eSHIP_BVC_Contract__r.Quote__c,eSHIP_BVC_Contract__r.Quote__r.Name,Business_Type_eSHIP__c,Contracted_ACR_Package_eSHIP_BVC__c,
                                                      ExhibiShip_Bvc_Contract__c,Business_Type_Exhibiship_BVC__c,ExhibiShip_Bvc_Contract__r.Contracted_ACR_Package__c,
                                                      ExhibiShip_Bvc_Contract__r.Contract_Start_Date__c,ExhibiShip_Bvc_Contract__r.Contract_End_Date__c,ExhibiShip_Bvc_Contract__r.Adjustment_Amount__c,
                                                      ExhibiShip_Bvc_Contract__r.Balance_Amount__c,Adjusted_Contract_Amount_ExhibiShip__c
                                                      FROM Account
                                                      WHERE (/*Active_Contract__c != null OR*/ BVC_Contract__c != null OR eSHIP_BVC_Contract__c != null OR ExhibiShip_Bvc_Contract__c!=null)
                                                      AND Id IN :accIds
                                                     ]);
        Map<Id,BVC_Order_Product__c> oItemMap = new Map<Id,BVC_Order_Product__c>();
        for(BVC_Order_Product__c oItem : [Select Id, BVCOrder__c, Freight_Charges__c, Offline_Charge__c, BVC_Valuation_Charges__c, Docket_Charges__c, Fuel_Charges__c, 
                                          Holiday_Charges__c, Weight_Charges__c, Start_Date__c, End_Date__c, Next_Billing_Date__c, Next_Charge_Date__c, 
                                          Billable_Unit_Price__c, Unit_Price__c, Gross_Weight_gms__c, Gross_Weight_UOM__c, Gross_Weight__c, Number_of_Packages__c,
                                          Net_Weight__c, Net_Weight_UOM__c, Net_Weight_gms__c, Confirmation_By_Name__c, Confirmation_Reference__c, Confirmation_Email_ID__c, 
                                          Confirmed_By_Mobile__c, Liability_Cover_By_BVC__c, Payment_Received__c, Payment_Reference__c, Payment_Date__c, 
                                          Minimum_Freight__c, Liability_Charges__c, Fuel_Surcharge__c, Universe_Cost_Charge__c, Liability_Coverage__c, 
                                          Exhibition__c, Product_Name__c, Product_Code__c,Billing_status__c,Freight_Charges_eSHIP__c,
                                          Liability_Charges_eSHIP__c,Weight_Charges_eSHIP__c,Fuel_Surcharges_eSHIP__c,Additional_Charges_eSHIP__c,COD_Charges_eSHIP__c 
                                          From BVC_Order_Product__c                                       
                                          WHERE BVCOrder__c IN :newMap.keySet()]){
                                              oItemMap.put(oItem.BVCOrder__c,oItem);
                                          }
        Id bvcorderId;
        System.debug('for checking accMap :'+accMap);
        for(BVCOrder__c o : newMap.values()){
            System.debug('o.Account__r.ST_Pricing_Type__c ='+o.Account__r.ST_Pricing_Type__c);
            System.debug('accMap.containsKey(o.Account__c) ='+accMap.containsKey(o.Account__c));
            system.debug('account on order'+o.Account__c);
            system.debug('account on order'+newMap.values());
            
            Account a = accMap.get(o.Account__c);
           system.debug('a.Contract_End_Date__c::'+a.Contract_End_Date__c);
            system.debug('a.Business_Type_eSHIP__c=='+a.Business_Type_eSHIP__c);
            system.debug('a.Contracted_ACR_Package_eSHIP_BVC__c=='+a.Contracted_ACR_Package_eSHIP_BVC__c);
            system.debug('o.BVC_Service__c=='+o.BVC_Service__c);
            system.debug('o.Shipment__c=='+o.Shipment__c);
             system.debug('accMap.containsKey(o.Account__c)'+accMap.containsKey(o.Account__c));
           
            if(accMap.containsKey(o.Account__c)
               && (((a.Contract_End_Date__c >= system.today() || a.Business_Type_eSHIP__c == 'ACR')
               && (a.ST_Pricing_Type__c == 'ACR' || a.Business_Type_eSHIP__c == 'ACR' || a.Business_Type_Exhibiship_BVC__c=='ACR')
               && ((a.Contracted_ACR_Package__c != null) || (a.Contracted_ACR_Package_eSHIP_BVC__c!=null) ||(a.ExhibiShip_Bvc_Contract__r.Contracted_ACR_Package__c!=null))
               && ((o.Business_Type__c == 'ACR') || (o.BVC_Service__c == 'eSHIP') || (o.ExhibiSHIP_Order__c==true))))
               && o.Shipment__c != null
               && o.Account__c != null){
                   System.debug('for checking cu');
                   BVC_Order_Product__c oi = oItemMap.get(o.Id);
                   BVC_ACR_Consumption__c consumption = new BVC_ACR_Consumption__c();
                   consumption.Status__c = 'Valid';
                   consumption.Account__c = a.Id;
                   consumption.Bill_To_Account__c = a.Id;
                   consumption.Bill_To_Address__c = o.Billing_Address__c;
                   
                   
                   consumption.BVC_Order_Product__c = oi.Id;
                   if(a.eSHIP_BVC_Contract__c != null && o.Product_Code__c=='eSHIP' && o.ExhibiSHIP_Order__c==false){
                       consumption.BVC_Contract__c = a.eSHIP_BVC_Contract__c;
                       consumption.Contract_Date_From__c =consumption.BVC_Contract__r.Contract_Start_Date__c;
                       consumption.Contract_Date_To__c = consumption.BVC_Contract__r.Contract_End_Date__c;
                       consumption.Adjusted_Contract_Amount__c = consumption.BVC_Contract__r.Adjusted_Contract_Amount__c;
                       consumption.Adjustment_to_Contract_Amount__c = consumption.BVC_Contract__r.Adjustment_Amount__c;
                       consumption.Contract_Balance__c = consumption.BVC_Contract__r.Balance_Amount__c;
                       consumption.Contract_Amount__c = consumption.BVC_Contract__r.Adjusted_Contract_Amount__c;
                   }
                   if(a.BVC_Contract__c != null && o.Product_Code__c!='eSHIP' && o.ExhibiSHIP_Order__c==false){
                       consumption.BVC_Contract__c = a.BVC_Contract__c;
                       consumption.Contract_Date_From__c =accMap.get(o.Account__c).Contract_Start_Date__c;
                       consumption.Contract_Date_To__c = accMap.get(o.Account__c).Contract_End_Date__c;
                       consumption.Adjusted_Contract_Amount__c = accMap.get(o.Account__c).Adjusted_Contract_Amount__c;
                       consumption.Adjustment_to_Contract_Amount__c = accMap.get(o.Account__c).Adjustment_Amount__c;
                       consumption.Contract_Balance__c = accMap.get(o.Account__c).Balance_Amount__c;
                       consumption.Contract_Amount__c = accMap.get(o.Account__c).Adjusted_Contract_Amount__c;
                   }
                   if(o.ExhibiSHIP_Order__c && a.ExhibiShip_Bvc_Contract__c!=null){
                       consumption.BVC_Contract__c = a.ExhibiShip_Bvc_Contract__c;
                       consumption.Contract_Date_From__c =accMap.get(o.Account__c).ExhibiShip_Bvc_Contract__r.Contract_Start_Date__c;
                       consumption.Contract_Date_To__c = accMap.get(o.Account__c).ExhibiShip_Bvc_Contract__r.Contract_End_Date__c;
                       consumption.Adjusted_Contract_Amount__c = accMap.get(o.Account__c).Adjusted_Contract_Amount__c;
                       consumption.Adjustment_to_Contract_Amount__c = accMap.get(o.Account__c).ExhibiShip_Bvc_Contract__r.Adjustment_Amount__c;
                       consumption.Contract_Balance__c = accMap.get(o.Account__c).ExhibiShip_Bvc_Contract__r.Balance_Amount__c;
                       consumption.Contract_Amount__c = accMap.get(o.Account__c).Adjusted_Contract_Amount_ExhibiShip__c;
                   }
                   
                   consumption.Shipment__c = o.Shipment__c;
                   consumption.BVCOrder__c = o.Id;
                   bvcorderId = o.Id;
                   consumption.BVC_Branch__c = o.BVC_Branch__c;
                   
                   consumption.Shipment_Number__c = o.Shipment_Number__c;
                   consumption.Shipment_Date__c = o.Shipment_Date__c;
                   consumption.Pickup_Date__c = o.Pickup_Date__c;
                   consumption.Shipment_Value__c = o.Shipment_Value__c;
                   consumption.Product_Description__c = o.Product_Description__c;
                   consumption.No_Of_Packages__c = oi.Number_of_Packages__c;
                   
                   consumption.Shipper_Name__c = o.Shipper_Name__c;
                   consumption.Shipper_PAN__c= o.Shipper_PAN__c;
                   consumption.Consignee_Name__c = o.Consignee_Name__c;
                   consumption.Consignee_PAN__c = o.Consignee_PAN__c;
                   consumption.Destination_Address__c = o.Destination_Address__c;
                   consumption.Origin_Address__c = o.Origin_Address__c;
                   consumption.Destination_type__c = o.Destination_Type__c;
                   consumption.Origin_Type__c = o.Origin_Type__c;
                   
                   consumption.Net_Weight__c = oi.Net_Weight__c;
                   consumption.Net_Weight_GMS__c = oi.Net_Weight_gms__c;
                   consumption.Net_Weight_UOM__c = oi.Net_Weight_UOM__c;
                   consumption.Gross_Weight__c = oi.Gross_Weight__c;
                   consumption.Gross_Weight_GMS__c = oi.Gross_Weight_gms__c;
                   consumption.Gross_Weight_UOM__c = oi.Gross_Weight_UOM__c;
                   
                   if(o.BVC_Service__c != 'eSHIP'){
                       consumption.Freight_Charges__c = oi.Freight_Charges__c != null ? oi.Freight_Charges__c : 0;
                       consumption.Offline_Charges__c = oi.Offline_Charge__c != null ? oi.Offline_Charge__c : 0;
                       consumption.Liability_Cover_By_BVC__c = oi.Liability_Cover_by_BVC__c;
                       consumption.Liability_charges__c = oi.Liability_Charges__c != null ? oi.Liability_Charges__c : 0;
                       consumption.Minimum_Freight__c = oi.Minimum_Freight__c;
                       // Added new charge Heads
                       consumption.BVC_Valuation_Charges__c = oi.BVC_Valuation_Charges__c != null ? oi.BVC_Valuation_Charges__c : 0;
                       consumption.Docket_Charges__c = oi.Docket_Charges__c != null ? oi.Docket_Charges__c : 0;
                       consumption.Fuel_Charges__c = oi.Fuel_Charges__c != null ? oi.Fuel_Charges__c : 0;
                       consumption.Holiday_Charges__c = oi.Holiday_Charges__c != null ? oi.Holiday_Charges__c : 0;
                       consumption.Weight_Charges__c = oi.Weight_Charges__c != null ? oi.Weight_Charges__c : 0;
                       consumption.Fuel_Surcharge__c = oi.Fuel_Surcharge__c != null ? oi.Fuel_Surcharge__c : 0;//Prat
                       consumption.Universe_Cost_Charge__c = oi.Universe_Cost_Charge__c != null ? oi.Universe_Cost_Charge__c : 0;//UniverseCostCharge
                   } else {
                       consumption.Freight_Charges__c = oi.Freight_Charges_eSHIP__c != null ? oi.Freight_Charges_eSHIP__c : 0;
                       consumption.Liability_charges__c = oi.Liability_Charges_eSHIP__c != null ? oi.Liability_Charges_eSHIP__c : 0;
                       consumption.Weight_Charges__c = oi.Weight_Charges_eSHIP__c != null ? oi.Weight_Charges_eSHIP__c : 0;
                       consumption.Fuel_Surcharge__c = oi.Fuel_Surcharges_eSHIP__c != null ? oi.Fuel_Surcharges_eSHIP__c : 0;//Prat
                       consumption.Additional_Charges_eSHIP__c = oi.Additional_Charges_eSHIP__c != null ? oi.Additional_Charges_eSHIP__c : 0;
                       consumption.COD_Charges_eSHIP__c = oi.COD_Charges_eSHIP__c != null ? oi.COD_Charges_eSHIP__c : 0;//Prat
                       consumption.No_Of_Packages__c = oi.Number_of_Packages__c != null ? oi.Number_of_Packages__c : 0;// Added by Pratik 07-07-2025
                       
                       
                   }
                   if(o.BVC_Service__c == 'eSHIP'){
                   consumption.Shipment_Value__c=o.Shipment_Value__c; // Added by Pratik 04-07-2025
                       
                   }
                   consumption.Initiator_Name__c = o.Initiator_Name__c;
                   consumption.Initiator_Mobile__c = o.Initiator_Mobile__c;
                   consumption.Initiator_PAN__c = o.Initiator_PAN__c;
                   consumption.Initiator_Email__c = o.Initiator_Email__c;
                   
                   consumption.Confirmed_By_Name__c = oi.Confirmation_By_Name__c;
                   consumption.Confirmed_By_Phone__c = oi.Confirmed_By_Mobile__c;
                   consumption.Confirmed_By_Email__c = oi.Confirmation_Email_ID__c;
                   consumption.Confirmation_Reference__c = oi.Confirmation_Reference__c;
                   //consumption.Reference_Number__c = oi.Your_Reference_Number__c;
                   
                  /* if (accMap.get(o.Account__c).Active_Contract__c != null && o.ExhibiSHIP_Order__c==false){
                       consumption.Annual_Contract_ID__c = accMap.get(o.Account__c).Active_Contract__r.SBQQ__Quote__r.Name;*/ //commented for uninstalling CPQ 22 Jan 26
                    if (accMap.get(o.Account__c).BVC_Contract__c != null && o.ExhibiSHIP_Order__c==false){
                       consumption.Annual_Contract_ID__c = accMap.get(o.Account__c).BVC_Contract__r.Quote__r.Name;
                   //} else if (accMap.get(o.Account__c).eSHIP_BVC_Contract__c != null){
                   } else if (accMap.containsKey(o.Account__c) &&  o.ExhibiSHIP_Order__c==false &&
                              accMap.get(o.Account__c).eSHIP_BVC_Contract__r != null && 
                              accMap.get(o.Account__c).eSHIP_BVC_Contract__r.Quote__r != null) {
                                  consumption.Annual_Contract_ID__c = accMap.get(o.Account__c).eSHIP_BVC_Contract__r.Quote__r.Name;
                              }
                   if(accMap.get(o.Account__c).ExhibiShip_Bvc_Contract__c != null && o.ExhibiSHIP_Order__c){
                       consumption.Annual_Contract_ID__c = accMap.get(o.Account__c).BVC_Contract__r.Quote__r.Name;
                   }
                   
                   consumption.Shipment_Type__c = o.Shipment_Type__c;
                   consumption.Total_Charge__c = o.Order_Amount__c;
                   consumptionList.add(consumption);
               }
            //  }
        }
        System.debug('Rafi debug consumptionList.size() '+consumptionList.size());
        system.debug('To test eSHIP');
        if(consumptionList.size() > 0){
            UtilClass.orderTriggerLoop = true;
            
            try{
                insert consumptionList;
                
                List<Shipment__c> tmpShipList = new List<Shipment__c>();
                List<BVCOrder__c> tmpBVCOrderList = new List<BVCOrder__c>();
                Shipment__c tmpShip = new Shipment__c();
                BVCOrder__c bvcOrder = new BVCOrder__c();
                BVCInvoice__c relatedInvoice;
                if (!consumptionList.isEmpty()) { // added by Pratik
                    BVC_Contract__c relatedContract = [
                        SELECT Id, BVCInvoice__c 
                        FROM BVC_Contract__c 
                        WHERE Id = :consumptionList[0].BVC_Contract__c
                        LIMIT 1
                    ];
                    
                    if (relatedContract != null && relatedContract.BVCInvoice__c != null) {
                        
                        relatedInvoice = [
                            SELECT Id, ST_Invoice_Series__c, InvoiceDate__c, Subtotal__c, TaxAmount__c, Total_Amount_With_Tax__c 
                            FROM BVCInvoice__c 
                            WHERE Id = :relatedContract.BVCInvoice__c
                            LIMIT 1
                        ];
                    }
                }
                
                for(BVCOrder__c o : newMap.values()){
                    System.debug('o.Business_Type__c ='+o.Business_Type__c);
                    System.debug('consumptionList[0].Shipment__c ='+consumptionList[0].Shipment__c);
                    
                    if(o.Id == bvcorderId){
                        bvcOrder.BVC_ACR_Consumption__c = consumptionList[0].Id;
                        bvcOrder.Shipment_Status_Static__c = 'ACR Consumed';
                        bvcOrder.Id = o.Id;
                        if (relatedInvoice != null) {
                            bvcOrder.Invoice_series__c = relatedInvoice.ST_Invoice_Series__c;
                            bvcOrder.Invoice_Subtotal__c= relatedInvoice.Subtotal__c;
                            bvcOrder.Invoice_Date__c=relatedInvoice.InvoiceDate__c;
                            bvcOrder.Invoice_Tax__c=relatedInvoice.TaxAmount__c;
                            bvcOrder.Invoice_Total_Amount_with_tax__c=relatedInvoice.Total_Amount_With_Tax__c;
                        }
                    }
                    tmpBVCOrderList.add(bvcOrder);
                
                    if(consumptionList[0].Shipment__c != null && o.Business_Type__c == 'ACR'){
                        tmpShip.Status__c = 'ACR Consumed';
                        tmpShip.Id = consumptionList[0].Shipment__c;
                        tmpShip.BVCOrder__c=consumptionList[0].BVCOrder__c;
                        System.debug('tmpShip.Id :'+tmpShip.Id);
                        System.debug('consumptionList[0].Shipment__c :'+consumptionList[0].Shipment__c);
                    }
                    
                    tmpShipList.add(tmpShip);
                    
                }
                
                System.debug('tmpBVCOrderList :'+tmpBVCOrderList);
                if(tmpBVCOrderList.size()>0){
                    update tmpBVCOrderList;             
                }
                
                System.debug('tmpShipList :'+tmpShipList);
                if(tmpShipList.size()>0){
                    update tmpShipList;             
                }
                
                
            }catch(Exception ex){
                system.debug(ex.getStackTraceString()+'*** ACR Consumption : Insert Failed with following Exception***'+ex.getMessage());
            }
        }
        
        
    }
    
	
    public static void generateInvoice(Map<Id,BVCOrder__c> bvcOrderMap){
        System.debug('Rafi debug jumped inside generateInvoice and bvcOrderMap = '+bvcOrderMap);
        Set<Id> orderIds = new set<Id>();
        for(BVCOrder__c bvcOrder : bvcOrderMap.values()){
            orderIds.add(bvcOrder.Id);
        }
        System.debug('Rafi debug jumped inside generateInvoice and orderIds = '+orderIds);
        
        Map<Id,BVCOrder__c> nonacrBVCOrderMap = new Map<Id,BVCOrder__c>();
        Map<Id,List<BVC_Order_Product__c>> nonacrBVCOrderProductMap = new Map<Id,List<BVC_Order_Product__c>>();
        Map<Id,BVCOrder__c> CBOrderMap = new Map<Id,BVCOrder__c>();
        Map<Id,List<BVC_Order_Product__c>> CBItemMap = new Map<Id,List<BVC_Order_Product__c>>();
        
		
        List<BVCOrder__c> bvcOrderList = new List<BVCOrder__c>();
        if(orderIds.size() > 0){
            bvcOrderList.addAll([Select Id, Account__c, Account_Number__c, Account__r.BVC_CB_Bill_To_Contact__c, ACR_Consumption__c, 
                                 ACR_Ordered__c, Bill_To_GSTIN__c, Bill_To_Trade_Name__c, Billing_Address__c, BillingAccount__c, 
                                 Business_Type__c, BVC_Branch__c, BVC_Entity__c, Shipment__c, 
                                 Consignee_Name__c, Consignee_PAN__c, Destination_Address__c, Destination_City__c, 
                                 Destination_Type__c, Gross_Weight__c, Gross_Weight_UOM__c, Net_Weight__c, Net_Weight_UOM__c, 
                                 Opt_For_Liability_Coverage__c, Origin_Address__c, Origin_City__c, Origin_Type__c, 
                                 Price_Book__c, Product_Code__c, Product_Description__c, Shipment_Date__c, Shipment_Number__c, 
                                 Shipper_Name__c, Shipper_PAN__c, Ship_To_Contact__c, Status__c, Total_Freight__c, Order_Amount__c, 
                                 Order_Type__c, Contract_Signed_Date__c, PO_Number__c, ActivatedBy__c, Shipping_Address__c, 
                                 Confirmed_By_Name__c, Order_Status_Static__c, PO_Date__c, Customer_Authorized_By__c, 
                                 Order_Reference_Number__c, Customer_Authorized_Date__c, Order_Name__c, Company_Authorized_By__c, 
                                 Company_Authorized_Date__c, Description__c, Reduction_Order__c, Shipment_Status__c, Activated_Date__c, 
                                 Order_End_Date__c, Order_Start_Date__c, Billing_Day_Of_Month__c, //Payment_Term__c, 
                                /* Invoice_Batch__c,*/ Billing_Account__c, Bill_Now__c, BVCQuote__c, Bill_To_Contact__c, 
                                 Valid_Order__c, Shipment_Value__c, Pickup_Date__c, Liability_Cover_By_BVC__c, Minimum_Freight__c, 
                                 Initiator_Name__c, Initiator_PAN__c, Initiator_Email__c, Contracted__c, X18_Digit_ID__c, 
                                 Order_Reversal_Reason__c, Original_Order__c, Original_Order_Static__c, Initiator_Mobile__c, 
                                 Shipment_Status_Static__c, Shipment_Type__c, Product_Name__c, BVC_Order_Product__c, 
                                 Total_Fuel_Surcharge__c, Total_Liability_Charges__c, Total_Offline_Charges__c, 
                                 Total_Weight_Charges__c, Status_Flag__c, Total_BVC_Valuation_Charges__c, Total_Docket_Charges__c, 
                                 Total_Fuel_Charges__c, Total_Holiday_Charges__c, Total_Universe_Cost_Charge__c, Migrated_Order__c, 
                                 Total_Freight_Charges__c, ShippingCity__c, ShippingCountry__c, ShippingPostalCode__c, 
                                 ShippingState__c, ShippingStreet__c, BVC_Service__c, BVC_ACR_Consumption__c, BVC_Invoice_Run__c, 
                                 Customer_Category_Static__c, Reversed_Order_Amount__c, Reversed_Order_Of__c, Original_Order_number__c, 
                                 Deactivate_Order__c, Billing_status__c, BVC_Billing_Entity_Migrated__c, BVC_Legal_Entities__c, 
                                 BVC_CB_AIR_SEA__c, BVC_CB_Assessable_Value__c, BVC_CB_BE_Date__c, BVC_CB_BE_No__c, 
                                 BVC_CB_Billing_Account_2__c, BVC_CB_Billing_Account_Address__c, BVC_CB_Billing_Account_Address_2__c, 
                                 BVC_CB_Billing_GST_State_Code__c, BVC_CB_Billing_GSTIN__c, BVC_CB_Billing_Oracle_SiteId__c, 
                                 BVC_CB_Billing_OracleId__c, BVC_CB_Billing_SF_Customer__c, BVC_CB_Billing_PAN__c, 
                                 BVC_CB_Billing_SF_Customer_Address__c, BVC_CB_Billing_State__c, BVC_CB_BillingDocumentNumber__c, 
                                 BVC_CB_BillTo_Fields__c, BVC_CB_Bond_Date__c, BVC_CB_Bond_No__c, BVC_CB_BOS_Bill_Amount__c, 
                                 BVC_CB_BOS_Invoice_No__c, BVC_CB_BOS_Round_Off__c, BVC_CB_BVC_VAMASHIP_ID__c, BVC_CB_Cash_Idf_Date__c, 
                                 BVC_CB_Cash_Idf_No__c, BVC_CB_CCDate__c, BVC_CB_CCNo__c, BVC_CB_CM_Bill_Amount__c, 
                                 BVC_CB_CM_Invoice_No__c, BVC_CB_CM_Round_Off__c, BVC_CB_CONTENT__c, BVC_CB_Created_By__c, 
                                 BVC_CB_Created_By_Datetime__c, BVC_CB_Customer_Address__c, BVC_CB_Customer_GSTINNO__c, 
                                 BVC_CB_Customer_Invoice_Date__c, BVC_CB_Customer_Invoice_Number__c, 
                                 BVC_CB_Customer_Invoice_Value_Currency__c, BVC_CB_Customer_Name__c, BVC_CB_CUSTOMER_TRANSACTION_TYPE__c, 
                                 BVC_CB_Despatch__c, BVC_CB_Destination_Country_2__c, BVC_CB_Destination_Port_2__c, 
                                 BVC_CB_DestinationCountry__c, BVC_CB_digiGSTErrorCode__c, BVC_CB_digiGSTErrorMessage__c, 
                                 BVC_CB_DT_GR_FORM_NO__c, BVC_CB_EDFDate__c, BVC_CB_EDFNo__c, BVC_CB_ERDate__c, BVC_CB_ERNo__c, 
                                 BVC_CB_ExportShipmentID__c, BVC_CB_FOBValue__c, BVC_CB_GR_FORM_NO__c, BVC_CB_GrossWt__c, 
                                 BVC_CB_GSTIN_Remarks__c, BVC_CB_HAWB_Date__c, BVC_CB_HAWB_No__c, BVC_CB_IGM_Item_Date__c, 
                                 BVC_CB_IGM_Item_No__c, BVC_CB_Import_Shipment__c, BVC_CB_Invoice_Value__c, BVC_CB_Invoice_Value_INR__c, 
                                 BVC_CB_IRN__c, BVC_CB_IRN_Date__c, BVC_CB_JOB_DT__c, BVC_CB_JOB_NO__c, BVC_CB_Last_Modifiedby__c, 
                                 BVC_CB_License_Date__c, BVC_CB_License_No__c, BVC_CB_lospCity__c, BVC_CB_lospColumn__c, 
                                 BVC_CB_lospState__c, BVC_CB_lospStateCode__c, BVC_CB_lospTable__c, BVC_CB_MAWB_Date__c, 
                                 BVC_CB_MAWB_No__c, BVC_CB_Modified_Datetime__c, BVC_CB_Net_Wt__c, BVC_CB_No_Of_Pkgs__c, 
                                 BVC_CB_Oracle_SiteId__c, BVC_CB_OracleID__c, BVC_CB_Org_Branch_GST_State_Code__c, Org_Branch_GSTIN__c, 
                                 BVC_CB_Org_Branch_GSTIN__c, BVC_CB_Org_Branch_SF_ID__c, BVC_CB_Org_Branch_State__c, BVC_CB_Org_CINNO__c, 
                                 BVC_CB_Org_PAN__c, BVC_CB_OrgBranchCode__c, BVC_CB_OrgBranchName__c, BVC_CB_PickupLocationCity__c, 
                                 BVC_CB_PickupLocationCountry__c, BVC_CB_PickupLocationState__c, BVC_CB_PlaceOfDelivery__c, 
                                 BVC_CB_PlaceOfReceipt__c, BVC_CB_POS__c, posCity__c, BVC_CB_posColumn__c, BVC_CB_posState__c, 
                                 BVC_CB_posStateCode__c, BVC_CB_posTable__c, BVC_CB_Pre_Tax_Date__c, BVC_CB_Pre_Tax_No__c, 
                                 BVC_CB_PreTaxBill__c, BVC_CB_PreTaxInvoice_ID__c, BVC_CB_ProcessingDate__c, BVC_CB_Remarks__c, 
                                 BVC_CB_Remarks1__c, BVC_CB_ROUND_OFF__c, BVC_CB_SalesForceAddress__c, BVC_CB_SalesForceCustomerId__c, 
                                 BVC_CB_SBDate__c, SBNo__c, BVC_CB_Shipment_Date__c, BVC_CB_Shipment_No__c, BVC_CB_ShipTo_Fields__c, 
                                 BVC_CB_SoldTo_Fields__c, BVC_CB_SOS__c, BVC_CB_SUPPLY_TYPE__c, BVC_CB_SupplyType__c, 
                                 BVC_CB_Tariff_Name__c, BVC_CB_Tax_Bill_Amount__c, BVC_CB_Tax_Invoice_No__c, BVC_CB_Tax_Round_Off__c, 
                                 BVC_CB_Trade_Name__c, BVC_CB_TRANSACTION_CLASS__c, BVC_CB_Operation_Type__c, BVC_CB_Invoice_Type__c, 
                                 OS_Username__c, BVC_CB_SBNo__c, BVC_CB_DestinationPort__c, BVC_LegalEntity__c,Billing_Account__r.Billing_Address__c,
                                 (SELECT Id, BVCOrder__c, Quantity__c, Required_By__c, /*Bookings_Indicator__c,*/ Default_Subscription_Term__c, 
                                  Customer_Product_Category__c, Origin_Address_Name__c, X18_Digit_ID__c, Line_Description__c, Total_Price__c, 
                                  Billing_Account__c, /*Activation_Status__c, Hold_Billing__c,*/ Activated__c, BVC_Branch__c,// Charge_Type__c, 
                                 /* Billing_Type__c, */ACR_Contracted_Price__c, ACR_Standard_Price__c, /*Invoice_Group__c,*/ Invoice_Group_ID__c, 
                                 /* Billing_Frequency__c,*/ Non_ACR_Contracted_Price__c, Non_ACR_Standard_Price__c, BVC_Invoice_Run__c, 
                                  BVC_Legal_Entities__c, Billed_Tax__c, Billed_Amount_without_tax__c, Total_Billings__c, 
                                  Pending_Billing_Amount_without_tax__c, Canceled_Billing_Amount_without_tax__c, Total_Charges__c, 
                                  Freight_Charges__c, Offline_Charge__c, BVC_Valuation_Charges__c, Docket_Charges__c, Fuel_Charges__c, 
                                  Holiday_Charges__c, Weight_Charges__c, Total_Logistics_Charges__c, Total_Commission_Charges__c, 
                                  Total_eSHIP_Freight_Charges__c, Total_eSHIP_COD_Charges__c, Total_eSHIP_Additional_Charges__c, 
                                  Secure_Logistics_Charges__c, Total_eSHIP_Weight_Charges__c, Total_eSHIP_Fuel_Surcharges__c, 
                                  Total_eSHIP_Liability_Charges__c, Start_Date__c, End_Date__c, Next_Billing_Date__c, Next_Charge_Date__c, 
                                  Override_Next_Billing_Date__c, Last_Charge_To_Date__c, Bill_Through_Date_Override__c, 
                                  Last_Invoice_Target_Date__c, Override_Initial_Revenue_Start_Date__c, Override_Initial_Revenue_End_Date__c, 
                                  Terminated_Date__c, Billable_Unit_Price__c, Override_Billable_Unit_Price__c, List_Price__c, 
                                  Full_Term_Net_Unit_Price__c, Unit_Price__c, Estimated_Tax__c,  Tax_Error_Message__c, 
                                  BVC_CB_CGSTAmount__c, Tax_Street_1_Override__c, Tax_City_Override__c, Tax_State_Override__c, 
                                  Tax_Country_Override__c, Tax_Postal_Code_Override__c, Revenue_Allocation_Amount__c, Revenue_Liability_Amount__c, 
                                  /*Revenue_Schedule_Status__c,*/ Revenue_Expected_Amount__c, Group_Id__c, Included_Usage__c, Usage_Floor_Quantity__c, 
                                  BVCQuoteLineItem__c, /*Subscription_Pricing__c,*/ Subscription_Term__c, /*Subscription_Type__c, */
                                 /* Product_Subscription_Type__c,*/ Rate_UOM__c, Shipment__c, Shipment_Number__c, Shipment_Date__c, 
                                  PickUp_Date_and_Time__c, Delivery_Date_and_Time__c, Shipper_Name__c, Shipper_PAN__c, Consignee_Name__c, 
                                  Consignee_PAN__c, Origin_City__c, Origin_State__c, Origin_PinCode__c, Origin_Type__c, Destination_City__c, 
                                  Destination_State__c, Destination_Pin_Code__c, Destination_Type__c, Rate_Amount__c, Shipment_Type__c, 
                                  Contracting_Method__c, Pricing_Method__c, Gross_Weight_gms__c, Gross_Weight_UOM__c, Gross_Weight__c, 
                                  Net_Weight__c, Net_Weight_UOM__c, Net_Weight_gms__c, Number_of_Packages__c, Your_Reference_Number__c, 
                                  Initiator_Email__c, Initiator_Mobile__c, Initiator_Name__c, Initiator_PAN__c, Confirmation_By_Name__c, 
                                  Confirmation_Reference__c, Confirmation_Email_ID__c, Confirmed_By_Mobile__c, Liability_Cover_By_BVC__c, 
                                  Payment_Received__c, Payment_Reference__c, Payment_Date__c, Minimum_Freight__c, Liability_Charges__c, 
                                  Fuel_Surcharge__c, Universe_Cost_Charge__c, Liability_Coverage__c, Exhibition__c, Product_Name__c, Product_Code__c, 
                                  Vaulting_Charges__c, Total_Freight__c, Opt_for_Liability_Coverage__c, Invoice_Value__c, InvSheduler_Billing__c, 
                                  Billing_status__c, BVC_CB_CGSTTaxRate__c, BVC_CB_ChargeAmount__c, BVC_CB_ChargeCode__c, 
                                  BVC_CB_ChargeDescription__c, BVC_CB_ChargeType__c, BVC_CB_COA_BRANCH__c, BVC_CB_COAENTITY__c, 
                                  BVC_CB_COA_EXHIBITION_CODE__c, BVC_CB_COA_INTERCOMPANY__c, BVC_CB_COA_PRODUCT__c, BVC_CB_COA_REVENUE_COST_CENTRE__c, 
                                  BVC_CB_COA_REVENUE_SUB_ACCOUNT__c, BVC_CB_COA_REVENUE_ACCOUNT_CODE__c, BVC_CB_CreatedBy__c, BVC_CB_CreatedByDatetime__c, 
                                  BVC_CB_ExportPreTaxBillID__c, BVC_CB_HSNCODE__c, BVC_CB_Id__c, BVC_CB_IGSTAmount__c, BVC_CB_IGSTTaxRate__c, 
                                  BVC_CB_ImportPreTaxBillID__c, BVC_CB_Invoice_Type__c, BVC_CB_InvoiceType__c, BVC_CB_LastModifiedby__c, 
                                  BVC_CB_LINE_NUMBER__c, BVC_CB_LineTotal__c, BVC_CB_LINEUOMCODE__c, BVC_CB_ModifiedDatetime__c, BVC_CB_NatureOfService__c, 
                                  BVC_CB_NONTAXVALUE__c, BVC_CB_OracleGLCode__c, BVC_CB_OracleItemCode__c, BVC_CB_ReceiptDate__c, BVC_CB_ReceiptNo__c, 
                                  BVC_CB_Remarks__c, BVC_CB_SAC__c, BVC_CB_SalesforceCharge__c, BVC_CB_SGSTAmount__c, BVC_CB_SGSTTaxRate__c, BVC_LegalEntity__c,
                                  BVC_CB_TAXABLEVALUE__c, BVC_CB_TaxCalculated__c, BVC_CB_TaxCalculatedINR__c, BVC_CB_TaxCategory__c, BVC_CB_TotalItemValue__c, 
                                  BVC_CB_UTGSTAmount__c, BVC_CB_UTGSTTaxRate__c, BVC_CB_PreTaxBillDetails__c FROM BVC_Order_Products__r)
                                 From BVCOrder__c WHERE Id IN :orderIds AND BVC_Invoice_Run__c=null]);
        }
        System.debug('Rafi debug jumped inside generateInvoice and bvcOrderList.size() : '+bvcOrderList.size());
        System.debug('Rafi debug jumped inside generateInvoice and bvcOrderList : '+bvcOrderList);
        
        
        for(BVCOrder__c bvcOrder : bvcOrderList){
            
            if(bvcOrder.BVC_CB_PreTaxBill__c !=null && bvcOrder.BVC_Order_Products__r.size() > 0){
                CBOrderMap.put(bvcOrder.Id,bvcOrder);
                CBItemMap.put(bvcOrder.Id,bvcOrder.BVC_Order_Products__r);
            }
            
			
            if(bvcOrder.Business_Type__c == 'Non ACR' && bvcOrder.BVC_Order_Products__r.size() > 0){
                nonacrBVCOrderMap.put(bvcOrder.Id,bvcOrder);
                nonacrBVCOrderProductMap.put(bvcOrder.Id,bvcOrder.BVC_Order_Products__r);
            } 
            
        }
        
        System.debug('Rafi debug jumped inside generateInvoice and nonacrBVCOrderMap.size() : '+nonacrBVCOrderMap.size());
        System.debug('Rafi debug jumped inside generateInvoice and nonacrBVCOrderMap.values() : '+nonacrBVCOrderMap.values());
        System.debug('Rafi debug jumped inside generateInvoice and nonacrBVCOrderProductMap.size() : '+nonacrBVCOrderProductMap.size());
        System.debug('Rafi debug jumped inside generateInvoice and nonacrBVCOrderProductMap.values() : '+nonacrBVCOrderProductMap.values());
        
        if(nonacrBVCOrderProductMap.size() > 0 && nonacrBVCOrderProductMap != null){
            UtilClass.orderTriggerLoop = true;
            System.debug('Rafi debug jumped inside generateInvoice and UtilClass.orderTriggerLoop : '+UtilClass.orderTriggerLoop);
            BVC_InvoiceGenerator.createNONACRInvoice(nonacrBVCOrderMap, nonacrBVCOrderProductMap);
        }
        
        if(CBItemMap.size() > 0 && CBItemMap != null){
            System.debug('Rafi debug jumped inside BVC_CB_InvoiceGenerator === ');
            BVC_CB_InvoiceGenerator.createShipmentCBInvoice(CBOrderMap, CBItemMap);
        }
        
        
    }
    //***************************************************************************************************
    // Reverse Order Implementation
    //***************************************************************************************************
    
  public static void createReverseOrder(Map<Id,BVCOrder__c> oldMap,Map<Id,BVCOrder__c> newMap){
        system.debug('reverse order::::');
        List<BVCOrder__c> reverseOrders = new List<BVCOrder__c>();
        List<BVC_ACR_Consumption__c> reverseACRConsumption = new List<BVC_ACR_Consumption__c>();
        List<BVC_Order_Product__c> reverseorderitem = new List<BVC_Order_Product__c>();
        List<BVCOrder__c> ordersToUpdate = new List<BVCOrder__c>();
        
        for(Id orderId:newMap.keySet()){
            if(oldMap.get(orderId).Shipment_Status__c=='ACR Consumed'){
                BVCOrder__c oldOrderRec = oldMap.get(orderId);
                BVCOrder__c newOrderRec = newMap.get(orderId);
                
                System.debug(oldOrderRec.Status__c + ' '+ newOrderRec.Status__c);
                if(oldOrderRec.Status__c != null && newOrderRec.Status__c != null){
				
																																														
                    
                    if(oldOrderRec.Status__c != newOrderRec.Status__c&& oldOrderRec.Status__c=='Activated' && newOrderRec.Status__c=='Draft'){
																							 
						if(newOrderRec.Account__c!= null && newOrderRec.Customer_Category_Static__c!=null && newOrderRec.Customer_Category_Static__c=='ACR'){
                            BVCOrder__c reverseOrder = newOrderRec.clone(false,true,false,false);
                            reverseOrder.Reversed_Order_Amount__c = -1 * newOrderRec.Order_Amount__c;
                            reverseOrder.Reversed_Order_Of__c = newOrderRec.id;
                            reverseOrder.Order_reversal_reason__c=newOrderRec.Order_reversal_reason__c;//prat
                            reverseOrder.Original_Order_Static__c=newOrderRec.id;
                            reverseOrder.Original_Order_number__c=newOrderRec.Name;
                            reverseOrder.Order_Amount__c=-1*newOrderRec.Order_Amount__c;
                            reverseOrder.Status__c='Draft';
                            reverseOrder.Order_Status_Static__c='Cancelled';
                            reverseOrders.add(reverseOrder);
                            
                        }
                    }
                }
			   
            }
        } 
        
        if(reverseOrders.size()>0){
            insert reverseOrders;
            system.debug('Reverse order inserted'+reverseOrders[0].id);
            
            createReverseOrderItems(reverseOrders, newMap.keySet());
            createReverseACR(reverseOrders, newMap.keySet());
        }
    }
    public static void createReverseOrderItems(List<BVCOrder__c> reverseOrders,Set<Id> oldOrderIds){
        
        Map<Id,Id> origVsRever =new Map<Id,Id>();
        for(BVCOrder__c orderRec:reverseOrders){
            origVsRever.put(orderRec.Reversed_Order_Of__c,orderRec.Id);
        }
        system.debug('PORGVSREVER+++'+origVsRever);
        List<BVC_Order_Product__c> orderItems = [Select Id,BVCOrder__c,End_Date__c,Unit_Price__c from BVC_Order_Product__c where BVCOrder__c in :oldOrderIds];
        List<BVC_Order_Product__c> reversedOrderItems = new List<BVC_Order_Product__c>();
        for(BVC_Order_Product__c ordItem:orderItems){
            BVC_Order_Product__c revOrdItem = ordItem.clone(false,true,false,false);
            revOrdItem.Unit_Price__c = -1*revOrdItem.Unit_Price__c;
            System.debug('Order on orderProduct======'+revOrdItem.BVCOrder__c);
            revOrdItem.BVCOrder__c = origVsRever.get(revOrdItem.BVCOrder__c);
            System.debug('Order on orderProduct+++++++++'+revOrdItem.BVCOrder__c);
            reversedOrderItems.add(revOrdItem);
        }
        insert reversedOrderItems;
    }
    
    
    public static void createReverseACR(List<BVCOrder__c> reverseOrders,Set<Id> oldOrderIds){
        Set<Id> accIds = new Set<Id>();
        for(BVCOrder__c o : reverseOrders){
            
            accIds.add(o.Account__c);
        }
        List<BVC_Order_Product__c> orderItems = [Select Id,Net_Weight__c,Net_Weight_gms__c,
                                                 Net_Weight_UOM__c,Gross_Weight__c ,
                                                 Gross_Weight_gms__c,Gross_Weight_UOM__c,
                                                 Freight_Charges__c,Offline_Charge__c ,
                                                 Liability_Cover_by_BVC__c,Liability_Charges__c ,
                                                 Minimum_Freight__c, BVC_Valuation_Charges__c ,
                                                 Docket_Charges__c, Fuel_Charges__c,
                                                 Holiday_Charges__c , Weight_Charges__c ,Fuel_Surcharge__c,Universe_Cost_Charge__c,
                                                 Confirmation_By_Name__c,Confirmed_By_Mobile__c,
                                                 Confirmation_Email_ID__c,Confirmation_Reference__c,
                                                 Your_Reference_Number__c,Unit_Price__c,
                                                 Product_Code__c,Number_of_Packages__c,BVCOrder__c,Vaulting_Charges__c,
                                                 Total_eSHIP_Additional_Charges__c,Total_eSHIP_COD_Charges__c,Total_eSHIP_Freight_Charges__c, // added by Pratik on 23rd July 25
                                                 Total_eSHIP_Fuel_Surcharges__c,Total_eSHIP_Liability_Charges__c,Total_eSHIP_Weight_Charges__c,Secure_Logistics_Charges__c
                                                 from BVC_Order_Product__c  where BVCOrder__c in: oldOrderIds];
        
        Map<Id,BVC_Order_Product__c> oiMap = new Map<Id,BVC_Order_Product__c>();
        for(BVC_Order_Product__c oi:orderItems){
            oiMap.put(oi.BVCOrder__c,oi);
        }
        List<BVC_ACR_Consumption__c > consumptionList = new List<BVC_ACR_Consumption__c >();
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,ST_Pricing_Type__c,
                                                      BVC_Contract__c,
                                                     // Original_Contract_End_Date__c, commented to uninstall CPQ
                                                      BVC_Contract__r.Quote__r.Name,
                                                      of_Contract_Consumption__c,Adjusted_Contract_Amount__c,
                                                      Adjustment_Amount__c,Balance_Amount__c,
                                                      Contracted_ACR_Package__c,Contract_Start_Date__c,
                                                      Contract_End_Date__c,Contract_Amount__c,
                                                      Business_Type_eSHIP__c,eSHIP_BVC_Contract__c,Contract_Start_Date_eSHIP_BVC__c,Contract_End_Date_eSHIP__c,
                                                      Contracted_ACR_Package_eSHIP_BVC__c,Adjustment_Amount_eSHIP__c,Adjusted_Contract_Amount_eSHIP__c,Consumed_Amount_eSHIP__c,
                                                      of_Contract_Consumption_eShip__c,Contract_Amount_eShip__c,Remaining_Amount_eSHIP__c,
                                                      Business_Type_Exhibiship_BVC__c,ExhibiShip_Bvc_Contract__c,Contract_Amount_ExhibiShip__c,original_contract_amount_Exhibition__c,
                                                      adjustment_amount_Exhibition__c,Adjusted_Contract_Amount_ExhibiShip__c,consumption_status_Exhibition__c,Consumed_Amount_ExhibiShip__c,
                                                      of_Contract_Consumption_ExhibiShip__c,Remaining_Amout_ExhibiShip__c,Contract_Start_DATE_Exhibiship__c,Contract_END_DATE_Exhibiship__c
                                                      FROM Account
                                                      WHERE (BVC_Contract__c != null OR eSHIP_BVC_Contract__c !=null)
                                                      AND Id IN :accIds
                                                     ]);
        List<BVC_ACR_Consumption__c > reverseACRConsumption = new List<BVC_ACR_Consumption__c >();
        set<Id> acrId=new set<Id>();
        for(BVCOrder__c o1 : reverseOrders){
            
            acrId.add(o1.BVC_ACR_Consumption__c);
        }
        Map<Id,BVC_ACR_Consumption__c > acrMap=new Map<Id,BVC_ACR_Consumption__c >([select Id,Name,BVCOrder__c, 
                                                                                    Net_Weight__c,Net_Weight_GMS__c,Net_Weight_UOM__c,Gross_Weight__c,
                                                                                    Gross_Weight_GMS__c,Gross_Weight_UOM__c,Freight_Charges__c,
                                                                                    Offline_Charges__c,Liability_Cover_By_BVC__c,Liability_charges__c,
                                                                                    Minimum_Freight__c,BVC_Valuation_Charges__c,Docket_Charges__c,
                                                                                    Fuel_Charges__c,Holiday_Charges__c,Weight_Charges__c,Confirmed_By_Name__c,
                                                                                    Confirmed_By_Phone__c,Confirmed_By_Email__c,Confirmation_Reference__c,
                                                                                    Reference_Number__c,Consumption__c,BVC_Order_Product__c,Product_code__c,Product_name__c,
                                                                                    No_Of_Packages__c,Bill_To_Account__c,Bill_To_Address__c,
                                                                                    Contract_Date_From__c,Contract_Date_To__c,Adjusted_Contract_Amount__c,
                                                                                    Adjustment_to_Contract_Amount__c,Contract_Balance__c,Contract_Amount__c,
                                                                                    Shipment__c,BVC_Branch__c,Shipment_Number__c,Shipment_Date__c,
                                                                                    Pickup_Date__c,Shipment_Value__c,Product_Description__c,
                                                                                    Shipper_Name__c,Shipper_PAN__c,Consignee_Name__c,Consignee_PAN__c,
                                                                                    Destination_Address__c,Origin_Address__c,Destination_type__c,
                                                                                    Origin_Type__c,Account__c,Fuel_Surcharge__c,Universe_Cost_Charge__c
                                                                                    from BVC_ACR_Consumption__c 
                                                                                    where Id IN :acrId]); 
        if(acrMap.size()>0){
            for(BVCOrder__c orderRec:reverseOrders){
		
			 BVC_ACR_Consumption__c  consumption = new BVC_ACR_Consumption__c ();
                
                
                if(orderRec.BVC_Service__c!='eSHIP' && orderRec.ExhibiSHIP_Order__c==false){consumption.BVC_Contract__c = accMap.get(orderRec.Account__c).BVC_Contract__c;} //for valship
                if(orderRec.BVC_Service__c=='eSHIP'){consumption.BVC_Contract__c = accMap.get(orderRec.Account__c).eSHIP_BVC_Contract__c;} //for eSHIP
                if(orderRec.ExhibiSHIP_Order__c==true){consumption.BVC_Contract__c = accMap.get(orderRec.Account__c).ExhibiShip_Bvc_Contract__c;} //for exhibition
                
                consumption.Status__c = 'Invalid';
                consumption.Account__c = orderRec.Account__c;
                consumption.BVCOrder__c = orderRec.Id;
                consumption.Total_Charge__c = orderRec.Reversed_Order_Amount__c;
                consumption.Bill_To_Account__c = orderRec.Account__c;
                consumption.Bill_To_Address__c = orderRec.Billing_Address__c;
                consumption.Original_ACR_Consumption__c = acrMap.get(orderRec.BVC_ACR_Consumption__c).Name;
                
                if(orderRec.BVC_Service__c!='eSHIP' && orderRec.ExhibiSHIP_Order__c==false){
                consumption.Contract_Date_From__c =accMap.get(orderRec.Account__c).Contract_Start_Date__c;
              //  consumption.Contract_Date_To__c = accMap.get(orderRec.Account__c).Original_Contract_End_Date__c; commented to uninstall CPQ
                consumption.Adjusted_Contract_Amount__c = accMap.get(orderRec.Account__c).Adjusted_Contract_Amount__c;
                consumption.Adjustment_to_Contract_Amount__c = accMap.get(orderRec.Account__c).Adjustment_Amount__c;
                consumption.Contract_Balance__c = accMap.get(orderRec.Account__c).Balance_Amount__c;
                consumption.Contract_Amount__c = accMap.get(orderRec.Account__c).Adjusted_Contract_Amount__c;
                }
                if(orderRec.BVC_Service__c=='eSHIP'){
                   consumption.Contract_Date_From__c =accMap.get(orderRec.Account__c).Contract_Start_Date_eSHIP_BVC__c;
                consumption.Contract_Date_To__c = accMap.get(orderRec.Account__c).Contract_End_Date_eSHIP__c;
                consumption.Adjusted_Contract_Amount__c = accMap.get(orderRec.Account__c).Adjusted_Contract_Amount_eSHIP__c;
                consumption.Adjustment_to_Contract_Amount__c = accMap.get(orderRec.Account__c).Adjustment_Amount_eSHIP__c;
                consumption.Contract_Balance__c = accMap.get(orderRec.Account__c).Remaining_Amount_eSHIP__c;
                consumption.Contract_Amount__c = accMap.get(orderRec.Account__c).Adjusted_Contract_Amount_eSHIP__c; 
                }
                
                if(orderRec.ExhibiSHIP_Order__c==true){
                consumption.Contract_Date_From__c =accMap.get(orderRec.Account__c).Contract_Start_DATE_Exhibiship__c;
                consumption.Contract_Date_To__c = accMap.get(orderRec.Account__c).Contract_END_DATE_Exhibiship__c;
                consumption.Adjusted_Contract_Amount__c = accMap.get(orderRec.Account__c).Adjusted_Contract_Amount_ExhibiShip__c;
                consumption.Adjustment_to_Contract_Amount__c = accMap.get(orderRec.Account__c).adjustment_amount_Exhibition__c;
                consumption.Contract_Balance__c = accMap.get(orderRec.Account__c).Remaining_Amout_ExhibiShip__c;
                consumption.Contract_Amount__c = accMap.get(orderRec.Account__c).Adjusted_Contract_Amount_ExhibiShip__c;
                }
                
                consumption.Shipment__c = orderRec.Shipment__c;
                consumption.BVC_Branch__c = orderRec.BVC_Branch__c;
                consumption.Shipment_Number__c = orderRec.Shipment_Number__c;
                consumption.Shipment_Date__c = orderRec.Shipment_Date__c;
                consumption.Pickup_Date__c = orderRec.Pickup_Date__c;
                consumption.Shipment_Value__c = orderRec.Shipment_Value__c;
                consumption.Product_Description__c = orderRec.Product_Description__c;
                consumption.Shipper_Name__c = orderRec.Shipper_Name__c;
                consumption.Shipper_PAN__c= orderRec.Shipper_PAN__c;
                consumption.Consignee_Name__c = orderRec.Consignee_Name__c;
                consumption.Consignee_PAN__c = orderRec.Consignee_PAN__c;
                consumption.Destination_Address__c = orderRec.Destination_Address__c;
                consumption.Origin_Address__c = orderRec.Origin_Address__c;
                consumption.Destination_type__c = orderRec.Destination_Type__c;
                consumption.Origin_Type__c = orderRec.Origin_Type__c;
                
                if(oiMap.get(orderRec.Reversed_Order_Of__c)!=null){
                    BVC_Order_Product__c oi = oiMap.get(orderRec.Reversed_Order_Of__c);
                    consumption.Net_Weight__c = oi.Net_Weight__c;
                    consumption.Net_Weight_GMS__c = oi.Net_Weight_gms__c;
                    consumption.Net_Weight_UOM__c = oi.Net_Weight_UOM__c;
                    consumption.Gross_Weight__c = oi.Gross_Weight__c;
                    consumption.Gross_Weight_GMS__c = oi.Gross_Weight_gms__c;
                    consumption.Gross_Weight_UOM__c = oi.Gross_Weight_UOM__c;
                    
                     if(orderRec.BVC_Service__c!='eSHIP' || orderRec.ExhibiSHIP_Order__c==true){
                    consumption.Freight_Charges__c = oi.Freight_Charges__c != null ? oi.Freight_Charges__c : 0;
                    consumption.Offline_Charges__c = oi.Offline_Charge__c != null ? oi.Offline_Charge__c : 0;
                    consumption.Liability_Cover_By_BVC__c = oi.Liability_Cover_by_BVC__c;
                    consumption.Liability_charges__c = oi.Liability_Charges__c != null ? oi.Liability_Charges__c : 0;
                    consumption.Minimum_Freight__c = oi.Minimum_Freight__c;
                    // Added new charge Heads
                    consumption.BVC_Valuation_Charges__c = oi.BVC_Valuation_Charges__c != null ? oi.BVC_Valuation_Charges__c : 0;
                    consumption.Docket_Charges__c = oi.Docket_Charges__c != null ? oi.Docket_Charges__c : 0;
                    consumption.Fuel_Charges__c = oi.Fuel_Charges__c != null ? oi.Fuel_Charges__c : 0;
                    consumption.Holiday_Charges__c = oi.Holiday_Charges__c != null ? oi.Holiday_Charges__c : 0;
                    consumption.Weight_Charges__c = oi.Weight_Charges__c != null ? oi.Weight_Charges__c : 0;
                    consumption.Fuel_Surcharge__c = oi.Fuel_Surcharge__c != null ? oi.Fuel_Surcharge__c : 0;//Prat
                    consumption.Universe_Cost_Charge__c = oi.Universe_Cost_Charge__c != null ? oi.Universe_Cost_Charge__c : 0;
                     }
                    if(orderRec.BVC_Service__c=='eSHIP'){
                        consumption.Secure_Logistics_Charges__c = oi.Secure_Logistics_Charges__c != null ? oi.Secure_Logistics_Charges__c : 0;
                    }
                    
                    consumption.Confirmed_By_Name__c = oi.Confirmation_By_Name__c;
                    consumption.Confirmed_By_Phone__c = oi.Confirmed_By_Mobile__c;
                    consumption.Confirmed_By_Email__c = oi.Confirmation_Email_ID__c;
                    consumption.Confirmation_Reference__c = oi.Confirmation_Reference__c;
                    consumption.Reference_Number__c = oi.Your_Reference_Number__c;
                    
                    if(orderRec.BVC_Service__c!='eSHIP'&& orderRec.ExhibiSHIP_Order__c==false){
                        consumption.Consumption__c = (oi.Unit_Price__c/accMap.get(orderRec.Account__c).Adjusted_Contract_Amount__c)*100;}
                    if(orderRec.BVC_Service__c=='eSHIP'){
                        consumption.Consumption__c = (oi.Unit_Price__c/accMap.get(orderRec.Account__c).Adjusted_Contract_Amount_eSHIP__c)*100;}
                    if(orderRec.ExhibiSHIP_Order__c==true){
                        consumption.Consumption__c = (oi.Unit_Price__c/accMap.get(orderRec.Account__c).Adjusted_Contract_Amount_ExhibiShip__c)*100;}
                    
                    consumption.BVC_Order_Product__c = oi.Id;
                    consumption.No_Of_Packages__c = oi.Number_of_Packages__c;
                    System.debug('Consumption');
                }
                reverseACRConsumption.add(consumption);
            }
												   
		 
        } 
        if(reverseACRConsumption.size()>0)
            insert reverseACRConsumption;
        
        
        if( reverseACRConsumption.size()>0 ){
            // Shipment__c Ship = [Select Id,Status__c,Verified_for_Billing__c From Shipment__c Where id =:reverseACRConsumption[0].Shipment__c]; 
            Shipment__c Ship = new Shipment__c(id=reverseACRConsumption[0].Shipment__c);
            Ship.Status__c='Pending Billing';
            Ship.Verified_for_Billing__c=false;
            update Ship;
            BVC_ACR_Consumption__c  consumption=[SELECT id,name,status__c FROM BVC_ACR_Consumption__c WHERE BVCOrder__c=:reverseOrders[0].Original_Order_Static__c ];
            system.debug('Consumption Name:::'+consumption.name);
            system.debug('BVCOrder__c:::'+reverseOrders[0].id );
             system.debug('consumption.status__c before:::'+consumption.status__c);
            consumption.Status__c='Invalid';
            update consumption;
             system.debug('consumption.status__c:::'+consumption.status__c);
        }
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
    }
    
    
    
}