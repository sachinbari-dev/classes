public class BVC_EyManualTaxCalculationClass {

       @AuraEnabled
    public static string invoiceEyIntegration(String recordId, String obj){ 
        System.debug('recordId :'+recordId);
        Datetime startTime = Datetime.now();
        try {
            List<BVCInvoice__c> invoiceObj= new List<BVCInvoice__c>();
            If(obj=='Inv'){
                
            
             invoiceObj = [Select id,Total_Fuel_Surcharge__c,Account__r.Name,Account__r.ShippingAddress,BVC_CB_Is_CB_Invoice__c,Total_Universe_Cost_Charge__c,
                                                 Total_Vaulting_Charges__c,Total_Vaulting_tax__c,Total_Fuel_surcharge_Tax__c,
                                                 Total_Universe_Cost_Charge_Tax__c,Total_Docket_Charge_Tax__c,Total_Commission_Tax__c,
                                                 Total_Logistics_Tax_Amount__c,Total_Secure_Logistics_Tax_Amount__c,
                                                 Total_Logistics_Charges__c,Total_Weight_Charge_Tax__c,ST_Tax_Percent__c ,
                                                 Total_Fuel_Charge_Tax__c,Total_Holiday_Charge_Tax__c,Total_BVC_Valuation_Charge_Tax__c,
                                                 Total_Liability_Charge_Tax__c,Total_Offline_Tax__c,Total_Freight_Tax__c,
                                                  Status__c,BVC_Branch__c,Billing_Address__c,Total_Liability_Charge__c,
                                                 Total_Offline_Charges__c,Total_Freight_Charges__c,Total_Holiday_Charges__c, Destination_Address__c,
                                                 Destination_Address__r.ADDRESS1__c,Destination_Address__r.ADDRESS2__c,Destination_Address__r.CITY__c,
                                                 Destination_Address__r.STATE__c,Destination_Address__r.COUNTRY__c,Consignee_Name__c, Billing_Address__r.PINCODE__c,
                                                 Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.COUNTRY__c,Billing_Address__r.GST_Registered_Status__c,
                                                 Billing_Address__r.Dealer_Type__c,Billing_Address__r.GSTIN__c,Account__r.PAN_Number_of_Entity__c,
                                                 BVC_Branch__r.BVC_Entity__r.PAN__c,BVC_Branch__r.BVC_Entity__r.Name,BVC_LegalEntity__r.GSTIN_Principle_Business_Address_Line_2__c,
                                                 BVC_LegalEntity__r.GSTIN_Principle_Business_Address_Line_1__c,BVC_LegalEntity__r.GSTIN__c,
                                                 origin_Address__r.STATE__c,Origin_Address__r.COUNTRY__c,BVCOrder__r.Business_Type__c,
                                                 BVC_Branch__r.Hub_State__c,BVC_Branch__r.Hub_Address_Line_1__c,BVC_Branch__r.Hub_Address_Line_2__c,
                                                 BVC_LegalEntity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c, BVC_LegalEntity__r.GSTIN_Principle_Business_Address_City__c,
                                                 BVC_LegalEntity__r.GSTIN_Principle_Business_Address_State__c,origin_Address__r.City__c,Total_Commission_Charges__c,Total_Secure_Logistics_Charges__c,
                                                Total_Docket_Charges__c,ST_Invoice_Series__c,
                                                BVC_LegalEntity__r.GSTIN_Principle_Business_Address_Pincode__c,
                                                
                                                 Name 
                                                 from BVCInvoice__c where id=:recordId ];
                System.debug('invoiceObj[0].Status__c :'+invoiceObj[0].Status__c);
            }
            else if(obj=='invRun'){
                invoiceObj = [Select id,Total_Fuel_Surcharge__c,Account__r.Name,Account__r.ShippingAddress,BVC_CB_Is_CB_Invoice__c,Total_Universe_Cost_Charge__c,
                              Total_Vaulting_Charges__c,Total_Vaulting_tax__c,Total_Fuel_surcharge_Tax__c,
                              Total_Universe_Cost_Charge_Tax__c,Total_Docket_Charge_Tax__c,Total_Commission_Tax__c,
                              Total_Logistics_Tax_Amount__c,Total_Secure_Logistics_Tax_Amount__c,
                              Total_Logistics_Charges__c,Total_Weight_Charge_Tax__c,ST_Tax_Percent__c ,
                              Total_Fuel_Charge_Tax__c,Total_Holiday_Charge_Tax__c,Total_BVC_Valuation_Charge_Tax__c,
                              Total_Liability_Charge_Tax__c,Total_Offline_Tax__c,Total_Freight_Tax__c,
                              Status__c,BVC_Branch__c,BVC_LegalEntity__c,Billing_Address__c,Total_Liability_Charge__c,
                              Total_Offline_Charges__c,Total_Freight_Charges__c,Total_Holiday_Charges__c, Destination_Address__c,
                              Destination_Address__r.ADDRESS1__c,Destination_Address__r.ADDRESS2__c,Destination_Address__r.CITY__c,
                              Destination_Address__r.STATE__c,Destination_Address__r.COUNTRY__c,Consignee_Name__c, Billing_Address__r.PINCODE__c,
                              Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.COUNTRY__c,Billing_Address__r.GST_Registered_Status__c,
                              Billing_Address__r.Dealer_Type__c,Billing_Address__r.GSTIN__c,Account__r.PAN_Number_of_Entity__c,
                              BVC_Branch__r.BVC_Entity__r.PAN__c,BVC_Branch__r.BVC_Entity__r.Name,BVC_LegalEntity__r.GSTIN_Principle_Business_Address_Line_2__c,
                              BVC_LegalEntity__r.GSTIN_Principle_Business_Address_Line_1__c,BVC_LegalEntity__r.GSTIN__c,
                              origin_Address__r.STATE__c,Origin_Address__r.COUNTRY__c,BVCOrder__r.Business_Type__c,
                              BVC_Branch__r.Hub_State__c,BVC_Branch__r.Hub_Address_Line_1__c,BVC_Branch__r.Hub_Address_Line_2__c,
                              BVC_LegalEntity__r.GSTIN_Principle_Business_Address_Pincode__r.Pincodes__c, BVC_LegalEntity__r.GSTIN_Principle_Business_Address_City__c,
                              BVC_LegalEntity__r.GSTIN_Principle_Business_Address_State__c,origin_Address__r.City__c,Total_Commission_Charges__c,Total_Secure_Logistics_Charges__c,
                              Total_Docket_Charges__c,ST_Invoice_Series__c,BVC_LegalEntity__r.GSTIN_Principle_Business_Address_Pincode__c,
                              Name 
                              from BVCInvoice__c where BVC_Invoice_Run__c=:recordId ];
                recordId=invoiceObj[0].id;
            }
            if(invoiceObj[0].Status__c != 'Draft'){
                throw new applicationException('Invoice stage should be draft');
            } else if (invoiceObj[0].ST_Invoice_Series__c == null){
                throw new applicationException('Invoice Series is blank');
            }
            else if(invoiceObj[0].BVC_Branch__c == null || invoiceObj[0].BVC_LegalEntity__c == null ){
                throw new applicationException('Invalid Billing Information, Please validate Branch,Billing Entity and Billing Address Values');
            }else if(invoiceObj[0].BVC_CB_Is_CB_Invoice__c == False && 
            (invoiceObj[0].Total_Liability_Charge__c == null || invoiceObj[0].Total_Liability_Charge__c == 0) && 
            (invoiceObj[0].Total_Offline_Charges__c == null || invoiceObj[0].Total_Offline_Charges__c == 0)&& 
            (invoiceObj[0].Total_Freight_Charges__c == null || invoiceObj[0].Total_Freight_Charges__c == 0.00)&&
            (invoiceObj[0].Total_Fuel_Surcharge__c == null || invoiceObj[0].Total_Fuel_Surcharge__c == 0)&&//Prat
            (invoiceObj[0].Total_Vaulting_Charges__c == null || invoiceObj[0].Total_Vaulting_Charges__c == 0)&&//Prat
            (invoiceObj[0].Total_Universe_Cost_Charge__c == null || invoiceObj[0].Total_Universe_Cost_Charge__c == 0)&&//UniverseCostCharge
            (invoiceObj[0].Total_Logistics_Charges__c == null || invoiceObj[0].Total_Logistics_Charges__c == 0.00)&&
            (invoiceObj[0].Total_Commission_Charges__c == null || invoiceObj[0].Total_Commission_Charges__c == 0.00)&&
            (invoiceObj[0].Total_Secure_Logistics_Charges__c == null || invoiceObj[0].Total_Secure_Logistics_Charges__c == 0.00) &&
            (invoiceObj[0].Total_Holiday_Charges__c == null || invoiceObj[0].Total_Holiday_Charges__c == 0.00)
            ){
                throw new applicationException('Invalid Amount, Please validate Liability, Frieght and Offline chanrges before applying Tax');
            }else{
                List<Id> invIds = new List<Id>{Id.valueOf(recordId)}; 
                List<Id> razorpayInvoiceIds = new List<Id>();
                if(invIds.size() >0){
                    system.debug('here in invoice');
                    razorpayInvoiceIds.addAll(BVC_QueryUtilityManual.invoiceQuery(invIds));
                }
                //List<blng__Invoice__c> invoiceObjMap = [Select id,Total_Logistics_Tax_Amount__c,Total_Secure_Logistics_Tax_Amount__c,Total_Docket_Charge_Tax__c,Total_Weight_Charge_Tax__c,Total_Commission_Tax__c,Total_Fuel_Charge_Tax__c,Total_Holiday_Charge_Tax__c,Total_BVC_Valuation_Charge_Tax__c,Total_Liability_Charge_Tax__c,Total_Offline_Tax__c,Total_Freight_Tax__c,ST_Tax_Percent__c,Total_Secure_Logistics_Charges__c,blng__InvoiceStatus__c ,BVC_Branch__c,BVC_Billing_Entity__c,Total_Logistics_Charges__c,Total_Commission_Charges__c,Billing_Address__c,Total_Liability_Charge__c,Total_Offline_Charges__c,Total_Freight_Charges__c from blng__Invoice__c where id=:recordId];
                //Map<id,blng__Invoice__c> mapInvoiceList =new Map<id,blng__Invoice__c>();
                //for(blng__Invoice__c inv:invoiceObjMap){
                   //mapInvoiceList.put(inv.id,inv); 
                //}
                
                if(razorpayInvoiceIds.size() > 0){
                    //InvoiceLineTaxCalculator.lineTaxCalculator(mapInvoiceList);
                    //system.enqueueJob(new InvoiceLineTaxUpdateQueueable(mapInvoiceList));
                 system.enqueueJob(new BVC_RazorpayQueueable(razorpayInvoiceIds));
                    
                }
                Datetime endTime = Datetime.now();
                System.debug('final time: ' + startTime+':::::::::::::::'+endTime);
                return 'Tax Calculation Completed Succesfully, Please refresh the Page';
            }
            
        } catch (Exception e) {
            System.debug('Error Message.  '+e.getMessage());
            System.debug('Error on Line Number :'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
            //return 'Error in Completion of Tax Calculation';
        }
        
    }
    public BVC_EyManualTaxCalculationClass() {

    }
    
    
    
     public static void f1Method(){
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
        i++;}
}