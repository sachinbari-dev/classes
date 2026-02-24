/*Class      : PickupStatusValidator
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : April 2024
 */
public class PickupStatusValidator {
    public static void validatePickupStatus(List<Pickup__c> pickupsToUpdate, Map<Id, Pickup__c> oldPickupsMap) {
        // Prepare data structures
        List<Id> pickupIdsWithError = new List<Id>();
        Map<Id, String> pickupIdToErrorMessages = new Map<Id, String>();
        Map<Id, List<String>> pickupIdToIncompleteShipments = new Map<Id, List<String>>();
        Map<Id, List<String>> pickupIdToMissingBagsShipments = new Map<Id, List<String>>();
        Map<Id, String> pickupIdToName = new Map<Id, String>();

        // Store Pickup Names and initialize maps
        for (Pickup__c pickup : pickupsToUpdate) {
            pickupIdToIncompleteShipments.put(pickup.Id, new List<String>());
            pickupIdToMissingBagsShipments.put(pickup.Id, new List<String>());
            pickupIdToName.put(pickup.Id, pickup.Name);
        }

        // Query shipments related to pickups
        for (Shipment__c shipment : [
            SELECT Id, Name, Pickup__c, Net_Weight__c, Customer_Product_Category__c, 
                   Shipping_Note_Number__c, Shipment_Value__c, Number_of_Secure_Bags__c 
            FROM Shipment__c 
            WHERE Pickup__c IN :pickupIdToIncompleteShipments.keySet()
        ]) {

            // Check for missing invoice details
            if (shipment.Net_Weight__c == null || shipment.Shipment_Value__c == null) {
                pickupIdToIncompleteShipments.get(shipment.Pickup__c).add(shipment.Shipping_Note_Number__c);
            }

            // Check for missing secure bags (except 'Hyper local')
            if (shipment.Number_of_Secure_Bags__c == 0 && shipment.Customer_Product_Category__c != 'Hyper local') {
                pickupIdToMissingBagsShipments.get(shipment.Pickup__c).add(shipment.Shipping_Note_Number__c);
            }
        }

        // Build error messages
        for (Id pickupId : pickupIdToName.keySet()) {
            List<String> missingBagShipments = pickupIdToMissingBagsShipments.get(pickupId);
            List<String> incompleteShipments = pickupIdToIncompleteShipments.get(pickupId);
            String pickupName = pickupIdToName.get(pickupId);
            String errorMessage = '';

            // Build parts of message conditionally
            if (!missingBagShipments.isEmpty()) {
                String shipments = String.join(missingBagShipments, ', ');
                errorMessage += '🚫 Missing Secure Bags in Shipment(s): ' + shipments;
            }

            if (!incompleteShipments.isEmpty()) {
                String shipments = String.join(incompleteShipments, ', ');
                if (errorMessage != '') errorMessage += '\n\n';
                errorMessage += '📦 Missing Invoice Details in Shipment(s): ' + shipments;
            }

            // Only add pickup name once, if any error exists
            if (errorMessage != '') {
                errorMessage += '\n\n For⚠️ PICKUP: ' + pickupName;
                pickupIdToErrorMessages.put(pickupId, errorMessage);
                pickupIdsWithError.add(pickupId);
            }
        }

        // Add validation errors to pickups being marked as Completed
        for (Pickup__c pickup : pickupsToUpdate) {
            if (pickup.Pickup_Status__c == 'Completed' && pickupIdsWithError.contains(pickup.Id)) {
                pickup.addError(pickupIdToErrorMessages.get(pickup.Id), false);
            }
        }
    }
}