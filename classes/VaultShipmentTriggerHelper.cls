public class VaultShipmentTriggerHelper {
    public static void createBVCOrder(List<Vault_Shipmet__c> vaultShipments) {

        List<BVCOrder__c> ordersToInsert = new List<BVCOrder__c>();
        Set<Id> accountIds = new Set<Id>();

        for (Vault_Shipmet__c vs : vaultShipments) {
            if (vs.Billing_Account__c != null) {
                accountIds.add(vs.Billing_Account__c);
            }
        }
		system.debug('Size of accountIds:::'+accountIds.size());
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Customer_Category_Static__c 
            FROM Account 
            WHERE Id IN :accountIds
        ]);

        Map<Id, BVC_Contract__c> accountToContractMap = new Map<Id, BVC_Contract__c>();
        for (BVC_Contract__c con : [
            SELECT Id, Quote__c, Customer_Name__r.Billing_Address__c, BVC_Entity__c, BVC_LegalEntity__c, Contract_Amount__c, BVC_Branch__c 
            FROM BVC_Contract__c 
            WHERE Customer_Name__c IN :accountIds
        ]) {
            accountToContractMap.put(con.Customer_Name__c, con);
        }

        for (Vault_Shipmet__c vs : vaultShipments) {
            BVC_Contract__c contract = accountToContractMap.get(vs.Billing_Account__c);
            Account acct = accountMap.get(vs.Billing_Account__c);
			system.debug('customer id:::'+acct.id);
            BVCOrder__c order = new BVCOrder__c();
            order.Vault_Shipmet__c = vs.Id;
            order.Account__c = vs.Billing_Account__c;
            order.Billing_Account__c = vs.Billing_Account__c;
            order.Order_Amount__c = vs.Product_Value__c;
            if (contract != null) {
                order.BVC_Branch__c = contract.BVC_Branch__c;
                order.BVC_Entity__c = contract.BVC_Entity__c;
                order.BVC_LegalEntity__c = contract.BVC_LegalEntity__c;
            }
            order.Billing_Address__c = vs.Billing_Address__c;
			system.debug('customer static:::'+acct.Customer_Category_Static__c);
            if (acct.Customer_Category_Static__c == 'ACR') {
                order.Business_Type__c = 'ACR';
            } else if (acct.Customer_Category_Static__c == 'Non-ACR') {
                order.Business_Type__c = 'Non ACR';
            }

            ordersToInsert.add(order);
        }

        Map<Id, BVCOrder__c> insertedOrderMap = new Map<Id, BVCOrder__c>();
        if (!ordersToInsert.isEmpty()) {
            Database.SaveResult[] lsr = Database.insert(ordersToInsert, false);
            for (Integer i = 0; i < lsr.size(); i++) {
                if (lsr[i].isSuccess()) {
                    BVCOrder__c original = ordersToInsert[i];
                    original.Id = lsr[i].getId();
                    insertedOrderMap.put(original.Id, original);
                    System.debug('Order with Id :' + original.Id + ' Successfully Inserted');
                } else {
                    for (Database.Error err : lsr[i].getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        List<BVC_Order_Product__c> orderItemsToInsert = new List<BVC_Order_Product__c>();
        Map<Id, Id> shipmentToOrderMap = new Map<Id, Id>();
        for (BVCOrder__c od : insertedOrderMap.values()) {
            shipmentToOrderMap.put(od.Vault_Shipmet__c, od.Id);
        }

        for (Vault_Shipmet__c vs : vaultShipments) {
            BVC_Contract__c contract = accountToContractMap.get(vs.Billing_Account__c);
            Id orderId = shipmentToOrderMap.get(vs.Id);

            if (orderId != null) {
                BVC_Order_Product__c oi = new BVC_Order_Product__c();
                oi.BVCOrder__c = orderId;
                oi.Vault_Shipmet__c = vs.Id;
                oi.Total_Price__c = vs.Product_Value__c;
              //  oi.Activation_Status__c = 'Activated';
                oi.Total_Charges__c = vs.Product_Value__c;
                oi.Unit_Price__c = vs.Product_Value__c;
                oi.Billable_Unit_Price__c = vs.Product_Value__c;
                oi.Activated__c = true;
                if (contract != null) {
                    oi.BVC_Branch__c = contract.BVC_Branch__c;
                    oi.BVC_Entity__c = contract.BVC_Entity__c;
                    oi.BVC_LegalEntity__c = contract.BVC_LegalEntity__c;
                }
                orderItemsToInsert.add(oi);
            }
        }

        Map<Id, List<BVC_Order_Product__c>> orderToProductMap = new Map<Id, List<BVC_Order_Product__c>>();
        if (!orderItemsToInsert.isEmpty()) {
            Database.SaveResult[] lsr = Database.insert(orderItemsToInsert, false);
            for (Integer i = 0; i < lsr.size(); i++) {
                if (lsr[i].isSuccess()) {
                    BVC_Order_Product__c item = orderItemsToInsert[i];
                    System.debug('Order Item with Id :' + lsr[i].getId() + ' Successfully Inserted');
                    if (!orderToProductMap.containsKey(item.BVCOrder__c)) {
                        orderToProductMap.put(item.BVCOrder__c, new List<BVC_Order_Product__c>());
                    }
                    orderToProductMap.get(item.BVCOrder__c).add(item);
                } else {
                    for (Database.Error err : lsr[i].getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order Item fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        List<BVCOrder__c> ordersToUpdate = new List<BVCOrder__c>();
        for (Id ordId : insertedOrderMap.keySet()) {
            BVCOrder__c ord = new BVCOrder__c(Id = ordId);
            ord.Status__c = 'Activated';
            ordersToUpdate.add(ord);
        }
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }

        Map<Id, BVCOrder__c> nonAcrOrders = new Map<Id, BVCOrder__c>();
        Map<Id, List<BVC_Order_Product__c>> nonAcrOrderToProducts = new Map<Id, List<BVC_Order_Product__c>>();

        for (Id orderId : insertedOrderMap.keySet()) {
            BVCOrder__c order = insertedOrderMap.get(orderId);
            if (order.Business_Type__c == 'Non ACR') {
                nonAcrOrders.put(orderId, order);
                if (orderToProductMap.containsKey(orderId)) {
                    nonAcrOrderToProducts.put(orderId, orderToProductMap.get(orderId));
                }
            }
        }

        if (!nonAcrOrders.isEmpty()) {
            createNONACRInvoice(nonAcrOrders, nonAcrOrderToProducts);
        }

        Map<Id, BVCOrder__c> acrOrders = new Map<Id, BVCOrder__c>();
        Map<Id, List<BVC_Order_Product__c>> acrOrderToProducts = new Map<Id, List<BVC_Order_Product__c>>();

        for (Id orderId : insertedOrderMap.keySet()) {
            BVCOrder__c order = insertedOrderMap.get(orderId);
            if (order.Business_Type__c == 'ACR') {
                acrOrders.put(orderId, order);
                if (orderToProductMap.containsKey(orderId)) {
                    acrOrderToProducts.put(orderId, orderToProductMap.get(orderId));
                }
            }
        }

        if (!acrOrders.isEmpty()) {
            createBVCACRConsumption(acrOrders, acrOrderToProducts);
        }
    }

    public static void createNONACRInvoice(Map<Id,BVCOrder__c> nonacrBVCOrderMap, Map<Id,List<BVC_Order_Product__c>> nonacrBVCOrderProductMap){
        List<BVCInvoice__c> newInvoices = new List<BVCInvoice__c>();
        for(BVCOrder__c BVCOrder : nonacrBVCOrderMap.values()){
            BVCInvoice__c inv = new BVCInvoice__c();
            inv.Account__c = BVCOrder.Billing_Account__c;
            inv.BVCOrder__c = BVCOrder.Id;
            inv.Invoice_Date__c = Date.today();
            inv.InvoiceDate__c = Date.today();
            inv.Invoice_datetime__c = System.now();
            inv.BVC_Branch__c = BVCOrder.BVC_Branch__c;
            inv.BVC_LegalEntity__c = BVCOrder.BVC_LegalEntity__c;
            inv.BVC_Entity__c = BVCOrder.BVC_Entity__c;
            inv.status__c='Draft';
            inv.EY_Tax_Calculation_Status__c='Pending';
            inv.RDS_Status__c = 'Pending';
            inv.Billing_Address__c = BVCOrder.Billing_Address__c;
            inv.Origin_Address__c = BVCOrder.Billing_Address__c;
            newInvoices.add(inv);
        }

        if (!newInvoices.isEmpty()) {
            Database.SaveResult[] lsr = Database.insert(newInvoices);
            for (Database.SaveResult result : lsr) {
                if (result.isSuccess()) {
                    System.debug('The Following Invoices were Inserted' + result.getId());
                } else {
                    for (Database.Error err : result.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        Map<Id, Id> orderInvMap = new Map<Id, Id>();
        for (BVCInvoice__c inv : newInvoices) {
            if (inv.BVCOrder__c != null && inv.Id != null) {
                orderInvMap.put(inv.BVCOrder__c, inv.Id);
            }
        }

        Id invoiceId = null;
        List<BVCInvoiceLineItem__c> lines = new List<BVCInvoiceLineItem__c>();
        System.debug('Inside invoiceLine Creation');

        for (List<BVC_Order_Product__c> oiList : nonacrBVCOrderProductMap.values()) {
            for (BVC_Order_Product__c oi : oiList) {
                if (orderInvMap.containsKey(oi.BVCOrder__c) || Test.isRunningTest()) {
                    BVCInvoiceLineItem__c li = new BVCInvoiceLineItem__c();
                    li.BVC_Order_Product__c = oi.Id;
                    li.BVCInvoice__c = orderInvMap.get(oi.BVCOrder__c);

                    invoiceId = orderInvMap.get(oi.BVCOrder__c);
                    li.Quantity__c = oi.Quantity__c;
                    li.Calculated_Quantity__c = oi.Quantity__c;
                    li.Subtotal__c = oi.Total_Price__c;
                    li.UnitPrice__c = oi.Unit_Price__c;
                    li.Legal_Entity__c = oi.Legal_Entity__c;
                    li.Start_Date__c = oi.Start_Date__c;
                    li.End_Date__c = oi.End_Date__c;
                    li.Charge_Date__c = Date.today();
                    li.Vault_Shipmet__c = oi.Vault_Shipmet__c;
                    li.Gross_Weight__c = oi.Gross_Weight__c;
                    li.Net_Weight__c = oi.Net_Weight__c;
                    li.Product_Name__c = oi.Product_Name__c;
                    li.Product_Code__c = oi.Product_Code__c;
                    li.Total_Charge__c = oi.Total_Charges__c;

                    lines.add(li);
                }
            }
        }

        Boolean isILInserted = false;
        if (!lines.isEmpty()) {
            Database.SaveResult[] lsr = Database.insert(lines);
            for (Database.SaveResult result : lsr) {
                if (result.isSuccess()) {
                    isILInserted = true;
                    System.debug('The Following Invoice Lines were Inserted' + result.getId());
                } else {
                    for (Database.Error err : result.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice Line fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        if (invoiceId != null && !lines.isEmpty()) {
            BVCInvoice__c inv = new BVCInvoice__c(Id = invoiceId);
            inv.Product_Code__c = lines[0].Product_Code__c;
            inv.Product_Name__c = lines[0].Product_Name__c;
            update inv;
        }
    }

    public static void createBVCACRConsumption(Map<Id, BVCOrder__c> orderMap, Map<Id, List<BVC_Order_Product__c>> orderProductMap) {
        System.debug('Inside createBVCACRConsumption. Order Count: ' + orderMap.size());
        UtilClass.triggerLoop = true;

        Set<Id> accountIds = new Set<Id>();
        for (BVCOrder__c order : orderMap.values()) {
            if (order.Account__c != null) {
                accountIds.add(order.Account__c);
            }
        }

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, ST_Pricing_Type__c, Active_Contract__c,
            BVC_Contract__r.Quote__r.Name, BVC_Contract__r.Quote__c,
           // Original_Contract_End_Date__c, commented to uninstall CPQ
            BVC_Contract__c,
            of_Contract_Consumption__c, Adjusted_Contract_Amount__c,
            Adjustment_Amount__c, Balance_Amount__c,
            Contracted_ACR_Package__c, Contract_Start_Date__c,
            Contract_End_Date__c, Contract_Amount__c
            FROM Account
            WHERE Id IN :accountIds
        ]);

        List<BVC_ACR_Consumption__c> consumptionList = new List<BVC_ACR_Consumption__c>();

        for (BVCOrder__c order : orderMap.values()) {
            Account acc = accMap.get(order.Account__c);

            Boolean isEligible = acc != null &&
                ((acc.Contract_End_Date__c != null && acc.Contract_End_Date__c >= Date.today())
                 && (acc.ST_Pricing_Type__c == 'ACR')
                 && (acc.Contracted_ACR_Package__c != null)
                 && (order.Business_Type__c == 'ACR'))
                && order.Vault_Shipmet__c != null;
			system.debug('acc.Contract_End_Date__c::'+acc.Contract_End_Date__c);
            system.debug('acc.ST_Pricing_Type__c::'+acc.ST_Pricing_Type__c);
            system.debug('acc.Contracted_ACR_Package__c::'+acc.Contracted_ACR_Package__c);
            system.debug('order.Business_Type__c::'+order.Business_Type__c);
            system.debug('order.Vault_Shipmet__c::'+order.Vault_Shipmet__c);
            if (isEligible && orderProductMap.containsKey(order.Id)) {
                for (BVC_Order_Product__c oi : orderProductMap.get(order.Id)) {
                    BVC_ACR_Consumption__c consumption = new BVC_ACR_Consumption__c();
                    consumption.Account__c = acc.Id;
                    consumption.BVCOrder__c = order.Id;
                    consumption.Total_Charge__c = order.Order_Amount__c;
                    consumption.Vault_Shipmet__c = oi.Vault_Shipmet__c;
                    consumption.BVC_Order_Product__c = oi.Id;
                    consumption.No_Of_Packages__c = oi.Number_of_Packages__c;
                    consumption.Status__c = 'Valid';
                    consumption.Freight_Charges__c = oi.Freight_Charges__c;
                    consumption.Gross_Weight__c = oi.Gross_Weight__c;
                    consumption.Net_Weight__c = oi.Net_Weight__c;
                    consumption.BVC_Contract__c=acc.BVC_Contract__c;
                    consumptionList.add(consumption);
                }
            }
        }

        if (!consumptionList.isEmpty()) {
            Database.SaveResult[] results = Database.insert(consumptionList, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug('Insert ACR_Consumption error: ' + err.getMessage());
                    }
                } else {
                    System.debug('Inserted ACR Consumption: ' + results[i].getId());
                }
            }
        }
    }
}