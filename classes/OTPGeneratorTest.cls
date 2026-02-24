@isTest
private class OTPGeneratorTest {

    @isTest
    static void testOtpGenerator() {
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        List<OTPGenerator.AcceptDeliveryWrapper> testDeliveryIds = new List<OTPGenerator.AcceptDeliveryWrapper>();
        List<String> shipperAddresses = new List<String>();
        
        for (Integer i = 0; i < 5; i++) {
            Delivery__c testDelivery = new Delivery__c(
                Consignee_Contact__c = 'Consignee_' + i,
                Shipper_Address__c = ShipperAddress.Id,
                Shipper_Contact__c = 'Shipper_' + i
            );
            insert testDelivery;
            OTPGenerator.AcceptDeliveryWrapper wrapper = new OTPGenerator.AcceptDeliveryWrapper();
            wrapper.deliveryId = testDelivery.Id;
            testDeliveryIds.add(wrapper);
            ShipperAddresses.add(ShipperAddress.Id);
        }

        Test.startTest();
        OTPGenerator.otpGenerator(testDeliveryIds);
        OTPGenerator.GetCoverage();
        Test.stopTest();

        
    }
}