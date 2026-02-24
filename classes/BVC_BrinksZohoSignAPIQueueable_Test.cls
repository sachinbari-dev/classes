@isTest
public class BVC_BrinksZohoSignAPIQueueable_Test {

    @isTest
    static void testQueueableExecution() {
       
        BVC_bulk_Agreement_signing__c testQuote = new BVC_bulk_Agreement_signing__c(customer_Address__c = 'test');
        insert testQuote;

        Test.startTest();
        System.enqueueJob(new BVC_BrinksZohoSignAPIQueueable(new List<Id>{testQuote.Id}));
        Test.stopTest(); 
    }
}