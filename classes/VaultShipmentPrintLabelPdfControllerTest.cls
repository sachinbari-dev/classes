@isTest
public class VaultShipmentPrintLabelPdfControllerTest {
    
    @testSetup
    static void setupData() {
        // Create related records
        Account billingAcc = new Account(Name = 'Billing Account');
        insert billingAcc;
        
        Account shippingAcc = new Account(Name = 'Shipping Account');
        insert shippingAcc;
        
        ST_Exhibition__c exhibition = new ST_Exhibition__c();
        insert exhibition;
        
        Hub__c hub = new Hub__c(Name = 'Mumbai Hub');
        insert hub;

        BVC_Vault_Master__c vault = new BVC_Vault_Master__c();
        insert vault;

        // Create Vault Shipments
        List<Vault_Shipmet__c> shipments = new List<Vault_Shipmet__c>();
        for (Integer i = 0; i < 2; i++) {
            shipments.add(new Vault_Shipmet__c(
                
                Product_Description__c = 'GOLD BAR',
                Number_of_Packages__c = 5,
                Net_Weight_in_Kgs__c = 10.5,
                Gross_Weight_Kgs__c = 11.2,
                Product_Value__c = 250000,
              //  Insurance_by_BVC__c = true,
                Billing_Account__c = billingAcc.Id,
                Shipping_Account__c = shippingAcc.Id,
                Exhibition_Name__c = exhibition.Id,
                Hub__c = hub.Id,
                Vault__c = vault.Id,
                Secure_Bags__c = 'SB001,SB002,SB003'

            ));
        }
        insert shipments;
    }

    @isTest
    static void testSingleIdController() {
        Vault_Shipmet__c vs = [SELECT Id FROM Vault_Shipmet__c LIMIT 1];

        Test.startTest();
        PageReference pageRef = Page.VaultShipmentPrintLabelPdf;
        pageRef.getParameters().put('id', vs.Id);
        Test.setCurrentPage(pageRef);

        VaultShipmentPrintLabelPdfController controller = new VaultShipmentPrintLabelPdfController();
        Test.stopTest();

        
    }

    @isTest
    static void testMultipleIdsController() {
        List<Vault_Shipmet__c> vsList = [SELECT Id FROM Vault_Shipmet__c LIMIT 2];
        String idParam = vsList[0].Id + ',' + vsList[1].Id;

        Test.startTest();
        PageReference pageRef = Page.VaultShipmentPrintLabelPdf;
        pageRef.getParameters().put('ids', idParam);
        Test.setCurrentPage(pageRef);

        VaultShipmentPrintLabelPdfController controller = new VaultShipmentPrintLabelPdfController();
        Test.stopTest();

        
    }

    @isTest
    static void testNoIdScenario() {
        Test.startTest();
        PageReference pageRef = Page.VaultShipmentPrintLabelPdf;
        Test.setCurrentPage(pageRef);

        VaultShipmentPrintLabelPdfController controller = new VaultShipmentPrintLabelPdfController();
        Test.stopTest();

       
    }
}