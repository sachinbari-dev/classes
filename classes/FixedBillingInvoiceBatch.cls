global class FixedBillingInvoiceBatch implements Database.Batchable<SObject>, Database.Stateful {
	
   global Map<Id, BVCOrder__c> nonacrBVCOrderMap;
    global Map<String,BVCOrder__c> ProductCodeOrdersMap= new Map<String,BVCOrder__c>();
   
    global List<BVC_Invoice_Run__c> runRecordList;
    
    global Map<Id,List<BVC_Order_Product__c>> nonacrBVCOrderProductMap = new Map<Id,List<BVC_Order_Product__c>>();
    // Constructor 
    global FixedBillingInvoiceBatch(Map<Id, BVCOrder__c> nonacrBVCOrderMap,List<BVC_Invoice_Run__c> runRecordList)
       
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
                                          Total_Price__c, Billing_Account__c,BVC_Branch__c, /*Charge_Type__c,Billing_Type__c, 
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
                                          Liability_Coverage__c,Billing_status__c,Secure_Logistics_Charges__c 
                                          from BVC_Order_Products__r)
                                         
                                         from BVCOrder__c WHERE Id IN :nonacrBVCOrderMap.keySet() AND
                                         Billing_status__c='Pending'  AND fixed_billing_order__c=true
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
        System.debug(' Finished FixedBillingInvoiceBatch');
    }
    
    /*  global void InvSchcreateNONACRInvoice(
Map<Id,BVCOrder__c> nonacrBVCOrderMap,
Map<Id,List<BVC_Order_Product__c>> nonacrBVCOrderProductMap,
List<BVC_Invoice_Run__c> invoiceRun
) {
System.debug('👉 Starting simplified invoice creation...');

// ---------------------------
// STEP 1️⃣: Create One Invoice
// ---------------------------
BVCInvoice__c singleInvoice = new BVCInvoice__c();
singleInvoice.Account__c = (nonacrBVCOrderMap.values().isEmpty()) ? null : nonacrBVCOrderMap.values()[0].Billing_Account__c;
singleInvoice.BVC_Invoice_Run__c = invoiceRun[0].Id;
singleInvoice.BVC_LegalEntity__c = nonacrBVCOrderMap.values().isEmpty() ? null : nonacrBVCOrderMap.values()[0].BVC_LegalEntity__c;
singleInvoice.InvoiceDate__c = Date.today();
singleInvoice.Status__c = 'Draft';
singleInvoice.EY_Tax_Calculation_Status__c = 'Pending';
singleInvoice.Total_BVC_Valuation_Charges__c = 0;
singleInvoice.Total_Docket_Charges__c = 0;
singleInvoice.Total_Fuel_Charges__c = 0;
singleInvoice.Total_Fuel_Surcharge__c = 0;
singleInvoice.Total_Holiday_Charges__c = 0;
singleInvoice.Total_Weight_Charges__c = 0;
singleInvoice.Total_Vaulting_Charges__c = 0;
singleInvoice.Total_Universe_Cost_Charge__c = 0;

insert singleInvoice;
System.debug('✅ Created single invoice: ' + singleInvoice.Id);

// ---------------------------
// STEP 2️⃣: Create Line Items
// ---------------------------
List<BVCInvoiceLineItem__c> lineItems = new List<BVCInvoiceLineItem__c>();
Set<Id> shipmentIdsToUpdate = new Set<Id>();
List<BVC_Order_Product__c> orderProductsToUpdate = new List<BVC_Order_Product__c>();

for (BVCOrder__c order : nonacrBVCOrderMap.values()) {
for (BVC_Order_Product__c op : order.BVC_Order_Products__r) {
if (op.Billing_status__c == 'Pending') {
BVCInvoiceLineItem__c li = new BVCInvoiceLineItem__c();
li.BVCInvoice__c = singleInvoice.Id;
li.BVC_Order_Product__c = op.Id;
li.BVC_Invoice_Run__c = invoiceRun[0].Id;
li.Charge_Date__c = Date.today();
li.Quantity__c = op.Quantity__c;
li.Unit_Price__c = op.Total_Charges__c;
li.Subtotal__c = op.Total_Charges__c;
li.Product_Code__c = op.Product_Code__c;
li.Consignee_Name__c = op.Consignee_Name__c;
li.Shipment__c = op.Shipment__c;
lineItems.add(li);

if (op.Shipment__c != null) shipmentIdsToUpdate.add(op.Shipment__c);

op.Billing_status__c = 'Completed';
orderProductsToUpdate.add(op);
}
}
}

if (!lineItems.isEmpty()) {
insert lineItems;
System.debug('✅ Inserted ' + lineItems.size() + ' invoice lines');
}

// ---------------------------
// STEP 3️⃣: Update Shipments
// ---------------------------
if (!shipmentIdsToUpdate.isEmpty()) {
List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();
for (Id sid : shipmentIdsToUpdate) {
shipmentsToUpdate.add(new Shipment__c(Id = sid, Status__c = 'Billed'));
}
update shipmentsToUpdate;
System.debug('✅ Updated ' + shipmentsToUpdate.size() + ' shipments to Billed');
}

// ---------------------------
// STEP 4️⃣: Update Orders
// ---------------------------
List<BVCOrder__c> ordersToUpdate = new List<BVCOrder__c>();
for (BVCOrder__c o : nonacrBVCOrderMap.values()) {
o.Billing_status__c = 'Completed';
ordersToUpdate.add(o);
}

update orderProductsToUpdate;
update ordersToUpdate;
System.debug('✅ Orders and Order Products marked as completed');

// ---------------------------
// STEP 5️⃣: Update Invoice Run Summary
// ---------------------------
AggregateResult[] result = [
SELECT COUNT(Id) totalCount 
FROM BVCInvoiceLineItem__c 
WHERE BVCInvoice__c = :singleInvoice.Id
];

if (!result.isEmpty()) {
invoiceRun[0].Total_Invoice_Lines__c = (Integer) result[0].get('totalCount');
update invoiceRun[0];
System.debug('✅ Updated invoice run summary');
}

System.debug('🎯 Simplified invoice creation complete!');
}*/
    global void InvSchcreateNONACRInvoice(
        Map<Id, BVCOrder__c> nonacrBVCOrderMap,
        Map<Id,List<BVC_Order_Product__c>> nonacrBVCOrderProductMap,
        List<BVC_Invoice_Run__c> invoiceRun
    ) {
        System.debug(' Starting multi-entity invoice creation...');
        
       //group orders by legal entity
        Map<Id, List<BVCOrder__c>> ordersByLegalEntity = new Map<Id, List<BVCOrder__c>>();
        for (BVCOrder__c order : nonacrBVCOrderMap.values()) {
            if (order.BVC_LegalEntity__c != null) {
                if (!ordersByLegalEntity.containsKey(order.BVC_LegalEntity__c)) {
                    ordersByLegalEntity.put(order.BVC_LegalEntity__c, new List<BVCOrder__c>());
                }
                ordersByLegalEntity.get(order.BVC_LegalEntity__c).add(order);
            }
        }
        
        List<BVCInvoice__c> invoicesToInsert = new List<BVCInvoice__c>();
        Map<Id, Id> legalEntityToInvoiceMap = new Map<Id, Id>();
        
        //Create one invoice per Legal Entity
        for (Id leId : ordersByLegalEntity.keySet()) {
            List<BVCOrder__c> orders = ordersByLegalEntity.get(leId);
            
            BVCInvoice__c invoice = new BVCInvoice__c();
            invoice.Account__c = (orders.isEmpty()) ? null : orders[0].Billing_Account__c;
            invoice.BVC_Invoice_Run__c = invoiceRun[0].Id;
            invoice.BVC_LegalEntity__c = leId;
            invoice.InvoiceDate__c = Date.today();
            invoice.Status__c = 'Draft';
            invoice.EY_Tax_Calculation_Status__c = 'Pending';
            invoice.Total_BVC_Valuation_Charges__c = 0;
            invoice.Total_Docket_Charges__c = 0;
            invoice.Total_Fuel_Charges__c = 0;
            invoice.Total_Fuel_Surcharge__c = 0;
            invoice.Total_Holiday_Charges__c = 0;
            invoice.Total_Weight_Charges__c = 0;
            invoice.Total_Vaulting_Charges__c = 0;
            invoice.Total_Universe_Cost_Charge__c = 0;
            
            invoicesToInsert.add(invoice);
        }
        
        insert invoicesToInsert;
        System.debug('Created ' + invoicesToInsert.size() + ' invoices');
        
        // Map legal entity → invoice Id
        for (Integer i = 0; i < invoicesToInsert.size(); i++) {
            legalEntityToInvoiceMap.put(invoicesToInsert[i].BVC_LegalEntity__c, invoicesToInsert[i].Id);
        }
        
        // Create Invoice Line Items
        List<BVCInvoiceLineItem__c> lineItems = new List<BVCInvoiceLineItem__c>();
        Set<Id> shipmentIdsToUpdate = new Set<Id>();
        List<BVC_Order_Product__c> orderProductsToUpdate = new List<BVC_Order_Product__c>();
        List<BVCOrder__c> ordersToUpdate = new List<BVCOrder__c>();
        
        for (BVCOrder__c order : nonacrBVCOrderMap.values()) {
            Id invoiceId = legalEntityToInvoiceMap.get(order.BVC_LegalEntity__c);
            if (invoiceId == null) continue;
            
            for (BVC_Order_Product__c op : order.BVC_Order_Products__r) {
                if (op.Billing_status__c == 'Pending') {
                    BVCInvoiceLineItem__c li = new BVCInvoiceLineItem__c();
                    li.BVCInvoice__c = invoiceId;
                    li.BVC_Order_Product__c = op.Id;
                    li.BVC_Invoice_Run__c = invoiceRun[0].Id;
                    li.Charge_Date__c = Date.today();
                    li.Quantity__c = op.Quantity__c;
                    li.Unit_Price__c = op.Total_Charges__c;
                    li.Subtotal__c = op.Total_Charges__c;
                    li.Product_Code__c = op.Product_Code__c;
                    li.Consignee_Name__c = op.Consignee_Name__c;
                    li.Shipment__c = op.Shipment__c;
                    lineItems.add(li);
                    
                    if (op.Shipment__c != null) shipmentIdsToUpdate.add(op.Shipment__c);
                    
                    op.Billing_status__c = 'Completed';
                    orderProductsToUpdate.add(op);
                }
            }
            
            order.Billing_status__c = 'Completed';
            ordersToUpdate.add(order);
        }
        
        if (!lineItems.isEmpty()) {
            insert lineItems;
            System.debug(' Inserted ' + lineItems.size() + ' invoice lines');
        }
        
        //Update Shipments
        if (!shipmentIdsToUpdate.isEmpty()) {
            List<Shipment__c> shipmentsToUpdate = new List<Shipment__c>();
            for (Id sid : shipmentIdsToUpdate) {
                shipmentsToUpdate.add(new Shipment__c(Id = sid, Status__c = 'Billed'));
            }
            update shipmentsToUpdate;
            System.debug('Updated ' + shipmentsToUpdate.size() + ' shipments to Billed');
        }
        
        //Update Orders & Order Products
        update orderProductsToUpdate;
        update ordersToUpdate;
        System.debug('Orders and Order Products marked as completed');
        
       // Update Invoice Run summary
        AggregateResult[] result = [
            SELECT COUNT(Id) totalCount 
            FROM BVCInvoiceLineItem__c 
            WHERE BVC_Invoice_Run__c = :invoiceRun[0].Id
        ];
        
        if (!result.isEmpty()) {
            invoiceRun[0].Total_Invoice_Lines__c = (Integer) result[0].get('totalCount');
            update invoiceRun[0];
            System.debug('Updated invoice run summary');
        }
        
        System.debug('Multi-entity invoice creation complete!');
    }
    
}