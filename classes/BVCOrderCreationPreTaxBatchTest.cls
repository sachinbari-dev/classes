@isTest
public class BVCOrderCreationPreTaxBatchTest {
    
    @testSetup
    static void testData() {
        
        Account acrAccount = BVCL_TestDataFactory.createCustomer('ACR Account','Billing',true);
        Account nonAcrAccount = BVCL_TestDataFactory.createCustomer('NonACRAccount','Billing',true);
        Hub__c testHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        
        
        BVC_CB_PreTaxBill__c preTaxBill = new BVC_CB_PreTaxBill__c(
            Name = 'Test PreTax Bill',
            BVC_CB_Is_Order_Created__c = false,
            BVC_CB_PretaxDetails_Inserted__c = true,
            BVC_CB_Org_Branch_SF_ID__c = testHub.Id
        );
        insert preTaxBill;

        BVC_CB_PreTaxBillDetails__c preTaxBillDetail = new BVC_CB_PreTaxBillDetails__c(
            BVC_CB_PreTaxBill__c = preTaxBill.Id,
            BVC_CB_ChargeAmount__c = 100.0,
            BVC_CB_Invoice_Type__c = 'Tax Invoice'
        );
        insert preTaxBillDetail;

        BVC_CB_Object_Mapping__c objectMapping = new BVC_CB_Object_Mapping__c(
            Source_Object_API_Name__c = 'BVC_CB_PreTaxBill__c',
            Source_Field_API_Name__c = 'Name',
            Target_Field_API_Name__c = 'Name',
            Target_Object_API_Name__c = 'BVCOrder__c',
            Is_Active__c = true
        );
        insert objectMapping;
    }

    @isTest
    static void testBatchExecution() {
        String query = 'SELECT Id, Name, BVC_CB_Is_Order_Created__c, BVC_CB_PretaxDetails_Inserted__c FROM BVC_CB_PreTaxBill__c WHERE BVC_CB_Is_Order_Created__c = false';
        BVCOrderCreationPreTaxBatch batchInstance = new BVCOrderCreationPreTaxBatch(query);

        Test.startTest();
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();
        
    }

    @isTest
    static void testErrorHandlingInBatch() {
        Test.startTest();
        String query = 'SELECT Id, Name, BVC_CB_Is_Order_Created__c, BVC_CB_PretaxDetails_Inserted__c FROM BVC_CB_PreTaxBill__c WHERE BVC_CB_Is_Order_Created__c = false';
        BVCOrderCreationPreTaxBatch batchInstance = new BVCOrderCreationPreTaxBatch(query);
        
        BVC_CB_PreTaxBill__c invalidPreTaxBill = new BVC_CB_PreTaxBill__c(
            Name = 'Invalid Test PreTax Bill',
            BVC_CB_Is_Order_Created__c = false,
            BVC_CB_PretaxDetails_Inserted__c = true
        );
        insert invalidPreTaxBill;
        
        Database.executeBatch(batchInstance, 10);
        BVCOrderCreationPreTaxBatch.Method2();
        Test.stopTest();

    }
}