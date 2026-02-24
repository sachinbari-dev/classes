/*Description      	: to Generate Authority Letter PDF.
 *Author     		: rafi.khan@bvclogistics.com
 *Date       		: 28-02-2024
*/

public class TMS_AuthorityLetterPdfController {
    public List<Secure_Packaging__c> SelectedLabelList {get;set;}
    public static  List<Shipment__c> shipmentList{get;set;}
    public String BVgrossWeight { get; set; }
    public shipment__c ShipmentRecord { get; set; }
    public List<String> splitValues { get; set; }

    public TMS_AuthorityLetterPdfController(){
        String ShipId = ApexPages.currentPage().getParameters().get('id');
        system.debug('for checking ShipId '+ShipId);
        shipmentList = new List<Shipment__c>();
        if(string.isNotBlank(ShipId)){
            Shipment__c ship = new Shipment__c();
            ship = [Select Id, name,Reference_1__c,Pickup__r.Receiver_Name__c,Shipment_Date__c,Origin_Address_City__c,Pickup__r.Shipper_Name1__r.Name,Pickup__r.Shipper_Email__c,Pickup__r.Email_Sent_Date_Time__c, Origin_Address_Line_1__c,Origin_Address_Line_2__c,Secure_Bags__c,
                    Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,Customer__r.Name,Customer__r.Primary_GSTIN__c,Consignee_Name_TMS__r.Primary_GSTIN__c,
                    Number_of_Packages__c,Net_Weight__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,Shipper_Name_TMS__r.Primary_GSTIN__c,
                    Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,Number_of_Secure_Bags__c,Consignee_Name_TMS__r.PAN_Number_of_Entity__c,
                    Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,Shipper_Name_TMS__r.PAN_Number_of_Entity__c,
                    Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c, Multi_Product_Description__c,
                    SNN_Bar_Code__c,Shipment_Type__c,Origin_Hub__r.name,Destination_Hub__r.name,Pickup__r.name,CurrencyIsoCode,Gross_Weight__c,Gross_Weight_UOM_TMS__c,Net_Weight_UOM_TMS__c,Product_Description__c, Billing_Account__r.name,
                    Billing_Address__r.ADDRESS1__c,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,
                    Billing_Address__r.PINCODE__c,Billing_Address__r.Active_Pincode__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c,(Select Document_type__c From Customer_Documents__r)
                    FROM Shipment__c WHERE Id =:ShipId limit 1];
            system.debug('for checking ShipId '+ShipId);
            
            if(ship!=null){
                
                Decimal dec =  ship.Gross_Weight__c;
                String formattedValue = String.format('{0}', new List<Object>{dec});
                BVgrossWeight = formattedValue + ' ' + ship.Gross_Weight_UOM_TMS__c;
                
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
                ShipList = [Select Id, name,Reference_1__c,Pickup__r.Receiver_Name__c,Shipment_Date__c,Origin_Address_City__c,Pickup__r.Shipper_Name1__r.Name,Pickup__r.Shipper_Email__c,Pickup__r.Email_Sent_Date_Time__c, Origin_Address_Line_1__c,Origin_Address_Line_2__c,Secure_Bags__c,
                    Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,Customer__r.Name,Customer__r.Primary_GSTIN__c,Consignee_Name_TMS__r.Primary_GSTIN__c,
                    Number_of_Packages__c,Net_Weight__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,Shipper_Name_TMS__r.Primary_GSTIN__c,
                    Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,Number_of_Secure_Bags__c,Shipper_Name_TMS__r.PAN_Number_of_Entity__c,
                    Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,Consignee_Name_TMS__r.PAN_Number_of_Entity__c,
                    Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c, Multi_Product_Description__c,
                    SNN_Bar_Code__c,Shipment_Type__c,Origin_Hub__r.name,Destination_Hub__r.name,Pickup__r.name,CurrencyIsoCode,Gross_Weight__c,Gross_Weight_UOM_TMS__c,Net_Weight_UOM_TMS__c,Product_Description__c, Billing_Account__r.name,
                    Billing_Address__r.ADDRESS1__c,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,
                    Billing_Address__r.PINCODE__c,Billing_Address__r.Active_Pincode__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c
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
                }
                
            }
        }
    }
    
}