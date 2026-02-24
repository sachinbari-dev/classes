@isTest
public class SecurePackagingBulkUpdateAPITest {

  @isTest
    static void testUpdateSecurePackagingByIdNoRequestBody() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
        
       
        String result = SecurePackagingBulkUpdateAPI.updateSecurePackagingById();
        
       
        System.assertEquals('Error: No request body provided.', result);
    }

    @isTest
    static void testUpdateSecurePackagingByIdNoRecordIds() {
       
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"recordIds": []}');
        RestContext.request = req;
        RestContext.response = res;
        
       
        String result = SecurePackagingBulkUpdateAPI.updateSecurePackagingById();
        
        
        System.assertEquals('Error:  No record IDs provided.', result);
    }

    @isTest
    static void testUpdateSecurePackagingByIdWithRecordIds() {
        
        secure_packaging__C sp1 = new secure_packaging__C();
        sp1.Digital__c = true;
        sp1.Consumed_in_Universe__c = false;
        sp1.Name = 'OS32424';
        sp1.Status__c = 'Available';
        sp1.Type_of_Packaging__c = 'Shipping Label';
        sp1.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
       
        
        secure_packaging__C sp2 = new secure_packaging__C();
        sp2.Digital__c = true;
        sp2.Consumed_in_Universe__c = false;
        sp2.Name = 'OS3242434';
        sp2.Status__c = 'Available';
        sp2.Type_of_Packaging__c = 'Shipping Label';
        sp2.RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
        
        
        insert new List<secure_packaging__C>{sp1,sp2};
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"recordIds": ["' + sp1.Id + '", "' + sp2.Id + '"]}');
        RestContext.request = req;
        RestContext.response = res;
        
        
        Test.startTest();
        String result = SecurePackagingBulkUpdateAPI.updateSecurePackagingById();
        Test.stopTest();
        
        
        System.assert(result.contains('Batch process initiated successfully'));
        System.assert(result.contains('JobID:'));
    }

    @isTest
    static void testUpdateSecurePackagingByIdWithException() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{invalidJson}');
        RestContext.request = req;
        RestContext.response = res;
        
       
        String result = SecurePackagingBulkUpdateAPI.updateSecurePackagingById();
        
        
        System.assert(result.contains('Error:'));
    }
}