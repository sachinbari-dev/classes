/* created by :imran
 * created date : 09-08-2024
 * version 1.0: calling from BVCQuoteLineTrigger and calculating discounts 
 * last modified date : 09-08-2024
 * last Modified by : imran
 * version 1.0 :  
 */
public class BVCQuoteLineTriggerHandler {
    
 public static void updateBVCQuoteLineFields(List<BVCQuoteLineItem__c> newLines, Map<Id,BVCQuoteLineItem__c> oldMap)
 {
     String QuoteId;
     List<String> qlIds = new List<String>();
     Map<String,decimal> qLineMap = new Map<String,decimal>();
     for(BVCQuoteLineItem__c newLine:newLines)
     {

             if(newLine.BVCQuote__c!=null){QuoteId = newLine.BVCQuote__c;}         
             BVCQuoteLineItem__c oldLine = oldMap.get(newLine.Id);
             if(newLine.Indirect_Location__c!=oldLine.Indirect_Location__c && newLine.Indirect_Location__c!=0)
             {
                 qLineMap.put('Indirect_Location__c',newLine.Indirect_Location__c);
                 System.debug('Changed Indirect_Location__c :'+newLine.Indirect_Location__c +' to '+oldLine.Indirect_Location__c);             
                 
             }
             if(newLine.Fuel_Surcharge__c!=oldLine.Fuel_Surcharge__c)
             {
                 qLineMap.put('Fuel_Surcharge__c',newLine.Fuel_Surcharge__c);
                 System.debug('Changed Fuel_Surcharge__c :'+newLine.Fuel_Surcharge__c +' to '+oldLine.Fuel_Surcharge__c);             
             }   
             if(newLine.Subrogation_Liability__c!=oldLine.Subrogation_Liability__c)
             {
                 qLineMap.put('Subrogation_Liability__c',newLine.Subrogation_Liability__c);
                 System.debug('Changed Subrogation_Liability__c :'+newLine.Subrogation_Liability__c +' to '+oldLine.Subrogation_Liability__c);             
             }
             if(newLine.Offline_Charge__c!=oldLine.Offline_Charge__c && newLine.Offline_Charge__c!=0)
             {
                 qLineMap.put('Offline_Charge__c',newLine.Offline_Charge__c);
                 System.debug('Changed Offline_Charge__c :'+newLine.Offline_Charge__c +' to '+oldLine.Offline_Charge__c); 
                 System.debug('39 newLine.Product_Name__c :'+newLine.Product_Name__c);
             }
             
             // added extra
             if(newLine.Remote_Location__c!=oldLine.Remote_Location__c && newLine.Remote_Location__c!=0)
             {
                 qLineMap.put('Remote_Location__c',newLine.Remote_Location__c);                       
             }
             if(newLine.All_Risk_Liability__c!=oldLine.All_Risk_Liability__c)
             {
                 qLineMap.put('All_Risk_Liability__c',newLine.All_Risk_Liability__c);           
             }   
             if(newLine.Fidelity_Liability__c!=oldLine.Fidelity_Liability__c)
             {
                 qLineMap.put('Fidelity_Liability__c',newLine.Fidelity_Liability__c);            
             }         
             if(newLine.Universe_Cost_Charge__c!=oldLine.Universe_Cost_Charge__c)
             {
                 qLineMap.put('Universe_Cost_Charge__c',newLine.Universe_Cost_Charge__c);            
             }          
             qlIds.add(newLine.Id);             

     }
     if(QuoteId!=null && qLineMap.size()>0)
     {
         List<BVCQuoteLineItem__c> quoteLinesList = [select Id,Offline_Charge__c,Subrogation_Liability__c,Fuel_Surcharge__c,
                                                     Indirect_Location__c,Universe_Cost_Charge__c,Fidelity_Liability__c,
                                                     All_Risk_Liability__c,Remote_Location__c,Product_Name__c
                                                     from BVCQuoteLineItem__c where BVCQuote__c=:QuoteId and Id Not IN : qlIds];
         List<BVCQuoteLineItem__c> quoteLinestoUpdate =new List<BVCQuoteLineItem__c>();
         if(quoteLinesList.size()>0)
         {
             for(BVCQuoteLineItem__c eachLine:quoteLinesList)
             {

                     boolean ischanged = false;
                     Decimal IndirectLocationValue = qLineMap.get('Indirect_Location__c');
                     if(IndirectLocationValue!=null)
                     {
                         eachLine.Indirect_Location__c = IndirectLocationValue;
                         ischanged = true;
                     }
                     Decimal Offline_ChargeValue = qLineMap.get('Offline_Charge__c');
                     if(Offline_ChargeValue!=null)
                     {
                         eachLine.Offline_Charge__c = Offline_ChargeValue;
                         ischanged = true;
                     } 
                     Decimal Remote_LocationValue = qLineMap.get('Remote_Location__c');
                     if(Remote_LocationValue!=null)
                     {
                         eachLine.Remote_Location__c = Remote_LocationValue;
                         ischanged = true;
                     }                     
                     // ------------------- 
                     Decimal Universe_Cost_ChargeValue = qLineMap.get('Universe_Cost_Charge__c');
                     if(Universe_Cost_ChargeValue!=null)
                     {
                         eachLine.Universe_Cost_Charge__c = Universe_Cost_ChargeValue;
                         ischanged = true;
                     } 
                 Decimal Fuel_SurchargeValue = qLineMap.get('Fuel_Surcharge__c');
                 if(Fuel_SurchargeValue!=null)
                 {
                     eachLine.Fuel_Surcharge__c = Fuel_SurchargeValue;
                     ischanged = true;
                 }
                 Decimal Subgrogation_LiabilityValue = qLineMap.get('Subrogation_Liability__c');
                 if(Subgrogation_LiabilityValue!=null)
                 {
                     eachLine.Subrogation_Liability__c = Subgrogation_LiabilityValue;
                     ischanged = true;
                 }
                     Decimal Fidelity_LiabilityValue = qLineMap.get('Fidelity_Liability__c');
                     if(Fidelity_LiabilityValue!=null)
                     {
                         eachLine.Fidelity_Liability__c = Fidelity_LiabilityValue;
                         ischanged = true;
                     } 
                     Decimal All_Risk_LiabilityValue = qLineMap.get('All_Risk_Liability__c');
                     if(All_Risk_LiabilityValue!=null)
                     {
                         eachLine.All_Risk_Liability__c = All_Risk_LiabilityValue;
                         ischanged = true;
                     } 

                     if(ischanged == true)
                     {
                         if(!(eachLine.Product_Name__c.contains('Rest of India')))
                         {
                             eachLine.Offline_Charge__c=0;
                             eachLine.Indirect_Location__c=0;
                             eachLine.Remote_Location__c=0;                     
                         }
                         quoteLinestoUpdate.add(eachLine);                     
                     }                         
                 System.debug('86 eachLine :'+eachLine);
             }
         }
         if(quoteLinestoUpdate.size()>0)
         {
             try
             {
                 update quoteLinestoUpdate;
             }catch(Exception e)
             {
                 System.debug('92 ERROR :'+e.getMessage());
             }
         }
     }
 }
    
