public class TMS_ShipmentPdfController1 {
    public List<Secure_Packaging__c> SelectedLabelList {get;set;}
    public static  List<Shipment__c> shipmentList{get;set;}
    public static  List<Secure_Bag__c> SecureBagList{get;set;}
    public String BVgrossWeight { get; set; }
    public shipment__c ShipmentRecord { get; set; }
    public static List<String> SecureBagNames { get; set; }
    public List<String> secureBagNamessplit { get; set; }
    public List<String> RefNamessplit { get; set; }      
    public List<String> additionalBags { get; set; }
    public List<String> additionalRefs { get; set; }
    public String additionalInformation { get; set; }
    public List<String> rowData { get; set; }
    public List<String> RefrowData { get; set; }
    public String[] allBags {get;set;}
    public String[] allrefs {get;set;}
    public string[]  allvalues {get;set;}
    public string[] allNetWeight{get;set;}
    public string[] allProdDesc{get;set;}
    // added by Imran
    
	public Map<String,List<String>> allrefs1 = new Map<String,List<String>>(); 	
    public Map<String,List<String>> allProdDesc1 = new Map<String,List<String>>();
    public Map<String,List<String>>  allvalues1 = new Map<String,List<String>>();
    public Map<String,List<String>> allNetWeight1 = new Map<String,List<String>>();
    public Map<String,List<String>> allBags1 = new Map<String,List<String>>();
    List<String> ar = new List<String>();
    List<String> pd = new List<String>();
    List<String> avl = new List<String>();
    List<String> anwv = new List<String>();
    List<String> abgs = new List<String>();
   
    // upto here
   //  public String concatenatedValue { get; set; }
    public List<String> splitValues { get; set; }
  
