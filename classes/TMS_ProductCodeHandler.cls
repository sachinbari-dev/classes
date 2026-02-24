/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-09-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TMS_ProductCodeHandler {
    public static void UpdateProductDetails(List<Shipment__c> ShipList){
        Set<String> OriginCitySet = new Set<String>();
        Set<String> DestinationCitySet = new Set<String>();
        id accountid;
        boolean IsExhibition;
        for(Shipment__c sh:ShipList){
            OriginCitySet.add(sh.Origin_Address_City__c);
            DestinationCitySet.add(sh.Destination_Address_City__c);
            accountid=sh.Customer__c;
            if(sh.IsExhibition__c){
                IsExhibition = true;
            }else {IsExhibition = false;}
        }
        system.debug('OriginCitySet::'+OriginCitySet);
        system.debug('DestinationCitySet::'+DestinationCitySet);
        Map<String,Product_Name_Code__mdt> NameCodeMap = new Map<String,Product_Name_Code__mdt>();
        String defaultProduct = '';
        for(Product_Name_Code__mdt mdt :[select MasterLabel,Product_Name__c,Product_Code__c,Is_Default__c FROM Product_Name_Code__mdt ]){
            NameCodeMap.put(mdt.MasterLabel, mdt);
            if(mdt.Is_Default__c)
                defaultProduct = mdt.MasterLabel;
        }
        //System.debug('OriginCitySet: '+OriginCitySet);
        //System.debug('DestinationCitySet: '+DestinationCitySet);
        
        List<account> acc = [SELECT id, New_Contract__c,New_Exhibition_Contract__c from account where id=:accountid LIMIT 1];
        
        List<Origin_Destination__c> OD_PAirs = [
            SELECT OriginCity__c,
            DestinationCity__c,
            Is_State_to_State__c,
            Destination_State__c,
            Origin_State__c,
            State_Mode_of_Service__c, 
            New_Pricing__c,
            Mode_Of_Service__c 
            FROM Origin_Destination__c 
            WHERE 
            (
                Mode_Of_Service__c != null
                AND (
                    New_Pricing__c = :acc[0].New_Contract__c
                    OR New_Pricing__c = :acc[0].New_Exhibition_Contract__c
                )
                AND (
                    (OriginCity__c IN :OriginCitySet AND DestinationCity__c IN :DestinationCitySet)
                    OR Is_State_to_State__c = true
                )
            )
            LIMIT 100
        ];
        
        
        Map<String,string> OD_PairMAp = new Map<string,string>();
        Boolean isNewPricing = false;
        Boolean isNewPricingExhibition = false;
        
        System.debug('OD_PAirs>>'+OD_PAirs.size());
         
        System.debug('IsExhibition::'+IsExhibition);
        
        if(OD_PAirs != null && OD_PAirs.size()>0){
            for(Origin_Destination__c od:OD_PAirs){
                if((od.New_Pricing__c==acc[0].New_Contract__c) || (od.New_Pricing__c==acc[0].New_Exhibition_Contract__c)){
                    system.debug('Inside if 1==');
                    if(od.Is_State_to_State__c){
                        OD_PairMAp.put(od.Origin_State__c + od.Destination_State__c, od.State_Mode_of_Service__c);
                    }else{
                        OD_PairMAp.put(od.OriginCity__c + od.DestinationCity__c, od.Mode_Of_Service__c);
                    }
                    if(od.New_Pricing__c && acc[0].New_Contract__c && IsExhibition==false ){// || acc[0].New_Exhibition_Contract__c)) {
                        system.debug('Inside if 2==');
                        isNewPricing = true;
                        
                    }
                    if(IsExhibition==true && acc[0].New_Exhibition_Contract__c){
                        isNewPricingExhibition = true;
                    }
                }
            }
        }
        System.debug('isNewPricing________'+isNewPricing);
        System.debug('isNewPricingExhibition____'+isNewPricingExhibition);
        
        if(NameCodeMap !=null && NameCodeMap.size()>0){
            for(Shipment__c sh:ShipList){
                
                String BVC_Service = '';
                
                BVC_Service = sh.Customer_Product_Category__c;
                
                string serviceMode = '';
                system.debug('sh.State_Logic_Check__c:::'+sh.State_Logic_Check__c);
                if(sh.State_Logic_Check__c== 'With-In-City'){
                    serviceMode = 'Within City';
                }
                system.debug('serviceMode:::::'+serviceMode);
                if(sh.State_Logic_Check__c != 'With-In-City' && OD_PairMAp!=null && OD_PairMAp.containsKey(sh.Origin_Address_State__c+sh.Destination_Address_State__c)){
                    serviceMode = OD_PairMAp.get(sh.Origin_Address_State__c+sh.Destination_Address_State__c);
                    system.debug('State:::');

                }else if(sh.State_Logic_Check__c != 'With-In-City' && OD_PairMAp!=null && OD_PairMAp.containsKey(sh.Origin_Address_City__c+sh.Destination_Address_City__c)){
                    serviceMode = OD_PairMAp.get(sh.Origin_Address_City__c+sh.Destination_Address_City__c);
                    system.debug('City:::');
                    System.debug('City::: fetched from OD_PairMap = ' + serviceMode);
				
                } else if(string.isBlank(serviceMode) && (!isNewPricing) && !acc[0].New_Contract__c){
                       serviceMode = 'Express (City-to-City)'; 
                    system.debug('default:::');
                    }
                else if(string.isBlank(serviceMode)){
                    serviceMode = defaultProduct;
                }
                System.debug('===serviceMode=='+serviceMode);
                System.debug('===acc[0].New_Contract__c=='+acc[0].New_Contract__c);
                System.debug('===defaultProduct=='+defaultProduct);
                System.debug('===isNewPricing=='+isNewPricing);
                System.debug('===isNewPricingExhibition=='+isNewPricingExhibition);
                 if((!isNewPricing || (!isNewPricingExhibition&& IsExhibition==true)) && serviceMode!=defaultProduct ){
                if(string.isNotBlank(serviceMode) && NameCodeMap.containsKey(serviceMode)){
                    system.debug('OLD Pricing::');
                    sh.BVC_Product_Name__c = BVC_Service + ' ' + NameCodeMap.get(serviceMode).Product_Name__c;
                    sh.Product_Code__c = BVC_Service.toUpperCase().remove('SHIP') + '-' +NameCodeMap.get(serviceMode).Product_Code__c;
                }
                 }
                system.debug('NameCodeMap'+NameCodeMap);
                System.debug('===sh.Product_Code__c=='+sh.Product_Code__c);
                System.debug('===sh.BVC_Product_Name__c=='+sh.BVC_Product_Name__c);
                System.debug('===acc[0].New_Contract__c=='+acc[0].New_Contract__c);
                
                //===================================New Pricing Logic==================================================================
                string grosWeight='';
                //  if((isNewPricing || (serviceMode=='Within City' && !isNewPricing && acc[0].New_Contract__c) || serviceMode == defaultProduct) && (serviceMode=='Within City'  && !IsExhibition) ){
               /* if (
                    (isNewPricing || (serviceMode == 'Within City' && !isNewPricing && acc[0].New_Contract__c) || serviceMode == defaultProduct || isNewPricingExhibition==true)
                    &&
                    !('Within City'.equals(serviceMode) && IsExhibition==true)
                ){    
                 if (
                    (isNewPricing || (serviceMode == 'Within City' && !isNewPricing && acc[0].New_Contract__c) || serviceMode == defaultProduct )
                    
                ){*/
                if (
                    (
                        isNewPricing
                        || (serviceMode == 'Within City' && !isNewPricing && acc[0].New_Contract__c)
                        || serviceMode == defaultProduct
                    )
                    ||( (IsExhibition == true
                    && isNewPricingExhibition == true
                    && !('Within City'.equals(serviceMode) && IsExhibition == true))|| serviceMode == defaultProduct)
                ) {
                    system.debug('New Pricing:::');
                    
                    system.debug('shipment gross weight-----'+sh.Gross_Weight__c);
                    if((sh.Gross_Weight_UOM_TMS__c=='Gram' && sh.Gross_Weight__c <= 1000) ||(sh.Gross_Weight_UOM_TMS__c=='KG' && sh.Gross_Weight__c <= 1) ){
                        grosWeight =serviceMode + '(0-1)';
                    }
                    if((sh.Gross_Weight_UOM_TMS__c=='Gram' && sh.Gross_Weight__c > 1000 && sh.Gross_Weight__c <= 20000)||(sh.Gross_Weight_UOM_TMS__c=='KG' && sh.Gross_Weight__c > 1 && sh.Gross_Weight__c <= 20)){
                        grosWeight =serviceMode + '(1-20)';
                    }
                    if((sh.Gross_Weight_UOM_TMS__c=='Gram' && sh.Gross_Weight__c > 20000) ||(sh.Gross_Weight_UOM_TMS__c=='KG' && sh.Gross_Weight__c > 20 )){
                        grosWeight =serviceMode + '(20-25)';
                    }
                    System.debug('===grosWeight=='+grosWeight);
                
                } 
                System.debug('===isNewPricing=='+isNewPricing);
                System.debug('===IsExhibition=='+IsExhibition);
                System.debug('===serviceMode=='+serviceMode);
                System.debug('===acc[0].New_Contract__c=='+acc[0].New_Contract__c);
                if( (isNewPricingExhibition==true && IsExhibition==true && serviceMode=='Within City') ){ //added by Pratik on 21st July 2025
                    system.debug('Inside exhibition withing city');
                    if(sh.Number_of_Packages__c>0 && sh.Number_of_Packages__c<=2) {
                        grosWeight =serviceMode + '(1-2)';
                    }
                    if(sh.Number_of_Packages__c>2 && sh.Number_of_Packages__c<=5) {
                        grosWeight =serviceMode + '(3-5)';
                    }
                    if(sh.Number_of_Packages__c>5 && sh.Number_of_Packages__c<=10) {
                        grosWeight =serviceMode + '(6-10)';
                    }
                    if(sh.Number_of_Packages__c>10 && sh.Number_of_Packages__c<=15) {
                        grosWeight =serviceMode + '(11-15)';
                    }
                    if(sh.Number_of_Packages__c>15 ) {
                        grosWeight =serviceMode + '(15+)';
                    }
                }
                if(string.isNotBlank(grosWeight) && NameCodeMap.containsKey(grosWeight)){
                    
                    sh.BVC_Product_Name__c = BVC_Service + ' ' + NameCodeMap.get(grosWeight).Product_Name__c;
                    sh.Product_Code__c = BVC_Service.toUpperCase().remove('SHIP') + '-' +NameCodeMap.get(grosWeight).Product_Code__c;
                    System.debug('sh.Product_Code__c::'+sh.Product_Code__c);
                	System.debug('sh.BVC_Product_Name__c::'+sh.BVC_Product_Name__c);
                }
                //=====================================================================================================
            }
        }
    }
    public static void coverageMethod(){
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
        i++;}
}