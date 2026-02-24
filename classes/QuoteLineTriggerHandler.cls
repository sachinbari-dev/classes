public with sharing class QuoteLineTriggerHandler {
    
    public static void dummyMethod(){
        
    }
    /*********************************************************************************************
    		test class- QuoteTriggerTest
    *********************************************************************************************/
   /* public static void updateQuoteLineChargeFields(List<SBQQ__QuoteLine__c> newList){
        for(SBQQ__QuoteLine__c line : newList){
            
            if(line.ST_Offline_Charge__c != null){
                line.Prior_Offline_Charge__c = line.ST_Offline_Charge__c;
            }
            if(line.ST_Liability_Coverage__c != null){
                line.Prior_Liability_Coverage__c = line.ST_Liability_Coverage__c;
            }
           
            if(line.ST_Minimum_Freight__c != null){
                line.Prior_Freight_Charge__c = line.ST_Minimum_Freight__c;
            }
             if(line.Fuel_Surcharge__c != null){
                line.Prior_Fuel_Surcharge__c = line.Fuel_Surcharge__c;
            }
            if(line.Universe_Cost_Charge__c != null){
                line.Prior_Universe_Cost_Charge__c = line.Universe_Cost_Charge__c;
            }
            if(line.Remote_Location__c != null){
                line.Prior_Remote_charge__c = line.Remote_Location__c;
            }
            if(line.Indirect_Location__c != null){
                line.Prior_Indirect_Charge__c = line.Indirect_Location__c;
            }
            if(line.Subrogation_Liability__c != null){
                line.Prior_Subrogation_charge__c = line.Subrogation_Liability__c;
            }
            if(line.All_Risk_Liability__c != null){
                line.Prior_All_Risk_liability_charge__c = line.All_Risk_Liability__c;
            }
            if(line.Fidelity_Liability__c != null){
                line.Prior_Fidelity_charge__c = line.Fidelity_Liability__c;
            }
            
           UtilClass.qliRecursionCheck = true;
        }
    }
    
    public static void quoteLineMaxDiscount(List<SBQQ__QuoteLine__c> newList,Map<Id,SBQQ__QuoteLine__c> oldQliMap){
        for(SBQQ__QuoteLine__c line : newList){
            // For new quote lines
            if(!line.SBQQ__ProductCode__c.contains('EXHIBI')){
                if(oldQliMap == null){
                    if(line.STT_Freight_Invoice_Value__c != null ||
                       line.ST_Rate_Discount__c != null  
                       || line.Offline_Charge_Discount_Percent__c != null 
                       || line.ST_Minimum_Percent__c != null  
                       || line.Liability_Coverage_Discount_Percent__c != null
                       || line.Fuel_Surcharge_Discount_Percent__c != null
                       || line.Universe_Cost_Charge_Discount_Percent__c != null
                       || line.Remote_Location_Discount_Percent__c != null
                       || line.Indirect_Location_Discount_Percent__c != null
                       || line.Subrogation_Liability_Discount_Percent__c != null
                       || line.All_Risk_Liability_Discount_Percent__c != null
                       || line.Fidelity_Liability_Discount_Percent__c != null
                      ){
                           Decimal[] DecList = new list<Decimal>{line.ST_Minimum_Percent__c, line.Offline_Charge_Discount_Percent__c,line.STT_Freight_Invoice_Value__c, 
                               										line.ST_Rate_Discount__c, line.Liability_Coverage_Discount_Percent__c,line.Fuel_Surcharge_Discount_Percent__c,
                               										line.Universe_Cost_Charge_Discount_Percent__c,line.Remote_Location_Discount_Percent__c,
                               										line.Indirect_Location_Discount_Percent__c,line.Subrogation_Liability_Discount_Percent__c,
                               										line.All_Risk_Liability_Discount_Percent__c,line.Fidelity_Liability_Discount_Percent__c};
                           DecList.sort();// sort ascending. Max discount will be last in the list
                           line.Max_Discount__c = DecList[11];// Taking max discount and putting in the field
                           UtilClass.qliRecursionCheck = true;
                    }  
                }
                //for old quote lines
                else if(oldQliMap != null && oldQliMap.containskey(line.Id)){
                    SBQQ__QuoteLine__c oldLine = oldQliMap.get(Line.Id);
                    if(line.STT_Freight_Invoice_Value__c != oldLine.STT_Freight_Invoice_Value__c
                       || line.ST_Rate_Discount__c != oldLine.ST_Rate_Discount__c 
                       || line.Offline_Charge_Discount_Percent__c != oldLine.Offline_Charge_Discount_Percent__c 
                       || line.ST_Minimum_Percent__c != oldLine.ST_Minimum_Percent__c
                       || line.Liability_Coverage_Discount_Percent__c != oldLine.Liability_Coverage_Discount_Percent__c
                       || line.Fuel_Surcharge_Discount_Percent__c != oldLine.Fuel_Surcharge_Discount_Percent__c
                       || line.Universe_Cost_Charge_Discount_Percent__c != oldLine.Universe_Cost_Charge_Discount_Percent__c
                       || line.Remote_Location_Discount_Percent__c != oldLine.Remote_Location_Discount_Percent__c
                       || line.Indirect_Location_Discount_Percent__c != oldLine.Indirect_Location_Discount_Percent__c
                       || line.Subrogation_Liability_Discount_Percent__c != oldLine.Subrogation_Liability_Discount_Percent__c
                       || line.All_Risk_Liability_Discount_Percent__c != oldLine.All_Risk_Liability_Discount_Percent__c
                       || line.Fidelity_Liability_Discount_Percent__c != oldLine.Fidelity_Liability_Discount_Percent__c
                      ){
                           Decimal[] DecList = new list<Decimal>{line.ST_Minimum_Percent__c, line.Offline_Charge_Discount_Percent__c,line.STT_Freight_Invoice_Value__c,
                               									line.ST_Rate_Discount__c, line.Liability_Coverage_Discount_Percent__c, line.Fuel_Surcharge_Discount_Percent__c, 
                               									line.Universe_Cost_Charge_Discount_Percent__c,line.Remote_Location_Discount_Percent__c,
                               									line.Indirect_Location_Discount_Percent__c,line.Subrogation_Liability_Discount_Percent__c,
                               									line.All_Risk_Liability_Discount_Percent__c,line.Fidelity_Liability_Discount_Percent__c};
                           DecList.sort(); // sort ascending. Max discount will be last in the list
                           line.Max_Discount__c = DecList[11]; // Taking max discount and putting in the field
                           UtilClass.qliRecursionCheck = true;
                    } 
                }  
            }
            else if( line.SBQQ__ProductCode__c.contains('EXHIBI') && line.ST_Customer_Product_Category__c != '' && line.ST_Customer_Product_Category__c != null){
               		 if(oldQliMap == null){
                    if(line.Offline_Charge_Discount_Percent__c != null || line.Liability_Coverage_Discount_Percent__c != null|| line.Fuel_Surcharge_Discount_Percent__c != null || line.Slab_Level_1_Discount_Percent__c != null || line.Slab_Level_5_Discount_Percent__c != null
                       || line.Slab_Level_2_Discount_Percent__c != null || line.Slab_Level_3_Discount_Percent__c != null|| line.Slab_Level_4_Discount_Percent__c != null){
                      	   Decimal[] DecList = new list<Decimal>{line.Offline_Charge_Discount_Percent__c , line.Liability_Coverage_Discount_Percent__c, line.Slab_Level_1_Discount_Percent__c, line.Slab_Level_2_Discount_Percent__c, line.Slab_Level_3_Discount_Percent__c, line.Slab_Level_4_Discount_Percent__c, line.Slab_Level_5_Discount_Percent__c,line.Max_Slab_Rate_Discount__c};
                          	   DecList.sort();
                           line.Max_Discount__c = DecList[7];
                           UtilClass.qliRecursionCheck = true;
                    }  
                }
                else if(oldQliMap != null && oldQliMap.containskey(line.Id)){
                    SBQQ__QuoteLine__c oldLine = oldQliMap.get(Line.Id);
                    if(line.Offline_Charge_Discount_Percent__c != oldLine.Offline_Charge_Discount_Percent__c 
                       || line.Liability_Coverage_Discount_Percent__c != oldLine.Liability_Coverage_Discount_Percent__c
                       || line.Fuel_Surcharge_Discount_Percent__c != oldLine.Fuel_Surcharge_Discount_Percent__c
                       || line.Universe_Cost_Charge_Discount_Percent__c != oldLine.Universe_Cost_Charge_Discount_Percent__c
                       || line.Slab_Level_1_Rate__c != oldLine.Slab_Level_1_Rate__c
                       || line.Slab_Level_2_Rate__c != oldLine.Slab_Level_2_Rate__c
                       || line.Slab_Level_3_Rate__c != oldLine.Slab_Level_3_Rate__c
                       || line.Slab_Level_4_Rate__c != oldLine.Slab_Level_4_Rate__c
                       || line.Slab_Level_5_Rate__c != oldLine.Slab_Level_5_Rate__c){
                           Decimal[] DecList = new list<Decimal>{line.Offline_Charge_Discount_Percent__c, line.Liability_Coverage_Discount_Percent__c, line.Fuel_Surcharge_Discount_Percent__c,line.Universe_Cost_Charge_Discount_Percent__c,  line.Slab_Level_1_Discount_Percent__c, line.Slab_Level_2_Discount_Percent__c, line.Slab_Level_3_Discount_Percent__c, line.Slab_Level_4_Discount_Percent__c, line.Slab_Level_5_Discount_Percent__c,line.Max_Slab_Rate_Discount__c};
                               DecList.sort();
                           line.Max_Discount__c = DecList[7];
                           UtilClass.qliRecursionCheck = true;
                       } 
                }   
            }
        }
    }*/
    
}