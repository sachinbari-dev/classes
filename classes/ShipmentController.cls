public with sharing class ShipmentController {
    @AuraEnabled(cacheable=true)
    public static Shipment__c getShipmentByNoteNumber(String shippingNoteNumber) {
        return [
            SELECT Id, Origin_Address_City__c, Destination_Address_City__c, Product_Description__c, Gross_Weight__c, Shipment_Value__c, Customer_Gross_Weight__c, Billing_Account__r.Name
            FROM Shipment__c 
            WHERE Shipping_Note_Number__c = :shippingNoteNumber
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static void updateShipment(Shipment__c shipment) {
        update shipment;
    }

   
    @AuraEnabled
    public static void updateShipmentWithoutApproval(Shipment__c shipment) {
        update shipment;
    }

   
    @AuraEnabled
    public static void submitForApproval(Id shipmentId) {
        Shipment__c shipment = [SELECT Id FROM Shipment__c WHERE Id = :shipmentId LIMIT 1];
        updateShipmentWithoutApproval(shipment);
    }
}