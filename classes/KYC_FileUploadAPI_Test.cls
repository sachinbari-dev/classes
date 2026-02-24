@IsTest
public class KYC_FileUploadAPI_Test {

      @TestSetup
    static void setupData() {
     
        BVCQuote__c a = new BVCQuote__c(Status__c = 'Draft');
        insert a;
        Account ac = new Account(name='TestAccount');
        insert Ac;
    }

    static String base64For(String plain) {
        return EncodingUtil.base64Encode(Blob.valueOf(plain));
    }
    @IsTest
    static void testNotCustomerId(){
         BVCQuote__c acct = [SELECT Id FROM BVCQuote__c LIMIT 1];

       
        Map<String, Object> fileItem = new Map<String, Object>{
            'linkedEntityIds' => new List<Id>{ acct.Id },
            'title' => 'TestTitle',
            'fileName' => 'TestFile1',
            'base64Data' => base64For('This is a test PDF content'),
            'contentType' => 'application/pdf'
        };

        Map<String, Object> grp = new Map<String, Object>{
            'recordId' => acct.Id,
            'files' => new List<Object>{ fileItem }
        };

        List<Object> grp1 = new List<Object>{ grp };
        String jsonBody = JSON.serialize(grp1);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        
        Test.startTest();
        List<KYC_FileUploadAPI.FileResult> results = KYC_FileUploadAPI.uploadFilesForQuotes();
        Test.stopTest();
    }
    @IsTest
    static void testSuccessfulUploadAndLink() {
        
        Account acct = [SELECT Id FROM Account LIMIT 1];

       
        Map<String, Object> fileItem = new Map<String, Object>{
            'linkedEntityIds' => new List<Id>{ acct.Id },
            'title' => 'TestTitle',
            'fileName' => 'TestFile1',
            'base64Data' => base64For('This is a test PDF content'),
            'contentType' => 'application/pdf'
        };

        Map<String, Object> grp = new Map<String, Object>{
            'recordId' => acct.Id,
            'files' => new List<Object>{ fileItem }
        };

        List<Object> grp1 = new List<Object>{ grp };
        String jsonBody = JSON.serialize(grp1);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        
        Test.startTest();
        List<KYC_FileUploadAPI.FileResult> results = KYC_FileUploadAPI.uploadFilesForQuotes();
        Test.stopTest();

     
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'There should be exactly one FileResult returned');
        KYC_FileUploadAPI.FileResult fr = results[0];
        System.assertEquals('SUCCESS', fr.status, 'Status should be SUCCESS for properly uploaded and linked file');
        System.assertEquals('File uploaded and linked successfully.', fr.message);

   
        System.assertNotEquals(null, fr.contentDocumentId, 'ContentDocumentId should be populated');
        System.assertNotEquals(null, fr.contentVersionId, 'ContentVersionId should be populated');

    
        List<ContentDocumentLink> cdls = [
            SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility
            FROM ContentDocumentLink
            WHERE ContentDocumentId = :fr.contentDocumentId
            AND LinkedEntityId = :acct.Id
        ];
        System.assertEquals(1, cdls.size(), 'One ContentDocumentLink should have been created linking to the account');
        System.assertEquals('V', cdls[0].ShareType);
        System.assertEquals('AllUsers', cdls[0].Visibility);

    
        System.assert(fr.linkedEntityIdsCreated.contains(acct.Id), 'linkedEntityIdsCreated should contain the account id');
    }

    @IsTest
    static void testMissingBase64OrFileNameErrors() {
        Account acct = [SELECT Id FROM Account LIMIT 1];

     
        Map<String, Object> badFile1 = new Map<String, Object>{
            'linkedEntityIds' => new List<Id>{ acct.Id },
            'title' => 'BadFile',
            'fileName' => 'BadFile1',
            'base64Data' => '', // blank
            'contentType' => 'application/pdf'
        };

     
        Map<String, Object> badFile2 = new Map<String, Object>{
            'linkedEntityIds' => new List<Id>{ acct.Id },
            'title' => 'BadFile2',
            'fileName' => null, // null
            'base64Data' => base64For('something'),
            'contentType' => 'application/pdf'
        };

        Map<String, Object> grp = new Map<String, Object>{
            'recordId' => acct.Id,
            'files' => new List<Object>{ badFile1, badFile2 }
        };

        List<Object> grp1 = new List<Object>{ grp };
        String jsonBody = JSON.serialize(grp1);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        List<KYC_FileUploadAPI.FileResult> results = KYC_FileUploadAPI.uploadFilesForQuotes();
        Test.stopTest();

       
        System.assertEquals(2, results.size(), 'Expected two file results for the two files provided');

     
        Integer errorCount = 0;
        for (KYC_FileUploadAPI.FileResult r : results) {
            if (r.status == 'ERROR') {
                errorCount++;
                System.assert(r.message != null && r.message.startsWith('fileName and base64Data are required.' ) 
                              || r.message.contains('Base64 decode failed') , 'Error message should describe missing data or decode failures');
            }
        }
        System.assertEquals(2, errorCount, 'Both files should have produced ERROR results');
    }
    
}