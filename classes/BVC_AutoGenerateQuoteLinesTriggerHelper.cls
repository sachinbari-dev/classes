public class BVC_AutoGenerateQuoteLinesTriggerHelper 
{
 public static void ChangePriceSlab(Map<String,BVCQuote__c> quoteMap, Set<String> PriceSlabList)
 {     
	List<ST_ACR_Standard_Price__c> acrList = [SELECT Id, ST_Product__c, ST_Rate_Amount__c, Product__c, Product_Code__c, ST_ACR_Package_Amount__c,
                                                      ST_Minimum_Freight__c, ST_Liability_Coverage__c, ST_Rate_UOM__c, ST_Offline_Charge__c,
                                                      Subrogation_Liability__c, All_Risk_Liability__c, Fidelity_Liability__c,
                                                      Remote_Location__c,ST_ACR_Package_Type__c	,Indirect_Location__c, Fuel_Surcharge__c, ST_Freight_on_Invoice_Value__c,
                                                      Universe_Cost_Charge__c FROM ST_ACR_Standard_Price__c WHERE ST_ACR_Package_Type__c = :PriceSlabList];
      System.debug('44 acrList :' + acrList.size());
	if (acrList.size() > 0) 
    {
        List<BVCQuoteLineItem__c> qlList = new List<BVCQuoteLineItem__c>();
        List<String> quoteIds = new List<String>();
        for(String priceSlab:quoteMap.keySet())
        {
			BVCQuote__c quote = quoteMap.get(priceSlab);
            if(quote !=null)
            {
                if (quote.BVC_Service__c == 'SilverSHIP' || quote.BVC_Service__c == 'ValSHIP') 
                {
                    for (ST_ACR_Standard_Price__c sp : acrList) 
                    {
                        if(sp.ST_ACR_Package_Type__c ==priceSlab)
                        {
                            BVCQuoteLineItem__c qlItem = new BVCQuoteLineItem__c();
                            quoteIds.add(quote.Id);
                            qlItem.BVCQuote__c = quote.Id;
                            
                            qlItem.Product__c = sp.ST_Product__c;
                            qlItem.Quantity__c = 1;
                            qlItem.Rate_Amount__c = sp.ST_Rate_Amount__c;
                            qlItem.Minimum_Freight__c = sp.ST_Minimum_Freight__c; 
                            qlItem.Product_Code__c = sp.Product_Code__c;
                            qlItem.Subrogation_Liability__c = sp.Subrogation_Liability__c;
                            qlItem.All_Risk_Liability__c = sp.All_Risk_Liability__c;
                            qlItem.Fidelity_Liability__c = sp.Fidelity_Liability__c;
                            qlItem.Offline_Charge__c = sp.ST_Offline_Charge__c;
                            qlItem.Remote_Location__c = sp.Remote_Location__c;
                            qlItem.Indirect_Location__c = sp.Indirect_Location__c;
                            qlItem.Fuel_Surcharge__c = sp.Fuel_Surcharge__c;
                            qlItem.Freight_on_Invoice_Value__c = sp.ST_Freight_on_Invoice_Value__c;
                            qlItem.Universe_Cost_Charge__c = sp.Universe_Cost_Charge__c;
                            qlItem.Product_Name__c = sp.Product__c;
                            qlItem.ACR_Standard_Price__c = sp.Id;
                            qlItem.Rate_UOM__c = sp.ST_Rate_UOM__c;
                            qlItem.Package_Type__c = sp.ST_ACR_Package_Type__c;
                            qlItem.Net_Unit_Price__c = sp.ST_ACR_Package_Amount__c;
                            qlItem.Liability_Coverage__c = sp.ST_Liability_Coverage__c;
                            qlList.add(qlItem);
                        }                        
                    }      
                }
            }            
        }
        if(quoteIds.size()>0 && qlList.size()>0)
        {
            List<BVCQuoteLineItem__c> deleteList = [select Id from BVCQuoteLineItem__c where BVCQuote__c IN : quoteIds];
            if(deleteList.size()>0)
            {
                delete deleteList;
                insert qlList;
            }
        }
    }
 }
public static void createeShipCustomPricing(List<BVCQuote__c> quoteList)
{
    List<eSHIP_Custom_Pricing__c> toCreate = new List<eSHIP_Custom_Pricing__c>();
    
    
    List<eSHIP_Standard_Pricing__c> standardPricingList = [SELECT Id,No_Of_Free_Atttemps__c ,Liability_Cover_By_BVC__c	,Additional_Charge__c,Gross_Weight_Unit_for_Additional_Weight__c,Liability_Charges__c,Weight_Charges__c,COD_Charges_percentage_of_product__c,COD_Charges_per_shipment__c,UOM_Percentage__c, Rate_INR__c,Weight_Covered_Gms__c,Logistice_Charges__c, Package_Amount__c FROM eSHIP_Standard_Pricing__c];
    
    for (BVCQuote__c q : quoteList)
    {
        eSHIP_Custom_Pricing__c singleRecord = new eSHIP_Custom_Pricing__c();
        singleRecord.Customer__c = q.Account__c;
        singleRecord.Package_Amount__c = q.Package_Amount__c;
        singleRecord.ACR_Amount__c = q.Net_Amount__c;
        singleRecord.Business_Type__c = q.Business_Type__c;
        singleRecord.BVCQuote__c = q.Id;
        for (eSHIP_Standard_Pricing__c standardPricing : standardPricingList)
        {
            if (standardPricing.Package_Amount__c == q.Package_Amount__c)
            {
                
                singleRecord.Rate_INR__c = standardPricing.Rate_INR__c;
                singleRecord.Weight_Covered_Gms__c = standardPricing.Weight_Covered_Gms__c;
                singleRecord.Logistice_Charges__c = standardPricing.Logistice_Charges__c;
                singleRecord.UOM_Percentage__c = standardPricing.UOM_Percentage__c;
                singleRecord.l_Liability_Cover_By_BVC__c = standardPricing.Liability_Cover_By_BVC__c	;
                singleRecord.COD_Charges_per_shipment__c = standardPricing.COD_Charges_per_shipment__c;
                singleRecord.COD_Charges_percentage_of_product__c = standardPricing.COD_Charges_percentage_of_product__c;
                singleRecord.Weight_Charges__c = standardPricing.Weight_Charges__c;
                singleRecord.Liability_Charges__c = standardPricing.Liability_Charges__c;
                singleRecord.Gross_Weight_Unit_for_Additional_Weight__c = standardPricing.Gross_Weight_Unit_for_Additional_Weight__c;
                singleRecord.Additional_Charge__c= standardPricing.Additional_Charge__c;
                singleRecord.No_Of_Free_Atttemps__c  = standardPricing.No_Of_Free_Atttemps__c;
                singleRecord.Latest_Pricing__c = True;
                //singleRecord.Fuel_Surcharge__c = standardPricing.Fuel_Surcharge__c;
                break; 
            }
        }

        toCreate.add(singleRecord);
    }

    if (toCreate.size() > 0)
    {
        insert toCreate;
    }
}

    
}