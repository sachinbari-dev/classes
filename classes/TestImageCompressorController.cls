@IsTest
private class TestImageCompressorController {

    @IsTest
    static void testUploadImage_success() {
        ImageCompTestObj__c testAcc = new ImageCompTestObj__c();
        testAcc.Name = 'Test1';
        Insert testAcc;
        
        String sampleImageData = 'data:image/jpeg;base64,' + EncodingUtil.base64Encode(Blob.valueOf('dummy image data'));

        Map<String, Object> requestMap = new Map<String, Object>{
            'imageContent' => sampleImageData,
            'recId' => testAcc.Id
        };
        String requestBody = JSON.serialize(requestMap);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/imagecompressor/';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        String response = ImageCompressorController.uploadImage();
        Test.stopTest();

    }

    @IsTest
    static void testUploadImage_missingFields() {
        Map<String, Object> requestMap = new Map<String, Object>{
            'imageContent' => 'dummydata'
        };
        String requestBody = JSON.serialize(requestMap);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/imagecompressor/';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        String response = ImageCompressorController.uploadImage();
        Test.stopTest();

    }

    @IsTest
    static void testUploadImage_exceptionHandling() {
        ImageCompTestObj__c testAcc = new ImageCompTestObj__c();
        testAcc.Name = 'Test1';
        Insert testAcc;
        
        Map<String, Object> requestMap = new Map<String, Object>{
            'imageContent' => 'data:image/jpeg;base64,@@@INVALIDBASE64@@@',
            'recId' => testAcc.Id
        };
        String requestBody = JSON.serialize(requestMap);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/imagecompressor/';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        String response = ImageCompressorController.uploadImage();
        Test.stopTest();

    }
}