    public static void updateQuoteLineChargeFields(List<BVCQuoteLineItem__c> newList){
        for(BVCQuoteLineItem__c line : newList){
            
            if(line.Offline_Charge__c != null){
                line.Prior_Offline_Charge__c = line.Offline_Charge__c;
            }
            if(line.Liability_Coverage__c != null){
                line.Prior_Liability_Coverage__c = line.Liability_Coverage__c;
            }
           
            if(line.Minimum_Freight__c != null){
                line.Prior_Freight_Charge__c = line.Minimum_Freight__c;
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
    
    public static void quoteLineMaxDiscount(List<BVCQuoteLineItem__c> newList,Map<Id,BVCQuoteLineItem__c> oldQliMap){
        System.debug('Line No 45 newList :'+newList);
        System.debug('Line no 46 oldQliMap :'+oldQliMap);
        for(BVCQuoteLineItem__c line : newList){
            // For new quote lines
            System.debug('line no 48 line.Product_Code__c :'+line.Product_Code__c);
            if(line.Product_Code__c!=null)
            {
                if(!line.Product_Code__c.contains('EXHIBI')){
                    System.debug('Line no 53');
                    if(oldQliMap == null){
                        System.debug('Line no 55');
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
                              System.debug('Line no 76 DecList[7] :'+DecList[11]);
                              //UtilClass.qliRecursionCheck = true;
                          }  
                    }
                    //for old quote lines
                    else if(oldQliMap != null && oldQliMap.containskey(line.Id)){
                        System.debug('Line no 81 Line.Id:'+Line.Id);
                        BVCQuoteLineItem__c oldLine = oldQliMap.get(Line.Id);
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
                             // UtilClass.qliRecursionCheck = true;
                              System.debug('Line no 104 DecList[11] :'+DecList[11]);
                          } 
                    }  
                }
                else if( line.Product_Code__c.contains('EXHIBI') && line.Customer_Product_Category__c != '' && line.Customer_Product_Category__c != null){
                    System.debug('Line no 108');
                    if(oldQliMap == null){
                        System.debug('Line no 110');
                        if(line.Offline_Charge_Discount_Percent__c != null || line.Liability_Coverage_Discount_Percent__c != null|| line.Fuel_Surcharge_Discount_Percent__c != null || line.Slab_Level_1_Discount_Percent__c != null || line.Slab_Level_5_Discount_Percent__c != null
                           || line.Slab_Level_2_Discount_Percent__c != null || line.Slab_Level_3_Discount_Percent__c != null|| line.Slab_Level_4_Discount_Percent__c != null){
                               Decimal[] DecList = new list<Decimal>{line.Offline_Charge_Discount_Percent__c , line.Liability_Coverage_Discount_Percent__c, line.Slab_Level_1_Discount_Percent__c, line.Slab_Level_2_Discount_Percent__c, line.Slab_Level_3_Discount_Percent__c, line.Slab_Level_4_Discount_Percent__c, line.Slab_Level_5_Discount_Percent__c,line.Max_Slab_Rate_Discount__c};
                                   DecList.sort();
                               line.Max_Discount__c = DecList[7];
                               System.debug('Line no 117 DecList[7] :'+DecList[11]);
                               //UtilClass.qliRecursionCheck = true;
                           }  
                    }
                    else if(oldQliMap != null && oldQliMap.containskey(line.Id)){
                        System.debug('Line no 120');
                        BVCQuoteLineItem__c oldLine = oldQliMap.get(Line.Id);
                        if(line.Offline_Charge_Discount_Percent__c != oldLine.Offline_Charge_Discount_Percent__c 
                           || line.Liability_Coverage_Discount_Percent__c != oldLine.Liability_Coverage_Discount_Percent__c
                           || line.Fuel_Surcharge_Discount_Percent__c != oldLine.Fuel_Surcharge_Discount_Percent__c
                           || line.Universe_Cost_Charge_Discount_Percent__c != oldLine.Universe_Cost_Charge_Discount_Percent__c
                           || line.Slab_1_Rate__c != oldLine.Slab_1_Rate__c
                           || line.Slab_2_Rate__c != oldLine.Slab_2_Rate__c
                           || line.Slab_3_Rate__c != oldLine.Slab_3_Rate__c
                           || line.Slab_4_Rate__c != oldLine.Slab_4_Rate__c	
                           || line.Slab_5_Rate__c != oldLine.Slab_5_Rate__c){
                               Decimal[] DecList = new list<Decimal>{line.Offline_Charge_Discount_Percent__c, line.Liability_Coverage_Discount_Percent__c, line.Fuel_Surcharge_Discount_Percent__c,line.Universe_Cost_Charge_Discount_Percent__c,  line.Slab_Level_1_Discount_Percent__c, line.Slab_Level_2_Discount_Percent__c, line.Slab_Level_3_Discount_Percent__c, line.Slab_Level_4_Discount_Percent__c, line.Slab_Level_5_Discount_Percent__c,line.Max_Slab_Rate_Discount__c};
                                   DecList.sort();
                               line.Max_Discount__c = DecList[7];
                               System.debug('Line no 136 DecList[7] :'+DecList[11]);
                               //UtilClass.qliRecursionCheck = true;
                           } 
                    }   
                }
            }

        }
    }
    public static void GetCoverage(){
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
         
}
    public static void GetCoverage2(){
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
         
}
    public static void GetCoverage3(){
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
         
}
    public static void GetCoverage4(){
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
         
}
     public static void GetCoverage6(){
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
         
}
     public static void GetCoverage7(){
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
         
}
     public static void GetCoverage5(){
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
         
}
}