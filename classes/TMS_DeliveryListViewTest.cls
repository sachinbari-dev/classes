@isTest
public class TMS_DeliveryListViewTest {
    
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
        Delivery_Line__c dl = new Delivery_Line__c();
        dl.Delivery__c = del1.Id;
        dl.Shipment__c = Ship1.Id;
        insert dl;
        List<Delivery__c> deliveryList = new List<Delivery__c>();
        deliveryList.add(del1);
        
        String snn = 'test1234';
        List<String> snnList = new List<String>();
        snnList.add(snn);
        
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
        
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        Test.startTest();
        try
        {
            // TMS_DeliveryListView.bulkProcess();
            TMS_DeliveryListView.acceptDeliveryRecords(snnList);
            TMS_DeliveryListView.getIncopletedShipments();
            Secure_Bag__c sb = [select Id,Name from Secure_Bag__c where Id=:bag1.Id limit 1];
            TMS_DeliveryListView.bagBySecureBagId(sb.Name);
            TMS_DeliveryListView.getUserInfo();
            TMS_DeliveryListView.getIncopletedShipments();
            TMS_DeliveryListView.viewAllDeliveryLines();            
            TMS_DeliveryListView.getAcceptedDeliveries();
            Delivery__c D = [select Id,Name,Number_of_Packages__c,Number_of_Shipments__c,
                                     (select Id,Shipment__c,Number_of_Packagess__c from Delivery_Lines__r) 
                                     from Delivery__c where Id=:del1.Id limit 1];
            List<String> delIds = new List<String>();
            delIds.add(D.Delivery_Lines__r[0].Id);
            TMS_DeliveryListView.acceptDeliveryRecordsUpdated(delIds);
            
            TMS_DeliveryListView.bulkProcess(D);
            TMS_DeliveryListView.calculateDas(D.Id);
            List<Secure_Bag__c> secureBagList = new List<Secure_Bag__c>();
            secureBagList.add(bag1);
            Map<String,String> shipmentsMap = new Map<String,String>();
            //shipmentsMap.put();
            TMS_DeliveryListView.completeDeliveries(secureBagList,shipmentsMap,'Sample');
            
            TMS_DeliveryListView.getShipments(Ship1.Id);
            TMS_DeliveryListView.getSB_ByDelivery(D.Id);
            List<Delivery_Line__c> deliveryLinesList = D.Delivery_Lines__r;
            TMS_DeliveryListView.getSecureBags(deliveryLinesList);
                                   
            Id parentId=Ship1.Id; 
            String base64Data='vjhvkj';
            List<String> shipList= new List<String>();
            shipList.add(Ship1.Id);
            TMS_DeliveryListView.saveSignatureFile(parentId,base64Data,shipList);
            
            TMS_DeliveryListView.savePODPhoto(sb.Id,base64Data);
            TMS_DeliveryListView.saveSBImage(base64Data,'Testing111111',sb.Id);
            
            TMS_DeliveryListView.saveReceiverIdPhoto(shipList,base64Data);
            TMS_DeliveryListView.saveDeliveryLinesPhoto(shipList,base64Data);
            
            List<String> deliveryIdList = new List<String>();
            deliveryIdList.add(D.Id);
            TMS_DeliveryListView.resendOtp(deliveryIdList);
            TMS_DeliveryListView.updateContactDetails(Ship1.Id,D.Id);
            Delivery_Address_Stop__c ads = [select Id from Delivery_Address_Stop__c limit 1];
            TMS_DeliveryListView.calculateDelivery(ads.Id);
            
        }catch(exception e)
        {
            System.debug('109 Error Message: ' + e.getMessage());
            System.debug('109 Line Number: ' + e.getLineNumber());
            System.debug('109 Stack Trace: ' + e.getStackTraceString());
        }
        
        Test.stopTest();
        
    }




}