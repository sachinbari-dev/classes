/*Class      : ShipmentHandler
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : June 2024
 */
public class ShipmentHandler {
    public static void beforeInsert(List<Shipment__c> shipments) {
        System.debug('Entered beforeInsert method' + shipments);
        System.debug('Entered beforeInsert method');
        Set<Id> billingAccountIds = new Set<Id>();
        Set<Id> billingAddressIds = new Set<Id>();
        Set<Id> shipperNameTmsIds = new Set<Id>();
        Set<Id> originAddressNameIds = new Set<Id>();
        Set<Id> customerIds = new Set<Id>();
        
        for (Shipment__c shipment : shipments) {
            System.debug('Processing Shipment__c: ' + shipment);
            System.debug('Processing Shipment__c: ' + shipment.Billing_Account__c);
            
            if (shipment.API_or_Excel__c == true) {
                if (shipment.Billing_Account__c != null) {
                    billingAccountIds.add(shipment.Billing_Account__c);
                }
                if (shipment.Billing_Address__c != null) {
                    billingAddressIds.add(shipment.Billing_Address__c);
                }
                if (shipment.Shipper_Name_TMS__c != null) {
                    shipperNameTmsIds.add(shipment.Shipper_Name_TMS__c);
                }
                if (shipment.Origin_Address_Name__c != null) {
                    originAddressNameIds.add(shipment.Origin_Address_Name__c);
                }
                if (shipment.Customer__c != null) {
                    customerIds.add(shipment.Customer__c);
                }
            }
        }
        
        System.debug('Billing Account IDs: ' + billingAccountIds);
        System.debug('Billing Address IDs: ' + billingAddressIds);
        System.debug('Shipper Name TMS IDs: ' + shipperNameTmsIds);
        System.debug('Origin Address Name IDs: ' + originAddressNameIds);
        System.debug('Customer IDs: ' + customerIds);
        
        // Query to find matching Pickup__c records
        Map<String, Pickup__c> pickupMap = new Map<String, Pickup__c>();
        if (!billingAccountIds.isEmpty() && !billingAddressIds.isEmpty() && !shipperNameTmsIds.isEmpty() && !originAddressNameIds.isEmpty()) {
            for (Pickup__c pickup : [
                SELECT Id, Billing_Account__c, Billing_Address__c, Shipper_Name__c, Shipper_Address__c
                FROM Pickup__c
                WHERE Billing_Account__c IN :billingAccountIds
                AND Billing_Address__c IN :billingAddressIds
                AND Shipper_Name__c IN :shipperNameTmsIds
                AND Shipper_Address__c IN :originAddressNameIds
                AND Pickup_Status__c NOT IN ('Completed', 'Cancelled')
            ]) {
                String key = String.valueOf(pickup.Billing_Account__c) + '-' + String.valueOf(pickup.Billing_Address__c) + '-' + String.valueOf(pickup.Shipper_Name__c) + '-' + String.valueOf(pickup.Shipper_Address__c);
                pickupMap.put(key, pickup);
            }
        }
        
        System.debug('Pickup Map: ' + pickupMap);
        
        // Query to get the Customer__c accounts with Customer_Category_Static__c field
        Map<Id, Account> customerAccountMap = new Map<Id, Account>();
        if (!customerIds.isEmpty()) {
            customerAccountMap = new Map<Id, Account>([
                SELECT Id, Customer_Category_Static__c, Credit_Status__c
                FROM Account
                WHERE Id IN :customerIds
            ]);
        }
        
        System.debug('Customer Account Map: ' + customerAccountMap);
        
        for (Shipment__c shipment : shipments) {
            Boolean hasPickupError = false;
            
            if (shipment.API_or_Excel__c == true) {
                if (shipment.Billing_Account__c != null && shipment.Billing_Address__c != null && shipment.Shipper_Name_TMS__c != null && shipment.Origin_Address_Name__c != null) {
                    String key = String.valueOf(shipment.Billing_Account__c) + '-' + String.valueOf(shipment.Billing_Address__c) + '-' + String.valueOf(shipment.Shipper_Name_TMS__c) + '-' + String.valueOf(shipment.Origin_Address_Name__c);
                    System.debug('Generated Key: ' + key);
                    
                    if (pickupMap.containsKey(key)) {
                        shipment.Pickup__c = pickupMap.get(key).Id;
                        System.debug('Matching Pickup__c found: ' + pickupMap.get(key));
                    } else {
                        hasPickupError = true;
                    }
                }
                
                
                
                if (hasPickupError) {
                    shipment.addError('No Pickup found with Same Shipper or Pickup is either Completed or Cancelled.');
                }
            }
        }
    }
}