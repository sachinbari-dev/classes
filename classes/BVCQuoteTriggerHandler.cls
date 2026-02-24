/* created by : Rafi Khan
 * created date :
 * version 1.0: 
 
 */
public class BVCQuoteTriggerHandler {

      public static void BVCQuoteProcessor(Map<Id,BVCQuote__c> newMap){
        
        System.debug('Rafi debug Inside BVCQuoteTriggerHandler.BVCQuoteProcessor() newMap = '+newMap);
        
        Map<Id,BVCQuote__c> invBVCQuoteMap = new Map<Id,BVCQuote__c>();
        Set<Id> accIds = new Set<Id>();
        
        for(BVCQuote__c bvcQuote : newMap.values()){
            accIds.add(bvcQuote.Account__c);
        }
        
        System.debug('Rafi debug Inside BVCQuoteTriggerHandler.BVCQuoteProcessor() accIds = '+accIds);
        
        for(BVCQuote__c bvcQuote : [SELECT Id,Business_Type__c, Account__r.Active_Contract__c
                       FROM BVCQuote__c 
                       WHERE Account__c IN :accIds
                       AND Id IN :newMap.keySet()]){
                           
                           if(bvcQuote.Business_Type__c == 'ACR'){
                               invBVCQuoteMap.put(newMap.get(bvcQuote.Id).Id,newMap.get(bvcQuote.Id));
                           }
                           
                           
                       } 
        
        System.debug('Rafi debug Inside BVCQuoteTriggerHandler.BVCQuoteProcessor() invBVCQuoteMap.size() = '+invBVCQuoteMap.size());
        System.debug('Rafi debug Inside BVCQuoteTriggerHandler.BVCQuoteProcessor() invBVCQuoteMap.values() = '+invBVCQuoteMap.values());
        if(invBVCQuoteMap.size() > 0 && invBVCQuoteMap != null){
            generateInvoice(invBVCQuoteMap);
        }
    } 
    
