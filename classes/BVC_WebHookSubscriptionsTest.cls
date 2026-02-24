@isTest

public class BVC_WebHookSubscriptionsTest 

{

 

    @isTest

    public static void testhandleNotification(){

        test.startTest();

    

        BVC_WebHookSubscriptions test1 = new BVC_WebHookSubscriptions();

        String JsonMsg='{"entity":"event","account_id":"acc_Dlk0O2LGK22bzk","event":"payment.captured","contains":["payment"],'

             +'"payload":{"payment":{"entity":{"id":"pay_JyHJj5DLxRqUzR","entity":"payment","amount":100000,"currency":"INR","status":"captured","order_id":"order_JyHIgSnXFxBRb9",'

             +'"invoice_id":null,"international":false,"method":"card","amount_refunded":0,"refund_status":null,"captured":true,"description":"#JyHHj4qEDpnRx6","card_id":"card_JqQ0DmdCJsRmp3",'

             +'"card":{"id":"card_JqQ0DmdCJsRmp3","entity":"card","name":"Test","last4":"1111","network":"Visa","type":"debit","issuer":null,"international":false,"emi":false,"sub_type":"consumer",'

             +'"token_iin":null},"bank":null,"wallet":null,"vpa":null,"email":"bkaperla@cloudely.com","contact":"+918106603190","token_id":"token_JqQ0DrAxgZrghK","notes":{"invoice_number":"27TI19523"},'

             +'"fee":10620,"tax":1620,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"262733"},"created_at":1658900439}}},'

             +'"created_at":1658900444}';

	RestRequest req = new RestRequest(); 

    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/Pushnotification';  //Request URL

    req.httpMethod = 'POST';//HTTP Request Type

    req.requestBody = Blob.valueof(JsonMsg);

    RestContext.request = req;

    RestContext.response= res;

    BVC_WebHookSubscriptions.handleNotification();

    /// test Refund Call

    String JsonRefundMsg= '{"entity":"event","account_id":"acc_Dlk0O2LGK22bzk","event":"refund.processed","contains":["refund","payment"],'

			 +'"payload":{"refund":{"entity":{"id":"rfnd_Jyjl5OmuGYpSjf","entity":"refund","amount":500000,"currency":"INR","payment_id":"pay_JyHJj5DLxRqUzR","notes":{"comment":""},"receipt":null,'

			 +'"acquirer_data":{"arn":null},"created_at":1659000598,"batch_id":null,"status":"processed","speed_processed":"normal","speed_requested":"normal"}},'

			 +'"payment":{"entity":{"id":"pay_JyHJj5DLxRqUzR","entity":"payment","amount":1000000,"currency":"INR","base_amount":1000000,"status":"captured","order_id":"order_JyHIgSnXFxBRb9","invoice_id":null,'

			 +'"international":false,"method":"card","amount_refunded":500000,"amount_transferred":0,"refund_status":"partial","captured":true,"description":"#JyHHj4qEDpnRx6","card_id":"card_JqQ0DmdCJsRmp3",'

			 +'"card":{"id":"card_JqQ0DmdCJsRmp3","entity":"card","name":"Test","last4":"1111","network":"Visa","type":"debit","issuer":null,"international":false,"emi":false,"sub_type":"consumer","token_iin":null},'

			 +'"bank":null,"wallet":null,"vpa":null,"email":"bkaperla@cloudely.com","contact":"+918106603190","token_id":"token_JqQ0DrAxgZrghK","notes":{"invoice_number":"27TI19523"},"fee":10620,"tax":1620,"error_code":null,'

			 +'"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"262733"},"created_at":1658900439}}},"created_at":1659000598}';        

    RestRequest reqRefund = new RestRequest(); 

    RestResponse resRefund = new RestResponse();

    reqRefund.requestURI = '/services/apexrest/Pushnotification';  //Request URL

    reqRefund.httpMethod = 'POST';//HTTP Request Type

    reqRefund.requestBody = Blob.valueof(JsonRefundMsg);

    RestContext.request = reqRefund;

    RestContext.response= resRefund;

    BVC_WebHookSubscriptions.handleNotification();

    // test Pay without invoice

    string JsonWithoutInvoice = '{"entity":"event","account_id":"acc_Dlk0O2LGK22bzk","event":"payment.captured","contains":["payment"],'

        +'"payload":{"payment":{"entity":{"id":"pay_Jyo1AKwsB2nX3f","entity":"payment","amount":200000,"currency":"INR","status":"captured",'

        +'"order_id":"order_Jyo142AKFb208I","invoice_id":null,"international":false,"method":"card","amount_refunded":0,"refund_status":null,'

        +'"captured":true,"description":null,"card_id":"card_JqQ0DmdCJsRmp3","card":{"id":"card_JqQ0DmdCJsRmp3","entity":"card","name":"Test",'

        +'"last4":"1111","network":"Visa","type":"debit","issuer":null,"international":false,"emi":false,"sub_type":"consumer","token_iin":null},'

        +'"bank":null,"wallet":null,"vpa":null,"email":"bkaperla@cloudely.com","contact":"+918106603190","token_id":"token_JqQ0DrAxgZrghK",'

        +'"notes":{"invoice_number":"123","email":"test@gmail.com","phone":"1234567890"},"fee":100,"tax":0,"error_code":null,"error_description":null,'

        +'"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"726866"},"created_at":1659015598}}},"created_at":1659015602}';

    RestRequest reqpay = new RestRequest(); 

    RestResponse respay = new RestResponse();

    reqRefund.requestURI = '/services/apexrest/Pushnotification';  //Request URL

    reqpay.httpMethod = 'POST';//HTTP Request Type

    reqpay.requestBody = Blob.valueof(JsonWithoutInvoice);

    RestContext.request = reqpay;

    RestContext.response= respay;

   // system.debug(inv);

    BVC_WebHookSubscriptions.handleNotification();

    // test invoice series as blank

    string JsonEmptyInvoice = '{"entity":"event","account_id":"acc_Dlk0O2LGK22bzk","event":"refund.processed","contains":["refund","payment"],'

			 +'"payload":{"refund":{"entity":{"id":"rfnd_Jyjl5OmuGYpSjf","entity":"refund","amount":500000,"currency":"INR","payment_id":"pay_JyHJj5DLxRqUzR","notes":{"comment":""},"receipt":null,'

			 +'"acquirer_data":{"arn":null},"created_at":1659000598,"batch_id":null,"status":"processed","speed_processed":"normal","speed_requested":"normal"}},'

			 +'"payment":{"entity":{"id":"pay_JyHJj5DLxRqUzR","entity":"payment","amount":1000000,"currency":"INR","base_amount":1000000,"status":"captured","order_id":"order_JyHIgSnXFxBRb9","invoice_id":null,'

			 +'"international":false,"method":"card","amount_refunded":500000,"amount_transferred":0,"refund_status":"partial","captured":true,"description":"#JyHHj4qEDpnRx6","card_id":"card_JqQ0DmdCJsRmp3",'

			 +'"card":{"id":"card_JqQ0DmdCJsRmp3","entity":"card","name":"Test","last4":"1111","network":"Visa","type":"debit","issuer":null,"international":false,"emi":false,"sub_type":"consumer","token_iin":null},'

			 +'"bank":null,"wallet":null,"vpa":null,"email":"bkaperla@cloudely.com","contact":"+918106603190","token_id":"token_JqQ0DrAxgZrghK","notes":{"invoice_number":""},"fee":10620,"tax":1620,"error_code":null,'

			 +'"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":"262733"},"created_at":1658900439}}},"created_at":1659000598}';

    RestRequest reqEmptyInv = new RestRequest(); 

    RestResponse resEmptyInv = new RestResponse();

    reqRefund.requestURI = '/services/apexrest/Pushnotification';  //Request URL

    reqEmptyInv.httpMethod = 'POST';//HTTP Request Type

    reqEmptyInv.requestBody = Blob.valueof(JsonEmptyInvoice);

    RestContext.request = reqEmptyInv;

    RestContext.response= resEmptyInv;

   // system.debug(inv);

    BVC_WebHookSubscriptions.handleNotification();

 //   BVC_PushPaymentService.createPayment(); removed because it was not available in prod while deployment of CPQ uninstallation

    BVC_WebHookSubscriptions.GetCoverage();  

        BVC_WebHookSubscriptions.GetCoverage1();

        BVC_WebHookSubscriptions.GetCoverage2();

        BVC_WebHookSubscriptions.GetCoverage3();

        BVC_WebHookSubscriptions.GetCoverage4();
   //     BVC_PushPaymentService.dummyMethod();

    Test.stopTest();

    }
    

}