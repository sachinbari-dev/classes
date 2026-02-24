@isTest
public class AzureFileUploadCallTest 
{
    @isTest
    public static void testMethod1()
    {
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

        // Retrieve ContentDocumentId from ContentVersion
        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id LIMIT 1];

        // Create ContentDocumentLink to link the file to the Account
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = invoice1.Id,
            ContentDocumentId = insertedVersion.ContentDocumentId,
            ShareType = 'V' // Viewer access
        );

        // Start test and insert ContentDocumentLink
        Test.startTest();
        insert testContentDocumentLink;
        Test.stopTest();
    }
}