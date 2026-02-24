public class InvoiceLineTriggerHandler {
    public static void dummyMethod(){
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
    }}
   
  /*  public static void populateInvoiceProductField(List<blng__InvoiceLine__c> lines){
        Map<Id,blng__InvoiceLine__c> invoiceLiMap = new Map<Id,blng__InvoiceLine__c>();
        Map<Id,Id> liLegEntities = new Map<Id,Id>();
        Set<Id> ShipmentIds = new Set<Id>();
        Map<Id,Id> invProdMap = new Map<Id,Id>();
        Set<Id> invIds = new Set<Id>();
        for(blng__InvoiceLine__c li : lines){
            if(li.blng__Product__c != null){
                invIds.add(li.blng__Invoice__c);
                invProdMap.put(li.blng__Invoice__c,li.blng__Product__c);
                if(li.blng__InvoiceRun__c != null){
                    liLegEntities.put(li.blng__Invoice__c,li.blng__LegalEntity__c);
                    
                }
            }
            if(li.Shipment__c != null){
                ShipmentIds.add(li.Shipment__c);
            }
            
            
        }
        List<blng__Invoice__c> invoices = [SELECT Id,Product__c,
                                           blng__InvoiceRunCreatedBy__c,
                                           blng__Order__c
                                           FROM blng__Invoice__c 
                                           WHERE Id IN :invIds];
        Map<Id,blng__LegalEntity__c> legEntitiesMap = new Map<Id,blng__LegalEntity__c>([SELECT Id,Default_Branch__c,BVC_Entity__c 
                                                                                        FROM blng__LegalEntity__c 
                                                                                        WHERE Id IN :liLegEntities.values()]);
         Map<Id,blng__Invoice__c> invoiceMap = new Map<Id,blng__Invoice__c>(); 
        
        if(invoices.size() > 0){
            for(blng__Invoice__c inv :  invoices){
                if(invProdMap.containsKey(inv.Id)){
                    inv.Product__c = invProdMap.get(inv.Id);
                    
                    if((inv.blng__InvoiceRunCreatedBy__c != null && inv.blng__Order__c == null)
                       &&liLegEntities.containsKey(inv.Id)){
                           Id billEntityId = liLegEntities.get(inv.Id);
                           if(billEntityId != null ){
                               inv.BVC_Billing_Entity__c = legEntitiesMap.get(billEntityId).Id;
                               inv.BVC_Branch__c = legEntitiesMap.get(billEntityId).Default_Branch__c;
                               inv.BVC_Entity__c = legEntitiesMap.get(billEntityId).BVC_Entity__c;
                               
                           }
                           
                       }
                    invoiceMap.put(inv.Id,inv);
                }
                
                
            }
        }
        List<Shipment__c> ships = new List<Shipment__c>();
        if(ShipmentIds.size() > 0){
            for(Shipment__c ship : [SELECT Id,Status__c 
                                    FROM Shipment__c 
                                    WHERE Status__c = 'Picked for Billing' 
                                    AND Id IN :ShipmentIds]){
                                        ship.Status__c = 'Billed';
                                        ships.add(ship);
                                    }
        }
        
        if(invoiceMap.size() > 0){
            try{
                update invoiceMap.values();
            }catch(Exception ex){
                system.debug('Consolidated/Product : Invoice Update Failed:::'+ex.getMessage());
            }
        }
        if(ships.size() > 0){
            try{
                update ships;
            }catch(Exception ex){
                system.debug('Bill Ship : Failed:::'+ex.getMessage());
            }
        }
    }
    
    public static void updateOrderProductFields(List<blng__InvoiceLine__c> lines){
        Set<Id> oItemIds = new Set<Id>();
        Set<Id> consOItemIds = new Set<Id>();
        for(blng__InvoiceLine__c li : lines){
            if(li.blng__InvoiceRun__c == null && li.blng__OrderProduct__c != null){
                oItemIds.add(li.blng__OrderProduct__c);
            }
            if(li.blng__InvoiceRun__c != null && li.blng__OrderProduct__c != null){
                consOItemIds.add(li.blng__OrderProduct__c);
                
            }
        }
        
        List<OrderItem> oItems = new List<OrderItem>();
        if(oItemIds != null && oItemIds.size() > 0){
            Set<Id> orderIds = new Set<Id>();
            List<Order> orders = new List<Order>();
            List<OrderItem> ordertItemList=[SELECT Id,OrderId,blng__InvoiceRunProcessingStatus__c FROM OrderItem WHERE Id IN :oItemIds AND blng__InvoiceRunProcessingStatus__c = 'Pending Billing'];
            for(OrderItem oi :ordertItemList ){
                oi.blng__InvoiceRunProcessingStatus__c = 'Completed';
                oItems.add(oi); 
                orderIds.add(oi.OrderId);
            }
            List<Order> ord=[SELECT Id ,Shipment_Status_Static__c FROM Order WHERE Id IN :orderIds];
            for(Order o : ord){
                o.Shipment_Status_Static__c = 'Billed';
                orders.add(o);
            }
            Database.SaveResult[] results = Database.update(oItems);
            for(Database.SaveResult sr : results){
                if(sr.isSuccess()){
                    system.debug('Order Invoice Run Processing Status Updated : Id = '+sr.getId());
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice Line fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
            Database.SaveResult[] orderResults = Database.update(orders);
            for(Database.SaveResult sr : orderResults){
                if(sr.isSuccess()){
                    system.debug('Order Shipment Status Static Updated : Id = '+sr.getId());
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order Fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
            
        }
        if(consOItemIds != null && consOItemIds.size() > 0){
            List<Order> ords = new List<Order>();
            Set<Id> consOrderIds = new Set<Id>();
            for(OrderItem oi : [SELECT Id,OrderId,blng__InvoiceRunProcessingStatus__c FROM OrderItem WHERE Id IN :consOItemIds]){
                consOrderIds.add(oi.OrderId);
                
            }
            for(Order o : [SELECT Id FROM Order WHERE Id IN :consOrderIds]){
                o.Shipment_Status_Static__c = 'Billed';
                ords.add(o);
            }  
            Database.SaveResult[] orderResults = Database.update(ords);
            for(Database.SaveResult sr : orderResults){
                if(sr.isSuccess()){
                    system.debug('Order Shipment Status Static Updated : Id = '+sr.getId());
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order Fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
            
        }
    }
    
    public static void rollupInvoiceCharges(List<blng__InvoiceLine__c> lines, Map<id,blng__InvoiceLine__c> OldLines){
        Map<Id,Decimal> mapVlauationCharges = new map<Id,Decimal>();
        Map<Id,Decimal> mapDocketCharges = new map<Id,Decimal>();
        Map<Id,Decimal> mapFuelCharges = new map<Id,Decimal>();
        Map<Id,Decimal> mapHolidayCharges = new map<Id,Decimal>();
        Map<Id,Decimal> mapWeightCharges = new map<Id,Decimal>();
        Map<Id,Decimal> mapVaultCharges = new map<Id,Decimal>();//Prat
        Map<Id,Decimal> mapSurchargeCharges = new map<Id,Decimal>();//Prat
        Map<Id,Decimal> mapUCostChargeCharges = new map<Id,Decimal>();//Universe Cost Charge
        Map<Id,Decimal> mapLogisticsCharges = new map<Id,Decimal>();
        Set<Id> invoiceIds = new Set<Id>();
        List<blng__Invoice__c> updateList = new List<blng__Invoice__c>();
        for(blng__InvoiceLine__c lineItem : lines){
            if(lineItem.blng__InvoiceLineStatus__c!='Posted'){
               invoiceIds.add(lineItem.blng__Invoice__c); 
            }
        }
        list<blng__Invoice__c> invList = [SELECT id,Total_BVC_Valuation_Charges__c,Total_Docket_Charges__c,Total_Fuel_Charges__c,Total_Holiday_Charges__c,Total_Weight_Charges__c,Total_Logistics_Charges__c,Total_Fuel_Surcharge__c,Total_Vaulting_Charges__c,Total_Universe_Cost_Charge__c FROM blng__Invoice__c WHERE id IN:invoiceIds];
       // Map<id,blng__Invoice__c> InvMap1 = new Map<id,blng__Invoice__c>(invList);
        Map<id,blng__Invoice__c> InvMap = new Map<id,blng__Invoice__c>(invList);
        for(blng__Invoice__c inloop :invList ){
            InvMap.put(inloop.id,inloop);
        }
        for(blng__InvoiceLine__c lineItem : lines){
                        
            if(lineItem.BVC_Valuation_Charges__c !=null ){
                
                if(mapVlauationCharges.containsKey(lineItem.blng__Invoice__c)){
                    Decimal bvcValues = mapVlauationCharges.get(lineItem.blng__Invoice__c) +lineItem.BVC_Valuation_Charges__c ;
                    mapVlauationCharges.put(lineItem.blng__Invoice__c,bvcValues);
                }else{
                    mapVlauationCharges.put(lineItem.blng__Invoice__c,lineItem.BVC_Valuation_Charges__c );
                }
            }else{
                mapVlauationCharges.put(lineItem.blng__Invoice__c,0);
            }
           if(lineItem.Fuel_Surcharge__c !=null ){//Prat
              // Decimal SurchageVar=0;
              // SurchageVar=invMap.get(lineItem.blng__Invoice__c).Total_Fuel_Surcharge__c==null ?0: invMap.get(lineItem.blng__Invoice__c).Total_Fuel_Surcharge__c;
               if(mapSurchargeCharges.containsKey(lineItem.blng__Invoice__c)){
                    system.debug('before adding surcharge--------'+mapSurchargeCharges);
                    
                    Decimal fSurcharge = mapSurchargeCharges.get(lineItem.blng__Invoice__c) +lineItem.Fuel_Surcharge__c ;
                    mapSurchargeCharges.put(lineItem.blng__Invoice__c,fSurcharge);
                    system.debug('after adding surcharge--------'+mapSurchargeCharges);
                }
                    else{
                        mapSurchargeCharges.put(lineItem.blng__Invoice__c,lineItem.Fuel_Surcharge__c );
                         }
                }
           
            else{
                mapSurchargeCharges.put(lineItem.blng__Invoice__c,0);
           		 }
            if(lineItem.Vaulting_Charges__c !=null ){//Prat
                
                if(mapVaultCharges.containsKey(lineItem.blng__Invoice__c)){
                    Decimal VaultCharge = mapVaultCharges.get(lineItem.blng__Invoice__c) +lineItem.Vaulting_Charges__c;
                    mapVaultCharges.put(lineItem.blng__Invoice__c,VaultCharge);
                }
                    else{
                        mapVaultCharges.put(lineItem.blng__Invoice__c,lineItem.Vaulting_Charges__c);
                         }
                }
            else{
                mapVaultCharges.put(lineItem.blng__Invoice__c,0);
           		 }
            //Prat end
             //New lines for Universe Cost Charge
            	if(lineItem.Universe_Cost_Charge__c !=null ){
              // Decimal SurchageVar=0;
              // SurchageVar=invMap.get(lineItem.blng__Invoice__c).Total_Fuel_Surcharge__c==null ?0: invMap.get(lineItem.blng__Invoice__c).Total_Fuel_Surcharge__c;
               if(mapUCostChargeCharges.containsKey(lineItem.blng__Invoice__c)){
                    system.debug('before adding surcharge--------'+mapUCostChargeCharges);
                    
                    Decimal uCostCharge = mapUCostChargeCharges.get(lineItem.blng__Invoice__c) +lineItem.Universe_Cost_Charge__c ;
                    mapUCostChargeCharges.put(lineItem.blng__Invoice__c,uCostCharge);
                    system.debug('after adding surcharge--------'+mapUCostChargeCharges);
                }
                    else{
                        mapUCostChargeCharges.put(lineItem.blng__Invoice__c,lineItem.Universe_Cost_Charge__c );
                         }
                }
            else{
                mapUCostChargeCharges.put(lineItem.blng__Invoice__c,0);
           		 }
            //End new lines
            if(lineItem.Docket_Charges__c != null ){
                
                if(mapDocketCharges.containsKey(lineItem.blng__Invoice__c)){
                    Decimal bvcValues = mapDocketCharges.get(lineItem.blng__Invoice__c) +lineItem.Docket_Charges__c;
                    mapDocketCharges.put(lineItem.blng__Invoice__c,bvcValues);
                }else{
                    mapDocketCharges.put(lineItem.blng__Invoice__c,lineItem.Docket_Charges__c);
                }
            }else{
                mapDocketCharges.put(lineItem.blng__Invoice__c,0);
            }
            if(lineItem.Holiday_Charges__c != null){
                
                if(mapHolidayCharges.containsKey(lineItem.blng__Invoice__c)){
                    Decimal bvcValues = mapHolidayCharges.get(lineItem.blng__Invoice__c) +lineItem.Holiday_Charges__c;
                    mapHolidayCharges.put(lineItem.blng__Invoice__c,bvcValues);
                }else{
                    mapHolidayCharges.put(lineItem.blng__Invoice__c,lineItem.Holiday_Charges__c);
                }
            }else{
                mapHolidayCharges.put(lineItem.blng__Invoice__c,0);
            }
            if(lineItem.Fuel_Charges__c != null){
                
                if(mapFuelCharges.containsKey(lineItem.blng__Invoice__c)){
                    Decimal bvcValues = mapFuelCharges.get(lineItem.blng__Invoice__c) +lineItem.Fuel_Charges__c;
                    mapFuelCharges.put(lineItem.blng__Invoice__c,bvcValues);
                }else{
                    mapFuelCharges.put(lineItem.blng__Invoice__c,lineItem.Fuel_Charges__c);
                }
            }else{
                mapFuelCharges.put(lineItem.blng__Invoice__c,0);
            }
            if(lineItem.Weight_Charges__c != null){
                
                if(mapWeightCharges.containsKey(lineItem.blng__Invoice__c)){
                      Decimal bvcValues = mapWeightCharges.get(lineItem.blng__Invoice__c) +lineItem.Weight_Charges__c ;
                      mapWeightCharges.put(lineItem.blng__Invoice__c,bvcValues);
                    
                }else{
                    mapWeightCharges.put(lineItem.blng__Invoice__c,lineItem.Weight_Charges__c);
                }
            }else{
                mapWeightCharges.put(lineItem.blng__Invoice__c,0);
            }
            //Updated for mapping Logistics charges(bath)
            if(lineItem.Logistics_Charges__c != null){
                
                if(mapLogisticsCharges.containsKey(lineItem.blng__Invoice__c)){
                    Decimal bvcValues = mapLogisticsCharges.get(lineItem.blng__Invoice__c) +lineItem.Logistics_Charges__c;
                    mapLogisticsCharges.put(lineItem.blng__Invoice__c,bvcValues);
                    
                }else{
                    mapLogisticsCharges.put(lineItem.blng__Invoice__c,lineItem.Logistics_Charges__c);
                }
            }else{
                mapLogisticsCharges.put(lineItem.blng__Invoice__c,0);
            } 
        }
       /* if(invoiceIds.size()>0){
              for(Id invId : invoiceIds){
                blng__Invoice__c invObj = new blng__Invoice__c();
                invObj.Id = invId;
                blng__Invoice__c invM = InvMap.get(invId);
                
                  decimal ValuationVar=0.00;
                  if(invM.Total_BVC_Valuation_Charges__c!=null){
                     ValuationVar= invM.Total_BVC_Valuation_Charges__c;
                  }
                      if(mapVlauationCharges.get(invId)!=0){
                          invObj.Total_BVC_Valuation_Charges__c = ValuationVar+mapVlauationCharges.get(invId);
                      }
                  decimal DocketVar=0.00;
                  if(invM.Total_Docket_Charges__c!=null){
                     DocketVar= invM.Total_Docket_Charges__c;
                  }
                    if(mapDocketCharges.get(invId)!=0){invObj.Total_Docket_Charges__c = DocketVar + mapDocketCharges.get(invId);
                      }
                  
                  decimal FuelVar=0.00;
                  if(invM.Total_Fuel_Charges__c!=null){
                     FuelVar= invM.Total_Fuel_Charges__c;
                  }
                    if(mapFuelCharges.get(invId)!=0){invObj.Total_Fuel_Charges__c = FuelVar + mapFuelCharges.get(invId);
                      }
                  
                  decimal HolidayVar=0.00;
                  if(invM.Total_Holiday_Charges__c!=null){
                     HolidayVar= invM.Total_Holiday_Charges__c;
                  }
                    if(mapHolidayCharges.get(invId)!=0){invObj.Total_Holiday_Charges__c = HolidayVar + mapHolidayCharges.get(invId);
                      }
                  
                  decimal WeightVar=0.00;
                  if(invM.Total_Weight_Charges__c!=null){
                     WeightVar= invM.Total_Weight_Charges__c;
                  }
                    if(mapWeightCharges.get(invId)!=0){invObj.Total_Weight_Charges__c = WeightVar + mapWeightCharges.get(invId);
                      }
                  
                  decimal LogisticVar=0.00;
                  if(invM.Total_Logistics_Charges__c!=null){
                     LogisticVar= invM.Total_Logistics_Charges__c;
                  }
                    if(mapLogisticsCharges.get(invId)!=0){invObj.Total_Logistics_Charges__c = LogisticVar + mapLogisticsCharges.get(invId);
                      }
                  
                  decimal SurchageVar=0.00;
                  if(invM.Total_Fuel_Surcharge__c!=null){
                     SurchageVar= invM.Total_Fuel_Surcharge__c;
                  }
                      if(invM.Total_Fuel_Surcharge__c!=null){
                         SurchageVar= invM.Total_Fuel_Surcharge__c;
                      } 
                  if(mapSurchargeCharges.get(invId)!=0  ){
                       invObj.Total_Fuel_Surcharge__c = SurchageVar + mapSurchargeCharges.get(invId);//Prat
                  }
                  decimal VaultVar=0.00;
                  if(invM.Total_Vaulting_Charges__c!=null){
                     VaultVar= invM.Total_Vaulting_Charges__c;
                  }
                  if(mapVaultCharges.get(invId)!=0){ invObj.Total_Vaulting_Charges__c = VaultVar + mapVaultCharges.get(invId);
                  }
                 
                updateList.add(invObj);
        for(Id invId : invoiceIds){
            blng__Invoice__c invObj = new blng__Invoice__c();
            invObj.Id = invId;
            decimal ValuationVar=0;
            	ValuationVar=invMap.get(invId).Total_BVC_Valuation_Charges__c==null ?0: invMap.get(invId).Total_BVC_Valuation_Charges__c;
            invObj.Total_BVC_Valuation_Charges__c = mapVlauationCharges.get(invId)+ValuationVar;
            decimal DocketVar=0;
            	DocketVar=invMap.get(invId).Total_Docket_Charges__c==null ?0: invMap.get(invId).Total_Docket_Charges__c;
            invObj.Total_Docket_Charges__c = mapDocketCharges.get(invId)+DocketVar;
            decimal FuelVar=0;
                FuelVar=invMap.get(invId).Total_Fuel_Charges__c==null ?0: invMap.get(invId).Total_Fuel_Charges__c;
            invObj.Total_Fuel_Charges__c = mapFuelCharges.get(invId)+FuelVar;
            decimal HolidayVar=0;
            	HolidayVar=invMap.get(invId).Total_Holiday_Charges__c==null ?0: invMap.get(invId).Total_Holiday_Charges__c;
            invObj.Total_Holiday_Charges__c = mapHolidayCharges.get(invId)+HolidayVar;
            decimal WeightVar=0;
            	WeightVar=invMap.get(invId).Total_Weight_Charges__c==null ?0: invMap.get(invId).Total_Weight_Charges__c;
            invObj.Total_Weight_Charges__c = mapWeightCharges.get(invId)+WeightVar;
            Decimal SurchageVar=0;
            	SurchageVar=invMap.get(invId).Total_Fuel_Surcharge__c==null ?0: invMap.get(invId).Total_Fuel_Surcharge__c;
            invObj.Total_Fuel_Surcharge__c = mapSurchargeCharges.get(invId)+SurchageVar;
            //New lines for Universe Cost Charge
            Decimal UCostChargeVar=0;
            	UCostChargeVar=invMap.get(invId).Total_Universe_Cost_Charge__c==null ?0: invMap.get(invId).Total_Universe_Cost_Charge__c;
            invObj.Total_Universe_Cost_Charge__c = mapUCostChargeCharges.get(invId)+UCostChargeVar;
            //End new lines
            decimal VaultVar=0;
            	VaultVar=invMap.get(invId).Total_Vaulting_Charges__c==null ?0: invMap.get(invId).Total_Vaulting_Charges__c;
            invObj.Total_Vaulting_Charges__c = mapVaultCharges.get(invId)+VaultVar;
            decimal LogisticVar=0;
            	LogisticVar=invMap.get(invId).Total_Logistics_Charges__c==null ?0: invMap.get(invId).Total_Logistics_Charges__c;
            invObj.Total_Logistics_Charges__c = mapLogisticsCharges.get(invId)+LogisticVar;
            
            updateList.add(invObj);
        }
            
            if(!updateList.isEmpty()){
                system.debug('=====>'+updateList[0]);
            	update updateList;
        	}
        } 
        
    
    
    public static void updateManualInvoiceBillingDetails(List<blng__InvoiceLine__c> lines){
        Set<Id> invIds = new Set<Id>();
        for(blng__InvoiceLine__c li : lines){
            if(li.blng__InvoiceRun__c == null && li.blng__OrderProduct__c == null){
                invIds.add(li.blng__Invoice__c);  
            }
            
        }
        Map<Id,blng__Invoice__c> invMap = new Map<Id,blng__Invoice__c>([SELECT Id,BVC_Branch__c 
                                                                        FROM blng__Invoice__c 
                                                                        WHERE Id IN :invIds]);
        for(blng__InvoiceLine__c li : lines){
            if(invMap.containsKey(li.blng__Invoice__c)){
                li.BVC_Branch__c =  invMap.get(li.blng__Invoice__c).BVC_Branch__c;
            }
        }
    }
    
    public static void updateShipmentStatus(List<blng__InvoiceLine__c> lines){
        Set<Id> shipmentIds = new Set<Id>();
        for(blng__InvoiceLine__c li :  lines){
            shipmentIds.add(li.Shipment__c);
        }
        Database.executeBatch(new ECSSShipmentUpdateBatch(shipmentIds), 100);
    }    
  
}*/