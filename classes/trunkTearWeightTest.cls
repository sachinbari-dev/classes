@isTest
public class trunkTearWeightTest {
    
    @isTest
    public static void testTrunkTearWeightCalculator() {
        
        Secure_Packaging__c SP_Trunk = BVCL_TestDataFactory.createPackaging('Trunk','BVCL1234','Available',true);
        
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c ship = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        Trunk__c testTrunk = new Trunk__c();
        testTrunk.Trunk_name__c = SP_Trunk.Id;
        insert testTrunk;
        
        Secure_Bag__c testSecureBag = new Secure_Bag__c();
        testSecureBag.Trunk_Id__c = SP_Trunk.Id;
        testSecureBag.Shipment__c = ship.Id;
        testSecureBag.Volumetric_Weight__c = 252.25;
        testSecureBag.BVC_Gross_Weight_Manual_in_Grams__c = 142.52;
        insert testSecureBag;
        
        test.startTest();
        trunkTearWeight.trunkTearWeightCalculator(new List<Trunk__c>{ testTrunk });
        test.stopTest();
        
    }
}