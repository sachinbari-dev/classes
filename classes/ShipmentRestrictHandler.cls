/*Class      : ShipmentRestrictHandler
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : NO 2024
 */

public class ShipmentRestrictHandler {
    public static void restrictShipmentCreation(List<Shipment__c> shipments) {
         if(Exclude_Validation__mdt.getInstance('Apex_Eclude')?.Exclude__c == false){
        Set<Id> customerIds = new Set<Id>();
        for (Shipment__c shipment : shipments) {
            if (shipment.Shipment_Created_Through__c =='Mobile App' && shipment.Customer__c != null) {
                customerIds.add(shipment.Customer__c);
            }
        }

        
        Map<Id, Account> customers = new Map<Id,Account>(
            [SELECT Id, Customer_Category_Static__c, Credit_Status__c
             FROM Account
             WHERE Id IN :customerIds]
        );

       
        for (Shipment__c shipment : shipments) {
            if (shipment.DSN__c == true && customers.containsKey(shipment.Customer__c)) {
                Account customer = customers.get(shipment.Customer__c);
                if (customer.Customer_Category_Static__c == 'Non-ACR' && customer.Credit_Status__c == 'Non Credit') {
                    shipment.addError('Cannot create Shipment as the Customer has Non-ACR category and Non Credit status.');
                }
            }
        }
    }
    }
}