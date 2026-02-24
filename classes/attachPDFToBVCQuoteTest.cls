@isTest
public class attachPDFToBVCQuoteTest {

   @isTest
    static void testmethod1(){
        
         List<id> QuoteList = new List<id>();
        
        Account acc = BVCL_TestDataFactory.createCustomer('Test','Billing',True);
          String currentDate = String.valueOf(system.today());
        
        BVCQuote__c bvcq = new BVCQuote__c();
        bvcq.Account__c = Acc.id;
        bvcq.BVC_Service__c = 'ExhibiSHIP';
        bvcq.Status__c = 'Quote Sent';
        bvcq.Quote_Sent_Date__c = system.today();
        bvcq.Document_Date__c = system.today();

        insert bvcq;
        QuoteList.add(bvcq.id);
        system.debug(QuoteList);
        
        
        String fileContent = 'This is a test file content';
        
     
        Blob fileBlob = Blob.valueOf(fileContent);
        
       
        ContentVersion testFile = new ContentVersion();
        testFile.Title = 'TestFile.pdf';
        testFile.PathOnClient = 'TestFile.pdf';
        testFile.VersionData = fileBlob;
        testFile.IsMajorVersion = true;
        testFile.FirstPublishLocationId = bvcq.id;
        insert testFile;
        try{
            attachPDFToBVCQuote.getPdfBlob(QuoteList);
            
        }catch(exception e){
            system.debug('exception'+e);
        }
      
    }
     @isTest
    static void testmethod4(){
        
         List<id> QuoteList = new List<id>();
         String currentDate = String.valueOf(system.today());
        Account acc = BVCL_TestDataFactory.createCustomer('Test','Billing',True);
        
        BVCQuote__c bvcq = new BVCQuote__c();
        bvcq.Account__c = Acc.id;
        bvcq.BVC_Service__c = 'ValSHIP';
         bvcq.Business_Type__c = 'Non ACR';
        bvcq.Status__c = 'Quote Sent';
        bvcq.Quote_Sent_Date__c = system.today();
        bvcq.Document_Date__c = system.today();

        insert bvcq;
        QuoteList.add(bvcq.id);
        system.debug(QuoteList);
        
         String fileContent = 'This is a test file content';
        
       
        Blob fileBlob = Blob.valueOf(fileContent);
        
        
        ContentVersion testFile = new ContentVersion();
        testFile.Title = 'TestFile.pdf';
        testFile.PathOnClient = 'TestFile.pdf';
        testFile.VersionData = fileBlob;
        testFile.IsMajorVersion = true;
        testFile.FirstPublishLocationId = bvcq.id;
        insert testFile;
        try{
              attachPDFToBVCQuote.addFile(QuoteList);
            
        }catch(exception e){
            system.debug('exception'+e);
        }
      
    }
     @isTest
    static void testmethod2(){
        
         List<id> QuoteList = new List<id>();
         String currentDate = String.valueOf(system.today());
        Account acc = BVCL_TestDataFactory.createCustomer('Test','Billing',True);
        
        BVCQuote__c bvcq = new BVCQuote__c();
        bvcq.Account__c = Acc.id;
        bvcq.BVC_Service__c = 'ExhibiSHIP';
        bvcq.Business_Type__c = 'Non ACR';
        bvcq.Status__c = 'Quote Sent';
        bvcq.Quote_Sent_Date__c = system.today();
        bvcq.Document_Date__c = system.today();

        insert bvcq;
        QuoteList.add(bvcq.id);
        system.debug(QuoteList);
        
         String fileContent = 'This is a test file content';
        
       
        Blob fileBlob = Blob.valueOf(fileContent);
        
        
        ContentVersion testFile = new ContentVersion();
        testFile.Title = 'TestFile.pdf';
        testFile.PathOnClient = 'TestFile.pdf';
        testFile.VersionData = fileBlob;
        testFile.IsMajorVersion = true;
        testFile.FirstPublishLocationId = bvcq.id;
        insert testFile;
        
        try{
             attachPDFToBVCQuote.addFile(QuoteList);
           
        }catch(exception e){
           
            system.debug('exception'+e);
        }
        
        
     
    }
       @isTest
    static void testmethod3(){
        
         List<id> QuoteList = new List<id>();
        
        Account acc = BVCL_TestDataFactory.createCustomer('Test','Billing',True);
        
        BVCQuote__c bvcq = new BVCQuote__c();
        bvcq.Account__c = Acc.id;
        bvcq.BVC_Service__c = 'ExhibiSHIP';
        bvcq.Status__c = 'Quote Sent';
        bvcq.Quote_Sent_Date__c = system.today();
        bvcq.Document_Date__c = system.today();

        insert bvcq;
        QuoteList.add(bvcq.id);
        system.debug(QuoteList);
        
         String fileContent = 'This is a test file content';
        
       
        Blob fileBlob = Blob.valueOf(fileContent);
        
    
        ContentVersion testFile = new ContentVersion();
        testFile.Title = 'TestFile.pdf';
        testFile.PathOnClient = 'TestFile.pdf';
        testFile.VersionData = fileBlob;
        testFile.IsMajorVersion = true;
        testFile.FirstPublishLocationId = bvcq.id;
        insert testFile;
        
        try{
            Test.setMock(HttpCalloutMock.class, new sendGridEmailMessageAttachmentsMock());
             attachPDFToBVCQuote.sendEmailToCustomer(QuoteList, testFile.VersionData);
           
        }catch(exception e){
           
            system.debug('exception'+e);
        }
        
        
     
    }
}