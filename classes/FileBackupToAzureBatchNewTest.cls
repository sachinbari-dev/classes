@isTest
public class FileBackupToAzureBatchNewTest 
{
    @isTest
    static void TestMethodforBVCInvoice()
    {       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileBackupToAzureBatchNewMock());
        Account Acc = New Account();
        Acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Acc.Name = 'TITAN COMPANY LIMITED - Billing EQUPNB123K';
        Acc.BVC_Company_Type__c = 'Domestic';        
        Acc.KYC_Indicator_for_Domestic_Flag__c = true;
        Acc.Customer_Status__c = 'Active';
        Acc.Category__c = 'Manufacturer';
        Acc.Type_Of_Customer__c = 'Both';
        Acc.BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited';
        Acc.Primary_Customer_Email__c = 'abc@sdcn.com';
        Acc.Phone = '+919474636783';
        Acc.First_Name__c = 'billing firstname';               
        Acc.Last_Name__c = 'billing lst name';
        //      Acc.Name_As_Per_PAN__pc = 'EQUPNB123K';
        Acc.Name_As_Per_PAN_Manual_Input__c = 'new cust';
        Acc.PAN_Number_of_Entity__c = 'EQUPNB123K';  
        Acc.BVC_Virtual_Bank_Account_Number__c='ZBVC11566198';
        Insert Acc; 
        BVCInvoice__c invoice1 = new BVCInvoice__c(
            Account__c = Acc.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Success',
            BVC_CB_Is_CB_Invoice__c = true,
            Invoice_Doc_URL__c = 'test String'
        );
        insert invoice1;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('This is a test file content'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        
        ContentVersion testContentVersion1 = new ContentVersion(
            Title = 'TestFile1',
            PathOnClient = 'TestFile1.EXCEL',
            VersionData = Blob.valueOf('This is a test file content'),
            IsMajorVersion = true
        );
        insert testContentVersion1;
        
        // Retrieve ContentDocumentId from ContentVersion
        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id LIMIT 1];
        
        // Create ContentDocumentLink to link the file to the Account
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = invoice1.Id,
            ContentDocumentId = insertedVersion.ContentDocumentId,
            ShareType = 'V' // Viewer access
        );
        insert testContentDocumentLink;
        // Start test and insert ContentDocumentLink
        
        
        FileBackupToAzureBatchNew batchJob = new FileBackupToAzureBatchNew('Invoices');
        database.executeBatch(batchJob,1);
        Test.stopTest();
        
    }    
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
        FileBackupToAzureBatchNew batchJob = new FileBackupToAzureBatchNew('Shipment');
        database.executeBatch(batchJob,1);
        Test.stopTest();
        
    }
    
    @isTest
    static void TestMethod2()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileBackupToAzureBatchNewMock());
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Transport__c DelhiAir = BVCL_TestDataFactory.CreateAirport('Delhi Airport', true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        FSE_Sales__c fse = BVCL_TestDataFactory.createFSE(DelhiHub.id,userInfo.getUserId(),'Manager',true,true);
        
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c ShipperAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        
        Secure_Packaging__c Label = BVCL_TestDataFactory.createPackaging('Shipping Label', 'YYY7777', 'Available', true);        
        Shipment__c Ship1 = BVCL_TestDataFactory.CreateShipment(BillingAcc.id, ShipperAcc.id, ShipperAddress.id, ShipperAcc.id, ShipperAddress.id, false);
        Ship1.Shipping_Note_Number__c = 'EB78464734';
        insert Ship1;                     
        //system.debug('SNN'+Ship1.Shipping_Note_Number__c);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ000333','Available',true);
        Secure_Bag__c bag1 = new Secure_Bag__c();
        bag1.Shipment__c = Ship1.id;
        bag1.Secure_Bag__c = SP_Bag.id;
        bag1.Azure_IsFileUpload__c=false;
        insert bag1;
        insertFiles(bag1.Id);        
        
        FileBackupToAzureBatchNew batchJob1 = new FileBackupToAzureBatchNew('SecureBag');       
        database.executeBatch(batchJob1,2);
        Test.stopTest();        
    }
    @isTest
    static void TestMethod3()
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
        FileBackupToAzureBatchNew batchJob3 = new FileBackupToAzureBatchNew('CustomerDocument');
        database.executeBatch(batchJob3,2);
        
        Test.stopTest();        
    }    
    @isTest
    static void TestMethod4()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileBackupToAzureBatchNewMock());
        Delivery__c d = new Delivery__c();
        insert d;
        insertFiles(d.Id);        
        FileBackupToAzureBatchNew batchJob4 = new FileBackupToAzureBatchNew('Delivery');
        database.executeBatch(batchJob4,2);
        Test.stopTest();        
    }    
    @isTest
    static void TestMethod5()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileBackupToAzureBatchNewMock());
        Delivery__c d = new Delivery__c();
        insert d;
        // Create an EmailMessage record
        EmailMessage emailMessage = new EmailMessage(
            Subject = 'Test Email Subject',
            FromAddress = 'test@example.com',
            ToAddress = 'user@example.com',
            TextBody = 'This is a test email body.',
            HtmlBody = '<p>This is a test email body in HTML.</p>',
            RelatedToId = d.Id,
            Status = '0', // Draft status
            MessageDate = System.now()
        );
        insert emailMessage;       
        insertFiles(emailMessage.Id);
        FileBackupToAzureBatchNew batchJob4 = new FileBackupToAzureBatchNew('Email');
        database.executeBatch(batchJob4,2);
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