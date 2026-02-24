public class BVC_ZohoSignAcessTokenGenerator {

    public static void AccessTokenGenerator(){
        
         String clientId = '';
        String clientSecret = '';
        String refToken = '';
        String grantType = '';
        String redirectUri = '';
        String Endpoint = '';
        string AccessToken = '';
        
        List<ZohoSign__mdt> zohoMdtList =[SELECT Id, DeveloperName, Client_Secret__c, Client_Id__c, refresh_token__c, code__c, Endpoint__c, grant_type__c, redirect_uri__c FROM ZohoSign__mdt where DeveloperName = 'Access_token'];
        
        for(ZohoSign__mdt  zmd : zohoMdtList){
            clientId = zmd.Client_Id__c;
            clientSecret = zmd.Client_Secret__c;
            refToken = zmd.refresh_token__c;
            grantType = zmd.grant_type__c;
            redirectUri = zmd.redirect_uri__c;
            Endpoint = zmd.Endpoint__c; 
        }
        
        String endpointUrl = Endpoint + 
                                        'refresh_token=' + EncodingUtil.urlEncode(refToken, 'UTF-8') + 
                                        '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') + 
                                        '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') + 
                                        '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8') + 
                                        '&grant_type=' + EncodingUtil.urlEncode(grantType, 'UTF-8');
                                        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
       try {
            HttpResponse response = http.send(request);
           
            if (response.getStatusCode() == 200) {
                System.debug('Response: ' + response.getBody());
                
                ZohoSignGetAccessTokenWrapper resWrap = ZohoSignGetAccessTokenWrapper.parse(response.getBody());
                system.debug('resWrap'+ resWrap);
                
                if(resWrap != Null){
                    AccessToken = resWrap.access_token;
                    system.debug('AccessToken@@' + AccessToken);
                    
                   Zoho_Access_Token__c AccToken = [ SELECT Name, Access_Token__c, Id FROM Zoho_Access_Token__c];
                    AccToken.Access_Token__c = AccessToken;
                    
                    update AccToken;
                }else{
                    AccessToken = '';
                }
               
            } else {
               
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus() );
            }
           
        } catch (Exception e) {
         
            System.debug('Exception: ' + e.getMessage());
        }
    }
}