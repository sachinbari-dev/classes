global with sharing class SmartTrackingVehicle 
{
    public class PayloadBody
    {
        public String name;
        public String client_asset_number ;
        public String device_imei;
    }
    public static string jsonContentAfterUpdate(List<Smart_Tracking__c> st,Map<Id,Smart_Tracking__c> ost)
    {
         Smart_Tracking__c oldRecord = ost.get(st[0].Id);
        if(st[0].V_Allocation__c!=oldRecord.V_Allocation__c && st[0].V_Allocation__c!=null)
        {
            PayloadBody pl = new PayloadBody();
           // Secure_Bag__c sb = [select Id,Name,Secure_Packaging_Identifier__c from Secure_Bag__c where Id=:st[0].H_Allocation__c limit 1];
            Transport__c hub = [select Id,Name,Vehicle_Number__c from Transport__c where Id=:st[0].V_Allocation__c limit 1];
            String jsString='{';
            jsString = jsString +'"name":"'+hub.Name+'",';
            jsString = jsString +'"client_asset_number":"'+hub.Vehicle_Number__c+'",';        
            jsString = jsString +'"device_imei":"'+st[0].Imei__c+'"';  
     //       jsString = jsString +'"LastModifiedDate":"'+st[0].LastModifiedDate+'",'; 
            jsString = jsString +'}';
            System.debug('11. jsString :'+jsString); 
            sendRequest(jsString,hub.Id,st[0].Id);
            return jsString;            
        }
        return null;

    }
    
    public static string jsonContent(List<Smart_Tracking__c> st)
    {
        if(st[0].V_Allocation__c!=null)
        {
            PayloadBody pl = new PayloadBody();
            //Secure_Bag__c sb = [select Id,Name,Secure_Packaging_Identifier__c from Secure_Bag__c where Id=:st[0].SB_Allocation__c limit 1];
            Transport__c hub = [select Id,Name,Vehicle_Number__c from Transport__c where Id=:st[0].V_Allocation__c limit 1];
            String jsString='{';
            jsString = jsString +'"name":"'+hub.Name+'",';
            jsString = jsString +'"client_asset_number":"'+hub.Vehicle_Number__c+'",';        
            jsString = jsString +'"device_imei":"'+st[0].Imei__c+'"';  
     //       jsString = jsString +'"LastModifiedDate":"'+st[0].LastModifiedDate+'",'; 
            jsString = jsString +'}';
            System.debug('11. jsString :'+jsString);  
            sendRequest(jsString,hub.Id,st[0].Id);
            return jsString;            
        }
        return null;

    }
    
    @future(callout=true)   
    //global static void sendRequest(String jsonstring){
	global static void sendRequest(String jsonstring,String hb,String st){  
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        // req.setEndpoint('');               
        API_Integration_Credential__mdt Tracking_Webhook_url = API_Integration_Credential__mdt.getInstance('Smart_Tracking');        
        // API_Integration_Credential__mdt Tracking_Webhook_url = API_Integration_Credential__mdt.getInstance('Razorpay_Payment_Link_Generator');        // it is kept here for testing
        String endpoint = Tracking_Webhook_url.Server_URL__c;
        /* endpoint = endpoint +'/'; 
string username = Tracking_Webhook_url.UserName__c; 
string password = Tracking_Webhook_url.Password__c;
Blob headerValue = Blob.valueOf(username + ':' + password);
Blob headerValue = Blob.valueOf(headerValue);
System.debug('12.headerValue :'+headerValue); 
String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
*/
        req.setEndpoint(endpoint);
        req.setMethod('POST');        
       // req.setHeader('Username', Tracking_Webhook_url.UserName__c);
        req.setHeader('apikey', Tracking_Webhook_url.Password__c);
        req.setHeader('Content-Type','application/json');
        req.setBody(jsonstring);      
        // req.setBody('{"ID":0}');
        
        req.setTimeout(120000);        
        String printUrl = req.toString();
        System.debug(' printUrl :'+printUrl);
        System.debug(' getBody :'+req.getBody());
        System.debug(' getEndpoint :'+req.getEndpoint());
        //System.debug(' authorizationHeader :'+req.getHeader('Authorization'));
        //System.debug(' req :'+req.getHeader());
        System.debug(' req :'+req);
        //req.setCompressed(true);                        
        try {
            resp = http.send(req);
            System.debug('Response :'+resp);
            System.debug('Response getStatusCode:'+resp.getStatusCode());
            System.debug('Response getStatus:'+resp.getStatus());
            // System.debug('Response getBodyDocument:'+resp.getBodyDocument());
            System.debug('Response Body :'+resp.getBody());
            if(resp.getBody()!=null && resp.getStatusCode()==200)
            {
               // Secure_Bag__c securebag = [select Id,Name,Secure_Packaging_Identifier__c,UUID__c from Secure_Bag__c where Id=:sb limit 1];
                Transport__c hub = [select Id,Name,Vehicle_Number__c,UUID__c from Transport__c where Id=:hb limit 1];
                System.debug('hub :'+hub);  
                
                RespBody getresult = 
                (RespBody)JSON.deserialize(resp.getBody(), RespBody.class);                
                hub.UUID__c = getresult.uuid;
                update hub;                
            }
        }  catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(resp.toString());
        }        
    }

    public class RespBody
    {
        public String uuid;
        public String status;
    }    

}