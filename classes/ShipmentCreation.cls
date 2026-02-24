public class ShipmentCreation {
    public static void validateCustomerCategory(List<Shipment__c> shipments) {
        // Collect the Customer__c Ids from the shipments
        Set<Id> customerIds = new Set<Id>();
        for (Shipment__c shipment : shipments) {
            if (shipment.Customer__c != null) {
                customerIds.add(shipment.Customer__c);
            }
        }

        // Query the related Accounts to get the Customer_Category_Static__c field
        Map<Id, Account> customerAccountMap = new Map<Id, Account>(
            [SELECT Id, Customer_Category_Static__c FROM Account WHERE Id IN :customerIds]
        );

        // Validate the Customer_Category_Static__c field
        for (Shipment__c shipment : shipments) {
            if (shipment.Customer__c != null) {
                Account customerAccount = customerAccountMap.get(shipment.Customer__c);
                // Check if Customer_Category_Static__c is blank or 'None'
                if (customerAccount != null && 
                    (customerAccount.Customer_Category_Static__c == null || 
                     customerAccount.Customer_Category_Static__c == '' || 
                     customerAccount.Customer_Category_Static__c == 'None')) {
                    shipment.addError('Shipment cannot be created because the Customer Category is either blank or set to None.');
                }
            }
        }
    }
}