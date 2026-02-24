@isTest
public class BVC_GenerateBrinksPDFQueueable_Test {

       @TestSetup
    static void setupTestData() {

        BVC_bulk_Agreement_signing__c testRecord = new BVC_bulk_Agreement_signing__c();
        insert testRecord;
        
        
          ContentVersion cv= new Contentversion();
          cv.title= 'Test';
          cv.PathOnClient ='Test'+'.pdf';         
          cv.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
          cv.SharingPrivacy = 'N';
          cv.FirstPublishLocationId = testRecord.id;
          insert cv; 
        
        
    }
    
    @IsTest
    static void testQueueableExecution() {
      
        BVC_bulk_Agreement_signing__c testRecord = [SELECT Id FROM BVC_bulk_Agreement_signing__c LIMIT 1];
        
   
        Test.startTest();
        System.enqueueJob(new BVC_GenerateBrinksPDFQueueable(testRecord.Id));
        Test.stopTest();
        
       
    }
}