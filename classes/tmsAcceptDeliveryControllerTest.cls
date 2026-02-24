@isTest
public class tmsAcceptDeliveryControllerTest {
    
    @isTest
    public static void test1(){
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, null, ShipperAcc.id, null, true);
        
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Current_Scan_Loction__c = 'Created';
        bag1.Volumetric_Weight__c = 234.43;
        bag1.Length__c = 986.23;
        bag1.Width__c = 896.56;
        bag1.Height__c = 654.23;
        insert bag1;
        
        Map<string,Secure_Bag__c> bagMap = new Map<string,Secure_Bag__c>();
        bagMap.put(bag1.name, bag1);
        
        Delivery__c del1 = new Delivery__c();
        del1.Status__c = 'Accepted';
        del1.Shipment__c = Ship1.Id;
        Insert del1;
        
        TmsAcceptDeliveryController.ShipmetWrap shipWrap = new TmsAcceptDeliveryController.ShipmetWrap();
        shipWrap.shipmentRecordMap = bagMap;
        
        string sign = 'ruirfgerufgduifufurryerioyioyiwjhdfbvdfuirfgurerofhefherhfouerh'; 
        
        ContentVersion cVersion = new ContentVersion();
        Id contentDocId;
        
        cVersion.ContentLocation = 'S';  
        cVersion.PathOnClient = 'Signature-'+System.now() +'.png'; 
        cVersion.Origin = 'H';  
        cVersion.Title = 'Test.png'; 
        cVersion.VersionData = EncodingUtil.base64Decode(sign); 
        Insert cVersion;
        
        contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = contentDocId; 
        cDocLink.LinkedEntityId = Ship1.Id; 
        cDocLink.ShareType = 'V'; 
        cDocLink.Visibility = 'AllUsers';
        Upsert cDocLink;
        
        
        Test.startTest();
        TmsAcceptDeliveryController.secureBagById(bag1.Id);
        TmsAcceptDeliveryController.allSecureBagGet(del1.Id);
        TmsAcceptDeliveryController.deliveryUpdate(del1.Id);
        TmsAcceptDeliveryController.GetCoverage();
        Test.stopTest();
        
    }


}