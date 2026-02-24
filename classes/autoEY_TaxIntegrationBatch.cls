public class autoEY_TaxIntegrationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

   List<Id> invoiceIds;

    public autoEY_TaxIntegrationBatch(List<Id> invoiceIds) {
        this.invoiceIds = invoiceIds;
    }
	
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('for checking this.invoiceIds '+this.invoiceIds);
        return Database.getQueryLocator([SELECT Is_Shipment_Rebilled__c,Account__r.Name,Account__r.ShippingAddress,BVC_CB_Is_CB_Invoice__c, 
                                         Net_Weight__c,BVCOrder__r.Billing_Address__c, Net_Weight_UOM__c,ST_Tax_Percent__c , BVCQuote__c, InvoiceDate__c, 
                                           Email_Recepients__c, Total_Docket_Charge_Tax__c, Total_Commission_Tax__c, total_Credit_Payment__c,
                                           Gross_Weight_UOM__c, Gross_Weight__c, Operation_Type__c, Business_Type__c, Attachment_Date_Time__c,
                                           TDS_value__c, Internal_Remarks__c, ACR_Cancelled__c, No_Of_Pkgs__c,BVC_CB_AIR_SEA__c, 
                                           Total_Offline_Charges__c, Total_Liability_Charge__c, Total_Freight_Charges__c, TaxAmount__c, Subtotal__c,
                                           Shipping_Note_Number__c, Shipping_Date__c, state_code__c, Shipment__c, QRCode__c, QR_Code_URL__c, BVCOrder__c,
                                           Origin_Address__c, IRN_QR_CODE_IMAGE__c, Invoice_PDF_Attachment__c, Invoice_PDF__c, Invoice_Number__c,
                                           Impact_Amount__c, COA_Intercompany__c, COA_Exhibition_Code__c, Exhibition__c, BVC_Entity__c,
                                           BVC_Billing_Entity__c, Bill_To_Contact__c, Billing_Address__c, Bill_From_Location__c, BVC_Branch__c,
                                           Balance_Amount__c, Total_Amount_With_Tax__c, Allocations_Against_Invoice__c, Advance_Payment_Received__c, 
                                           Actual_Payment_Collected__c, Account__c, Annexure_Report__c, RDS_Status__c, ACK_Number__c, X18_Digit_ID__c,
                                           Total_Weight_Charge_Tax__c, QR_Image_URL__c, Total_Fuel_Surcharge__c, IRN__c, Invoice_Type__c,ACK_Date_Time__c, 
                                           Invoice_Cancellation_Status__c, Invoice_Public_Link__c, Total_BVC_Valuation_Charges__c, Total_Weight_Charges__c, 
                                           Oracle_Site_ID__c, EY_Tax_Calculation_Status__c, State_Of_Supply__c, Place_Of_Supply_State_Code__c,
                                           Tax_Integration_Error_Message__c, Short_URL__c, Total_Fuel_Charges__c, Razorpay_Id__c, Type_of_Invoice__c,
                                           Total_Secure_Logistics_Tax_Amount__c, Total_Logistics_Tax_Amount__c, Invoice_AttachmentId__c, Invoice_Date__c,
                                           Total_BVC_Valuation_Charge_Tax__c, ST_Invoice_Series__c, Total_Fuel_surcharge_Tax__c, Place_of_Supply_City__c, 
                                           Total_Vaulting_Charges__c, Total_Offline_Tax__c, Total_Universe_Cost_Charge__c, Status__c, 
                                           Tax_Status__c, Tax_Percent__c,  Oracle_Integration_Status__c, Total_Freight_Tax__c,
                                           Total_Holiday_Charge_Tax__c, Advance_Payment_Created__c, Razorpay_Payment_Received__c, Total_Fuel_Charge_Tax__c, 
                                           Invoice_datetime__c, Total_Vaulting_tax__c, Total_Logistics_Charges__c, Total_Holiday_Charges__c, 
                                           Total_Liability_Charge_Tax__c, Signed_QR_code_URL__c, Total_Universe_Cost_Charge_Tax__c, Place_Of_Supply_State__c,
                                           Send_Status__c, TDS_Payment_Created__c, Place_Of_Supply__c, NumberToWord__c, Invoice_Doc_URL__c, Due_Date__c,
                                           Destination_Address__c,Destination_Address__r.ADDRESS1__c,Destination_Address__r.ADDRESS2__c,Destination_Address__r.CITY__c,
                                           Destination_Address__r.STATE__c,Destination_Address__r.COUNTRY__c,Consignee_Name__c,Signed_IRN_Text__c,
                                           Billing_Address__r.PINCODE__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.COUNTRY__c,
                                           Billing_Address__r.GST_Registered_Status__c,Billing_Address__r.Dealer_Type__c,Billing_Address__r.GSTIN__c,Account__r.PAN_Number_of_Entity__c,
                                           BVC_Branch__r.BVC_Entity__r.PAN__c,BVC_Branch__r.BVC_Entity__r.Name,BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_2__c,
                                           BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Line_1__c,BVC_Billing_Entity__r.GSTIN__c,
                                           origin_Address__r.STATE__c,origin_Address__r.City__c,Origin_Address__r.COUNTRY__c,BVCOrder__r.Business_Type__c,
                                           BVC_Branch__r.Hub_State__c,BVC_Branch__r.Hub_Address_Line_1__c,BVC_Branch__r.Hub_Address_Line_2__c,BVC_Branch__r.Name,
                                           BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c,Total_Docket_Charges__c,
                                           BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_City__c,Total_Commission_Charges__c,Total_Secure_Logistics_Charges__c,
                                           BVC_Billing_Entity__r.GSTIN_Principle_Business_Address_State__c,BVCOrder__r.Billing_Address__r.CITY__c,BVCOrder__r.BillingAccount__r.Name,
                                           BVCOrder__r.Account__r.Name,Destination_Address__r.PINCODE__c,Notes__c, PreTaxBill__c, BVC_CB_BOS_Bill_Amount__c, 
                                              BVC_CB_CB_BOS_Inv_Seriess__c, BVC_CB_CB_Comm_Inv_Amount__c, BVC_CB_CB_Comm_Inv_Series__c,
                                              BVC_CB_ROUND_OFF__c, BVC_CB_CB_Tax_Inv_Amount__c, BVC_CB_CB_Tax_Inv_Series__c, Total_SGST_Amount__c,
                                              Payments__c, Payment_Status__c, AR_Status__c, Email_PDF_Date__c, BVC_Invoice_Run__c, Total_IGST_Amount__c, 
                                              Total_Taxable_Amount__c, customer_phone__c, BVCPayment__c, Payments1__c, BVC_Payment_Allocation_Invoice__c,
                                              Balance_AMOUNT1__c, BVC_Product__c, Oracle_Integration_Error_Log__c, BVC_CB_COA_SOURCE_CODE__c, 
                                              BVC_CB_CONTENT__c, SBNo__c, BVC_CB_BE_No__c, SBDate__c, BVC_CB_BE_Date__c, MAWB_No__c, MAWB_Date__c, 
                                              BVC_CB_HAWB_No__c, BVC_CB_HAWB_Date__c, BVC_CB_ERNo__c, BVC_CB_ERDate__c, Product_Code__c, Product_Name__c,
                                              Intercompany_Customer__c, BVC_CB_COA_Product_Code_CB__c, Batch_Source_Name__c, BVC_Billing_Entity_Migrated__c,
                                              Manual_Invoice__c, BVC_CB_Billing_Account_Address__c, BVC_CB_Billing_Account_Address_2__c, 
                                              BVC_CB_Billing_Account_2__c, COA_Product_Code__c, ACR_Product_Code__c, ACR_Product_Name__c,
                                              BVC_CB_Billing_GST_State_Code__c, BVC_CB_Billing_GSTIN__c, BVC_CB_Billing_OracleId__c,
                                              BVC_CB_Billing_Oracle_SiteId__c, BVC_CB_Billing_PAN__c, BVC_CB_Billing_SF_Customer__c,BVC_CB_Invoice_Type__c,
                                              BVC_CB_Billing_SF_Customer_Address__c, BVC_CB_Billing_State__c, BVC_CB_BillTo_Fields__c, BVC_CB_Bond_Date__c,
                                              Bond_No__c, BVC_CB_BOS_Invoice_No__c, BVC_CB_BOS_Round_Off__c, BVC_CB_Cash_Idf_Date__c, BVC_CB_Cash_Idf_No__c,
                                              BVC_CB_CB_BOC_Inv_Amount__c, BVC_CB_Invoice_Series__c, BVC_CB_Total_Amount__c, BVC_CB_CCDate__c, BVC_CB_CCNo__c,
                                              BVC_CB_CM_Bill_Amount__c, BVC_CB_CM_Invoice_No__c, BVC_CB_CM_Round_Off__c, BVC_CB_Created_By__c, BVC_CB_Created_By_Datetime__c,
                                              BVC_CB_Customer_Address__c, BVC_CB_Customer_GSTINNO__c, BVC_CB_Customer_Invoice_Date__c, BVC_CB_Customer_Invoice_Number__c, 
                                              BVC_CB_Customer_Invoice_Value_Currency__c, BVC_CB_Customer_Name__c, BVC_CB_Despatch__c, BVC_CB_Destination_Country_2__c, 
                                              BVC_CB_Destination_Port_2__c, BVC_CB_DestinationCountry__c, BVC_CB_DestinationPort__c, BVC_CB_DT_GR_FORM_NO__c, BVC_CB_EDFDate__c,
                                              BVC_CB_EDFNo__c, BVC_CB_ExportShipmentID__c, BVC_CB_FOBValue__c, BVC_CB_GrossWt__c, BVC_CB_GSTIN_Remarks__c, BVC_CB_IGM_Item_Date__c, 
                                              BVC_CB_IGM_Item_No__c, BVC_CB_Import_Shipment__c, BVC_CB_Invoice_Value__c, BVC_CB_IRN__c, BVC_CB_IRN_Date__c, BVC_CB_IsBosInvPosted__c,
                                              BVC_CB_IsCommInvPosted__c, BVC_CB_IsTaxPosted__c, BVC_CB_JOBDT__c, BVC_CB_JOB_NO__c, BVC_CB_Last_Modifiedby__c, BVC_CB_License_Date__c,
                                              BVC_CB_License_No__c, BVC_CB_lospCity__c, BVC_CB_lospColumn__c, BVC_CB_lospState__c, BVC_CB_lospStateCode__c, BVC_CB_lospTable__c,
                                              BVC_CB_MAWB_Date__c, BVC_CB_MAWB_No__c, BVC_CB_Modified_Datetime__c, BVC_CB_Net_Wt__c, BVC_CB_No_Of_Pkgs__c, BVC_CB_Operation_Type__c,
                                              BVC_CB_OracleID__c, BVC_CB_Oracle_SiteId__c, BVC_CB_Org_Branch_GST_State_Code__c, BVC_CB_Org_Branch_GSTIN__c, BVC_CB_Org_Branch_SF_ID__c,
                                              BVC_CB_Org_Branch_State__c, BVC_CB_Org_CINNO__c, BVC_CB_Org_PAN__c, BVC_CB_OrgBranchCode__c, BVC_CB_OrgBranchName__c, 
                                              BVC_CB_POS__c, BVC_CB_posColumn__c, BVC_CB_posTable__c, BVC_CB_Pre_Tax_Date__c, BVC_CB_Pre_Tax_No__c, BVC_CB_PreTaxBill__c, 
                                              BVC_CB_PreTaxInvoice_ID__c, BVC_CB_ProcessingDate__c, BVC_CB_QR_Code__c, BVC_CB_Remarks__c, BVC_CB_Remarks1__c,BVC_CB_Assessable_Value__c, 
                                              BVC_CB_SalesForceAddress__c, BVC_CB_SalesForceCustomerId__c, BVC_CB_SBDate__c, BVC_CB_SBNo__c, BVC_CB_Shipment_Date__c,
                                              BVC_CB_Shipment_No__c, BVC_CB_ShipTo_Fields__c, BVC_CB_SoldTo_Fields__c, BVC_CB_SOS__c, BVC_CB_SUPPLY_TYPE__c, BVC_CB_SupplyType__c,
                                              BVC_CB_Tariff_Name__c, BVC_CB_Tax_Bill_Amount__c, BVC_CB_Tax_Invoice_No__c, BVC_CB_Tax_Round_Off__c, BVC_CB_TemplateName__c,
                                              BVC_CB_Trade_Name__c, BVC_CB_TRANSACTION_CLASS__c, BVC_CB_BVC_VAMASHIP_ID__c, OS_Username__c, BVC_CB_Bond_No__c, BVC_CB_GR_FORM_NO__c,
                                              BVC_CB_Invoice_Value_INR__c, BVC_Shipment__c, BVC_CB_CUSTOMER_TRANSACTION_TYPE__c,  
                                           Name, Id 
                                           FROM BVCInvoice__c            								
                                           WHERE Id In :this.invoiceIds
        ]);
    }

    public void execute(Database.BatchableContext bc, List<BVCInvoice__c> scope) {
        System.debug('for checking scope '+scope);
        System.debug('for checking scope.size() '+scope.size());
            try {
                System.debug('for checking Calling autoEY_TaxIntegrationQueueable');
                System.enqueueJob(new autoEY_TaxIntegrationQueueable(scope));
            } catch(Exception e) {
                System.debug('for checking Tax_Integration_Error_Message__c '+e.getMessage());
                System.debug('for checking Tax_Integration_Error_Message__c on line number '+e.getLineNumber());
            }
        //update scope;
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}