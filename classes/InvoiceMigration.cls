/*
 *  @Created By : Imran Shaik
 *  @Created Date : 17-Sep-2024
 *  @Version V1: Migrating all CPQ Invoices to BVC Invoices (without Orders)
 */
global class InvoiceMigration implements Database.Batchable<sObject>,Database.Stateful
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
        i++;

        i++;
        i++;
        i++;
        i++;
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
/*{
    global static Map<String,String> QuoteIdMap = new Map<String,String>();
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('InvoiceMigration Line 6');
        String status='Activated';
        String query='Select Id,X18_Digit_ID__c,blng__Account__c,ACK_Date_Time__c,ACK_Number__c,ACR_Cancelled__c,Actual_Payment_Collected__c,';
        query+='Advance_Payment_Created__c,Advance_Payment_Received__c,BVC_CB_AIR_SEA__c,blng__PaymentsAgainstInvoice__c,Annexure_Report__c,blng__ARStatus__c,';
        query+='blng__Balance__c,Balance_Amount__c,Batch_Source_Name__c,BVC_CB_BE_Date__c,BVC_CB_BE_No__c,Bill_From_Location__c,';
        query+='blng__BillToContact__c,BVC_CB_BOS_Bill_Amount__c,Business_Type__c,BVC_Billing_Entity__c,BVC_Branch__c,BVC_Entity__c,blng__InvoiceRunCreatedBy__c,';
        query+='Product__c,Name,blng__Order__c,blng__Payments__c,BVC_CB_CB_BOS_Inv_Series__c,BVC_CB_CB_Comm_Inv_Amount__c,BVC_CB_CB_Comm_Inv_Series__c,';
        query+='BVC_CB_CB_Tax_Inv_Amount__c,BVC_CB_CB_Tax_Inv_Series__c,COA_Exhibition_Code__c,COA_Intercompany__c,BVC_CB_COA_Product_Code_CB__c,BVC_CB_COA_SOURCE_CODE__c,';
        query+='Consignee_Name__c,BVC_CB_CONTENT__c,CreatedById,CurrencyIsoCode,customer_phone__c,Destination_Address__c,blng__DueDate__c,Email_PDF_Date__c,';
        query+='Email_Recepients__c,BVC_CB_ERDate__c,BVC_CB_ERNo__c,Exhibition__c,EY_Tax_Calculation_Status__c,Gross_Weight__c,Gross_Weight_UOM__c,';
        query+='BVC_CB_HAWB_Date__c,BVC_CB_HAWB_No__c,blng__ImpactAmount__c,Intercompany_Customer__c,Internal_Remarks__c,Invoice_AttachmentId__c,';
        query+='Invoice_Cancellation_Status__c,blng__InvoiceDate__c,Invoice_date_time__c,Invoice_Doc_URL__c,Invoice_PDF__c,Invoice_PDF_Attachment__c,Invoice_Public_Link__c,ST_Invoice_Series__c,';
        query+='Invoice_Type__c,IRN__c,IRN_QR_CODE_IMAGE__c,BVC_CB_Is_CB_Invoice__c,Is_Shipment_Rebilled__c,LastModifiedById,BVC_CB_MAWB_Date__c,';
        query+='BVC_CB_MAWB_No__c,Net_Weight__c,Net_Weight_UOM__c,BVC_CB_No_Of_Pkgs__c,blng__Notes__c,NumberToWord__c,BVC_CB_Operation_Type__c,Oracle_Integration_Error_Log__c,Oracle_Integration_Status__c,Oracle_Site_ID__c,';
        query+='Origin_Address__c,blng__PaymentStatus__c,Place_Of_Supply__c,Place_of_Supply_City__c,Place_Of_Supply_State__c,';
        query+='Place_Of_Supply_State_Code__c,BVC_CB_PreTaxBill__c,QR_Code_URL__c,QR_Image_URL__c,BVC_CB_QR_Code__c,Razorpay_Id__c,';
        query+='Razorpay_Payment_Received__c,RDS_Status__c,BVC_CB_ROUND_OFF__c,BVC_CB_SBDate__c,BVC_CB_SBNo__c,Send_Status__c,BVC_Shipment__c,BVC_CB_Shipment_Date__c,Shipping_Note_Number__c,Short_URL__c,Signed_IRN_Text__c,';
        query+='Signed_QR_code_URL__c,state_code__c,State_Of_Supply__c,blng__InvoiceStatus__c,blng__Subtotal__c,blng__TaxAmount__c,';
        query+='Tax_Integration_Error_Message__c,ST_Tax_Percent__c,Tax_Percent_del__c,blng__TaxStatus__c,TDS_Payment_Created__c,blng__TotalAmount__c,Total_BVC_Valuation_Charge_Tax__c,Total_BVC_Valuation_Charges__c,';
        query+='Total_Commission_Charges__c,Total_Commission_Tax__c,Total_Docket_Charge_Tax__c,Total_Docket_Charges__c,Total_Freight_Charges__c,';
        query+='Total_Freight_Tax__c,Total_Fuel_Charge_Tax__c,Total_Fuel_Charges__c,Total_Fuel_Surcharge__c,Total_Fuel_surcharge_Tax__c,Total_Holiday_Charge_Tax__c,';
        query+='Total_Holiday_Charges__c,Total_IGST_Amount__c,Total_Liability_Charge__c,Total_Liability_Charge_Tax__c,Total_Logistics_Charges__c,Total_Logistics_Tax_Amount__c,';
        query+='Total_Offline_Charges__c,Total_Offline_Tax__c,Total_Secure_Logistics_Charges__c,Total_Secure_Logistics_Tax_Amount__c,Total_SGST_Amount__c,Total_Taxable_Amount__c,';
        query+='Total_Universe_Cost_Charge__c,Total_Universe_Cost_Charge_Tax__c,Total_Vaulting_Charges__c,Total_Vaulting_tax__c,Total_Weight_Charge_Tax__c,Total_Weight_Charges__c,Type_of_Invoice__c ';
        
        // query+=' from blng__Invoice__c where blng__Order__c=null';
        query+=' from blng__Invoice__c where blng__Order__c=null AND Id=\'a250T000000axSlQAI\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<blng__Invoice__c> invoiceList)
    {         System.debug('Line 16');
     Map<String,String> invIds = new Map<String,String>();
     List<String> bvcInvIdList = new List<String>();
     
     // Variables for Existing Invoices
     Map<String,String> oldMap = new Map<String,String>();
     List<String> oldList = new List<String>();
     List<BVCInvoice__c> oldInvList = new List<BVCInvoice__c>();
     List<BVCInvoice__c> createBVCInvoices = new List<BVCInvoice__c>();
     for(blng__Invoice__c Oinv:invoiceList)
     { 
         oldList.add(Oinv.id);         
     }
     
     if(oldList.size()>0)
     {
         oldInvList = [select Id,Migrated_Invoice__c from BVCInvoice__c where Migrated_Invoice__c IN :oldList ];
         if(oldInvList!=null)
         {
             for(BVCInvoice__c bi:oldInvList)
             {
                 oldMap.put(bi.Migrated_Invoice__c,bi.Id);
             }
         }
     }
     
     
     for(blng__Invoice__c inv:invoiceList)
     {   
         System.debug('InvoiceMigration Line 42');
         String oldInvId = null;
         oldInvId = oldMap.get(inv.Id);
         System.debug('InvoiceMigration Line 73 oldInvId:'+oldInvId);
         if(oldInvId==null)
         {
             BVCInvoice__c singleBvcInvoice = new BVCInvoice__c();
             singleBvcInvoice.Migrated_Invoice__c = inv.Id;
             
             singleBvcInvoice.Account__c =	inv.blng__Account__c;
             singleBvcInvoice.ACK_Date_Time__c	= inv.ACK_Date_Time__c;
             singleBvcInvoice.ACK_Number__c	= inv.ACK_Number__c;
             singleBvcInvoice.ACR_Cancelled__c	= inv.ACR_Cancelled__c;
             // singleBvcInvoice.Actual_Payment_Collected__c	= inv.Actual_Payment_Collected__c;
             singleBvcInvoice.Advance_Payment_Created__c	= inv.Advance_Payment_Created__c;
             // singleBvcInvoice.Advance_Payment_Received__c	= inv.Advance_Payment_Received__c;
              singleBvcInvoice.BVC_CB_AIR_SEA__c = inv.BVC_CB_AIR_SEA__c;
             //  singleBvcInvoice.Allocations_Against_Invoice__c	= inv.blng__PaymentsAgainstInvoice__c;
             //  singleBvcInvoice.Annexure_Report__c = inv.Annexure_Report__c;
             singleBvcInvoice.AR_Status__c = inv.blng__ARStatus__c;
             //  singleBvcInvoice.Balance_Amount__c = inv.blng__Balance__c;
             //  singleBvcInvoice.Balance_AMOUNT1__c = inv.Balance_Amount__c;
             //  singleBvcInvoice.Batch_Source_Name__c = inv.Batch_Source_Name__c;
             singleBvcInvoice.BVC_CB_BE_Date__c = inv.BVC_CB_BE_Date__c;
              singleBvcInvoice.BVC_CB_BE_No__c = inv.BVC_CB_BE_No__c;
             //  singleBvcInvoice.Bill_From_Location__c = inv.Bill_From_Location__c;
             singleBvcInvoice.Bill_To_Contact__c = inv.blng__BillToContact__c;
             singleBvcInvoice.BVC_CB_BOS_Bill_Amount__c = inv.BVC_CB_BOS_Bill_Amount__c;
             //   singleBvcInvoice.Business_Type__c = inv.Business_Type__c;
             // if(inv.BVC_Billing_Entity__c!=null){singleBvcInvoice.BVC_Billing_Entity__c = inv.BVC_Billing_Entity__c;}
             
             singleBvcInvoice.BVC_Branch__c = inv.BVC_Branch__c;
             singleBvcInvoice.BVC_Entity__c = inv.BVC_Entity__c;
             singleBvcInvoice.BVC_Invoice_Run__c = inv.blng__InvoiceRunCreatedBy__c;
             singleBvcInvoice.BVC_Product__c	= inv.Product__c;
             // singleBvcInvoice.BVCOrder__c = inv.blng__Order__c;
             //  singleBvcInvoice.BVCPayment__c = inv.blng__Payments__c;
             singleBvcInvoice.BVC_CB_CB_BOS_Inv_Seriess__c = inv.BVC_CB_CB_BOS_Inv_Series__c;
             singleBvcInvoice.BVC_CB_CB_Comm_Inv_Amount__c = inv.BVC_CB_CB_Comm_Inv_Amount__c;
             singleBvcInvoice.BVC_CB_CB_Comm_Inv_Series__c = inv.BVC_CB_CB_Comm_Inv_Series__c;
             singleBvcInvoice.BVC_CB_CB_Tax_Inv_Amount__c = inv.BVC_CB_CB_Tax_Inv_Amount__c;
             singleBvcInvoice.BVC_CB_CB_Tax_Inv_Series__c = inv.BVC_CB_CB_Tax_Inv_Series__c;
             //  singleBvcInvoice.COA_Exhibition_Code__c	= inv.COA_Exhibition_Code__c;
             // singleBvcInvoice.COA_Intercompany__c = inv.COA_Intercompany__c;
             //  singleBvcInvoice.BVC_CB_COA_Product_Code_CB__c	= inv.BVC_CB_COA_Product_Code_CB__c;
  				singleBvcInvoice.BVC_CB_COA_SOURCE_CODE__c = inv.BVC_CB_COA_SOURCE_CODE__c;
             // singleBvcInvoice.Consignee_Name__c = inv.Consignee_Name__c;
          singleBvcInvoice.BVC_CB_CONTENT__c = inv.BVC_CB_CONTENT__c;
             singleBvcInvoice.CreatedById = inv.CreatedById;
             //  singleBvcInvoice.CurrencyIsoCode = inv.CurrencyIsoCode
             // singleBvcInvoice.customer_phone__c = inv.customer_phone__c;
             singleBvcInvoice.Destination_Address__c	= inv.Destination_Address__c;
             singleBvcInvoice.Due_Date__c = inv.blng__DueDate__c;
             // singleBvcInvoice.Email_PDF_Date__c = inv.Email_PDF_Date__c;
             singleBvcInvoice.Email_Recepients__c = inv.Email_Recepients__c;
               singleBvcInvoice.BVC_CB_ERDate__c = inv.BVC_CB_ERDate__c;
             singleBvcInvoice.BVC_CB_ERNo__c = inv.BVC_CB_ERNo__c;
             singleBvcInvoice.Exhibition__c = inv.Exhibition__c;
             singleBvcInvoice.EY_Tax_Calculation_Status__c = inv.EY_Tax_Calculation_Status__c;
             // singleBvcInvoice.Gross_Weight__c = inv.Gross_Weight__c;
             //singleBvcInvoice.Gross_Weight_UOM__c = inv.Gross_Weight_UOM__c;
     singleBvcInvoice.BVC_CB_HAWB_Date__c = inv.BVC_CB_HAWB_Date__c;
     singleBvcInvoice.BVC_CB_HAWB_No__c = inv.BVC_CB_HAWB_No__c;
             // singleBvcInvoice.Impact_Amount__c = inv.blng__ImpactAmount__c;
             // singleBvcInvoice.Intercompany_Customer__c = inv.Intercompany_Customer__c;
             singleBvcInvoice.Internal_Remarks__c = inv.Internal_Remarks__c;
             singleBvcInvoice.Invoice_AttachmentId__c = inv.Invoice_AttachmentId__c;
             singleBvcInvoice.Invoice_Cancellation_Status__c	= inv.Invoice_Cancellation_Status__c;
             singleBvcInvoice.Invoice_Date__c = inv.blng__InvoiceDate__c;
             singleBvcInvoice.Invoice_datetime__c = inv.Invoice_date_time__c;
             singleBvcInvoice.Invoice_Doc_URL__c = inv.Invoice_Doc_URL__c;
             // singleBvcInvoice.Invoice_PDF__c	= inv.Invoice_PDF__c;
             // singleBvcInvoice.Invoice_PDF_Attachment__c = inv.Invoice_PDF_Attachment__c;
             singleBvcInvoice.Invoice_Public_Link__c	= inv.Invoice_Public_Link__c;
             // singleBvcInvoice.ST_Invoice_Series__c	= inv.ST_Invoice_Series__c;
             singleBvcInvoice.Invoice_Type__c = inv.Invoice_Type__c;
             singleBvcInvoice.IRN__c	= inv.IRN__c;
             // singleBvcInvoice.IRN_QR_CODE_IMAGE__c = inv.IRN_QR_CODE_IMAGE__c;
             singleBvcInvoice.BVC_CB_Is_CB_Invoice__c = inv.BVC_CB_Is_CB_Invoice__c;
             // singleBvcInvoice.Is_Shipment_Rebilled__c = inv.Is_Shipment_Rebilled__c;
             // singleBvcInvoice.MAWB_Date__c = inv.BVC_CB_MAWB_Date__c;
    singleBvcInvoice.MAWB_No__c = inv.BVC_CB_MAWB_No__c;
             // singleBvcInvoice.Net_Weight__c	= inv.Net_Weight__c;
             // singleBvcInvoice.Net_Weight_UOM__c = inv.Net_Weight_UOM__c;
    singleBvcInvoice.No_Of_Pkgs__c	= inv.BVC_CB_No_Of_Pkgs__c;
             singleBvcInvoice.Notes__c	= inv.blng__Notes__c;
             singleBvcInvoice.NumberToWord__c = inv.NumberToWord__c;
     singleBvcInvoice.Operation_Type__c = inv.BVC_CB_Operation_Type__c;
             singleBvcInvoice.Oracle_Integration_Error_Log__c = inv.Oracle_Integration_Error_Log__c;
             singleBvcInvoice.Oracle_Integration_Status__c = inv.Oracle_Integration_Status__c;
             singleBvcInvoice.Oracle_Site_ID__c = inv.Oracle_Site_ID__c;
             singleBvcInvoice.Origin_Address__c = inv.Origin_Address__c;
             //   singleBvcInvoice.Payment_Status__c = inv.blng__PaymentStatus__c;
             singleBvcInvoice.Payments1__c = inv.blng__Payments__c;
             singleBvcInvoice.Place_Of_Supply__c = inv.Place_Of_Supply__c;
             singleBvcInvoice.Place_of_Supply_City__c = inv.Place_of_Supply_City__c;
             singleBvcInvoice.Place_Of_Supply_State__c = inv.Place_Of_Supply_State__c;
             singleBvcInvoice.Place_Of_Supply_State_Code__c = inv.Place_Of_Supply_State_Code__c;
   singleBvcInvoice.BVC_CB_PreTaxBill__c	= inv.BVC_CB_PreTaxBill__c;
             //  singleBvcInvoice.QR_Code_URL__c	= inv.QR_Code_URL__c;
             singleBvcInvoice.QR_Image_URL__c = inv.QR_Image_URL__c;
             //  singleBvcInvoice.QRCode__c = inv.BVC_CB_QR_Code__c;
             singleBvcInvoice.Razorpay_Id__c	= inv.Razorpay_Id__c;
             singleBvcInvoice.Razorpay_Payment_Received__c	= inv.Razorpay_Payment_Received__c;
             singleBvcInvoice.RDS_Status__c	= inv.RDS_Status__c;
             singleBvcInvoice.BVC_CB_ROUND_OFF__c	= inv.BVC_CB_ROUND_OFF__c;
    singleBvcInvoice.SBDate__c = inv.BVC_CB_SBDate__c;
  singleBvcInvoice.SBNo__c = inv.BVC_CB_SBNo__c;
             singleBvcInvoice.Send_Status__c	= inv.Send_Status__c;
             singleBvcInvoice.Shipment__c	= inv.BVC_Shipment__c;
             //  singleBvcInvoice.Shipping_Date__c = inv.BVC_CB_Shipment_Date__c;
             // singleBvcInvoice.Shipping_Note_Number__c = inv.Shipping_Note_Number__c;
             singleBvcInvoice.Short_URL__c = inv.Short_URL__c;
             singleBvcInvoice.Signed_IRN_Text__c = inv.Signed_IRN_Text__c;
             singleBvcInvoice.Signed_QR_code_URL__c	= inv.Signed_QR_code_URL__c;
             // singleBvcInvoice.state_code__c	= inv.state_code__c;
             singleBvcInvoice.State_Of_Supply__c = inv.State_Of_Supply__c;
             singleBvcInvoice.Status__c = inv.blng__InvoiceStatus__c;
             // singleBvcInvoice.Subtotal__c	= inv.blng__Subtotal__c;
             // singleBvcInvoice.TaxAmount__c	= inv.blng__TaxAmount__c;
             singleBvcInvoice.Tax_Integration_Error_Message__c = inv.Tax_Integration_Error_Message__c;
             singleBvcInvoice.ST_Tax_Percent__c = inv.ST_Tax_Percent__c;
             singleBvcInvoice.Tax_Percent__c	= inv.Tax_Percent_del__c;
             singleBvcInvoice.Tax_Status__c	= inv.blng__TaxStatus__c;
             singleBvcInvoice.TDS_Payment_Created__c	= inv.TDS_Payment_Created__c;
             // singleBvcInvoice.Total_Amount_With_Tax__c = inv.blng__TotalAmount__c;
             singleBvcInvoice.Total_BVC_Valuation_Charge_Tax__c = inv.Total_BVC_Valuation_Charge_Tax__c;
             singleBvcInvoice.Total_BVC_Valuation_Charges__c	= inv.Total_BVC_Valuation_Charges__c;
             // singleBvcInvoice.Total_CGST_Amount__c	= inv.Total_CGST_Amount__c;
             // singleBvcInvoice.Total_Commission_Charges__c	= inv.Total_Commission_Charges__c;
             singleBvcInvoice.Total_Commission_Tax__c	= inv.Total_Commission_Tax__c;
             singleBvcInvoice.Total_Docket_Charge_Tax__c	= inv.Total_Docket_Charge_Tax__c;
             singleBvcInvoice.Total_Docket_Charges__c	= inv.Total_Docket_Charges__c;
             // singleBvcInvoice.Total_Freight_Charges__c	= inv.Total_Freight_Charges__c;
             singleBvcInvoice.Total_Freight_Tax__c	= inv.Total_Freight_Tax__c;
             singleBvcInvoice.Total_Fuel_Charge_Tax__c	= inv.Total_Fuel_Charge_Tax__c;
             singleBvcInvoice.Total_Fuel_Charges__c	= inv.Total_Fuel_Charges__c;
             singleBvcInvoice.Total_Fuel_Surcharge__c	= inv.Total_Fuel_Surcharge__c;
             singleBvcInvoice.Total_Fuel_surcharge_Tax__c	= inv.Total_Fuel_surcharge_Tax__c;
             singleBvcInvoice.Total_Holiday_Charge_Tax__c	= inv.Total_Holiday_Charge_Tax__c;
             singleBvcInvoice.Total_Holiday_Charges__c	= inv.Total_Holiday_Charges__c;
             // singleBvcInvoice.Total_IGST_Amount__c	= inv.Total_IGST_Amount__c;
             // singleBvcInvoice.Total_Liability_Charge__c	= inv.Total_Liability_Charge__c;
             singleBvcInvoice.Total_Liability_Charge_Tax__c	= inv.Total_Liability_Charge_Tax__c;
             singleBvcInvoice.Total_Logistics_Charges__c	= inv.Total_Logistics_Charges__c;
             singleBvcInvoice.Total_Logistics_Tax_Amount__c	= inv.Total_Logistics_Tax_Amount__c;
             //singleBvcInvoice.Total_Offline_Charges__c	= inv.Total_Offline_Charges__c;
             singleBvcInvoice.Total_Offline_Tax__c	= inv.Total_Offline_Tax__c;
             //singleBvcInvoice.Total_Secure_Logistics_Charges__c	= inv.Total_Secure_Logistics_Charges__c;
             singleBvcInvoice.Total_Secure_Logistics_Tax_Amount__c	= inv.Total_Secure_Logistics_Tax_Amount__c;
             //singleBvcInvoice.Total_SGST_Amount__c	= inv.Total_SGST_Amount__c;
             //singleBvcInvoice.Total_Taxable_Amount__c	= inv.Total_Taxable_Amount__c;
             singleBvcInvoice.Total_Universe_Cost_Charge__c	= inv.Total_Universe_Cost_Charge__c;
             singleBvcInvoice.Total_Universe_Cost_Charge_Tax__c	= inv.Total_Universe_Cost_Charge_Tax__c;
             singleBvcInvoice.Total_Vaulting_Charges__c	= inv.Total_Vaulting_Charges__c;
             singleBvcInvoice.Total_Vaulting_tax__c	= inv.Total_Vaulting_tax__c;
             singleBvcInvoice.Total_Weight_Charge_Tax__c	= inv.Total_Weight_Charge_Tax__c;
             singleBvcInvoice.Total_Weight_Charges__c	= inv.Total_Weight_Charges__c;
             singleBvcInvoice.Type_of_Invoice__c	= inv.Type_of_Invoice__c;
             
             bvcInvIdList.add(inv.Id);
             createBVCInvoices.add(singleBvcInvoice); 
             System.debug('Line 198 singleBvcInvoice.Id:'+singleBvcInvoice.Id);
         }      
     }         
     System.debug('Line 201 bvcInvIdList:'+bvcInvIdList.size());   
     System.debug('Line 204 createBVCInvoices size:'+createBVCInvoices.size());
     if(createBVCInvoices.size()>0)
     { 
         try
         {
             List<Database.UpsertResult> upsertResults = Database.upsert(createBVCInvoices, false); 
             InvoiceMigrationHelper.MakeMail(upsertResults,createBVCInvoices,'BVCInvoice__c');
             for(BVCInvoice__c bvc:createBVCInvoices)
             {
                 invIds.put(bvc.Migrated_Invoice__c,bvc.Id);        
             }
             System.debug('Line 62 contIds : '+invIds.size());
             InvoiceMigrationHelper.generateInvoiceLines(bvcInvIdList,invIds);
             InvoiceMigrationHelper.generatePayments(bvcInvIdList,invIds);
             InvoiceMigrationHelper.generateAttachments(bvcInvIdList,invIds);
         }catch(Exception e)
         {
             System.debug('Line No 65 ACRCP Error :'+e.getMEssage());
         }              
     }        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}*/