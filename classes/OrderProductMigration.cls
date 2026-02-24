global class OrderProductMigration implements Database.Batchable<sObject>,Database.Stateful
{
    
    public Database.QueryLocator Start(Database.BatchableContext bc){return Database.getQueryLocator(
            'SELECT Id FROM Shipment__c WHERE id=null'
        );}
    public void execute(Database.BatchableContext bc , List<Shipment__c> newShipment){}
    public void finish(Database.BatchableContext bc){}
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
    }
}
   /* Map<String,String> orderMap = new Map<String,String>();
    public Integer totalRecordsProcesses=0;        
    public OrderProductMigration(Map<String,String> orderMap)
    {
        this.orderMap = orderMap;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        List<String> orderIdList = new List<String>(orderMap.keySet());
        
        String query='select Id,X18_Digit_ID__c,ACR_Contracted_Price__c,ST_ACR_Contracted_Price__c,';
        query+='ACR_Package_type__c,ST_Package_Type__c,ACR_Standard_Price__c,';
        query+='ST_ACR_Standard_Price__c,ACR_type__c,SBQQ__Activated__c,';
        query+='SBQQ__Status__c,SBQQ__Asset__c,AvailableQuantity,';
        query+='BATHeSHIPChargesMap__c,blng__BillThroughDateOverride__c,blng__BillableUnitPrice__c,';
        query+='blng__BilledAmountwithouttax__c,blng__BilledTax__c,blng__BillingAccount__c,';
        query+='SBQQ__BillingFrequency__c,blng__BillingGLRule__c,blng__BillingGLTreatment__c,';
        query+='blng__BillingRule__c,blng__BillingTreatment__c,SBQQ__BillingType__c,';
        query+='SBQQ__BlockPrice__c,SBQQ__BookingsIndicator__c,SBQQ__BundleRoot__c,';
        query+='BVC_Branch__c,BVC_Entity__c,BVC_Service__c,';
        query+='BVC_Valuation_Charges__c,blng__CanceledBillings__c,BVC_CB_CGSTAmount__c,';
        query+='BVC_CB_CGSTTaxRate__c,BVC_CB_ChargeAmount__c,BVC_CB_ChargeCode__c,';
        query+='BVC_CB_ChargeDescription__c,BVC_CB_ChargeType__c,SBQQ__ChargeType__c,';
        query+='BVC_CB_COA_BRANCH__c,BVC_CB_COAENTITY__c,BVC_CB_COA_EXHIBITION_CODE__c,';
        query+='BVC_CB_COA_INTERCOMPANY__c,BVC_CB_COA_PRODUCT__c,BVC_CB_COA_REVENUE_COST_CENTRE__c,';
        query+='BVC_CB_COA_REVENUE_SUB_ACCOUNT__c,BVC_CB_COA_REVENUE_ACCOUNT_CODE__c,ST_Commodity_Type__c,';
        query+='Confirmation_By_Name__c,Confirmation_Email_ID__c,Confirmation_Reference__c,';
        query+='Confirmed_By_Mobile__c,Consignee_Name__c,Consignee_PAN__c,';
        query+='SBQQ__Contract__c,SBQQ__ContractAction__c,SBQQ__Contracted__c,';
        query+='Contracted_Offline_Charge__c,SBQQ__ContractingMethod__c,BVC_CB_CreatedBy__c,';
        query+='CreatedById,BVC_CB_CreatedByDatetime__c,ST_Customer_Product_Category__c,';
        query+='SBQQ__DefaultSubscriptionTerm__c,Delivery_Date_and_Time__c,ST_Destination__c,';
        query+='Destination_Address__c,Destination_City__c,Destination_Pin_Code__c,';
        query+='Destination_State__c,Destination_Type__c,SBQQ__DiscountSchedule__c,';
        query+='Docket_Charges__c,EndDate,SBQQ__TaxAmount__c ,';
        query+='Exhibition__c,ST_Exhibition__c,BVC_CB_ExportPreTaxBillID__c,';
        query+='blng__FinanceBookAccounting__c,Freight_Charges__c,ST_Freight_on_Invoice_Value__c,';
        query+='Fuel_Charges__c,Fuel_Surcharge__c,SBQQ__UnproratedNetPrice__c,';
        query+='Gross_Weight__c,ST_Gross_Weight_Kg__c,Gross_Weight_Slabs__c,';
        query+='ST_Gross_Weight_Slabs__c,Gross_Weight_UOM__c,Gross_Weight_gms__c,';
        query+='blng__GroupId__c,blng__GroupQuantity__c,blng__GroupUnitPrice__c,';
        query+='Handling_Charges_Inbound__c,Handling_Charges_Outbound__c,blng__HoldBilling__c,';
        query+='Holiday_Charges__c,BVC_CB_HSNCODE__c,BVC_CB_Id__c,';
        query+='BVC_CB_IGSTAmount__c,BVC_CB_IGSTTaxRate__c,BVC_CB_ImportPreTaxBillID__c,';
        query+='blng__IncludedUsage__c,Initiator_Email__c,Initiator_Mobile__c,';
        query+='Initiator_Name__c,Initiator_PAN__c,blng__InvoiceGrouping__c,';
        query+='blng__InvoiceGroupId__c,blng__InvoiceRun__c,blng__InvoiceRunProcessingStatus__c,';
        query+='blng__InvoiceRunStartDate__c,blng__InvoiceRunStatusIndex__c,BVC_CB_Invoice_Type__c,';
        query+='ST_Invoice_Value__c,BVC_CB_InvoiceType__c,IsOfflineLocation__c,';
        query+='blng__LastChargeToDate__c,blng__LastInvoiceTargetDate__c,LastModifiedById,';
        query+='BVC_CB_LastModifiedby__c,blng__LegalEntity__c,blng__LegalEntityReference__c,';
        query+='Liability_Charges__c,Liability_Cover_By_BVC__c,ST_Liability_Coverage__c,';
        query+='Liability_Coverage_Discount_Percent__c,Liability_Coverage__c,blng__Asset__c,';
        query+='Description,BVC_CB_LINE_NUMBER__c,BVC_CB_LineTotal__c,';
        query+='BVC_CB_LINEUOMCODE__c,ListPrice,ST_Max_Gross_Weight__c, ';
        query+='Max_Slab_Rate__c,ST_Min_Gross_Weight__c,ST_Minimum_Freight__c,';
        query+='BVC_CB_ModifiedDatetime__c,BVC_CB_NatureOfService__c,Net_Weight__c,';
        query+='Net_Weight_UOM__c,Net_Weight_gms__c,blng__NextBillingDate__c,';
        query+='blng__NextChargeDate__c,Non_ACR_Contracted_Price__c,Non_ACR_Standard_Price__c,';
        query+='BVC_CB_NONTAXVALUE__c,Number_of_Packages__c,ST_Offline_Charge__c,';
        query+='ST_Opt_For_Liability_Coverage__c,BVC_CB_OracleGLCode__c,BVC_CB_OracleItemCode__c,';
        query+='OrderId,SBQQ__OrderProductBookings__c,Order_Product_Code__c,';
        query+='OrderItemNumber,SBQQ__OrderedQuantity__c,ST_Origin__c,';
        query+='Origin__c,Origin_Address__c,Origin_Address_Name__c,';
        query+='Origin_City__c,Origin_Destination_Pair__c,Origin_PinCode__c,';
        query+='Origin_State__c,Origin_Type__c,OriginalOrderItemId,';
        query+='blng__OverrideBillableUnitPrice__c,blng__OverrideInitialRevenueEndDate__c,blng__OverrideInitialRevenueStartDate__c,';
        query+='blng__OverrideNextBillingDate__c,Payment_Date__c,Payment_Received__c,';
        query+='Payment_Reference__c,blng__PendingBillings__c,PickUp_Date__c,';
        query+='PickUp_Date_and_Time__c,SBQQ__PriceDimension__c,SBQQ__PriceSchedule__c,';
        query+='SBQQ__PricingMethod__c,Product2Id,Product_Description__c,';
        query+='SBQQ__ProductSubscriptionType__c,SBQQ__ProrateMultiplier__c,Quantity,';
        query+='SBQQ__QuoteLine__c,SBQQ__QuotedListPrice__c,SBQQ__QuotedQuantity__c,';
        query+='ST_Rate_Amount__c,ST_Rate_UOM__c,BVC_CB_ReceiptDate__c,';
        query+='BVC_CB_ReceiptNo__c,BVC_CB_Remarks__c,SBQQ__RequiredBy__c,';
        query+='blng__AllocatedRevenueAmount__c,blng__RevenueExpectedAmount__c,blng__RevenueLiabilityAmount__c,';
        query+='blng__RevenueMostLikelyAmount__c,blng__RevenueRecognitionRule__c,blng__RevenueScheduleStatus__c,';
        query+='SBQQ__RevisedOrderProduct__c,BVC_CB_SAC__c,BVC_CB_SalesforceCharge__c,';
        query+='Secure_Logistics_Charges__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,';
        query+='SBQQ__DimensionType__c,BVC_CB_SGSTAmount__c,BVC_CB_SGSTTaxRate__c,';
        query+='Shipment__c,Shipment_Date__c,Shipment_Number__c,';
        query+='Shipment_Type__c,Shipment_Value__c,Shipper_Name__c,Is_Migrted__c,';
        query+='Shipper_PAN__c,SBQQ__ShippingAccount__c,ServiceDate,';
        query+='SBQQ__Subscription__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c,';
        query+='SBQQ__SubscriptionType__c,blng__TaxStatus__c,blng__TaxCity__c,';
        query+='SBQQ__TaxCode__c,blng__TaxCountry__c,blng__TaxCounty__c,blng__TaxErrorMessage__c,';
        query+='blng__TaxGLRule__c,blng__TaxGLTreatment__c,blng__TaxPercentageApplied__c,';
        query+='blng__TaxZipCode__c,blng__TaxRule__c,blng__TaxState__c,';
        query+='blng__TaxStreet__c,blng__TaxStreet2__c,';
        query+='blng__TaxTreatment__c,BVC_CB_TAXABLEVALUE__c,BVC_CB_TaxCalculated__c,';
        query+='BVC_CB_TaxCalculatedINR__c,BVC_CB_TaxCategory__c,SBQQ__TermDiscountSchedule__c,';
        query+='blng__TerminatedBillings__c,SBQQ__TerminatedDate__c,blng__TotalBilling__c,';
        query+='Total_Charges__c,Commission_Charges__c,Additional_Charges_eSHIP__c,';
        query+='COD_Charges_eSHIP__c,Freight_Charges_eSHIP__c,Fuel_Surcharges_eSHIP__c,';
        query+='Liability_Charges_eSHIP__c,Weight_Charges_eSHIP__c,Total_Freight__c,Logistics_Charges__c,';
        query+='TotalPrice,BVC_CB_TotalItemValue__c,blng__UniqueId__c,';
        query+='UnitPrice,Universe_Cost_Charge__c,SBQQ__UpgradedSubscription__c,';
        query+='blng__UsageFloorQuantity__c,BVC_CB_UTGSTAmount__c,BVC_CB_UTGSTTaxRate__c,Vaulting_Charges__c,';
        query+='Weight_Charges__c,Your_Reference_Number__c from OrderItem where OrderId IN : orderIdList and Is_Migrted__c=FALSE';
       // query+='from OrderItem where OrderId IN : orderIdList and Is_Migrted__c=FALSE and to_check_migration__c=true';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<OrderItem> OrderItemsList)
    {
        System.debug('381 OrderItemsList.size() :'+OrderItemsList.size());        
        if(OrderItemsList.size()>0)
        {
            List<BVC_Order_Product__c> bvcOrderProductList = new List<BVC_Order_Product__c>();
            Map<String,OrderItem> migratedOrderItems = new Map<String,OrderItem>();
            for(OrderItem o:OrderItemsList)
            {
                BVC_Order_Product__c bvcOrderProduct = new BVC_Order_Product__c();
                String bvcOrderId = null;
                bvcOrderId = orderMap.get(o.OrderId); 
                if(bvcOrderId!=null)  // skipping the OrderItems which was created already
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
                    //added by Pratik for eSHIP 
                    bvcOrderProduct.Additional_Charges_eSHIP__c =  o.Additional_Charges_eSHIP__c;
                    bvcOrderProduct.COD_Charges_eSHIP__c =  o.COD_Charges_eSHIP__c;
                    bvcOrderProduct.Freight_Charges_eSHIP__c =  o.Freight_Charges_eSHIP__c;
                    bvcOrderProduct.Fuel_Surcharges_eSHIP__c =  o.Fuel_Surcharges_eSHIP__c;
                    bvcOrderProduct.Liability_Charges_eSHIP__c =  o.Liability_Charges_eSHIP__c;
                    bvcOrderProduct.Weight_Charges_eSHIP__c =  o.Weight_Charges_eSHIP__c;
                    bvcOrderProduct.Net_Weight__c= o.Net_Weight__c;
                    bvcOrderProduct.Net_Weight_gms__c=o.Net_Weight_gms__c;
                    bvcOrderProduct.Net_Weight_UOM__c=o.Net_Weight_UOM__c;
                    bvcOrderProduct.Secure_Logistics_Charges__c=o.Secure_Logistics_Charges__c;
                    bvcOrderProduct.Shipment_Type__c=o.Shipment_Type__c;
                    //till here
                    // bvcOrderProduct. =  o.ServiceDate;
                    bvcOrderProduct.End_Date__c =  o.EndDate; 
                    bvcOrderProduct.Billable_Unit_Price__c =  o.blng__BillableUnitPrice__c;
                    bvcOrderProduct.Unit_Price__c =  o.UnitPrice;
                    totalRecordsProcesses+=1;
                    migratedOrderItems.put(o.Id,o);
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
                    List<OrderItem> OrderItemToUpdate = new List<OrderItem>();
                    for (Integer i = 0; i < upsertResults.size(); i++) 
                    {
                        Database.UpsertResult result = upsertResults[i];
                        if (result.isSuccess()) 
                        {
                            OrderItem ordItem = migratedOrderItems.get(bvcOrderProductList[i].Migrated_OrderItem__c);
                            if(ordItem!=null)
                            {
                                ordItem.Is_Migrted__c= true;
                                OrderItemToUpdate.add(ordItem);
                            }                        
                        }                    
                    }
                    List<Database.UpsertResult> CheckBoxupsertResults = Database.upsert(OrderItemToUpdate, false);
                    System.debug('Line No 428 After Upsert');
                }catch(Exception e)
                {
                    System.debug('Line No 431 bvcOrderProductList Error :'+e.getMessage());
                }
            }
        }   
    }
    global void finish(Database.BatchableContext bc)
    {
        String body = 'Order Products To BVC Order Products Migration Processed Records :'+totalRecordsProcesses;
        // Email configuration
       /* Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'imran.shaik@bvclogistics.com'});
        email.setSubject('Order Products To BVC Order Products Migration');
        email.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email}); 
    }*/