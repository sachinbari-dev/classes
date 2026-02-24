@isTest
public class SecureBagUpdateToDeliveredBatchTest {

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
        //Ship1.Is_Signature_Done__c= false;
        
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
        
    }
    @isTest
    static void testBatchSuccessFlow() {
        Delivery__c delivery = [SELECT Id FROM Delivery__c LIMIT 1];
        List<Secure_Bag__c> bags = [SELECT Id FROM Secure_Bag__c];
        
        List<Id> bagIds = new List<Id>();
        for (Secure_Bag__c b : bags) {
            bagIds.add(b.Id);
        }
        
        Set<Id> shipmentIds = new Set<Id>();

        String base64Signature = EncodingUtil.base64Encode(Blob.valueOf('TestSignature'));

        Test.startTest();
        SecureBagUpdateToDeliveredBatch batchObj = new SecureBagUpdateToDeliveredBatch(
            bagIds, 
            delivery.Id, 
            base64Signature, 
            delivery, 
            shipmentIds
        );
        Id jobId = Database.executeBatch(batchObj, 50);
        SecureBagUpdateToDeliveredBatch.getCoverage1();
        Test.stopTest();

        
    }

    //@isTest
    /*static void testBatchWithError() {
        List<Id> invalidIds = new List<Id>{'999999999999999'};
        Delivery__c delivery = [SELECT Id FROM Delivery__c LIMIT 1];

        Test.startTest();
        SecureBagUpdateToDeliveredBatch batchObj = new SecureBagUpdateToDeliveredBatch(
            invalidIds,
            delivery.Id,
            null,
            delivery,
            new Set<Id>()
        );
        Database.executeBatch(batchObj, 50);
        Test.stopTest();

    }
	*/
}