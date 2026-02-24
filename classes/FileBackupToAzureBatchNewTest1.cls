@isTest
public class FileBackupToAzureBatchNewTest1 
{

    @isTest
    static void TestMethod1()
    {       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileBackupToAzureBatchNewMock());
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer1','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer1','Shipping',true);
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,userInfo.getUserId(),'Manager',true,true);
        
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
                     
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label', 'YYY7777', 'Available', true);        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship1.Shipping_Note_Number__c = 'EB78464734';
        Ship1.Azure_IsFileUpload__c=false;
        insert Ship1;   
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        ContentVersion cv = [select Id,ContentDocumentId from ContentVersion limit 1];
        System.debug('176 cv:'+cv);
        ContentDocument contentDocument = [SELECT Id, Title FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocument.Id,
            LinkedEntityId = Ship1.Id,
            ShareType = 'I',  
            Visibility = 'AllUsers'
        );
       insert contentDocumentLink;       
        ShipmentFileBackupToAzureBatchNew batchJob = new ShipmentFileBackupToAzureBatchNew();
        database.executeBatch(batchJob,1);
        Test.stopTest();
        
    }
    

    @isTest
    static void TestMethod2()
    {
                Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileBackupToAzureBatchNewMock());
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer1','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer1','Shipping',true);
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,userInfo.getUserId(),'Manager',true,true);
        
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
                     
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label', 'YYY7777', 'Available', true);        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship1.Shipping_Note_Number__c = 'EB78464734';
        Ship1.Azure_IsFileUpload__c=false;
        insert Ship1; 
        Customer_Documents__c cd = new Customer_Documents__c();
        cd.Shipment__c = Ship1.Id;
        cd.Total_Net_Weight__c=112;
		insert cd;    
		insertFiles(cd.Id);
        CustDocFileBackupToAzureBatchNew CDTest = new CustDocFileBackupToAzureBatchNew();
        database.executeBatch(CDTest,2);

        Test.stopTest();        
    }    
    @isTest
    static void TestMethod3()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileBackupToAzureBatchNewMock());
        Delivery__c d = new Delivery__c();
        insert d;
		insertFiles(d.Id);        
        DeliveryFileBackupToAzureBatchNew DelTest = new DeliveryFileBackupToAzureBatchNew();
        database.executeBatch(DelTest,2);
        Test.stopTest();        
    }    


public static void insertFiles(String linkedId)
{
    ContentVersion contentVersion = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
    insert contentVersion;
    
    ContentVersion cv = [select Id,ContentDocumentId from ContentVersion where Id=:contentVersion.Id limit 1];
    System.debug('176 cv:'+cv);
    ContentDocument contentDocument = [SELECT Id, Title FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
    
    ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
        ContentDocumentId = contentDocument.Id,
        LinkedEntityId = linkedId,
        ShareType = 'I',  
        Visibility = 'AllUsers'
    );
    insert contentDocumentLink;
    // second cv
    ContentVersion contentVersion1 = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
        IsMajorVersion = true);
    insert contentVersion1;
    
    ContentVersion cv1 = [select Id,ContentDocumentId from ContentVersion where Id=:contentVersion1.Id limit 1];
    System.debug('176 cv:'+cv1);
    ContentDocument contentDocument1 = [SELECT Id, Title FROM ContentDocument WHERE Id = :cv1.ContentDocumentId];
    
    ContentDocumentLink contentDocumentLink1 = new ContentDocumentLink(
        ContentDocumentId = contentDocument1.Id,
        LinkedEntityId = linkedId,
        ShareType = 'I',  
        Visibility = 'AllUsers'
    );
    insert contentDocumentLink1;    
}    
}