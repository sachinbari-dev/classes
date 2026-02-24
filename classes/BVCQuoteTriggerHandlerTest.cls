@IsTest
public class BVCQuoteTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        BVCQuote__c quote1 = new BVCQuote__c();
        insert quote1;

        BVCQuote__c quote2 = new BVCQuote__c();
        insert quote2;

        BVCQuoteLineItem__c lineItem1 = new BVCQuoteLineItem__c();
        lineItem1.BVCQuote__c = quote1.Id;
        lineItem1.Quantity__c = 5;
        lineItem1.Product_name__c = 'Product111';
        insert lineItem1;

        BVCQuoteLineItem__c lineItem2 = new BVCQuoteLineItem__c();
        lineItem2.BVCQuote__c = quote2.Id;
        lineItem2.Quantity__c = 3;
        lineItem2.Product_name__c = 'Product222';
        
        insert lineItem2;
    }

    @IsTest
    static void testBVCQuoteProcessor() {
       Map<Id, BVCQuote__c> bvcQuoteMap = new Map<Id, BVCQuote__c>([
            SELECT Id
            FROM BVCQuote__c
            WHERE Name = 'Quote1'
        ]);

        Test.startTest();
        BVCQuoteTriggerHandler.BVCQuoteProcessor(bvcQuoteMap);
        Test.stopTest();
    }

    @IsTest
    static void testGenerateInvoice() {
        Map<Id, BVCQuote__c> bvcQuoteMap = new Map<Id, BVCQuote__c>([
            SELECT Id
            FROM BVCQuote__c
            WHERE Name = 'Quote1'
        ]);

        Test.startTest();
        BVCQuoteTriggerHandler.generateInvoice(bvcQuoteMap);
        BVCQuoteTriggerHandler.getCoverage();
        Test.stopTest();

    }

}