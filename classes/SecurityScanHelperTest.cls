/**
* @description       : Test class for SecurityScanHelper
* @author            : Imran Shaik
* @group             : 
* @last modified on  : 30-09-2025
**/
@isTest
public class SecurityScanHelperTest 
{
    @isTest
    public static void Test1(){
        Transport__c Airport = BVCL_TestDataFactory.CreateAirport('Delhi Airport',true);
        Hub__c hub = BVCL_TestDataFactory.CreateHub('DELHI',false,'DELHI');
        hub.Airport__c = Airport.id;
        insert hub;
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        Secure_Packaging__c SP_Bag1= BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000334','Available',true);
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Seal_Id__c = Seal.id;
        bag1.Current_Scan_Loction__c = 'Origin Hub';
        bag1.Current_Scan_Hub__c = hub.id;
        bag1.Current_Scan_Airport__c = Airport.id;
        insert bag1;
        
        Secure_Bag__c bag2 = new Secure_Bag__c();
        bag2.Shipment__c = Ship1.id;
        bag2.Secure_Bag__c = SP_Bag1.id;
        bag2.Seal_Id__c = Seal.id;
        bag2.Current_Scan_Loction__c = 'Origin Hub';
        bag2.Current_Scan_Hub__c = hub.id;
        bag2.Current_Scan_Airport__c = Airport.id;
        insert bag2;
        
        
        List<Secure_Bag__c> BagList = new List<Secure_Bag__c>();
        BagList.add(bag1);
        BagList.add(bag2);
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(SP_Bag.name, bag1);
        TM_ShipmentTrackerController.bagBySealId(Seal.name);
        
        TM_ShipmentTrackerController.ShipmetWrap wr= new TM_ShipmentTrackerController.ShipmetWrap();
        wr.shipmentRecordMap = bagMap;
        TM_ShipmentTrackerController.scanningInProgress(wr);
        
        BVC_Vault_Master__c vault = new BVC_Vault_Master__c();
        vault.Name ='Blr001';
        vault.BVC_Vault_Type__c='VAULT';
        insert vault;
        String isvault = vault.id;
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        st.Shipment__c = Ship1.id;
        st.Location__c = 'Origin Hub';
        st.Hub__c = hub.id; 
        st.Scan_Time__c = system.now();
        //insert st;
        //
        Test.setMock(HttpCalloutMock.class, new TSM_SignatureHelper_Mock());
        //
        try{
            Test.startTest();
			SecurityScanHelper.geCurrenttUserRecord();
            SecurityScanHelper.getTodayRecords();
            SecurityScanHelper.getRecord('EZ333','Pickup Scan');
            SecurityScanHelper.getRecord('EZ000333','Pickup Scan');
            SecurityScanHelper.checkRecord('EZ000333');
            String scannedItems='[{"id":"22222","name":"EZ000333"},{"id":"111111","name":"EZ000334"}]';
            SecurityScanHelper.completeScanAction(scannedItems,'Vehicle In','TS00236');
            SecurityScanHelper.getTodaySSPRecords();
            Test.stopTest();
        }
        catch (Exception e) {
            throw new AuraHandledException(''+e);
        }
    }
}