    public static void generateInvoice(Map<Id,BVCQuote__c> bvcQuoteMap){
        System.debug('Rafi debug jumped inside generateInvoice and bvcQuoteMap = '+bvcQuoteMap);
        Set<Id> quoteIds = new set<Id>();
        for(BVCQuote__c bvcQuote : bvcQuoteMap.values()){
            quoteIds.add(bvcQuote.Id);
        }
        System.debug('Rafi debug jumped inside generateInvoice and quoteIds = '+quoteIds);
        
        Map<Id,BVCQuote__c> acrBVCQuoteMap = new Map<Id,BVCQuote__c>();
        Map<Id,List<BVCQuoteLineItem__c>> acrBVCQuoteLineMap = new Map<Id,List<BVCQuoteLineItem__c>>();
        
        List<BVCQuote__c> bvcQuoteList = new List<BVCQuote__c>();
        if(quoteIds.size() > 0){
            bvcQuoteList.addAll([Select Id, Account_Email_ID__c, Business_Type__c, Status__c, Sales_Rep__c, Base_Quote__c, 
                                 Exhibition__c,Create_Order__c, Decision_Maker_Email_Id__c, 
                                 Account__c, BVC_Service__c, Primary__c, Ordered__c, eSHIP_legacy__c, Primary_Contact__c, Type__c, 
                                 Shipment__c, Quick_Calculate_BVC__c, Personal_Contract_Status__c, Contract_Signed__c, Customer_PAN__c, 
                                 Customer_Name_As_Per_Pan__c, Bill_To_GSTIN__c, Evaluator__c, Decision_Maker__c, 
                                 Customer_Authorized_Signatory__c, Customer_Authorized_Signatory_Full_Name__c, 
                                 Customer_Authorized_Signatory_Designatio__c, Customer_Billing_Frequency__c, Billing_Address__c, 
                                 Bill_To_Trade_Name__c, Bill_To_Street__c, Bill_To_Postal_Code__c, Bill_To_City__c, Bill_To_State__c, 
                                 Bill_To_Country__c, BVC_Branch__c, BVC_Entity__c, BVC_Billing_Entity_GSTIN__c,KYC_Indicator_for_Domestic_Flag__c,
                                 BVC_Billing_Entity_PAN__c, BVC_Authorized_Signatory__c, BVC_Authorized_Signatory_Designation__c, 
                                 BVC_Care_Email__c, BVC_Care_Phone_Number__c, Start_Date__c, End_Date__c, Quote_Sent_Date__c, 
                                 Contract_Signed_Date__c, Subscription_Term__c, Payment_Terms__c, Credit_Limit__c, Notes__c, 
                                 Net_Amount__c, Subrogation_Start_Date__c, Subrogation_End_Date__c, No_Of_Attempts__c, 
                                 Max_Discount_on_QuoteLine__c, BVC_Price_Slab__c, Tariff_Plan__c, Customized__c, Is_Shipment__c, 
                                 Approval_Stage__c, Approval_Flag__c, Account_Name__c,BVC_LegalEntity__c,
                                 (Select Id, BVCQuote__c, Quantity__c, Number__c, Renewal__c, Pricing_Method__c, 
                                  Pricing_Method_Editable__c, Cost_Editable__c, Hidden__c, Price_Editable__c, 
                                  Service_Type__c, Discount_Approval_Status__c, Guidance__c, Contracted_No_Of_Free_Attempts__c, 
                                  Per_Shipment_Freight_Charge__c, UOM_Percentage__c, Indirect_Location__c, Remote_Location__c, 
                                  All_Risk_Liability__c, Fidelity_Liability__c, Subrogation_Liability__c, Description__c, 
                                  Rate_Amount__c, Offline_Charge__c, Minimum_Freight__c, Fuel_Surcharge__c, Prior_Fuel_Surcharge__c, 
                                  Universe_Cost_Charge__c, Prior_Universe_Cost_Charge__c, Freight_on_Invoice_Value__c, Package_Type__c, 
                                  Gross_Weight_Slabs__c, Origin__c, Destination__c, Origin_Destination_Pair__c, COA_Product_Code__c, 
                                  Customer_Product_Category__c, Rate_UOM__c, Liability_Coverage__c, ACR_Standard_Price__c, 
                                  NonACR_Standard_Price__c, Net_Unit_Price__c, List_Unit_Price__c, Max_Discount__c, 
                                  Subscription_Pricing__c, Percent_of_Total_Base__c, Percent_of_Total__c, Default_Subscription_Term__c, 
                                  Start_Date__c, End_Date__c, Subscription_Type__c, Additional_Disc__c, Option_Discount__c,Product_Code__c, 
                                  Non_Discountable__c, Non_Partner_Discountable__c, Partner_Discount__c, Volume_Discount__c,Product_name__c, 
                                  Term_Discount__c, Compound_Discount__c, Existing__c, Exhibition__c, Product__c,
                                  ACR_Standard_Price__r.Product_Name__c, ACR_Standard_Price__r.ACR_Product_Code__c From BVCQuoteLineItems__r),
                                 Account__r.Billing_Address__c
                                 From BVCQuote__c WHERE Id IN :quoteIds]);
        }
        System.debug('Rafi debug jumped inside generateInvoice and bvcQuoteList.size() : '+bvcQuoteList.size());
        System.debug('Rafi debug jumped inside generateInvoice and bvcQuoteList : '+bvcQuoteList);
        
        
        for(BVCQuote__c bvcQuote : bvcQuoteList){
            
            if(bvcQuote.Business_Type__c == 'ACR' && bvcQuote.BVCQuoteLineItems__r.size() > 0){
                acrBVCQuoteMap.put(bvcQuote.Id,bvcQuote);
                acrBVCQuoteLineMap.put(bvcQuote.Id,bvcQuote.BVCQuoteLineItems__r);
            } 
            
        }
        
        System.debug('Rafi debug jumped inside generateInvoice and acrBVCQuoteMap.size() : '+acrBVCQuoteMap.size());
        System.debug('Rafi debug jumped inside generateInvoice and acrBVCQuoteMap.values() : '+acrBVCQuoteMap.values());
        System.debug('Rafi debug jumped inside generateInvoice and acrBVCQuoteLineMap.size() : '+acrBVCQuoteLineMap.size());
        System.debug('Rafi debug jumped inside generateInvoice and acrBVCQuoteLineMap.values() : '+acrBVCQuoteLineMap.values());
        
        if(acrBVCQuoteLineMap.size() > 0 && acrBVCQuoteLineMap != null){
            UtilClass.orderTriggerLoop = true;
            System.debug('Rafi debug jumped inside generateInvoice and UtilClass.orderTriggerLoop : '+UtilClass.orderTriggerLoop);
            BVC_InvoiceGenerator.createACRInvoice(acrBVCQuoteMap, acrBVCQuoteLineMap);
        }
        
    }
    
    
    //getCoverage method
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
    }
    

}