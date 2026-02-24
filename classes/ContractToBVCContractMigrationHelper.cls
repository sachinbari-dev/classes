public class ContractToBVCContractMigrationHelper 
{/*
public static void MigratedLogGeneration(List<Database.UpsertResult> upsertResults,List<BVCOrder__c> bvcOrderList,
                                         List<BVC_ACR_Consumption__c> bvcACRConsumptionList,List<BVC_Order_Product__c> bvcOrderProductList,
                                         String FromObject,String ToObject)
{
    List<Data_Migration_Log__c> dmList = new List<Data_Migration_Log__c>();
    List<String> recIdsList = new List<String>();
    for (Integer i = 0; i < upsertResults.size(); i++) 
    {
        Database.UpsertResult result = upsertResults[i];
        if (result.isSuccess()) 
        {                       
            Data_Migration_Log__c MigrationLogPassed = new Data_Migration_Log__c();
            MigrationLogPassed.Name=FromObject+' Migration';
            MigrationLogPassed.Migrated_From__c=FromObject;
            MigrationLogPassed.Migrated_To__c=ToObject;
            MigrationLogPassed.Result__c='Passed';
			if(FromObject =='Order')			
			{
				MigrationLogPassed.Processed_recordId__c=bvcOrderList[i].Migrated_Order__c;
			}
            if(FromObject =='ACR Consumption')			
            {
                MigrationLogPassed.Processed_recordId__c=bvcOrderProductList[i].Migrated_OrderItem__c;
            }
            if(FromObject =='Order Product')			
            {
                MigrationLogPassed.Processed_recordId__c=bvcOrderProductList[i].Migrated_OrderItem__c;
            }
            recIdsList.add(MigrationLogPassed.Processed_recordId__c);
            dmList.add(MigrationLogPassed);
        } 
        else 
        {
            Data_Migration_Log__c MigrationLogFailed = new Data_Migration_Log__c();
            MigrationLogFailed.Name=FromObject+' Migration';
            MigrationLogFailed.Result__c='Failed';
            MigrationLogFailed.Migrated_From__c=FromObject;
            MigrationLogFailed.Migrated_To__c=ToObject;            
            for (Database.Error error : result.getErrors()) 
			{     
                if(FromObject =='Order')			
                {
                    MigrationLogFailed.Error__c='Error on record Id: ' + bvcOrderList[i].Migrated_Order__c + ' - ' + error.getMessage();
                    MigrationLogFailed.Processed_recordId__c=bvcOrderList[i].Migrated_Order__c;
                }
                if(FromObject =='ACR Consumption')			
                {
                    MigrationLogFailed.Error__c='Error on record Id: ' + bvcACRConsumptionList[i].Migrated_ACR_Consumption__c + ' - ' + error.getMessage();
                    MigrationLogFailed.Processed_recordId__c=bvcACRConsumptionList[i].Migrated_ACR_Consumption__c;
                }
                if(FromObject =='Order Product')			
                {
                    MigrationLogFailed.Error__c='Error on record Id: ' + bvcOrderProductList[i].Migrated_OrderItem__c + ' - ' + error.getMessage();
                    MigrationLogFailed.Processed_recordId__c=bvcOrderProductList[i].Migrated_OrderItem__c;
                }
            } 
            recIdsList.add(MigrationLogFailed.Processed_recordId__c);
            dmList.add(MigrationLogFailed);
        }
    }
    if(recIdsList.size()>0)
    {
        List<Data_Migration_Log__c> DeleteLogList = [select Id from Data_Migration_Log__c where Processed_recordId__c IN : recIdsList];
        delete DeleteLogList;
        insert dmList;
    }
}    
    public static void generateBvcOrders(List<String> contractsIdList,Map<String,String> contIds)
    {
        List<ST_ACR_Consumption__c> acrConsList = new List<ST_ACR_Consumption__c>();
        acrConsList = [select id,Contract__c,Contract_Date_From__c,Contract_Date_To__c,Product__c,Adjustment_to_Contract_Amount__c
                                                   ,Adjusted_Contract_Amount__c,Shipper_PAN__c,Consignee_Name__c,Minimum_Freight__c,
                                                   Bill_To_Account__c,ST_ACR_Order__c,BVC_Valuation_Charges__c,
                                                   Bill_To_Address__c,BVC_Branch__c,Shipment__c,Shipment_Number__c,
                                                   Gross_Weight_UOM__c,Gross_Weight_GMS__c,Gross_Weight_Kg__c,Gross_Weight__c,
                                                   Net_Weight__c,Docket_Charges__c,Fuel_Charges__c,Fidelity_Liability__c,Net_Weight_UOM__c,Net_Weight_GMS__c,Universe_Cost_Charge__c,Net_Weight_kg__c,
                                                   Liability_Cover_By_BVC__c,Holiday_Charges__c,Status__c,Remote_Location__c,Subrogation_Liability__c,Indirect_Location__c,Consumption__c,Total_Charge__c,
                                                   No_Of_Packages__c,Offline_Charges__c,Liability_charges__c,Contract_Amount__c,Contract_Balance__c,
                                                   Customer_Account__c,Shipment_Date__c,Shipper_Name__c,Consignee_PAN__c,
                                                   Freight_Charges__c,Fuel_Surcharge__c,Weight_Charges__c,Destination_Address__c,
                                                   Destination_type__c,Destination_City__c,Origin_Address__c,Origin_Type__c,
                                                   Confirmed_By_Name__c,Shipment_Value__c,Product_Description__c
                                                   from ST_ACR_Consumption__c where Contract__c IN :contractsIdList];
        System.debug('Line 18 Found acrConsList Size : '+acrConsList.size());
        List<BVCOrder__c> bvcOrders = new List<BVCOrder__c>();
        if(acrConsList.size()>0) 
        { 
            System.debug('Line 20 ');
            List<String> orderIds = new List<String>();
            List<Order> orderList = new List<Order>();
            for(ST_ACR_Consumption__c acrcm : acrConsList)         
            { 
                System.debug('Line 24 acrcm.Id:'+acrcm.Id);
                System.debug('Line 24 acrcm.ST_ACR_Order__c:'+acrcm.ST_ACR_Order__c);
                if(acrcm.ST_ACR_Order__c!=null)
                { System.debug('Line 25 ');
                 orderIds.add(acrcm.ST_ACR_Order__c);
                }            
            } 
            System.debug('Line 29 orderIds.size() : '+orderIds.size());
            if(orderIds.size()>0)
            {
                Map<String,String> orderMap = new Map<String,String>();
                orderList = [select Id,Order_Status_Static__c,ActivatedById,Status,TotalAmount,BVC_Branch__c,Shipment_Date__c,Shipment_Number__c,Destination_Address__c,
                             Destination_Type__c, Total_Freight_Charges__c,Total_BVC_Valuation_Charges__c,Consignee_Name__c,Consignee_PAN__c,Shipper_Name__c,Shipper_PAN__c,Product_Description__c,
                             Shipment_Status_Static__c,EndDate,blng__InvoiceBatch__c,blng__BillingAccount__c,Billing_Address__c,Shipment__c,
                             SBQQ__PaymentTerm__c,blng__BillingDayOfMonth__c,Origin_Type__c,Origin_Address__c,Shipment_Value__c,Confirmed_By_Name__c,
                             Shipping_Address__c,Type,AccountId from Order where Id IN :orderIds];
                System.debug('Line 38 orderList.size() : '+orderList.size());
                if(orderList.size()>0)
                {                    
                    for(Order o:orderList)
                    {
                        System.debug('Line 44 o : '+o.Id);
                        BVCOrder__c newBvcOrder = new BVCOrder__c();
                        newBvcOrder.Migrated_Order__c = o.Id;	// mapping migrated Id
                        newBvcOrder.Account__c = o.AccountId;
                        newBvcOrder.Order_Type__c = o.Type;
                        //newBvcOrder.Total_Freight_Charges__c = o.Total_Freight_Charges__c;
                        newBvcOrder.Shipping_Address__c = o.Shipping_Address__c;                    
                        newBvcOrder.Confirmed_By_Name__c = o.Confirmed_By_Name__c;
                        newBvcOrder.Shipment_Value__c = o.Shipment_Value__c;
                        newBvcOrder.Origin_Address__c = o.Origin_Address__c;
                        newBvcOrder.Origin_Type__c = o.Origin_Type__c;
                        newBvcOrder.Order_Amount__c = o.TotalAmount;
                        // newBvcOrder.Account__c = o.EffectiveDate;
                        newBvcOrder.Billing_Day_Of_Month__c = o.blng__BillingDayOfMonth__c;
                        newBvcOrder.Payment_Term__c = o.SBQQ__PaymentTerm__c;
                        newBvcOrder.Shipping_Address__c = o.Shipping_Address__c;
                        newBvcOrder.Billing_Address__c = o.Billing_Address__c; 
                        newBvcOrder.BillingAccount__c = o.blng__BillingAccount__c;
                        newBvcOrder.Invoice_Batch__c = o.blng__InvoiceBatch__c;
                        newBvcOrder.Order_End_Date__c = o.EndDate;
                        newBvcOrder.Shipment_Status_Static__c = o.Shipment_Status_Static__c;
                        newBvcOrder.Product_Description__c = o.Product_Description__c; 
                        newBvcOrder.Shipper_PAN__c = o.Shipper_PAN__c;
                       // newBvcOrder.Total_BVC_Valuation_Charges__c =o.Total_BVC_Valuation_Charges__c;
                        newBvcOrder.Shipper_Name__c = o.Shipper_Name__c;
                        newBvcOrder.Consignee_PAN__c = o.Consignee_PAN__c;
                        newBvcOrder.Consignee_Name__c = o.Consignee_Name__c;
                        newBvcOrder.Destination_Type__c = o.Destination_Type__c;                                    
                        newBvcOrder.Destination_Address__c = o.Destination_Address__c;
                        newBvcOrder.Shipment_Number__c = o.Shipment_Number__c;                     
                        newBvcOrder.Shipment_Date__c = o.Shipment_Date__c;
                        if(o.Shipment__c!=null){newBvcOrder.Shipment__c = o.Shipment__c;}                        
                        newBvcOrder.BVC_Branch__c = o.BVC_Branch__c;                     
                        newBvcOrder.Status__c = o.Status;
                        newBvcOrder.ActivatedBy__c = o.ActivatedById;                     
                        newBvcOrder.Order_Status_Static__c = o.Order_Status_Static__c;   
                        
                        bvcOrders.add(newBvcOrder);
                    }
                    System.debug('Line 79 bvcOrders.size() : '+bvcOrders.size());
                    if(bvcOrders.size()>0)
                    {  
                        System.debug('Line 81');
                     try{
                         // upsert bvcOrders;
                             List<Database.UpsertResult> upsertResults = Database.upsert(bvcOrders, false);
							 ContractToBVCContractMigrationHelper.MigratedLogGeneration(upsertResults,bvcOrders,null,null,'Order','BVC Order');
                         System.debug('129 bvcOrders successfully Inserted');
                         for(BVCOrder__c bo:bvcOrders)
                         {
                             orderMap.put(bo.Migrated_Order__c,bo.Id);
                         } System.debug('Line 87 orderMap:'+orderMap.size());
                         // inserting ST_ACR_Consumption__c
                         List<BVC_ACR_Consumption__c> bvcAcrCToInsert = new List<BVC_ACR_Consumption__c>();
                         for(ST_ACR_Consumption__c acrCL:acrConsList)
                         {
                             System.debug('Line 93 acrCL:'+acrCL.ST_ACR_Order__c);
                             BVC_ACR_Consumption__c singleRecord = new BVC_ACR_Consumption__c();
                             String bvcOrderId = orderMap.get(acrCL.ST_ACR_Order__c);
                             String bvContractId = contIds.get(acrCL.Contract__c);
                             if(bvcOrderId!=null && bvcOrderId!='')
                             {
                                 singleRecord.BVCOrder__c= bvcOrderId;                            
                                 singleRecord.BVC_Contract__c = bvContractId;
                                 singleRecord.Migrated_ACR_Consumption__c=acrCL.Id; // mapping migrated Id
                                 singleRecord.Account__c = acrCL.Customer_Account__c;
                                 
                                 singleRecord.Contract_Date_From__c = acrCL.Contract_Date_From__c;
                                 singleRecord.Contract_Date_To__c = acrCL.Contract_Date_To__c;
                                 // singleRecord. = acrCL.Product__c;
                                 singleRecord.Adjustment_to_Contract_Amount__c = acrCL.Adjustment_to_Contract_Amount__c;
                                 singleRecord.Adjusted_Contract_Amount__c = acrCL.Adjusted_Contract_Amount__c;
                                 singleRecord.Shipper_PAN__c = acrCL.Shipper_PAN__c;
                                 singleRecord.Consignee_Name__c = acrCL.Consignee_Name__c;
                                 singleRecord.Minimum_Freight__c = acrCL.Minimum_Freight__c;
                                 // singleRecord = acrCL.Order_Product__c;
                                 singleRecord.Bill_To_Account__c = acrCL.Bill_To_Account__c;
                                 if(acrCL.Bill_To_Address__c!=null)
                                 {
                                     singleRecord.Bill_To_Address__c = acrCL.Bill_To_Address__c;
                                 }
                                 
                                 singleRecord.BVC_Branch__c = acrCL.BVC_Branch__c;
                                 if(acrCL.Shipment__c!=null)
                                 {
                                     singleRecord.Shipment__c = acrCL.Shipment__c;
                                 }
                                 
                                 singleRecord.Shipment_Number__c = acrCL.Shipment_Number__c;
                                 singleRecord.Gross_Weight_UOM__c = acrCL.Gross_Weight_UOM__c;
                                 singleRecord.Gross_Weight_GMS__c = acrCL.Gross_Weight_GMS__c;
                                 // singleRecord.Gross_Weight__c = acrCL.Gross_Weight_Kg__c;
                                 singleRecord.Gross_Weight__c = acrCL.Gross_Weight__c;
                                 singleRecord.Net_Weight__c = acrCL.Net_Weight__c;
                                 singleRecord.Net_Weight_UOM__c = acrCL.Net_Weight_UOM__c;
                                 singleRecord.Net_Weight_GMS__c = acrCL.Net_Weight_GMS__c;
                                 // singleRecord.Account__c = acrCL.Net_Weight_kg__c;
                                 singleRecord.Liability_Cover_By_BVC__c = acrCL.Liability_Cover_By_BVC__c;
                                 singleRecord.Status__c = acrCL.Status__c;
                                 singleRecord.Offline_Charges__c = acrCL.Offline_Charges__c;
                                 singleRecord.Liability_charges__c = acrCL.Liability_charges__c;
                                 singleRecord.Fuel_Surcharge__c = acrCL.Fuel_Surcharge__c;
                                 singleRecord.Consumption__c = acrCL.Consumption__c;
                                 singleRecord.Total_Charge__c = acrCL.Total_Charge__c;
                                 singleRecord.No_Of_Packages__c = acrCL.No_Of_Packages__c;
                                 singleRecord.Contract_Amount__c = acrCL.Contract_Amount__c;
                                 singleRecord.Contract_Balance__c = acrCL.Contract_Balance__c;
                                 //  singleRecord.Account__c = acrCL.Customer_Account__c;
                                 singleRecord.Shipment_Date__c = acrCL.Shipment_Date__c;
                                 singleRecord.Shipper_Name__c = acrCL.Shipper_Name__c;
                                 singleRecord.Consignee_PAN__c = acrCL.Consignee_PAN__c;
                                 singleRecord.Freight_Charges__c = acrCL.Freight_Charges__c;
                                 singleRecord.Fuel_Charges__c = acrCL.Fuel_Charges__c;
                                 singleRecord.Weight_Charges__c = acrCL.Weight_Charges__c;
                                 singleRecord.Universe_Cost_Charge__c = acrCL.Universe_Cost_Charge__c;
                                 singleRecord.Holiday_Charges__c = acrCL.Holiday_Charges__c;
                                 singleRecord.BVC_Valuation_Charges__c = acrCL.BVC_Valuation_Charges__c;
                                 singleRecord.Indirect_Location__c = acrCL.Indirect_Location__c;
                                 singleRecord.Remote_Location__c = acrCL.Remote_Location__c;
                                 singleRecord.Fidelity_Liability__c = acrCL.Fidelity_Liability__c;
                                 singleRecord.Subrogation_Liability__c = acrCL.Subrogation_Liability__c;
                                 singleRecord.Destination_Address__c = acrCL.Destination_Address__c;
                                 singleRecord.Destination_type__c = acrCL.Destination_type__c;
                                 // singleRecord.Destination_City__c = acrCL.Destination_City__c;
                                 singleRecord.Origin_Address__c = acrCL.Origin_Address__c;
                                 singleRecord.Origin_Type__c = acrCL.Origin_Type__c;
                                 singleRecord.Confirmed_By_Name__c = acrCL.Confirmed_By_Name__c;
                                 singleRecord.Shipment_Value__c = acrCL.Shipment_Value__c;
                                 singleRecord.Product_Description__c = acrCL.Product_Description__c;
                                 
                                 bvcAcrCToInsert.add(singleRecord); 
                             }

                         }
                         try
                         {
                             System.debug('Line 152 bvcAcrCToInsert:'+bvcAcrCToInsert);
                            // upsert bvcAcrCToInsert;
                             List<Database.UpsertResult> upsertResults1 = Database.upsert(bvcAcrCToInsert, false);
                             ContractToBVCContractMigrationHelper.MigratedLogGeneration(upsertResults1,null,bvcAcrCToInsert,null,'ACR Consumption','BVC ACR Consumption'); 
                             // Generate OrderProducts
                             ContractMigrationHelper.MigrateOrderProducts(orderMap);
                             // creating Invoices from BVC Contract
                             /*
                             InvoiceMigrationWithOrder invOrdBatch =  new InvoiceMigrationWithOrder(orderMap);
                             database.executeBatch(invOrdBatch,10);
							
                         }catch(Exception e)
                         {
                             System.debug('156 Error insert bvcOrders :'+e.getMessage());
                         }
                     }catch(Exception e){
                         System.debug('159 Error insert bvcOrders :'+e.getMessage());
                     }
                     
                    }                 
                }             
            }
            else
            {
                System.debug('170 Withour Orders');
                // inserting ST_ACR_Consumption__c
                List<BVC_ACR_Consumption__c> bvcAcrCToInsert = new List<BVC_ACR_Consumption__c>();
                for(ST_ACR_Consumption__c acrCL:acrConsList)
                {
                    System.debug('Line 169 acrCL:'+acrCL.ST_ACR_Order__c);
                    BVC_ACR_Consumption__c singleRecord = new BVC_ACR_Consumption__c();
                    // String bvcOrderId = orderMap.get(acrCL.ST_ACR_Order__c);
                    String bvContractId = contIds.get(acrCL.Contract__c);
                    
                    // singleRecord.BVCOrder__c= bvcOrderId;                            
                    singleRecord.BVC_Contract__c = bvContractId;
                    
                    singleRecord.Account__c = acrCL.Customer_Account__c;
                    singleRecord.Migrated_ACR_Consumption__c=acrCL.Id; // mapping migrated Id
                    singleRecord.Contract_Date_From__c = acrCL.Contract_Date_From__c;
                    singleRecord.Contract_Date_To__c = acrCL.Contract_Date_To__c;
                    // singleRecord. = acrCL.Product__c;
                    singleRecord.Adjustment_to_Contract_Amount__c = acrCL.Adjustment_to_Contract_Amount__c;
                    singleRecord.Adjusted_Contract_Amount__c = acrCL.Adjusted_Contract_Amount__c;
                    singleRecord.Shipper_PAN__c = acrCL.Shipper_PAN__c;
                    singleRecord.Consignee_Name__c = acrCL.Consignee_Name__c;
                    singleRecord.Minimum_Freight__c = acrCL.Minimum_Freight__c;
                    // singleRecord = acrCL.Order_Product__c;
                    singleRecord.Bill_To_Account__c = acrCL.Bill_To_Account__c;
                    singleRecord.Bill_To_Account__c = acrCL.Bill_To_Account__c;
                    if(acrCL.Bill_To_Address__c!=null)
                    {
                        singleRecord.Bill_To_Address__c = acrCL.Bill_To_Address__c;
                    }
                    
                    singleRecord.BVC_Branch__c = acrCL.BVC_Branch__c;
                    if(acrCL.Shipment__c!=null)
                    {
                        singleRecord.Shipment__c = acrCL.Shipment__c;
                    }
                    singleRecord.Shipment_Number__c = acrCL.Shipment_Number__c;
                    singleRecord.Gross_Weight_UOM__c = acrCL.Gross_Weight_UOM__c;
                    singleRecord.Gross_Weight_GMS__c = acrCL.Gross_Weight_GMS__c;
                    // singleRecord.Gross_Weight__c = acrCL.Gross_Weight_Kg__c;
                    singleRecord.Gross_Weight__c = acrCL.Gross_Weight__c;
                    singleRecord.Net_Weight__c = acrCL.Net_Weight__c;
                    singleRecord.Net_Weight_UOM__c = acrCL.Net_Weight_UOM__c;
                    singleRecord.Net_Weight_GMS__c = acrCL.Net_Weight_GMS__c;
                    // singleRecord.Account__c = acrCL.Net_Weight_kg__c;
                    singleRecord.Liability_Cover_By_BVC__c = acrCL.Liability_Cover_By_BVC__c;
                    singleRecord.Status__c = acrCL.Status__c;
                    singleRecord.Universe_Cost_Charge__c = acrCL.Universe_Cost_Charge__c;
                    singleRecord.Consumption__c = acrCL.Consumption__c;
                    singleRecord.Total_Charge__c = acrCL.Total_Charge__c;
                    singleRecord.Docket_Charges__c = acrCL.Docket_Charges__c;
                    singleRecord.No_Of_Packages__c = acrCL.No_Of_Packages__c;
                    singleRecord.Contract_Amount__c = acrCL.Contract_Amount__c;
                    singleRecord.Contract_Balance__c = acrCL.Contract_Balance__c;
                    //  singleRecord.Account__c = acrCL.Customer_Account__c;
                    singleRecord.Shipment_Date__c = acrCL.Shipment_Date__c;
                    singleRecord.Shipper_Name__c = acrCL.Shipper_Name__c;
                    singleRecord.Consignee_PAN__c = acrCL.Consignee_PAN__c;
                    singleRecord.Freight_Charges__c = acrCL.Freight_Charges__c;
                    singleRecord.Fuel_Charges__c = acrCL.Fuel_Surcharge__c;
                    singleRecord.Weight_Charges__c = acrCL.Weight_Charges__c;
                    singleRecord.Destination_Address__c = acrCL.Destination_Address__c;
                    singleRecord.Destination_type__c = acrCL.Destination_type__c;
                    // singleRecord.Destination_City__c = acrCL.Destination_City__c;
                    singleRecord.Origin_Address__c = acrCL.Origin_Address__c;
                    singleRecord.Origin_Type__c = acrCL.Origin_Type__c;
                    singleRecord.Confirmed_By_Name__c = acrCL.Confirmed_By_Name__c;
                    singleRecord.Shipment_Value__c = acrCL.Shipment_Value__c;
                    singleRecord.Product_Description__c = acrCL.Product_Description__c;
                    
                    bvcAcrCToInsert.add(singleRecord);
                }
                try
                {
                    System.debug('Line 228 bvcAcrCToInsert:'+bvcAcrCToInsert);
                    // upsert bvcAcrCToInsert;
					List<Database.UpsertResult> upsertResults = Database.upsert(bvcAcrCToInsert, false);
                	ContractToBVCContractMigrationHelper.MigratedLogGeneration(upsertResults,null,bvcAcrCToInsert,null,'ACR Consumption','BVC ACR Consumption');
                }catch(Exception e)
                {
                    System.debug('223 Error insert bvcOrders :'+e.getMessage());
                }     
            }
            
        }        
    }

public static void MigrateOrderProducts(Map<String,String> orderMap)
{
    System.debug('Line nO 288 MigrateOrderProducts');
    if(orderMap.size()>0)
    {
        List<OrderItem> OrderItemsList = [select Id,X18_Digit_ID__c,ACR_Contracted_Price__c,ST_ACR_Contracted_Price__c,
                                          ACR_Package_type__c,ST_Package_Type__c,ACR_Standard_Price__c,
                                          ST_ACR_Standard_Price__c,ACR_type__c,SBQQ__Activated__c,
                                          SBQQ__Status__c,SBQQ__Asset__c,AvailableQuantity,
                                          BATHeSHIPChargesMap__c,blng__BillThroughDateOverride__c,blng__BillableUnitPrice__c,
                                          blng__BilledAmountwithouttax__c,blng__BilledTax__c,blng__BillingAccount__c,
                                          SBQQ__BillingFrequency__c,blng__BillingGLRule__c,blng__BillingGLTreatment__c,
                                          blng__BillingRule__c,blng__BillingTreatment__c,SBQQ__BillingType__c,
                                          SBQQ__BlockPrice__c,SBQQ__BookingsIndicator__c,SBQQ__BundleRoot__c,
                                          BVC_Branch__c,BVC_Entity__c,BVC_Service__c,
                                          BVC_Valuation_Charges__c,blng__CanceledBillings__c,BVC_CB_CGSTAmount__c,
                                          BVC_CB_CGSTTaxRate__c,BVC_CB_ChargeAmount__c,BVC_CB_ChargeCode__c,
                                          BVC_CB_ChargeDescription__c,BVC_CB_ChargeType__c,SBQQ__ChargeType__c,
                                          BVC_CB_COA_BRANCH__c,BVC_CB_COAENTITY__c,BVC_CB_COA_EXHIBITION_CODE__c,
                                          BVC_CB_COA_INTERCOMPANY__c,BVC_CB_COA_PRODUCT__c,BVC_CB_COA_REVENUE_COST_CENTRE__c,
                                          BVC_CB_COA_REVENUE_SUB_ACCOUNT__c,BVC_CB_COA_REVENUE_ACCOUNT_CODE__c,ST_Commodity_Type__c,
                                          Confirmation_By_Name__c,Confirmation_Email_ID__c,Confirmation_Reference__c,
                                          Confirmed_By_Mobile__c,Consignee_Name__c,Consignee_PAN__c,
                                          SBQQ__Contract__c,SBQQ__ContractAction__c,SBQQ__Contracted__c,
                                          Contracted_Offline_Charge__c,SBQQ__ContractingMethod__c,BVC_CB_CreatedBy__c,
                                          CreatedById,BVC_CB_CreatedByDatetime__c,ST_Customer_Product_Category__c,
                                          SBQQ__DefaultSubscriptionTerm__c,Delivery_Date_and_Time__c,ST_Destination__c,
                                          Destination_Address__c,Destination_City__c,Destination_Pin_Code__c,
                                          Destination_State__c,Destination_Type__c,SBQQ__DiscountSchedule__c,
                                          Docket_Charges__c,EndDate,SBQQ__TaxAmount__c ,
                                          Exhibition__c,ST_Exhibition__c,BVC_CB_ExportPreTaxBillID__c,
                                          blng__FinanceBookAccounting__c,Freight_Charges__c,ST_Freight_on_Invoice_Value__c,
                                          Fuel_Charges__c,Fuel_Surcharge__c,SBQQ__UnproratedNetPrice__c,
                                          Gross_Weight__c,ST_Gross_Weight_Kg__c,Gross_Weight_Slabs__c,
                                          ST_Gross_Weight_Slabs__c,Gross_Weight_UOM__c,Gross_Weight_gms__c,
                                          blng__GroupId__c,blng__GroupQuantity__c,blng__GroupUnitPrice__c,
                                          Handling_Charges_Inbound__c,Handling_Charges_Outbound__c,blng__HoldBilling__c,
                                          Holiday_Charges__c,BVC_CB_HSNCODE__c,BVC_CB_Id__c,
                                          BVC_CB_IGSTAmount__c,BVC_CB_IGSTTaxRate__c,BVC_CB_ImportPreTaxBillID__c,
                                          blng__IncludedUsage__c,Initiator_Email__c,Initiator_Mobile__c,
                                          Initiator_Name__c,Initiator_PAN__c,blng__InvoiceGrouping__c,/*
                                          blng__InvoiceGroupId__c,blng__InvoiceRun__c,blng__InvoiceRunProcessingStatus__c,
                                          blng__InvoiceRunStartDate__c,blng__InvoiceRunStatusIndex__c,BVC_CB_Invoice_Type__c,
                                          ST_Invoice_Value__c,BVC_CB_InvoiceType__c,IsOfflineLocation__c,
                                          blng__LastChargeToDate__c,blng__LastInvoiceTargetDate__c,LastModifiedById,
                                          BVC_CB_LastModifiedby__c,blng__LegalEntity__c,blng__LegalEntityReference__c,
                                          Liability_Charges__c,Liability_Cover_By_BVC__c,ST_Liability_Coverage__c,
                                          Liability_Coverage_Discount_Percent__c,Liability_Coverage__c,blng__Asset__c,
                                          Description,BVC_CB_LINE_NUMBER__c,BVC_CB_LineTotal__c,
                                          BVC_CB_LINEUOMCODE__c,ListPrice,ST_Max_Gross_Weight__c, 
                                          Max_Slab_Rate__c,ST_Min_Gross_Weight__c,ST_Minimum_Freight__c,
                                          BVC_CB_ModifiedDatetime__c,BVC_CB_NatureOfService__c,Net_Weight__c,
                                          Net_Weight_UOM__c,Net_Weight_gms__c,blng__NextBillingDate__c,
                                          blng__NextChargeDate__c,Non_ACR_Contracted_Price__c,Non_ACR_Standard_Price__c,
                                          BVC_CB_NONTAXVALUE__c,Number_of_Packages__c,ST_Offline_Charge__c,
                                          ST_Opt_For_Liability_Coverage__c,BVC_CB_OracleGLCode__c,BVC_CB_OracleItemCode__c,
                                          OrderId,SBQQ__OrderProductBookings__c,Order_Product_Code__c,
                                          OrderItemNumber,SBQQ__OrderedQuantity__c,ST_Origin__c,
                                          Origin__c,Origin_Address__c,Origin_Address_Name__c,
                                          Origin_City__c,Origin_Destination_Pair__c,Origin_PinCode__c,
                                          Origin_State__c,Origin_Type__c,OriginalOrderItemId,
                                          blng__OverrideBillableUnitPrice__c,blng__OverrideInitialRevenueEndDate__c,blng__OverrideInitialRevenueStartDate__c,
                                          blng__OverrideNextBillingDate__c,Payment_Date__c,Payment_Received__c,
                                          Payment_Reference__c,blng__PendingBillings__c,PickUp_Date__c,
                                          PickUp_Date_and_Time__c,SBQQ__PriceDimension__c,SBQQ__PriceSchedule__c,
                                          SBQQ__PricingMethod__c,Product2Id,Product_Description__c,
                                          SBQQ__ProductSubscriptionType__c,SBQQ__ProrateMultiplier__c,Quantity,
                                          SBQQ__QuoteLine__c,SBQQ__QuotedListPrice__c,SBQQ__QuotedQuantity__c,
                                          ST_Rate_Amount__c,ST_Rate_UOM__c,BVC_CB_ReceiptDate__c,
                                          BVC_CB_ReceiptNo__c,BVC_CB_Remarks__c,SBQQ__RequiredBy__c,
                                          blng__AllocatedRevenueAmount__c,blng__RevenueExpectedAmount__c,blng__RevenueLiabilityAmount__c,
                                          blng__RevenueMostLikelyAmount__c,blng__RevenueRecognitionRule__c,blng__RevenueScheduleStatus__c,
                                          SBQQ__RevisedOrderProduct__c,BVC_CB_SAC__c,BVC_CB_SalesforceCharge__c,
                                          Secure_Logistics_Charges__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,
                                          SBQQ__DimensionType__c,BVC_CB_SGSTAmount__c,BVC_CB_SGSTTaxRate__c,
                                          Shipment__c,Shipment_Date__c,Shipment_Number__c,
                                          Shipment_Type__c,Shipment_Value__c,Shipper_Name__c,
                                          Shipper_PAN__c,SBQQ__ShippingAccount__c,ServiceDate,
                                          SBQQ__Subscription__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c,
                                          SBQQ__SubscriptionType__c,blng__TaxStatus__c,blng__TaxCity__c,
                                          SBQQ__TaxCode__c,blng__TaxCountry__c,blng__TaxCounty__c,blng__TaxErrorMessage__c,
                                          blng__TaxGLRule__c,blng__TaxGLTreatment__c,blng__TaxPercentageApplied__c,
                                          blng__TaxZipCode__c,blng__TaxRule__c,blng__TaxState__c,
                                          blng__TaxStreet__c,blng__TaxStreet2__c,
                                          blng__TaxTreatment__c,BVC_CB_TAXABLEVALUE__c,BVC_CB_TaxCalculated__c,
                                          BVC_CB_TaxCalculatedINR__c,BVC_CB_TaxCategory__c,SBQQ__TermDiscountSchedule__c,
                                          blng__TerminatedBillings__c,SBQQ__TerminatedDate__c,blng__TotalBilling__c,
                                          Total_Charges__c,Commission_Charges__c,Additional_Charges_eSHIP__c,
                                          COD_Charges_eSHIP__c,Freight_Charges_eSHIP__c,Fuel_Surcharges_eSHIP__c,
                                          Liability_Charges_eSHIP__c,Weight_Charges_eSHIP__c,Total_Freight__c,Logistics_Charges__c,
                                          TotalPrice,BVC_CB_TotalItemValue__c,blng__UniqueId__c,
                                          UnitPrice,Universe_Cost_Charge__c,SBQQ__UpgradedSubscription__c,
                                          blng__UsageFloorQuantity__c,BVC_CB_UTGSTAmount__c,BVC_CB_UTGSTTaxRate__c,Vaulting_Charges__c,
                                          Weight_Charges__c,Your_Reference_Number__c 
                                          from OrderItem where OrderId IN : orderMap.keySet()];
        System.debug('381 OrderItemsList.size() :'+OrderItemsList.size());
        
        if(OrderItemsList.size()>0)
        {
            List<BVC_Order_Product__c> bvcOrderProductList = new List<BVC_Order_Product__c>();
            for(OrderItem o:OrderItemsList)
            {
                BVC_Order_Product__c bvcOrderProduct = new BVC_Order_Product__c();
                String bvcOrderId = null;
                bvcOrderId = orderMap.get(o.OrderId);
                if(bvcOrderId!=null)
                {                
                    bvcOrderProduct.BVCOrder__c = bvcOrderId;   
                    bvcOrderProduct.Migrated_OrderItem__c = o.Id;	// Mapping Migrated Id
                    bvcOrderProduct.Quantity__c =  o.Quantity;
                    bvcOrderProduct.Origin_Address_Name__c =  o.Origin_Address_Name__c;
                    bvcOrderProduct.Activated__c =  o.SBQQ__Activated__c;
                    // bvcOrderProduct. =  o.SBQQ__Status__c;
                    bvcOrderProduct.Hold_Billing__c =  o.blng__HoldBilling__c;
                    bvcOrderProduct.Total_Price__c =  o.TotalPrice;
                    bvcOrderProduct.Charge_Type__c =  o.SBQQ__ChargeType__c;
                    bvcOrderProduct.ACR_Contracted_Price__c =  o.ACR_Contracted_Price__c;
                    bvcOrderProduct.ACR_Standard_Price__c =  o.ST_ACR_Standard_Price__c;
                    bvcOrderProduct.Invoice_Group_ID__c =  o.blng__InvoiceGroupId__c;
                    bvcOrderProduct.Invoice_Group__c =  o.blng__InvoiceGrouping__c;
                    // bvcOrderProduct. =  o.blng__InvoiceRunProcessingStatus__c;
                    bvcOrderProduct.BVC_Branch__c =  o.BVC_Branch__c;
                    bvcOrderProduct.Non_ACR_Contracted_Price__c =  o.Non_ACR_Contracted_Price__c;
                    bvcOrderProduct.Fuel_Surcharge__c = o.Fuel_Surcharge__c;
                    bvcOrderProduct.Liability_Charges__c = o.Liability_Charges__c;
                    bvcOrderProduct.BVC_Valuation_Charges__c = o.BVC_Valuation_Charges__c;
                    bvcOrderProduct.Universe_Cost_Charge__c = o.Universe_Cost_Charge__c;
                    bvcOrderProduct.Non_ACR_Standard_Price__c =  o.Non_ACR_Standard_Price__c;
                    bvcOrderProduct.Freight_Charges__c =  o.Freight_Charges__c;
                    bvcOrderProduct.Docket_Charges__c = o.Docket_Charges__c;
                    bvcOrderProduct.Fuel_Charges__c = o.Fuel_Charges__c;
                    bvcOrderProduct.Holiday_Charges__c = o.Holiday_Charges__c;
                    bvcOrderProduct.Offline_Charge__c =  o.ST_Offline_Charge__c;
                    bvcOrderProduct.Weight_Charges__c = o.Weight_Charges__c;
                    bvcOrderProduct.Total_Charges__c =  o.Total_Charges__c;
                    // bvcOrderProduct. =  o.ServiceDate;
                    bvcOrderProduct.End_Date__c =  o.EndDate; 
                    bvcOrderProduct.Billable_Unit_Price__c =  o.blng__BillableUnitPrice__c;
                    bvcOrderProduct.Unit_Price__c =  o.UnitPrice;
                    bvcOrderProductList.add(bvcOrderProduct);                    
                }
                

            }
            if(bvcOrderProductList.size()>0)
            {
                try
                {
                    System.debug('Line No 426 Before Upsert');
                    // upsert bvcOrderProductList;
                    List<Database.UpsertResult> upsertResults = Database.upsert(bvcOrderProductList, false);
					ContractToBVCContractMigrationHelper.MigratedLogGeneration(upsertResults,null,null,bvcOrderProductList,'Order Product','BVC Order Product');
                    System.debug('Line No 428 After Upsert');
                }catch(Exception e)
                {
                    System.debug('Line No 431 bvcOrderProductList Error :'+e.getMessage());
                }
            }
        }
    }
    
}*/
}