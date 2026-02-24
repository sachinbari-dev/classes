@isTest
public class BVC_brinksGetDoumentAPIhelperBatch_Test {

    
     @isTest
    public static void zohoGetdocumentBatchTest(){
        
        Test.setMock(HttpCalloutMock.class, new zohoSignGetDocumentAPIHelperMock());
        
        
        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId(),
            BVC_Company_Type__c = 'Domestic',
            KYC_Indicator_for_Domestic_Flag__c = true,
            Customer_Status__c = 'Active',
            Category__c = 'Manufacturer',
            Type_Of_Customer__c = 'Both',
            BVC_Legal_Entity__c = 'B.V.C. Logistics Private Limited',
            Primary_Customer_Email__c = 'abc@sdcn.com',
            Phone = '94746367837',
            First_Name__c = 'billing firstname',
            Last_Name__c = 'billing lst name',
            Name_As_Per_PAN_Manual_Input__c = 'new cust',
            PAN_Number_of_Entity__c = 'EQUPNB543K'
        );
        insert acc;
        
        Contact ct = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            AccountId = acc.Id,
            Email = 'test@gmail.com'
        );
        insert ct;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            Amount = 214325,
            ContactId = ct.Id,
            StageName = 'BVC Opportunity',
            CloseDate = System.today().addDays(1)
        );
        insert opp;
        
        BVC_bulk_Agreement_signing__c quote = new BVC_bulk_Agreement_signing__c(
            Customer_Name__c = acc.Id,
            Documentstatus__c='Draft',
            status__c = 'Contract sent',
            RequestId__c = '60959000000416407',
            DocumentId__c = '60959000000416408'
        );
        insert quote;

       
        List<BVC_bulk_Agreement_signing__c> additionalQuotes = new List<BVC_bulk_Agreement_signing__c>();
        for (Integer i = 0; i < 5; i++) {
            additionalQuotes.add(new BVC_bulk_Agreement_signing__c(
                Customer_Name__c = acc.Id,
                Documentstatus__c='Draft',
                status__c = 'Contract sent',
                RequestId__c = '60959000000416407',  
                DocumentId__c = '60959000000416408' 
            ));
        }
        insert additionalQuotes;
         ContentVersion cv= new Contentversion();
          cv.title= 'Test';
          cv.PathOnClient ='Test'+'.pdf';         
          cv.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
          cv.SharingPrivacy = 'N';
          cv.FirstPublishLocationId = quote.id;
          insert cv; 
        
        try {
            
             Zoho_Access_Token__c tokenSetting = new Zoho_Access_Token__c(
            Name = 'Default', 
            Access_Token__c = '1000.e43c5bbeb14b605b9984ff7a139ae903.05d9372e9766995ae5c27d336ec4d50b'
        );
        insert tokenSetting;
            
            Test.startTest();
            BVC_brinksGetDoumentAPIhelperBatch batchClass = new BVC_brinksGetDoumentAPIhelperBatch();
            Database.executeBatch(batchClass);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('Error: ' + e);
            
        }

       
        List<BVC_bulk_Agreement_signing__c> updatedQuotes = [
            SELECT Id, status__c 
            FROM BVC_bulk_Agreement_signing__c 
            WHERE RequestId__c = '60959000000063321'
        ];
        
       
    }

   
    @isTest
    public static void testBatchWithNoQuotes() {
        Test.setMock(HttpCalloutMock.class, new zohoSignGetDocumentAPIHelperMock());
         
       
        try {
            Test.startTest();
            BVC_brinksGetDoumentAPIhelperBatch batchClass = new BVC_brinksGetDoumentAPIhelperBatch();
            Database.executeBatch(batchClass);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('Error: ' + e);
           
        }

       
      
    }  
}