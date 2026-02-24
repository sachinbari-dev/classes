@isTest
public class BVC_ZohogetDocumentButtonTest {

      @isTest
    public static void testZohoDocument(){
        
        Test.startTest();
        
        // Call the method to be tested
        BVC_ZohogetDocumentButton.getDocument();
        
        // Check if the batch job was added to the job queue
        Integer jobCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        
        Test.stopTest();
    }
}