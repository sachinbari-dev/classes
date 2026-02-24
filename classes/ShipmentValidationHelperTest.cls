@isTest(seeAllData=true)
public class ShipmentValidationHelperTest {
    @isTest
    public static void testMethod1()
    {
        Shipment__c ship = [select Id,Customer__c,Consignee_Name_TMS__c,Destination_Address_Name__c,Shipment_Created_Through__c,
                            Origin_Address_Name__c,Customer_Product_Category__c,Insurance_By__c,Shipment_Value__c,
                            Net_Weight__c,Shipper_Name_TMS__c from Shipment__c limit 1];
        User testUser = [select Id,Profile.Name from User where Profile.Name='Operations Office Executive' and isActive=true limit 1];
        ShipmentValidationHelper.ValidateValues(ship,testUser);
    }
}