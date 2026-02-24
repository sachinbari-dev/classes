@isTest
public class BVCRazorpayAllocationBatchTest 
{
    @isTest
    public static void testhandleNotification()
    {
        test.startTest();
        Account BillingAcc = BVCL_TestDataFactory.createCustomer('BVCLBill Customer','Billing',true);
        Account ShipperAcc = BVCL_TestDataFactory.createCustomer('BVCLShipp Customer','Shipping',true);
        Hub__c DelhiHub = BVCL_TestDataFactory.CreateHub('Delhi', true, 'DELHI');
        Active_Pincode__c DelhiPin = BVCL_TestDataFactory.CreatePincode('110025', DelhiHub.id, 'Delhi', 'South', true);
        AddressBook__c regularAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        AddressBook__c sezAddress = BVCL_TestDataFactory.CreateAddress('Shipping',ShipperAcc.id,'Line 1',DelhiPin.id,'Cityyy',true);
        Secure_Packaging__c Seal = BVCL_TestDataFactory.createPackaging('Secure Seal','EZ333','Available',true);
        Secure_Packaging__c SP_Bag = BVCL_TestDataFactory.createPackaging('Secure Bag','EZ888999','Available',true);
        
        BVCInvoice__c invoice1 = new BVCInvoice__c(
            Account__c = BillingAcc.Id,
            Status__c = 'Posted',
            EY_Tax_Calculation_Status__c = 'Success',
            Billing_Address__c = regularAddress.Id,
            Razorpay_Id__c='plink_On1l7elWUtgfnE',
            Short_URL__c='https://rzp.io/i/zvn47YuqYl' 
        );
        BVCInvoice__c invoice2 = new BVCInvoice__c(
            Account__c = BillingAcc.Id,
            Status__c = 'Draft',
            EY_Tax_Calculation_Status__c = 'Success',
            Billing_Address__c = sezAddress.Id
        );
        List<BVCInvoice__c> invList = new List<BVCInvoice__c>();
        invList.add(invoice1);
        // invList.add(invoice2);
        // insert new List<BVCInvoice__c>{invoice1, invoice2};
        insert invList;
            
            DocumentSeries__c docSeries = new DocumentSeries__c(
                Name = 'Doc Series 1',
                Unique_Key__c = '01TI',
                Last_Serial_Number__c = '01TI0001'
            );
        insert docSeries;
        BVCRazorpayAllocationBatch BvcRbatch = new BVCRazorpayAllocationBatch(invoice1.Id);
        Database.executeBatch(BvcRbatch,20);
        
        string endpoint = 'https://api.razorpay.com/v1/payment_links/';
        //string method = 'GET';  
        //
        string username = 'rzp_live_JA5HWotrBj8p5M'; 
        string password = '2kl9CVFq12TJ5n62zorVLPhI';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);        
        BVCPaymentBuilder.paymentLinkGenerator(endpoint,authorizationHeader,invList); 
        
        test.stopTest();
    }
}