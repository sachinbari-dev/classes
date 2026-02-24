@isTest
public class BVCnonAcrQuotePdfControllerTest {

   
    private static Id setupTestData() {
      
        Account acc = BVCL_TestDataFactory.createCustomer('Test','Billing',True);
      
        Entity__c e = new Entity__c(Name = 'BVC Logistics.pvt.Ltd');
        insert e;
        
       System.debug('Entity ' + e);
        
        BVC_LegalEntity__c l = new BVC_LegalEntity__c(Name = 'BVC logistics', BVC_Entity__c = e.Id,GSTIN_Principle_Business_Address_Line_1__c = 'Test Add',GSTIN_Principle_Business_Address_Line_2__c='testadd');
        insert l;
        
       System.debug('LegalEntity ' + l);
      
        BVCQuote__c bq = new BVCQuote__c(
            Account__c = acc.Id,
            Business_Type__c = 'Non ACR',
            BVC_LegalEntity__c = l.Id,
           
            BVC_Entity__c = e.Id
        );
        insert bq;
        System.debug('BVC quote: ' + bq);

       
        List<Product2> productList = new List<Product2>{
            new Product2(Name = 'Valship Metro To Metro (20-25)'),
            new Product2(Name = 'SilverSHIP Metro To Metro (0-1)'),
            new Product2(Name = 'SilverSHIP Within City (0-1)'),
            new Product2(Name = 'ValSHIP Within Region (0-1)'),
            new Product2(Name = 'ValSHIP Within Region-(1-20)'),
            new Product2(Name = 'ValSHIP Within Region (20-25)'),
            new Product2(Name = 'Valship Metro To Metro (0-1)'),
            new Product2(Name = 'Valship Metro To Metro (1-20)'),
            new Product2(Name = 'ValSHIP Within City(0-1)'),
            new Product2(Name = 'ValSHIP Within City(1-20)'),
            new Product2(Name = 'ValSHIP Within City(20-25)'),
            new Product2(Name = 'Valship Rest of India(0-1)'),
            new Product2(Name = 'Valship Rest of India(1-20)'),
            new Product2(Name = 'Valship Rest of India(20-25)'),
            new Product2(Name = 'SilverSHIP Metro To Metro (1-20)'),
            new Product2(Name = 'SilverSHIP Metro To Metro (20-25)'),
            new Product2(Name = 'SilverSHIP Rest of India(0-1)'),
            new Product2(Name = 'SilverSHIP Rest of India (1-20)'),
            new Product2(Name = 'SilverSHIP Rest of India (20-25)'),
            new Product2(Name = 'SilverSHIP Within City (1-20)'),
            new Product2(Name = 'SilverSHIP Within City (20-25)'),
            new Product2(Name = 'SilverSHIP Within Region (0-1)'),
            new Product2(Name = 'SilverSHIP Within Region (1-20)'),
            new Product2(Name = 'SilverSHIP Within Region (20-25)')
        };
        insert productList;

       
        List<BVCQuoteLineItem__c> quoteLineItemList = new List<BVCQuoteLineItem__c>();
        for(Product2 product : productList) {
            quoteLineItemList.add(new BVCQuoteLineItem__c(
                BVCQuote__c = bq.Id,
                Product__c = product.id,
                Product_Name__c = product.Name
            ));
        }
        insert quoteLineItemList;
        system.debug('quoteLineItemList'+quoteLineItemList);
        system.debug('quoteLineItemList'+quoteLineItemList.size());
        
       
        return bq.Id;
    }

    @isTest
    static void testBVCnonAcrQuotePdfController() {
    
        Id quoteId = setupTestData();

        Test.startTest();
        PageReference pageRef = Page.BVCnonACRPDFVFpage;
        pageRef.getParameters().put('id', quoteId);
        Test.setCurrentPage(pageRef);

        BVCnonAcrQuotePdfController controller = new BVCnonAcrQuotePdfController();
        Test.stopTest();
       
       
    }
}