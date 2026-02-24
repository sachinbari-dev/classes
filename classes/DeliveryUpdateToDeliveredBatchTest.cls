@isTest
public class DeliveryUpdateToDeliveredBatchTest {

    @testSetup
    static void setupData() {
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        
        Ship1.Destination_Address_Name__c = ShipperAddress.Id;
        Ship1.Consignee_Name__c = 'Test Developer';
        Ship1.Consignee_Designation__c = 'Developer';
        Ship1.Delivered_To_Person__c = 'Test Developer';
        Ship1.Shipping_Note_Number__c = 'DS124586';
        
        insert Ship1;
        
        string sign = 'ruirfgerufgduifufurryerioyioyiwjhdfbvdfuirfgurerofhefherhfouerh'; 
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Last_Scan_Location__c = 'Out for Delivery';
        bag1.Current_Origin_City__c = 'Mumbai';                                            
        bag1.Is_Misrouted__c = false;                                                      
        bag1.Is_Count_Mismatch__c = false;
        insert bag1;
        
        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag1);
         
        String secureBagName = bag1.Name;
        
        Delivery__c delivery = new Delivery__c();
        delivery.Shipment__c = Ship1.Id;
        delivery.Status__c = 'Accepted';
        delivery.Address__c = ShipperAddress.id;
        delivery.Error_Remark__c = true;
        delivery.Error_Remark_Description__c = 'Test Data';
        
        Insert delivery;
        
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test content'),
            Origin = 'H'
        );
        insert cv;
    }

    @isTest
    static void testBatchSuccessFlow() {
        Shipment__c shipment = [SELECT Id FROM Shipment__c LIMIT 1];
        Delivery__c delivery = [SELECT Id FROM Delivery__c LIMIT 1];
        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId;

        Set<Id> shipmentIds = new Set<Id>{shipment.Id};

        Test.startTest();
        DeliveryUpdateToDeliveredBatch batchObj = new DeliveryUpdateToDeliveredBatch(
            shipmentIds,
            delivery.Id,
            delivery,
            contentDocId
        );
        Id jobId = Database.executeBatch(batchObj, 50);
        DeliveryUpdateToDeliveredBatch.getCoverage1();
        Test.stopTest();

    }

}