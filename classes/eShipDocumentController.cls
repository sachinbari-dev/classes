public class eShipDocumentController {

    public static List<BVCQuote__c> BVCQuoteList {get;set;} 
    public static List<eSHIP_Custom_Pricing__c>  eshipCustPriceList {get;set;} 
    
    public eShipDocumentController(){
        
         String quoteID = ApexPages.currentPage().getParameters().get('id');
         system.debug('@@@@@@@ ::'+quoteID);
         BVCQuoteList = new List<BVCQuote__c>();
        
         if(string.isNotBlank(quoteID)){
                
             BVCQuote__c bvcquote = new BVCQuote__c();
                
               bvcquote =[SELECT Id, Name, Account_Email_ID__c, Owner.name,createdby.name,createdby.Email ,owner.email,owner.phone,Quote_sent_date_add_30__c,BVC_Entity__r.id,BVC_Entity__r.name,Account__r.name,Account__r.phone,
                       BVC_Authorized_Signatory__r.name,BVC_LegalEntity__r.Name, BVC_Billing_Entity_City__c,BVC_Billing_Entity_Pincode__c,BVC_Billing_Entity_State__c,BVC_Billing_Entity_Country__c,
                       Customer_Authorized_Signatory__r.name,Customer_Authorized_Signatory__r.Email,Customer_Authorized_Signatory__r.phone,Business_Type__c, Base_Quote__c, Sales_Rep__c, Exhibition__c, Status__c,BVC_Entity_Name_c__c,
                       Create_Order__c, Account__c, Decision_Maker_Email_Id__c, BVC_Service__c,Contract_Start_Date__c,Contract_End_Date__c, Ordered__c,BVC_Billing_Entity_Address_Line_1__c,BVC_Billing_Entity_Address_Line_2__c, 
                       Primary__c, eSHIP_legacy__c, Primary_Contact__c, Type__c, Shipment__c, Quick_Calculate_BVC__c, Personal_Contract_Status__c,KYC_Indicator_for_Domestic_Flag__c,
                       Contract_Signed__c, Customer_PAN__c, Customer_Name_As_Per_Pan__c, Evaluator__c, Bill_To_GSTIN__c, Decision_Maker__c, 
                       Customer_Authorized_Signatory_Full_Name__c, Customer_Authorized_Signatory__c, Customer_Billing_Frequency__c, 
                       Customer_Authorized_Signatory_Designatio__c, Billing_Address__c,Billing_Address__r.name, Bill_To_Trade_Name__c, Bill_To_Street__c, Bill_To_Postal_Code__c,
                       Bill_To_City__c, Bill_To_State__c, Bill_To_Country__c, BVC_Branch__c,  BVC_Entity__c,BVC_LegalEntity__c, 
                       BVC_Billing_Entity_GSTIN__c, BVC_Billing_Entity_PAN__c, BVC_Authorized_Signatory__c, BVC_Authorized_Signatory_Designation__c, 
                       BVC_Care_Email__c, BVC_Care_Phone_Number__c, Start_Date__c, End_Date__c, Quote_Sent_Date__c, Contract_Signed_Date__c,
                       Subscription_Term__c, Credit_Limit__c, Payment_Terms__c, Notes__c, Net_Amount__c, Subrogation_End_Date__c,
                       Subrogation_Start_Date__c, No_Of_Attempts__c, Max_Discount_on_QuoteLine__c, BVC_Price_Slab__c, Tariff_Plan__c, Customized__c, 
                       Is_Shipment__c, Approval_Stage__c, Approval_Flag__c,Document_Date__c, Account_Name__c FROM BVCQuote__c where ID =:quoteID LIMIT 1];
            
               BVCQuoteList.add(bvcquote);
               system.debug('BVCQuoteList@@@'+ BVCQuoteList);
            
             eshipCustPriceList = new List<eSHIP_Custom_Pricing__c>();
             eSHIP_Custom_Pricing__c eshipList =[SELECT Name, Id, ACR_Amount__c, Business_Type__c, Additional_Charge__c, COD_Charges_per_shipment__c,
                                          COD_Charges_percentage_of_product__c, Customer__c, Fuel_Surcharge__c, Gross_Weight_Unit_for_Additional_Weight__c,
                                          Liability_Charges__c, Logistice_Charges__c, Lower_Bound__c, No_Of_Free_Atttemps__c, Package_Amount__c, Rate_INR__c,
                                          Shipment_Type__c, Slab_Criteria__c, Slab_Level__c, Upper_Bound__c, Weight_Charges__c, Weight_Covered_Gms__c,
                                          l_Liability_Cover_By_BVC__c, COD_Charges_percentage_e_of_product__c, Final_Fuel__c, Final_Logistice_Charges__c,
                                          Liability_l_Charges__c, Per_Shipment_Freight_Charge__c, UOM_Percentage__c, Universe_Cost_Charge__c, 
                                          BVCQuote__c 
                                          FROM eSHIP_Custom_Pricing__c where BVCQuote__r.id =:quoteID LIMIT 1];
            
             eshipCustPriceList.add(eshipList);
               system.debug('eshipCustPriceList@@@'+ eshipCustPriceList);
             
             if(eshipCustPriceList.isEmpty()){
                 system.debug('eshipCustPriceList'+ eshipCustPriceList);
                 system.debug('eship custom pricing record is missing');
             }
                String fileName = 'e-Ship Quote Quotation' +' '+ bvcquote.Name + '.pdf';
               // fileName = fileName.replace('_', ''); 
                
                ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename="' + fileName + '"');
         }
    }
}