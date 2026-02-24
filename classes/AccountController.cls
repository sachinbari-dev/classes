public class AccountController {
    //this is test code used for testing LWC component createACRReport
   @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id,(select id,Shipping_Note_Number__c,Shipment_Date__c,Shipment_Value__c,Net_weight_in_Gram__c,Gross_weight_in_Gram__c,Product_Code__c,
                                       Product_Description__c, Shipper_Name_TMS__c,Consignee_Name_TMS__c ,/* Docket_No__c,No_Of_Attempts__c,Payment_Mode__c,*/Shipment_Type__c
                                       /*,From_City__c,To_City__c*/  from Shipments__r), Name,Email__c FROM Account limit 5000];
    }
}