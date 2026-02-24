global with sharing class SmartTrackingHubDeallocation {
	public static void deallocation(List<Hub__c> hbList,Map<Id,Hub__c> oldHBMap) //Deallocated__c
    {
        System.debug('Inside SmartTrackingDeallocation');
        Hub__c oldRecord = oldHBMap.get(hbList[0].Id);
        if(hbList[0].Deallocated__c!=oldRecord.Deallocated__c &&
           hbList[0].Deallocated__c==true && hbList[0].UUID__c!=null)
        {
            System.debug('Inside SmartTrackingDeallocation Calling SendRequest');
            sendRequest(hbList[0].UUID__c,hbList[0].Id);
        }
    }
    @future(callout=true)
    global static void sendRequest(String uuid,string sbId)
    {  
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        // req.setEndpoint('');               
        API_Integration_Credential__mdt Tracking_Webhook_url = API_Integration_Credential__mdt.getInstance('Smart_Tracking');        
        // API_Integration_Credential__mdt Tracking_Webhook_url = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');        // it is kept here for testing
        String endpoint = Tracking_Webhook_url.Server_URL__c;
		endpoint = endpoint +'/'+uuid;
        System.debug(' endpoint :'+endpoint);
        req.setEndpoint(endpoint);
        req.setMethod('DELETE');        
        req.setHeader('apikey', Tracking_Webhook_url.Password__c);
        req.setHeader('Content-Type','application/json');           
        req.setTimeout(120000);        
        String printUrl = req.toString();
        System.debug(' printUrl :'+printUrl);
        System.debug(' getBody :'+req.getBody());
        System.debug(' getEndpoint :'+req.getEndpoint());
        System.debug(' req :'+req);
        try {
            resp = http.send(req);
            System.debug('Response :'+resp);
            System.debug('Response getStatusCode:'+resp.getStatusCode());
            System.debug('Response getStatus:'+resp.getStatus());
            // System.debug('Response getBodyDocument:'+resp.getBodyDocument());
            System.debug('Response Body :'+resp.getBody());
            if(resp.getBody()!=null && resp.getStatusCode()==200)
            {               
					System.debug('resp.getBody() :'+resp.getBody());
            }
        }  catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(resp.toString());
        }    
    }
}