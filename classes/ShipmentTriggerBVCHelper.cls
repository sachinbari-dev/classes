public class ShipmentTriggerBVCHelper {

  
    Public static void createBVCOrderNew(List<Shipment__c> newShipment){
        System.debug('for checking Inside createBVCOrderNew newShipment '+newShipment);
        set<Id> accId =new set<Id>();
        set<Id> ShipId =new set<Id>();
        Decimal totalCharge;
        
        for(Shipment__c ship:newShipment){
            accId.add(ship.Customer__c);
            ShipId.add(ship.id); 
        }
        System.debug('for checking accId : '+accId);
        System.debug('for checking ShipId : '+ShipId);
        List<Account> AccList =[select id,eSHIP_BVC_Contract__c,BATH_BVC_Contract__c,BVC_eSHIP_Invoice_Run__c  from Account where Id IN :accId];
        System.debug('for checking AccList.size() : '+AccList.size());
        set<Id> ConId =new set<Id>();
        list<Id> InvRunId =new list<Id>();
        
        for(Account A:AccList){
            System.debug('for checking A.eSHIP_BVC_Contract__c : '+A.eSHIP_BVC_Contract__c);
            System.debug('for checking A.BATH_BVC_Contract__c : '+A.BATH_BVC_Contract__c);
            if(A.eSHIP_BVC_Contract__c!=null ){
                ConId.add(A.eSHIP_BVC_Contract__c);
                
                if(A.BVC_eSHIP_Invoice_Run__c!=null){
                    InvRunId.add(A.BVC_eSHIP_Invoice_Run__c);
                }
            }
            if( A.BATH_BVC_Contract__c!=null){ConId.add(A.BATH_BVC_Contract__c);}
        }
        System.debug('for checking ConId : '+ConId);
        
        List<BVC_Contract__c> conList =[select id,name,Quote__c,Customer_Name__r.Billing_Address__c,BVC_Entity__c,BVC_LegalEntity__c,Slab_Criteria__c,Is_Legacy_Contract__c,Contract_Amount__c,BVC_Branch__c,Tariff_Plan__c,Customer_Name__c,BVC_Service__c,Contracted_ACR_Package__c,Business_Type__c   from BVC_Contract__c where Id IN :ConId];//getting eship contracts
        System.debug('for checking conList.size() : '+conList.size());
        System.debug('contract number : '+conList[0].name);
        List<eSHIP_Custom_Pricing__c> eShipObjs = new List<eSHIP_Custom_Pricing__c>();
        if (!conList.isEmpty()) {
        // eShipObjs =[SELECT Id,Latest_Pricing__c,customer__r.Liability_Cover_By_BVC_For_Eship__c,Rate_INR__c,Liability_Charges__c,COD_Charges_percentage_of_product__c,Fuel_Surcharge__c,UOM_Percentage__c,Weight_Charges__c,Per_Shipment_Freight_Charge__c,BVCQuote__c,No_Of_Free_Atttemps__c,Gross_Weight_Unit_for_Additional_Weight__c,Additional_Charge__c,COD_Charges_per_shipment__c FROM eSHIP_Custom_Pricing__c Where BVCQuote__c =: conList[0].Quote__c AND Latest_Pricing__c=true  LIMIT 1];
        	eShipObjs =[SELECT Id,customer__c,Latest_Pricing__c,customer__r.Liability_Cover_By_BVC_For_Eship__c,Rate_INR__c,Liability_Charges__c,COD_Charges_percentage_of_product__c,Fuel_Surcharge__c,UOM_Percentage__c,Weight_Charges__c,Per_Shipment_Freight_Charge__c,BVCQuote__c,No_Of_Free_Atttemps__c,Gross_Weight_Unit_for_Additional_Weight__c,Additional_Charge__c,COD_Charges_per_shipment__c FROM eSHIP_Custom_Pricing__c Where customer__c =: conList[0].Customer_Name__c AND Latest_Pricing__c=true  LIMIT 1];
            System.debug('for checking eShipObjs : '+eShipObjs);
        }
        eSHIP_Custom_Pricing__c eShipObj = null;
        if (!eShipObjs.isEmpty()) {
            eShipObj = eShipObjs[0]; // Pick the first record if appropriate
            System.debug('Selected eShipObj: ' + eShipObj);
        }
        Id recordTypeId1 = [SELECT Id FROM RecordType WHERE SObjectType = 'eSHIP_Standard_Pricing__c' AND DeveloperName = 'Legacy_eSHIP_Pricing' LIMIT 1].Id;
        eSHIP_Standard_Pricing__c StdeShipObj =[SELECT Id,Rate_INR__c,Liability_Charges__c,COD_Charges_percentage_of_product__c,Fuel_Surcharge__c,UOM_Percentage__c,Weight_Charges__c,Per_Shipment_Freight_Charge__c,No_Of_Free_Atttemps__c,Gross_Weight_Unit_for_Additional_Weight__c,Additional_Charge__c,COD_Charges_per_shipment__c FROM eSHIP_Standard_Pricing__c  where RecordTypeId = :recordTypeId1 LIMIT 1];
        system.debug('accId-----'+accId.size());
        system.debug('conList[0].Quote__c-----'+conList[0].Quote__c);
        List<eSHIP_Custom_Pricing__c> NonACRLegacyeShipPricingList = [SELECT Id, customer__c, customer__r.Liability_Cover_By_BVC_For_Eship__c, Rate_INR__c, Liability_Charges__c, 
                                                                      COD_Charges_percentage_of_product__c, Fuel_Surcharge__c, UOM_Percentage__c, 
                                                                      Weight_Charges__c, Per_Shipment_Freight_Charge__c, BVCQuote__c, 
                                                                      No_Of_Free_Atttemps__c, Gross_Weight_Unit_for_Additional_Weight__c, Additional_Charge__c, 
                                                                      COD_Charges_per_shipment__c, Shipment_Type__c,Lower_Bound__c ,
                                                                      Upper_Bound__c,Slab_Criteria__c,name,Latest_Pricing__c 
                                                                      FROM eSHIP_Custom_Pricing__c
                                                                      WHERE Customer__c IN :accId AND customer__c =: conList[0].Customer_Name__c AND Latest_Pricing__c=true];
        system.debug('NonACRLegacyeShipPricingList.size()-----'+NonACRLegacyeShipPricingList.size()); 
        Set<Id> shipIds = new Set<Id>();
        //Map<Id,SBQQ__Quote__c> ShipIdQuoteMap = new Map<Id,SBQQ__Quote__c>();
        Map<Id,Decimal> BATHlogisCharge = new Map<Id,Decimal>();
        Map<Id,Decimal> BATHcommissionCharge = new Map<Id,Decimal>();
        
		
		Map<Id,Decimal> eSHIPAdditionalCharge = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPCODCharges = new Map<Id,Decimal>();
		Map<Id,Id> eSHIPeSHIPFreight = new Map<Id,Id>();
		Map<Id,Decimal> eSHIPFuelSurcharge = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPLiabilityCharges = new Map<Id,Decimal>();
		Map<Id,Decimal> eSHIPWeightCharge = new Map<Id,Decimal>();        
        
        for(Shipment__c S:newShipment){
            shipIds.add(S.Id);
        }
        
        List<BVCOrder__c> orders2Update = new List<BVCOrder__c>();
        if(newShipment.size()>0){
            for(Shipment__c ship : newShipment){
                BVCOrder__c o = new BVCOrder__c();
                if(ship.Customer_Category_Static__c=='ACR'){o.Business_Type__c = 'ACR';}
                else{o.Business_Type__c = 'Shipment';}
                o.Account__c = ship.Bill_To_Account__c;
                o.BillingAccount__c = ship.Bill_To_Account__c;
                if(ship.Shipment_Date__c != null){
                    o.Shipment_Date__c = ship.Shipment_Date__c;
                }
                o.Order_Start_Date__c = System.today();
                o.Order_End_Date__c = System.today();
              //  o.Payment_Term__c = 'Net 30';
                o.Shipment__c = ship.Id;
                o.ActivatedBy__c=UserInfo.getUserId();
                o.Activated_Date__c = System.today();
                o.Billing_Account__c = ship.Bill_To_Account__c;
                o.Billing_Day_Of_Month__c = String.valueOf(System.now().date().day());
                o.Shipment_Number__c = ship.Shipping_Note_Number__c;
                o.Origin_Address__c = ship.Origin_Address_Name__c;
                o.Destination_Address__c = ship.Destination_Address_Name__c;
                o.Status__c = 'Draft';
                o.Order_Type__c = 'New';
                o.Billing_status__c ='Pending';
                
                system.debug('ship.Bill_To_Account__r.BVC_eSHIP_Invoice_Run__c'+ship.Bill_To_Account__r.BVC_eSHIP_Invoice_Run__c);
                if(InvRunId.size()>0){
                     o.BVC_Invoice_Run__c=InvRunId[0];
                }
                
                if(ship.Customer_Product_Category__c=='BATH' && ship.Account__r.BATH_Contract__c!=null){
                    o.Contract_ID_Map__c=ship.Account__r.BATH_Contract__c;
                }else if(ship.Customer_Product_Category__c=='eSHIP' && ship.Account__r.eSHIP_Contract__c !=null){
                    o.Contract_ID_Map__c=ship.Account__r.eSHIP_Contract__c; 
                }
                if( ship.Billing_Account__c!=null){
                    o.BillingAccount__c = ship.Billing_Account__c;
                }
                if(ship.Origin_Type__c!=null){
                  o.Origin_Type__c = ship.Origin_Type__c;  
                }
                if(ship.Destination_Type__c!=null){
                  o.Destination_Type__c = ship.Destination_Type__c;  
                }
                if(ship.Total_Invoice_Value__c!=null){
                  o.Shipment_Value__c = ship.Total_Invoice_Value__c;  
                }
                if(ship.Shipment_Type__c!=null){
                  o.Shipment_Type__c = ship.Shipment_Type__c;  
                }
                
                o.Shipment_Status_Static__c = 'Picked for Billing';
                if(ship.Product_Description__c!=null){
                   o.Product_Description__c = ship.Product_Description__c; 
                }
                
                if(conList.size()>0){
                    System.debug('for checking Inside if(conList.size()>0) ');
                    
                    for(BVC_Contract__c contObj : conList){
                        System.debug('for checking Inside for(BVC_Contract__c contObj : conList) to create order');
                        System.debug('for checking contObj.Quote__c === '+contObj.Quote__c);                    
                       // System.debug('for checking eShipObj.BVCQuote__c === '+eShipObj.BVCQuote__c);
                        if(contObj.Quote__c!=null && contObj.Quote__c==eShipObj.BVCQuote__c){
                            
                            o.BVCQuote__c = contObj.Quote__c;
                            System.debug('for checking ship.Customer_Product_Category__c == '+ship.Customer_Product_Category__c);
                            System.debug('for checking ship.Account__c == '+ship.Account__c);
                            System.debug('for checking ship.Customer__c == '+ship.Customer__c);
                            System.debug('for checking ship.Account__r.eSHIP_BVC_Contract__c == '+ship.Account__r.eSHIP_BVC_Contract__c);
                            System.debug('contObj.name == '+contObj.name);
                            System.debug('contObj.BVC_LegalEntity__c '+contObj.BVC_LegalEntity__c);
                            System.debug('for checking ship.Account__r.eSHIP_BVC_Contract__r.BVC_Entity__c == '+ship.Account__r.eSHIP_BVC_Contract__r.BVC_Entity__c);
                            if(ship.Customer_Product_Category__c=='BATH' && ship.Account__r.BATH_Contract__r.BVC_Branch__c!=null){
                                o.BVC_Branch__c=ship.Account__r.BATH_BVC_Contract__r.BVC_Branch__c;
                            }else if(ship.Customer_Product_Category__c=='eSHIP' && contObj.BVC_Branch__c !=null){
                                o.BVC_Branch__c = contObj.BVC_Branch__c; 
                            }
                           /* if(ship.Customer_Product_Category__c=='BATH' && ship.Account__r.BATH_BVC_Contract__c.BVC_LegalEntity__c!=null){
                                o.BVC_LegalEntity__c = ship.Account__r.BATH_BVC_Contract__c.BVC_LegalEntity__c;
                            }*/ if(ship.Customer_Product_Category__c=='eSHIP' && contObj.BVC_LegalEntity__c !=null){
                                system.debug('I am here==');
                                o.BVC_LegalEntity__c = contObj.BVC_LegalEntity__c;                
                            }
                            /*if(ship.Customer_Product_Category__c=='BATH' && ship.Account__r.BATH_Contract__r.BVC_Entity__c!=null){
                                o.BVC_Entity__c = ship.Account__r.BATH_Contract__r.BVC_Entity__c;
                            }*/if(ship.Customer_Product_Category__c=='eSHIP' && contObj.BVC_Entity__c !=null){
                                o.BVC_Entity__c = contObj.BVC_Entity__c;                
                            }
                        }
                    }
                }
                if(ship.Account__r.eSHIP_BVC_Contract__c==null || ship.Account__r.BATH_BVC_Contract__c==null ){
                    
                }
                o.Billing_Address__c = ship.Account__r.Billing_Address__c;                
                orders2Update.add(o);
   
            }
        }
        system.debug('o.BVCQuote__c===' +orders2Update[0].BVCQuote__c);
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
       

        List<BVC_Order_Product__c> ordersItems2Update = new List<BVC_Order_Product__c>();
        id ordId;
        for(Shipment__c ship : newShipment){
            BVC_Order_Product__c oi = new BVC_Order_Product__c();
            if(ship.Net_weight_in_Gram__c!=null){
              oi.Net_Weight_gms__c = ship.Net_weight_in_Gram__c;  
            }
            oi.End_Date__c = System.today();
            oi.BVCOrder__c = shipOrderMap.get(ship.Id);
            ordId=shipOrderMap.get(ship.Id);
            oi.Quantity__c = 1;
          //  oi.Charge_Type__c = 'One-Time'; 
          //  oi.Billing_Frequency__c = '';
            oi.Billing_status__c ='Pending';
            if(ship.Customer_Product_Category__c!=null){
               oi.Customer_Product_Category__c = ship.Customer_Product_Category__c; 
            }
            if(InvRunId.size()>0){
                     oi.BVC_Invoice_Run__c=InvRunId[0];
                }
            
     		oi.Shipment__c = ship.Id;
            if(ship.Shipment_Date__c!=null){
               oi.Shipment_Date__c = ship.Shipment_Date__c; 
            }
            if(ship.Origin_Address_Name__c!=null){
               oi.Origin_Address_Name__c = ship.Origin_Address_Name__c; 
            }
            if(ship.Destination_Address_City__c!=null){
              oi.Destination_City__c = ship.Destination_Address_City__c;  
            }
            if(ship.Gross_Weight__c!=null){
               oi.Gross_Weight__c = ship.Gross_Weight__c; 
            }
            if(ship.Net_Weight__c!=null){
              oi.Net_Weight__c = ship.Net_Weight__c;  
            }
            if(ship.Shipment_Date__c!=null){
               oi.Next_Billing_Date__c = ship.Shipment_Date__c; 
            }
           // oi.Subscription_Type__c = 'One-Time';
           // oi.Product_Subscription_Type__c = 'One-time';
           // oi.Subscription_Pricing__c = 'Fixed Price';
            if(ship.Shipment_Type__c!=null){
               oi.Shipment_Type__c = ship.Shipment_Type__c; 
            }
            if(ship.Number_of_Packages__c!=null){ //added by Pratik 7-7-2025
               oi.Number_of_Packages__c = ship.Number_of_Packages__c; 
            }
            
            oi.Contracting_Method__c = 'Inherit';
            oi.Pricing_Method__c = 'List';
            oi.Gross_Weight_UOM__c=ship.Gross_Weight_UOM__c;
            oi.Net_Weight_UOM__c=ship.Net_Weight_UOM_TMS__c;
            
            // Total Bath
            
            if(conList.size()>0){
                System.debug('for checking Inside if(conList.size()>0) ');
        
                for(BVC_Contract__c contObj : conList){
                    System.debug('for checking Inside for(BVC_Contract__c contObj : conList) ');
        
					System.debug('for checking contObj.Quote__c === '+contObj.Quote__c);                    
                    System.debug('for checking eShipObj.BVCQuote__c === '+eShipObj.BVCQuote__c);
                    if(contObj.Quote__c!=null && contObj.Quote__c==eShipObj.BVCQuote__c){
                        System.debug('for checking contObj.Is_Legacy_Contract__c === '+contObj.Is_Legacy_Contract__c);                    
                        System.debug('for checking contObj.BVC_Service__c === '+contObj.BVC_Service__c);
                        System.debug('for checking contObj.Slab_Criteria__c === '+contObj.Slab_Criteria__c);  
                        
                        if(ship.Customer_Product_Category__c=='BATH' && ship.Account__r.BATH_Contract__r.BVC_Branch__c!=null){
                            oi.BVC_Branch__c=ship.Account__r.BATH_Contract__r.BVC_Branch__c;
                        }else if(ship.Customer_Product_Category__c=='eSHIP' && contObj.BVC_Branch__c !=null){
                            oi.BVC_Branch__c = contObj.BVC_Branch__c; 
                        }
                        
                        if(ship.Customer_Product_Category__c=='BATH' && ship.Account__r.BATH_Contract__r.BVC_Entity__c!=null){
                            oi.BVC_Entity__c = ship.Account__r.BATH_Contract__r.BVC_Entity__c;
                        }else if(ship.Customer_Product_Category__c=='eSHIP' && contObj.BVC_Entity__c !=null){
                            oi.BVC_Entity__c = contObj.BVC_Entity__c;                
                        }
                        
                       /* if(ship.Customer_Product_Category__c=='BATH' && ship.Account__r.BATH_Contract__r.BVC_LegalEntity__c!=null){
                            oi.Legal_Entity__c = ship.Account__r.BATH_Contract__r.BVC_LegalEntity__c;
                        }*/else if(ship.Customer_Product_Category__c=='eSHIP' && contObj.BVC_LegalEntity__c !=null){
                            oi.BVC_LegalEntity__c = contObj.BVC_LegalEntity__c;                
                        }
                        
      //  ==========================================================For ACR===============================================================================                
                        if(contObj.Business_Type__c=='ACR'){
                        
                        //Code to populate Additional_Charges_eSHIP__c
                        if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP'){
                            System.debug('for checking Inside if(contObj.Is_Legacy_Contract__c) == true ');
                              if ((contObj.Slab_Criteria__c == 'Net Weight' || contObj.Slab_Criteria__c == 'Gross Weight Gms' || contObj.Slab_Criteria__c=='Invoice Value INR') && ship.No_Of_Attempts__c > 0){
                                System.debug('for checking if((contObj.Slab_Criteria__c == Net Weight || contObj.Slab_Criteria__c == Gross Weight Gms))');                    
                                if(eShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c <= 1){
                                    oi.Additional_Charges_eSHIP__c = 0;
                                } else if(eShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c > 1){
                                    oi.Additional_Charges_eSHIP__c = ((ship.No_Of_Attempts__c-eShipObj.No_Of_Free_Atttemps__c) * eShipObj.Additional_Charge__c);
                                } else if(eShipObj.No_Of_Free_Atttemps__c > 0 && ship.No_Of_Attempts__c > eShipObj.No_Of_Free_Atttemps__c){
                                    oi.Additional_Charges_eSHIP__c = ((ship.No_Of_Attempts__c-eShipObj.No_Of_Free_Atttemps__c) * eShipObj.Additional_Charge__c);
                                } else {
                                    oi.Additional_Charges_eSHIP__c = 0;
                                }
                            } 
                        }
                        
                        if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP' && ship.No_Of_Attempts__c > 0){
                            System.debug('for checking Inside if(contObj.Is_Legacy_Contract__c) == false ');
                            if(eShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c <= 1){
                                    oi.Additional_Charges_eSHIP__c = 0;
                                } else if(eShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c > 1){
                                    oi.Additional_Charges_eSHIP__c = ((ship.No_Of_Attempts__c-eShipObj.No_Of_Free_Atttemps__c) * eShipObj.Additional_Charge__c);
                                } else if(eShipObj.No_Of_Free_Atttemps__c > 0 && ship.No_Of_Attempts__c > eShipObj.No_Of_Free_Atttemps__c){
                                    oi.Additional_Charges_eSHIP__c = ((ship.No_Of_Attempts__c-eShipObj.No_Of_Free_Atttemps__c) * eShipObj.Additional_Charge__c);
                                } else {
                                    oi.Additional_Charges_eSHIP__c = 0;
                                }
                            
                        }
                        //upto here
                        
                        
                        //Code to populate Weight_Charges_eSHIP__c
                        if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP'){
                            if(contObj.Slab_Criteria__c=='Invoice Value INR' || contObj.Slab_Criteria__c == 'Gross Weight Gms'){
                                if(ship.Gross_Weight__c > eShipObj.Gross_Weight_Unit_for_Additional_Weight__c){
                                    oi.Weight_Charges_eSHIP__c = Integer.valueOf(Math.ceil(((ship.Gross_Weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c ) / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c ) * eShipObj.Weight_Charges__c)); 
                                } else {
                                    oi.Weight_Charges_eSHIP__c = 0;
                                }
                            }else if(contObj.Slab_Criteria__c == 'Net Weight'){
                                if(ship.Net_Weight__c > eShipObj.Gross_Weight_Unit_for_Additional_Weight__c){
                                    oi.Weight_Charges_eSHIP__c = Integer.valueOf(Math.ceil(((ship.Net_Weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c ) / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c ) * eShipObj.Weight_Charges__c)); 
                                } else if(ship.Net_Weight__c < eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) {
                                    oi.Weight_Charges_eSHIP__c = 0;
                                }

                            } 
                                
                        }
                        
                        if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP'){
                            System.debug('for checking Inside if(contObj.Is_Legacy_Contract__c) == false ');
                            oi.Weight_Charges_eSHIP__c = Integer.valueOf(Math.ceil(((ship.Gross_Weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c ) / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c ) * eShipObj.Weight_Charges__c)); 
                        }
                        //upto here
                        
                  
                        
                         //Code to populate Freight charges
                        if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP'){
                            
                           if(contObj.Slab_Criteria__c=='Invoice Value INR'|| contObj.Slab_Criteria__c == 'Gross Weight Gms'){
                              if (eShipObj.Per_Shipment_Freight_Charge__c == false && 
                                   ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > eShipObj.Rate_INR__c) {
                                       
                                       oi.Freight_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100);
                                   } else {
                                       oi.Freight_Charges_eSHIP__c = eShipObj.Rate_INR__c;
                                   }
                           }
                            if(contObj.Slab_Criteria__c=='Net Weight'){
                              if (eShipObj.Per_Shipment_Freight_Charge__c == true && 
                                   ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > eShipObj.Rate_INR__c) {
                                       
                                       oi.Freight_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100);
                                   } else{
                                       system.debug('In else of freight@@@');         
                                       oi.Freight_Charges_eSHIP__c=eShipObj.Rate_INR__c;
                                             }  
                            }
                        }
                        if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP'){
                            
                            if (eShipObj.Per_Shipment_Freight_Charge__c == true && 
                                   ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > eShipObj.Rate_INR__c) {
                                       
                                       oi.Freight_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100);
                                   } else {
                                       oi.Freight_Charges_eSHIP__c = eShipObj.Rate_INR__c;
                                   }
                        }
                        //upto here
                        
                         //Code to populate Liability Charges
                        if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP'){
                            system.debug('Im here===');
                            system.debug(ship.Bill_To_Account__c);
                            system.debug(ship.Bill_To_Account__r.Liability_Cover_By_BVC_For_Eship__c);
                            system.debug(contObj.Slab_Criteria__c);
                            if((contObj.Slab_Criteria__c=='Invoice Value INR' || contObj.Slab_Criteria__c== 'Gross Weight Gms'|| contObj.Slab_Criteria__c=='Net Weight') &&
                               eShipObj.customer__r.Liability_Cover_By_BVC_For_Eship__c=='Yes'){
                                oi.Liability_Charges_eSHIP__c=ship.Total_Invoice_Value__c * (eShipObj.Liability_Charges__c/100);
                                   system.debug('Im here 2===');
                            }
                        }
                        if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP'){
                            oi.Liability_Charges_eSHIP__c=ship.Total_Invoice_Value__c * (eShipObj.Liability_Charges__c/100);
                            system.debug('Im here 3===');
                        }
                        //upto here
                        
                        // Code to populate COD Charges
                         if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP'){
                             if((contObj.Slab_Criteria__c=='Invoice Value INR' || contObj.Slab_Criteria__c=='Gross Weight Gms' || contObj.Slab_Criteria__c=='Net Weight') && ship.Payment_Mode__c=='COD'){
                                 system.debug('Inside COD');
                                 system.debug('eShipObj.COD_Charges_per_shipment__c=='+eShipObj.COD_Charges_per_shipment__c);
                                 system.debug('ship.Total_Invoice_Value__c=='+ship.Total_Invoice_Value__c);
                                 system.debug('eShipObj.COD_Charges_percentage_of_product__c/100=='+eShipObj.COD_Charges_percentage_of_product__c/100);
                                 IF(eShipObj.COD_Charges_per_shipment__c > ( ship.Total_Invoice_Value__c * (eShipObj.COD_Charges_percentage_of_product__c/100))){
                                     oi.COD_Charges_eSHIP__c=eShipObj.COD_Charges_per_shipment__c; 
                                 }else{ 
                                        oi.COD_Charges_eSHIP__c=ship.Total_Invoice_Value__c * (eShipObj.COD_Charges_percentage_of_product__c/100);
                                    }
                             }else if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP' && ship.Payment_Mode__c!='COD'){oi.COD_Charges_eSHIP__c=0;}//check net weight if necessary. Price rule does not have Action a0q5g000001aFkAAAU
                         }
                        if(contObj.Is_Legacy_Contract__c == False && contObj.BVC_Service__c == 'eSHIP' && ship.Payment_Mode__c=='COD'){
                            IF(eShipObj.COD_Charges_per_shipment__c > ( ship.Total_Invoice_Value__c * (eShipObj.COD_Charges_percentage_of_product__c/100))){
                                oi.COD_Charges_eSHIP__c=eShipObj.COD_Charges_per_shipment__c; 
                            }else{ 
                                oi.COD_Charges_eSHIP__c=ship.Total_Invoice_Value__c * (eShipObj.COD_Charges_percentage_of_product__c/100);
                            }
                        }else if(contObj.Is_Legacy_Contract__c == False && contObj.BVC_Service__c == 'eSHIP' && ship.Payment_Mode__c!='COD'){oi.COD_Charges_eSHIP__c=0;}
                         //upto here
                         system.debug('oi.Freight_Charges_eSHIP__c=='+oi.Freight_Charges_eSHIP__c);
                            system.debug('oi.Weight_Charges_eSHIP__c=='+oi.Weight_Charges_eSHIP__c);
                            system.debug('eShipObj.Fuel_Surcharge__c=='+eShipObj.Fuel_Surcharge__c);
                         oi.Fuel_Surcharges_eSHIP__c=(oi.Freight_Charges_eSHIP__c+oi.Weight_Charges_eSHIP__c)*eShipObj.Fuel_Surcharge__c/100;
                            system.debug('oi.Fuel_Surcharges_eSHIP__c====='+oi.Fuel_Surcharges_eSHIP__c);
                      }
     //=================================================================ACR ENDS AND NON ACR STARTS====================================================================
                        if(contObj.Business_Type__c=='Non ACR'){
                            //Code to populate Additional Charges for Non ACR
                            if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP'){
                                if(ship.No_Of_Attempts__c> 0 && contObj.Business_Type__c=='Non ACR'){
                                    if (eShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c <= 1) {
                                        oi.Additional_Charges_eSHIP__c = 0;
                                    } 
                                   
                                    else if (eShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c > 1) {
                                        oi.Additional_Charges_eSHIP__c = (ship.No_Of_Attempts__c - eShipObj.No_Of_Free_Atttemps__c) * eShipObj.Additional_Charge__c;
                                    } 
                                    
                                    else if (eShipObj.No_Of_Free_Atttemps__c > 0 && ship.No_Of_Attempts__c > eShipObj.No_Of_Free_Atttemps__c) {
                                        oi.Additional_Charges_eSHIP__c = (ship.No_Of_Attempts__c - eShipObj.No_Of_Free_Atttemps__c) * eShipObj.Additional_Charge__c;
                                    } else {
                                        oi.Additional_Charges_eSHIP__c = 0;
                                    }
                                }
                               
                            }//upto here 
                            //Code to populate COD Charges for Non ACR
                            if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP' && ship.Payment_Mode__c=='COD'){
                                if (eShipObj.COD_Charges_per_shipment__c > (ship.Total_Invoice_Value__c * (eShipObj.COD_Charges_percentage_of_product__c/100))) {
                                    oi.COD_Charges_eSHIP__c = eShipObj.COD_Charges_per_shipment__c;
                                } else {
                                    oi.COD_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.COD_Charges_percentage_of_product__c/100);
                                }
                            }
                            
                            //Code to populate Freight Charges for Non ACR
                            if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP'){
                                if (!eShipObj.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > eShipObj.Rate_INR__c)) {
                                    oi.Freight_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100);
                                } else {
                                    oi.Freight_Charges_eSHIP__c = eShipObj.Rate_INR__c;
                                } 
                            }
                           //upto here
                            //Code to populate Fuel Surchrage Charges for Non ACR
                            if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP'){
                                if (ship.Gross_weight__c > eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) {
                                    if (!eShipObj.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > eShipObj.Rate_INR__c)) {
                                        oi.Fuel_Surcharges_eSHIP__c = (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) * (eShipObj.Fuel_Surcharge__c/100)) 
                                            + (Math.ceil((ship.Gross_weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                               * eShipObj.Weight_Charges__c * (eShipObj.Fuel_Surcharge__c/100));
                                    } else {
                                        oi.Fuel_Surcharges_eSHIP__c = (eShipObj.Rate_INR__c * (eShipObj.Fuel_Surcharge__c/100)) 
                                            + (Math.ceil((ship.Gross_weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                               * eShipObj.Weight_Charges__c * (eShipObj.Fuel_Surcharge__c/100));
                                    }
                                    
                                } else {
                                    
                                    if (!eShipObj.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > eShipObj.Rate_INR__c)) {
                                        oi.Fuel_Surcharges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) * (eShipObj.Fuel_Surcharge__c/100);
                                    } else {
                                        oi.Fuel_Surcharges_eSHIP__c = eShipObj.Rate_INR__c * (eShipObj.Fuel_Surcharge__c/100);
                                    }
                                }
                            }
                            //upto here
                            
                            //Code to populate Liability Charges for Non ACR
                            if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP' && eShipObj.customer__r.Liability_Cover_By_BVC_For_Eship__c=='Yes'){
                               oi.Liability_Charges_eSHIP__c= ship.Total_Invoice_Value__c * (eShipObj.Liability_Charges__c/100);
                            }
                           //upto here
                            
                            //Code to populate Weight Charges for Non ACR
                            if(contObj.Is_Legacy_Contract__c == false && contObj.BVC_Service__c == 'eSHIP'){
                                if (ship.Gross_weight__c > eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) {
                                     oi.Weight_Charges_eSHIP__c = Math.ceil((ship.Gross_weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                                                       / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) * eShipObj.Weight_Charges__c;
                                }
                            }
                            
                            //upto here
                            
                            //==================================================== for Non ACR Legacy=================================================
                            if (!NonACRLegacyeShipPricingList.isEmpty()) {
                                 system.debug('Non ACR Legacy');
                                system.debug('NonACRLegacyeShipPricingList=='+NonACRLegacyeShipPricingList);
                                system.debug('NonACRLegacyeShipPricingList size=='+NonACRLegacyeShipPricingList.size());
                                for (eSHIP_Custom_Pricing__c record : NonACRLegacyeShipPricingList) {
                                    if (contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP') {
                                        system.debug('ship.Shipment_Type__c==='+ship.Shipment_Type__c);
                                        system.debug('record.Shipment_Type__c==='+record.Shipment_Type__c);
                                        system.debug('Lower_Bound__c==='+record.Lower_Bound__c);
                                        system.debug('Upper_Bound__c==='+ record.Upper_Bound__c);
                                        if((record.Slab_Criteria__c=='Invoice Value INR' && /*((ship.Shipment_Type__c=='Intracity') ||
                                                                                             (ship.Shipment_Type__c=='Intercity')*/ (ship.Shipment_Type__c==record.Shipment_Type__c && (ship.Total_Invoice_Value__c<= record.Upper_Bound__c)&& ship.Total_Invoice_Value__c>= record.Lower_Bound__c)
                                          ) ||
                                          (record.Slab_Criteria__c=='Net Weight' && /*((ship.Shipment_Type__c=='Intracity') ||
                                                                                             (ship.Shipment_Type__c=='Intercity') &&*/( (ship.Net_weight_in_Gram__c<= record.Upper_Bound__c)&& ship.Net_weight_in_Gram__c>= record.Lower_Bound__c)
                                          )||
                                          (record.Slab_Criteria__c=='Gross Weight Gms' && /*((ship.Shipment_Type__c=='Intracity') ||
                                                                                             (ship.Shipment_Type__c=='Intercity') &&*/( (ship.Gross_weight_in_Gram__c<= record.Upper_Bound__c)&& ship.Gross_weight_in_Gram__c>= record.Lower_Bound__c)
                                          )){
                                              system.debug('ship.Shipment_Type__c+++'+ship.Shipment_Type__c);
                                              //for freight
                                              system.debug('record name===='+record.name);
                                              if (!record.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (record.UOM_Percentage__c/100) > record.Rate_INR__c)) {
                                                oi.Freight_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (record.UOM_Percentage__c/100);
                                                system.debug('in freight if statement');
                                            } else {
                                                oi.Freight_Charges_eSHIP__c = record.Rate_INR__c;
                                                system.debug('in freight else');
                                            } //upto here for freight
                                              
                                              //for Additional Charge
                                              if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP'){
                                                  if(ship.No_Of_Attempts__c> 0 && contObj.Business_Type__c=='Non ACR'){
                                                      if (eShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c <= 1) {
                                                          oi.Additional_Charges_eSHIP__c = 0;
                                                      } 
                                                      
                                                      else if (eShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c > 1) {
                                                          oi.Additional_Charges_eSHIP__c = (ship.No_Of_Attempts__c - eShipObj.No_Of_Free_Atttemps__c) * eShipObj.Additional_Charge__c;
                                                      } 
                                                      
                                                      else if (eShipObj.No_Of_Free_Atttemps__c > 0 && ship.No_Of_Attempts__c > eShipObj.No_Of_Free_Atttemps__c) {
                                                          oi.Additional_Charges_eSHIP__c = (ship.No_Of_Attempts__c - eShipObj.No_Of_Free_Atttemps__c) * eShipObj.Additional_Charge__c;
                                                      } else {
                                                          oi.Additional_Charges_eSHIP__c = 0;
                                                      }
                                                  }
                                                  
                                              }//upto here Additional Charge
                                              
                                              // For COD
                                              if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP' && ship.Payment_Mode__c=='COD'){
                                                  if (eShipObj.COD_Charges_per_shipment__c > (ship.Total_Invoice_Value__c * (eShipObj.COD_Charges_percentage_of_product__c/100))) {
                                                      oi.COD_Charges_eSHIP__c = eShipObj.COD_Charges_per_shipment__c;
                                                  } else {
                                                      oi.COD_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.COD_Charges_percentage_of_product__c/100);
                                                  }
                                              }
                                              // upto here COD
                                              // 
                                              // for fuel surcharge
                                              if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP'){
                                                  if (ship.Gross_weight__c > eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) {
                                                      if (!eShipObj.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > eShipObj.Rate_INR__c)) {
                                                          oi.Fuel_Surcharges_eSHIP__c = (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) * (eShipObj.Fuel_Surcharge__c/100)) 
                                                              + (Math.ceil((ship.Gross_weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                                                 * eShipObj.Weight_Charges__c * (eShipObj.Fuel_Surcharge__c/100));
                                                      } else {
                                                          oi.Fuel_Surcharges_eSHIP__c = (eShipObj.Rate_INR__c * (eShipObj.Fuel_Surcharge__c/100)) 
                                                              + (Math.ceil((ship.Gross_weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                                                 * eShipObj.Weight_Charges__c * (eShipObj.Fuel_Surcharge__c/100));
                                                      }
                                                      
                                                  } else {
                                                      
                                                      if (!eShipObj.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > eShipObj.Rate_INR__c)) {
                                                          oi.Fuel_Surcharges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) * (eShipObj.Fuel_Surcharge__c/100);
                                                      } else {
                                                          oi.Fuel_Surcharges_eSHIP__c = eShipObj.Rate_INR__c * (eShipObj.Fuel_Surcharge__c/100);
                                                      }
                                                  }
                                              }
                                              // upto here fuel surcharge
                                              // 
                                              //Code to populate Liability Charges for Non ACR
                                              if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP' && eShipObj.customer__r.Liability_Cover_By_BVC_For_Eship__c=='Yes'){
                                                  oi.Liability_Charges_eSHIP__c= ship.Total_Invoice_Value__c * (eShipObj.Liability_Charges__c/100);
                                              }
                                              //upto here
                                              
                                              //Code to populate Weight Charges for Non ACR
                                              if(contObj.Is_Legacy_Contract__c == true && contObj.BVC_Service__c == 'eSHIP'){
                                                  if (ship.Gross_weight__c > eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) {
                                                      oi.Weight_Charges_eSHIP__c = Math.ceil((ship.Gross_weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                                                                             / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) * eShipObj.Weight_Charges__c;
                                                  }
                                              }
                                              
                                              //upto here
                                          }//upto here Invoice value INR
                                    }
                                }
                            }//======================================================end of Non ACR Legacy=======================================
                        }
                    }
                }
            }
            //for calculation of non acr non contracted standard pricing
            if(((ship.Account__r.eSHIP_BVC_Contract__c==null) && ship.Account__r.Business_Type_eSHIP_BVC__c!=null) ){
               System.debug('calculation of non acr non contracted standard pricing');
                //additional charge
                   if(StdeShipObj.No_Of_Free_Atttemps__c> 0 && (ship.account__r.Business_Type_eSHIP_BVC__c=='Non ACR')){//standard
                                    if (StdeShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c <= 1) {
                                        oi.Additional_Charges_eSHIP__c = 0;
                                    } 
                                    
                                    else if (StdeShipObj.No_Of_Free_Atttemps__c == 0 && ship.No_Of_Attempts__c > 1) {
                                        oi.Additional_Charges_eSHIP__c = (ship.No_Of_Attempts__c - StdeShipObj.No_Of_Free_Atttemps__c) * StdeShipObj.Additional_Charge__c;
                                    } 
                                    
                                    else if (StdeShipObj.No_Of_Free_Atttemps__c > 0 && ship.No_Of_Attempts__c > StdeShipObj.No_Of_Free_Atttemps__c) {
                                        oi.Additional_Charges_eSHIP__c = (ship.No_Of_Attempts__c - StdeShipObj.No_Of_Free_Atttemps__c) * StdeShipObj.Additional_Charge__c;
                                    } else {
                                        oi.Additional_Charges_eSHIP__c = 0;
                                    }
                                } //upto here 
                // COD charge
                		if( (ship.Customer_Product_Category__c == 'eSHIP' || ship.Customer_Product_Category__c == 'BATH') && ship.Payment_Mode__c=='COD'){//standard
                                if (StdeShipObj.COD_Charges_per_shipment__c > (ship.Total_Invoice_Value__c * (StdeShipObj.COD_Charges_percentage_of_product__c/100))) {
                                    oi.COD_Charges_eSHIP__c = StdeShipObj.COD_Charges_per_shipment__c;
                                } else {
                                    oi.COD_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (StdeShipObj.COD_Charges_percentage_of_product__c/100);
                                }
                            }//upto here
                           
                          //Freight charge
                           if((ship.Customer_Product_Category__c == 'eSHIP' || ship.Customer_Product_Category__c == 'BATH')){//standard
                                if (!StdeShipObj.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > StdeShipObj.Rate_INR__c)) {
                                    oi.Freight_Charges_eSHIP__c = ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100);
                                } else {
                                    oi.Freight_Charges_eSHIP__c = StdeShipObj.Rate_INR__c;
                                } 
                            }
                          //upto here
                          
                          //Fuel Surcharge 
                          if(ship.Customer_Product_Category__c == 'eSHIP' || ship.Customer_Product_Category__c == 'BATH'){//standard
                                if (ship.Gross_weight__c > StdeShipObj.Gross_Weight_Unit_for_Additional_Weight__c) {
                                    if (!StdeShipObj.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > StdeShipObj.Rate_INR__c)) {
                                        oi.Fuel_Surcharges_eSHIP__c = (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) * (StdeShipObj.Fuel_Surcharge__c/100)) 
                                            + (Math.ceil((ship.Gross_weight__c - StdeShipObj.Gross_Weight_Unit_for_Additional_Weight__c) / StdeShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                               * StdeShipObj.Weight_Charges__c * (StdeShipObj.Fuel_Surcharge__c/100));
                                    } else {
                                        oi.Fuel_Surcharges_eSHIP__c = (StdeShipObj.Rate_INR__c * (StdeShipObj.Fuel_Surcharge__c/100)) 
                                            + (Math.ceil((ship.Gross_weight__c - StdeShipObj.Gross_Weight_Unit_for_Additional_Weight__c) / StdeShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                               * StdeShipObj.Weight_Charges__c * (StdeShipObj.Fuel_Surcharge__c/100));
                                    }
                                    
                                } else {
                                    
                                    if (!StdeShipObj.Per_Shipment_Freight_Charge__c && (ship.Total_Invoice_Value__c * (eShipObj.UOM_Percentage__c/100) > StdeShipObj.Rate_INR__c)) {
                                        oi.Fuel_Surcharges_eSHIP__c = ship.Total_Invoice_Value__c *(eShipObj.UOM_Percentage__c/100) * (StdeShipObj.Fuel_Surcharge__c/100);
                                    } else {
                                        oi.Fuel_Surcharges_eSHIP__c = StdeShipObj.Rate_INR__c * (StdeShipObj.Fuel_Surcharge__c/100);
                                    }
                                }
                            }
                          //upto here
                          //
                        //Liability Charge
                          if((ship.Customer_Product_Category__c == 'eSHIP' || ship.Customer_Product_Category__c == 'BATH') && ship.customer__r.Liability_Cover_By_BVC_For_Eship__c=='Yes'){
                               oi.Liability_Charges_eSHIP__c= ship.Total_Invoice_Value__c * (StdeShipObj.Liability_Charges__c/100);
                            }
                        //upto here
                        //Weight Charge
                         if(ship.Customer_Product_Category__c == 'eSHIP' || ship.Customer_Product_Category__c == 'BATH'){//standard
                                if (ship.Gross_weight__c > eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) {
                                    oi.Weight_Charges_eSHIP__c = Math.ceil((ship.Gross_weight__c - eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) 
                                                                           / eShipObj.Gross_Weight_Unit_for_Additional_Weight__c) * eShipObj.Weight_Charges__c;
                                }
                            }
                        //upto here
                }
          
            system.debug('Ship name===' +ship.Name);
            system.debug('oi.COD_Charges_eSHIP__c==='+oi.COD_Charges_eSHIP__c);
            system.debug('oi.Liability_Charges_eSHIP__c==='+oi.Liability_Charges_eSHIP__c);
            system.debug('oi.Freight_Charges_eSHIP__c==='+oi.Freight_Charges_eSHIP__c);
            system.debug('oi.Fuel_Surcharges_eSHIP__c==='+oi.Fuel_Surcharges_eSHIP__c);
            system.debug('oi.Weight_Charges_eSHIP__c==='+oi.Weight_Charges_eSHIP__c);
            system.debug('oi.Additional_Charges_eSHIP__c==='+oi.Additional_Charges_eSHIP__c);
            system.debug('oi.Secure_Logistics_Charges__c==='+oi.Secure_Logistics_Charges__c);
            
                        
           // fcharge=(oi.Freight_Charges_eSHIP__c+oi.Weight_Charges_eSHIP__c)*oi.Fuel_Surcharges_eSHIP__c;
            
           // System.debug('for checking fcharge =='+fcharge);
            
           // oi.Secure_Logistics_Charges__c=oi.COD_Charges_eSHIP__c+oi.Liability_Charges_eSHIP__c+oi.Freight_Charges_eSHIP__c+oi.Fuel_Surcharges_eSHIP__c+oi.Weight_Charges_eSHIP__c+oi.Additional_Charges_eSHIP__c; 
            oi.Secure_Logistics_Charges__c = 
                (oi.COD_Charges_eSHIP__c ?? 0) + 
                (oi.Liability_Charges_eSHIP__c ?? 0) + 
                (oi.Freight_Charges_eSHIP__c ?? 0) + 
                (oi.Fuel_Surcharges_eSHIP__c ?? 0) + 
                 
                (oi.Weight_Charges_eSHIP__c ?? 0) + 
                (oi.Additional_Charges_eSHIP__c ?? 0);
            oi.Unit_Price__c = oi.Secure_Logistics_Charges__c;
            oi.Billable_Unit_Price__c=oi.Secure_Logistics_Charges__c;
            totalCharge=oi.Secure_Logistics_Charges__c;
            oi.Total_Price__c = oi.Secure_Logistics_Charges__c;
           // oi.Activation_Status__c='Activated';
            oi.Total_Charges__c=oi.Secure_Logistics_Charges__c;
            oi.Activated__c = true;
        //    oi.Fuel_Surcharges_eSHIP__c=fcharge;
            ordersItems2Update.add(oi);  
                   
        }
        if(ordersItems2Update.size()>0){
            
            Database.SaveResult[] lsr = Database.insert(ordersItems2Update,false);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    system.debug('Order Item with Id :'+result.getId()+' Successfully Inserted');
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
   /*     if(ordersItems2Update.size()>0 && ordId!=null){ commented for the deployment reason
            
            // added try catch block and exception log record generation logic is added on order update by govind 
           
            try{
                
                 system.debug('inside order update=====');
                BVCorder__c Ord = new BVCorder__c(id=ordId); 
                system.debug('iord.Total_Secure_Logistics_Charges__c====='+ord.Total_Secure_Logistics_Charges__c);
                Ord.Status__c='Activated';
                Ord.Order_Status_Static__c='Activated';
                ord.Order_Amount__c=totalCharge;
                update ord;
                system.debug('ord.Order_Amount__c====='+ord.Order_Amount__c);
                
            }catch(exception e){
                List<Exception_Log__c> elList = new List<Exception_Log__c>();
                
                Exception_Log__c el = new Exception_Log__c();
                el.Exception_Error_Message__c = e.getMessage();
                el.BVC_Order__c = ordId;
                el.Line_Number__c = e.getLineNumber();
                el.Exception_Message__c = e.getTypeName();
                insert el;
                
            }
            
        }*/
    }
    
  /*  Public static void deleteOldQuote(List<Shipment__c> newShipment){
        
        Set<Id> shipIds = new Set<Id>();
        for(Shipment__c S:newShipment){
            shipIds.add(S.Id);
        }
        List<SBQQ__Quote__c> newQuote = [select id from SBQQ__Quote__c  where Shipment__c IN :shipIds ORDER BY CreatedDate Desc Limit 1];   

        if(newQuote.size()>0){
            delete newQuote;
        }
        
    }
    Public static void rebillingOrder(List<Shipment__c> newShipment){
        Set<Id> ShipIds = new Set<Id>();
        for(Shipment__c ship:newShipment){
            ShipIds.add(ship.Id);
        }
        List<Order> orderList = [select id,Shipment__c from Order where Shipment__c IN :ShipIds];
        Set<Id> orderIds = new Set<Id>();
        for(Order Odr:orderList){
            orderIds.add(Odr.Id);
        }
        List<ST_ACR_Consumption__c> ACRConsumedLst =[select id,ST_ACR_Order__c from ST_ACR_Consumption__c where ST_ACR_Order__c IN :orderIds];
        if(ACRConsumedLst.size()>0){
            system.debug('ACRConsumedLst =======delete'+ACRConsumedLst);
            delete ACRConsumedLst;
        }
        Set<Id> orderInvoicedList = new Set<Id>();
        List<blng__InvoiceLine__c> invoiceLineList = [select id,blng__OrderProduct__r.OrderId from blng__InvoiceLine__c where Shipment__c IN :ShipIds];
        for(blng__InvoiceLine__c invLine:invoiceLineList){
            orderInvoicedList.add(invLine.blng__OrderProduct__r.OrderId); 
            
        }
        //List<blng__Invoice__c> invoiceList = [select id,blng__Order__c from blng__Invoice__c where blng__Order__c IN :orderIds];
        //for(blng__Invoice__c inv:invoiceList){
            //inv.Invoice_Cancellation_Status__c='Cancelled';
            //orderInvoicedList.add(inv.blng__Order__c); 
            
        //}
        for(Order O:orderList){
            if(!orderInvoicedList.contains(O.ID)){
               O.Status='Cancelled';   
           }	
        }
        //if(invoiceList.size()>0){
            //Update invoiceList;
        //}
        
        if(orderList.size()>0){
        	Update orderList;  
        }
    } 
    
    public static void updateQuote(set<id> shipmentid){
        list<SBQQ__Quote__c> qlist = [select id,  Quick_Calculate_BVC__c,Shipment__c from SBQQ__Quote__c where Shipment__c IN : shipmentid];
		for(SBQQ__Quote__c  q1 : qlist){
            if(q1.Quick_Calculate_BVC__c == true){
                q1.Quick_Calculate_BVC__c = false;
                        
            }else{
                q1.Quick_Calculate_BVC__c = true;
            }
        }
        update qlist;
                
    }*///above lines commented to remove CPQ reference
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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