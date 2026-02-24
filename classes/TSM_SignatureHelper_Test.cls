/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 12-11-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TSM_SignatureHelper_Test {
    
    @isTest
    public static void test1(){
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
        
        system.assertEquals('DS124586',Ship1.Shipping_Note_Number__c);
        
        Shipment_Tracking__c trackingRecord = new Shipment_Tracking__c();
        trackingRecord.Shipment__c = Ship1.Id;
        insert trackingRecord;
        
        List<Shipment_Tracking__c> trackingList = new List<Shipment_Tracking__c>();
        trackingList.add(trackingRecord);
        
        List<Shipment__c> shipList = new List<Shipment__c>();
        shipList.add(Ship1);
        
        string sign = 'ruirfgerufgduifufurryerioyioyiwjhdfbvdfuirfgurerofhefherhfouerh'; 
        
        
        //Ship1.Tracking_Status__c = 'Delivered';
        //Update Ship1;
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        //bag1.Seal_Id__c = Seal.id;
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
        
        system.assertEquals(Ship1.Id,delivery.Shipment__c);
        
        ContentVersion cVersion = new ContentVersion();
        Id contentDocId;
        
        cVersion.ContentLocation = 'S';  
        cVersion.PathOnClient = 'Signature-'+System.now() +'.png'; 
        cVersion.Origin = 'H';  
        cVersion.Title = 'Test.png'; 
        cVersion.VersionData = EncodingUtil.base64Decode(sign); 
        Insert cVersion;
        
        system.assertEquals('H',cVersion.Origin);
        
        contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = contentDocId; 
        cDocLink.LinkedEntityId = Ship1.Id; 
        cDocLink.ShareType = 'V'; 
        cDocLink.Visibility = 'AllUsers';
        Upsert cDocLink;
        
        List<Delivery__c> deliveryListToUpdate = new List<Delivery__c>();
        Delivery__c delTest = new Delivery__c();
        delTest.Shipment__c = ship1.id;
        delTest.Error_Remark__c = true;
        delTest.Error_Remark_Description__c = 'Testing purpose';
        delTest.Id = delivery.Id;
        deliveryListToUpdate.add(delTest);
        update deliveryListToUpdate;
        
        system.assertEquals(ship1.id,  delTest.Shipment__c);
        
        Test.setMock(HttpCalloutMock.class, new TSM_SignatureHelper_Mock());
        
        Shipment_Tracking__c st = new Shipment_Tracking__c();
        Test.startTest();
        //TSM_SignatureHelper.saveSNPhoto(Ship1.Id,contentDocId,BagList);
        //TSM_SignatureHelper.saveIdPhoto(Ship1.Id,contentDocId,BagList);
        TSM_SignatureHelper.insertUpdateRecord(st,BagList);
        //TSM_SignatureHelper.processBagsAndDelivery(BagList,delivery.id,sign,delivery);
        TSM_SignatureHelper.saveSign(sign,delivery.id,delivery,trackingList,true);
        TSM_SignatureHelper.saveReceiverIdPhoto(shipList,sign);
        TSM_SignatureHelper tempObj = new TSM_SignatureHelper();
        tempObj.GetCoverage();
        TSM_SignatureHelper.bagBySecureBagId(SP_Bag.name);
        TSM_SignatureHelper.allSecureBagGet(delivery.Id);
        Test.stopTest(); 
        
    }
    
    @isTest static void testSaveSecureBagPhoto() {
        
        Shipment__c shipmentObj = new Shipment__c(
            Product_Code__c = 'VAL-WC-1'
            );
        insert shipmentObj;
            
        Secure_Bag__c secureBagObj = new Secure_Bag__c(
            Finalised_Linehaul_Number__c = 'FL- MUM-MUM-34900',                         
            Shipment__c = shipmentObj.Id,                                              
            Current_Scan_Hub__c = 'a3m5g000000IIyk'                                      
        );
        insert secureBagObj;
        
        TSM_SignatureHelper.saveSecureBagPhoto('fileData', secureBagObj.Name);
        
    }
    
    @isTest static void testPodUpload(){
        
        Shipment__c shipmentObj = new Shipment__c(
            Shipping_Note_Number__c = 'DS568956'
            );
        insert shipmentObj;
        
        TSM_SignatureHelper.podUpload('fileData',shipmentObj.Shipping_Note_Number__c);
        
    }
    
    
    
    
    
    
}