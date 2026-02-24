/*Class      : PickupStatusValidator
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : April 2024
 */
@isTest
private class PickupStatusValidatorTest {

    @isTest
    static void testValidatePickupStatus() {
       
        List<Pickup__c> pickups = new List<Pickup__c>();
        for(Integer i = 0; i < 3; i++) {
            pickups.add(new Pickup__c(Pickup_Status__c = 'Completed'));
        }
        insert pickups;

       
        List<Shipment__c> incompleteShipments = new List<Shipment__c>();
        for(Pickup__c pickup : pickups) {
            incompleteShipments.add(new Shipment__c(Pickup__c = pickup.Id));
        }
        insert incompleteShipments;

        Test.startTest();

       
        PickupStatusValidator.validatePickupStatus(pickups, null);

        Test.stopTest();

        
        for(Pickup__c pickup : pickups) {
            if(pickup.Pickup_Status__c == 'Completed') {
               // System.assert(pickup.Pickup_Status__c.getErrors().size() > 0, 'Error message should be added');
            } else {
               // System.assert(pickup.Pickup_Status__c.getErrors().size() == 0, 'No error message should be added');
            }
        }
    }
}