    public TMS_ShipmentPdfController1(){
            
        
        String ShipId = ApexPages.currentPage().getParameters().get('id');
        system.debug('@@@@@@@ ::'+ShipId);
        shipmentList = new List<Shipment__c>();
        if(string.isNotBlank(ShipId)){
            Shipment__c ship = new Shipment__c();
            ship = [Select Id, name,Reference_1__c,Pickup__r.Receiver_Name__c,Shipment_Date__c,Origin_Address_City__c,Pickup__r.Shipper_Name1__r.Name,Pickup__r.Shipper_Email__c,Pickup__r.Email_Sent_Date_Time__c, Origin_Address_Line_1__c,Origin_Address_Line_2__c,Secure_Bags__c,
                    Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,Customer__r.Name,
                    Number_of_Packages__c,Net_Weight__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,
                    Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,
                    Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,
                    Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c,
                    SNN_Bar_Code__c,Shipment_Type__c,Multi_Invoice_Value__c,Multi_Net_Weight__c,Multi_Product_Description__c,Customer_Gross_Weight__c,Delivery_Route_Number__c,E_Waybill_Number__c,Chargeable_Weight__c,Liability_Cover_By_BVC__c,Origin_Hub__r.hub_city__c,Origin_Hub__r.name,Destination_Hub__r.hub_city__c,Destination_Hub__r.name,Pickup__r.name,CurrencyIsoCode,Gross_Weight__c,Gross_Weight_UOM_TMS__c,Net_Weight_UOM_TMS__c,Product_Description__c, Billing_Account__r.name,
                    Billing_Address__r.ADDRESS1__c,Delivery_Route_Number__r.name,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,
                    Billing_Address__r.PINCODE__c,Billing_Address__r.Active_Pincode__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c
                    FROM Shipment__c WHERE Id =:ShipId limit 1];
            system.debug('@@@@@@@ ::'+ShipId);
           //added by govind from line 30 to 102
            if(ship.Secure_Bags__c != null){
                    allBags = ship.Secure_Bags__c.split(',');
              
            }
          
            if(ship.Reference_1__c != null){
                
                allrefs = ship.Reference_1__c.split(',');
             
            }
            
            if(ship.Multi_Invoice_Value__c != null){     
                  allvalues = ship.Multi_Invoice_Value__c.split(',');
            }
             if(ship.Multi_Net_Weight__c != null){
                  allNetWeight = ship.Multi_Net_Weight__c.split(',');
            }
             if(ship.Multi_Product_Description__c != null){     
                  allProdDesc = ship.Multi_Product_Description__c.split(',');
            }
            
            if(ship!=null){
                Decimal dec =  ship.Gross_Weight__c;
                String formattedValue = String.format('{0}', new List<Object>{dec});
                BVgrossWeight = formattedValue + ' ' + ship.Gross_Weight_UOM_TMS__c;
          
             SecureBagList = new List<Secure_Bag__c>();
           List<Secure_Bag__c> SecureBag= [Select Secure_Packaging_Identifier__c From Secure_Bag__c Where Shipment__c=:ShipId];
            For(Secure_Bag__c S:SecureBag){
                  SecureBagList.add(S);
            }
            SecureBagNames = new List<String>();
        for (Secure_Bag__c sb : SecureBag) {
            SecureBagNames.add(sb.Secure_Packaging_Identifier__c);
        }
        }
            if (String.isNotBlank(BVgrossWeight)) {
            splitValues = BVgrossWeight.split(',');
        }
            if(ship.Invoice_Number__c!=null&&ship.Invoice_Number__c.length()>40){
                Integer ir=0;
                ir=ship.Invoice_Number__c.length()/35;
                for(Integer i=1;i<=ir;i++){
                    ship.Invoice_Number__c=ship.Invoice_Number__c.substring(0, i*35) + ' ' + ship.Invoice_Number__c.substring(i*35);
                }
            }
            shipmentList.add(ship);
            shipmentList.add(ship);
        }else{
            string pageType = ApexPages.currentPage().getParameters().get('type');
            if(pageType=='pre'){
                String[] ids = ApexPages.currentPage().getParameters().get('list').split(',');
                SelectedLabelList = [select id, name,Status__c FROM Secure_Packaging__c WHERE id=:ids];
            }
            else if(pageType=='post'){
                String[] ids = ApexPages.currentPage().getParameters().get('list').split(',');
                List<Shipment__c> ShipList = new List<Shipment__c>();
                set<id> shiId = new set<id>();
                ShipList = [Select Id, name,Shipment_Date__c,Reference_1__c,Pickup__r.Receiver_Name__c,Pickup__r.Shipper_Name1__r.Name,Pickup__r.Shipper_Email__c,Origin_Address_City__c,Pickup__r.Email_Sent_Date_Time__c, Origin_Address_Line_1__c,Origin_Address_Line_2__c,Secure_Bags__c,
                            Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,Customer__r.Name,
                            Number_of_Packages__c,Net_Weight__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,
                            Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,
                            Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,
                            Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c,
                            SNN_Bar_Code__c,Shipment_Type__c,Delivery_Route_Number__c,E_Waybill_Number__c,Chargeable_Weight__c,Liability_Cover_By_BVC__c,Origin_Hub__r.hub_city__c,Origin_Hub__r.name,Destination_Hub__r.hub_city__c,Destination_Hub__r.name,Pickup__r.name,CurrencyIsoCode,Gross_Weight__c,Gross_Weight_UOM_TMS__c,Net_Weight_UOM_TMS__c,Product_Description__c,Billing_Account__r.name,
                            Billing_Address__r.ADDRESS1__c,Multi_Invoice_Value__c,Multi_Net_Weight__c,Multi_Product_Description__c,Customer_Gross_Weight__c,Delivery_Route_Number__r.name,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,
                            Billing_Address__r.PINCODE__c,Billing_Address__r.Active_Pincode__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c,
                            (select Id from Customer_Documents__r)
                            FROM Shipment__c WHERE Id in:ids  order by createddate DESC limit 50000];
                for(Shipment__c sh:ShipList){
                    if(sh.Invoice_Number__c!=null&&sh.Invoice_Number__c.length()>40){
                        Integer ir=0;
                        ir=sh.Invoice_Number__c.length()/35;
                        for(Integer i=1;i<=ir;i++){
                            sh.Invoice_Number__c=sh.Invoice_Number__c.substring(0, i*35) + ' ' + sh.Invoice_Number__c.substring(i*35);
                        }
                    }
                    shipmentList.add(sh);
                    shipmentList.add(sh);
                }
              //added by govind  from line 169 to 239
                for(shipment__c s :  shipList){
                     if(s.Secure_Bags__c != null){
                    // allBags = s.Secure_Bags__c.split(',');                          
                         abgs.addAll(s.Secure_Bags__c.split(','));
                         System.debug('<== abgs :'+abgs);
                         allBags1.put(s.Id,abgs);

                    }
                  
                    if(s.Reference_1__c != null){
                        System.debug('<= Ref :'+s.Reference_1__c);
                       // allrefs = s.Reference_1__c.split(',');
                     	ar.addAll(s.Reference_1__c.split(','));
                        System.debug('<== ar :'+ar);
                        allrefs1.put(s.Id,ar);

                    }
                    
                    if(s.Multi_Invoice_Value__c != null){     
                         // allvalues = s.Multi_Invoice_Value__c.split(',');
                        avl.addAll(s.Multi_Invoice_Value__c.split(','));
                        System.debug('<== avl :'+avl);
                        allvalues1.put(s.Id,avl);

                    }
                     if(s.Multi_Net_Weight__c != null){
                         // allNetWeight = s.Multi_Net_Weight__c.split(',');
                         anwv.addAll(s.Multi_Net_Weight__c.split(','));
                         System.debug('<== anwv :'+anwv);
                         allNetWeight1.put(s.Id,anwv);

                    }
                     if(s.Multi_Product_Description__c != null){     
                        // allProdDesc = s.Multi_Product_Description__c.split(',');
                         pd.addAll(s.Multi_Product_Description__c.split(','));
                         System.debug('<== pd :'+pd);
                         allProdDesc1.put(s.Id,pd);

                    }  
                    System.debug('<== Inside PDF ==>');
                    System.debug('<== Inside PDF allrefs1 ==>'+allrefs1);
                    System.debug('<== Inside PDF allProdDesc1 ==>'+allProdDesc1);
                    System.debug('<== Inside PDF allvalues1 ==>'+allvalues1);
                    System.debug('<== Inside PDF allNetWeight1 ==>'+allNetWeight1);
                    System.debug('<== Inside PDF allBags1 ==>'+allBags1);
                    /*
                    System.debug('<== Inside PDF 11 ==>');
					allProdDesc1.put(s.Id,pd); 
                    allNetWeight1.put(s.Id,anwv); 		// added by Imran
                    allvalues1.put(s.Id,avl); 		// added by Imran
                    allrefs1.put(s.Id,ar); 		// added by Imran
                    allBags1.put(s.Id,abgs); 		// added by Imran
                    System.debug('allProdDesc1 :'+allProdDesc1.get(s.Id));
					
                    System.debug('<== Inside PDF 11 ==>');
                     System.debug('allProdDesc1 :'+allProdDesc1.get(s.Id));
					allProdDesc1.put(s.Id,pd); 
                    allNetWeight1.put(s.Id,anwv); 		// added by Imran
                    allvalues1.put(s.Id,avl); 		// added by Imran
                    allrefs1.put(s.Id,ar); 		// added by Imran
                    allBags1.put(s.Id,abgs); 		// added by Imran
                    System.debug('allProdDesc1 :'+allProdDesc1.get(s.Id)); */
                }
                
               // sanket's code
             SecureBagList = new List<Secure_Bag__c>();
           List<Secure_Bag__c> SecureBag= [Select Secure_Packaging_Identifier__c From Secure_Bag__c Where Shipment__c=:ShipList];
            
            SecureBagNames = new List<String>();
        for (Secure_Bag__c sb : SecureBag) {
            SecureBagNames.add(sb.Secure_Packaging_Identifier__c);
        }
         
            } 
        }
    }
     public String formatCurrency(Decimal value) {
        String formattedValue = '';
        Integer integerPart = (Integer)value;
        Decimal decimalPart = value - integerPart;
        formattedValue += addCommasToIntegerPart(integerPart);
        formattedValue += '.' + addDecimalPart(decimalPart);
        return formattedValue;
    }
    private String addCommasToIntegerPart(Integer value) {
        String integerPart = String.valueOf(value);
        String formattedIntegerPart = '';
        while (integerPart.length() > 3) {
            formattedIntegerPart = ',' + integerPart.substring(integerPart.length() - 3, integerPart.length()) + formattedIntegerPart;
            integerPart = integerPart.substring(0, integerPart.length() - 3);
        }
        formattedIntegerPart = integerPart + formattedIntegerPart;
        return formattedIntegerPart;
    }
    private String addDecimalPart(Decimal value) {
        String decimalPart = String.valueOf(value);
        decimalPart = decimalPart.substringAfter('.');
        decimalPart = (decimalPart + '00').substring(0, 2); // Ensuring two decimal places
        return decimalPart;
    }
    
}