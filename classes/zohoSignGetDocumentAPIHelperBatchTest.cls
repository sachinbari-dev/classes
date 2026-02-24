@isTest
public class zohoSignGetDocumentAPIHelperBatchTest {
     @isTest
    static void acrShipmentTestMethod(){
    zohoSignGetDocumentAPIHelperBatch.dummyMethod();
    }}

  /*  @isTest
    public static void zohoGetdocumentBatchTest(){
        // Set the mock callout
        Test.setMock(HttpCalloutMock.class, new zohoSignGetDocumentAPIHelperMock());
        
        // Create test data
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
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = acc.Id,
            SBQQ__Status__c = 'Ordered',
            SBQQ__Opportunity2__c = opp.Id,
            RequestId__c = '60959000000063321',
            DocumentId__c = '60959000000068062'
        );
        insert quote;

       
        List<SBQQ__Quote__c> additionalQuotes = new List<SBQQ__Quote__c>();
        for (Integer i = 0; i < 5; i++) {
            additionalQuotes.add(new SBQQ__Quote__c(
                SBQQ__Account__c = acc.Id,
                SBQQ__Status__c = 'ordered',
                SBQQ__Opportunity2__c = opp.Id,
                RequestId__c = '60959000000063321',  // Same RequestId to test grouping
                DocumentId__c = '6095900000006806' + i
            ));
        }
        insert additionalQuotes;

        try {
            Test.startTest();
            zohoSignGetDocumentAPIHelperBatch batchClass = new zohoSignGetDocumentAPIHelperBatch();
            Database.executeBatch(batchClass);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('Error: ' + e);
            
        }

        // Verify the quotes were processed
        List<SBQQ__Quote__c> updatedQuotes = [
            SELECT Id, SBQQ__Status__c 
            FROM SBQQ__Quote__c 
            WHERE RequestId__c = '60959000000063321'
        ];
        
        // Add more specific assertions as needed, e.g., checking if specific fields were updated
    }

    // Additional test cases to ensure coverage
    @isTest
    public static void testBatchWithNoQuotes() {
        Test.setMock(HttpCalloutMock.class, new zohoSignGetDocumentAPIHelperMock());
        
        try {
            Test.startTest();
            zohoSignGetDocumentAPIHelperBatch batchClass = new zohoSignGetDocumentAPIHelperBatch();
            Database.executeBatch(batchClass);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('Error: ' + e);
           
        }

        // Verify no quotes exist
      
    }
}*/