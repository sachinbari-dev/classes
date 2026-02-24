@isTest
public class VaultShipmentControllerTest {

    @testSetup
    static void setupData() {
      
        Account customer = new Account(Name = 'Test Customer');
        insert customer;

        Account billingAccount = new Account(Name = 'Test Billing Account');
        insert billingAccount;

       
        List<Vault_Shipmet__c> shipments = new List<Vault_Shipmet__c>();
        for (Integer i = 0; i < 3; i++) {
            shipments.add(new Vault_Shipmet__c(
                Customer__c = customer.Id,
                Billing_Account__c = billingAccount.Id
            ));
        }
        insert shipments;
    }

    @isTest
    static void testGetVaultShipments() {
        Test.startTest();
        List<Vault_Shipmet__c> results = VaultShipmentController.getVaultShipments();
        Test.stopTest();

        
    }

    @isTest
    static void testGenerateVaultShipmentLabels_Success() {
     
        List<Vault_Shipmet__c> shipments = [SELECT Id FROM Vault_Shipmet__c LIMIT 2];

        Test.startTest();
        String resultUrl = VaultShipmentController.generateVaultShipmentLabels(
            new List<Id>{shipments[0].Id, shipments[1].Id}
        );
        Test.stopTest();

       
    }

    @isTest
    static void testGenerateVaultShipmentLabels_NoSelection() {
        try {
            Test.startTest();
            VaultShipmentController.generateVaultShipmentLabels(new List<Id>());
            Test.stopTest();
            System.assert(false, 'Expected AuraHandledException for empty list.');
        } catch (AuraHandledException e) {
        
        }
    }
}