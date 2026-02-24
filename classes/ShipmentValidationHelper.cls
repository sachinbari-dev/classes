public class ShipmentValidationHelper 
{
	public static boolean ValidateValues(Shipment__c ship,User U)
    {
        boolean validation=true;
        if(U.Profile.Name=='Operations Office Executive' || U.Profile.Name=='Operations Field Executive' )
        {
            if (ship.Shipment_Created_Through__c != 'Mobile App') {
               if(ship.Customer__c==null || ship.Consignee_Name_TMS__c==null ||
               ship.Destination_Address_Name__c==null || ship.Origin_Address_Name__c==null ||
               ship.Customer_Product_Category__c==null || ship.Insurance_By__c==null || 
               ship.Shipment_Value__c==null || ship.Net_Weight__c==null || ship.Shipper_Name_TMS__c==null)                
            {
                validation=false; 
            }            
        }
        }

        return validation;
    }
}