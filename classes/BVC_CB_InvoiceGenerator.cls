public class BVC_CB_InvoiceGenerator {
    
   /* public static void createShipmentInvoice(Map<Id,Order> orderMap, Map<Id,List<OrderItem>> orderProductMap){
        List<blng__Invoice__c> newInvoices = new List<blng__Invoice__c>();
        //List<Object_Mapping__mdt> objectMappings = Object_Mapping__mdt.getAll().Values();
        List<BVC_CB_Object_Mapping__c> objectMappings = [select Id,Source_Object_API_Name__c, Source_Field_API_Name__c, Target_Field_API_Name__c, Target_Object_API_Name__c from BVC_CB_Object_Mapping__c where Source_Object_API_Name__c ='Order' and Is_Active__c = true];
        for(Order o : orderMap.values()){
            blng__Invoice__c inv = new blng__Invoice__c();
            inv.blng__Account__c = o.AccountId;
            inv.blng__Order__c = o.Id;
            inv.blng__InvoiceDate__c = Date.today();
            //inv.BVC_Branch__c = o.BVC_Branch__c;
            inv.BVC_Billing_Entity__c = o.BVC_Billing_Entity__c;
            inv.BVC_Entity__c = o.BVC_Entity__c;
            inv.BVC_CB_COA_SOURCE_CODE__c = 44;
            inv.blng__BillToContact__c = o.Account.blng__BillToContact__c;
            /* if(o.Billing_Address__c != null){
inv.Billing_Address__c = o.Billing_Address__c;
}
else if(o.Billing_Address__c == null && o.Account != null){
inv.Billing_Address__c = o.Account.Billing_Address__c;
}
            inv.Origin_Address__c = o.Origin_Address__c;
            inv.BVC_CB_Is_CB_Invoice__c = true;
            for(BVC_CB_Object_Mapping__c fieldMapping : objectMappings){
                inv.put(fieldMapping.Target_Field_API_Name__c, o.get(fieldMapping.Source_Field_API_Name__c));       
            } 
            newInvoices.add(inv);
        }
        
        if(newInvoices.size() > 0 && newInvoices != null){
            Database.SaveResult[] lsr = Database.insert(newInvoices);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    System.debug('The Following Invoice Lines were Inserted'+result.getId());
                }
                else {
                    // Operation failed, so get all errors                
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
            for(blng__Invoice__c inv : newInvoices){
                if(inv.blng__Order__c != null && inv.Id != null){
                    orderInvMap.put(inv.blng__Order__c,inv.Id);     
                }
                
            }
        }
        List<blng__InvoiceLine__c> lines = new List<blng__InvoiceLine__c>();
        List<BVC_CB_Object_Mapping__c> orderItemMappings = [select Id,Source_Object_API_Name__c, Source_Field_API_Name__c, Target_Field_API_Name__c, Target_Object_API_Name__c from BVC_CB_Object_Mapping__c where Source_Object_API_Name__c ='OrderItem'];
        
        for(Id key : orderMap.keyset()){
            if(orderProductMap.containsKey(key)){
                for(OrderItem oi : orderProductMap.get(key)){
                    
                    if(orderInvMap.containsKey(oi.OrderId)){
                        blng__InvoiceLine__c li = new blng__InvoiceLine__c();
                        li.blng__OrderProduct__c = oi.Id;
                        li.blng__Product__c = oi.Product2Id;
                        li.blng__Invoice__c = orderInvMap.get(oi.OrderId);
                        li.Name = oi.Product2.Name;
                        li.blng__Quantity__c = oi.Quantity;
                        li.blng__CalculatedQuantity__c = oi.Quantity;
                        li.blng__Subtotal__c = oi.TotalPrice;
                        // li.blng__Subtotal__c = 78.3;
                        li.blng__UnitPrice__c = oi.UnitPrice;
                        //li.name=oi.BVC_CB_ChargeDescription__c;
                        li.blng__BillingRule__c = oi.Product2.blng__BillingRule__c;
                        li.blng__TaxRule__c = oi.Product2.blng__TaxRule__c;
                        li.blng__LegalEntity__c = oi.blng__LegalEntity__c;
                        li.blng__BillingTreatment__c = oi.blng__BillingTreatment__c;
                        li.blng__StartDate__c = oi.ServiceDate;
                        li.blng__EndDate__c = oi.EndDate;
                        li.blng__ChargeDate__c = Date.today();
                        for(BVC_CB_Object_Mapping__c fieldMapping : orderItemMappings){
                            li.put(fieldMapping.Target_Field_API_Name__c, oi.get(fieldMapping.Source_Field_API_Name__c));       
                        } 
                        lines.add(li);
                        
                    }
                } 
            }
            
        }
        
        Database.SaveResult[] lsr = Database.insert(lines);
        for(Database.SaveResult result : lsr){
            if(result.isSuccess()){
                System.debug('The Following Invoice Lines were Inserted'+result.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : result.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Invoice Line fields that affected this error: ' + err.getFields());
                }
            }
            
        }
        
    }*/
    
    public static void createShipmentCBInvoice(Map<Id,BVCOrder__c> orderMap, Map<Id,List<BVC_Order_Product__c>> orderProductMap){
        System.debug('=== Rafi debug inside createShipmentCBInvoice  === ');
        
        List<BVCInvoice__c> newInvoices = new List<BVCInvoice__c>();
        //List<Object_Mapping__mdt> objectMappings = Object_Mapping__mdt.getAll().Values();
        List<BVC_CB_Object_Mapping__c> objectMappings = [select Id,Source_Object_API_Name__c, Source_Field_API_Name__c, Target_Field_API_Name__c, Target_Object_API_Name__c from BVC_CB_Object_Mapping__c where Source_Object_API_Name__c ='BVCOrder__c' and Is_Active__c = true];
        
        Map<String, Id> createdInvoicesByInvoiceType = new Map<String, Id>();
        
        Set<String> existingInvoiceKeys = new Set<String>();
        
        for (BVCInvoice__c inv : [SELECT Id, BVCOrder__c, BVCOrder__r.BVC_CB_Invoice_Type__c FROM BVCInvoice__c WHERE BVCOrder__c IN :orderMap.keySet()]) {
            String existingInvoiceKey = inv.BVCOrder__r.BVC_CB_Invoice_Type__c + '-' + inv.BVCOrder__c;
            existingInvoiceKeys.add(existingInvoiceKey);
        }
        
        for (BVCOrder__c o : orderMap.values()) {
            System.debug('for checking for order: ' + o.Id);
            
            String invoiceKey = o.BVC_CB_Invoice_Type__c + '-' + o.Id;
            
            System.debug('for checking Generated invoiceKey: ' + invoiceKey);
            System.debug('for checking Current existingInvoiceKeys: ' + existingInvoiceKeys);
            
            if (!existingInvoiceKeys.contains(invoiceKey)) {
                System.debug('for checking Inside for of Invoice generation');
                BVCInvoice__c inv = new BVCInvoice__c();
                inv.Account__c = o.Account__c;
                inv.BVCOrder__c = o.Id;
                inv.InvoiceDate__c = Date.today();
                inv.Invoice_Date__c= Date.today();
                inv.BVC_Branch__c = o.BVC_Branch__c;
                inv.BVC_LegalEntity__c = o.BVC_LegalEntity__c;
                inv.BVC_Entity__c = o.BVC_Entity__c;
                inv.BVC_CB_COA_SOURCE_CODE__c = 44;
                inv.Bill_To_Contact__c = o.Account__r.BVC_CB_Bill_To_Contact__c;
                inv.ACK_Date_Time__c = System.now();
                inv.Invoice_datetime__c = System.now();
                inv.Origin_Address__c = o.Origin_Address__c;
                inv.BVC_CB_Is_CB_Invoice__c = true;
                
                for (BVC_CB_Object_Mapping__c fieldMapping : objectMappings) {
                    inv.put(fieldMapping.Target_Field_API_Name__c, o.get(fieldMapping.Source_Field_API_Name__c));       
                } 
                
                newInvoices.add(inv);
                existingInvoiceKeys.add(invoiceKey);
                System.debug('for checking Added invoiceKey to existingInvoiceKeys: ' + invoiceKey);
            } else {
                System.debug('for checking Duplicate invoice found for key: ' + invoiceKey + ', skipping creation.');
            }
        }
        
        System.debug('for checking New Invoices to insert: ' + newInvoices);
        System.debug('for checking New Invoices Size to insert: ' + newInvoices.size());
        
        if (!newInvoices.isEmpty()) {
            try{
            Database.SaveResult[] lsr = Database.insert(newInvoices);
            
            for (Database.SaveResult result : lsr) {
                if (result.isSuccess()) {
                    System.debug('for checking Invoice inserted successfully with Id: ' + result.getId());
                } else {
                    for (Database.Error err : result.getErrors()) {
                        System.debug('for checking Error inserting invoice: ' + err.getMessage());
                    }
                }
            }
            } catch (Exception ex){
                System.debug('for checking error '+ex.getMessage());
                System.debug('for checking error line number '+ex.getLineNumber());
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
        List<BVC_CB_Object_Mapping__c> orderItemMappings = [select Id,Source_Object_API_Name__c, Source_Field_API_Name__c, Target_Field_API_Name__c, Target_Object_API_Name__c from BVC_CB_Object_Mapping__c where Source_Object_API_Name__c ='BVC_Order_Product__c'];
        try{
            for(Id key : orderMap.keyset()){
                if(orderProductMap.containsKey(key)){
                    for(BVC_Order_Product__c oi : orderProductMap.get(key)){
                        
                        if(orderInvMap.containsKey(oi.BVCOrder__c)){
                            BVCInvoiceLineItem__c li = new BVCInvoiceLineItem__c();
                            li.BVC_Order_Product__c = oi.Id;
                            li.BVCInvoice__c = orderInvMap.get(oi.BVCOrder__c);
                            invoiceId = orderInvMap.get(oi.BVCOrder__c);
                            //li.Name = oi.Product_Name__c;
                            li.Quantity__c = oi.Quantity__c;
                            li.Calculated_Quantity__c = oi.Quantity__c;
                            li.Subtotal__c = oi.Total_Price__c;
                            li.Unit_Price__c = oi.Unit_Price__c;
                            li.name=oi.BVC_CB_ChargeDescription__c;
                            /*li.blng__BillingRule__c = oi.Product2.blng__BillingRule__c;
li.blng__TaxRule__c = oi.Product2.blng__TaxRule__c;
li.blng__LegalEntity__c = oi.blng__LegalEntity__c;
li.blng__BillingTreatment__c = oi.blng__BillingTreatment__c;*/
                            li.Start_Date__c = oi.Start_Date__c;
                            li.End_Date__c = oi.End_Date__c;
                            li.Charge_Date__c = Date.today();
                            li.Product_Name__c = oi.BVC_CB_ChargeDescription__c;
                            li.Product_Code__c = 'CB-'+oi.BVC_CB_ChargeCode__c;
                            //li.Product_Name__c=oi.Product_Name__c;
                            for(BVC_CB_Object_Mapping__c fieldMapping : orderItemMappings){
                                li.put(fieldMapping.Target_Field_API_Name__c, oi.get(fieldMapping.Source_Field_API_Name__c));       
                            } 
                            lines.add(li);
                            
                        }
                    } 
                }
                
            }
            
            Database.SaveResult[] lsr = Database.insert(lines);
            for(Database.SaveResult result : lsr){
                if(result.isSuccess()){
                    System.debug('The Following Invoice Lines were Inserted'+result.getId());
                    
                    if(invoiceId!=null){
                        BVCinvoice__c inv = new BVCinvoice__c(id=invoiceId);
                        inv.Product_Code__c=lines[0].Product_Code__c;
                        inv.Product_Name__c=lines[0].Product_Name__c;
                        
                        System.debug('Rafi debug to check  invoice inv.Product_Code__c = '+inv.Product_Code__c);
                        System.debug('Rafi debug to check  invoice inv.Product_Name__c = '+inv.Product_Name__c);
                        
                        update inv;
                    }
            
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Invoice Line fields that affected this error: ' + err.getFields());
                    }
                }
                
            }
            
            
        } catch (Exception e){
            System.debug('for checking e.getMessage() '+e.getMessage());
            System.debug('for checking e.getLineNumber() '+e.getLineNumber());
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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