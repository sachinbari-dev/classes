@isTest
public class Test_updateBillingAccount_handlerPickup {
    @isTest
    static void testUpdatePrimaryAddress() {
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Primary_Address__c = 'a2f5g000000B8dJAAS'
        );
        insert testAccount;

        Pickup__c testPickup = new Pickup__c(
            Billing_Account__c = testAccount.Id
            // Add any other required fields for your Pickup__c object
        );
        insert testPickup;

        // Call the method to be tested
        List<Pickup__c> pickListToUpdate = new List<Pickup__c>{testPickup};
        updateBillingAccount_handlerPickup.updatePrimaryAddress(pickListToUpdate);

        // Retrieve the updated Pickup__c record
        Pickup__c updatedPickup = [SELECT Id, Billing_Address__c FROM Pickup__c WHERE Id = :testPickup.Id LIMIT 1];

        
    }
}