public with sharing class SendOutBoundOtp 
{
    @future(callout=true)
    public static void resendOTP(String requestBody) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint( 'https://Staging.bvclogistics.com/Notification_CS/rest/ResendOTP/DeliveryOTP' );
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Pass request payload if required
        if (requestBody != null) {
            req.setBody(requestBody);
        }
        HttpResponse res = http.send(req);
        System.debug('Response Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());
        //return res.getBody();
    }
}