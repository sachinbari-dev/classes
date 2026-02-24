public class BVCInvoicePdfController {

    public static List<BVCInvoice__c> bvcInvoiceList {get;set;}
    
    public BVCInvoicePdfController(){
        
        String invoiceID = ApexPages.currentPage().getParameters().get('id');
        system.debug('@@@@@@@ ::'+invoiceID);
        bvcInvoiceList = new List<BVCInvoice__c>();
        if(string.isNotBlank(invoiceID)){
              BVCInvoice__c bvcInv = new BVCInvoice__c();
              
              bvcInv = [SELECT Total_Offline_Charges__c, Total_Liability_Charge__c, TaxAmount__c, state_code__c,
                        Total_Freight_Charges__c, Subtotal__c, Shipping_Note_Number__c, Shipping_Date__c, QRCode__c, Shipment__c, 
                        QR_Code_URL__c,Origin_Address__c, BVCOrder__c, IRN_QR_CODE_IMAGE__c, Invoice_PDF_Attachment__c,
                        Invoice_PDF__c, Invoice_Number__c, Impact_Amount__c, COA_Intercompany__c, Exhibition__c, BVC_Entity__c, COA_Exhibition_Code__c,
                        BVC_Billing_Entity__c, Billing_Address__c, Bill_To_Contact__c, Bill_From_Location__c, BVC_Branch__c, Balance_Amount__c,
                        Total_Amount_With_Tax__c, Allocations_Against_Invoice__c, Advance_Payment_Received__c, Account__c, Annexure_Report__c,
                        RDS_Status__c, Actual_Payment_Collected__c, X18_Digit_ID__c, ACK_Number__c, Total_Weight_Charge_Tax__c, Total_Fuel_Surcharge__c, 
                      /*  IRN__c, Invoice_Public_Link__c, Invoice_Type__c, QR_Image_URL__c, Total_BVC_Valuation_Charges__c, Invoice_Cancellation_Status__c,
                        Total_Weight_Charges__c, EY_Tax_Calculation_Status__c, Oracle_Site_ID__c, Place_Of_Supply_State_Code__c, State_Of_Supply__c, 
                        Tax_Integration_Error_Message__c, Short_URL__c, Total_Fuel_Charges__c, Razorpay_Id__c, Type_of_Invoice__c,
                        Total_Secure_Logistics_Tax_Amount__c, Total_Logistics_Tax_Amount__c, Invoice_AttachmentId__c, Invoice_Date__c,
                        Total_BVC_Valuation_Charge_Tax__c, ST_Invoice_Series__c,Total_Fuel_surcharge_Tax__c, Place_of_Supply_City__c, 
                        Total_Vaulting_Charges__c, Total_Offline_Tax__c, Total_Universe_Cost_Charge__c, Status__c, Signed_QR_Code__c, Tax_Status__c, 
                        Tax_Percent__c, ACK_DateTime__c, Oracle_Integration_Status__c, Total_Freight_Tax__c, Total_Holiday_Charge_Tax__c, 
                        Advance_Payment_Created__c, Total_Fuel_Charge_Tax__c, Razorpay_Payment_Received__c, Invoice_datetime__c, Total_Vaulting_tax__c, 
                        Total_Logistics_Charges__c, Total_Holiday_Charges__c, Total_Liability_Charge_Tax__c, Signed_QR_code_URL__c, Place_Of_Supply_State__c,
                        Total_Universe_Cost_Charge_Tax__c, Send_Status__c, TDS_Payment_Created__c, Place_Of_Supply__c, NumberToWord__c, Invoice_Doc_URL__c,*/
                        Due_Date__c, Name, Id FROM BVCInvoice__c where ID =:invoiceID LIMIT 1];
            
                bvcInvoiceList.add(bvcInv);
              
        }
    }
}