@isTest
public class TMS_ScanningBarCodeWithoutShipment_Test {
    public static testmethod void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Pickup__c Pickup = BVCL_TestDataFactory.CreatePickup(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, true);
        Shipment__c Ship = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship.Pickup__c = Pickup.id;
        Ship.Shipping_Note_Number__c = 'EZ00000005';
        insert Ship;
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label',Ship.Shipping_Note_Number__c,'Available',true);
        Secure_Packaging__c Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','AB98898','Available',true);
        // Secure_Packaging__c Label1 = BVCL_TestDataFactory.createPackaging('Shipping Label','EZ00000007','Available',true);        
        Test.startTest();
        TMS_ScanningBarCodeWithoutShipment.shipmentRecordGet(Ship.Shipping_Note_Number__c, Pickup.id);
        
        Shipment__c Ship2 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        // TMS_ScanningBarCodeWithoutShipment.createShipmentRecord(Ship2, Pickup.id, Ship.Shipping_Note_Number__c);
        Secure_Packaging__c Label1 = BVCL_TestDataFactory.createPackaging('Shipping Label','EZ00000007','Available',true);
        System.debug('1.Label1 :'+Label1);
        
        Secure_Packaging__c spack= new Secure_Packaging__c();
        spack.RecordTypeId = Schema.SObjectType.Secure_Packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
        spack.Name = 'EZ00000009';
        spack.Status__c = 'Available';
        insert spack;
        System.debug('1.spack :'+spack);
        TMS_ScanningBarCodeWithoutShipment.createShipmentRecord(Ship2, Pickup.id, spack.Name);
        System.debug('2.spack :'+spack);
        TMS_ScanningBarCodeWithoutShipment.createSecureBagRecords(Bag.name, Ship.id);
        
        Test.setMock(HttpCalloutMock.class, new TSM_SignatureHelper_Mock());
        
        Shipment_Tracking__c st = new Shipment_Tracking__c(); 
        st.Scan_Time__c = system.now();
        
        Secure_Bag__c sb = new Secure_Bag__c();
        sb.Shipment__c = Ship.id;
        sb.Secure_Bag__c = Bag.id;
        insert sb;
        TMS_ScanningBarCodeWithoutShipment.shipmentRecordGet1(Ship2.Id); // added by imran
        TMS_ScanningBarCodeWithoutShipment.createTrackingRecord(st, Ship.id, new List<Secure_Bag__c>{sb});
        TMS_ScanningBarCodeWithoutShipment.SecureBagWrapper wrap = new TMS_ScanningBarCodeWithoutShipment.SecureBagWrapper();
        wrap.bagId = sb.id;
        wrap.secureBag = sb;
        TMS_ScanningBarCodeWithoutShipment.getCoverage();
        TMS_ScanningBarCodeWithoutShipment.getCoverage1();
        TMS_ScanningBarCodeWithoutShipment.getCoverage2();
        Test.stopTest();
    }
}