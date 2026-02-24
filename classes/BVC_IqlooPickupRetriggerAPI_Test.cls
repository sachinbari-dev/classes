@isTest
public class BVC_IqlooPickupRetriggerAPI_Test {

    @isTest
    static void testIqlooNoRequestBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;

        String result = BVC_IqlooPickupRetriggerAPI.generateIqlooOTP();
        System.assertEquals('Error: No request body provided.', result);
    }

    @isTest
    static void testIqlooNoRecordIds() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"recordId": []}');  // <-- corrected key
        RestContext.request = req;
        RestContext.response = res;

        String result = BVC_IqlooPickupRetriggerAPI.generateIqlooOTP();
        System.assertEquals('Error:  No record IDs provided.', result);
    }

    @isTest
    static void testIqlooWithPickup() {
        
        Test.setMock(HttpCalloutMock.class,new BVC_IqlooLockAPIHelperMock2());
         
        secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X1889b31c',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
        Pickup__c p = new Pickup__c(
            pickup_Status__c = 'Assigned',
            Lock_ID__c = sp.Id
        );
        insert p;

        List<String> ids = new List<String>{ p.Id};
        String requestBody = JSON.serialize(new Map<String, Object>{ 'recordId' => ids });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BVC_IqlooPickupRetriggerAPI.getCoverage();
        String result = BVC_IqlooPickupRetriggerAPI.generateIqlooOTP();
        Test.stopTest();

        System.debug('Response: ' + result);
 
    }
    @isTest
    static void testIqlooWithShipment() {
        
        Test.setMock(HttpCalloutMock.class,new BVC_IqlooLockAPIHelperMock2());
         
        secure_packaging__C sp = new secure_packaging__C(
            Name = 'SP2X1889b31c',
            Status__c = 'Available',
            Digital__c = false,
            Consumed_in_Universe__c = false,
            Type_of_Packaging__c = 'Lock',
            RecordTypeId = Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shield Lock').getRecordTypeId()
        );
        insert sp;

        
       Shipment__c s = new shipment__c();
        s.LOCK_ID__c = 'SP2X1889b31c';
        
        insert s;

        List<String> ids = new List<String>{ s.Id};
        String requestBody = JSON.serialize(new Map<String, Object>{ 'recordId' => ids });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BVC_IqlooPickupRetriggerAPI.getCoverage();
        String result = BVC_IqlooPickupRetriggerAPI.generateIqlooOTP();
        Test.stopTest();

        System.debug('Response: ' + result);
 
    }

    @isTest
    static void testIqlooWithException() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{invalidJson}');
        RestContext.request = req;
        RestContext.response = res;

        String result = BVC_IqlooPickupRetriggerAPI.generateIqlooOTP();
        System.assert(result.startsWith('Error:'), 'Should catch and return error message');
    }
}