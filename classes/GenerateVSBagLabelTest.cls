@isTest
public class GenerateVSBagLabelTest {

    @testSetup
    static void setupTestData() {
        // Create Accounts
        Account custAcc = new Account(Name = 'Test Customer');
        Account shipAcc = new Account(Name = 'Test Shipping');
        Account billAcc = new Account(Name = 'Test Billing');
        insert new List<Account>{ custAcc, shipAcc, billAcc };

        // Create Vault (Name is auto-number, so don’t set manually)
        BVC_Vault_Master__c vault = new BVC_Vault_Master__c();
        insert vault;

        // Create Hub
        Hub__c hub = new Hub__c(Name = 'Test Hub');
        insert hub;

        // Create Secure Packaging records
        List<Secure_Packaging__c> bags = new List<Secure_Packaging__c>();
        for (Integer i = 1; i <= 3; i++) {
            bags.add(new Secure_Packaging__c(Name = 'BAG-' + i));
        }
        insert bags;

        // Create Vault Shipments
        Vault_Shipmet__c shipment1 = new Vault_Shipmet__c(
            Customer__c = custAcc.Id,
            Shipping_Account__c = shipAcc.Id,
            Billing_Account__c = billAcc.Id,
            Vault__c = vault.Id,
            Hub__c = hub.Id,
            Secure_Bags__c = 'BAG-1,BAG-2',
            Number_of_Packages__c = 2,
            Gross_Weight_Kgs__c = 10.5
        );

        Vault_Shipmet__c shipment2 = new Vault_Shipmet__c(
            Customer__c = custAcc.Id,
            Shipping_Account__c = shipAcc.Id,
            Billing_Account__c = billAcc.Id,
            Vault__c = vault.Id,
            Hub__c = hub.Id,
            Secure_Bags__c = 'BAG-3',
            Number_of_Packages__c = 1,
            Gross_Weight_Kgs__c = 5
        );

        Vault_Shipmet__c shipment3 = new Vault_Shipmet__c(
            Customer__c = custAcc.Id,
            Shipping_Account__c = shipAcc.Id,
            Billing_Account__c = billAcc.Id,
            Vault__c = vault.Id,
            Hub__c = hub.Id
        );

        insert new List<Vault_Shipmet__c>{ shipment1, shipment2, shipment3 };
    }

    @isTest
    static void testSingleIdParameter() {
        Vault_Shipmet__c vs = [SELECT Id FROM Vault_Shipmet__c LIMIT 1];

        Test.startTest();
        Test.setCurrentPage(new PageReference('/apex/mockPage'));
        ApexPages.currentPage().getParameters().put('id', vs.Id);

        GenerateVSBagLabel controller = new GenerateVSBagLabel();
        Test.stopTest();

        System.assert(!controller.vaultShipList.isEmpty(), 'Vault shipments should be fetched');
        System.assert(controller.spMap.containsKey(vs.Id), 'spMap should contain the shipment Id');
    }

    @isTest
    static void testMultipleIdsParameter() {
        List<Vault_Shipmet__c> vsList = [SELECT Id FROM Vault_Shipmet__c LIMIT 2];
        String idString = String.join(new List<String>{ vsList[0].Id, vsList[1].Id }, ',');

        Test.startTest();
        Test.setCurrentPage(new PageReference('/apex/mockPage'));
        ApexPages.currentPage().getParameters().put('ids', idString);

        GenerateVSBagLabel controller = new GenerateVSBagLabel();
        Test.stopTest();

        System.assertEquals(2, controller.vaultShipList.size(), 'Should fetch 2 Vault Shipments');
    }

    @isTest
    static void testNoBagsScenario() {
        Vault_Shipmet__c vs = [SELECT Id FROM Vault_Shipmet__c WHERE Secure_Bags__c = null LIMIT 1];

        Test.startTest();
        Test.setCurrentPage(new PageReference('/apex/mockPage'));
        ApexPages.currentPage().getParameters().put('id', vs.Id);

        GenerateVSBagLabel controller = new GenerateVSBagLabel();
        Test.stopTest();

        System.assert(controller.spMap.containsKey(vs.Id), 'spMap should contain shipment Id');
        System.assertEquals(0, controller.spMap.get(vs.Id).size(), 'Should not have any Secure Packaging wrappers');
    }

    @isTest
    static void testEmptyParameterHandling() {
        Test.startTest();
        Test.setCurrentPage(new PageReference('/apex/mockPage'));
        // no params set
        GenerateVSBagLabel controller = new GenerateVSBagLabel();
        Test.stopTest();

        System.assertEquals(0, controller.vaultShipList.size(), 'No Vault shipments should be fetched');
    }
}