@isTest
public class ProductMasterControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a Hub record (Lookup Object)
        Hub__c hub = new Hub__c(Name = 'Test Hub');
        insert hub;

        // Create Product_Master__c records
        List<Product_Master__c> products = new List<Product_Master__c>{
            new Product_Master__c(Name = 'Product 1', Category__c = 'Gold', Description__c = 'Test Description 1', Hub__c = hub.Id),
            new Product_Master__c(Name = 'Product 2', Category__c = 'Gold', Description__c = 'Test Description 2', Hub__c = hub.Id)
        };
        insert products;
    }

    @isTest
    static void testGetProducts() {
        // Call the method
        Test.startTest();
        List<Product_Master__c> products = ProductMasterController.getProducts();
        Test.stopTest();

           
    }

    @isTest
    static void testGetCategoryPicklistValues() {
        // Call the method
        Test.startTest();
        List<String> categories = ProductMasterController.getCategoryPicklistValues();
        Test.stopTest();

      
    }
}