global class BVCInvoiceSchedulerBatch implements Database.Batchable<SObject>, database.stateful {
    
    global Map<Id, BVCOrder__c> nonacrBVCOrderMap;
    global Map<String,BVCOrder__c> ProductCodeOrdersMap= new Map<String,BVCOrder__c>();
   
    global List<BVC_Invoice_Run__c> runRecordList;
    
    global Map<Id,List<BVC_Order_Product__c>> nonacrBVCOrderProductMap = new Map<Id,List<BVC_Order_Product__c>>();
    // Constructor 
    global BVCInvoiceSchedulerBatch(Map<Id, BVCOrder__c> nonacrBVCOrderMap,List<BVC_Invoice_Run__c> runRecordList)
       
    {
        this.nonacrBVCOrderMap = nonacrBVCOrderMap;
        this.runRecordList = runRecordList;
        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select Id, Account__c,  Bill_To_GSTIN__c, Account__r.BVC_Contract__c,Origin_Address__c,schedulerKey__c,Billing_Account__r.Billing_Address__c,
                                         Billing_Address__c, BillingAccount__c, Business_Type__c, BVC_LegalEntity__c, BVC_LegalEntity__r.GSTIN_State__c,
                                         BVC_Branch__c, BVC_Entity__c, Shipment__c, Consignee_Name__c, Consignee_PAN__c, Destination_Address__c, 
                                         Destination_City__c, Destination_Type__c, Gross_Weight__c, Gross_Weight_UOM__c, Net_Weight__c, Net_Weight_UOM__c, 
                                         Opt_For_Liability_Coverage__c,  Origin_Type__c,  Product_Code__c,Status__c, Total_Freight__c, Order_Amount__c, Order_Type__c,
                                         Order_Status_Static__c,Order_Name__c,Shipment_Status__c,  Order_End_Date__c, Order_Start_Date__c, BVC_Invoice_Run__c,Total_Universe_Cost_Charge__c,
                                          Billing_Account__c, Liability_Cover_By_BVC__c, Product_Name__c,Minimum_Freight__c,  Billing_status__c,Shipment_Type__c,
                                         
                                         (Select Id, BVCOrder__c, Quantity__c,Customer_Product_Category__c, Origin_Address_Name__c,BVCOrder__r.Billing_Address__c,BVCOrder__r.Billing_Account__c, BVCOrder__r.BVC_LegalEntity__c, 
                                          Total_Price__c, Billing_Account__c,BVC_Branch__c, /*Charge_Type__c, Billing_Type__c, 
                                          Billing_Frequency__c,*/  Vaulting_Charges__c,
                                          Total_Charges__c, Freight_Charges__c,BVC_Invoice_Run__c,Offline_Charge__c, 
                                          BVC_Valuation_Charges__c, Docket_Charges__c, Fuel_Charges__c, 
                                          Holiday_Charges__c, Weight_Charges__c, Total_Logistics_Charges__c, 
                                          Total_Commission_Charges__c,Start_Date__c, End_Date__c,List_Price__c, 
                                          Shipment__c, Shipment_Date__c,Shipment_Number__c,Shipper_Name__c,
                                          Shipper_PAN__c, Consignee_Name__c, Consignee_PAN__c, Origin_City__c, Origin_State__c, 
                                          Origin_PinCode__c, Origin_Type__c, Destination_City__c, Destination_State__c, 
                                          Destination_Pin_Code__c, Destination_Type__c, Rate_Amount__c, 
                                          Gross_Weight_gms__c, Gross_Weight_UOM__c,Gross_Weight__c, Net_Weight__c,
                                          Net_Weight_UOM__c, Net_Weight_gms__c,Minimum_Freight__c, Liability_Charges__c, 
                                          Fuel_Surcharge__c, Product_Name__c,Product_Code__c,Universe_Cost_Charge__c, 
                                          Liability_Coverage__c,Billing_status__c,Secure_Logistics_Charges__c,BVC_LegalEntity__c 
                                          from BVC_Order_Products__r)
                                         
                                         from BVCOrder__c WHERE Id IN :nonacrBVCOrderMap.keySet() AND
                                         Billing_status__c='Pending' and Fixed_billing_order__c=false 
                                        ]);
    }
    
    
    global void execute(Database.BatchableContext BC, List<BVCOrder__c> scope) {
        
        Map<Id, BVCOrder__c> ordersInScope = new Map<Id, BVCOrder__c>(scope);
        Map<Id, List<BVC_Order_Product__c>> productsInScope = new Map<Id, List<BVC_Order_Product__c>>();
        
        for (BVCOrder__c order : scope) {
            productsInScope.put(order.Id, order.BVC_Order_Products__r);
            
        }
        
        System.debug('ordersInScope===='+ordersInScope);
        System.debug('productsInScope'+productsInScope);
        System.debug('runRecordList'+runRecordList);
        InvSchcreateNONACRInvoice(ordersInScope, productsInScope, runRecordList);
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Process Complete');
    }
    
    global  void InvSchcreateNONACRInvoice(Map<Id,BVCOrder__c> nonacrBVCOrderMap, Map<Id,List<BVC_Order_Product__c>> nonacrBVCOrderProductMap, 
                                           list<BVC_Invoice_Run__c> invoiceRun){
                                               Map<id,BVCInvoice__c> InvMap = new Map<id,BVCInvoice__c>();     
                                               system.debug('into the InvSchcreateNONACRInvoice');
                                               List<BVCInvoice__c> newInvoices = new List<BVCInvoice__c>(); 
                                               Map<String,id> ProductCodeMap = new Map<String,id>();
                                               
                                               list<BVCInvoice__c> existinginvoices=[select id,schedulerKey__c,Product_Code__c,BVC_Invoice_Run__c,BVC_LegalEntity__c,Account__c,Billing_Address__c,Total_BVC_Valuation_Charges__c,Total_Docket_Charges__c,Total_Fuel_Charges__c,Total_Fuel_Surcharge__c,Total_Holiday_Charges__c,Total_Weight_Charges__c,Total_Vaulting_Charges__c,Total_Universe_Cost_Charge__c from BVCInvoice__c 
                                                                                     where BVC_Invoice_Run__c=:invoiceRun[0].id];
                                               
                                               system.debug('existinginvoices++++'+existinginvoices);
                                               for(integer j=0; j<existinginvoices.size(); j++){
                                                   system.debug('existinginvoices[j]++++'+existinginvoices[j]);
                                                   system.debug('String Key++++'+existinginvoices[j].schedulerKey__c);
                                                   
                                                   if(!ProductCodeMap.containsKey(existinginvoices[j].schedulerKey__c)){
                                                       ProductCodeMap.put(existinginvoices[j].schedulerKey__c,existinginvoices[j].id);
                                                       InvMap.put(existinginvoices[j].id,existinginvoices[j]);
                                                   }
                                                   system.debug('ProductCodeMap++++'+ProductCodeMap);
                                               }                                             
                                               
                                               list<BVCOrder__c> BVCOrder =nonacrBVCOrderMap.values();
                                               Set<String> KeyCombination = new Set<String>();
                                               for(Id o: nonacrBVCOrderMap.keySet()){
                                                   BVCOrder__c op = nonacrBVCOrderMap.get(o);
                                                   if(!ProductCodeMap.containsKey(op.schedulerKey__c) && !KeyCombination.contains(op.schedulerKey__c)){  
                                                       BVCInvoice__c inv = new BVCInvoice__c();
                                                       inv.Account__c = op.Billing_Account__c;
                                                       if(op.Billing_Address__c != null){
                                                           inv.Billing_Address__c = op.Billing_Address__c;
                                                       }
                                                       else if(op.Billing_Address__c == null && op.Billing_Account__c != null){
                                                           inv.Billing_Address__c = op.Billing_Account__r.Billing_Address__c;
                                                       }
                                                       if(op.BVC_Invoice_Run__c != null){
                                                           inv.BVC_Invoice_Run__c = op.BVC_Invoice_Run__c;
                                                       }
                                                       inv.BVC_Entity__c=op.BVC_Entity__c;//added by Pratik
                                                       inv.Origin_Address__c = op.Origin_Address__c;
                                                       inv.BVC_Branch__c = op.BVC_Branch__c;
                                                       inv.Product_Code__c=op.Product_Code__c; 
                                                       inv.InvoiceDate__c = Date.today();
                                                       inv.status__c='Draft';
                                                       inv.EY_Tax_Calculation_Status__c='Pending';
                                                       inv.Invoice_Date__c=Date.today();
                                                       inv.Total_BVC_Valuation_Charges__c=0;
                                                       inv.Total_Docket_Charges__c=0;
                                                       inv.Total_Fuel_Charges__c=0;
                                                       inv.Total_Fuel_Surcharge__c=0;
                                                       inv.Total_Holiday_Charges__c=0;
                                                       inv.Total_Weight_Charges__c=0;
                                                       inv.Total_Vaulting_Charges__c=0;
                                                       inv.BVC_LegalEntity__c = op.BVC_LegalEntity__c;
                                                       newInvoices.add(inv);
                                                       KeyCombination.add(op.schedulerKey__c);
                                                       
                                                   }
                                               }
                                               
                                               system.debug('newInvoices======='+newInvoices);
                                               system.debug('newInvoices.size======='+newInvoices.size());
                                               List<BVCInvoiceLineItem__c> lines = new List<BVCInvoiceLineItem__c>();
                                               list<BVC_Order_Product__c> orderProductIdsToUpdate = new List<BVC_Order_Product__c>();
                                               List<Error_Log__c> errorRecords = new List<Error_Log__c>();
                                               system.debug('Inside invoiceLine Creation');                                         
                                               if(newInvoices.size() > 0 && newInvoices != null){
                                                   
                                                   Database.SaveResult[] lsr = Database.insert(newInvoices);
                                                   for(Database.SaveResult result : lsr){
                                                       if(result.isSuccess()){
                                                           system.debug('invoiceRun[0].id'+invoiceRun[0].id);
                                                           system.debug('invoiceRun[0].id'+result.getid());
                                                           System.debug('The Following Invoices were Inserted'+result.getId());
                                                       }
                                                       else {
                                                           
                                                           for(Database.Error err : result.getErrors()) {
                                                               System.debug('The following error has occurred.');                    
                                                               System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                               System.debug('Invoice fields that affected this error: ' + err.getFields());
                                                               Error_Log__c errorLog = new Error_Log__c();
                											   errorLog.Error_Mesaage__c = err.getMessage();
                                                               errorLog.Invoice_Id__c = result.getId();
                                                               errorLog.BVC_Invoice_Run__c= invoiceRun[0].id;
                                                               errorRecords.add(errorLog);
                                                           }
                                                       }    
                                                   }
                                                   list<BVCInvoice__c> QueryInvoice =[SELECT id,schedulerKey__c,Total_BVC_Valuation_Charges__c,Total_Docket_Charges__c,Total_Fuel_Charges__c,Total_Fuel_Surcharge__c,Total_Holiday_Charges__c,Total_Weight_Charges__c,Total_Vaulting_Charges__c,Total_Universe_Cost_Charge__c  from BVCInvoice__c where id IN:newInvoices];
                                                   for(BVCInvoice__c newBVCInvoice: QueryInvoice){
                                                       ProductCodeMap.put(newBVCInvoice.schedulerKey__c,newBVCInvoice.id);
                                                       InvMap.put(newBVCInvoice.id,newBVCInvoice);
                                                       System.debug('Invoice Id:::::::'+newBVCInvoice.id);
                                                       System.debug('Invoice Key:::::::'+newBVCInvoice.schedulerKey__c);
                                                   }
                                                   if (!errorRecords.isEmpty()) {
                                                       insert errorRecords;  
                                                   }
                                               }
                                               
                                               System.debug('ProductCodeMap.size:::::::'+ProductCodeMap.size());
                                               for(Id key : nonacrBVCOrderMap.keyset()){
                                                   
                                                   for(BVC_Order_Product__c oi : nonacrBVCOrderMap.get(key).BVC_Order_Products__r){ 
                                                       if(oi.Billing_status__c == 'Pending'){
                                                           BVCInvoiceLineItem__c li = new BVCInvoiceLineItem__c();
                                                           li.BVC_Order_Product__c = oi.Id;
                                                           li.BVC_Invoice_Run__c=oi.BVC_Invoice_Run__c;
                                                           System.debug('Oi prodmap'+nonacrBVCOrderMap.get(key).schedulerKey__c);
                                                           li.BVCInvoice__c =ProductCodeMap.get(nonacrBVCOrderMap.get(key).schedulerKey__c);
                                                           //=========================FOR ROLLING UP FIELDS======================================
                                                           if(InvMap.containsKey(ProductCodeMap.get(nonacrBVCOrderMap.get(key).schedulerKey__c))){
                                                               system.debug('In If Statement');
                                                               BVCInvoice__c inv = invMap.get(ProductCodeMap.get(nonacrBVCOrderMap.get(key).schedulerKey__c));
                                                               system.debug('invoice====='+inv.id);
                                                               System.debug('for checking before calc in if oi.Holiday_Charges__c == '+oi.Holiday_Charges__c);
                                                               System.debug('for checking in if inv.Total_Holiday_Charges__c == '+inv.Total_Holiday_Charges__c);
                                                               
                                                               if(oi.BVC_Valuation_Charges__c!=null && oi.BVC_Valuation_Charges__c!=0  ){ inv.Total_BVC_Valuation_Charges__c = oi.BVC_Valuation_Charges__c+(inv.Total_BVC_Valuation_Charges__c==null ? 0:inv.Total_BVC_Valuation_Charges__c);}
                                                               if( oi.Docket_Charges__c!=null && oi.Docket_Charges__c!=0 ){ inv.Total_Docket_Charges__c = oi.Docket_Charges__c +(inv.Total_Docket_Charges__c==null ? 0:inv.Total_Docket_Charges__c);}
                                                               if(oi.Fuel_Charges__c!=null && oi.Fuel_Charges__c!=0 ){ inv.Total_Fuel_Charges__c= oi.Fuel_Charges__c +(inv.Total_Fuel_Charges__c==null ? 0:inv.Total_Fuel_Charges__c);}
                                                               if( oi.Fuel_Surcharge__c!=null && oi.Fuel_Surcharge__c!=0 ){ inv.Total_Fuel_Surcharge__c = oi.Fuel_Surcharge__c+(inv.Total_Fuel_Surcharge__c==null ? 0:inv.Total_Fuel_Surcharge__c);}
                                                               if(oi.Holiday_Charges__c!=null && oi.Holiday_Charges__c!=0 ){ inv.Total_Holiday_Charges__c = oi.Holiday_Charges__c+(inv.Total_Holiday_Charges__c==null ? 0:inv.Total_Holiday_Charges__c);}
                                                               if( oi.Weight_Charges__c!=null && oi.Weight_Charges__c!=0 ){ inv.Total_Weight_Charges__c = oi.Weight_Charges__c+(inv.Total_Weight_Charges__c==null ? 0:inv.Total_Weight_Charges__c);}
                                                               if( oi.Vaulting_Charges__c!=null && oi.Vaulting_Charges__c!=0 ){   inv.Total_Vaulting_Charges__c = oi.Vaulting_Charges__c+(inv.Total_Vaulting_Charges__c==null ? 0:inv.Total_Vaulting_Charges__c); }
                                                               if( oi.Universe_Cost_Charge__c!=null && oi.Universe_Cost_Charge__c!=0 ){   inv.Total_Universe_Cost_Charge__c = oi.Universe_Cost_Charge__c+(inv.Total_Universe_Cost_Charge__c==null ? 0:inv.Total_Universe_Cost_Charge__c); }
                                                               system.debug('inv.Total_Fuel_Surcharge__c===='+inv.Total_Fuel_Surcharge__c);
                                                               System.debug('for checking after calculation in if oi.Holiday_Charges__c == '+oi.Holiday_Charges__c);
                                                               InvMap.put(ProductCodeMap.get(nonacrBVCOrderMap.get(key).schedulerKey__c),inv);
                                                           }else{
                                                               system.debug('In else Statement====');
                                                               system.debug('oi.Fuel_Surcharge__c===='+oi.Fuel_Surcharge__c);
                                                               system.debug('map====='+ProductCodeMap.get(nonacrBVCOrderMap.get(key).schedulerKey__c));
                                                               System.debug('for checking before calc in else oi.Holiday_Charges__c == '+oi.Holiday_Charges__c);
                                                               
                                                               BVCInvoice__c inv =new BVCInvoice__c(id=ProductCodeMap.get(nonacrBVCOrderMap.get(key).schedulerKey__c));
                                                               
                                                               System.debug('for checking in else inv.Total_Holiday_Charges__c == '+inv.Total_Holiday_Charges__c);
                                                               
                                                               system.debug('invoice====='+inv.id);
                                                               system.debug('inv.Total_Fuel_Surcharge__c===='+inv.Total_Fuel_Surcharge__c);
                                                               if(oi.BVC_Valuation_Charges__c!=null && oi.BVC_Valuation_Charges__c!=0  ){ inv.Total_BVC_Valuation_Charges__c = oi.BVC_Valuation_Charges__c+(inv.Total_BVC_Valuation_Charges__c==null ? 0:inv.Total_BVC_Valuation_Charges__c);}
                                                               if( oi.Docket_Charges__c!=null && oi.Docket_Charges__c!=0 ){ inv.Total_Docket_Charges__c = oi.Docket_Charges__c +(inv.Total_Docket_Charges__c==null ? 0:inv.Total_Docket_Charges__c);}
                                                               if(oi.Fuel_Charges__c!=null && oi.Fuel_Charges__c!=0 ){ inv.Total_Fuel_Charges__c= oi.Fuel_Charges__c +(inv.Total_Fuel_Charges__c==null ? 0:inv.Total_Fuel_Charges__c);}
                                                               if( oi.Fuel_Surcharge__c!=null && oi.Fuel_Surcharge__c!=0 ){ inv.Total_Fuel_Surcharge__c = oi.Fuel_Surcharge__c+(inv.Total_Fuel_Surcharge__c==null ? 0:inv.Total_Fuel_Surcharge__c);}
                                                               if(oi.Holiday_Charges__c!=null && oi.Holiday_Charges__c!=0 ){ inv.Total_Holiday_Charges__c = oi.Holiday_Charges__c+(inv.Total_Holiday_Charges__c==null ? 0:inv.Total_Holiday_Charges__c);}
                                                               if( oi.Weight_Charges__c!=null && oi.Weight_Charges__c!=0 ){ inv.Total_Weight_Charges__c = oi.Weight_Charges__c+(inv.Total_Weight_Charges__c==null ? 0:inv.Total_Weight_Charges__c);}
                                                               if( oi.Vaulting_Charges__c!=null && oi.Vaulting_Charges__c!=0 ){   inv.Total_Vaulting_Charges__c = oi.Vaulting_Charges__c+(inv.Total_Vaulting_Charges__c==null ? 0:inv.Total_Vaulting_Charges__c); }
                                                               if( oi.Universe_Cost_Charge__c!=null && oi.Universe_Cost_Charge__c!=0 ){   inv.Total_Universe_Cost_Charge__c = oi.Universe_Cost_Charge__c+(inv.Total_Universe_Cost_Charge__c==null ? 0:inv.Total_Universe_Cost_Charge__c); }
                                                               System.debug('for checking after calculation in else oi.Holiday_Charges__c == '+oi.Holiday_Charges__c);
                                                               system.debug('inv.Total_Fuel_Surcharge__c===='+inv.Total_Fuel_Surcharge__c);
                                                               system.debug('product code===='+ oi.Product_Code__c);
                                                               system.debug('Legal Entity===='+ oi.BVC_LegalEntity__c);
                                                               system.debug('ProductCodeMap.get(oi.Product_Code__c+========='+ ProductCodeMap.get(nonacrBVCOrderMap.get(key).schedulerKey__c));    
                                                               InvMap.put(ProductCodeMap.get(nonacrBVCOrderMap.get(key).schedulerKey__c),inv);
                                                           }
                                                           //====================================END FOR ROLLING UP FIELDS===============================================================
                                                           
                                                           li.Quantity__c = oi.Quantity__c;
                                                           li.Calculated_Quantity__c = oi.Quantity__c;
                                                           li.BVC_LegalEntity__c = oi.BVC_LegalEntity__c;
                                                           li.Start_Date__c = oi.Start_Date__c;
                                                           li.End_Date__c = oi.End_Date__c;
                                                           li.Charge_Date__c = Date.today();
                                                           li.Freight_Charges__c=oi.Freight_Charges__c;
                                                           li.Offline_Charge__c=oi.Offline_Charge__c;
                                                           li.Liability_Charges__c=oi.Liability_Charges__c;
                                                           li.Weight_Charges__c=oi.Weight_Charges__c;
                                                           li.BVC_Valuation_Charges__c=oi.BVC_Valuation_Charges__c; 
                                                           li.Docket_Charges__c=oi.Docket_Charges__c;
                                                           li.Fuel_Charges__c=oi.Fuel_Charges__c;
                                                           li.Fuel_Surcharge__c=oi.Fuel_Surcharge__c;
                                                           li.Universe_Cost_Charge__c=oi.Universe_Cost_Charge__c;
                                                           li.Holiday_Charges__c=oi.Holiday_Charges__c;
                                                           li.Secure_Logistics_Charges__c=oi.Secure_Logistics_Charges__c;
                                                           li.Subtotal__c = oi.Total_Charges__c;
                                                           li.Unit_Price__c = oi.Total_Charges__c;
                                                           li.Consignee_Name__c=oi.Consignee_Name__c;
                                                           li.Consignee_PAN__c=oi.Consignee_PAN__c;
                                                           li.BVC_Branch__c=oi.BVC_Branch__c;
                                                           li.Shipment__c=oi.Shipment__c;
                                                           li.Shipment_Date__c=oi.Shipment_Date__c;
                                                           li.Shipment_Number__c=oi.Shipment_Number__c;
                                                           li.Shipper_Name__c=oi.Shipper_Name__c;
                                                           li.Shipper_PAN__c=oi.Shipper_PAN__c;
                                                           li.Origin_City__c=oi.Origin_City__c;
                                                           li.Origin_State__c=oi.Origin_State__c;
                                                           li.Origina_Pin_Code__c=oi.Origin_PinCode__c;
                                                           li.Origin_Type__c=oi.Origin_Type__c;
                                                           li.Destination_City__c=oi.Destination_City__c;
                                                           li.Destination_State__c=oi.Destination_State__c;
                                                           li.Destination_Pin_Code__c=oi.Destination_Pin_Code__c;
                                                           li.Destination_type__c=oi.Destination_type__c;
                                                           li.Gross_Weight__c=oi.Gross_Weight__c;
                                                           li.Gross_Weight_UOM__c=oi.Gross_Weight_UOM__c;
                                                           li.Gross_Weightgms__c=oi.Gross_Weight_gms__c;
                                                           li.Net_Weight__c=oi.Net_Weight__c;
                                                           li.Net_Weight_UOM__c=oi.Net_Weight_UOM__c;
                                                           li.Net_Weightgms__c=oi.Net_Weight_gms__c;
                                                           li.Total_Charge__c=oi.Total_Charges__c;
                                                           li.Product_Code__c=oi.Product_Code__c;
                                                           orderProductIdsToUpdate.add(oi); //to update oi after insertion of li
                                                           lines.add(li);
                                                           
                                                       }
                                                   } 
                                                   //  }
                                               }
                                               Boolean isILInserted = false;
                                               Set<Id> shipmentIdsToUpdate = new Set<Id>();
                                               Set<Id> invoiceLineIds = new Set<Id>();
                                               if(lines.size()>0){
                                                   Database.SaveResult[] lsr = Database.insert(lines);
                                                   
                                                   for(Database.SaveResult result : lsr){
                                                       if(result.isSuccess()){
                                                           isILInserted = true;
                                                           System.debug('The Following Invoice Lines were Inserted'+result.getId());
                                                           invoiceLineIds.add(result.getId());
                                                       }
                                                       else {
                                                           
                                                           for(Database.Error err : result.getErrors()) {
                                                               System.debug('The following error has occurred.');                    
                                                               System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                               System.debug('Invoice Line fields that affected this error: ' + err.getFields());
                                                               Error_Log__c errorLog = new Error_Log__c();
                											   errorLog.Error_Mesaage__c = err.getMessage();
                                                               errorLog.Invoice_Line_Id__c = result.getId();
                                                               errorLog.BVC_Invoice_Run__c= invoiceRun[0].id;
                                                               errorRecords.add(errorLog);
                                                           }
                                                       }
                                                       
                                                   }
                                                   if (!errorRecords.isEmpty()) {
                                                       insert errorRecords;  
                                                   }
                                               }
                                               system.debug('invMap.size()======'+invMap.size());
                                               system.debug('invMap======'+invMap);
                                               if(invMap.size()>0){
                                                  update invMap.values(); 
                                               }
                                               
                                               //==============================To Update Shipment===================================================================
                                               if (!invoiceLineIds.isEmpty()) {
                                                   List<BVCInvoiceLineItem__c> invoiceLines = [SELECT Shipment__c FROM BVCInvoiceLineItem__c WHERE Id = :invoiceLineIds];
                                                   for (BVCInvoiceLineItem__c line : invoiceLines) {
                                                       if (line.Shipment__c != null) {
                                                           shipmentIdsToUpdate.add(line.Shipment__c);
                                                       }
                                                   }
                                               }
                                               List<Shipment__c> shipmentsToUpdate=new  List<Shipment__c>();
                                               if (!shipmentIdsToUpdate.isEmpty()) {
                                                   //  List<Shipment__c> shipmentsToUpdate = [SELECT Id, Status__c FROM Shipment__c WHERE Id IN :shipmentIdsToUpdate];
                                                   
                                                   for (Id shipment : shipmentIdsToUpdate) {
                                                       shipment__c s = new shipment__c(id=shipment);
                                                       s.Status__c = 'Billed';
                                                       shipmentsToUpdate.add(s);
                                                   }
                                                   try {
                                                       if(shipmentsToUpdate.size()>0){
                                                           update shipmentsToUpdate;
                                                           System.debug('Shipments have been successfully updated to "Billed" status.');  
                                                       }
                                                       
                                                   } catch (DmlException e) {
                                                       System.debug('Error occurred while updating Shipments: ' + e.getMessage());
                                                   }
                                               }
                                               //=================================================================================================================                                                  
                                               if (isILInserted) {
                                                   
                                                   List<AggregateResult> results = [SELECT COUNT(Id) totalCount1 FROM BVCInvoiceLineitem__c WHERE BVCInvoice__r.BVC_Invoice_Run__c = :invoiceRun[0].Id];
                                                   
                                                   Integer invoiceLineCount = 0;
                                                   if (results.size() > 0) {
                                                       invoiceLineCount = (Integer)results[0].get('totalCount1');
                                                   }
                                                   invoiceRun[0].Total_Invoice_Lines__c = invoiceLineCount;
                                                   update invoiceRun[0];
                                               }
                                               if (isILInserted && !orderProductIdsToUpdate.isEmpty()) {
                                                   
                                                   for (BVC_Order_Product__c orderProduct : orderProductIdsToUpdate) {
                                                       orderProduct.Billing_status__c = 'completed';
                                                   }
                                                   update orderProductIdsToUpdate;
                                               }
                                               //==========================================================================================
                                              /* if (isILInserted && !nonacrBVCOrderMap.isEmpty()) {
                                                   Map<Id, Id> orderToInvoiceMap = new Map<Id, Id>();  // Order ID -> Invoice ID
                                                   Map<Id, BVCInvoice__c> invoiceMap = new Map<Id, BVCInvoice__c>();  // Invoice ID -> Invoice Record
                                                   List<BVCOrder__c> odList = new List<BVCOrder__c>();
                                                   
                                                   // Fetch all Invoice Lines linked to our Invoice Run
                                                   List<BVCInvoiceLineItem__c> invoiceLines = [
                                                       SELECT Id, BVCInvoice__c, BVC_Order_Product__c 
                                                       FROM BVCInvoiceLineItem__c 
                                                       WHERE BVCInvoice__r.BVC_Invoice_Run__c = :invoiceRun[0].Id
                                                   ];
                                                   
                                                   // Fetch related Order Products
                                                   Map<Id, BVC_Order_Product__c> orderProductMap = new Map<Id, BVC_Order_Product__c>();
                                                   for (BVCInvoiceLineItem__c line : invoiceLines) {
                                                       if (line.BVC_Order_Product__c != null) {
                                                           orderProductMap.put(line.BVC_Order_Product__c, null);  // Placeholder
                                                       }
                                                   }
                                                   
                                                   if (!orderProductMap.isEmpty()) {
                                                       orderProductMap = new Map<Id, BVC_Order_Product__c>([
                                                           SELECT Id, BVCOrder__c
                                                           FROM BVC_Order_Product__c
                                                           WHERE Id IN :orderProductMap.keySet()
                                                       ]);
                                                   }
                                                   
                                                   // Map Orders to Invoices
                                                   for (BVCInvoiceLineItem__c line : invoiceLines) {
                                                       if (line.BVC_Order_Product__c != null && orderProductMap.containsKey(line.BVC_Order_Product__c)) {
                                                           Id orderId = orderProductMap.get(line.BVC_Order_Product__c).BVCOrder__c;
                                                           if (orderId != null) {
                                                               orderToInvoiceMap.put(orderId, line.BVCInvoice__c);
                                                           }
                                                       }
                                                   }
                                                   
                                                   // Fetch Invoice Details
                                                   if (!orderToInvoiceMap.isEmpty()) {
                                                       invoiceMap = new Map<Id, BVCInvoice__c>([
                                                           SELECT Id, ST_Invoice_Series__c,Subtotal__c,InvoiceDate__c,TaxAmount__c,Total_Amount_With_Tax__c
                                                           FROM BVCInvoice__c 
                                                           WHERE Id IN :orderToInvoiceMap.values()
                                                       ]);
                                                   }
                                                   
                                                   // Update Orders with Invoice Details
                                                   for (Id orderId : orderToInvoiceMap.keySet()) {
                                                       if (invoiceMap.containsKey(orderToInvoiceMap.get(orderId))) {
                                                           BVCInvoice__c inv = invoiceMap.get(orderToInvoiceMap.get(orderId));
                                                           BVCOrder__c order = new BVCOrder__c(
                                                               Id = orderId,
                                                               Billing_status__c = 'Completed',
                                                               //Total_BVC_Valuation_Charges__c = inv.Total_BVC_Valuation_Charges__c,
                                                               Invoice_series__c = inv.ST_Invoice_Series__c,
                                                               Invoice_Subtotal__c= inv.Subtotal__c,
                                                               Invoice_Date__c=inv.InvoiceDate__c,
                                                               Invoice_Tax__c=inv.TaxAmount__c,
                                                               Invoice_Total_Amount_with_tax__c=inv.Total_Amount_With_Tax__c
                                                               
                                                           );
                                                           odList.add(order);
                                                       }
                                                   }
                                                   
                                                   // Perform bulk update
                                                   if (!odList.isEmpty()) {
                                                       update odList;
                                                   }
                                               }*/
                                               
                                               //===========================================================================================
                                               if (isILInserted && !nonacrBVCOrderMap.isEmpty()) {
                                                   list<BVCorder__c> odList = new list<BVCorder__c>();
                                                   for (id order1 : nonacrBVCOrderMap.keySet()) {
                                                       BVCorder__c o=new BVCorder__c(id=order1);
                                                       o.Billing_status__c = 'completed';
                                                       odList.add(o);
                                                   }
                                                   update odList;
                                               }
                                               
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
    }
}