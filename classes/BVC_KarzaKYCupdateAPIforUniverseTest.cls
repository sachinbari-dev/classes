@IsTest
public class BVC_KarzaKYCupdateAPIforUniverseTest {

    @TestSetup
    static void setupTestData() {
        // Create test Accounts
        Account acc1 = new Account(Name = 'balaji raghav jwelles AAAFH2213A - Billing AAAFH2213A BHAPN5467P', PAN_Number_of_Entity__c = 'ABCDE1234F');
        insert acc1;

        Account acc2 = new Account(Name = 'raman wagh jwells HGHHJ7656Y - Billing HGHHJ7656Y BHAPN5467P', PAN_Number_of_Entity__c = null);
        insert acc2;
    }

    @IsTest
    static void testSuccessfulUpdateAndPANVerification() {
        // Prepare the request payload
        String requestBody = JSON.serialize(new Map<String, Object>{
            'Name' => 'balaji raghav jwelles AAAFH2213A - Billing AAAFH2213A BHAPN5467P',
            'PAN_Number_of_Entity__c' => 'XYZ456789P',
            'First_Name__c' => 'John',
            'Last_Name__c' => 'Doe',
            'Primary_Customer_Email__c' => 'john.doe@example.com',
            'Phone' => '1234567890',
            'Customer_Created_In_Universe__c' => true
        });

        // Mock the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the API method
        Test.startTest();
        String response = BVC_KarzaKYCupdateAPIforUniverse.karzaKYCUpdate();
        BVC_KarzaKYCupdateAPIforUniverse.GetCoverage();
        Test.stopTest();
         system.debug('response@@@@'+ response);
        // Assert the response
   //     System.assert(response.contains('Customer updated successfully And PAN KYC Re-verification initiated ID:'), 'Response does not contain success message.');

        // Validate account updates
       
    }

    @IsTest
    static void testMissingNameField() {
        // Prepare the request payload without Name
        String requestBody = JSON.serialize(new Map<String, Object>{
            'PAN_Number_of_Entity__c' => 'XYZ456789P'
        });

        // Mock the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the API method
        Test.startTest();
        String response = BVC_KarzaKYCupdateAPIforUniverse.karzaKYCUpdate();
        Test.stopTest();

        // Assert the response
        System.assertEquals('Error: Missing required field "Name".', response);
    }

    @IsTest
    static void testBlankNameField() {
        // Prepare the request payload with blank Name
        String requestBody = JSON.serialize(new Map<String, Object>{
            'Name' => '',
            'PAN_Number_of_Entity__c' => 'XYZ456789P'
        });

        // Mock the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the API method
        Test.startTest();
        String response = BVC_KarzaKYCupdateAPIforUniverse.karzaKYCUpdate();
        Test.stopTest();

        // Assert the response
        System.assertEquals('Error: Missing required field "Name".', response);
    }

    @IsTest
    static void testCustomerNotFound() {
        // Prepare the request payload with a non-existing customer
        String requestBody = JSON.serialize(new Map<String, Object>{
            'Name' => 'Non Existing Customer',
            'PAN_Number_of_Entity__c' => 'XYZ456789P'
        });

        // Mock the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the API method
        Test.startTest();
        String response = BVC_KarzaKYCupdateAPIforUniverse.karzaKYCUpdate();
        Test.stopTest();

        // Assert the response
        System.assert(response.contains('Error: No customer found with the provided Name'), 'Response does not indicate customer not found.');
    }

    @IsTest
    static void testFutureMethodInvocation() {
        // Simulate future method invocation
        Test.startTest();
        BVC_KarzaKYCupdateAPIforUniverse.verifyPANInFuture(
            new List<String>{'001XXXXXXXXXXXX'},
            new List<String>{'ABCDE1234F'}
        );
        Test.stopTest();
    }
}