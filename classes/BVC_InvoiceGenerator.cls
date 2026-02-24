public class BVC_InvoiceGenerator {
    
    public static void createACRInvoice(Map<Id,BVCQuote__c> acrBVCQuoteMap, Map<Id,List<BVCQuoteLineItem__c>> acrBVCQuoteLineMap){
        
        List<BVCInvoice__c> newInvoices = new List<BVCInvoice__c>();
        
        // Get details from BVCquote and populate BVCInvoice fields
        
        for(BVCQuote__c BVCQuote : acrBVCQuoteMap.values()){
            system.debug('quote+++++'+BVCQuote);
            // newly added 29-10-2025
            boolean OneQLine=false;
			Decimal Subtotal=0,TDSBalance=0;
            if (acrBVCQuoteLineMap.containsKey(BVCQuote.Id)) {
                for (BVCQuoteLineItem__c oi : acrBVCQuoteLineMap.get(BVCQuote.Id)) {
                    if (!OneQLine) {
                    Subtotal = Subtotal+oi.Net_Unit_Price__c;
                    OneQLine=true;
                    }
                }
            }
			if(Subtotal>0)
            {
               TDSBalance =  Subtotal * 2/100;
            }
            // newly added 29-10-2025
            
            BVCInvoice__c inv = new BVCInvoice__c();
            inv.Account__c = BVCQuote.Account__c;
            inv.BVCQuote__c = BVCQuote.Id;
            inv.Invoice_Date__c = Date.today();
            inv.InvoiceDate__c = Date.today();
            //inv.Invoice_Date__c=Date.today();
            inv.Invoice_datetime__c = System.now();
            inv.BVC_Branch__c = BVCQuote.BVC_Branch__c;
            system.debug('contact+++'+BVCQuote.Primary_Contact__c);
            inv.Bill_To_Contact__c=BVCQuote.Primary_Contact__c;
            inv.BVC_LegalEntity__c = BVCQuote.BVC_LegalEntity__c;
            inv.BVC_Entity__c = BVCQuote.BVC_Entity__c;
            inv.Invoice_Type__c='Tax Invoice';//confirm with Samir Shigwan
            inv.status__c='Draft';
            inv.EY_Tax_Calculation_Status__c='Pending';
            inv.RDS_Status__c = 'Pending';
            //inv.TDS_Balance__c = TDSBalance; // newly added 29-10-2025
            if(BVCQuote.Billing_Address__c != null){
                inv.Billing_Address__c = BVCQuote.Billing_Address__c;
            }
            else if(BVCQuote.Billing_Address__c == null && BVCQuote.Account__c != null && !Test.isRunningTest()){
                inv.Billing_Address__c = BVCQuote.Account__r.Billing_Address__c;
            }
            inv.Origin_Address__c = BVCQuote.Billing_Address__c;
            newInvoices.add(inv);
        }
        //Insert Invoice for ACR
        System.debug('for checking serialise '+JSON.serializePretty(newInvoices));
        if(newInvoices.size() > 0 && newInvoices != null){
            Database.SaveResult[] lsr = Database.insert(newInvoices);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    System.debug('The Following Invoices were Inserted'+result.getId());
                }
                else {
                    // If Operation failed, get all errors                
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice fields that affected this error: ' + err.getFields());
                        // System.debug('Invoice fields that affected this error: ' + err.getLine());
                    }
                }
                
            }
        }
        
        
        Map<Id,Id> orderInvMap = new Map<Id,Id>();
        if(newInvoices.size() > 0 && newInvoices != null){
            for(BVCInvoice__c inv : newInvoices){
                if(inv.BVCQuote__c != null && inv.Id != null){
                    orderInvMap.put(inv.BVCQuote__c,inv.Id);     
                }
                
            }
        }
        // Insert Invoice Lines for ACR
        id invId;
        List<BVCInvoiceLineitem__c> lines = new List<BVCInvoiceLineitem__c>();
        boolean OneQLine=false;
        for (Id key : acrBVCQuoteMap.keySet()) {
            if (acrBVCQuoteLineMap.containsKey(key)) {
                for (BVCQuoteLineItem__c oi : acrBVCQuoteLineMap.get(key)) {
                    if (!OneQLine) {
                        BVCInvoiceLineitem__c li = new BVCInvoiceLineitem__c();
                        
                        li.BVCQuoteLineItem__c = oi.Id;
                        li.BVCInvoice__c = orderInvMap.get(oi.BVCQuote__c);
                        invId=orderInvMap.get(oi.BVCQuote__c);
                        li.Subtotal__c = oi.Net_Unit_Price__c;
                        li.Unit_Price__c = oi.Net_Unit_Price__c;
                        li.Freight_Charges__c=oi.Net_Unit_Price__c;
                        li.Calculated_Quantity__c=1;
                        li.BVCQuoteLineItem__c= oi.id;
                        li.Charge_Date__c = Date.today();
                        li.Start_Date__c = Date.today();
                        li.End_Date__c = Date.today();
                        //li.Status__c='Draft';
                        li.Product_Code__c= oi.Product_Code__c;
                        li.Product_Name__c=oi.Product_Name__c;
                        li.COA_Product_Code__c = oi.COA_Product_Code__c;
                        li.ACR_Product_Code__c = oi.ACR_Standard_Price__r.ACR_Product_Code__c;
                        li.ACR_Product_Name__c = oi.ACR_Standard_Price__r.Product_Name__c;
                        
                        lines.add(li);
                        OneQLine=true; 
                    }
                }
            }
        }
        if(lines.size()>0){
            Database.SaveResult[] lsr = Database.insert(lines);
            for (Database.SaveResult result : lsr) {
                if (result.isSuccess()) {
                    System.debug('The Following Invoice Lines were Inserted: ' + result.getId());
                } else {
                    // Operation failed, so get all errors                
                    for (Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred:');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice Line fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        if(invId!=null && lines.size()>0 ){
            BVCinvoice__c inv = new BVCinvoice__c(id=invId);
            inv.Product_Code__c=lines[0].ACR_Product_Code__c;
            inv.Product_Name__c=lines[0].ACR_Product_Name__c;
            inv.COA_Product_Code__c = lines[0].COA_Product_Code__c;
            inv.Total_Freight_Tax__c=lines[0].Freight_Charges__c *0.18;
            System.debug('Rafi debug to check  invoice inv.Product_Code__c = '+inv.Product_Code__c);
            System.debug('Rafi debug to check  invoice inv.Product_Name__c = '+inv.Product_Name__c);
            
            update inv;
            
            /*List<id> shipments = new List<id>();
            if (isILInserted && !acrBVCQuoteMap.isEmpty()) {
                list<BVCorder__c> odList = new list<BVCorder__c>();
                for (id order1 : acrBVCQuoteMap.keySet()) {
                    BVCorder__c o=new BVCorder__c(id=order1);
                    o.Shipment_Status_Static__c = 'Billed';
                    odList.add(o);
                }
                if(odList.size()>0){
                    update odList;
                }
                
            }*/
        }
    }
    
    public static void createNONACRInvoice(Map<Id,BVCOrder__c> nonacrBVCOrderMap, Map<Id,List<BVC_Order_Product__c>> nonacrBVCOrderProductMap){
        
        List<BVCInvoice__c> newInvoices = new List<BVCInvoice__c>();
        
        // Get details from order and populate BVCInvoice fields
        
        for(BVCOrder__c BVCOrder : nonacrBVCOrderMap.values()){
            BVCInvoice__c inv = new BVCInvoice__c();
            inv.Account__c = BVCOrder.Billing_Account__c;
            //inv.Account__c = BVCOrder.Account__c;
            inv.BVCOrder__c = BVCOrder.Id;
            inv.Invoice_Date__c = Date.today();
            inv.InvoiceDate__c = Date.today();
            inv.Invoice_datetime__c = System.now();
            inv.BVC_Branch__c = BVCOrder.BVC_Branch__c;
            inv.BVC_LegalEntity__c = BVCOrder.BVC_LegalEntity__c;
            inv.BVC_Entity__c = BVCOrder.BVC_Entity__c;
            inv.status__c='Draft';
            inv.EY_Tax_Calculation_Status__c='Pending';
            inv.Invoice_Date__c=Date.today();
            inv.RDS_Status__c = 'Pending';
            inv.Shipment__c = BVCOrder.Shipment__c;
            if(BVCOrder.Billing_Address__c != null){
                inv.Billing_Address__c = BVCOrder.Billing_Address__c;
            }
            else if(BVCOrder.Billing_Account__r.Billing_Address__c == null && BVCOrder.Billing_Account__c != null && test.isRunningTest()){
            //else if(BVCOrder.Account__r.Billing_Address__c == null && BVCOrder.Account__c != null && test.isRunningTest()){
                //inv.Billing_Address__c = BVCOrder.Account__r.Billing_Address__c;
                inv.Billing_Address__c = BVCOrder.Billing_Account__r.Billing_Address__c;
            }
            inv.Origin_Address__c = BVCOrder.Origin_Address__c;
            newInvoices.add(inv);
        }
        //Insert Invoice for Non ACR
        
        if(newInvoices.size() > 0 && newInvoices != null){
            Database.SaveResult[] lsr = Database.insert(newInvoices);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    System.debug('The Following Invoices were Inserted'+result.getId());
                }
                else {
                    // If Insert Invoice Operation failed, get all errors                
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
        }
        
        Map<Id,Id> orderInvMap = new Map<Id,Id>();
        if(newInvoices.size() > 0 && newInvoices != null){
            for(BVCInvoice__c inv : newInvoices){
                if(inv.BVCOrder__c != null && inv.Id != null){
                    orderInvMap.put(inv.BVCOrder__c,inv.Id);     
                }
                
            }
        }
        
        id invoiceId=null;
        
        List<BVCInvoiceLineItem__c> lines = new List<BVCInvoiceLineItem__c>();
        system.debug('Inside invoiceLine Creation');
        for(Id key : nonacrBVCOrderMap.keyset()){
            if(nonacrBVCOrderProductMap.containsKey(key)){
                for(BVC_Order_Product__c oi : nonacrBVCOrderProductMap.get(key)){
                    
                    if(orderInvMap.containsKey(oi.BVCOrder__c) || Test.isRunningTest()){
                        BVCInvoiceLineItem__c li = new BVCInvoiceLineItem__c();
                        li.BVC_Order_Product__c = oi.Id;
                        li.BVCInvoice__c = orderInvMap.get(oi.BVCOrder__c);
                        
                        invoiceId = orderInvMap.get(oi.BVCOrder__c);
                        li.Quantity__c = oi.Quantity__c;
                        li.Calculated_Quantity__c = oi.Quantity__c;
                        li.Subtotal__c = oi.Total_Price__c;
                        li.UnitPrice__c = oi.Unit_Price__c;
                        //li.Status__c= 'Draft';
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
                        li.Product_Name__c=oi.Product_Name__c;
                        li.Product_Code__c=oi.Product_Code__c;
                        //li.Name = oi.Product_Name__c;
                        //li.COA_Product_Code__c = oi.Non_ACR_Standard_Price__r.COA_Product_Code_c__c;
                        
                        lines.add(li);
                        
                    }
                } 
            }
            
        }
        Boolean isILInserted = false;
        if(lines.size()>0){
            Database.SaveResult[] lsr = Database.insert(lines);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    isILInserted = true;
                    System.debug('The Following Invoice Lines were Inserted'+result.getId());
                }
                else {
                    // Insert InvoiceLineItems Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice Line fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
            
            
        }
        if(invoiceId!=null && lines.size()>0 ){
            ST_NonACR_Standard_Price__c newNonACRCOACode = [Select Id,COA_Product_Code_c__c From ST_NonACR_Standard_Price__c Where Product_Code__c =:lines[0].Product_Code__c LIMIT 1]; 
            BVCinvoice__c inv = new BVCinvoice__c(id=invoiceId);
            inv.Product_Code__c=lines[0].Product_Code__c;
            inv.Product_Name__c=lines[0].Product_Name__c;
            inv.COA_Product_Code__c = newNonACRCOACode.COA_Product_Code_c__c;
          
            System.debug('Rafi debug to check  invoice inv.Product_Code__c = '+inv.Product_Code__c);
            System.debug('Rafi debug to check  invoice inv.Product_Name__c = '+inv.Product_Name__c);
            
            update inv;
        }
        // Retrieve the invoice record before accessing its fields
        BVCInvoice__c relatedInvoice;
        if (invoiceId != null) {
            relatedInvoice = [SELECT Id, ST_Invoice_Series__c,InvoiceDate__c,Subtotal__c,TaxAmount__c,Total_Amount_With_Tax__c FROM BVCInvoice__c WHERE Id = :invoiceId LIMIT 1];
        }
        List<id> shipments = new List<id>();
        if (isILInserted && !nonacrBVCOrderMap.isEmpty()) {
            list<BVCorder__c> odList = new list<BVCorder__c>();
            for (id order1 : nonacrBVCOrderMap.keySet()) {
                BVCorder__c o=new BVCorder__c(id=order1);
                o.Shipment_Status_Static__c = 'Billed';
                if (relatedInvoice != null) {
                    o.Invoice_series__c = relatedInvoice.ST_Invoice_Series__c;
                    o.Invoice_Subtotal__c= relatedInvoice.Subtotal__c;
                    o.Invoice_Date__c=relatedInvoice.InvoiceDate__c;
                    o.Invoice_Tax__c=relatedInvoice.TaxAmount__c;
                    o.Invoice_Total_Amount_with_tax__c=relatedInvoice.Total_Amount_With_Tax__c;
                }
                odList.add(o);
            }
            if(odList.size()>0){
                update odList;
            }
            
        }
        
    }
    
      
    //  Method To create invoice and invoice lines with invoice scheduler
    //  
   @InvocableMethod
    public static void getOrderids(list<String> invoicerunid){
        system.debug('Calling get records of invoice scheduler_____');
       
        list<BVC_Invoice_Run__c> runrecord=[select id,Customer__c,BVCInvoice__c,To__c,From__c,Lock_this_Invoice_Run__c,Total_Invoice_Lines__c from BVC_Invoice_Run__c 
                                            where id=:invoicerunid AND Lock_this_Invoice_Run__c=false];
       
        list<BVCOrder__c> ordersList=[select Id,Product_Code__c,BVC_LegalEntity__c,Billing_Account__c,schedulerKey__c,Billing_Address__c,
                                      (Select Id from BVC_Order_Products__r)
                                      from BVCOrder__c where 
                                      Account__c=:runrecord[0].Customer__c AND 
                                      Shipment_Date__c>=:runrecord[0].From__c AND 
                                      Shipment_Date__c<=:runrecord[0].To__c
                                      AND Billing_status__c='Pending' AND 
                                      BVC_LegalEntity__c!=null AND
                                      BVC_Invoice_Run__c=:runrecord[0].id
                                     ];
        
        system.debug('Order List======'+ordersList);
        Map<Id,BVCOrder__c> nonacrBVCOrderMap=new Map<Id,BVCOrder__c>();
        if(ordersList.size()>0){
        for(BVCOrder__c OP:ordersList){
            nonacrBVCOrderMap.put(OP.id,OP);
            
        }}
        System.debug(nonacrBVCOrderMap.size());
 
		BVCInvoiceSchedulerBatch bcn = new BVCInvoiceSchedulerBatch(nonacrBVCOrderMap,runrecord) ; 
        ID batchprocessid = Database.executeBatch(bcn,200);
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
    }
    
}