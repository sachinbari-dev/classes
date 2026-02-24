/**
* @File Name : GenerateLabelController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 24, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 24, 2025 |   | Initial Version
**/

public class GenerateLabelController {
	@AuraEnabled
	public static List<Shipment__c> shipmentsList(List<String> idList){
                List<Shipment__c> shipList = new List<Shipment__c>();
                if(idList.size()>0)
                {
                   shipList = [Select Id, name,Reference_1__c,Pickup__r.Receiver_Name__c,Shipment_Date__c,Pickup__c,Destination_Hub__c,Origin_Hub__c,
                                Origin_Address_City__c,Pickup__r.Shipper_Name1__r.Name,Pickup__r.Shipper_Email__c,Pickup__r.Email_Sent_Date_Time__c, 
                                Origin_Address_Line_1__c,Origin_Address_Line_2__c,Secure_Bags__c,Pickup__r.Shipper_Name1__c,
                                Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,Customer__r.Name,
                                Number_of_Packages__c,Net_Weight__c,Additional_Remarks__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,
                                Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,Consignee_Name_TMS__c,
                                Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,
                                Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c,
                                SNN_Bar_Code__c,Shipment_Type__c,Multi_Invoice_Value__c,Multi_Net_Weight__c,Multi_Product_Description__c,Customer_Gross_Weight__c,Delivery_Route_Number__c,E_Waybill_Number__c,Chargeable_Weight__c,
                                Liability_Cover_By_BVC__c,Origin_Hub__r.hub_city__c,Origin_Hub__r.name,Destination_Hub__r.hub_city__c,Destination_Hub__r.name,Pickup__r.name,
                                CurrencyIsoCode,Gross_Weight__c,Gross_Weight_UOM_TMS__c,Net_Weight_UOM_TMS__c,Product_Description__c, Billing_Account__r.name,
                                Billing_Address__r.ADDRESS1__c,Delivery_Route_Number__r.name,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,Origin_Type__c,Destination_Type__c,
                                Billing_Address__r.PINCODE__c,Billing_Address__r.Active_Pincode__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c,Sender_Name__r.MobilePhone,Reciever_Name__r.MobilePhone
                                FROM Shipment__c where Id IN : idList];
                }
                else
                {
                 shipList = [Select Id, name,Reference_1__c,Pickup__r.Receiver_Name__c,Shipment_Date__c,Pickup__c,Destination_Hub__c,Origin_Hub__c,
                                Origin_Address_City__c,Pickup__r.Shipper_Name1__r.Name,Pickup__r.Shipper_Email__c,Pickup__r.Email_Sent_Date_Time__c, 
                                Origin_Address_Line_1__c,Origin_Address_Line_2__c,Secure_Bags__c,Pickup__r.Shipper_Name1__c,
                                Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,Customer__r.Name,
                                Number_of_Packages__c,Net_Weight__c,Additional_Remarks__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,
                                Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,Consignee_Name_TMS__c,
                                Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,
                                Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c,
                                SNN_Bar_Code__c,Shipment_Type__c,Multi_Invoice_Value__c,Multi_Net_Weight__c,Multi_Product_Description__c,Customer_Gross_Weight__c,Delivery_Route_Number__c,E_Waybill_Number__c,Chargeable_Weight__c,
                                Liability_Cover_By_BVC__c,Origin_Hub__r.hub_city__c,Origin_Hub__r.name,Destination_Hub__r.hub_city__c,Destination_Hub__r.name,Pickup__r.name,
                                CurrencyIsoCode,Gross_Weight__c,Gross_Weight_UOM_TMS__c,Net_Weight_UOM_TMS__c,Product_Description__c, Billing_Account__r.name,
                                Billing_Address__r.ADDRESS1__c,Delivery_Route_Number__r.name,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,Origin_Type__c,Destination_Type__c,
                                Billing_Address__r.PINCODE__c,Billing_Address__r.Active_Pincode__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c,Sender_Name__r.MobilePhone,Reciever_Name__r.MobilePhone
                                FROM Shipment__c limit 4];
                }

                    
		return shipList;
	}
        @AuraEnabled
	public static Shipment__c getShipment(List<String> idList){
                return [Select Id, name,Reference_1__c,Pickup__r.Receiver_Name__c,Shipment_Date__c,Pickup__c,Destination_Hub__c,Origin_Hub__c,
                                Origin_Address_City__c,Pickup__r.Shipper_Name1__r.Name,Pickup__r.Shipper_Email__c,Pickup__r.Email_Sent_Date_Time__c, 
                                Origin_Address_Line_1__c,Origin_Address_Line_2__c,Secure_Bags__c,Pickup__r.Shipper_Name1__c,
                                Origin_Address_State__c,Shipper_PAN_TMS__c,Origin_Address_Pincode__c,Origin_Address_Phone__c,Customer__r.Name,
                                Number_of_Packages__c,Net_Weight__c,Additional_Remarks__c, Shipment_Value__c, CreatedDate,Shipper_Name_TMS__c,Shipper_Name_TMS__r.name,
                                Shipping_Note_Number__c, Consignee_Name_TMS__r.name, Destination_Address_Line1__c,Consignee_Name_TMS__c,
                                Destination_Address_Line_2__c,Destination_Address_City__c, Destination_Address_State__c,Destination_Address_Phone__c,
                                Destination_Address_Pincode__c,Bill_To_GSTIN__c,Bill_To_Party__c,Bill_To_Party_PAN__c, Consignee_PAN_TMS__c,Net_weight_in_Gram__c,
                                SNN_Bar_Code__c,Shipment_Type__c,Multi_Invoice_Value__c,Multi_Net_Weight__c,Multi_Product_Description__c,Customer_Gross_Weight__c,Delivery_Route_Number__c,E_Waybill_Number__c,Chargeable_Weight__c,
                                Liability_Cover_By_BVC__c,Origin_Hub__r.hub_city__c,Origin_Hub__r.name,Destination_Hub__r.hub_city__c,Destination_Hub__r.name,Pickup__r.name,
                                CurrencyIsoCode,Gross_Weight__c,Gross_Weight_UOM_TMS__c,Net_Weight_UOM_TMS__c,Product_Description__c, Billing_Account__r.name,
                                Billing_Address__r.ADDRESS1__c,Delivery_Route_Number__r.name,Billing_Address__r.ADDRESS2__c,Billing_Address__r.CITY__c,Billing_Address__r.STATE__c,Billing_Address__r.MOBILE1__c,Origin_Type__c,Destination_Type__c,
                                Billing_Address__r.PINCODE__c,Billing_Address__r.Active_Pincode__c,Insurance_By_BVC__c,Customer_Product_Category__c,Invoice_Number__c,Insurance_By__c,Sender_Name__r.MobilePhone,Reciever_Name__r.MobilePhone
                                 FROM Shipment__c where Id IN : idList];
        }

}