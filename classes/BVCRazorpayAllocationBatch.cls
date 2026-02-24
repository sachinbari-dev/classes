global class BVCRazorpayAllocationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
	public String InvoiceId;   
    public BVCRazorpayAllocationBatch(String invId)
    {
        this.InvoiceId = invId;
    }
    API_Integration_Credential__mdt razorPayLoginCredentials = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');
    string endpoint = razorPayLoginCredentials.Server_URL__c+'/';
    //string method = 'GET';  
    //
    string username = razorPayLoginCredentials.UserName__c; 
    string password = razorPayLoginCredentials.Password__c;
   
    global Database.QueryLocator Start(Database.BatchableContext bc){
        /*String str = 'abc-xyz-123';
        List < String > strList = str.split( '-' );
        System.debug( 'List String is ' + strList );*/
        System.debug('30 InvoiceId:::' +InvoiceId);
        String query = 'SELECT Id,Name,'
        +' Razorpay_Id__c,Short_URL__c,Account__c,ST_Invoice_Series__c,Total_Amount_With_Tax__c,'
        +' (SELECT Id,Name,Amount1__c,BVCInvoice__c,'
        +' Payment_Type__c FROM BVCPayments__r WHERE Payment_Type__c = \'Razorpay\' Order By createdDate desc LIMIT 1),'
        +' (SELECT id,Amount__c,RazorPay_PaymentId__c from BVC_Payment_Allocations_Invoice__r WHERE '
        +' BVCPayment__r.Payment_Type__c = \'Razorpay\' AND RazorPay_PaymentId__c != null)'
        +' FROM BVCInvoice__c'
        +' WHERE Razorpay_Id__c != null'
        +' AND  Short_URL__c != null'
        +' AND Status__c = \'Posted\''
        +' AND Payment_Status__c != \'Paid\''
        +' AND CreatedDate <= LAST_N_DAYS:10 and Id=:InvoiceId';
        System.debug('30 query:::' +query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<BVCInvoice__c> scope){
        List<String> rpayIds = new List<String>();        
        System.debug('30 Invoice List:::Batch:::' +scope);
        System.debug('31 InvoiceId:::' +scope);
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);        
        BVCPaymentBuilder.paymentLinkGenerator(endpoint,authorizationHeader,scope);                 
    }
    global void finish(Database.BatchableContext bc){
        
    }
}